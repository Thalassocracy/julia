function randn2!(rng::Union{Xoshiro, TaskLocalRNG}, A::Array{Float64})
    # Basically identical to current implementation
    # Only changes are namespace clarifications
    # Used as performance benchmark
    if length(A) < 7
        for i in eachindex(A)
            @inbounds A[i] = randn(rng, Float64)
        end
    else
        GC.@preserve A rand!(rng, Random.UnsafeView{UInt64}(pointer(A), length(A)))

        for i in eachindex(A)
            @inbounds A[i] = Random._randn(rng, reinterpret(UInt64, A[i]) >>> 12)
        end
    end
    A
end

function randn3!(rng::Union{Xoshiro, TaskLocalRNG}, A::Array{Float64})
    # Similar or slightly slower performance
    if length(A) < 7
        map!((_) -> randn(rng, Float64), A, A)
    else
        GC.@preserve A rand!(rng, Random.UnsafeView{UInt64}(pointer(A), length(A)))
        map!((a) -> Random._randn(rng, reinterpret(UInt64, a) >>> 12), A, A)
    end
    A
end

function randn4!(rng::Union{Xoshiro, TaskLocalRNG}, A::Array{Float64})
    # Similar or slightly slower performance
    if length(A) < 7
        A = randn.(rng, Float64)
    else
        GC.@preserve A rand!(rng, Random.UnsafeView{UInt64}(pointer(A), length(A)))
        map!((a) -> Random._randn(rng, reinterpret(UInt64, a) >>> 12), A, A)
    end
    A
end