:- encoding(utf8).

% Capítulo 60 - Soluciones de los ejercicios.
%
% Programas nuevos para el intérprete, una estrategia más, la traza como
% datos y variantes del demostrador. Carga las versiones 4 y 5, que cargan
% las anteriores, y no modifica ningún archivo del capítulo: los programas
% se agregan a programa/2 y la estrategia a clave/4, que son multifile.
%
% solo-local: carga resolucion.pl y terminacion.pl con ensure_loaded/1, y
% SWISH no permite cargar archivos.
%
%?- ejecutar(maximo, [numero(25), numero(10), numero(15), numero(30)], M, R).
%?- numeros(2, 30, H), ejecutar(criba, H, M, R).

:- ensure_loaded(resolucion).
:- ensure_loaded(terminacion).

% Ejercicios 2, 3, 4, 7, 8, 9 y 12: programas nuevos.
programa(maximo,
    [ menor :: [numero(X), numero(Y), {X < Y}]
           ---> [quitar(numero(X))],
      resultado :: [numero(X)]
           ---> [parar(X)]
    ]).
programa(criba,
    [ multiplo :: [numero(X), numero(Y), {X < Y, Y mod X =:= 0}]
           ---> [quitar(numero(Y))]
    ]).
programa(burbuja,
    [ vecinos :: [pos(I, X), pos(J, Y), {J =:= I + 1, X > Y}]
           ---> [reemplazar(pos(I, X), pos(I, Y)),
                 reemplazar(pos(J, Y), pos(J, X))]
    ]).
programa(escrutinio,
    [ otro_voto :: [voto(C), total(C, N)]
           ---> [quitar(voto(C)), {M is N + 1},
                 reemplazar(total(C, N), total(C, M))],
      primer_voto :: [voto(C), no(total(C, _))]
           ---> [quitar(voto(C)), agregar(total(C, 1))]
    ]).
programa(resolucion_subsuncion,
    [ contradiccion :: [clausula([])]
           ---> [parar(contradiccion)],
      tautologia :: [clausula(C), {tautologica(C)}]
           ---> [quitar(clausula(C))],
      subsumir :: [clausula(C1), clausula(C2),
                   {C1 \== C2, ord_subset(C1, C2)}]
           ---> [quitar(clausula(C2))],
      resolver :: [clausula(C1), clausula(C2),
                   {resolvente(C1, C2, R), \+ tautologica(R)},
                   no(clausula(R)), no(hecha(C1, C2, R))]
           ---> [agregar(clausula(R)), agregar(hecha(C1, C2, R))],
      agotado :: []
           ---> [parar(sin_contradiccion)]
    ]).
programa(resolucion_sin_control,
    [ contradiccion :: [clausula([])]
           ---> [parar(contradiccion)],
      tautologia :: [clausula(C), {tautologica(C)}]
           ---> [quitar(clausula(C))],
      resolver :: [clausula(C1), clausula(C2),
                   {resolvente(C1, C2, R), \+ tautologica(R)}]
           ---> [agregar(clausula(R))],
      agotado :: []
           ---> [parar(sin_contradiccion)]
    ]).
programa(luz_limitada,
    [ fin :: [cambios(0)]
           ---> [parar(listo)],
      apagar :: [luz(encendida), cambios(N), {N > 0}]
           ---> [{M is N - 1}, reemplazar(cambios(N), cambios(M)),
                 reemplazar(luz(encendida), luz(apagada))],
      encender :: [luz(apagada), cambios(N), {N > 0}]
           ---> [{M is N - 1}, reemplazar(cambios(N), cambios(M)),
                 reemplazar(luz(apagada), luz(encendida))]
    ]).

%!  numeros(+Desde:integer, +Hasta:integer, -Hechos:list) is det.
%
%   Hechos son los hechos numero(I) para I de Desde a Hasta.
numeros(Desde, Hasta, Hechos) :-
    findall(numero(I), between(Desde, Hasta, I), Hechos).

%!  clave(+Estrategia, +Largo:integer, +Instancia, -Clave) is det.
%
%   Ejercicio 5: la estrategia lejana. Al ordenar, las acciones de una
%   instancia nombran las dos posiciones que intercambia; la clave prefiere
%   la mayor distancia entre ellas. Una instancia sin intercambio tiene
%   clave 0.
clave(lejana, _, instancia(_, _, _, Acciones), Clave) :-
    distancia(Acciones, Clave).

