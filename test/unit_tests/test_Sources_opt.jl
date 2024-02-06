using Cloudy.ParticleDistributions
using Cloudy.KernelFunctions
using Cloudy.Coalescence:
    weighting_fn,
    q_integrand_inner,
    q_integrand_outer,
    r_integrand_inner,
    r_integrand_outer,
    s_integrand1,
    s_integrand2,
    s_integrand_inner,
    update_R_coalescence_matrix!,
    update_S_coalescence_matrix!,
    update_Q_coalescence_matrix!,
    initialize_coalescence_data,
    get_coalescence_integral_moment_qrs!,
    update_coal_ints!
using Cloudy.Sedimentation
using Cloudy.Condensation
using JET: @test_opt
using QuadGK

# TODO: test analytical cases type stability as well as sedimentation
rtol = 1e-4

# weighting function
dist1a = GammaPrimitiveParticleDistribution(10.0, 100.0, 3.0)
dist1b = ExponentialPrimitiveParticleDistribution(10.0, 100.0)
dist2a = GammaPrimitiveParticleDistribution(1.0, 10.0, 5.0)
dist2b = ExponentialPrimitiveParticleDistribution(10.0, 1000.0)

x = 50.0
y = 20.0
j = 1
k = 2
kernel = LinearKernelFunction(1.0)

for pdists in ([dist1a, dist2a], [dist1b, dist2b])
    @test_opt weighting_fn(10.0, 1, pdists)
    @test_opt weighting_fn(8.0, 2, pdists)

    # q_integrands
    @test_opt q_integrand_inner(x, y, j, k, kernel, pdists)
    @test_opt q_integrand_outer(x, j, k, kernel, pdists, 0.0)
    @test_opt q_integrand_outer(x, j, k, kernel, pdists, 1.0)
    @test_opt q_integrand_outer(x, j, k, kernel, pdists, 1.5)

    # r_integrands
    @test_opt r_integrand_inner(x, y, j, k, kernel, pdists)
    @test_opt r_integrand_outer(x, j, k, kernel, pdists, 0.0)
    @test_opt r_integrand_outer(x, j, k, kernel, pdists, 1.0)

    # s_integrands
    @test_opt s_integrand_inner(x, k, kernel, pdists, 1.0)
    @test_opt s_integrand1(x, k, kernel, pdists, 1.0)
    @test_opt s_integrand2(x, k, kernel, pdists, 1.0)
end



# overall Q R S fill matrices 
# n = 1
@test_opt initialize_coalescence_data(3, 3)
moment_order = 0.0

for pdists in ([dist1a], [dist1a, dist2a])
    cd = initialize_coalescence_data(length(pdists), 3)

    @test_opt update_Q_coalescence_matrix!(moment_order, kernel, pdists, cd.Q)
    @test_opt update_R_coalescence_matrix!(moment_order, kernel, pdists, cd.R)
    @test_opt update_S_coalescence_matrix!(moment_order, kernel, pdists, cd.S)
    @test_opt get_coalescence_integral_moment_qrs!(moment_order, kernel, pdists, cd.Q, cd.R, cd.S)
    @test_opt update_coal_ints!(NumericalCoalStyle(), 3, kernel, pdists, cd)
end

for pdists in ([dist1b], [dist1b, dist2b])
    cd = initialize_coalescence_data(length(pdists), 2)

    @test_opt update_Q_coalescence_matrix!(moment_order, kernel, pdists, cd.Q)
    @test_opt update_R_coalescence_matrix!(moment_order, kernel, pdists, cd.R)
    @test_opt update_S_coalescence_matrix!(moment_order, kernel, pdists, cd.S)
    @test_opt get_coalescence_integral_moment_qrs!(moment_order, kernel, pdists, cd.Q, cd.R, cd.S)
    @test_opt update_coal_ints!(NumericalCoalStyle(), 2, kernel, pdists, cd)
end

## Sedimentation.jl
# Sedimentation moment flux tests
par = (; pdists = [ExponentialPrimitiveParticleDistribution(1.0, 1.0)], vel = [(1.0, 0.0), (-1.0, 1.0 / 6)])
@test_opt get_sedimentation_flux(par)

## Condensation.jl
# Condensation moment tests
par = (; pdists = [ExponentialPrimitiveParticleDistribution(1.0, 1.0)], ξ = 1e-6)
@test_opt get_cond_evap(0.01, par) 