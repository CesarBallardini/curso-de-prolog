:- encoding(utf8).

% Capítulo 58 - Versión 1: el intérprete concreto como referencia.
%
% Los análisis del capítulo se comparan con la ejecución real de los
% programas Mini. Este archivo carga el intérprete del capítulo 45, sin
% copiarlo, y le agrega lo que necesita una referencia: variables de
% entrada, que empiezan con un valor dado en lugar de 0, y la ejecución
% del programa con cada valor de entrada de una muestra.
%
% Un caso es un programa de ejemplo con la descripción de sus entradas:
% una lista de X-entre(Min, Max), con Min un entero o inf, y Max un entero
% o sup. Las demás variables empiezan en 0, como en el capítulo 45.
%
% solo-local: carga interprete.pl del capítulo 45 con ensure_loaded/1.
%
%?- programa_caso(promedio, P, _), correr_desde(P, [n-4], R).
%?- programa_caso(promedio, P, _), correr_desde(P, [n-0], R).
%?- muestra(factorial, Cs), length(Cs, N).

:- ensure_loaded('../capitulo-45/interprete').

%!  programa_caso(?Nombre, -Programa:list, -Entradas:list) is nondet.
%
%   Programa es la sintaxis abstracta del caso Nombre, y Entradas la
%   descripción de sus variables de entrada.
programa_caso(Nombre, Programa, Entradas) :-
    caso(Nombre, Entradas, Lineas),
    atomic_list_concat(Lineas, '\n', Texto),
    analizar(Texto, Programa).

%!  correr_caso(+Nombre, +Valores:list, -Resultado) is semidet.
%
%   Resultado es lo que produce el caso Nombre con las entradas de Valores,
%   como en correr_desde/3. Falla si Nombre no es un caso.
correr_caso(Nombre, Valores, Resultado) :-
    programa_caso(Nombre, Programa, _),
    correr_desde(Programa, Valores, Resultado).

% caso(Nombre, Entradas, Lineas): un programa Mini con entradas, por líneas.
caso(promedio, [n-entre(0, sup)],
     [ "s := 0; i := 0;",
       "mientras i < n hacer",
       "  s := s + i;",
       "  i := i + 1",
       "fin;",
       "escribir s / n" ]).
caso(factorial, [n-entre(0, 10)],
     [ "f := 1;",
       "mientras n > 0 hacer",
       "  f := f * n;",
       "  n := n - 1",
       "fin;",
       "escribir f" ]).
caso(cuenta, [n-entre(1, sup)],
     [ "x := n;",
       "mientras x > 0 hacer x := x - 1 fin;",
       "escribir 100 / (x + 1)" ]).
caso(cuadrado, [n-entre(inf, sup)],
     [ "y := n * n;",
       "si y < 0 entonces escribir 0 sino escribir y fin" ]).
caso(diez, [],
     [ "i := 0;",
       "mientras i < 10 hacer i := i + 1 fin;",
       "escribir i" ]).
caso(mcd, [a-entre(1, sup), b-entre(1, sup)],
     [ "mientras a <> b hacer",
       "  si a > b entonces a := a - b",
       "  sino b := b - a fin",
       "fin;",
       "escribir 100 / a" ]).

%!  correr_desde(+Programa:list, +Valores:list, -Resultado) is det.
%
%   Resultado es lo que produce Programa ejecutado con el intérprete del
%   capítulo 45, con las variables de Valores, pares X-N, en N y las demás
%   en 0: fin(Salida, Final), con la salida y el entorno final, o
%   error(division_por_cero). No termina si Programa no termina.
correr_desde(Programa, Valores, Resultado) :-
    entorno_inicial(Programa, E0),
    foldl(fijar, Valores, E0, E1),
    catch(( once(phrase(ejecutar_bloque(Programa, E1, E), Salida)),
            Resultado = fin(Salida, E) ),
          error(evaluation_error(zero_divisor), _),
          Resultado = error(division_por_cero)).

%!  fijar(+Par, +E0:list, -E:list) is det.
%
%   E es el entorno E0 con la variable del par X-N en N; si X no aparece en
%   el programa, E es E0.
fijar(X-N, E0, E) :-
    (   actualizar(X, N, E0, E1)
    ->  E = E1
    ;   E = E0
    ).

%!  muestra(+Nombre, -Corridas:list) is det.
%
%   Corridas es la lista de las ejecuciones del caso Nombre con cada
%   combinación de valores de entrada de la ventana de muestra: cada una
%   es corrida(Valores, Resultado), como en correr_desde/3.
muestra(Nombre, Corridas) :-
    programa_caso(Nombre, Programa, Entradas),
    findall(corrida(Valores, R),
            ( valores_muestra(Entradas, Valores),
              correr_desde(Programa, Valores, R) ),
            Corridas).

%!  valores_muestra(+Entradas:list, -Valores:list) is nondet.
%
%   Valores da a cada variable de Entradas un valor de su rango que cae en
%   la ventana de muestra, de -6 a 12: una respuesta por combinación.
valores_muestra([], []).
valores_muestra([X-entre(Min, Max)|Es], [X-N|Vs]) :-
    desde_ventana(Min, A),
    hasta_ventana(Max, B),
    between(A, B, N),
    valores_muestra(Es, Vs).

%!  desde_ventana(+Min, -A:integer) is det.
%
%   A es la cota inferior Min recortada por la ventana de muestra.
desde_ventana(inf, -6).
desde_ventana(Min, A) :-
    integer(Min),
    A is max(Min, -6).

%!  hasta_ventana(+Max, -B:integer) is det.
%
%   B es la cota superior Max recortada por la ventana de muestra.
hasta_ventana(sup, 12).
hasta_ventana(Max, B) :-
    integer(Max),
    B is min(Max, 12).
