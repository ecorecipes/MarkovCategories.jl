# Exceptions of MarkovCategories (ADR 0013). Every exception the package defines lives in
# this file, with its `showerror` method. The package has a single type of its own, so it
# adds no abstract root: the type subtypes `FiniteKernelsError`, the root of the
# `FiniteKernels` tier it builds on, which the module imports and re-exports. The module
# includes this file first: the type has only a Base field type, and `evaluate` in
# `finstoch_model.jl` throws it.
#
# - Carry the offending generator in the fields and the message. Library code never calls
#   a bare `error("...")`.
# - Invalid arguments and keywords raise `ArgumentError`, not a type from this file.
# - Errors of `FiniteKernels` (a composite whose spaces do not match, for example) pass
#   through the FinStoch instance unchanged.
# - A docstring names another package's type as a code span, never with `@ref`.

"""
    UnboundGeneratorError(name)

Thrown by [`evaluate`](@ref) when a generator of the expression has no image in
the `generators` dictionary. It subtypes `FiniteKernelsError`, the root that
`FiniteKernels.jl` defines and this package re-exports, so one `catch` covers it
and the kernel errors that evaluating an expression can raise.
"""
struct UnboundGeneratorError <: FiniteKernelsError
    name::Any
end

function Base.showerror(io::IO, e::UnboundGeneratorError)
    return print(io, "UnboundGeneratorError: no kernel or space bound to generator ",
                 repr(e.name))
end
