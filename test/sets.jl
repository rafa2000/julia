# Set tests

# Construction, collect
@test is(typeof(Set([1,2,3])), Set{Int})
@test is(typeof(Set{Int}([3])), Set{Int})
data_in = (1,"banana", ())
s = Set(data_in)
data_out = collect(s)
@test is(typeof(data_out), Array{Any,1})
@test all(map(d->in(d,data_out), data_in))
@test length(data_out) == length(data_in)

# hash
s1 = Set{ASCIIString}(["bar", "foo"])
s2 = Set{ASCIIString}(["foo", "bar"])
s3 = Set{ASCIIString}(["baz"])
@test hash(s1) == hash(s2)
@test hash(s1) != hash(s3)

# isequal
@test  isequal(Set(), Set())
@test !isequal(Set(), Set([1]))
@test  isequal(Set{Any}(Any[1,2]), Set{Int}([1,2]))
@test !isequal(Set{Any}(Any[1,2]), Set{Int}([1,2,3]))
# Comparison of unrelated types seems rather inconsistent
@test  isequal(Set{Int}(), Set{AbstractString}())
@test !isequal(Set{Int}(), Set{AbstractString}([""]))
@test !isequal(Set{AbstractString}(), Set{Int}([0]))
@test !isequal(Set{Int}([1]), Set{AbstractString}())
@test  isequal(Set{Any}([1,2,3]), Set{Int}([1,2,3]))
@test  isequal(Set{Int}([1,2,3]), Set{Any}([1,2,3]))
@test !isequal(Set{Any}([1,2,3]), Set{Int}([1,2,3,4]))
@test !isequal(Set{Int}([1,2,3]), Set{Any}([1,2,3,4]))
@test !isequal(Set{Any}([1,2,3,4]), Set{Int}([1,2,3]))
@test !isequal(Set{Int}([1,2,3,4]), Set{Any}([1,2,3]))

# eltype, similar
s1 = similar(Set([1,"hello"]))
@test isequal(s1, Set())
@test is(eltype(s1), Any)
s2 = similar(Set{Float32}([2.0f0,3.0f0,4.0f0]))
@test isequal(s2, Set())
@test is(eltype(s2), Float32)

# show
@test sprint(show, Set()) == "Set{Any}()"
@test sprint(show, Set(['a'])) == "Set(['a'])"

# isempty, length, in, push, pop, delete
# also test for no duplicates
s = Set(); push!(s,1); push!(s,2); push!(s,3)
@test !isempty(s)
@test in(1,s)
@test in(2,s)
@test length(s) == 3
push!(s,1); push!(s,2); push!(s,3)
@test length(s) == 3
@test pop!(s,1) == 1
@test !in(1,s)
@test in(2,s)
@test length(s) == 2
@test_throws KeyError pop!(s,1)
@test pop!(s,1,:foo) == :foo
@test length(delete!(s,2)) == 1
@test !in(1,s)
@test !in(2,s)
@test pop!(s) == 3
@test length(s) == 0
@test isempty(s)

# copy
data_in = (1,2,9,8,4)
s = Set(data_in)
c = copy(s)
@test isequal(s,c)
v = pop!(s)
@test !in(v,s)
@test  in(v,c)
push!(s,100)
push!(c,200)
@test !in(100,c)
@test !in(200,s)

# sizehint, empty
s = Set([1])
@test isequal(sizehint!(s, 10), Set([1]))
@test isequal(empty!(s), Set())
# TODO: rehash

# start, done, next
for data_in in ((7,8,4,5),
                ("hello", 23, 2.7, (), [], (1,8)))
    s = Set(data_in)

    s_new = Set()
    for el in s
        push!(s_new, el)
    end
    @test isequal(s, s_new)

    t = tuple(s...)
    @test length(t) == length(s)
    for e in t
        @test in(e,s)
    end
end

# union
@test isequal(union(),Set())
@test isequal(union(Set([1])),Set([1]))
s = ∪(Set([1,2]), Set([3,4]))
@test isequal(s, Set([1,2,3,4]))
s = union(Set([5,6,7,8]), Set([7,8,9]))
@test isequal(s, Set([5,6,7,8,9]))
s = Set([1,3,5,7])
union!(s,(2,3,4,5))
@test isequal(s,Set([1,2,3,4,5,7]))

# intersect
@test isequal(intersect(Set([1])),Set([1]))
s = ∩(Set([1,2]), Set([3,4]))
@test isequal(s, Set())
s = intersect(Set([5,6,7,8]), Set([7,8,9]))
@test isequal(s, Set([7,8]))
@test isequal(intersect(Set([2,3,1]), Set([4,2,3]), Set([5,4,3,2])), Set([2,3]))

