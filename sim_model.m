function z = sim_model(x)
    % Objective function weights:
    w1 = 1;
    w2 = 0.2;
    
    % PID parameters:
    Kp = x(1);
    Ki = x(2);
    Kd = x(3);
    
    % Set PID parameters:
    set_param('PID_sim_test_coa/PID', 'Kp', num2str(Kp));
    set_param('PID_sim_test_coa/PID', 'Ki', num2str(Ki));
    set_param('PID_sim_test_coa/PID', 'Kd', num2str(Kd));
    
    % Simulate model:
    simout = sim('PID_sim_test_coa');
    
    % Data from model:
    e_in = simout.e.signals.values(end);  % integral square error
    u_in = simout.u.signals.values(end);  % integral square control signal
    
    % Calculate the objective function value:
    z = w1*e_in; %+ w2*u_in;
end