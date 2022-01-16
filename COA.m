function [opt_dv, opt_OF] = COA(OF, lb, ub, max_iter, Ng, Nc)
    %% Parametry algorytmu:
    Ndv = size(lb, 2);  % ilość zmiennych decyzyjnych
    dv_min = lb;      % wektor ograniczeń dolnych
    dv_max = ub;      % wektor ograniczeń górnych

    %% Inicjalizacja  algorytmu (krok 0):
    % Liczba kojotów w populacji:
    Npop = Ng * Nc;

    % Wartości funkcji celu na początku algorytmu:
    FF_kg = zeros(Npop, 1);

    %% Generowanie rozwiązań początkowych (krok 1):
    % Dolne i górne ograniczenia:
    Co_min = repmat(dv_min, Npop, 1);
    Co_max = repmat(dv_max, Npop, 1);

    % Losowa wartość z przedziału [0,1]
    gamma = rand(Npop, Ndv); % lepsze rozwiązania dla wektora rand niż jednej liczby

    % Utworzenie populacji początkowej kojotów:
    Co_kg = Co_min + gamma .* (Co_max - Co_min);  

    % Tworzenie grup z losowo wybieranych kojotów:
    groups = reshape(randperm(Npop), Ng, []);

    %% Obliczanie jakości populacji początkowej kojotów (krok 2):
    % Współczynnik kary:
    pen_fact = 1000000; 

    for k = 1:Npop
        % Sprawdzenie naruszenia ograniczeń:
        check_lb = Co_kg(k,:) < dv_min;
        check_ub = Co_kg(k,:) > dv_max;
        check_bound = check_lb + check_ub;
        penalty = sumsqr(sum(check_bound));
        PF = pen_fact * penalty;

        % Obliczanie funkcji przystosowania z uwzględnieniem kary:
        FF_kg(k,1) = OF(Co_kg(k,:)) + PF;
    end

    % Wyszukiwanie najmniejszej wartości funkcji celu:
    [opt_OF, opt_idx] = min(FF_kg);

    % Najlepsze rozwiązanie:
    opt_dv = Co_kg(opt_idx,:);

    %% Główna pętla algorytmu:
    iter = Npop;

    % Kryterium stopu:
    while iter < max_iter 

        % Dla każdego kojota p w grupie Ng: 
        for g = 1:Ng

            % Wybieranie danej grupy kojotów i ich przystosowania:
            C_new_pop = Co_kg(groups(g,:),:);
            FF_old = FF_kg(groups(g,:),:);

            %% Wyznaczenie najlepszych lokalnych rozwiązań (krok 3):
            Co_best = min(C_new_pop);

            % Wyznaczenie rozwiązana środkowego (mediana):
            Co_mid = median(C_new_pop); 

            % Wybranie dwóch losowych rozwiązań w danej grupie:
            Co_new = zeros(Nc, Ndv);

            for c = 1:Nc
                %% Wybranie dwóch losowych kojotów (bez powtórzeń):
                idx = randperm(Nc,2);
                Co1 = C_new_pop(idx(1),:);
                Co2 = C_new_pop(idx(2),:);

                % Obliczanie nowych rozwiązań:
                Co_new(c,:) = C_new_pop(c,:) + rand*(Co_best - Co1) + rand*(Co_mid  - Co2);

                % Sprawdzenie naruszenia ograniczeń nowych rozwiązań:
                check_lb = Co_new(c,:) < dv_min;
                check_ub = Co_new(c,:) > dv_max;
                check_bound = check_lb + check_ub;
                penalty = sumsqr(sum(check_bound));
                PF = pen_fact * penalty;

                %% Ocena przystosowania nowych rozwiązań (krok 4):
                FF_new = OF(Co_new(c,:)) + PF;

                %% Selekcja osobników (krok 5):
                if FF_new < FF_old(c, 1)
                    FF_old(c, 1) = FF_new;
                    C_new_pop(c,:) = Co_new(c,:);
                end

                % Aktualizacja iteracji:
                iter = iter + 1;
            end

            %% Utworzenie nowego rozwiązania w każdej grupie kojotów (krok 6):
            % Wybieranie dwóch losowych osobników z nowej populacji (bez powtórzeń):
            par_idx = randperm(Nc, 2);
            C_par1 = C_new_pop(par_idx(1),:);
            C_par2 = C_new_pop(par_idx(2),:);

            % Tworzenie nowego rozwiązania (potomka):
            new_coy = zeros(1, Ndv);
            for x = 1:Ndv
                % Losowa liczba z przedziału [0,1]:
                beta = rand;
                % Wybieranie zmiennych decyzyjnych dla potomka:
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

            % Obliczanie przystosowania nowego rozwiązania (zapewnione ograniczenia, więc bez kary):
            new_coy_cost = OF(new_coy);

            %% Określenie najgorszego rozwiązania i zastąpienie go (krok 7):
            [Co_worst, worst_idx] = max(FF_old);

            % Zastąpienie najgorszego rozwiązania:
            if new_coy_cost < Co_worst
                FF_old(worst_idx,:) = new_coy_cost;
                C_new_pop(worst_idx,:) = new_coy;
            end

            % Aktualizacja grup kojotów:
            Co_kg(groups(g,:),:) = C_new_pop;
            FF_kg(groups(g,:),:) = FF_old;

            % Aktualizacja iteracji:
            iter = iter + 1;
        end

        %% Wymiana rozwiązań pomiędzy grupami (krok 8):
        if rand < (0.01/2) * Nc^2
            % Losowanie dwóch grup i dwóch kojotów w danej grupie:
            group_idx = randperm(Ng, 2);
            coy_idx = randperm(Nc, 2);

            % Znalezienie kojotów do wymiany w grupach:
            coy_ex1 = groups(group_idx(1), coy_idx(1));
            coy_ex2 = groups(group_idx(2), coy_idx(2));

            % Wymiana rozwiązań w grupach:
            groups(group_idx(1), coy_idx(1)) = coy_ex2;
            groups(group_idx(2), coy_idx(2)) = coy_ex1;
        end

        %% Określenie najlepszego rozwiązania (krok 9):
        [opt_OF, opt_idx] = min(FF_kg);
        opt_dv = Co_kg(opt_idx,:);    

    end
end
