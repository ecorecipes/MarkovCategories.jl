# MarkovCategories.jl

[![Build Status](https://github.com/ecorecipes/MarkovCategories.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/ecorecipes/MarkovCategories.jl/actions/workflows/CI.yml)
[![Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://ecorecipes.github.io/MarkovCategories.jl/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Markov categories over finite stochastic kernels: the GATlab theory, its free symbolic model, and the FinStoch
instance.

Part of the ecorecipes compositional Bayesian-network ecosystem:
`FiniteKernels.jl` → `MarkovCategories.jl` → `BayesianNetworks.jl` → `BayesianNetworkInference.jl` →
`InfluenceDiagrams.jl`, with `BayesianNetworkFormats.jl` (file formats) and
`EcologicalBayesianNetworks.jl` (model zoo).

The numbers live one level down in [`FiniteKernels.jl`](https://github.com/ecorecipes/FiniteKernels.jl), which
has neither Catlab nor GATlab in its dependency graph. This package adds the category theory. Every name of
`FiniteKernels.jl` is re-exported, so `using MarkovCategories` is a superset of `using FiniteKernels`.

## Features

- GATlab theory `ThMarkovCategory`: Catlab's `ThMonoidalCategoryWithDiagonals` (aliased
  `ThCopyDiscardCategory`) plus the single axiom that discarding is natural.
- `FreeMarkovCategory`, the free symbolic model, in which string-diagram expressions such as
  `compose(mcopy(X), otimes(f, delete(X)))` are built with `Ob`, `Hom`, `compose`, `otimes`, `id`, `braid`,
  `mcopy` and `delete`, normalised to be strictly associative and unital.
- `@instance ThMarkovCategory{FiniteSpace, FiniteKernel}`: the category **FinStoch**, binding Catlab's generic
  functions to the SPEC section 3.2 implementations of `FiniteKernels.jl`.
- `evaluate(expr, generators)`: the structure-preserving functor from free expressions to kernels, with
  `UnboundGeneratorError` for a generator with no image.
- Wiring-diagram support: `to_wiring_diagram`, `to_graphviz` and `to_tikz` work on `FreeMarkovCategory`
  expressions, with copies and discards drawn implicitly.

## Installation

The ecosystem packages are not registered. Install this package and its ecosystem
dependencies by URL, in dependency order:

```julia
using Pkg
Pkg.add(url="https://github.com/ecorecipes/FiniteKernels.jl")
Pkg.add(url="https://github.com/ecorecipes/MarkovCategories.jl")
```

Requires Julia ≥ 1.12.

## Quick Start

```julia
using MarkovCategories

rain = FiniteAxis(:Rain, [:yes, :no])
grass = FiniteAxis(:Grass, [:wet, :dry])
R, G = FiniteSpace(rain), FiniteSpace(grass)

p = state(R, [0.2, 0.8])                          # I → Rain
k = cpt(rain, grass, [0.9 0.1; 0.2 0.8])          # Rain → Grass, table laid out (parent, child)

joint = compose(p, mcopy(R), otimes(id(R), k))    # I → Rain ⊗ Grass
marginal(joint, :Grass).table                     # [0.34, 0.66]

compose(p, mcopy(R)) ≈ otimes(p, p)               # false: copy once is not two samples

# The same wiring as a free expression, evaluated in FinStoch
X, Y = Ob(FreeMarkovCategory, :X, :Y)
f = Hom(:f, X, Y)
q = Hom(:q, munit(FreeMarkovCategory.Ob), X)
expr = compose(q, mcopy(X), otimes(id(X), f))
evaluate(expr, Dict(:X => R, :Y => G, :f => k, :q => p)) ≈ joint   # true
```

## Vignettes

Rendered vignettes live in [`vignettes/`](vignettes/) and are published in the
[documentation](https://ecorecipes.github.io/MarkovCategories.jl/).

## References

The package is an implementation of established constructions rather than new
theory; the works it most directly follows are:

- Fritz, T. (2020). A synthetic approach to Markov kernels, conditional independence and theorems on
  sufficient statistics. *Advances in Mathematics* 370, 107239.
  [doi:10.1016/j.aim.2020.107239](https://doi.org/10.1016/j.aim.2020.107239), arXiv:1908.07021.
- Cho, K. and Jacobs, B. (2019). Disintegration and Bayesian inversion via string diagrams.
  *Mathematical Structures in Computer Science* 29(7), 938-971.
  [doi:10.1017/S0960129518000488](https://doi.org/10.1017/S0960129518000488), arXiv:1709.00322.
- Fox, T. (1976). Coalgebras and cartesian categories. *Communications in Algebra* 4(7), 665-667.
  [doi:10.1080/00927877608822127](https://doi.org/10.1080/00927877608822127).
- Patterson, E., Lynch, O. and Fairbanks, J. (2022). Categorical data structures for technical
  computing. *Compositionality* 4(5).
  [doi:10.32408/compositionality-4-5](https://doi.org/10.32408/compositionality-4-5).
- The mathlib Community (2020). The Lean mathematical library. *CPP 2020*, 367-381.
  [doi:10.1145/3372885.3373824](https://doi.org/10.1145/3372885.3373824).

The full bibliography for the ecosystem is `docs/src/references.bib` (also in
`vignettes/references.bib`); the rendered list is the References page of the
[documentation](https://ecorecipes.github.io/MarkovCategories.jl/).
