function [x0, z0, ban, iter] = mSimplexFaseII(A, b, c, imprimirTableau) 

% Esta funcion realiza la Fase II del Metodo Simplex para problemas
% que tienen la siguiente forma
%
%               minimizar   c'x 
%               sujeto a    Ax <= b , x >= 0 , b >= 0 
% 
% In :  A ... mxn matrix 
%       b ... column vector with as many rows as A 
%       c ... column vector with as many entries as one row of A 
%       imprimirTableau ... boolean variable which indicates whether
%       or not to print the step-by-step solution of the given problem 
% 
% Out:  xo ..... SBF optima del problema 
%       zo ..... valor optimo del problema 
%       ban .... indica casos: 
%           -1 ... si el conjunto factible es vacio 
%           0 .... si se encontro una solucion optima 
%           1 .... si la funcion objectivo no es acotada. 
%       iter ... numero de iteraciones (cambios de variables basicas) 
%       que hizo el metodo

    % 1 Construccion del tableau en estado 0 
    
    format rat; % MATLAB imprime fracciones en vez de decimales
    
    [m, n] = size(A); % m variables basicas
    iter = 0;
    ban = 0;

    % 1.1 Calculamos los costos relativos iniciales, definimos los
    % conjuntos B, N
    N = 1:n;
    B = n+1:m+n;
    c = [c' zeros(1, m)];
    lambda = c(B);
    r_N = lambda*A - c(N);

    % 1.2 Construccion del tableau inicial
    T = construirTableau(eye(m), A, c(B), r_N, b, B, N, iter, imprimirTableau);
    AB = T(1:m, B);
    h = T(1:m, m+n+1);
    
    % Si el conjunto factible es vacio, el Metodo Simplex no
    % tendra opcion mas que escoger un punto que no cumpla
    % la restriccion de no-negatividad
    if any(h < 0)
        if imprimirTableau
            fprintf("Conjunto factible vacio\n");
        end
        ban = -1;
    end
    
    % 2 Probamos la condicion de optimalidad
    while any(r_N > 0) && ban == 0
        
        % 2.1 Seleccionamos la variable de entrada mediante
        % la Regla de Bland
        e = find(r_N > 0, 1);
        
        % 3 Probamos si el problema es acotado
        if any(T(1:m, N(e)) > 0)
            
            % 3.1 Seleccion de la variable de salida mediante
            % la Regla de Bland

            % Buscamos los indices de los denominadores no-positivos
            noPositivos = T(1:m, N(e)) <= 0; 

            % Calculamos los cocientes y asignamos infinito a los
            % cocientes que corresponden a los denominadores 
            % menores o iguales a cero
            h = T(1:m,m+n+1);
            cocientes = h./T(1:m, N(e));
            cocientes(noPositivos) = inf;

            % s es el indice que corresponde al minimo de cocientes
            [~, s] = min(cocientes);
            
            if imprimirTableau
                fprintf("La variable de entrada es X%d y la variable de salida es X%d\n",N(e),B(s));
            end
            
            % 4 Redefinimos los conjuntos B y N 
            aux = B(s);
            B(s) = N(e);
            N(e) = aux;
            iter = iter + 1;
            
            % Definimos las nuevas matrices y los nuevos costos
            % asociados a nuestras variables basicas y no-basicas
            AB = T(1:m, B);
            AN = T(1:m, N);
            
            % 4.1 Calculamos los nuevos costos relativos y 
            % construimos el nuevo tableau 
            lambda = (AB')\c(B)';
            lambda = lambda';
            r_N = lambda*AN - c(N);
            T = construirTableau(AB, AN, c(B), r_N, h, B, N, iter, imprimirTableau);
            
        else
            
            % El problema es no-acotado. 
            ban = 1;
            if imprimirTableau
                fprintf("Problema no-acotado\n");
            end
            break;
        
        end
        
    end
    
    if ban == -1
        x0 = [];
        z0 = [];
    else
        x0 = zeros(m+n, 1);
        x0(B) = AB\h;
        z0 = c*x0;
        x0 = x0(1:n); % Solo devolvemos los valores de las variables originales
    end
    
    return;
  
end

function [T] = construirTableau(AB, AN, c_B, r_N, b, B, N, iter, imprimirTableau)

% Esta funcion construye el tableau correspondiente a la base B
% usando las matrices AB, AN y los coeficientes c_B

    m = length(B);
    n = length(N);

    T = zeros(m+1,m+n+1);
    
    h = AB\b;
    H = AB\AN;
    z = c_B*h;

    T(1:m, B) = eye(m);
    T(1:m, N) = H;
    T(1:m, m+n+1) = h;
    T(m+1, N) = r_N;
    T(m+1, m+n+1) = z;
    
    if imprimirTableau
        fprintf("\nIteracion %d\n\n", iter);
        disp(T);
        fprintf("Variables basicas: ");
        disp(B);
    end

    return;

end