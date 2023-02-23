#!/usr/bin/env python3

# Author:       Kolos Koblasz
# Created:      2023.02.22.
# Description:  This script can compare the how accurately approximates
#               the first few elements of sin(x)'s taylor polinom its
#               closed form definition.

import math
import matplotlib.pyplot as plt
import numpy as np

def taylor_series_p3( values):
    """
        Calculates the value of sin(x)'s taylor polinom up to 3rd power.

        Parameters:
        values (list of float) : Values which should be computed

        Returns:
        result (list of float) : Result of computation
    """

    temp_list = []

    for x in values :
        temp = x - ((x**3) / 6)
        temp_list.append(temp)

    return temp_list

def taylor_series_p5( values):
    """
        Calculates the value of sin(x)'s taylor polinom up to 5rd power.

        Parameters:
        values (list of float) : Values which should be computed

        Returns:
        result (list of float) : Result of computation
    """

    temp_list = []

    for x in values :
        temp = x - ((x**3) / 6) + ((x**5) / 120)
        temp_list.append(temp)

    return temp_list

def taylor_series_p7( values):
    """
        Calculates the value of sin(x)'s taylor polinom up to 7rd power.

        Parameters:
        values (list of float) : Values which should be computed

        Returns:
        result (list of float) : Result of computation
    """

    temp_list = []

    for x in values :
        temp = x - ((x**3) / 6) + ((x**5) / 120) - ((x**7) / 5040)
        temp_list.append(temp)

    return temp_list

if __name__ == '__main__':
    #parser = argparse.ArgumentParser(description="TT setup")

    x_min = -np.pi /2
    x_max =  np.pi /2

    x_list = list(np.arange(x_min, x_max , 0.1))
    y_ref_sin = [math.sin(x) for x in x_list ]

    x_tsp3 = list(np.arange(x_min, x_max , 0.1))
    y_tsp_3_sin = taylor_series_p3(values=x_tsp3)

    x_tsp5 = list(np.arange(x_min, x_max , 0.1))
    y_tsp_5_sin = taylor_series_p5(values=x_tsp5)

    x_tsp7 = list(np.arange(x_min, x_max , 0.1))
    y_tsp_7_sin = taylor_series_p7(values=x_tsp7)

    fig , ax = plt.subplots()
    ax.plot(x_list, y_ref_sin   , "b", label="sin(x)")
    #ax.plot(x_tsp3, y_tsp_3_sin , "r", label="taylor poly 3")
    ax.plot(x_tsp5, y_tsp_5_sin , "g", label="taylor poly 5")
    ax.plot(x_tsp7, y_tsp_7_sin , "y", label="taylor poly 7")
    ax.legend()

    plt.xlabel("[Rad]")
    plt.title("Sin(x) compares")

    error = [ b_i - a_i for a_i, b_i in zip(y_ref_sin , y_tsp_5_sin) ]

    print("max deviation: ", str(max([abs(e) for e in error])*100), "%")
    fig2 , ax2 = plt.subplots()
    ax2.plot(x_list, error , "b", label="Error")


    plt.xlabel("[Rad]")
    plt.title("Difference of sin(x) and TSP5")

    plt.show()