"Testing correctness of ParticleDistributions module."

using SpecialFunctions: gamma, gamma_inc
using Cloudy.ParticleDistributions

import Cloudy.ParticleDistributions: nparams, get_params, update_dist!,
                                     check_moment_consistency, moment_func, 
                                     density_func, density
rtol = 1e-3

# Monodisperse distribution
# Initialization
dist = MonodispersePrimitiveParticleDistribution(1.0, 1.0)
@test (dist.n, dist.θ) == (FT(1.0), FT(1.0))
@test_throws Exception MonodispersePrimitiveParticleDistribution(-1.0, 2.)
@test_throws Exception MonodispersePrimitiveParticleDistribution(1.0, -2.)

# Getters and setters
@test nparams(dist) == 2
@test get_params(dist) == ([:n, :θ], [1.0, 1.0])
update_dist!(dist, [1.0, 2.0])
@test get_params(dist) == ([:n, :θ], [1.0, 2.0])
@test_throws Exception update_params(dist, [-0.2, 1.1])
@test_throws Exception update_params(dist, [0.2, -1.1])

# Moments, moments, density
dist = MonodispersePrimitiveParticleDistribution(1.0, 2.0)
@test moment_func(dist)(0.0) == 1.0
@test moment(dist, 1.0) == 2.0
@test moment(dist, 0.0) == 1.0
@test moment(dist, 10.0) == 2.0^10.0

## Update params from moments
update_dist_from_moments!(dist, [1.0, 1.0]; param_range =  Dict("θ" => (0.1, 0.5)))
@test moment(dist, 0.0) ≈ 2.0 rtol=rtol
@test moment(dist, 1.0) ≈ 1.0 rtol=rtol
update_dist_from_moments!(dist, [1.1, 2.0])
@test moment(dist, 0.0) ≈ 1.1 rtol=rtol
@test moment(dist, 1.0) ≈ 2.0 rtol=rtol
update_dist_from_moments!(dist, [1.1, 0.0])
@test moment(dist, 0.0) ≈ 0.0 rtol=rtol
@test moment(dist, 1.0) ≈ 0.0 rtol=rtol


# Exponential distribution
# Initialization
dist = ExponentialPrimitiveParticleDistribution(1.0, 1.0)
@test (dist.n, dist.θ) == (FT(1.0), FT(1.0))
@test_throws Exception ExponentialPrimitiveParticleDistribution(-1.0, 2.)
@test_throws Exception ExponentialPrimitiveParticleDistribution(1.0, -2.)

# Getters and setters
@test nparams(dist) == 2
@test get_params(dist) == ([:n, :θ], [1.0, 1.0])
update_dist!(dist, [1.0, 2.0])
@test get_params(dist) == ([:n, :θ], [1.0, 2.0])
@test_throws Exception update_params(dist, [-0.2, 1.1])
@test_throws Exception update_params(dist, [0.2, -1.1])

# Moments, moments, density
dist = ExponentialPrimitiveParticleDistribution(1.0, 2.0)
@test moment_func(dist)(0.0) == 1.0
@test moment(dist, 1.0) == 2.0
@test moment(dist, 0.0) == 1.0
@test get_moments(dist) == [1.0, 2.0]
@test moment(dist, 10.0) == 2.0^10.0 * gamma(11.0)
@test density_func(dist)(3.1) == 0.5 * exp(-3.1 / 2.0)
@test density_func(dist)(0.0) == 0.5
@test density(dist, 0.0) == 0.5
@test density(dist, 3.1) == 0.5 * exp(-3.1 / 2.0)
@test dist(0.0) == 0.5
@test dist(3.1) == 0.5 * exp(-3.1 / 2.0)
@test_throws Exception density(dist, -3.1)

## Update params or dist from moments
update_dist_from_moments!(dist, [1.1, 2.0])
@test moment(dist, 0.0) ≈ 1.1 rtol=rtol
@test moment(dist, 1.0) ≈ 2.0 rtol=rtol
moments = [10.0, 50.0]
update_dist_from_moments!(dist, moments)
@test (dist.n, dist.θ) == (10.0, 5.0)
@test_throws Exception update_dist_from_moments!(dist, [10.0, 50.0, 300.0])
update_dist_from_moments!(dist, [1.1, 0.0])
@test moment(dist, 0.0) ≈ 0.0 rtol=rtol
@test moment(dist, 1.0) ≈ 0.0 rtol=rtol


# Gamma distribution
# Initialization
dist = GammaPrimitiveParticleDistribution(1.0, 1.0, 2.0)
@test (dist.n, dist.θ, dist.k) == (FT(1.0), FT(1.0), FT(2.0))
@test_throws Exception GammaPrimitiveParticleDistribution(-1.0, 2.0, 3.0)
@test_throws Exception GammaPrimitiveParticleDistribution(1.0, -2.0, 3.0)
@test_throws Exception GammaPrimitiveParticleDistribution(1.0, 2.0, -3.0)

