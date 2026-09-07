# Catlab wiring-diagram support for free Markov-category expressions.
#
# Catlab converts free expressions to wiring diagrams with
# `to_wiring_diagram(expr)`, which needs to know how copying is drawn for the
# expression's theory. As for `ThMonoidalCategoryWithDiagonals`, copies and
# deletions are implicit (a wire fans out or ends), so
# `to_wiring_diagram`, `to_graphviz` and `to_tikz` work on `FreeMarkovCategory`
# expressions once this method is defined.

using Catlab.WiringDiagrams: Ports, implicit_mcopy

mcopy(A::Ports{ThMarkovCategory.Meta.T}, n::Int) = implicit_mcopy(A, n)
