module math_mod

  use, intrinsic :: iso_fortran_env, only : wp=>real64

  implicit none

  private
  public multiply_by_two

  contains

  subroutine multiply_by_two(input, output)
    real(wp), dimension(:), intent(in) :: input
    real(wp), dimension(:), intent(inout) :: output

    output = input * 2.0
  end subroutine

end module math_mod
