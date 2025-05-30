program autograd
  use, intrinsic :: iso_fortran_env, only : sp => real32
  use ftorch, only : torch_tensor, torch_tensor_from_array, torch_kCPU, torch_tensor_backward, &
       torch_tensor_get_gradient

  implicit none

  ! Set working precision for reals
  integer, parameter :: wp = sp

  ! Declare output arrays
  integer, parameter :: ndims = 1
  integer, parameter :: n = 2
  real(wp), dimension(n), target :: out_data1, out_data2, out_data3

  ! Declare torch tensors
  type(torch_tensor) :: a, b, Q, multiplier, divisor, dQda, dQdb

  ! Initialise Torch Tensors from input arrays as in Python example
  call torch_tensor_from_array(a, [2.0_wp, 3.0_wp], torch_kCPU, requires_grad=.true.)
  call torch_tensor_from_array(b, [6.0_wp, 4.0_wp], torch_kCPU, requires_grad=.true.)

  ! TODO: Initialise the tensor Q from the first array used for output with torch_tensor_from_array

  ! Scalar multiplication and division are not currently implemented in FTorch. However, you can
  ! achieve the same thing by defining a rank-1 tensor with a single entry, as follows:
  call torch_tensor_from_array(multiplier, [3.0_wp], torch_kCPU)
  call torch_tensor_from_array(divisor, [3.0_wp], torch_kCPU)

  ! TODO: Compute the same mathematical expression as in the Python example and print it to screen.
  !       Does it give the expected value?

  ! Run the back-propagation operator
  call torch_tensor_backward(Q)

  ! TODO: Create tensors dQda and dQdb based off output arrays for the gradients with
  !       torch_tensor_from_array.

  ! TODO: Retrieve the gradient values with torch_tensor_get_gradient and print the corresponding
  !       arrays to screen. Do they give the expected values?

end program autograd
