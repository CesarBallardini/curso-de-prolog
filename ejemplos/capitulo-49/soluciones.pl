:- encoding(utf8).

% Capítulo 49 - Soluciones de los ejercicios 2 a 4 y 6 a 11.
%
% Carga los módulos del proyecto; las reglas nuevas de la teoría y los
% circuitos nuevos se agregan con cláusulas multifile.
%
% solo-local: carga módulos propios, y SWISH no los admite.
%
%?- mas_simples(fuerte, xor_nand, [[1, 0]-[0]], Ds).
%?- diagnostico_mal(sumador, [[0, 0, 1]-[0, 1], [1, 0, 0]-[1, 0]], D).
%?- aggregate_all(count, diagnostico(flach, sumador, [[0, 0, 1]-[0, 1]], _), N).
%?- abducir((motor(no_arranca), luces(encendidas)), S).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(ordsets)).
:- use_module(library(pairs)).
:- use_module(library(yall)).
:- use_module(medicion).
:- use_module(modelos).

:- multifile abduccion:regla/2.
:- multifile circuitos:circuito/3, circuitos:componente/5.

% Ejercicio 3

%!  abducir_mal(+Meta, ?Supuestos:list) is nondet.
%
%   Como abducir/2, con memberchk/2 en lugar de buscar/3: un error.
abducir_mal(true, _).
abducir_mal((A, B), Supuestos) :-
    abducir_mal(A, Supuestos),
    abducir_mal(B, Supuestos).
abducir_mal(estado(Componente, Estado), Supuestos) :-
    memberchk(Componente-Estado, Supuestos).
abducir_mal(Meta, Supuestos) :-
    abduccion:regla(Meta, Cuerpo),
    abducir_mal(Cuerpo, Supuestos).

%!  abductiva_mal(?Supuestos:list, +Ruta:list, ?Tipo, ?Entradas:list,
%!      ?Salida) is nondet.
%
%   La conducta abductiva del modelo fuerte, con abducir_mal/2.
abductiva_mal(Supuestos, Ruta, Tipo, Entradas, Salida) :-
    abducir_mal(salida(fuerte, Ruta, Tipo, Entradas, Salida), Supuestos).

%!  diagnostico_mal(+Circuito, +Observaciones:list(pair),
%!      -Fallas:list(pair)) is nondet.
%
%   Como diagnostico/4 en el modelo fuerte, con abducir_mal/2.
diagnostico_mal(Circuito, Observaciones, Fallas) :-
    maplist(observar_mal(Circuito, Supuestos), Observaciones),
    cerrar(Supuestos),
    fallas(Supuestos, Fallas).

%!  observar_mal(+Circuito, ?Supuestos:list, +Observacion:pair) is nondet.
%
%   Circuito reproduce la Observacion con abductiva_mal/5.
observar_mal(Circuito, Supuestos, Entradas-Salidas) :-
    simular(abductiva_mal(Supuestos), Circuito, Entradas, Salidas).

%!  repetida(+Fallas:list(pair)) is semidet.
%
%   Alguna ruta aparece dos veces en Fallas.
repetida(Fallas) :-
    pairs_keys(Fallas, Rutas),
    msort(Rutas, Ordenadas),
    append(_, [R, R|_], Ordenadas),
    !.

% Ejercicio 4

% En el modelo de Flach, una compuerta pegada a V solo se supone en falla
% cuando su tabla daría el otro bit.
abduccion:regla(salida(flach, Ruta, Tipo, Es, V),
                (tabla(Tipo, Es, S0), negacion(S0, V),
                 estado(Ruta, pegada(V)))).

% Ejercicio 6

circuitos:circuito(sumador_sondas, [a, b, ci], [s, co, c1, c2]).
circuitos:componente(sumador_sondas, Id, Tipo, Es, Ss) :-
    circuitos:componente(sumador, Id, Tipo, Es, Ss).

