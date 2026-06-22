program inference

   ! Import precision info from iso
   use, intrinsic :: iso_fortran_env, only : sp => real32

   ! Import our library for interfacing with PyTorch
   use ftorch, only : torch_model, torch_tensor, torch_kCPU, &
                      torch_tensor_from_array, torch_model_load, &
                      torch_model_forward, torch_model_print_parameters

   ! Import our tools module for testing utils
   use ftorch_test_utils, only : allclose

   implicit none

   ! Set working precision for reals
   integer, parameter :: wp = sp

   ! Set up Fortran data structures
   real(wp), dimension(5), target :: in_data
   real(wp), dimension(5), target :: out_data
   real(wp), dimension(5) :: expected

   ! Set up Torch data structures
   ! The net, a vector of input tensors, and a vector of output tensors
   type(torch_tensor), dimension(1) :: input_tensors
   type(torch_tensor), dimension(1) :: output_tensors
   type(torch_model) :: torch_net

   ! Set Torchscript model path (relative to the build directory)
   character(len=128) :: model_torchscript_file = '../torchscript_simplenet_model_cpu.pt'

   ! Flag for testing
   logical :: test_pass

   ! Initialise data
   in_data = [0.0, 1.0, 2.0, 3.0, 4.0]

   ! Create Torch input/output tensors from the above arrays
   call torch_tensor_from_array(input_tensors(1), in_data, torch_kCPU)
   call torch_tensor_from_array(output_tensors(1), out_data, torch_kCPU)

   ! Load ML model
   call torch_model_load(torch_net, model_torchscript_file, torch_kCPU)

   ! Print the parameters associated with the pre-trained model
   write (*,*) "Model parameters:"
   call torch_net%print_parameters()

   ! Run inference on the model using `torch_model_forward`
   call torch_model_forward(torch_net, input_tensors, output_tensors)

   ! Write out the result of calling the net
   ! Note: data immediately available in Fortran - no need to 'map'
   write (*,*) "Model output:"
   write (*,*) out_data(:)

   ! Check output tensor matches expected value
   expected = [0.0, 2.0, 4.0, 6.0, 8.0]
   test_pass = allclose(out_data, expected, test_name="SimpleNet", rtol=1e-5)

   if (.not. test_pass) then
     stop 999
   end if

   write (*,*) "SimpleNet example ran successfully"

end program inference
