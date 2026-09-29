:- encoding(utf8).

% Capítulo 69 - Versión 4: un rasgo nuevo vuelve separable a la o
% exclusiva.
%
% Un perceptrón separa las clases con una recta; la o exclusiva no se
% separa con ninguna. Si a cada ejemplo se le agrega una tercera entrada,
% el producto X1·X2, los ejemplos pasan a ser puntos del espacio, y allí
% un plano los separa. El entrenamiento no cambia: cambian los ejemplos.
% aprender/3 es el programa terminado: entrena desde pesos nulos, con tasa
% 1, uno de los conjuntos de datos/2 con las entradas dadas o ampliadas.
%
% solo-local: carga los programas de los capítulos 32 y 46, y SWISH no
% carga otros archivos.
%
%?- aprender(o_exclusivo, entradas, R).
%?- aprender(o_exclusivo, producto, R).

:- ensure_loaded(ciclos).

%!  rasgos(+Rasgos:atom, +Entradas:list(number), -Ampliadas:list(number))
%!      is det.
%
%   Ampliadas son las Entradas que ve el perceptrón según Rasgos:
%   entradas las deja iguales, y producto agrega al final el producto de
%   todas ellas.
rasgos(entradas, Xs, Xs).
rasgos(producto, Xs, Ampliadas) :-
    foldl(multiplicar, Xs, 1, P),
    append(Xs, [P], Ampliadas).

%!  multiplicar(+X:number, +P0:number, -P:number) is det.
%
%   P es P0·X.
multiplicar(X, P0, P) :-
    P is P0 * X.

%!  ampliar(+Rasgos:atom, +Ejemplo0, -Ejemplo) is det.
%
%   Ejemplo es Ejemplo0 con las entradas ampliadas según Rasgos.
ampliar(Rasgos, ej(Xs, D), ej(Ys, D)) :-
    rasgos(Rasgos, Xs, Ys).

%!  aprender(+Nombre:atom, +Rasgos:atom, -Resultado) is semidet.
%
%   Resultado es el de entrenar_o_ciclo/4 para el conjunto Nombre de
%   datos/2 con las entradas ampliadas según Rasgos, desde pesos nulos y
%   con tasa 1.
aprender(Nombre, Rasgos, Resultado) :-
    datos(Nombre, Ejemplos0),
    entrenar_ampliados(Rasgos, Ejemplos0, Resultado).

%!  entrenar_ampliados(+Rasgos:atom, +Ejemplos0:list, -Resultado)
%!      is semidet.
%
%   Resultado es el de entrenar_o_ciclo/4 para Ejemplos0 con las entradas
%   ampliadas según Rasgos, desde pesos nulos y con tasa 1.
entrenar_ampliados(Rasgos, Ejemplos0, Resultado) :-
    maplist(ampliar(Rasgos), Ejemplos0, Ejemplos),
    pesos_nulos(Ejemplos, Pesos0),
    entrenar_o_ciclo(1, Ejemplos, Pesos0, Resultado).

%!  separables_con(+Rasgos:atom, -Cantidad:integer) is det.
%
%   Cantidad es el número de funciones lógicas de dos entradas que el
%   entrenamiento separa con las entradas ampliadas según Rasgos.
separables_con(Rasgos, Cantidad) :-
    aggregate_all(count,
                  ( tabla(Clases),
                    ejemplos_de(Clases, Ejemplos),
                    entrenar_ampliados(Rasgos, Ejemplos, separa(_, _))
                  ),
                  Cantidad).
