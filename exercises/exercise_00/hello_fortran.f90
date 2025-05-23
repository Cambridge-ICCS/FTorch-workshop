program hello_fortran

  use, intrinsic :: iso_fortran_env, only : wp=>real64
  use math_mod, only: multiply_by_two

  implicit none

  real(wp) :: input(5) = [ 0.0, 1.0, 2.0, 3.0, 4.0 ]
  real(wp) :: output(5)

  call multiply_by_two(input, output)

  print *, 'Input:  ', input
  print *, 'Output: ', output

end program hello_fortran
