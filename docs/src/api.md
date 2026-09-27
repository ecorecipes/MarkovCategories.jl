# API Reference

```@docs
MarkovCategories
```

## Theory and free model

`ThCopyDiscardCategory` is a `const` alias for Catlab's
`ThMonoidalCategoryWithDiagonals`: a symmetric monoidal category in which every
object carries a commutative comonoid (`mcopy`/`Δ`, `delete`/`◊`) coherent with
the tensor product, that is, a copy-discard category.

`ThMarkovCategory` is the GATlab theory `ThCopyDiscardCategory` plus the single
axiom that discarding is natural.

```@docs
ThMarkovCategory
FreeMarkovCategory
evaluate(::MarkovCategories.HomExpr, ::AbstractDict)
```

## The FinStoch instance

The finite stochastic model is registered with
`@instance ThMarkovCategory{FiniteSpace, FiniteKernel}` in
`src/finstoch_model.jl`. It binds the Catlab generic functions `compose`,
`otimes`, `id`, `braid`, `mcopy`, `delete`, `munit`, `dom` and `codom` (with
the operators `⋅`, `⊗`, `σ`, `Δ`, `◊`) to the SPEC section 3.2 implementations
of `FiniteKernels.jl`: `compose_kernel`, `tensor_kernel`, `tensor_space`,
`identity_kernel`, `swap_kernel`, `copy_kernel` and `discard_kernel`. Those
functions, and the whole of the kernel API (`FiniteAxis`, `FiniteSpace`,
`FiniteKernel`, `cpt`, `state`, `marginal`, ...), are re-exported here and
documented in the
[`FiniteKernels.jl` API reference](https://ecorecipes.github.io/FiniteKernels.jl/api/).

`src/wiring_diagrams.jl` adds `mcopy(::Ports{ThMarkovCategory.Meta.T}, n)`, so
that Catlab's `to_wiring_diagram`, `to_graphviz` and `to_tikz` work on
`FreeMarkovCategory` expressions with copies and discards drawn implicitly.

## Exceptions

`UnboundGeneratorError` is the only exception type this package defines. Following
ADR 0013 it subtypes `FiniteKernelsError`, the root of the `FiniteKernels.jl`
tier, rather than adding a root of its own. The root and the five kernel errors
(`InvalidAxisError`, `KernelShapeError`, `KernelEntryError`,
`KernelNormalizationError` and `SpaceMismatchError`) are re-exported here and
documented in the
[`FiniteKernels.jl` API reference](https://ecorecipes.github.io/FiniteKernels.jl/api/).
The FinStoch instance passes the kernel errors through unchanged, so a single
`catch` on `FiniteKernelsError` covers both an unbound generator in
[`evaluate`](@ref) and a bound kernel whose spaces do not fit the expression
(`SpaceMismatchError`).

```@docs
UnboundGeneratorError
```
