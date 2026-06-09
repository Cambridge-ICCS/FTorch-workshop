program inference

   use, intrinsic :: iso_fortran_env, only : sp => real32

   ! TODO: Import our library for interfacing with PyTorch
   ! use ftorch, only : ...

   implicit none

   integer, parameter :: wp = sp

   call main()

contains

   subroutine main()

      character(len=128) :: model_file
      integer :: num_args

      ! TODO: Declare torch_model and torch_tensor variables

      ! Fortran data arrays — currently 3D for a single image
      real(wp), dimension(3, 224, 224), target :: in_data
      real(wp), dimension(1000), target :: out_data

      ! Parse command-line argument: <model_file>
      num_args = command_argument_count()
      if (num_args < 1) then
         write (*,*) "Usage: ./resnet_infer_fortran <model_file>"
         write (*,*) "       For batched inference: ./resnet_infer_fortran <model_file> <batch_size>"
         stop 1
      end if
      call get_command_argument(1, model_file)

      call load_data("data/image_tensor.dat", in_data)

      ! TODO: The ResNet model expects a 4-dimensional input tensor with shape
      !       (batch, channels, height, width). Currently in_data is 3D.
      !       You will need to handle this difference. One option is to declare
      !       in_data as a 4D array and reshape.

      ! TODO: Create input and output torch_tensors from the Fortran arrays
      !       using torch_tensor_from_array

      ! TODO: Load the TorchScript model using torch_model_load

      ! TODO: Run inference using torch_model_forward

      ! Print the top result
      call classify("data", out_data)

      ! TODO: Clean up allocated torch objects

   end subroutine main

   subroutine load_data(filename, in_data)

      character(len=*), intent(in) :: filename
      real(wp), dimension(:,:,:), intent(out) :: in_data

      integer :: tensor_length
      real(wp), allocatable :: flat_data(:)
      integer :: ios

      tensor_length = size(in_data)
      allocate(flat_data(tensor_length))

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

   subroutine classify(data_dir, out_data)

      character(len=*), intent(in) :: data_dir
      real(wp), dimension(:), intent(in) :: out_data

      character(len=128), dimension(1000) :: categories
      real(wp), dimension(1000) :: probabilities
      integer :: max_idx, i, ios
      character(len=128) :: cat_file

      ! Apply softmax
      probabilities = exp(out_data)
      probabilities = probabilities / sum(probabilities)

      ! Find top result
      max_idx = maxloc(probabilities, dim=1)

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

      write (*, "(a,', probability ',f6.4)") trim(categories(max_idx)), &
         probabilities(max_idx)

   end subroutine classify

end program inference
