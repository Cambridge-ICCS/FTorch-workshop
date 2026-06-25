program autograd
  use, intrinsic :: iso_fortran_env, only : sp => real32
  use ftorch, only : assignment(=), operator(-), operator(*), operator(/), &
       torch_kCPU, torch_tensor, torch_tensor_backward, &
       torch_tensor_from_array, torch_tensor_get_gradient, torch_tensor_ones

  implicit none

  ! Set working precision for reals
  integer, parameter :: wp = sp

  ! Declare input/output arrays
  integer, parameter :: ndims = 1
  integer, parameter :: n = 2
  real(wp), dimension(n), target :: in_data1, in_data2
  real(wp), dimension(n), target :: out_data1, out_data2, out_data3
  real(wp), dimension(1), target :: multiplier_value, divisor_value

  ! Declare torch tensors
  type(torch_tensor) :: a, b, Q, multiplier, divisor, dQda, dQdb, &
                        external_gradient

  ! Initialise Torch Tensors from input arrays as in Python example
  in_data1(:) = [2.0_wp, 3.0_wp]
  call torch_tensor_from_array(a, in_data1, torch_kCPU, requires_grad=.true.)
  in_data2(:) = [6.0_wp, 4.0_wp]
  call torch_tensor_from_array(b, in_data2, torch_kCPU, requires_grad=.true.)

  ! TODO 1: Initialise the tensor Q from the first array used for output with
  !         `torch_tensor_from_array`. Recall:
  !         https://cambridge-iccs.github.io/FTorch/interface/torch_tensor_from_array.html

  ! Scalar multiplication and division are not currently implemented in FTorch.
  ! However, you can achieve the same thing by defining a rank-1 tensor with a
  ! single entry, as follows:
  multiplier_value(1) = 3.0_wp
  call torch_tensor_from_array(multiplier, multiplier_value, torch_kCPU)
  divisor_value(1) = 3.0_wp
  call torch_tensor_from_array(divisor, divisor_value, torch_kCPU)

  ! TODO 2: Compute the same mathematical expression as in the Python example
  !         and print it to screen. Does it give the expected value?

  ! Create an external gradient tensor filled with ones for the backpropagation
  call torch_tensor_ones(external_gradient, Q%get_rank(), Q%get_shape(), &
       Q%get_dtype(), Q%get_device_type())

  ! TODO 3: Run the back-propagation operator using `torch_tensor_backward`
  !         with the external gradient. See
  !         https://cambridge-iccs.github.io/FTorch/interface/torch_tensor_backward.html

  ! TODO 4: Create tensors `dQda` and `dQdb` based off output arrays for the
  !         gradients with `torch_tensor_from_array`.

  ! TODO 5: Retrieve the gradient values with `torch_tensor_get_gradient` and
  !         print the corresponding arrays to screen. Do they give the expected
  !         values? See:
  !         https://cambridge-iccs.github.io/FTorch/interface/torch_tensor_get_gradient.html

end program autograd
