# FinStoch as a model of ThMarkovCategory, and evaluation of free expressions.

"""
    UnboundGeneratorError(name)

Thrown by [`evaluate`](@ref) when a generator of the expression has no image in
the `generators` dictionary.
"""
struct UnboundGeneratorError <: Exception
    name::Any
end

function Base.showerror(io::IO, e::UnboundGeneratorError)
    return print(io, "UnboundGeneratorError: no kernel or space bound to generator ",
                 repr(e.name))
end

# FinStoch: finite spaces and stochastic kernels as a model of ThMarkovCategory.
#
# Registers the Catlab generic functions on FiniteSpace and FiniteKernel so
# that compose, otimes (⊗), id, braid (σ), mcopy (Δ), delete (◊), munit and
# dom/codom all work on kernels. (GATlab attaches a docstring placed here to a
# generated symbol, so the model is documented in this comment and in the
# API page instead.)
@instance ThMarkovCategory{FiniteSpace,FiniteKernel} begin
    dom(k::FiniteKernel) = k.dom
    codom(k::FiniteKernel) = k.codom

    id(X::FiniteSpace) = identity_kernel(X)
    compose(k::FiniteKernel, l::FiniteKernel) = compose_kernel(k, l)

    otimes(X::FiniteSpace, Y::FiniteSpace) = tensor_space(X, Y)
    otimes(k::FiniteKernel, l::FiniteKernel) = tensor_kernel(k, l)
    munit(::Type{FiniteSpace}) = FiniteSpace()

    braid(X::FiniteSpace, Y::FiniteSpace) = swap_kernel(X, Y)
    mcopy(X::FiniteSpace) = copy_kernel(X)
    delete(X::FiniteSpace) = discard_kernel(X)
end

# Free expressions are normalised to n-ary `compose(f, g, h)` and
# `otimes(X, Y, Z)`; fold them so that `evaluate` (and users) can pass more
# than two arguments.
function compose(k::FiniteKernel, l::FiniteKernel, ms::FiniteKernel...)
    return compose(compose(k, l), ms...)
end
otimes(k::FiniteKernel, l::FiniteKernel, ms::FiniteKernel...) = otimes(otimes(k, l), ms...)
otimes(X::FiniteSpace, Y::FiniteSpace, Zs::FiniteSpace...) = otimes(otimes(X, Y), Zs...)

function _evaluate(expr::GATExpr, generators::AbstractDict{Symbol})
    function lookup(e)
        return haskey(generators, first(e)) ? generators[first(e)] :
               throw(UnboundGeneratorError(first(e)))
    end
    return functor((FiniteSpace, FiniteKernel), expr;
                   terms=Dict(:Ob => lookup, :Hom => lookup))
end

function _evaluate(expr::GATExpr, generators::AbstractDict)
    function lookup(e)
        return haskey(generators, e) ? generators[e] :
               throw(UnboundGeneratorError(first(e)))
    end
    return functor((FiniteSpace, FiniteKernel), expr;
                   terms=Dict(:Ob => lookup, :Hom => lookup))
end

# Catlab defines `evaluate(f::HomExpr, xs...)` for compiled Julia programs; the
# methods below are more specific than it, and are split by expression type so
# that no ambiguity arises with `AbstractDict{Symbol}`.
"""
    evaluate(expr, generators::AbstractDict) -> FiniteSpace or FiniteKernel

Evaluate a [`FreeMarkovCategory`](@ref) expression in **FinStoch** by the
structure-preserving functor determined by `generators`, which maps each object
generator to a `FiniteSpace` and each morphism generator to a
`FiniteKernel` (both from `FiniteKernels.jl`). Keys may be the generator
expressions themselves or
their names (`Symbol`s). Every `compose`/`otimes`/`mcopy`/... node is
interpreted by the FinStoch instance of `ThMarkovCategory`. Throws
[`UnboundGeneratorError`](@ref) for a generator that is not in the dictionary.

```jldoctest
julia> X, Y = Ob(FreeMarkovCategory, :X, :Y); f = Hom(:f, X, Y);

julia> SX = FiniteSpace(:X, [:a, :b]); SY = FiniteSpace(:Y, [:u, :v]);

julia> k = cpt(factors(SX), factors(SY)[1], [0.9 0.1; 0.2 0.8]);

julia> evaluate(compose(f, delete(Y)), Dict(:X => SX, :Y => SY, :f => k)) ≈ delete(SX)
true
```
"""
evaluate(expr::HomExpr, generators::AbstractDict) = _evaluate(expr, generators)
evaluate(expr::HomExpr, generators::AbstractDict{Symbol}) = _evaluate(expr, generators)
evaluate(expr::ObExpr, generators::AbstractDict) = _evaluate(expr, generators)
evaluate(expr::ObExpr, generators::AbstractDict{Symbol}) = _evaluate(expr, generators)
