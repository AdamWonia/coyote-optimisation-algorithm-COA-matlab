# Coyote Optimisation Algorithm COA in Matlab

## Description

This repository contains a stochastic optimisation algorithm developed in the Matlab environment. It is a Coyote Optimization Algorithm (COA) that was used in a master's thesis to optimize the operation of a wastewater treatment plant. It is an algorithm that minimises a given objective function.

The algorithm was developed based on the article:

*Nguyen T. T., Pham T. D., Kien L. C., Van Dai, L.: Improved coyote optimization algorithm for optimally installing solar photovoltaic distribution generation units in radial distribution power systems.*

However, this is a version of the algorithm without improvements. 

## Launch

To run the algorithm, open the **RunCOA.m** script in the Matlab environment. Inside it you have the possibility to choose two objective functions to be optimised by the algorithm:
- the first one is the Rastrigin function, which is contained in the file **Rastrigin.m**,
- the second one concerns the optimization of the PID controller parameters in a control system with a simple control object. The objective function in this case is the sum of the integral of the square of the control error and the integral of the square of the control signal, which are additionally multiplied by appropriate weights. Changes related to this function can be made in the file **sim_model.m**. 

The choice consists in commenting one of them. If the Rastrigin function is selected, it is only necessary to run the **RunCOA.m** script. On the other hand, in the case of the second objective function, Simulink must be started and a file named **PID_sim_test_coa.slx** must be opened. In it, the simulation model of the control system with PID controller is contained. 

When the optimization process is complete, the optimization results are displayed in the command window, including the value of the objective function, the values of the decision variables and the time of the calculation. 

The COA algorithm requires parameters such as the maximum number of iterations of the algorithm, which is the stopping criterion, the number of coyote groups, the number of coyotes in each group and constraints on the values of the decision variables. These parameters can be changed in the main script of the **RunCOA.m** program.

When the main script is run, the **COA.m** function is called, which contains the COA algorithm. This function takes as parameters the objective function, the maximum number of iterations, the number of coyote groups, the number of coyotes in each group and lower and upper bounds on the values of the decision variables. In turn, it returns the optimal values of the decision variables and the optimal value of the objective function.
