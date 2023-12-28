#!/usr/bin/julia

struct Map
    rock_positions::Array{Tuple{Int, Int}, 1}
    starting_position::Tuple{Int, Int}
    size::Tuple{Int, Int}
end

function parse_input(file_path::String)::Map
    file = open(file_path, "r")
    rock_positions::Array{Tuple{Int, Int}, 1} = []
    line_size::Int = countlines(file_path)
    col_size::Int = 0
    starting_position::Tuple{Int, Int} = (0,0)
    for (i, line) in enumerate(eachline(file))
        col_size = length(line)
        for (j, char) in  enumerate(line)
            if char == '#'
                push!(rock_positions, (i, j))
            elseif char == 'S'
                starting_position = (i, j)
            end
        end
    end
    close(file)
    @assert(line_size == col_size, "Map should be a perfect square!")
    return Map(rock_positions, starting_position, (col_size, line_size))
end

function advance_step(map::Map, position::Tuple{Int, Int})::Array{Tuple{Int, Int}, 1}
    end_positions::Array{Tuple{Int, Int}, 1} = []
    steps::Array{Tuple{Int, Int}, 1} = [(0,1), (1,0), (0,-1), (-1,0)]
    for step in steps
        end_position::Tuple{Int, Int} = (position[1] + step[1], position[2] + step[2])
        if (end_position[1] >= 1 && end_position[1] <= map.size[1]) && (end_position[2] >= 1 && end_position[2] <= map.size[2])
            if !(end_position in map.rock_positions)
                push!(end_positions, end_position)
            end
        end
    end
    return end_positions
end

function compute_reach(map::Map, steps::Int)::Int
    positions::Array{Tuple{Int, Int}, 1}  = [map.starting_position]
    for i in 1:steps
        end_positions::Array{Tuple{Int, Int}, 1} = []
        for position in positions
            next_positions::Array{Tuple{Int, Int}, 1} = advance_step(map, position)
            for next_position in next_positions
                if !(next_position in end_positions)
                    push!(end_positions, next_position)
                end
            end
        end
        positions = end_positions
    end
    return length(positions)
end

function compute_reach_infinite_board(map::Map, steps::Int)::Int
    # BFS over the map
    frontier_positions::Array{Tuple{Tuple{Int, Int}, Int}, 1} = [(map.starting_position, 0)]
    visited_positions::Array{Tuple{Tuple{Int, Int}, Int}, 1}  = [(map.starting_position, 0)]
    while !isempty(frontier_positions)
        position::Tuple{Int, Int}, distance::Int = popfirst!(frontier_positions)
        next_positions::Array{Tuple{Int, Int}, 1} = advance_step(map, position)
        for next_position in next_positions
            if !(any(x -> x[1] == next_position, visited_positions))
                push!(frontier_positions, (next_position, distance+1))
                push!(visited_positions, (next_position, distance+1))
            end
        end
    end
    # Number of squares theat can be reach in the steps informed
    squares::Int = floor(steps / map.size[1])
    # Number of steps to reach the border of the first square
    steps_to_the_border::Int = floor(map.size[1] / 2)
    # Compute number of tiles reach in even and odd steps
    # A detailed explanation to this procedure can be found here:
    # https://github.com/villuna/aoc23/wiki/A-Geometric-solution-to-advent-of-code-2023,-day-21
    count::Tuple{Int, Int} = (0, 0) # (Odd, Even)
    count_corners::Tuple{Int, Int} = (0, 0)
    for (position, distance) in visited_positions
        if distance % 2 == 1 # Odd
            count = (count[1]+1, count[2])
            if distance > steps_to_the_border
                count_corners = (count_corners[1]+1, count_corners[2])
            end
        else # Even
            count = (count[1], count[2]+1)
            if distance > steps_to_the_border
                count_corners = (count_corners[1], count_corners[2]+1)
            end
        end
    end
    return (squares+1)*(squares+1)*count[1] + squares*squares*count[2] - (squares+1)*count_corners[1] + squares*count_corners[2]
end

function part01(file_path::String, steps::Int)::Int
    map::Map = parse_input(file_path)
    return compute_reach(map, steps)
end

function part02(file_path::String)::Int
    map::Map = parse_input(file_path)
    return compute_reach_infinite_board(map, 26501365)
end

function main()
    @assert(part01("sample.txt", 6) == 16, "Part 01 failed for sample.txt")
    part01output::Int = part01("input.txt", 64)
    println("Part 01: $part01output")
    @assert(part01output == 3820, "Part 01 failed for input.txt")
    part02output::Int = part02("input.txt")
    println("Part 02: $part02output")
    @assert(part02output == 632421652138917, "Part 02 failed for input.txt")
end

main()