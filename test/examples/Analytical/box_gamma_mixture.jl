"Box model with two gamma modes"

using DifferentialEquations

include("../utils/box_model_helpers.jl")
include("../utils/plotting_helpers.jl")

FT = Float64

# Initial condition
moment_init = ArrayPartition([100.0, 10.0, 2], [1e-6, 3e-6, 12e-6])
# 100/cm^3
dist_init = [
    GammaPrimitiveParticleDistribution(FT(100), FT(0.1), FT(1)),    # 100/cm^3; 10^5 µm^3; k=1
    GammaPrimitiveParticleDistribution(FT(1e-6), FT(10), FT(3)),   # 0/cm^3; 10^6 µm^3; k=1
]

# Solver
kernel_func = (x, y) -> 5e-3 * (x + y)
kernel = Array{CoalescenceTensor{FT}}(undef, length(dist_init), length(dist_init))
kernel .= CoalescenceTensor(kernel_func, 1, FT(500))
tspan = (FT(0), FT(120))
NProgMoms = [nparams(dist) for dist in dist_init]
coal_data = initialize_coalescence_data(AnalyticalCoalStyle(), NProgMoms, kernel)
rhs = make_box_model_rhs(AnalyticalCoalStyle())
ODE_parameters =
    (; pdists = dist_init, kernel = kernel, coal_data = coal_data, dist_thresholds = [FT(0.5), Inf], dt = FT(0.5))
prob = ODEProblem(rhs, moment_init, tspan, ODE_parameters)
sol = solve(prob, SSPRK33(), dt = ODE_parameters.dt)

plot_params!(sol, (; pdists = dist_init); file_name = "box_gamma_mixture_params.pdf")
plot_moments!(sol, (; pdists = dist_init); file_name = "box_gamma_mixture_moments.pdf")
plot_spectra!(sol, (; pdists = dist_init); file_name = "box_gamma_mixture_spectra.pdf", logxrange = (-3, 6))
print_box_results!(sol, (; pdists = dist_init))
