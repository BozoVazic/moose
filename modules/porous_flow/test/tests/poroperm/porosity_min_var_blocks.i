# Minimal correctness test for PorousFlowPorosityLinear's new porosity_min_var parameter.
# Three blocks, one mesh, one run - isolates the parameter as the only difference between
# blocks so a single job proves all three cases at once:
#   block 1: porosity_min_var NOT set at all -> must exactly match block 3's literal-only result
#            (pure regression check: existing behavior unchanged for callers that don't use it)
#   block 2: porosity_min_var coupled to a POSITIVE constant (5e-4) that is LARGER than the
#            scalar porosity_min (1e-5) -> the resulting clamped porosity must equal 5e-4, not 1e-5
#   block 3: porosity_min_var coupled to a NEGATIVE constant (-1) -> must exactly match block 1
#            (explicit-negative-sentinel case, not just the implicit default)
# All three blocks share identical porosity_ref (1e-4) and P_coeff/pressure BC, driven far enough
# below P_ref that the unclamped linear porosity would be negative on all three (well below any
# of the three floors), so every block's porosity is fully clamp-controlled - the test isolates
# the floor value itself, not whether clamping engages.

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 1
    ny = 1
    nz = 3
    xmin = 0
    xmax = 1
    ymin = 0
    ymax = 1
    zmin = 0
    zmax = 3
  []
  [block1]
    type = SubdomainBoundingBoxGenerator
    input = gen
    bottom_left = '0 0 0'
    top_right = '1 1 1'
    block_id = 1
  []
  [block2]
    type = SubdomainBoundingBoxGenerator
    input = block1
    bottom_left = '0 0 1'
    top_right = '1 1 2'
    block_id = 2
  []
  [block3]
    type = SubdomainBoundingBoxGenerator
    input = block2
    bottom_left = '0 0 2'
    top_right = '1 1 3'
    block_id = 3
  []
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 0 0'
[]

[Variables]
  [porepressure]
    initial_condition = 1e3
  []
[]

[AuxVariables]
  [pmin_var_block2]
    family = MONOMIAL
    order = CONSTANT
    initial_condition = 5e-4  # positive, LARGER than the scalar porosity_min=1e-5 below
  []
  [pmin_var_block3]
    family = MONOMIAL
    order = CONSTANT
    initial_condition = -1  # negative sentinel - must fall back to the scalar, same as block1
  []
  [porosity_out]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[AuxKernels]
  [porosity_out]
    type = MaterialRealAux
    property = PorousFlow_porosity_qp
    variable = porosity_out
    execute_on = 'TIMESTEP_END'
  []
[]

[BCs]
  [fix_pressure]
    type = DirichletBC
    variable = porepressure
    boundary = 'left right top bottom front back'
    value = 1e3
  []
[]

[PorousFlowFullySaturated]
  coupling_type = Hydro
  porepressure = porepressure
  fp = simple_fluid
  stabilization = full
[]

[FluidProperties]
  [simple_fluid]
    type = SimpleFluidProperties
    bulk_modulus = 2e9
    density0 = 1000
    viscosity = 1e-3
    thermal_expansion = 0
  []
[]

[Materials]
  [permeability_all]
    type = PorousFlowPermeabilityConst
    permeability = '1e-13 0 0 0 1e-13 0 0 0 1e-13'
    block = '1 2 3'
  []
  [porosity_block1_no_override]
    type = PorousFlowPorosityLinear
    porosity_ref = 1e-4
    P_ref = 1e6
    P_coeff = 1e-6
    porosity_min = 1e-5
    block = 1
  []
  [porosity_block2_positive_override]
    type = PorousFlowPorosityLinear
    porosity_ref = 1e-4
    P_ref = 1e6
    P_coeff = 1e-6
    porosity_min = 1e-5
    porosity_min_var = pmin_var_block2
    block = 2
  []
  [porosity_block3_negative_override]
    type = PorousFlowPorosityLinear
    porosity_ref = 1e-4
    P_ref = 1e6
    P_coeff = 1e-6
    porosity_min = 1e-5
    porosity_min_var = pmin_var_block3
    block = 3
  []
[]

[Postprocessors]
  [porosity_block1]
    type = ElementAverageValue
    variable = porosity_out
    block = 1
  []
  [porosity_block2]
    type = ElementAverageValue
    variable = porosity_out
    block = 2
  []
  [porosity_block3]
    type = ElementAverageValue
    variable = porosity_out
    block = 3
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type'
    petsc_options_value = 'lu'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  dt = 1
  num_steps = 1
  nl_abs_tol = 1e-12
[]

[Outputs]
  csv = true
[]
