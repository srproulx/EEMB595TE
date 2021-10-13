# Function to simulation changes in population size
include("immigration_emigration.jl")

# Run the function once to get it compiled.
println()
println("First run: to get the function compiled")
@time immigration_emigration(50, 0.1, 0.1, 1);

# Now do the speed test I think we're all doing: 20 populations, 5000 time steps
println()
println("**** Speed test: 20 populations, 5000 time steps each ****")
@time sim1 = [immigration_emigration(40, 0.15, 0.2, 5000) for i=1:20];
println("******************************************************")