% Ejercicio 7

%!  sanas(+Supuestos:list(pair), -Rutas:list) is det.
%
%   Rutas son las rutas a las que Supuestos, un diccionario cerrado, asigna
%   el estado ok, en el orden del diccionario.
sanas(Supuestos, Rutas) :-
    include([_-Estado]>>(Estado == ok), Supuestos, Pares),
    pairs_keys(Pares, Rutas).

% Ejercicio 8

abduccion:regla(motor(arranca),
                (estado(bateria, bien), estado(arranque, bien),
                 estado(combustible, bien))).
abduccion:regla(motor(no_arranca), estado(bateria, mala)).
abduccion:regla(motor(no_arranca), estado(arranque, malo)).
abduccion:regla(motor(no_arranca), estado(combustible, vacio)).
abduccion:regla(luces(encendidas), estado(bateria, bien)).
abduccion:regla(luces(apagadas), estado(bateria, mala)).

% Ejercicio 9

% probabilidad(E, P): P es la probabilidad de que una compuerta esté en E.
probabilidad(pegada(_), 0.01).
probabilidad(invertida, 0.001).

%!  mas_probables(+Circuito, +Observaciones:list(pair), +K:integer,
%!      -Ordenados:list(pair)) is det.
%
%   Ordenados son los diagnósticos mínimos con a lo sumo K fallas, como
%   pares Probabilidad-Diagnostico, de mayor a menor probabilidad. Una
%   compuerta sana tiene probabilidad 1 - 0.021, el complemento de sus tres
%   estados de falla.
mas_probables(Circuito, Observaciones, K, Ordenados) :-
    minimos(fuerte, Circuito, Observaciones, K, Ds),
    compuertas(Circuito, N),
    maplist(con_probabilidad(N), Ds, Pares),
    sort(1, @>=, Pares, Ordenados).

%!  con_probabilidad(+N:integer, +Fallas:list(pair), -Par:pair) is det.
%
%   Par es P-Fallas, con P la probabilidad de que las compuertas de Fallas
%   estén en sus estados y las demás de las N, sanas.
con_probabilidad(N, Fallas, P-Fallas) :-
    foldl(multiplicar, Fallas, 1, P0),
    length(Fallas, F),
    P is P0 * (1 - 0.021) ** (N - F).

%!  multiplicar(+Falla:pair, +P0:number, -P:number) is det.
%
%   P es P0 por la probabilidad del estado de Falla.
multiplicar(_-Estado, P0, P) :-
    probabilidad(Estado, Q),
    P is P0 * Q.

% Ejercicio 10

%!  cono(+Circuito, +Salida, -Rutas:list) is det.
%
%   Rutas son las rutas de las compuertas de las que depende la salida
%   Salida de Circuito, como conjunto ordenado.
cono(Circuito, Salida, Rutas) :-
    depende(Circuito, [], Salida, Rutas, _).

%!  depende(+Circuito, +Ruta:list, +Cable, -Rutas:list, -Entradas:list)
%!      is det.
%
%   El Cable de Circuito, que está en Ruta dentro del exterior, depende de
%   las compuertas Rutas y de las entradas de Circuito Entradas, las dos
%   como conjuntos ordenados.
depende(Circuito, _Ruta, Cable, [], [Cable]) :-
    circuito(Circuito, Nombres, _),
    memberchk(Cable, Nombres),
    !.
depende(Circuito, Ruta, Cable, Rutas, Entradas) :-
    componente(Circuito, Id, Tipo, CEs, CSs),
    nth1(I, CSs, Cable),
    !,
    append(Ruta, [Id], RutaId),
    (   circuito(Tipo, TEs, TSs)
    ->  nth1(I, TSs, Interna),
        depende(Tipo, RutaId, Interna, Rutas0, Usadas),
        findall(C, ( member(U, Usadas), nth1(J, TEs, U), nth1(J, CEs, C) ),
                Cables)
    ;   Rutas0 = [RutaId],
        Cables = CEs
    ),
    foldl(unir(Circuito, Ruta), Cables, Rutas0-[], Rutas1-Entradas0),
    sort(Rutas1, Rutas),
    sort(Entradas0, Entradas).

