using GATlab: getvalue, AlgAxiom
using MarkovCategories: show_latex, show_unicode
using Catlab.WiringDiagrams: WiringDiagram, to_wiring_diagram, boxes, nboxes,
                             input_ports, output_ports

function count_axioms(theory_module)
    theory = theory_module.Meta.theory
    n = 0
    for scope in theory.segments.scopes, binding in scope
        getvalue(binding) isa AlgAxiom && (n += 1)
    end
    return n
end

@testset "theory" begin
    @testset "ThMarkovCategory" begin
        @test ThCopyDiscardCategory === MarkovCategories.ThMonoidalCategoryWithDiagonals
        @test ThMarkovCategory isa Module
        @test count_axioms(ThMarkovCategory) == count_axioms(ThCopyDiscardCategory) + 1
        # Copy naturality is not an axiom: the Markov theory is not cartesian.
        @test count_axioms(MarkovCategories.ThCartesianCategory) >
              count_axioms(ThMarkovCategory)
        @test occursin("delete", sprint(show, ThMarkovCategory.Meta.theory))
    end

    @testset "FinStoch instance" begin
        # The `@instance` binds Catlab's generic functions to the SPEC section 3.2
        # implementations of FiniteKernels.jl; the laws they satisfy are checked
        # numerically in that package's test/test_laws.jl.
        rng = Random.Xoshiro(7)
        X = FiniteSpace(:X, [:a, :b])
        Y = FiniteSpace(:Y, [:u, :v, :w])
        k = random_kernel(rng, X, Y)
        l = random_kernel(rng, Y, X)
        @test dom(k) == k.dom && codom(k) == k.codom
        @test munit(FiniteSpace) == FiniteSpace()
        @test otimes(X, Y) == tensor_space(X, Y) && X ⊗ Y == tensor_space(X, Y)
        @test otimes(X, Y, X) == tensor_space(X, Y, X)
        @test compose(k, l) == compose_kernel(k, l) && k ⋅ l == compose_kernel(k, l)
        @test compose(k, l, k) == compose_kernel(k, l, k)
        @test otimes(k, l) == tensor_kernel(k, l) && k ⊗ l == tensor_kernel(k, l)
        @test otimes(k, l, k) == tensor_kernel(k, l, k)
        @test id(X) == identity_kernel(X)
        @test mcopy(X) == copy_kernel(X) && Δ(X) == copy_kernel(X)
        @test delete(X) == discard_kernel(X) && ◊(X) == discard_kernel(X)
        @test braid(X, Y) == swap_kernel(X, Y) && σ(X, Y) == swap_kernel(X, Y)
    end

    @testset "FreeMarkovCategory expressions" begin
        X, Y, Z = Ob(FreeMarkovCategory, :X, :Y, :Z)
        f = Hom(:f, X, Y)
        g = Hom(:g, Y, Z)
        I = munit(FreeMarkovCategory.Ob)
        @test dom(f) == X && codom(f) == Y
        @test dom(compose(f, g)) == X && codom(compose(f, g)) == Z
        # Normal forms: strict associativity and units.
        @test compose(compose(f, g), Hom(:h, Z, X)) == compose(f, compose(g, Hom(:h, Z, X)))
        @test compose(id(X), f) == f && compose(f, id(Y)) == f
        @test otimes(otimes(X, Y), Z) == otimes(X, otimes(Y, Z))
        @test otimes(X, I) == X && otimes(I, X) == X
        @test f ⋅ g == compose(f, g) && X ⊗ Y == otimes(X, Y)
        # Copy, discard and braid have the right types.
        @test dom(mcopy(X)) == X && codom(mcopy(X)) == otimes(X, X)
        @test dom(delete(X)) == X && codom(delete(X)) == I
        @test dom(braid(X, Y)) == otimes(X, Y) && codom(braid(X, Y)) == otimes(Y, X)
        @test Δ(X) == mcopy(X) && ◊(X) == delete(X) && σ(X, Y) == braid(X, Y)
        expr = compose(mcopy(X), otimes(f, delete(X)))
        @test dom(expr) == X && codom(expr) == Y
        @test occursin("\\Delta", sprint(show_latex, expr))
        @test occursin("mcopy", sprint(show_unicode, expr))
        # n-ary normal form of composition and tensor.
        h = Hom(:h, Z, X)
        @test length(MarkovCategories.args(compose(f, g, h))) == 3
        @test compose(f, compose(g, h)) == compose(f, g, h)
    end

    @testset "evaluation in FinStoch" begin
        rng = Random.Xoshiro(42)
        SX = FiniteSpace(:X, [:x0, :x1])
        SY = FiniteSpace(:Y, [:y0, :y1, :y2])
        SZ = FiniteSpace(:Z, [:z0, :z1])
        k = random_kernel(rng, SX, SY)
        l = random_kernel(rng, SY, SZ)
        p = state(SX, [0.3, 0.7])

        X, Y, Z = Ob(FreeMarkovCategory, :X, :Y, :Z)
        I = munit(FreeMarkovCategory.Ob)
        f = Hom(:f, X, Y)
        g = Hom(:g, Y, Z)
        q = Hom(:p, I, X)
        gens = Dict(:X => SX, :Y => SY, :Z => SZ, :f => k, :g => l, :p => p)

        # A chain X -> Y -> Z: free expression versus direct composition.
        chain = compose(f, g)
        @test evaluate(chain, gens) ≈ compose(k, l)
        @test evaluate(chain, gens) ≈ compose_kernel(k, l)
        @test evaluate(compose(q, chain), gens) ≈ apply(compose(k, l), p)
        @test evaluate(compose(q, f, g), gens) ≈ compose(p, k, l)
        @test evaluate(otimes(X, Y, Z), gens) == otimes(SX, SY, SZ)
        @test evaluate(otimes(f, g, f), gens) ≈ otimes(k, l, k)
        # Objects and the unit.
        @test evaluate(X, gens) == SX
        @test evaluate(otimes(X, Y), gens) == otimes(SX, SY)
        @test evaluate(I, gens) == munit(FiniteSpace)
        # Structural morphisms.
        @test evaluate(id(X), gens) ≈ id(SX)
        @test evaluate(mcopy(X), gens) ≈ mcopy(SX)
        @test evaluate(delete(Y), gens) ≈ delete(SY)
        @test evaluate(braid(X, Y), gens) ≈ braid(SX, SY)
        @test evaluate(compose(f, delete(Y)), gens) ≈ delete(SX)
        # Copy versus tensor, at the level of expressions.
        copied = evaluate(compose(q, mcopy(X)), gens)
        independent = evaluate(otimes(q, q), gens)
        @test copied ≈ compose(p, mcopy(SX))
        @test independent ≈ otimes(p, p)
        @test !(copied ≈ independent)
        # A fan-out wiring: X -> (Y, Z) through two kernels sharing the input.
        h = Hom(:h, X, Z)
        m = random_kernel(rng, SX, SZ)
        gens2 = merge(gens, Dict(:h => m))
        fanout = compose(mcopy(X), otimes(f, h))
        @test evaluate(fanout, gens2) ≈ compose(mcopy(SX), otimes(k, m))
        # Generator-keyed dictionaries work as well as name-keyed ones.
        gens_expr = Dict{Any,Any}(X => SX, Y => SY, Z => SZ, f => k, g => l)
        @test evaluate(chain, gens_expr) ≈ compose(k, l)
        @test evaluate(otimes(X, Z), gens_expr) == otimes(SX, SZ)
        # Missing generators are reported by name.
        @test_throws UnboundGeneratorError evaluate(chain,
                                                    Dict(:X => SX, :Y => SY, :f => k))
        @test_throws UnboundGeneratorError evaluate(chain,
                                                    Dict{Any,Any}(X => SX, Y => SY, f => k))
        err = try
            evaluate(chain, Dict(:X => SX, :Y => SY, :f => k))
        catch e
            e
        end
        @test occursin(":g", sprint(showerror, err))
    end

    @testset "wiring diagrams" begin
        X, Y, Z = Ob(FreeMarkovCategory, :X, :Y, :Z)
        f = Hom(:f, X, Y)
        h = Hom(:h, X, Z)
        # `mcopy(::Ports{ThMarkovCategory.Meta.T}, n)` (src/wiring_diagrams.jl) is
        # what lets Catlab turn a free Markov expression into a wiring diagram:
        # copies are implicit, so a fan-out has one box per generator only.
        d = to_wiring_diagram(compose(mcopy(X), otimes(f, h)))
        @test d isa WiringDiagram
        @test nboxes(d) == 2
        @test Set(b.value for b in boxes(d)) == Set([:f, :h])
        @test input_ports(d) == [:X]
        @test output_ports(d) == [:Y, :Z]
        # Discard is implicit too: `f ⋅ ◊(Y)` keeps the box and drops the wire.
        d2 = to_wiring_diagram(compose(f, delete(Y)))
        @test nboxes(d2) == 1 && output_ports(d2) == Symbol[]
        @test nboxes(to_wiring_diagram(id(X))) == 0
    end
end
