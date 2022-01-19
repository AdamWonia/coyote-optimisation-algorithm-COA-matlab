% Cleanup
close all;
clc;

% Objective function:
% Simulink model with PID controller:
OF = @(x) sim_model(x);

% Rastrigin function:
% OF = @(x) Rastrigin(x);

% Bounds for decision variables:
lb = [0, 0, 0];
ub = [50, 2, 0.5];

% COA algorithm parameters:
% Stopping criteria - maximum number of iterations:
max_iter = 110;

% Number of coyote groups:
Ng = 25;

% Number of coyotes in each group:
Nc = 6;                     

% Time elapsed:
t = clock();

% Run COA algorithm:
[opt_result_dv, opt_result_OF] = COA(OF, max_iter, Ng, Nc, lb, ub);

% Display results:
disp('Optimal decision variable values:');
disp(opt_result_dv);
fprintf(1,'Optimal objective function value: %.4f, Time elapsed: %.4fs\n', opt_result_OF, etime(clock, t));
