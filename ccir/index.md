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

* [Lecture 1](/ccir/lecture1) &ndash; System of linear equations
* [Practical 1](/ccir/practical1) &ndash; Linear regressions
