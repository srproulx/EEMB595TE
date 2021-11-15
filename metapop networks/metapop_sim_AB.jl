using Graphs, Distributions, Plots

"""
    metapop_sim(pop_connectivity, init_pops, tmax)
    metapop_sim(pop_connectivity, init_pops, tmax; carrying_capacity=40, max_birth_probability=0.1, death_probability=0.05, dispersal_probability=0.05, extinction_probability=0.03)

Simulates metapopulation dynamics where dispersal occurs between connected subpopulations in the undirected graph `pop_connectivity`.
Subpopulations start with `init_pops` initial population sizes, and simulation runs for `tmax` time steps.
Returns a vector of metapopulation size over time.

# Optional arguments
- `carrying_capacity::Int=40`: the carrying capacity of each subpopulation
- `max_birth_probability=0.1`: the probability of an individual reproducing when the subpopulation is empty.
- `death_probability=0.05`: the probability of an individual dying.
- `dispersal_probability=0.05`: the probability of an individual dispersing to a neighboring subpopulation, if one exists.
- `extinction_probability=0.03`: the probability of a subpopulation going extinct
"""
function metapop_sim(pop_connectivity::SimpleGraph, init_pops::Vector{Int}, tmax::Int; carrying_capacity::Int=40, max_birth_probability=0.1, death_probability=0.05, dispersal_probability=0.05, extinction_probability=0.03)

    # Check that pop_connectivity and init_pops describe the same number of metapopulations
    if nv(pop_connectivity) != length(init_pops)
        error("metapop_sim: pop_connectivity must have exactly as many vertices as entries in init_pops")
    end

    # Initialize a vector of the current subpopulation sizes
    pop_sizes = init_pops

    # Initialize a vector to keep track of the metapopulation size over time
    metapop_size = zeros(Int, tmax+1)
    metapop_size[1] = sum(pop_sizes)

    for t=1:tmax
        # Emigration
        emigrants = [rand(Binomial(pop_sizes[i], dispersal_probability)) for i=1:length(pop_sizes)]
        pop_sizes = pop_sizes .- emigrants

        # Subpopulation extinction
        pop_sizes = pop_sizes .* (rand(length(pop_sizes)) .< 1 - extinction_probability)

        # Emigrants settle in neighboring populations (but not their own)
        for i=1:length(pop_sizes)
            if (emigrants[i] > 0) && (length(neighbors(pop_connectivity, i)) > 0)

                neighboring_subpops = neighbors(pop_connectivity, i)

                # Find the number of emigrants going to each neighboring subpopulation
                emigrants_to_neighbor = rand(Multinomial(emigrants[i], length(neighboring_subpops)))

                # Add the emigrants to each neighboring subpopulation
                for j=1:length(neighboring_subpops)
                    pop_sizes[neighboring_subpops[j]] += emigrants_to_neighbor[j]
                end
            end
        end

        # Birth and death inside subpopulations
        for i=1:length(pop_sizes)
            births = rand(Binomial(pop_sizes[i], max_birth_probability * max((1 - pop_sizes[i] / carrying_capacity), 0) ))
            deaths = rand(Binomial(pop_sizes[i], death_probability))
            pop_sizes[i] += (births - deaths)
        end

        # Update total population size
        metapop_size[t + 1] = sum(pop_sizes)
    end

    return(metapop_size)
end


################### End of function; here's some code to run the simulation ################
pop_connectivity = erdos_renyi(30, 0.24)
init_pops = rand(Binomial(60, 0.5), nv(pop_connectivity))

metapop_v_time = metapop_sim(pop_connectivity, init_pops, 1000)
plot(0:1000, metapop_v_time)
