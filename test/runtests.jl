using Test
using MarkovCategories
using Random

@testset "MarkovCategories" begin
    include("test_theory.jl")
    include("test_errors.jl")
    include("test_docstrings.jl")
end
