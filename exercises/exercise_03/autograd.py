"""Autograd demo taken from https://pytorch.org/tutorials/beginner/blitz/autograd_tutorial.html."""

import torch

# Create two arbitrary tensors with requires_grad=True
a = torch.tensor([2.0, 3.0], requires_grad=True)
b = torch.tensor([6.0, 4.0], requires_grad=True)

# Compute some mathematical expression involving the tensors
Q = 3 * (a**3 - b * b / 3)

# TODO: Calculate the value of Q by hand to provide expected values
# Q_expected = 
print(f"Q: expected {Q_expected}, got {Q}")

# Call backpropagation with an external gradient tensor filled with ones
external_grad = torch.tensor([1.0, 1.0])
Q.backward(gradient=external_grad)

# Extract the gradient values using the `grad` property
dQda = a.grad
dQdb = b.grad

# TODO: Calculate the directional derivatives of Q with respect to a and b by hand to
#       provide expected values
# dQda_expected =
# dQdb_expected =
print(f"dQda: expected {dQda_expected}, got {dQda}")
print(f"dQdb: expected {dQdb_expected}, got {dQdb}")
