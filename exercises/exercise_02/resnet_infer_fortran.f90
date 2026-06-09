program inference

   use, intrinsic :: iso_fortran_env, only : sp => real32

   ! TODO: Import our library for interfacing with PyTorch
   ! use ftorch, only : ...

   implicit none

   integer, parameter :: wp = sp

   call main()

contains

   subroutine main()

      ! Set up types of input and output data
      ! TODO: Declare torch_model and torch_tensor variables

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

      ! TODO: Create input and output torch_tensors from the Fortran arrays
      !       using torch_tensor_from_array

      ! TODO: Load the TorchScript model using torch_model_load

      ! TODO: Run inference using torch_model_forward

      ! Print top result
      call print_top_result(out_data, data_dir)

      ! TODO: Clean up allocated torch objects and Fortran arrays

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

end program inference
