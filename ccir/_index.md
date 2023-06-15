@def title = "The Applications of Mathematical Optimisation"
@def hascode = false

# The Applications of Mathematical Optimisation, Mixed-integer linear programming

Course given at the *Cambridge Centre for International Research*

## Abstract

**Nowadays, crucial modern infrastructures are operated by optimizing the decisions using what is called mixed integer linear programming (MILP)**.
This includes smart electrical grids, planning of deliveries for online shopping, scheduling at hospitals, or the design of transportation networks.

In this research course, students will learn the mathematical foundation of MILP as well as its numerical aspects with practical applications.
They will conduct research projects on MILP and learn how to solve complicated real-world problems by leveraging their knowledge in MILP.

The course will start with an introduction to linear programming.
We first cover how to model a problem as a linear program and its numerous applications.
We then review the different algorithms that can be used to solve it and the size of programs that can be handled by a computer.
We learn how to write programs in Julia (a high-level, high-performance, dynamic programming language for technical computing)
and then solve concrete problems by modelling them as linear programs using JuMP.
In addition, we cover data manipulation, visualisation and analysis in order to integrate real data into the model to obtain interpretable results.

The course then will then focus on integer variables in the modelling, expanding into the topic into mixed-integer linear programs (MILPs).
We will show how to formulate problems ranging from vehicle routing to machine learning as MILPs.
Mixed-integer linear programs can be solved using a branch and bound algorithm that we detail in the course.
The same problem can be formulated as different MILPs.
However, while some formulations can be solved in a few seconds, some may take hours!
We highlight the key aspects that are important for a formulation to be solved efficiently.

## Software prerequisite

The course uses a hands on approach by illustrating all theoretical results with
code using the JuMP framework in the Julia programming language.

In order to benefit from this, you will have to install the necessary in your computer.
This can be achieved via the following steps:
1. Install Julia, VS code and the Julia extension for VS code as detailed [here](https://code.visualstudio.com/docs/languages/julia#_getting-started).
   For installing Julia, I recommend doing it through [juliaup](https://julialang.org/downloads/#juliaup_-_julia_version_manager).
2. To download the course material, either follow the top badges to download the [Jupyter](https://jupyter.org/) notebooks or download the Julia files from [my website](https://github.com/blegat/blegat.github.io/tree/main/ccir). VS code provides similar interactive features with simple `.jl` Julia files than what is found in Jupyter notebooks so both option are equally good, you are free to choose the one you prefer.

## Course structure

You will find below the list of lectures and practical sessions in html format.
You can find a link to the jupyter notebook versions from the top of the pages.
