function [x0, z0, ban, iter] = mSimplexFaseII(A, b, c) 

% Esta funci�n realiza la Fase II del Metodo Simplex para problemas
% que tienen la siguiente forma
%
%               minimizar   c^T x 
%               sujeto a    Ax <= b , x >= 0 , b >= 0 
% 
% In :  A ... mxn matrix 
%       b ... column vector with as many rows as A 
%       c ... column vector with as many entries as one row of A 
% 
% Out:  xo ..... SFB optima del problema 
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
    
    % Solo imprimimos el tableau y los pasos para problemas
    % peque�os
    imprimirTableau = true;
    if n + m > 15
        imprimirTableau = false;
    end

    % 1.1 Calculamos los costos relativos iniciales, definimos los
    % conjuntos B, N
    N = 1:n;
    B = n+1:m+n;
    c = [c' zeros(1, m)];
    lambda = c(B);
    r_N = lambda*A - c';

    % 1.2 Construccion del tableau inicial 
    T = construirTableau(eye(m), A, c(B), r_N, b, B, N, iter, imprimirTableau);
    h = T(1:m, m+n+1);
    
    % Si el conjunto factible es vacio, el Metodo Simplex no
    % tendra opcion mas que escoger un punto que no cumpla
    % la restriccion de no-negatividad
    if any(h < 0)
        fprintf("\nConjunto factible vacio\n");
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
            break;
        
        end
        
    end
    
    x0 = AB\h;
    z0 = c_B*x0;
    x0 = x0(B <= n); % Solo devolvemos los valores de las variables originales
    
    return;
  
end

function [T] = construirTableau(A_B, A_N, c_B, r_N, b, B, N, iter, imprimirTableau)

% Esta funcion construye el tableau correspondiente a la base B
% usando las matrices A_B, A_N y los coeficientes c_B y c_N

    m = length(B);
    n = length(N);

    T = zeros(m+1,m+n+1);
    
    h = A_B\b;
    H = A_B\A_N;
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