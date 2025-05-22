program inference

   ! Import precision info from iso
   use, intrinsic :: iso_fortran_env, only : sp => real32

   ! Import our library for interfacing with PyTorch
   use :: ftorch, only : &
        torch_kCPU, &
        torch_tensor_from_array, &
        torch_model_load, &
        torch_model_forward, &
        torch_delete, &
        torch_tensor, &
        torch_model

   implicit none

   ! Set working precision for reals
   integer, parameter :: wp = sp

   ! Set up Fortran data structures
   real(wp), dimension(5), target :: in_data
   real(wp), dimension(5), target :: out_data

   ! Set up Torch data structures
   ! The net, a vector of input tensors, and a vector of output tensors
   type(torch_tensor), dimension(1) :: input_tensors
   type(torch_tensor), dimension(1) :: output_tensors
   type(torch_model) :: torch_net

   ! Get TorchScript model file
   character(len=128) :: model_torchscript_file

   ! Initialise data
   in_data = [0.0, 1.0, 2.0, 3.0, 4.0]

   ! Create Torch input/output tensors from the above arrays
   call torch_tensor_from_array(input_tensors(1), in_data, torch_kCPU)
   call torch_tensor_from_array(output_tensors(1), out_data, torch_kCPU)

   ! Load ML model
   model_torchscript_file = 'saved_model.pt'
   call torch_model_load(torch_net, model_torchscript_file, torch_kCPU)

   ! Infer
   call torch_model_forward(torch_net, input_tensors, output_tensors)

   ! Write out the result of calling the net
   write (*,*) out_data(:)

   ! Cleanup
   call torch_delete(input_tensors)
   call torch_delete(output_tensors)
   call torch_delete(torch_net)

end program inference
