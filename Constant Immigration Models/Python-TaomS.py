"""
A simple migration simulation.
Since this simulation is not computationally intensive the code focuses on readability
rather than efficiency. Vectorizing this with numpy should speed it up for larger simulations.
"""

from random import random  # import the random() function from the random package
import pandas as pd  # dataframes
from plotnine import ggplot, geom_point, aes  # python's clone of ggplot

def run_sim(n0, iterations, run_num=1):
    """
    Runs the simulation once.

    Args:
        n0: Initial population
        iterations: Number of iterations the simulation goes for
        run_num: Used to track multiple runs of the simulation. Defaults to 1.

    Returns:
        A dataframe that gives a timeseries of the population size along with the run number

    """
    alpha = .33  # Probability of migration in
    beta = .3  # Probability of migration out
    n = n0  # Current population size
    timeseries = []  # Where we will store the timeseries data

    # See if somebody migrates in or out.
    for i in range(0, iterations):
        if random() <= alpha:  # random() gives a number between 0 and 1
            n += 1
        if random() <= beta:
            n -= 1
        if n < 0:  # Can't go below 0 population
            n = 0
        timeseries.append(n)

    run_list = [run_num]*iterations  # A list of the run number. This will be the second column of our dataframe.
    data = pd.DataFrame({'t': range(0, iterations), 'n': timeseries, 'run_num': run_list})  # Make a dataframe with a n and run_num column.

    return data


# The code that actually runs when we start the script.
# The first line, if __name__ == "__main__" just tells python that this is the part we run.
if __name__ == "__main__":

    # Make multiple dataframes
    frames = []
    for i in range(0, 10):
        data = run_sim(100, 1000, run_num=i)  # Run the sim with n0=100, iterations=1000, and a counter to track the run number.
        frames.append(data)

    # Put all the dataframes into one
    all_data = pd.concat(frames)

    print(all_data)

    # Plot this
    plot = (ggplot(all_data, aes(x='t', y='n', color='run_num')) +
     geom_point()
     )

    # Draw the plot
    plot.draw()
