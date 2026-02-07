
using Freeze
using Test

struct Student
    name::String
    grades::Dict{String, Int}
end

mutable struct Faculty
    name::String
    students::Vector{Student}
end

faculty = Faculty(
    "Mutability and State Management",
    [
        Student(
            "Dave",
            Dict("Math" => 5, "Programming" => 8, "Slacking off" => 10),
        ),
        Student(
            "Mike",
            Dict("English" => 7, "Data structures" => 9, "Finance" => 6),
        ),
    ],
)

frozen_faculty = freeze(faculty)

@testset "All tests" begin
    @test frozen_faculty.name == "Mutability and State Management"
    @test frozen_faculty.students[1].grades["Programming"] == 8

    @test_throws "Cannot change frozen object" push!(
        frozen_faculty.students,
        Student("Denis", Dict("Pet projects" => 5, "Time management" => 5)),
    )

    @test_throws "Cannot change frozen object" frozen_faculty.students[2].grades["Mutation"] = 8

    @test_throws "Cannot change frozen object" frozen_faculty.name = "Immutability and multithreading"
    for stud in frozen_faculty.students
        @test stud isa Frozen
        @test_throws "Cannot change frozen object" stud.grades["NewSubject"] = 10
    end

end