# setdiff
@test isequal(setdiff(Set([1,2,3]), Set()),        Set([1,2,3]))
@test isequal(setdiff(Set([1,2,3]), Set([1])),     Set([2,3]))
@test isequal(setdiff(Set([1,2,3]), Set([1,2])),   Set([3]))
@test isequal(setdiff(Set([1,2,3]), Set([1,2,3])), Set())
@test isequal(setdiff(Set([1,2,3]), Set([4])),     Set([1,2,3]))
@test isequal(setdiff(Set([1,2,3]), Set([4,1])),   Set([2,3]))
s = Set([1,3,5,7])
setdiff!(s,(3,5))
@test isequal(s,Set([1,7]))
s = Set([1,2,3,4])
setdiff!(s, Set([2,4,5,6]))
@test isequal(s,Set([1,3]))

# ordering
@test Set() < Set([1])
@test Set([1]) < Set([1,2])
@test !(Set([3]) < Set([1,2]))
@test !(Set([3]) > Set([1,2]))
@test Set([1,2,3]) > Set([1,2])
@test !(Set([3]) <= Set([1,2]))
@test !(Set([3]) >= Set([1,2]))
@test Set([1]) <= Set([1,2])
@test Set([1,2]) <= Set([1,2])
@test Set([1,2]) >= Set([1,2])
@test Set([1,2,3]) >= Set([1,2])
@test !(Set([1,2,3]) >= Set([1,2,4]))
@test !(Set([1,2,3]) <= Set([1,2,4]))

# issubset, symdiff
for (l,r) in ((Set([1,2]),     Set([3,4])),
              (Set([5,6,7,8]), Set([7,8,9])),
              (Set([1,2]),     Set([3,4])),
              (Set([5,6,7,8]), Set([7,8,9])),
              (Set([1,2,3]),   Set()),
              (Set([1,2,3]),   Set([1])),
              (Set([1,2,3]),   Set([1,2])),
              (Set([1,2,3]),   Set([1,2,3])),
              (Set([1,2,3]),   Set([4])),
              (Set([1,2,3]),   Set([4,1])))
    @test issubset(intersect(l,r), l)
    @test issubset(intersect(l,r), r)
    @test issubset(l, union(l,r))
    @test issubset(r, union(l,r))
    @test isequal(union(intersect(l,r),symdiff(l,r)), union(l,r))
end
@test ⊆(Set([1]), Set([1,2]))
@test ⊊(Set([1]), Set([1,2]))
@test !⊊(Set([1]), Set([1]))
@test ⊈(Set([1]), Set([2]))
@test symdiff(Set([1,2,3,4]), Set([2,4,5,6])) == Set([1,3,5, 6])

# unique
u = unique([1,1,2])
@test in(1,u)
@test in(2,u)
@test length(u) == 2

# filter
s = Set([1,2,3,4])
@test isequal(filter(isodd,s), Set([1,3]))
filter!(isodd, s)
@test isequal(s, Set([1,3]))

# first
@test_throws ArgumentError first(Set())
@test first(Set(2)) == 2

# ########## end of set tests ##########

## IntSet

# Construction, collect
data_in = (1,5,100)
s = IntSet(data_in)
data_out = collect(s)
@test all(map(d->in(d,data_out), data_in))
@test length(data_out) == length(data_in)

# eltype, similar
@test is(eltype(IntSet()), Int64)
@test isequal(similar(IntSet([1,2,3])), IntSet())

# show
@test sprint(show, IntSet()) == "IntSet([])"
@test sprint(show, IntSet([1,2,3])) == "IntSet([1, 2, 3])"
@test contains(sprint(show, complement(IntSet())), "...,")


s = IntSet([0,1,10,20,200,300,1000,10000,10002])
@test last(s) == 10002
@test first(s) == 0
@test length(s) == 9
@test pop!(s) == 10002
@test length(s) == 8
@test shift!(s) == 0
@test length(s) == 7
@test !in(0,s)
@test !in(10002,s)
@test in(10000,s)
@test_throws ArgumentError first(IntSet())
@test_throws ArgumentError last(IntSet())
t = copy(s)
sizehint!(t, 20000) #check that hash does not depend on size of internal Array{UInt32, 1}
@test hash(s) == hash(t)
@test hash(complement(s)) == hash(complement(t))

@test setdiff(IntSet([1, 2, 3, 4]), IntSet([2, 4, 5, 6])) == IntSet([1, 3])
@test symdiff(IntSet([1, 2, 3, 4]), IntSet([2, 4, 5, 6])) == IntSet([1, 3, 5, 6])

s2 = IntSet([1, 2, 3, 4])
setdiff!(s2, IntSet([2, 4, 5, 6]))

@test s2 == IntSet([1, 3])

# issue #7851
@test_throws ArgumentError IntSet(-1)
@test !(-1 in IntSet(0:10))

# # issue #8570
# This requires 2^29 bytes of storage, which is too much for a simple test
# s = IntSet(2^32)
# @test length(s) == 1
# for b in s; b; end
