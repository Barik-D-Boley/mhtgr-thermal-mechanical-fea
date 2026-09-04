# ==============================================================================
# INL Portfolio Project: MHTGR Hexagonal Monolith
# Stage 1: Steady-State Thermal Conduction 
# ==============================================================================

[Mesh]
  # Loads the Exodus II mesh you generated in Cubit
  type = FileMesh
  file = 'hex_monolith.e'
[]

[Variables]
  # Defines the primary unknown variable to solve for (Temperature)
  [T]
    order = FIRST
    family = LAGRANGE
    initial_condition = 300  # Start the simulation at 300 Kelvin
  []
[]

[Kernels]
  # The partial differential equations (PDEs) governing the physics
  [heat_conduction]
    type = HeatConduction
    variable = T
  []
  [heat_source]
    type = BodyForce
    variable = T
    value = 5e6  # Volumetric heat generation from nuclear fuel (W/m^3) - Placeholder
  []
[]

[BCs]
  # Boundary Conditions mapped to your Cubit Sidesets
  [convective_cooling]
    type = ConvectiveHeatFluxBC
    variable = T
    boundary = 'channel_walls'   # Your internal holes sideset
    T_infinity = 600             # Coolant gas temperature (K) - Placeholder
    heat_transfer_coefficient = 2000                   # Heat transfer coefficient (W/m^2-K) - Placeholder
  []
  # Note: MOOSE defaults to perfectly insulated (adiabatic) for any unmentioned boundaries, 
  # so 'outer_walls', 'top_face', and 'bottom_face' are automatically insulated!
[]

[Materials]
  # Assigns physical properties to your volume block
  [graphite_thermal]
    type = HeatConductionMaterial
    block = 'monolith_graphite'  # Your volume block name
    thermal_conductivity = 30    # k for IG-110 graphite (W/m-K) - Placeholder
    specific_heat = 700          # Cp (J/kg-K) - Placeholder
  []
[]

[Executioner]
  # Tells MOOSE how to solve the math (Steady-state vs Transient)
  type = Steady
  solve_type = 'PJFNK'           # Preconditioned JFNK solver (standard for MOOSE)
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
  # Tells MOOSE to write an Exodus file with the results for ParaView
  exodus = true
  print_linear_residuals = false
[]