# Getters and settes
@test nparams(dist) == 3
@test get_params(dist) == ([:n, :θ, :k], [1.0, 1.0, 2.0])
update_dist!(dist, [1.0, 2.0, 1.0])
@test get_params(dist) == ([:n, :θ, :k], [1.0, 2.0, 1.0])
@test_throws Exception update_dist!(dist, [-0.2, 1.1, 3.4])
@test_throws Exception update_dist!(dist, [0.2, -1.1, 3.4])
@test_throws Exception update_dist!(dist, [0.2, 1.1, -3.4])

# Moments, moments, density
dist = GammaPrimitiveParticleDistribution(1.0, 1.0, 2.0)
@test moment_func(dist)(0.0) == 1.0
@test moment(dist, 0.0) == 1.0
@test moment(dist, 1.0) == 2.0
@test moment(dist, 2.0) == 6.0
@test get_moments(dist) == [1.0, 2.0, 6.0]
@test moment_func(dist)([0.0, 1.0, 2.0]) == [1.0, 2.0, 6.0]
@test moment(dist, 2/3) ≈ gamma(2+2/3)/gamma(2)
@test density_func(dist)(0.0) == 0.0
@test density_func(dist)(3.0) == 3/gamma(2)*exp(-3)
@test density(dist, 0.0) == 0.0
@test density(dist, 3.0) == 3/gamma(2)*exp(-3)
@test dist(0.0) == 0.0
@test dist(3.0) == 3/gamma(2)*exp(-3)
@test_throws Exception density(dist, -3.1)

# Update params or dist from moments
update_dist_from_moments!(dist, [1.1, 2.0, 4.1]; param_range = Dict("θ" => (1e-5, 1e5), "k" => (eps(Float64), 5.0)))
@test moment(dist, 0.0) ≈ 1.726 rtol=rtol
@test moment(dist, 1.0) ≈ 2.0 rtol=rtol
@test moment(dist, 2.0) ≈ 2.782 rtol=rtol
update_dist_from_moments!(dist, [1.1, 2.423, 8.112])
@test moment(dist, 0.0) ≈ 1.1 rtol=rtol
@test moment(dist, 1.0) ≈ 2.423 rtol=rtol
@test moment(dist, 2.0) ≈ 8.112 rtol=rtol
moments = [10.0, 50.0, 300.0]
update_dist_from_moments!(dist, moments)
@test (dist.n, dist.k, dist.θ) == (10.0, 5.0, 1.0)
@test_throws Exception update_dist_from_moments!(dist, [10.0, 50.0])

# Moment consistency checks
update_dist_from_moments!(dist, [1.1, 0.0, 8.112])
@test moment(dist, 0.0) ≈ 0.0 rtol=rtol
@test moment(dist, 1.0) ≈ 0.0 rtol=rtol
@test moment(dist, 2.0) ≈ 0.0 rtol=rtol

# Moment source helper
dist = MonodispersePrimitiveParticleDistribution(1.0, 0.5)
@test moment_source_helper(dist, 0.0, 0.0, 0.5) ≈ 0.0 rtol = rtol
@test moment_source_helper(dist, 0.0, 0.0, 1.2) ≈ 1.0 rtol = rtol
@test moment_source_helper(dist, 1.0, 0.0, 0.5) ≈ 0.0 rtol = rtol
@test moment_source_helper(dist, 0.0, 1.0, 1.2) ≈ 0.5 rtol = rtol
dist = ExponentialPrimitiveParticleDistribution(1.0, 0.5)
@test moment_source_helper(dist, 0.0, 0.0, 0.5; x_lowerbound = 1e-5, n_bins = 100) ≈ 2.842e-1 rtol = rtol
@test moment_source_helper(dist, 1.0, 0.0, 0.5; x_lowerbound = 1e-5, n_bins = 100) ≈ 4.797e-2 rtol = rtol
@test moment_source_helper(dist, 1.0, 1.0, 0.5; x_lowerbound = 1e-5, n_bins = 100) ≈ 5.142e-3 rtol = rtol
dist = GammaPrimitiveParticleDistribution(1.0, 0.5, 2.0)
@test moment_source_helper(dist, 0.0, 0.0, 0.5; x_lowerbound = 1e-5, n_bins = 100) ≈ 2.056e-2 rtol = rtol
@test moment_source_helper(dist, 1.0, 0.0, 0.5; x_lowerbound = 1e-5, n_bins = 100) ≈ 4.268e-3 rtol = rtol
@test moment_source_helper(dist, 1.0, 1.0, 0.5; x_lowerbound = 1e-5, n_bins = 100) ≈ 6.387e-4 rtol = rtol


# Moment consitency checks
m = [1.1, 2.1]
@test check_moment_consistency(m) == nothing
m = [0.0, 0.0]
@test check_moment_consistency(m) == nothing
m = [0.0, 1.0, 2.0]
@test check_moment_consistency(m) == nothing
m = [1.0, 1.0, 2.0]
@test check_moment_consistency(m) == nothing
m = [-0.1, 1.0]
@test_throws Exception check_moment_consistency(m)
m = [0.1, -1.0]
@test_throws Exception check_moment_consistency(m)
m = [1.0, 3.0, 2.0]
@test_throws Exception check_moment_consistency(m)
