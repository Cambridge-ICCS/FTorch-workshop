program inference

   use, intrinsic :: iso_fortran_env, only : sp => real32

   ! Import our library for interfacing with PyTorch
   use ftorch, only : torch_model, torch_tensor, torch_kCPU, torch_delete, &
                      torch_tensor_from_array, torch_model_load, torch_model_forward

   use ftorch_test_utils, only : isclose

   implicit none

   integer, parameter :: wp = sp

   call main()

contains

   subroutine main()

      ! Torch data structures
      type(torch_model) :: model
      type(torch_tensor), dimension(1) :: in_tensors
      type(torch_tensor), dimension(1) :: out_tensors

      ! Fortran data arrays — 4D with batch dimension
      real(wp), dimension(:,:,:,:), allocatable, target :: in_data
      real(wp), dimension(:,:), allocatable, target :: out_data
      real(wp), dimension(1000) :: out_data_1d

      integer :: batch_size, tensor_length, num_args
      character(len=128) :: model_file, data_dir, tensor_file, arg

      ! Parse command-line arguments
      num_args = command_argument_count()
      if (num_args < 1) then
         write (*,*) "Usage: ./resnet_infer_fortran <model_file> [batch_size] [data_dir]"
         stop 1
      end if
      call get_command_argument(1, model_file)
      if (num_args > 1) then
         call get_command_argument(2, arg)
         read(arg, *) batch_size
      else
         batch_size = 1
      end if
      if (num_args > 2) then
         call get_command_argument(3, data_dir)
      else
         data_dir = "data"
      end if

      ! Allocate 4D arrays with batch dimension
      allocate(in_data(batch_size, 3, 224, 224))
      allocate(out_data(batch_size, 1000))

      tensor_length = batch_size * 3 * 224 * 224
      if (batch_size == 1) then
         tensor_file = trim(data_dir)//"/image_tensor.dat"
      else
         write(tensor_file, "(a,a,i0,a)") trim(data_dir), "/image_batch_", batch_size, ".dat"
      end if
      call load_data_4d(tensor_file, tensor_length, in_data)

      ! Create input and output torch_tensors from the Fortran arrays
      call torch_tensor_from_array(in_tensors(1), in_data, torch_kCPU)
      call torch_tensor_from_array(out_tensors(1), out_data, torch_kCPU)

      ! Load the TorchScript model
      call torch_model_load(model, model_file, torch_kCPU)

      ! Run inference
      call torch_model_forward(model, in_tensors, out_tensors)

      ! Classify the results
      call classify_batch(data_dir, batch_size, out_data)

      ! Clean up
      call torch_delete(model)
      call torch_delete(in_tensors)
      call torch_delete(out_tensors)
      deallocate(in_data)
      deallocate(out_data)

      write (*,*) "ResNet-18 example ran successfully"

   end subroutine main

   subroutine load_data_4d(filename, tensor_length, in_data)

      character(len=*), intent(in) :: filename
      integer, intent(in) :: tensor_length
      real(wp), dimension(:,:,:,:), intent(out) :: in_data

      real(wp) :: flat_data(tensor_length)
      integer :: ios

      open(unit=10, file=filename, status='old', access='stream', &
           form='unformatted', action="read", iostat=ios)
      if (ios /= 0) then
         write (*,*) "Error opening ", trim(filename)
         stop 1
      end if
      read(10) flat_data
      close(10)

      ! Data was transposed in Python before saving so that the order
      ! is consistent with Fortran's column-major memory layout when
      ! reshaped here.
      in_data = reshape(flat_data, shape(in_data))

   end subroutine load_data_4d

   subroutine classify_batch(data_dir, batch_size, out_data)

      character(len=*), intent(in) :: data_dir
      integer, intent(in) :: batch_size
      real(wp), dimension(batch_size, 1000), intent(in) :: out_data

      character(len=128), dimension(1000) :: categories
      real(wp), dimension(1000) :: probabilities
      integer :: indices(batch_size)
      real(wp), dimension(batch_size) :: top_probabilities
      integer :: i, ios
      character(len=128) :: cat_file

      ! Load category labels
      cat_file = trim(data_dir)//"/categories.txt"
      open(unit=11, file=cat_file, status='old', action='read', iostat=ios)
      if (ios /= 0) then
         write (*,*) "Error opening ", trim(cat_file)
         stop 1
      end if
      do i = 1, 1000
         read(11, '(a)', iostat=ios) categories(i)
         if (ios /= 0) exit
      end do
      close(11)

      ! Apply softmax and find top result per batch element
      do i = 1, batch_size
         probabilities = exp(out_data(i, :))
         probabilities = probabilities / sum(probabilities)
         top_probabilities(i) = maxval(probabilities)
         indices(i) = maxloc(probabilities, dim=1)
      end do

      ! Print results
      do i = 1, batch_size
         write (*, "(i0,': ',a,', probability ',f6.4)") i, &
            trim(categories(indices(i))), top_probabilities(i)
      end do

   end subroutine classify_batch

end program inference
