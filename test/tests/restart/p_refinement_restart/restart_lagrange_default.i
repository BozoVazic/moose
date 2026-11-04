# Restores the checkpoint of lagrange_p_refinement_true.i into a LAGRANGE variable with the default
# p_refinement (false).  The p_refinement flag does not change the stored degrees of freedom, so u must be
# restored (1 + x + 2y on the unit square: 1 to 4), not left at zero.
[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = lagrange_p_refinement_true_out_cp/LATEST
    skip_partitioning = true
  []
[]

[Variables]
  [u]
  []
[]

[Problem]
  solve = false
  restart_file_base = lagrange_p_refinement_true_out_cp/LATEST
[]

[Postprocessors]
  [u_min]
    type = NodalExtremeValue
    variable = u
    value_type = min
    execute_on = 'initial'
  []
  [u_max]
    type = NodalExtremeValue
    variable = u
    execute_on = 'initial'
  []
[]

[Executioner]
  type = Steady
[]

[Outputs]
  csv = true
[]
