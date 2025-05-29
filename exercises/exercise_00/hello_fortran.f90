program hello_fortran

  ! Import the 64-bit real type from the intrinsic iso_fortran_env module
  use, intrinsic :: iso_fortran_env, only : wp => real64

  ! Import the multiply_by_two subroutine from the local math_mod module
  use math_mod, only: multiply_by_two

  ! Do not allow variables to be implicitly typed
  implicit none

  ! Declare a 64-bit real array with 5 entries and set the values
  real(wp) :: input(5) = [ 0.0, 1.0, 2.0, 3.0, 4.0 ]

  ! Declare a 64-bit real array with 5 entries but do not set any values
  real(wp) :: output(5)

  ! Call the multiply_by_two subroutine on the given arrays
  call multiply_by_two(input, output)

  ! Print both arrays to screen
  print *, 'Input:  ', input
  print *, 'Output: ', output

end program hello_fortran
