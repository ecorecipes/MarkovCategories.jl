# GATlab theories of copy-discard and Markov categories, and the free Markov category.

# ThCopyDiscardCategory
#
# Alias for Catlab's `ThMonoidalCategoryWithDiagonals`: a symmetric monoidal
# category in which every object carries a commutative comonoid
# (`mcopy`/`Δ`, `delete`/`◊`) coherent with the tensor product. Its axioms are
# exactly those of a copy-discard category (Cho and Jacobs 2019; Fritz 2020 --
# see the docstring of `ThMarkovCategory` below for the citations).
# Catlab already ships the theory under the "monoidal category with diagonals"
# name, so this package reuses it rather than redeclaring `mcopy` and `delete`.
# (A docstring cannot be attached to the alias: Julia resolves documentation of
# a module through the module's own binding, so `?ThCopyDiscardCategory` shows
# Catlab's docstring. The alias is documented here and in `ThMarkovCategory`.)
const ThCopyDiscardCategory = ThMonoidalCategoryWithDiagonals

@theory ThMarkovCategory <: ThMonoidalCategoryWithDiagonals begin
    # Naturality of discard: every morphism preserves normalisation.
    f ⋅ ◊(B) == ◊(A) ⊣ [A::Ob, B::Ob, f::(A → B)]
end

@doc """
    ThMarkovCategory

Theory of Markov categories: `ThCopyDiscardCategory` (this package's alias for
Catlab's `ThMonoidalCategoryWithDiagonals`, a symmetric monoidal category with a
coherent commutative comonoid `mcopy`/`delete` on every object, that is, a
copy-discard category) plus the single axiom that discarding is natural, `f ⋅ ◊(B) == ◊(A)` for every `f : A → B`
(every morphism is "causal"). These are the axioms of a Markov category in the
sense of [Fritz2020](@cite), whose copy-discard fragment is the "CD category" of
[ChoJacobs2019](@cite). Copying is deliberately **not** natural: in
**FinStoch**, `f ⋅ Δ(B) ≠ Δ(A) ⋅ (f ⊗ f)` unless `f` is deterministic. This is
the difference between a Markov category and a cartesian one
(`ThCartesianCategory`, where both naturality axioms hold): a symmetric monoidal
category in which every object carries a natural comonoid is cartesian, which is
Fox's theorem [Fox1976](@cite).

The same axioms are given for Mathlib's `CategoryTheory.CopyDiscardCategory` and
`CategoryTheory.MarkovCategory` [Mathlib2020](@cite), which the Lean development
in `proofs/` uses; the `@theory` below and the Lean classes are two statements of
the same axioms, checked to agree by hand rather than mechanically.

The finite stochastic model is registered with
`@instance ThMarkovCategory{FiniteSpace, FiniteKernel}`; the free model is
[`FreeMarkovCategory`](@ref). The complete generated list of operations and
axioms is available as `ThMarkovCategory.Meta.theory`.
""" ThMarkovCategory

@symbolic_model FreeMarkovCategory{ObExpr,HomExpr} ThMarkovCategory begin
    otimes(A::Ob, B::Ob) = associate_unit(new(A, B), munit)
    otimes(f::Hom, g::Hom) = associate(new(f, g))
    compose(f::Hom, g::Hom) = associate_unit(new(f, g; strict=true), id)
end

@doc """
    FreeMarkovCategory

Symbolic (free) model of `ThMarkovCategory`, mirroring Catlab's
`FreeSymmetricMonoidalCategory`: objects are built with
`Ob(FreeMarkovCategory, :X)` and generating morphisms with `Hom(:f, X, Y)`;
`compose`, `otimes`, `id`, `braid`, `mcopy` and `delete` build expressions,
with composition and tensor normalised to be strictly associative and unital.
Evaluate an expression in **FinStoch** with [`evaluate`](@ref).

```jldoctest
julia> X, Y = Ob(FreeMarkovCategory, :X, :Y); f = Hom(:f, X, Y);

julia> expr = compose(mcopy(X), otimes(f, delete(X)));

julia> dom(expr) == X && codom(expr) == Y
true
```
""" FreeMarkovCategory
