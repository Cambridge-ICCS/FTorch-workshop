"""Load a PyTorch model and convert it to TorchScript."""

import os
from typing import Optional

# TODO
# Add a module import with your model here:
import torch


def script_to_torchscript(
    model: torch.nn.Module, filename: Optional[str] = "scripted_model.pt"
) -> None:
    """
    Save PyTorch model to TorchScript using scripting.

    Parameters
    ----------
    model : torch.NN.Module
        a PyTorch model
    filename : str
        name of file to save to
    """
    print("Saving model using scripting...", end="")
    scripted_model = torch.jit.script(model)
    # print(scripted_model.code)
    scripted_model.save(filename)
    print("done.")


def trace_to_torchscript(
    model: torch.nn.Module,
    dummy_input: torch.Tensor,
    filename: Optional[str] = "traced_model.pt",
) -> None:
    """
    Save PyTorch model to TorchScript using tracing.

    Parameters
    ----------
    model : torch.NN.Module
        a PyTorch model
    dummy_input : torch.Tensor
        appropriate size Tensor to act as input to model
    filename : str
        name of file to save to
    """
    print("Saving model using tracing...", end="")
    traced_model = torch.jit.trace(model, dummy_input)
    frozen_model = torch.jit.freeze(traced_model)
    ## print(frozen_model.graph)
    ## print(frozen_model.code)
    frozen_model.save(filename)
    print("done.")


def load_torchscript(filename: Optional[str] = "saved_model.pt") -> torch.nn.Module:
    """
    Load a TorchScript from file.

    Parameters
    ----------
    filename : str
        name of file containing TorchScript model
    """
    model = torch.jit.load(filename)

    return model


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "--device_type",
        help="Device type to run the inference on",
        type=str,
        choices=["cpu", "cuda", "xpu", "mps"],
        default="cpu",
    )
    parser.add_argument(
        "--filepath",
        help="Path to the file containing the PyTorch model",
        type=str,
        default=os.path.dirname(__file__),
    )
    parsed_args = parser.parse_args()
    device_type = parsed_args.device_type
    filepath = parsed_args.filepath

    # =====================================================
    # Load model and prepare for saving
    # =====================================================

    # TODO
    # Load a pre-trained PyTorch model
    # Insert code here to load your model as `trained_model`.
    # trained_model = ...

    # Switch off specific layers/parts of the model that behave
    # differently during training and inference.
    # This may have been done by the user already, so just make sure here.
    trained_model.eval()

    # =====================================================
    # Prepare dummy input and check model runs
    # =====================================================

    # TODO
    # Generate a dummy input Tensor `dummy_input` to the model of appropriate size.
    # trained_model_dummy_input = torch.ones(...)

    # Transfer the model and inputs to GPU device, if appropriate
    if device_type != "cpu":
        device = torch.device(device_type)
        trained_model = trained_model.to(device)
        trained_model.eval()
        trained_model_dummy_input = trained_model_dummy_input.to(device)

    # TODO
    # Run model for dummy inputs

    # =====================================================
    # Save model
    # =====================================================

    # TODO
    # Set the name of the file you want to save the torchscript model to:
    # saved_ts_filename = "..."
    # A filepath may also be provided. To do this, pass the filepath as an argument to
    # this script when it is run from the command line, i.e. `./pt2ts.py path/to/model`.

    # TODO
    # Save the PyTorch model using either scripting (recommended if possible) or tracing
    # -----------
    # Scripting
    # -----------
    # script_to_torchscript(...)

    # -----------
    # Tracing
    # -----------
    # trace_to_torchscript(
    #     trained_model, trained_model_dummy_input, filename=saved_ts_filename
    # )

    print(f"Saved model to TorchScript in '{saved_ts_filename}'.")

    # =====================================================
    # Check model saved OK
    # =====================================================

    # Load torchscript and run model as a test, scaling inputs as above
    trained_model_dummy_input = 2.0 * trained_model_dummy_input
    trained_model_testing_outputs = trained_model(
        trained_model_dummy_input,
    )
    ts_model = load_torchscript(filename=saved_ts_filename)
    ts_model_outputs = ts_model(
        trained_model_dummy_input,
    )

    if not isinstance(ts_model_outputs, tuple):
        ts_model_outputs = (ts_model_outputs,)
    if not isinstance(trained_model_testing_outputs, tuple):
        trained_model_testing_outputs = (trained_model_testing_outputs,)
    for ts_output, output in zip(ts_model_outputs, trained_model_testing_outputs):
        if torch.all(ts_output.eq(output)):
            print("Saved TorchScript model working as expected in a basic test.")
            print("Users should perform further validation as appropriate.")
        else:
            model_error = (
                "Saved Torchscript model is not performing as expected.\n"
                "Consider using scripting if you used tracing, or investigate further."
            )
            raise RuntimeError(model_error)

    # Check that the model file is created
    if not os.path.exists(os.path.join(filepath, saved_ts_filename)):
        torchscript_file_error = (
            f"Saved TorchScript file {os.path.join(filepath, saved_ts_filename)} "
            "cannot be found."
        )
        raise FileNotFoundError(torchscript_file_error)
