function y = Rastrigin (x)
    % Rastrigin's Function:
    A = 10;
    n = length(x);
    sum = 0;
    
    for i = 1:n
        sum = sum + x(i)^2 - A * cos(2 * pi * x(i));
    end
    
    y = 10 * n + sum;
end