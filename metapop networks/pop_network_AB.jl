using Distributions, Graphs, GraphPlot, Cairo, Fontconfig, Reel

n = 20 # population size
pr = 0.01 # probability of forming a friendship with a "rando," not a friend of friend
pff = 0.03 # probability of forming a friendship with a friend of friend
puf = 0.03 # probability of losing a friendship
clearanceProb = 0.15 # probability of clearing the infection
infectionProb = 0.05 # probability of spreading the infection
tmax = 100 # time to run the simulation for

social_network = zeros(Bool, n, n) # unweighted network, so let's save some time by making it boolean
infection = rand(Bernoulli(0.25), n) # initialize infection with approximately 25% infected

# Iitialize the social network
for individual=1:n
    for possibleFriend=(individual + 1):n
        if rand() < 0.1
            social_network[individual, possibleFriend] = social_network[possibleFriend, individual] = 1
        end
    end
end

# Arrays to hold the results for plotting
networkVtime = zeros(Bool, tmax, n, n)
infectionVtime = zeros(Bool, tmax, n)

for t=1:tmax
    # Gain and lose friendships
    for individual=1:n
        # Identify friends of friends
        friendsOfFriends = zeros(Bool, n)
        for friend=findall(social_network[individual, :])
            friendsOfFriends .|= social_network[friend, :]
        end

        # Befriend randos
        for possibleFriend=findall(.!friendsOfFriends)
            if rand() < pr
                social_network[individual, possibleFriend] = social_network[possibleFriend, individual] = 1
            end
        end

        # Remove individual and friends from friends of friends
        friendsOfFriends[individual] = 0
        friendsOfFriends[findall(social_network[individual, :])] .= 0

        # Befriend friends of friends
        for possibleFriend=findall(friendsOfFriends)
            if rand() < pff
                social_network[individual, possibleFriend] = social_network[possibleFriend, individual] = 1
            end
        end

        # Lose friends
        for possibleExFriend=findall(social_network[individual, :])
            if rand() < puf
                social_network[individual, possibleExFriend] = social_network[possibleExFriend, individual] = 0
            end
        end
    end

    # Infection clearance
    infection .*= rand(Bernoulli(1 - clearanceProb), n)

    # Gain of infection
    for individual=1:n
        if rand() < (1 - (1 - infectionProb)^sum(infection .* social_network[individual, :]))
            infection[individual] = 1
        end
    end
    #println(sum(infection))
    networkVtime[t, :, :] = social_network
    infectionVtime[t, :] = infection
end

# Record simulation as a gif. CAUTION: This can take up a ton of space
film = roll([gplot(Graph(networkVtime[t, :, :]), nodelabel=1:n, nodefillc=[["cyan", "pink"][infectionVtime[t, i] + 1] for i=1:n], layout=circular_layout) for t=1:tmax], fps=7)
write("week5_sim.gif", film)
