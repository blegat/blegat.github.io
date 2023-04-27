# **Written by**: Jean Bouchat

# ## Dataset import

using CSV
using DataFrames

df = DataFrame(CSV.File("./Life Expectancy Data.csv", normalizenames=true))

# ## Linear regression

using Plots
using LinearAlgebra
using Statistics

new_df = dropmissing(df)

new_df = new_df[new_df.Year .== 2012, :]

# Data
y = new_df.Life_expectancy
A = new_df.BMI

# Plot the data
scatter(A, y, label="Data")

# Add a column of ones to the right of A'
new_A = hcat(A, ones(length(A)))

# Solve the system Ax=y to find x, i.e., the coefficients of the linear regression model
coefs = new_A\y # Cannot handle missing values

# Plot the regression line
x_plot = minimum(A):maximum(A)
y_plot = coefs[1]*x_plot .+ coefs[2]
label = string(coefs[1], "*x + ", coefs[2])

println("Regression line: $(label)")
println("R = $(cor(new_df.Life_expectancy, new_df.BMI))")

plot!(x_plot, y_plot, label=label)

names(df)

features = ["Life_expectancy", "Total_expenditure", "GDP", 
    "Income_composition_of_resources", "Adult_Mortality", "Schooling"]

for feature in features
    if feature != "Country" && feature != "Year" && feature != "Status"   
        # Data
        y = new_df.Life_expectancy
        A = new_df[:, feature]

        # Preparing the figure
        fig = plot()
        
        # Plot the data
        scatter!(A, y, label="Data")

        # Add a column of ones to the right of A'
        new_A = hcat(A, ones(length(A)))

        # Solve the system Ax=y to find x, i.e., the coefficients of the linear regression model
        coefs = new_A\y # Cannot handle missing values

        # Plot the regression line
        x_plot = range(minimum(A), maximum(A), 100)
        y_plot = coefs[1]*x_plot .+ coefs[2]
        label = string(coefs[1], "*x + ", coefs[2])
        xlabel = feature
        ylabel = "Life expectancy in 2012"
        
        display("Regression line: $(label)")
        
        # Prdicting Life_expectancy from feature using regression model
        y_hat = coefs[1].*A .+ coefs[2]
        
        # Computing correlation coefficient
        display("R = $(cor(y, y_hat))")
        
        plot!(x_plot, y_plot, label=label, xlabel=xlabel, ylabel=ylabel)
        
        # Displaying the figure
        display(fig)
    end
end

# ## Multiple linear regressions

# Data
y = new_df.Life_expectancy

# A is the key to go from single to multiple linear regression !
A = hcat(new_df.Adult_Mortality, new_df.Schooling, ones(size(new_df, 1)))

# Solve the system Ax=y to find x, i.e., the coefficients of the linear regression model
coefs = A\y # Cannot handle missing values

println("Regression line: $(coefs[1])*x1 + $(coefs[2])*x2 + $(coefs[3])")

# Use the regression model to predict Life_expectancy from Adult_Mortality and Schooling
y_hat = coefs[1].*new_df.Adult_Mortality + coefs[2].*new_df.Schooling .+ coefs[3]

# Compute correlation coefficient
println("R = $(cor(y, y_hat))")

#  #### ADD Correlation coefficient and coefficient of determination

# ## Linear regression with JuMP
# 
# https://github.com/odow/jump-training-materials/blob/master/getting_started_with_JuMP.ipynb  
# `JuMP` documentation https://jump.dev/JuMP.jl/stable/  
# `HiGHS` documentation https://www.maths.ed.ac.uk/hall/HiGHS/

# using Pkg
# Pkg.add("JuMP")
# Pkg.add("HiGHS")

using JuMP
using HiGHS # Solver

# Simple linear regression via [least squares](https://en.wikipedia.org/wiki/Least_squares)
# 
# $$\text{minimize}_{a, b} \sum_{i=1}^{N} (y_i-r_i)^2$$
# such that
# $$r_i = ax_i+b, \quad i=1,\ldots,N$$

y = new_df.Life_expectancy
x = new_df.Schooling
N = length(x)

model = Model(HiGHS.Optimizer)

@variable(model, a)
@variable(model, b)
@expression(model, r[i = 1:N], a*x[i] + b)

@objective(model, Min, sum((y[i] - r[i])^2 for i=1:N))

optimize!(model)

@show value(a)
@show value(b);

# ## Homework
# 
# The [diet problem](https://neos-guide.org/content/diet-problem) was one of the first problems in optimization. George Joseph Stigler formulated the problem of the optimal diet in the late 1930s in an attempt to satisfy the concern of the North American army to find the most economical way to feed its troops while at the same time ensuring certain nutritional requirements.
# 
# Your homework consists in solving the diet problem described in [Czyzyk and Wisniewski (1996)](https://ftp.mcs.anl.gov/pub/tech_reports/reports/P602.pdf), Section 2, pp. 2-3, using [`JuMP`](https://jump.dev/JuMP.jl/stable/).
