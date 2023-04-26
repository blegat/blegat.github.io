# # Practical 1 &ndash; Linear regressions
#
#md # ~~~
#md # <a href="@__BINDER_ROOT_URL__/../generated/notebooks/pratical1.ipynb"><span class="badge">
#md # ~~~
#md # ![](https://mybinder.org/badge_logo.svg)
#md # ~~~
#md # </span></a>
#md # ~~~
#md # ~~~
#md # <a href="@__NBVIEWER_ROOT_URL__/../generated/notebooks/practical1.ipynb"><span class="badge">
#md # ~~~
#md # ![](https://img.shields.io/badge/show-nbviewer-579ACA.svg)
#md # ~~~
#md # </span></a>
#md # ~~~
#
# **Written by**: Jean Bouchat
# 
# ---
# 
# In this session, we'll get right into coding to import, visualize, and analyze a dataset gathered by the World Health Organization (WHO) on life expectancy. The goal is to familiarize yourself with Julia, the use of a Jupyter notebook, and get an overview of one of the most popular data analysis methods in research, linear regression.

# ## Dataset import

# The very first step in any data analysis is to get the data. We downloaded the ones we will use today on [Kaggle](https://www.kaggle.com/datasets/kumarajarshi/life-expectancy-who).
# 
# The data set we want to exploit is contained in a csv file, and Julia is not able to open these files natively. Two separate libraries are actually needed: `CSV` et `DataFrames` [go further: Read CSV to Data Frame in Julia](https://towardsdatascience.com/read-csv-to-data-frame-in-julia-programming-lang-77f3d0081c14).
# 
# Let us install them, if it is not already done,

using Pkg
Pkg.add("CSV")
Pkg.add("DataFrames")

# and then import them to be able to actually use them

using CSV
using DataFrames

# We can now read the csv file that we want to explore

csv_file = CSV.File("./Life Expectancy Data.csv")

for row in csv_file[1:3]
    println(row)
end

# As you can see, while `CSV` allows us to read (and write) into csv files, it is not made for data manipulation. The `DataFrames` package is much more convenient for manipulating data tables. Check out its documentation https://dataframes.juliadata.org/stable/ if you want to learn more about it.
# 
# Let us now generate a dataframe with the contents of our csv file.

df = DataFrame(csv_file)

# To get a first understanding of the data table we are exploring, let us have a look at the names of its columns

names(df)

# and select the rows of the dataframe that relate to Afghanistan

df[df.:"Country" .== "Afghanistan", :]

# ## Cleaning names
# 
# The spaces in the names makes it cumbersome to access.

df.:"Life expectancy "

# The keyword `normalizenames` removes trailing whitespaces and replace inner spaces by `_`.

csv_file = CSV.File("./Life Expectancy Data.csv", normalizenames=true)

df = DataFrame(csv_file)

names(df)

# ## Dataset exploration

# What we want to learn is if there is a link between life expectancy throughout the world and other demographic variables.

df.Life_expectancy

# Visualizing the data is ususally the main driver to understanding what they mean. For this, we need yet another package, `Plots`. Check out its documentation https://docs.juliaplots.org/stable/ if you want to learn more about it.

Pkg.add("Plots")

using Plots

# To learn more about the evolution of life expectancy in Afghanistan through the recent years, we will plot its time series

x = df[df.Country .== "Afghanistan", :].Year
y = df[df.Country .== "Afghanistan", :].Life_expectancy

plot(x, y, label="Afghanistan", title="Life expectancy", ylabel="Life expectancy", markershape=:circle)

# But it does not tell us much by itself. Often, comparisons allows for a more intimate understanding of such quantities, but we do not know which countries are actually listed in the dataset. We can find out by printing their names 

for country in unique(df, :Country).Country
    println(country)
end

# and plot time series of life expectancy for countries you might be familiar with

fig = plot()
for country in ["Belgium", "Canada", "China", "Singapore", "United States of America"]
    y = df[df.Country .== country, :].Life_expectancy
    plot!(x, y, label=country, markershape=:circle)
end
display(fig)

# To begin to understand the relationship between life expectancy and the other features given in this table, let us reduce our analysis to the year 2012 (for the example)

df = df[df.Year .== 2012, :];

# and generate a scatter plot of life expectancy and BMI

y = df.Life_expectancy
x = df.BMI

println(x)

scatter(x, y, ylabel="Life expectancy", xlabel="BMI")

# ## Linear regression analysis

# `LinearAlgebra` is standard library of Julia. It provides native implementations of the most common linear algebra operations. Check out its documentation https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/ to learn more about it.
# 
# To quantify the linear relationship between life expectancy and BMI, we will fit a simple linear regression model by solving a least-squares problem with the backslash `\\` operator [go further: Least squares in Julia](https://stanford.edu/class/engr108/lectures/julia_least_squares_slides.pdf) which solves for $x$ systems such that $Ax=y$.

#Pkg.add("LinearAlgebra")
using LinearAlgebra

new_df = dropmissing(df);

y = new_df.Life_expectancy
A = new_df.BMI

scatter(A, y, label="Data")

# Linear regression model: A*x+b=y -> new_A*x=y
y = new_df.Life_expectancy
A = new_df.BMI

scatter(A, y, label="Data")

println("size(A) = ", size(A))
println("size(A') = ", size(A'))

new_A = vcat(A', ones(size(A))')'

println("size(new_A) = ", size(new_A))
println("size(y) = ", size(y))

coefs = new_A\y # Cannot handle missing values (hence dropmissing() above)

println("size(new_A\\y) = ", size(new_A\y))
println("Regression line: ", coefs[1], "*x+", coefs[2])

x = minimum(new_A):maximum(new_A)
plot!(x, coefs[1]*x.+coefs[2], label="Linear regression")

# Finally, let us quantify the fit of the linear regression model to the data via quality metrics

Pkg.add("Statistics")

using Statistics

println("Pearson's correlation coefficient R = ", cor(new_df[:, :Life_expectancy], new_df[:, :BMI]))
print("Coefficient of determination R^2 = ", cor(new_df[:, :Life_expectancy], new_df[:, :BMI])^2)

# ## Homework
# 
# Based on the results above, BMI seems not to be a very good predictor of life expectancy accross the world. Can you find a better explanatory variable using [simple linear regression](https://en.wikipedia.org/wiki/Simple_linear_regression) models ? Try also using multiple explanatory variables in a [multiple linear regression](https://en.wikipedia.org/wiki/Linear_regression#Simple_and_multiple_linear_regression) to see if they provide better results.
