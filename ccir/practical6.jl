# Inspired from [a JuMP tutorial](https://jump.dev/JuMP.jl/v1.10.0/tutorials/linear/sudoku)

using JuMP
using HiGHS

# # Sudoku

init_sol = [
    5 3 0 0 7 0 0 0 0
    6 0 0 1 9 5 0 0 0
    0 9 8 0 0 0 0 6 0
    8 0 0 0 6 0 0 0 3
    4 0 0 8 0 3 0 0 1
    7 0 0 0 2 0 0 0 6
    0 6 0 0 0 0 2 8 0
    0 0 0 4 1 9 0 0 5
    0 0 0 0 8 0 0 7 9
]

# ## Integer variables

model = Model(HiGHS.Optimizer)
@variable(model, 1 <= x[row in 1:9, col in 1:9] <= 9, Int)

optimize!(model)
termination_status(model)

solve_time(model)

value.(x)

for row in 1:9
    for col in 1:9
        value = init_sol[row, col]
        if value != 0
            fix(x[row, col], value, force = true)
        end
    end
end

@variable(model, which_one_should_be_satisfied, Bin)
@constraint(model, x[1, 3] - x[1, 4] >= 1 - (1 - which_one_should_be_satisfied) * 10000000)
@constraint(model, -(x[1, 3] - x[1, 4]) >= 1 - which_one_should_be_satisfied * 10000000)

function constraint_alldifferent(x::Vector)
    @assert length(x) == 9
    for i in 1:9
        for j in 1:9
            if i != j
                ## @constraint(model, abs(x[i] - x[j]) >= 1)
                positive = @variable(model, binary = true)
                ## @constraint(model, positive => {x[i] - x[j] >= 1})
                ## Big-M
                M = 9
                @constraint(model, x[i] - x[j] >= 1 - M * (1 - positive))
                ## @constraint(model, !positive => {-(x[i] - x[j]) >= 1})
                @constraint(model, x[j] - x[i] >= 1 - M * positive)
            end
        end
    end
end

for row in 1:9
    constraint_alldifferent(x[row, :])
end

for col in 1:9
    constraint_alldifferent(x[:, col])
end

for shift_row in 0:3:6
    for shift_col in 0:3:6
        constraint_alldifferent(vec(x[shift_row .+ (1:3), shift_col .+ (1:3)]))
    end
end

num_variables(model)

optimize!(model)

solution_summary(model)

value.(x)

# # With Binary variables

model = Model(HiGHS.Optimizer)

@variable(model, y[row = 1:9, col = 1:9, num = 1:9], Bin);

for row in 1:9
    for col in 1:9
        if init_sol[row, col] != 0
            for num in 1:9
                if num == init_sol[row, col]
                    fix(y[row, col, num], 1, force = true)
                else
                    fix(y[row, col, num], 0, force = true)
                end
            end
        end
    end
end

@constraint(model, [row in 1:9, col in 1:9], sum(y[row, col, :]) == 1);

@constraint(model, [row in 1:9, num in 1:9], sum(y[row, :, num]) == 1);

@constraint(model, [col in 1:9, num in 1:9], sum(y[row, col, num] for row in 1:9) == 1);

@constraint(
    model,
    [row_shift in 0:3:6, col_shift in 0:3:6, num in 1:9],
    sum(y[row_shift + row, col_shift + col, num] for row in 1:3, col in 1:3) == 1,
);

optimize!(model)

solution_summary(model)

num_variables(model)

function extract(x)
    nums = zeros(Int, 9, 9)
    for col in 1:9
        for row in 1:9
            for num in 1:9
                if x[row, col, num] > 0.5
                    if nums[row, col] != 0
                        error("Cell ($row, $col) cannot be both $(nums[row, col]) and $num")
                    end
                    nums[row, col] = num
                end
            end
        end
    end
    return nums
end

extract(value.(y))
