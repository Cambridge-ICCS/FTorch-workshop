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

      ! Set up types of input and output data
      type(torch_model) :: model
      type(torch_tensor), dimension(1) :: in_tensors
      type(torch_tensor), dimension(1) :: out_tensors

      ! Set up Fortran data arrays
      real(wp), dimension(:,:,:,:), allocatable, target :: in_data
      real(wp), dimension(:,:), allocatable, target :: out_data

      ! Tensor dimensions (batch of 1 image: 3 colour channels, 224x224 pixels)
      integer, parameter :: in_dims = 4
      integer, parameter :: in_shape(in_dims) = [1, 3, 224, 224]
      integer, parameter :: out_dims = 2
      integer, parameter :: out_shape(out_dims) = [1, 1000]

      character(len=128) :: data_dir
      character(len=128) :: model_file
      character(len=128) :: tensor_file
      integer, parameter :: tensor_length = 150528

      ! Expected probability for validation
      real(wp), parameter :: expected_prob = 0.8846225142478943_wp
      logical :: test_pass

      ! Parse command-line arguments
      if (command_argument_count() < 1) then
         write (*,*) "Usage: ./resnet_infer_fortran <model_file> [data_dir]"
         stop 1
      end if
      call get_command_argument(1, model_file)
      if (command_argument_count() > 1) then
         call get_command_argument(2, data_dir)
      else
         data_dir = "data"
      end if
      tensor_file = trim(data_dir)//"/image_tensor.dat"

      allocate(in_data(in_shape(1), in_shape(2), in_shape(3), in_shape(4)))
      allocate(out_data(out_shape(1), out_shape(2)))

      call load_data(tensor_file, tensor_length, in_data)

      ! Create input and output torch_tensors from the Fortran arrays
      call torch_tensor_from_array(in_tensors(1), in_data, torch_kCPU)
      call torch_tensor_from_array(out_tensors(1), out_data, torch_kCPU)

      ! Load the TorchScript model
      call torch_model_load(model, model_file, torch_kCPU)

      ! Run inference
      call torch_model_forward(model, in_tensors, out_tensors)

      ! Print top result
      call print_top_result(out_data, data_dir)

      ! Validate against expected probability
      call check_result(out_data, expected_prob, test_pass)

      ! Clean up
      call torch_delete(model)
      call torch_delete(in_tensors)
      call torch_delete(out_tensors)
      deallocate(in_data)
      deallocate(out_data)

      if (.not. test_pass) then
         write (*,*) "Test failed: probability does not match expected value."
         stop 999
      end if

      write (*,*) "ResNet-18 example ran successfully"

   end subroutine main

   subroutine load_data(filename, tensor_length, in_data)

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

   end subroutine load_data

   subroutine print_top_result(out_data, data_dir)

      real(wp), dimension(:,:), intent(in) :: out_data
      character(len=*), intent(in) :: data_dir

      character(len=128), dimension(1000) :: categories
      real(wp), dimension(1000) :: probabilities
      real(wp) :: prob_sum, max_prob
      integer :: max_idx, i, ios
      character(len=128) :: cat_file

      ! Apply softmax
      probabilities = exp(out_data(1, :))
      prob_sum = sum(probabilities)
      probabilities = probabilities / prob_sum

      ! Find top result
      max_idx = 1
      max_prob = probabilities(1)
      do i = 2, 1000
         if (probabilities(i) > max_prob) then
            max_idx = i
            max_prob = probabilities(i)
         end if
      end do

      ! Load categories
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

      write (*,*) "Top result:"
      write (*,*) trim(categories(max_idx)), " (id=", max_idx - 1, &
                 "), probability = ", max_prob

   end subroutine print_top_result

   subroutine check_result(out_data, expected_prob, test_pass)

      real(wp), dimension(:,:), intent(in) :: out_data
      real(wp), intent(in) :: expected_prob
      logical, intent(out) :: test_pass

      real(wp), dimension(1000) :: probabilities
      real(wp) :: prob_sum, max_prob

      probabilities = exp(out_data(1, :))
      prob_sum = sum(probabilities)
      probabilities = probabilities / prob_sum
      max_prob = maxval(probabilities)

      test_pass = isclose(max_prob, expected_prob, rtol=1e-5)

   end subroutine check_result

end program inference