%!  unir(+Circuito, +Ruta:list, +Cable, +Acumulado:pair, -Unido:pair)
%!      is det.
%
%   Unido agrega a los pares Rutas-Entradas de Acumulado los del Cable.
unir(Circuito, Ruta, Cable, Rs0-Es0, Rs-Es) :-
    depende(Circuito, Ruta, Cable, Rs1, Es1),
    append(Rs0, Rs1, Rs),
    append(Es0, Es1, Es).

%!  toca_los_conos(+Circuito, +Observacion:pair, +Diagnostico:list(pair))
%!      is semidet.
%
%   Diagnostico tiene al menos una compuerta en el cono de cada salida
%   que la Observacion tiene distinta de la del circuito sano.
toca_los_conos(Circuito, Entradas-Salidas, Diagnostico) :-
    circuito(Circuito, _, Nombres),
    predecir(Circuito, Entradas, [], Sanas),
    rutas(Diagnostico, Rutas),
    forall(( nth1(I, Nombres, Nombre),
             nth1(I, Salidas, S),
             nth1(I, Sanas, S0),
             S \== S0 ),
           ( cono(Circuito, Nombre, Cono),
             ord_intersect(Cono, Rutas) )).

% Ejercicio 11

%!  fallas_simples(+Circuito, -Fallas:list(pair)) is det.
%
%   Fallas son todas las fallas de una compuerta del modelo fuerte.
fallas_simples(Circuito, Fallas) :-
    findall(Ruta-Estado,
            ( compuerta_en(Circuito, Ruta, _), falla(Estado) ),
            Fallas).

%!  detecta(+Circuito, +Entradas:list, +Falla:pair) is semidet.
%
%   Con Entradas, Circuito con la Falla da otras salidas que sano.
detecta(Circuito, Entradas, Falla) :-
    predecir(Circuito, Entradas, [], Sanas),
    predecir(Circuito, Entradas, [Falla], ConFalla),
    Sanas \== ConFalla.

%!  conjunto_de_pruebas(+Circuito, -Pruebas:list,
%!      -NoDetectadas:list(pair)) is det.
%
%   Pruebas son entradas elegidas con el criterio voraz, en orden, hasta
%   que ninguna detecta una falla simple más; NoDetectadas son las fallas
%   simples que ninguna entrada detecta.
conjunto_de_pruebas(Circuito, Pruebas, NoDetectadas) :-
    fallas_simples(Circuito, Fallas),
    circuito(Circuito, Nombres, _),
    same_length(Nombres, Es),
    findall(Es, maplist(bit, Es), Entradas),
    elegir(Circuito, Entradas, Fallas, Pruebas, NoDetectadas).

%!  elegir(+Circuito, +Entradas:list, +Fallas:list(pair), -Pruebas:list,
%!      -NoDetectadas:list(pair)) is det.
%
%   Pruebas son las entradas elegidas para detectar Fallas.
elegir(Circuito, Entradas, Fallas, Pruebas, NoDetectadas) :-
    findall(N-Es,
            ( member(Es, Entradas),
              aggregate_all(count,
                            ( member(F, Fallas), detecta(Circuito, Es, F) ),
                            N),
              N > 0 ),
            Puntajes),
    (   Puntajes == []
    ->  Pruebas = [],
        NoDetectadas = Fallas
    ;   sort(1, @>=, Puntajes, [_-Mejor|_]),
        exclude(detecta(Circuito, Mejor), Fallas, Restantes),
        Pruebas = [Mejor|Pruebas1],
        elegir(Circuito, Entradas, Restantes, Pruebas1, NoDetectadas)
    ).
