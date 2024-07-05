program inference

   ! Import precision info from iso
   use, intrinsic :: iso_fortran_env, only : sp => real32

   ! Import our library for interfacing with PyTorch

   implicit none
  
   ! Set working precision for reals
   integer, parameter :: wp = sp
   
   integer :: num_args, ix
   character(len=128), dimension(:), allocatable :: args

   ! Set up Fortran data structures
   real(wp), dimension(5), target :: in_data
   real(wp), dimension(5), target :: out_data

   ! Set up Torch data structures
   ! The net, a vector of input tensors (in this case we only have one), and the output tensor

   ! Get TorchScript model file

   ! Initialise data
   in_data = [0.0, 1.0, 2.0, 3.0, 4.0]

   ! Create Torch input/output tensors from the above arrays

   ! Load ML model

   ! Infer

   ! Write out the result of calling the net
   write (*,*) out_data(:)

   ! Cleanup

end program inference
