function [opt_dv, opt_OF] = COA(OF, max_iter, Ng, Nc, dv_min, dv_max)
    %% Parameters:
    Ndv = size(dv_min, 2);  % number of decision variables

    %% Algorithm initialization (step 0):
    % Number of coyotes in population:
    Npop = Ng * Nc;

    % Initialization of objective function:
    FF_kg = zeros(Npop, 1);

    %% Generation of initial solutions (step 1):
    % Lower and upper bounds:
    Co_min = repmat(dv_min, Npop, 1);
    Co_max = repmat(dv_max, Npop, 1);

    % Get random number in range of [0,1]
    gamma = rand(Npop, Ndv);

    % Creating an initial population of coyotes:
    Co_kg = Co_min + gamma .* (Co_max - Co_min);  

    % Form groups from randomly selected coyotes:
    groups = reshape(randperm(Npop), Ng, []);

    %% Calculation of quality of the initial coyote population (step 2):
    % Penalty factor:
    pen_fact = 1000000; 

    for k = 1:Npop
        % Verification of violation of restrictions:
        check_lb = Co_kg(k,:) < dv_min;
        check_ub = Co_kg(k,:) > dv_max;
        check_bound = check_lb + check_ub;
        penalty = sumsqr(sum(check_bound));
        PF = pen_fact * penalty;

        % Calculation of the objective function including penalty:
        FF_kg(k,1) = OF(Co_kg(k,:)) + PF;
    end

    % Searching for the smallest value of the objective function:
    [opt_OF, opt_idx] = min(FF_kg);

    % Best solution:
    opt_dv = Co_kg(opt_idx,:);

    %% Main algorithm loop:
    iter = Npop;

    % Stopping criteria:
    while iter < max_iter 

        % For each p coyote in the Ng group: 
        for g = 1:Ng

            % Selecting a particular group of coyotes and their values:
            C_new_pop = Co_kg(groups(g,:),:);
            FF_old = FF_kg(groups(g,:),:);

            %% Identification of best local solutions (step 3):
            Co_best = min(C_new_pop);

            % Finding the middle solution (median):
            Co_mid = median(C_new_pop); 

            % Selecting two random solutions per group:
            Co_new = zeros(Nc, Ndv);

            for c = 1:Nc
                %% Selecting two random coyotes (no repeats):
                idx = randperm(Nc,2);
                Co1 = C_new_pop(idx(1),:);
                Co2 = C_new_pop(idx(2),:);

                % Calculation of new solutions:
                Co_new(c,:) = C_new_pop(c,:) + rand*(Co_best - Co1) + rand*(Co_mid  - Co2);

                % Checking violations of the limits of new solutions:
                check_lb = Co_new(c,:) < dv_min;
                check_ub = Co_new(c,:) > dv_max;
                check_bound = check_lb + check_ub;
                penalty = sumsqr(sum(check_bound));
                PF = pen_fact * penalty;

                %% Calculation of OF for new solutions (step 4):
                FF_new = OF(Co_new(c,:)) + PF;

                %% Selection of individuals (step 5):
                if FF_new < FF_old(c, 1)
                    FF_old(c, 1) = FF_new;
                    C_new_pop(c,:) = Co_new(c,:);
                end

                % Update iteration::
                iter = iter + 1;
            end

            %% Creation of a new solution in each coyote group (step 6):
            % Selection of two random individuals from a new population (no repeat):
            par_idx = randperm(Nc, 2);
            C_par1 = C_new_pop(par_idx(1),:);
            C_par2 = C_new_pop(par_idx(2),:);

            % Creating a new solution:
            new_coy = zeros(1, Ndv);
            for x = 1:Ndv
                % Get random number in range of [0,1]:
                beta = rand;
                % Selecting decision variables for new solution:
                if beta < 1/Ndv
                    new_coy(1, x) = C_par1(1, x);
                elseif beta >= 1/Ndv && beta < (0.5 + 1/Ndv)
                    new_coy(1, x) = C_par2(1, x);
                else
                    a = dv_min(1, x);
                    b = dv_max(1, x);
                    new_coy(1, x) = (b - a).* rand + a;
                end
            end

            % Calculation of the new solution:
            new_coy_cost = OF(new_coy);

            %% Identifying the worst solution and replacing it (step 7):
            [Co_worst, worst_idx] = max(FF_old);

            % Replacing the worst solution:
            if new_coy_cost < Co_worst
                FF_old(worst_idx,:) = new_coy_cost;
                C_new_pop(worst_idx,:) = new_coy;
            end

            % Update on coyote groups:
            Co_kg(groups(g,:),:) = C_new_pop;
            FF_kg(groups(g,:),:) = FF_old;

            % Update iteration:
            iter = iter + 1;
        end

        %% Exchange of solutions between groups (step 8):
        if rand < (0.01/2) * Nc^2
            % Draw two groups and two coyotes per group:
            group_idx = randperm(Ng, 2);
            coy_idx = randperm(Nc, 2);

            % Finding coyotes to exchange in groups:
            coy_ex1 = groups(group_idx(1), coy_idx(1));
            coy_ex2 = groups(group_idx(2), coy_idx(2));

            % Exchange of solutions in groups:
            groups(group_idx(1), coy_idx(1)) = coy_ex2;
            groups(group_idx(2), coy_idx(2)) = coy_ex1;
        end

        %% Determining the best solution (step 9):
        [opt_OF, opt_idx] = min(FF_kg);
        opt_dv = Co_kg(opt_idx,:);    

    end
end
