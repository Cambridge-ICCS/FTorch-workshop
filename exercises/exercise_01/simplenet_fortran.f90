program inference

   ! Import precision info from iso
   use, intrinsic :: iso_fortran_env, only : sp => real32

   ! TODO: Import our library for interfacing with PyTorch

   implicit none

   ! Set working precision for reals
   integer, parameter :: wp = sp

   ! Set up Fortran data structures
   real(wp), dimension(5), target :: in_data
   real(wp), dimension(5), target :: out_data

   ! TODO: Set up Torch data structures
   ! The net, a vector of input tensors (in this case we only have one), and the output tensor

   ! TODO: Get TorchScript model file

   ! Initialise data
   in_data = [0.0, 1.0, 2.0, 3.0, 4.0]

   ! TODO: Create Torch input/output tensors from the above arrays

   ! TODO: Load ML model

   ! TODO: Infer

   ! Write out the result of calling the net
   ! Note: data immediately available in Fortran - no need to 'map'
   write (*,*) out_data(:)

   ! TODO: Cleanup

end program inference
