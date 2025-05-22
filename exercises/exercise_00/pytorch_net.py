"""Module defining a simple PyTorch 'Net' to multiply a tensor by 2.0."""

import torch
from torch import nn


class SimpleNet(nn.Module):
    """PyTorch module multiplying an input vector by 2."""

    def __init__(
        self,
    ) -> None:
        """
        Initialize the SimpleNet model.

        Consists of a single Linear layer with weights predefined to
        multiply the input by 2.
        """
        super().__init__()
        self._fwd_seq = nn.Sequential(
            nn.Linear(5, 5, bias=False),
        )
        with torch.no_grad():
            self._fwd_seq[0].weight = nn.Parameter(2.0 * torch.eye(5))

    def forward(self, batch: torch.Tensor) -> torch.Tensor:
        """
        Pass ``batch`` through the model.

        Parameters
        ----------
        batch : torch.Tensor
            A mini-batch of input vectors of length 5.

        Returns
        -------
        torch.Tensor
            batch scaled by 2.

        """
        return self._fwd_seq(batch)


if __name__ == "__main__":
    # Construct a SimpleNet instance and specify that it will be used for evaluation
    # (as opposed to training)
    model = SimpleNet()
    model.eval()

    # Define an arbitrary input tensor
    input = torch.Tensor([0.0, 1.0, 2.0, 3.0, 4.0])

    # Run inference to obtain an output tensor
    # The torch.no_grad() context specifies that gradient computations should not be
    # performed when executing the indented code.
    with torch.no_grad():
        output = model.forward(input)

    print(f"Input is  {input}.")
    print(f"Output is {output}.")
