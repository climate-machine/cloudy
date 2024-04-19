# Unit tests
include("./unit_tests/run_unit_tests.jl")

# Analytical examples
include("./examples/Analytical/box_single_gamma.jl")
include("./examples/Analytical/box_single_lognorm.jl")
include("./examples/Analytical/box_single_gamma_hydro.jl")
include("./examples/Analytical/box_gamma_mixture.jl")
include("./examples/Analytical/box_gamma_mixture_3modes.jl")
include("./examples/Analytical/box_gamma_mixture_4modes.jl")
include("./examples/Analytical/box_lognorm_mixture.jl")
include("./examples/Analytical/box_mono_gamma_mixture.jl")
include("./examples/Analytical/box_gamma_mixture_hydro.jl")
include("./examples/Analytical/box_gamma_mixture_long.jl")
include("./examples/Analytical/condensation_single_gamma.jl")
include("./examples/Analytical/condensation_exp_gamma.jl")
include("./examples/Analytical/rainshaft_single_gamma.jl")
include("./examples/Analytical/rainshaft_gamma_mixture.jl")

# Numerical examples
include("./examples/Numerical/single_particle_exp.jl")
include("./examples/Numerical/single_particle_gamma.jl")
include("./examples/Numerical/n_particles_exp.jl")
include("./examples/Numerical/n_particles_gamma.jl")
include("./examples/Numerical/n_particles_lognorm.jl")
