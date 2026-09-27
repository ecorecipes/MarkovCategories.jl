# The exception hierarchy of ADR 0013. The package's one exception type subtypes the root
# `FiniteKernelsError` of the tier it builds on and keeps its module and its unqualified
# name. `using MarkovCategories` promises every name of `FiniteKernels`, so the drift test
# checks that each exception type FiniteKernels exports, the root included, is re-exported
# as the same binding.
using FiniteKernels: FiniteKernels

function owned_exception_types(M)
    types = Type[]
    for n in names(M; all=true)
        isdefined(M, n) || continue
        T = getglobal(M, n)
        T isa Type && T <: Exception && parentmodule(T) === M && push!(types, T)
    end
    return types
end

function exported_exception_names(M)
    return filter(names(M)) do n
        T = getglobal(M, n)
        return T isa Type && T <: Exception
    end
end

@testset "errors" begin
    @testset "hierarchy" begin
        owned = owned_exception_types(MarkovCategories)
        # The search is not vacuous: it finds the package's one type.
        @test UnboundGeneratorError in owned
        for T in owned
            @test T <: FiniteKernelsError
            @test parentmodule(T) === MarkovCategories
            @test string(T) == string(nameof(T))
        end
    end

    @testset "every FiniteKernels exception type is re-exported" begin
        fk = exported_exception_names(FiniteKernels)
        # The root and the five concrete types, at least.
        @test issubset([:FiniteKernelsError, :InvalidAxisError, :KernelShapeError,
                        :KernelEntryError, :KernelNormalizationError, :SpaceMismatchError],
                       fk)
        exported = names(MarkovCategories)
        for n in fk
            @test n in exported
            @test getglobal(MarkovCategories, n) === getglobal(FiniteKernels, n)
        end
    end

    @testset "evaluation errors are caught by the root" begin
        X, Y, Z = Ob(FreeMarkovCategory, :X, :Y, :Z)
        f = Hom(:f, X, Y)
        g = Hom(:g, Y, Z)
        SX = FiniteSpace(:X, [:a, :b])
        SY = FiniteSpace(:Y, [:u, :v])
        SZ = FiniteSpace(:Z, [:p, :q, :r])
        # Tables are stored outputs first, then inputs (ADR 0002).
        k = FiniteKernel(SX, SY, fill(0.5, 2, 2))
        # An unbound generator: this package's own type.
        @test_throws FiniteKernelsError evaluate(compose(f, g),
                                                 Dict(:X => SX, :Y => SY, :f => k))
        # A generator bound to a kernel whose spaces do not match: the FiniteKernels
        # error passes through the FinStoch instance unchanged.
        mismatched = FiniteKernel(SZ, SX, fill(0.5, 2, 3))
        gens = Dict(:X => SX, :Y => SY, :Z => SZ, :f => k, :g => mismatched)
        err = try
            evaluate(compose(f, g), gens)
            nothing
        catch e
            e
        end
        @test err isa SpaceMismatchError
        @test err isa FiniteKernelsError
    end
end
