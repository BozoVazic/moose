# Checks that porosity_min_var replaces porosity_min wherever it is non-negative.
# The porosity AuxVariable is -0.1 everywhere, so every element is floored.  The
# floor AuxVariable is 0.2 in the left element (x < 1) and -1 in the right one,
# so the left element takes the floor 0.2 and the right one porosity_min = 0.05.
[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 2
  xmax = 2
[]

[GlobalParams]
  PorousFlowDictator = dictator
[]

[Variables]
  [pp]
    initial_condition = 1
  []
[]

[AuxVariables]
  [poro_var]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = -0.1
  []
  [floor_var]
    order = CONSTANT
    family = MONOMIAL
  []
  [porosity]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[ICs]
  [floor_var]
    type = FunctionIC
    variable = floor_var
    function = 'if(x < 1, 0.2, -1)'
  []
[]

[AuxKernels]
  [porosity]
    type = PorousFlowPropertyAux
    property = porosity
    variable = porosity
    execute_on = 'initial timestep_end'
  []
[]

[Kernels]
  [mass0]
    type = PorousFlowMassTimeDerivative
    fluid_component = 0
    variable = pp
  []
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'pp'
    number_fluid_phases = 1
    number_fluid_components = 1
  []
[]

[FluidProperties]
  [simple_fluid]
    type = SimpleFluidProperties
  []
[]

[Materials]
  [temperature]
    type = PorousFlowTemperature
  []
  [ppss]
    type = PorousFlow1PhaseFullySaturated
    porepressure = pp
  []
  [massfrac]
    type = PorousFlowMassFraction
  []
  [simple_fluid]
    type = PorousFlowSingleComponentFluid
    fp = simple_fluid
    phase = 0
  []
  [porosity]
    type = PorousFlowPorosityConst
    porosity = poro_var
    porosity_min = 0.05
    porosity_min_var = floor_var
  []
[]

[Postprocessors]
  [porosity_left]
    type = PointValue
    variable = porosity
    point = '0.5 0 0'
    execute_on = 'initial timestep_end'
  []
  [porosity_right]
    type = PointValue
    variable = porosity
    point = '1.5 0 0'
    execute_on = 'initial timestep_end'
  []
[]

[Executioner]
  type = Transient
  solve_type = Newton
  dt = 1
  end_time = 1
  nl_abs_tol = 1E-10
[]

[Outputs]
  csv = true
[]
