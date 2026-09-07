# MarkovCategories.jl

Markov categories over finite stochastic kernels: the GATlab theory, its free
symbolic model, and the FinStoch instance.

This is the category-theory layer of the ecorecipes Bayesian-network ecosystem
(`FiniteKernels` → `MarkovCategories` → `BayesianNetworks` →
`BayesianNetworkInference` → `InfluenceDiagrams`). The numbers live one level
down in [`FiniteKernels.jl`](https://ecorecipes.github.io/FiniteKernels.jl/);
this package adds two things on top of them:

- **Syntax.** The GATlab theory `ThMarkovCategory`, which extends Catlab's
  `ThMonoidalCategoryWithDiagonals` (aliased as `ThCopyDiscardCategory`)
  with the single axiom that discarding is natural, and its free model
  [`FreeMarkovCategory`](@ref) in which string-diagram expressions such as
  `compose(mcopy(X), otimes(f, delete(X)))` are built symbolically.
- **Semantics.** The category **FinStoch** of finite state spaces
  (`FiniteSpace`) and stochastic kernels (`FiniteKernel`) from
  `FiniteKernels.jl`, registered as a Catlab `@instance` of `ThMarkovCategory`,
  so that `compose`, `otimes`, `id`, `braid`, `mcopy` and `delete` (and the
  operators `⋅`, `⊗`, `σ`, `Δ`, `◊`) dispatch on kernels, and free expressions
  are evaluated with [`evaluate`](@ref).

Every name of `FiniteKernels.jl` is re-exported, so `using MarkovCategories` is
a superset of `using FiniteKernels`. A package that needs only the numerical
layer should depend on `FiniteKernels.jl` directly: it has neither Catlab nor
GATlab in its dependency graph.

## Quick start

```julia
using MarkovCategories

rain = FiniteAxis(:Rain, [:yes, :no])
grass = FiniteAxis(:Grass, [:wet, :dry])
R, G = FiniteSpace(rain), FiniteSpace(grass)

p = state(R, [0.2, 0.8])                          # I → Rain
k = cpt(rain, grass, [0.9 0.1; 0.2 0.8])          # Rain → Grass, parents-first layout

joint = compose(p, mcopy(R), otimes(id(R), k))    # I → Rain ⊗ Grass
marginal(joint, :Grass).table                     # [0.34, 0.66]

# The same wiring, built symbolically and then interpreted in FinStoch.
X, Y = Ob(FreeMarkovCategory, :Rain, :Grass)
f = Hom(:f, X, Y)
evaluate(compose(f, delete(Y)), Dict(:Rain => R, :Grass => G, :f => k)) ≈ delete(R)
```

## The theory

`ThCopyDiscardCategory` is a `const` alias for Catlab's
`ThMonoidalCategoryWithDiagonals`: a symmetric monoidal category in which every
object carries a commutative comonoid (`mcopy`/`Δ`, `delete`/`◊`) coherent with
the tensor product, that is, a copy-discard category in the sense of
[ChoJacobs2019](@citet).

`ThMarkovCategory` adds the single axiom that discarding is natural,
`f ⋅ ◊(B) == ◊(A)` for every `f : A → B`. In **FinStoch** that axiom *is* the
normalisation condition on a kernel. Copying is deliberately **not** natural:
`f ⋅ Δ(B) ≠ Δ(A) ⋅ (f ⊗ f)` unless `f` is deterministic, which is what separates
a Markov category from a cartesian one [Fox1976](@citet).

The finite model is registered with
`@instance ThMarkovCategory{FiniteSpace, FiniteKernel}` in
`src/finstoch_model.jl`, which binds the Catlab generic functions to the SPEC
section 3.2 implementations of `FiniteKernels.jl`:

| Catlab | `FiniteKernels.jl` |
|---|---|
| `compose(k, l)`, `k ⋅ l` | `compose_kernel(k, l)` |
| `otimes(k, l)`, `k ⊗ l` | `tensor_kernel(k, l)` |
| `otimes(X, Y)`, `X ⊗ Y` | `tensor_space(X, Y)` |
| `id(X)` | `identity_kernel(X)` |
| `mcopy(X)`, `Δ(X)` | `copy_kernel(X)` |
| `delete(X)`, `◊(X)` | `discard_kernel(X)` |
| `braid(X, Y)`, `σ(X, Y)` | `swap_kernel(X, Y)` |
| `munit(FiniteSpace)` | `FiniteSpace()` |

`src/wiring_diagrams.jl` defines `mcopy(::Ports{ThMarkovCategory.Meta.T}, n)`,
which is what lets Catlab's `to_wiring_diagram`, `to_graphviz` and `to_tikz`
draw a free Markov expression with copies and discards implicit.

See the Tutorials section for a rendered vignette and the API Reference for
docstrings.

## References

The package implements, in Julia, constructions from:

- [Fritz2020](@citet), which defines Markov categories and the naturality of
  discard used as the single extra axiom here.
- [ChoJacobs2019](@citet), which defines the underlying copy-discard (CD)
  categories and the string-diagram calculus.
- [Fox1976](@citet), whose theorem identifies the categories in which copying is
  also natural as exactly the cartesian ones.
- [PattersonLynchFairbanks2022](@citet), the Catlab/GATlab framework supplying
  the theory, symbolic model, `@instance` mechanism and wiring diagrams.
- [Mathlib2020](@citet), whose `CopyDiscardCategory`/`MarkovCategory` classes the
  Lean development in `FiniteKernels.jl/proofs/` mirrors.

Full entries are on the [References](references.md) page.
