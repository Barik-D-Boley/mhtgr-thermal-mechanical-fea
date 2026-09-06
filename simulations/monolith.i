# ==============================================================================
# INL Portfolio Project: MHTGR Hexagonal Monolith
# Coupled Steady-State Thermal-Mechanical Analysis
# ==============================================================================

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = '../meshes/monolith.e'
  []
  
  [scale_to_meters]
    type = TransformGenerator
    input = fmg
    transform = SCALE
    vector_value = '0.01 0.01 0.01'
  []

  [pt1]
    type = ExtraNodesetGenerator
    input = scale_to_meters
    new_boundary = 'pin_pt1'
    coord = '0.2078 0.0 0.0'
    tolerance = 0.05
  []
  
  [pt2]
    type = ExtraNodesetGenerator
    input = pt1
    new_boundary = 'pin_pt2'
    coord = '-0.2078 0.0 0.0'
    tolerance = 0.05
  []
  
  [pt3]
    type = ExtraNodesetGenerator
    input = pt2
    new_boundary = 'pin_pt3'
    coord = '0.0 0.0 0.18'
    tolerance = 0.05
  []
[]

[Variables]
  [temperature]
    order = FIRST
    family = LAGRANGE
    initial_condition = 300
  []
[]

[GlobalParams]
  displacements = 'displacement_x displacement_y displacement_z'
[]

[Physics]
  [SolidMechanics]
    [QuasiStatic]
      [all]
        strain = SMALL
        add_variables = true
        eigenstrain_names = thermal_expansion
        generate_output = 'stress_xx stress_yy stress_zz vonmises_stress hydrostatic_stress'
        temperature = temperature
      []
    []
  []
[]

[Kernels]
  [heat_conduction]
    type = HeatConduction
    variable = temperature
  []
  [heat_source]
    type = BodyForce
    variable = temperature
    value = 5e6
  []
[]

[BCs]
  [convective_cooling]
    type = ConvectiveHeatFluxBC
    variable = temperature
    boundary = 'channel_walls'
    T_infinity = 600
    heat_transfer_coefficient = 2000
  []

  [pt1_x]
    type = DirichletBC
    variable = displacement_x
    boundary = pin_pt1
    value = 0
  []
  [pt1_y]
    type = DirichletBC
    variable = displacement_y
    boundary = pin_pt1
    value = 0
  []
  [pt1_z]
    type = DirichletBC
    variable = displacement_z
    boundary = pin_pt1
    value = 0
  []

  [pt2_y]
    type = DirichletBC
    variable = displacement_y
    boundary = pin_pt2
    value = 0
  []
  [pt2_z]
    type = DirichletBC
    variable = displacement_z
    boundary = pin_pt2
    value = 0
  []

  [pt3_y]
    type = DirichletBC
    variable = displacement_y
    boundary = pin_pt3
    value = 0
  []
[]

[Materials]
  # --- Thermal Properties (IG-110 Graphite) ---
  [graphite_conductivity]
    type = ParsedMaterial
    block = 'monolith_graphite'
    property_name = 'thermal_conductivity'
    coupled_variables = 'temperature'
    expression = '9000 / temperature'
  []

  [graphite_heat_capacity]
    type = GenericConstantMaterial
    block = 'monolith_graphite'
    prop_names = 'specific_heat'
    prop_values = '700'
  []

  [elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    block = 'monolith_graphite'
    youngs_modulus = 10e9
    poissons_ratio = 0.14
  []
  [linear_stress]
    type = ComputeLinearElasticStress
    block = 'monolith_graphite'
  []

  [thermal_expansion]
    type = ComputeThermalExpansionEigenstrain
    block = 'monolith_graphite'
    temperature = temperature
    stress_free_temperature = 300
    thermal_expansion_coeff = 4.5e-6
    eigenstrain_name = thermal_expansion
  []
[]

[Executioner]
  type = Steady
  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

[Postprocessors]
  # Finds the maximum temperature across all nodes
  [max_T]
    type = NodalExtremeValue
    variable = temperature
  []
  
  # Finds the maximum von Mises stress across all elements
  [max_vonmises]
    type = ElementExtremeValue
    variable = vonmises_stress
  []
[]

[Outputs]
  exodus = true
  csv = true
  print_linear_residuals = false
[]