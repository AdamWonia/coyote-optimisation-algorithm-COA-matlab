% Cleanup
close all;
clc;

% Objective function:
% Simulink model with PID controller:
OF = @(x) sim_model(x);

% Rastrigin function:
% OF = @(x) Rastrigin(x);

% Number of decision variables:
dv = 3;

% Decision variables bounds:
lb = [0, 0, 0];
ub = [50, 2, 0.5];

% COA algorithm parameters:
% Stopping criteria - maximum number of iterations:
max_iter = 110;

% Number of groups:
Ng = 25;

% Number of coyotes in each group:
Nc = 6;                     

% Number of attempts:
n = 5;

% Time elapsed:
t = clock();

% Run COA:
[opt_result_dv, opt_result_OF] = COA(OF, lb, ub, max_iter, Ng, Nc);

% Display results:
disp('Optimal decision variable values:');
disp(opt_result_dv);
fprintf(1,'Optimal objective function value: %.4f, Time elapsed: %.4fs\n', opt_result_OF, etime(clock, t));
