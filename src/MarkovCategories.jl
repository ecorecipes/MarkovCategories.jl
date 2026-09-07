"""
    MarkovCategories

Markov categories over finite stochastic kernels: the GATlab theory, its free
symbolic model, and the FinStoch instance.

The package is the category-theory layer over `FiniteKernels.jl`, which holds
the numbers:

  - **Syntax**: the GATlab theory `ThMarkovCategory` (Catlab's
    `ThMonoidalCategoryWithDiagonals`, aliased `ThCopyDiscardCategory`, plus
    naturality of discard) and its free model [`FreeMarkovCategory`](@ref), in
    which string-diagram expressions such as
    `compose(mcopy(X), otimes(f, delete(X)))` are built symbolically. The theory,
    the symbolic model and the wiring diagrams are Catlab/GATlab machinery
    [PattersonLynchFairbanks2022](@cite).
  - **Semantics**: the category **FinStoch** of finite state spaces
    (`FiniteSpace`) and stochastic kernels (`FiniteKernel`) from
    `FiniteKernels.jl`, registered as a Catlab `@instance` of
    `ThMarkovCategory` so that `compose`, `otimes`, `id`, `braid`, `mcopy` and
    `delete` dispatch on kernels, and free expressions can be evaluated with
    [`evaluate`](@ref).

Every name of `FiniteKernels.jl` is re-exported, so `using MarkovCategories`
is a superset of `using FiniteKernels`. Packages that need only the numerical
layer should depend on `FiniteKernels.jl` directly, which has no Catlab or
GATlab in its dependency graph.

Axis convention (ADR 0002): a kernel `X → Y` stores its table with the **output
axes first, then the input axes**, `size(table) == (size(Y)..., size(X)...)`, and
is normalised over the output axes for every input index. User-facing conditional
probability tables use the parents-first / child-last layout; `cpt` is
the single documented conversion between the two.

Markov categories in the sense used here are those of [Fritz2020](@cite), whose
copy-discard fragment is [ChoJacobs2019](@cite)'s CD category.

Part of the ecorecipes compositional Bayesian-network ecosystem.
"""
module MarkovCategories

using Catlab
using Catlab.Theories
using GATlab
# Imported by name rather than with a bare `using`: an explicit import shadows the
# implicit exports of `using Catlab`, so a name that both packages happen to export
# (`labels`, `state`, ...) resolves to the FiniteKernels one here and downstream.
using FiniteKernels: FiniteAxis, FiniteSpace, factors, labels, axis_names, state_index,
                     joint_states, tensor_space, DEFAULT_ATOL, FiniteKernel,
                     is_normalized, is_stochastic, normalize, assert_normalized,
                     kernel_matrix, probability, cpt, state, point_mass, dirac, uniform,
                     deterministic, random_kernel, compose_kernel, tensor_kernel,
                     identity_kernel, copy_kernel, discard_kernel, swap_kernel, marginal,
                     apply, InvalidAxisError, KernelShapeError, KernelEntryError,
                     KernelNormalizationError, SpaceMismatchError

import Catlab.Theories: dom, codom, id, compose, otimes, munit, braid, mcopy, delete,
                        Ob, Hom
import Catlab: evaluate

# Re-exported FiniteKernels names, so that `using MarkovCategories` gives the
# whole kernel API alongside the categorical one.
# Spaces
export FiniteAxis, FiniteSpace, factors, labels, axis_names, state_index, joint_states,
       tensor_space
# Kernels
export DEFAULT_ATOL
export FiniteKernel, is_normalized, is_stochastic, normalize, assert_normalized,
       kernel_matrix, probability, cpt, state, point_mass, dirac, uniform, deterministic,
       random_kernel
# SPEC section 3.2 names of the operations the `@instance` binds
export compose_kernel, tensor_kernel, identity_kernel, copy_kernel, discard_kernel,
       swap_kernel, marginal, apply
# FiniteKernels exceptions
export InvalidAxisError, KernelShapeError, KernelEntryError, KernelNormalizationError,
       SpaceMismatchError

# Markov-category operations (Catlab generic functions re-exported)
export dom, codom, id, compose, otimes, munit, braid, mcopy, delete, ⋅, ⊗, Δ, ◊, σ,
       Ob, Hom
# Theory and free model
export ThCopyDiscardCategory, ThMarkovCategory, FreeMarkovCategory, evaluate
# Exceptions of this layer
export UnboundGeneratorError

include("theory.jl")
include("finstoch_model.jl")
include("wiring_diagrams.jl")

end # module
