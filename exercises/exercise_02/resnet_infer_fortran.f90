! Template for ResNet-18 inference with FTorch
!
! The TorchScript model accepts a 4D input tensor
!   (batch_size, channels, height, width).
!
! Stage 1: The Fortran arrays are 3D (no batch dimension).
!          Use torch_tensor_from_blob to create a 4D tensor
!          view with batch_size as the first dimension.
!
! Stage 2: Change arrays to 4D and use torch_tensor_from_array.
!          The batch_size CLI arg is already available.

program resnet_infer_fortran
  use, intrinsic :: iso_fortran_env, only : sp => real32
  use ftorch, only: &
    torch_model, &
    torch_tensor, &
    torch_tensor_from_blob, &
    torch_kCPU, &
    torch_kFloat32, &
    torch_model_load, &
    torch_model_forward, &
    torch_delete

  implicit none

  ! TODO 1: Declare torch_model and torch_tensor variables

  integer, parameter :: wp = sp

  integer :: batch_size
  character(len=256) :: model_file
  logical :: file_exists

  integer :: nargs
  character(len=32) :: arg

  ! Model IO — Stage 1 uses 3D arrays
  real(wp), dimension(:,:,:), allocatable, target :: in_data
  real(wp), dimension(:), allocatable, target :: out_data

  ! File paths
  character(len=256) :: in_file

  ! Loop index
  integer :: i

  ! Get the model file from CLI
  nargs = command_argument_count()
  if (nargs < 1) then
    write(*, *) "Usage: ./resnet_infer_fortran <model_file> [batch_size]"
    stop
  end if
  call get_command_argument(1, model_file)
  inquire(file=trim(model_file), exist=file_exists)
  if (.not. file_exists) then
    write(*, *) "Model file not found: ", trim(model_file)
    stop
  end if

  ! Get batch_size from CLI (default 1). Available for Stage 2.
  batch_size = 1
  if (nargs >= 2) then
    call get_command_argument(2, arg)
    read(arg, *) batch_size
  end if
  write(*, *) "Running inference with batch_size = ", batch_size

  ! Stage 1: allocate 3D arrays (single image, no batch dimension)
  allocate(in_data(3, 224, 224))
  allocate(out_data(1000))

  ! Stage 1: load the single-image batch (image_batch_1.dat).
  ! Stage 2: switch to batch_size-dependent filename
  !          (image_batch_N.dat) when arrays become 4D.
  in_file = "data/image_batch_1.dat"
  inquire(file=trim(in_file), exist=file_exists)
  if (.not. file_exists) then
    write(*, *) "Input data file not found: ", trim(in_file)
    stop
  end if
  call load_data(trim(in_file), in_data)
  write(*, *) "Loaded input data from ", trim(in_file)

  ! TODO 2: Create the input and output torch tensors from
  !         the Fortran arrays. The model expects 4D input
  !         (batch_size, 3, 224, 224) and 2D output
  !         (batch_size, 1000), but the arrays are 3D/1D.
  !
  !         HINT: torch_tensor_from_blob(data, n_dims, shape, layout, dtype)
  !         creates a tensor with the given shape from raw data.

  ! TODO 3: Load the TorchScript model using torch_model_load

  ! TODO 4: Run inference using torch_model_forward

  ! TODO 5: Print the classification result for each image
  !         in the batch using the classify subroutine

  ! TODO 6: Clean up using torch_delete

  deallocate(in_data)
  deallocate(out_data)

contains

  subroutine load_data(filename, arr)
    character(len=*), intent(in) :: filename
    real(wp), dimension(:,:,:), intent(out) :: arr

    integer :: unit, sz, ierr
    real(wp), dimension(:), allocatable :: flat

    sz = size(arr)
    allocate(flat(sz))
    open(newunit=unit, file=filename, access="stream", &
         form="unformatted", status="old", iostat=ierr)
    if (ierr /= 0) then
      write(*, *) "Error opening ", filename
      stop
    end if
    read(unit) flat
    close(unit)
    arr = reshape(flat, shape(arr))
    deallocate(flat)
  end subroutine load_data

  subroutine classify(out_data, idx)
    real(wp), dimension(:), intent(in) :: out_data
    integer, intent(in) :: idx

    character(len=256), dimension(1000) :: labels
    integer :: unit, i, max_idx
    real(wp) :: max_val

    call load_labels(labels)

    max_val = -huge(max_val)
    max_idx = 1
    do i = 1, 1000
      if (out_data(i) > max_val) then
        max_val = out_data(i)
        max_idx = i
      end if
    end do

    write(*, "(A, I0, A)") "Image ", idx, ":"
    write(*, "(A, A, A, F6.4)") "  Predicted: ", trim(labels(max_idx)), &
      ", probability ", max_val
  end subroutine classify

  subroutine load_labels(labels)
    character(len=256), dimension(1000), intent(out) :: labels

    integer :: unit, i, ierr
    character(len=256) :: line

    open(newunit=unit, file="data/categories.txt", status="old", iostat=ierr)
    if (ierr /= 0) then
      write(*, *) "Error opening categories.txt"
      stop
    end if
    do i = 1, 1000
      read(unit, "(A)", iostat=ierr) line
      if (ierr /= 0) then
        write(*, *) "Error reading categories.txt at line ", i
        stop
      end if
      labels(i) = trim(adjustl(line))
    end do
    close(unit)
  end subroutine load_labels

end program resnet_infer_fortran
