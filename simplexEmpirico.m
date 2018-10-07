
% Este script usa la funcion mSimplexFaseII para resolver N problemas
% generados de manera aleatoria. En cada vuelta, se guardan el minimo 
% entre las dimensiones del problema min(m,n), el numero de iteraciones 
% y una variable booleana que indica si el problema tenia solucion o no

N = 50; % Numero de problemas que se quieren generar

res = zeros(N, 3);

for i = 1:N
    % Generar dimensiones del problema (m,n <= 200) 
    m = round(10*exp(log(20)*rand())); 
    n = round(10*exp(log(20)*rand()));
    
    % Generar A, b, c 
    sigma = 100; 
    A = round(sigma*randn(m,n)); 
    b = round(sigma*abs(randn(m,1))); 
    c = round(sigma*randn(n,1));
    
    % Llamamos a la funcion mSimplexFaseII y resolvemos el problema
    [~, ~, ban, iter] = mSimplexFaseII(A, b, c, false);
    
    % Guardamos los resultados que nos interesan
    if ban == 0
        res(i, :) = [min(m,n), iter, 1];
    else
        res(i, 1:2) = [min(m,n), iter];
    end   
end

% Separamos los resultados dependiendo de si tienen solucion o no
% y los guardamos en un "structure array"
% (ver https://la.mathworks.com/help/matlab/matlab_prog/create-a-structure-array.html)
resProblemas.conSolucion.minMN = res(logical(res(:, 3)), 1);
resProblemas.conSolucion.iter = res(logical(res(:, 3)), 2);
resProblemas.sinSolucion.minMN = res(~logical(res(:, 3)), 1);
resProblemas.sinSolucion.iter = res(~logical(res(:, 3)), 2);

% Graficamos los resultados
scatter( resProblemas.conSolucion.minMN, resProblemas.conSolucion.iter, 120, 'b', 'filled'); 
hold on
scatter( resProblemas.sinSolucion.minMN, resProblemas.sinSolucion.iter, 120, 'r', 's', 'filled'); 
hold off

% Formato de los ejes
% Para hacer que la grafica sea cuadrada usar "axis square"
set(gca, 'xscale', 'log', 'yscale', 'log', 'xlim', [0, 201], 'fontsize', 27); 
grid off

% Titulos, nombres de ejes y etiquetas
xlabel('$\min(m,n)$', 'interpreter', 'latex', 'fontsize', 33); 
ylabel('Numero de iteraciones', 'fontsize', 33); 
[~, iconos, ~, etiquetas] = legend({'Problemas con solucion', ...
    'Problemas sin solucion o no-acotados'}, ...
    'fontname', 'Segoe UI Light', 'fontsize', 27, 'location', 'southeast');
for k = (length(iconos)/2+1):length(iconos)
    % Increase legend marker size
    iconos(k).Children.MarkerSize = 17; 
end


