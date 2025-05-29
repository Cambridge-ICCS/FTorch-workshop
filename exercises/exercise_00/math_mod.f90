! Define a module containing math utilities
module math_mod

  ! Import the 64-bit real type from the intrinsic iso_fortran_env module
  use, intrinsic :: iso_fortran_env, only : wp => real64

  ! Do not allow variables to be implicitly typed
  implicit none

  ! Module members are set to be private by default, meaning they cannot be used outside the module
  ! definition in this file
  private

  ! Specify that the multiply_by_two subroutine is public, meaning it can be used outside the module
  ! definition
  public multiply_by_two

  contains

    ! Define the multiply_by_two subroutine with two arguments
    subroutine multiply_by_two(input, output)
      ! Specify that the first argument is a rank-1 64-bit real array with unspecified length.
      ! The intent(in) specifies that this is input only and cannot be modified.
      real(wp), dimension(:), intent(in) :: input

      ! Specify that the second argument is a rank-1 64-bit real array with unspecified length.
      ! The intent(out) specifies that this is for input only and any initial values are ignored.
      real(wp), dimension(:), intent(out) :: output

      ! Multiply *each entry* of the input by two. (There is an implicit loop here.)
      output(:) = input * 2.0
    end subroutine multiply_by_two

end module math_mod
