
# Freeze.jl

A very simple wrapper structure to make objects fully recursively immutable. It disallows `setproperty!`, `push!`, `append!`, `setindex!` and other mutating operations, but implements `getproperty`, `getindex` and `iterate`, all of which return Frozen for non-bitstype data.
Example:
```julia
julia> using Freeze

julia> struct MyData
        xs::Vector{Int}
        ys::Vector{Int}
    end
julia> data = freeze(MyData([1, 2, 3], [4, 5, 6]))
Frozen{MyData}(MyData([1, 2, 3], [4, 5, 6]))

julia> data.xs[1]
1

julia> data.xs[1] = 10
ERROR: Cannot change frozen object
Stacktrace:
 [1] error(s::String)
   @ Base ./error.jl:35
 [2] _err()
   @ Freeze ~/.../Freeze.jl/src/Freeze.jl:11
 [3] setindex!(::Frozen{Vector{Int64}}, ::Int64, ::Int64)
   @ Freeze ~/.../Freeze.jl/src/Freeze.jl:12
 [4] top-level scope
   @ REPL[4]:1

julia> push!(data.xs, 8)
ERROR: Cannot change frozen object

julia> dict = freeze(Dict{String, MyData}(
    "First" => MyData([1, 2, 3], [4, 5, 6]),
    "Second" => MyData([7, 8, 9], [10, 11, 12]))
    )
Frozen{Dict{String, MyData}}(Dict{String, MyData}("Second" => MyData([7, 8, 9], [10, 11, 12]), "First" => MyData([1, 2, 3], [4, 5, 6])))

julia> for (k, v) in dict
           @show k, v
           @show v.ys[1]
           # iterator over Frozen yeilds Frozen, so the next line will throw if uncommented
           # v.xs[2] = 10
       end
(k, v) = ("Second", Frozen{MyData}(MyData([7, 8, 9], [10, 11, 12])))
v.ys[1] = 10
(k, v) = ("First", Frozen{MyData}(MyData([1, 2, 3], [4, 5, 6])))
v.ys[1] = 4

```

# Interface

`Frozen(x)` - construct Frozen object directly from passed value  
`freeze(x)` - construct Frozen object from a copy of passed value. To customize copying override `clone`. For Frozen arguments, returns the argument.  
`unfreeze(x)` - get a mutable copy of stored data.
