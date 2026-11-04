# Writes a checkpoint of a LAGRANGE variable stored with p_refinement = true, which is how MOOSE stored
# every variable before the p_refinement default became false for continuous non-hierarchic families.
[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 4
    ny = 4
  []
[]

[Variables]
  [u]
    p_refinement = true
  []
[]

[ICs]
  [u]
    type = FunctionIC
    variable = u
    function = '1 + x + 2*y'
  []
[]

[Problem]
  solve = false
[]

[Executioner]
  type = Transient
  num_steps = 1
[]

[Outputs]
  checkpoint = true
[]
