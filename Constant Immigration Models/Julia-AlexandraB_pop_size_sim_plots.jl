using Plots # install Plots with: using Pkg; Pkg.add("Plots")
using DataFrames

# Function to simulation changes in population size
include("immigration_emigration.jl")

# Make the plot font size a bit smaller, after undoing any previous scaling.
scalefontsizes()
scalefontsizes(0.6)

# Run and plot a simulation
sim1 = immigration_emigration(500, 0.35, 0.25, 1000);

# Assigning plots to variables so I can put them all in one multipanel plot at the end
# Julia does have a mechanism to open plots in multiple windows; it's just broken *sigh*
p1 = plot(0:(length(sim1)-1), sim1, title="Sim 1: Pr(immigration) = 0.35, Pr(emigration) = 0.25",
    xlabel="Time", ylabel="Population size", legend=false)


# Run several simulations with different immigration rates
sim2 = [immigration_emigration(500, 0.35, beta, 1000) for beta=(0.25, 0.35, 0.45)]

# Make the simulation results into a dataframe!
sim2df = DataFrame(sim2, ["beta_0.25", "beta_0.35", "beta_0.45"])

# Plot the simulations
p2 = plot(0:nrow(sim2df)-1, [sim2df[!,i] for i=1:3], title="Sim 2: Different emigration rates",
        xlabel="Time", ylabel="Population size", label=permutedims(names(sim2df)),
        # reposition the legend
        legend=:topleft)


# Run simulations with different maximum time steps
# Why different maximum time steps? Because I thought it was cool that it's possible to plot that pretty easily
sim3 = [immigration_emigration(500, 0.35, 0.25, tmax) for tmax=(100, 1000)]

p3 = plot([0:length(sim3[i])-1 for i=1:length(sim3)], sim3,
    title="Sim 3: Run simulation for different lengths of time",
    xlabel="Time", ylabel="Population size", legend=:topleft,
    # fancy legend; permutedims required to make this a 1x2 string array
    label=permutedims(["tmax = $(length(sim3[i])-1)" for i=1:length(sim3)]))


# Show the plots as a multipanel figure
plot(p1, p2, p3, layout=3)
