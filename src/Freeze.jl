module Freeze

export freeze, unfreeze, Frozen

"""A wrapper type that implements getproperty, getindex and other common functions for stored value,
but recursively disallows setproperty! and other mutable functions for it or any of it's subobjects."""
struct Frozen{T}
    val::T
end

__val(v::Frozen) = getfield(v, :val)

_err() = error("Cannot change frozen object")
Base.setindex!(::Frozen, _, _) = _err()
Base.setproperty!(::Frozen, ::Symbol, _) = _err()
Base.push!(::Frozen, _) = _err()
Base.append!(::Frozen, _...) = _err()
Base.sort!(::Frozen) = _err()
Base.delete!(::Frozen, _) = _err()
Base.deleteat!(::Frozen, _) = _err()

function Base.getproperty(self::Frozen, name::Symbol)
    val = getproperty(__val(self), name)
    if !_should_wrap(val)
        return val
    end
    return Frozen(val)
end

function Base.getindex(self::Frozen, idx)
    val = Base.getindex(__val(self), idx)
    if _should_wrap(val)
        return Frozen(val)
    end
    return val
end

function _is_immutable(T::Type)
    if T == String || T == Symbol || isbitstype(T)
        return true
    end
    if T <: Tuple || T <: Pair
        return all(_is_immutable, T.parameters)
    end
    return false
end

function _should_wrap_type(T::Type)
    return !_is_immutable(T)
end

function _should_wrap(::T) where {T}
    return _should_wrap_type(T)
end

function Base.iterate(self::Frozen)
    next = iterate(__val(self))
    if isnothing(next)
        return nothing
    end
    (el, state) = next
    if _should_wrap(el)
        return Frozen(el), state
    end
    return el, state
end

function Base.iterate(self::Frozen, state)
    next = iterate(__val(self), state)
    if isnothing(next)
        return nothing
    end
    (el, state) = next
    if _should_wrap(el)
        return Frozen(el), state
    end
    return el, state
end

function Base.keys(self::Frozen)
    return Frozen(Base.keys(__val(self)))
end

function Base.values(self::Frozen)
    return Frozen(Base.keys(__val(self)))
end

Base.length(self::Frozen) = Base.length(__val(self))
Base.firstindex(self::Frozen) = Base.firstindex(__val(self))
Base.lastindex(self::Frozen) = Base.lastindex(__val(self))

function Base.eltype(self::Frozen)
    t = Base.eltype(__val(self))
    if _should_wrap_type(t)
        return Frozen{t}
    else
        return t
    end
end

clone(x) = deepcopy(x)
clone(x::Frozen) = x

freeze(x::Frozen) = x

"""Makes an immutable copy of passed object. Copying behavior can be customized by
overriding `Freeze.clone`, default implementation is `deepcopy`.
If a copy is undesired, use `Freeze` constructur directly."""
function freeze(x)
    if _should_wrap(x)
        return Frozen(clone(x))
    else
        return x
    end
end

"""Returns an unwrapped copy of stored value"""
unfreeze(x::Frozen) = clone(__val(x))

end
