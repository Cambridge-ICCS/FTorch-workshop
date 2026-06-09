! Solution for ResNet-18 inference with FTorch
!
! Stage 2: 4D arrays with torch_tensor_from_array (dynamic batch_size)
!
! Usage:
!   ./resnet_infer_fortran <model_file>         (batch_size=1)
!   ./resnet_infer_fortran <model_file> <N>     (batch_size=N)

program resnet_infer_fortran
  use ftorch
  implicit none

  integer, parameter :: wp = sp

  integer :: batch_size
  character(len=256) :: model_file
  logical :: file_exists

  integer :: nargs
  character(len=32) :: arg

  ! Model IO — 4D arrays with batch dimension
  real(wp), dimension(:,:,:,:), allocatable, target :: in_data
  real(wp), dimension(:,:), allocatable, target :: out_data

  type(torch_model) :: model
  type(torch_tensor), dimension(1) :: in_tensors, out_tensors

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

  ! Get batch_size from CLI (default 1)
  batch_size = 1
  if (nargs >= 2) then
    call get_command_argument(2, arg)
    read(arg, *) batch_size
  end if
  write(*, *) "Running inference with batch_size = ", batch_size

  ! Allocate 4D arrays with batch dimension
  allocate(in_data(batch_size, 3, 224, 224))
  allocate(out_data(batch_size, 1000))

  ! Load the input data
  write(in_file, "(A, I0, A)") "data/image_batch_", batch_size, ".dat"
  inquire(file=trim(in_file), exist=file_exists)
  if (.not. file_exists) then
    write(*, *) "Input data file not found: ", trim(in_file)
    stop
  end if
  call load_data(trim(in_file), in_data)
  write(*, *) "Loaded input data from ", trim(in_file)

  ! Create torch tensors from Fortran arrays
  call torch_tensor_from_array(in_tensors(1), in_data, torch_kCPU)
  call torch_tensor_from_array(out_tensors(1), out_data, torch_kCPU)

  ! Load the TorchScript model
  call torch_model_load(model, model_file, torch_kCPU)

  ! Run inference
  call torch_model_forward(model, in_tensors, out_tensors)

  ! Classify results for each image in the batch
  do i = 1, batch_size
    call classify(out_data(i, :), i)
  end do

  ! Clean up
  call torch_delete(in_tensors)
  call torch_delete(out_tensors)
  call torch_delete(model)

  deallocate(in_data)
  deallocate(out_data)

contains

  subroutine load_data(filename, arr)
    character(len=*), intent(in) :: filename
    real(wp), dimension(:,:,:,:), intent(out) :: arr

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
  end subroutine

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