%!  distancia(+Acciones:list, -Clave:integer) is det.
%
%   Clave es J - I con el signo cambiado si Acciones reemplaza los hechos
%   pos(I, _) y pos(J, _), y 0 si no.
distancia(Acciones, Clave) :-
    (   Acciones = [reemplazar(pos(I, _), _), reemplazar(pos(J, _), _)]
    ->  Clave is I - J
    ;   Clave = 0
    ).

%!  historia(+Programa, +Estrategia, +Memoria0:list, -Historia:list,
%!           -Resultado) is semidet.
%
%   Ejercicio 10. Historia es la traza de la ejecución como datos: un
%   término ciclo(N, Nombre, Cantidad, Hechos) por ciclo, con el módulo
%   elegido, el tamaño del conjunto de conflicto y los hechos que usa.
%   Falla si falla una acción de la instancia elegida.
historia(Programa, Estrategia, Memoria0, Historia, Resultado) :-
    programa(Programa, Modulos),
    historia(Modulos, Estrategia, 1, Memoria0, Historia, Resultado).

%!  historia(+Modulos:list, +Estrategia, +N:integer, +Memoria0:list,
%!           -Historia:list, -Resultado) is semidet.
%
%   Historia es la traza desde el ciclo N con la memoria Memoria0. Falla
%   si falla una acción de la instancia elegida.
historia(Modulos, Estrategia, N, Memoria0, Historia, Resultado) :-
    conflicto(Modulos, Memoria0, Instancias),
    (   Instancias == []
    ->  Historia = [],
        Resultado = nada_aplicable
    ;   elegir(Estrategia, Memoria0, Instancias, Elegida),
        Elegida = instancia(Nombre, _, Posiciones, Acciones),
        length(Instancias, Cantidad),
        findall(F, ( member(I, Posiciones), nth0(I, Memoria0, F) ), Hechos),
        Historia = [ciclo(N, Nombre, Cantidad, Hechos)|Resto],
        acciones(Acciones, Memoria0, Memoria1, Fin),
        (   Fin = parar(R)
        ->  Resto = [],
            Resultado = R
        ;   N1 is N + 1,
            historia(Modulos, Estrategia, N1, Memoria1, Resto, Resultado)
        )
    ).

%!  escribir_historia(+Historia:list) is det.
%
%   Escribe la Historia con el formato de trazar/5.
escribir_historia(Historia) :-
    forall(member(ciclo(N, Nombre, Cantidad, Hechos), Historia),
           format("~w: ~w de ~w, con ~w~n", [N, Nombre, Cantidad, Hechos])).

%!  ruido(+Cantidad:integer, -Hechos:list) is det.
%
%   Ejercicio 11. Hechos son Cantidad hechos ruido(I) que ningún módulo
%   usa.
ruido(Cantidad, Hechos) :-
    findall(ruido(I), between(1, Cantidad, I), Hechos).

%!  primos_hasta(+N:integer, -Primos:list(integer)) is det.
%
%   Ejercicio 3. Primos son los primos hasta N, en orden, según el
%   programa criba.
primos_hasta(N, Primos) :-
    numeros(2, N, Hechos),
    ejecutar(criba, Hechos, Memoria, nada_aplicable),
    findall(X, member(numero(X), Memoria), Xs),
    msort(Xs, Primos).

%!  vigilar_formula(+Programa, +Formula, +Limite:integer, -Resultado,
%!                  -Hechos:integer) is det.
%
%   Ejercicio 9. Ejecuta el Programa de resolución sobre la negación de
%   Formula con vigilar/6. Hechos es la cantidad de hechos de la memoria
%   final.
vigilar_formula(Programa, Formula, Limite, Resultado, Hechos) :-
    memoria_inicial(Formula, Memoria0),
    vigilar(Programa, primera, Limite, Memoria0, Memoria, Resultado),
    length(Memoria, Hechos).

%!  ciclos_invertida(+Programa, +Estrategia, +Largo:integer,
%!                   -Ciclos:integer) is det.
%
%   Ejercicios 4 y 5. Ciclos es la cantidad de ciclos del Programa de
%   ordenamiento, con la Estrategia, para la lista Largo, ..., 2, 1.
ciclos_invertida(Programa, Estrategia, Largo, Ciclos) :-
    numlist(1, Largo, Creciente),
    reverse(Creciente, Lista),
    posiciones(Lista, Hechos),
    ciclos(Programa, Estrategia, Hechos, Ciclos).
