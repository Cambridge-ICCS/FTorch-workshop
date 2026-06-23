program inference

   ! Import precision info from iso
   use, intrinsic :: iso_fortran_env, only : sp => real32

   ! Import our library for interfacing with PyTorch
   use ftorch, only : torch_model, torch_tensor, torch_tensor_from_array, &
                      torch_kCPU, torch_model_load, torch_model_forward

   implicit none

   ! Set working precision for reals
   integer, parameter :: wp = sp

   ! Set up Fortran data structures
   real(wp), dimension(5), target :: in_data
   real(wp), dimension(5), target :: out_data

   ! TODO: Set up Torch data structures
   ! The net, a vector of input tensors (in this case we only have one), and the output tensor

   ! Set Torchscript model path (relative to the build directory)
   character(len=128) :: model_torchscript_file = '../torchscript_simplenet_model_cpu.pt'

   ! Initialise data
   in_data = [0.0, 1.0, 2.0, 3.0, 4.0]

   ! TODO: Create Torch input/output tensors from the above arrays using
   !       `torch_tensor_from_array`

   ! TODO: Load ML model using `torch_model_load`

   ! Print the parameters associated with the pre-trained model
   write (*,*) "Model parameters:"
   call torch_net%print_parameters()

   ! TODO: Run inference on the model using `torch_model_forward`

   ! Write out the result of calling the net
   ! Note: data immediately available in Fortran - no need to 'map'
   write (*,*) "Model output:"
   write (*,*) out_data(:)

end program inference
