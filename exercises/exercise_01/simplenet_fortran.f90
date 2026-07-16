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

   ! TODO 1: Declare variables of types `torch_model` and `torch_tensor` variables
   !         - the net and vectors of input tensors (in this case we only have one),
   !         and output tensors. The model should be called `torch_net` in this
   !         example but you can choose names for the tensors. See:
   !         https://cambridge-iccs.github.io/FTorch/type/torch_model.html
   !         https://cambridge-iccs.github.io/FTorch/type/torch_tensor.html

   ! Set Torchscript model path (relative to the build directory)
   character(len=128) :: model_torchscript_file = '../torchscript_simplenet_model_cpu.pt'

   ! Initialise data
   in_data = [0.0, 1.0, 2.0, 3.0, 4.0]

   ! TODO 2: Create Torch input/output tensors from the above arrays using
   !         `torch_tensor_from_array`. See:
   !         https://cambridge-iccs.github.io/FTorch/interface/torch_tensor_from_array.html

   ! TODO 3: Load ML model using `torch_model_load`. See:
   !         https://cambridge-iccs.github.io/FTorch/proc/torch_model_load.html

   ! Print the parameters associated with the pre-trained model
   write (*,*) "Model parameters:"
   call torch_net%print_parameters()

   ! TODO 4: Run inference on the model using `torch_model_forward`. See:
   !         https://cambridge-iccs.github.io/FTorch/proc/torch_model_forward.html

   ! Write out the result of calling the net
   ! Note: data immediately available in Fortran - no need to 'map'
   write (*,*) "Model output:"
   write (*,*) out_data(:)

end program inference
