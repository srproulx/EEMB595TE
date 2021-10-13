"""
    immigration_emigration(n0, alpha, beta, tmax)

Simulate population size changes for tmax timesteps, starting from initial size n0, with immigration probability alpha and emigration probability beta.
"""
function immigration_emigration(n0::Int, alpha, beta, tmax::Int)
    # nt[i] will hold the population size at time step i
    nt = zeros(Int, tmax+1)

    # Initialize the population with n0 individuals
    nt[1] = n0

    for i=1:tmax
        # population gains individual with probability alpha, loses individual with probability beta
        nt[i+1] = max(nt[i] + (rand() < alpha) - (rand() < beta), 0)
    end

    # Return the final population size
    return(nt)
end
