:- encoding(utf8).

% Capítulo 66 - Soluciones de los ejercicios 2 a 12.
%
% Carga las versiones 2 y 5, que cargan las demás, y agrega métodos de
% combinación con cláusulas multifile de evidencia.
%
% solo-local: carga el sistema experto del capítulo 33, y SWISH no admite
% módulos propios.
%
%?- atenuacion(0.7, Filas).
%?- member(M, [mycin, conman]), grado(mamifero, [tiene_pelo-0.6,
%?-        da_leche-0.6], M, P).
%?- costo_minimo(C).

:- module(soluciones,
          [ atenuacion/2,
            y_no/4,
            dos_reglas/2,
            mas_probable/3,
            arbol_excluyentes/2,
            costo_minimo/1,
            promedio_ponderado/2,
            escribir_arbol/1,
            consultar_con_grado/5,
            fuerza_estimada/4
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(pairs)).
:- use_module(library(aggregate)).
:- reexport(cotas).
:- reexport(compilado).

% Ejercicio 2 ---------------------------------------------------------------

%!  atenuacion(+G:float, -Filas:list) is det.
%
%   Filas tiene, para mamifero, carnivoro y guepardo, un término
%   Meta-[I, C, L]: su grado con los métodos independiente, conservador y
%   liberal cuando las cuatro observaciones del caso 1 tienen grado G.
atenuacion(G, Filas) :-
    caso(1, Os),
    maplist(con_grado(G), Os, Gs),
    findall(Meta-Ps,
            ( member(Meta, [mamifero, carnivoro, guepardo]),
              findall(P, ( member(M, [independiente, conservador,
                                      liberal]),
                           grado(Meta, Gs, M, P) ),
                      Ps) ),
            Filas).

%!  con_grado(+G:float, ?Hecho, ?Par) is det.
%
%   Par es Hecho con grado G.
con_grado(G, Hecho, Hecho-G).

% Ejercicio 3 ---------------------------------------------------------------

evidencia:metodo(mycin).
evidencia:metodo(conman).

% MYCIN, según Merritt, y CONMAN, según Covington: y toma el mínimo; o
% acumula como la independencia en MYCIN y toma el máximo en CONMAN.
evidencia:y(mycin, P1, P2, P) :-
    evidencia:y(liberal, P1, P2, P).
evidencia:y(conman, P1, P2, P) :-
    evidencia:y(liberal, P1, P2, P).
evidencia:o(mycin, P1, P2, P) :-
    evidencia:o(independiente, P1, P2, P).
evidencia:o(conman, P1, P2, P) :-
    evidencia:o(conservador, P1, P2, P).

% Ejercicio 4 ---------------------------------------------------------------

%!  y_no(+Metodo, +PA:float, +PB:float, -P:float) is det.
%
%   P es el grado de «A y no B» cuando A tiene grado PA y B grado PB: el
%   grado de no B es 1 - PB. P tiene cuatro decimales.
y_no(Metodo, PA, PB, P) :-
    PNoB is 1 - PB,
    y(Metodo, PA, PNoB, P0),
    P is round(P0 * 10000) / 10000.0.

% Ejercicio 5 ---------------------------------------------------------------

%!  dos_reglas(+Metodo, -P:float) is det.
%
%   P es el grado de a con las reglas a(P) :- b(P2), P is P2 * 0.6 y
%   a(P) :- c(P), con b seguro y c de grado 0.8; con cuatro decimales.
dos_reglas(Metodo, P) :-
    y(Metodo, 0.6, 1.0, PB),
    combinar(o, Metodo, [PB, 0.8], P0),
    P is round(P0 * 10000) / 10000.0.

% Ejercicio 6 ---------------------------------------------------------------

%!  mas_probable(+Observaciones:list, +Metodo, -Hipotesis) is semidet.
%
%   Hipotesis es la de mayor grado con Metodo; entre las empatadas, la
%   primera de hipotesis/1. Falla si ninguna tiene grado mayor que 0.
mas_probable(Observaciones, Metodo, Hipotesis) :-
    findall(P-H,
            ( hipotesis(H),
              grado(H, Observaciones, Metodo, P),
              P > 0 ),
            Pares),
    Pares \== [],
    pairs_keys(Pares, Ps),
    max_list(Ps, Maximo),
    once(member(Maximo-Hipotesis, Pares)).

% Ejercicio 7 ---------------------------------------------------------------

% excluyentes(A, B): las preguntas A y B no pueden tener las dos un sí.
excluyentes(vuela, no_vuela).
excluyentes(no_vuela, vuela).

%!  arbol_excluyentes(+Estrategia, -Arbol) is det.
%
%   Arbol es el árbol de Estrategia construido sabiendo qué preguntas se
%   excluyen: un sí a una descarta las reglas que tienen la otra.
arbol_excluyentes(Estrategia, Arbol) :-
    colapsadas(Reglas),
    findall(H-Os, prototipo(H, Os), Prototipos),
    construir_excl(Estrategia, Reglas, Prototipos, Arbol).

%!  construir_excl(+Estrategia, +Reglas:list, +Prototipos:list,
%!                 -Arbol) is det.
%
%   Como construir/4 de arbol.pl, con la rama del sí sin las reglas que
%   tienen una pregunta excluida por la respondida.
construir_excl(Estrategia, Reglas, Prototipos, Arbol) :-
    (   Reglas == []
    ->  Arbol = hoja(ninguna)
    ;   memberchk(H-[], Reglas)
    ->  Arbol = hoja(H)
    ;   arbol:elegir(Estrategia, Reglas, Prototipos, P),
        Arbol = pregunta(P, Si, No),
        findall(Q, excluyentes(P, Q), Excluidas),
        exclude(con_alguna(Excluidas), Reglas, Compatibles),
        maplist(arbol:sin_pregunta(P), Compatibles, ReglasSi),
        exclude(arbol:con_pregunta(P), Reglas, ReglasNo),
        partition(arbol:prototipo_si(P), Prototipos, PSi, PNo),
        construir_excl(Estrategia, ReglasSi, PSi, Si),
        construir_excl(Estrategia, ReglasNo, PNo, No)
    ).

%!  con_alguna(+Preguntas:list, +Regla) is semidet.
%
%   Regla tiene alguna de Preguntas.
con_alguna(Preguntas, Regla) :-
    once(( member(Q, Preguntas),
           arbol:con_pregunta(Q, Regla) )).

% Ejercicio 8 ---------------------------------------------------------------

%!  costo_minimo(-C:integer) is det.
%
%   C es la menor suma de preguntas, sobre los prototipos, que alcanza un
%   árbol para las reglas colapsadas.
costo_minimo(C) :-
    colapsadas(Reglas),
    findall(H-Os, prototipo(H, Os), Prototipos),
    costo(Reglas, Prototipos, C).

:- table costo/3.

%!  costo(+Reglas:list, +Prototipos:list, -C:integer) is det.
%
%   C es la menor suma de preguntas para llevar Prototipos a su hoja en
%   un árbol de Reglas: cada pregunta del nodo cuenta una vez por cada
%   prototipo que llega a él.
costo(Reglas, Prototipos, C) :-
    (   (   Prototipos == []
        ;   Reglas == []
        ;   memberchk(_-[], Reglas)
        )
    ->  C = 0
    ;   foldl(agregar_preguntas, Reglas, [], Candidatas),
        length(Prototipos, N),
        findall(C1,
                ( member(P, Candidatas),
                  maplist(arbol:sin_pregunta(P), Reglas, ReglasSi),
                  exclude(arbol:con_pregunta(P), Reglas, ReglasNo),
                  partition(arbol:prototipo_si(P), Prototipos, PSi, PNo),
                  costo(ReglasSi, PSi, CSi),
                  costo(ReglasNo, PNo, CNo),
                  C1 is N + CSi + CNo ),
                Cs),
        min_list(Cs, C)
    ).

% Ejercicio 9 ---------------------------------------------------------------

% frecuencia(H, F): de cada 100 animales que se consultan, F son H.
frecuencia(guepardo, 10).
frecuencia(tigre, 10).
frecuencia(jirafa, 5).
frecuencia(cebra, 15).
frecuencia(pinguino, 40).
frecuencia(avestruz, 20).

%!  promedio_ponderado(+Arbol, -Promedio:float) is det.
%
%   Promedio es la cantidad media de preguntas de Arbol sobre los
%   prototipos, pesado cada uno por la frecuencia de su hipótesis
%   repartida entre sus reglas colapsadas; con dos decimales.
promedio_ponderado(Arbol, Promedio) :-
    findall(W-N,
            ( prototipo(H, Os),
              frecuencia(H, F),
              aggregate_all(count, colapsada(H, _), K),
              W is F / K,
              consultar(Arbol, lista(Os), _, Ps),
              length(Ps, N) ),
            Pares),
    foldl(sumar_pesado, Pares, 0-0, Pesos-Suma),
    Promedio is round(100 * Suma / Pesos) / 100.0.

%!  sumar_pesado(+Par, +Acumulado, -Acumulado1) is det.
%
%   Suma el peso W y el producto W * N del Par W-N al Acumulado.
sumar_pesado(W-N, W0-S0, W1-S1) :-
    W1 is W0 + W,
    S1 is S0 + W * N.

% Ejercicio 10 --------------------------------------------------------------

%!  escribir_arbol(+Archivo) is det.
%
%   Escribe en Archivo las cláusulas de nodo/3 y un responde/2 que busca
%   la pregunta entre las observaciones: un programa que no necesita ni
%   las reglas ni el árbol.
escribir_arbol(Archivo) :-
    setup_call_cleanup(
        open(Archivo, write, S, [encoding(utf8)]),
        with_output_to(S, escribir_clausulas),
        close(S)).

%!  escribir_clausulas is det.
%
%   Escribe en la salida actual los operadores, nodo/3 y responde/2.
escribir_clausulas :-
    format(":- op(780, xfy, y).~n~n"),
    forall(clause(compilado:nodo(N, F, H), Cuerpo),
           portray_clause((nodo(N, F, H) :- Cuerpo))),
    portray_clause((responde(lista(Os), P) :-
                        (   P = (O y C)
                        ->  memberchk(O, Os),
                            call(C)
                        ;   memberchk(P, Os)
                        ))).

% Ejercicio 11 --------------------------------------------------------------

%!  consultar_con_grado(+Arbol, +Observaciones:list, +Umbral:float,
%!                      -Hipotesis, -P:float) is det.
%
%   Recorre Arbol respondiendo que sí a una pregunta cuya observación
%   tiene grado de al menos Umbral; P es el grado de la Hipotesis de la
%   hoja con el método independiente, o 0.0 si es ninguna.
consultar_con_grado(Arbol, Observaciones, Umbral, Hipotesis, P) :-
    include(supera(Umbral), Observaciones, Seguras),
    pairs_keys(Seguras, Hechos),
    consultar(Arbol, lista(Hechos), Hipotesis, _),
    (   Hipotesis == ninguna
    ->  P = 0.0
    ;   grado(Hipotesis, Observaciones, independiente, P)
    ).

%!  supera(+Umbral:float, +Par) is semidet.
%
%   El grado del Par Hecho-Grado es al menos Umbral.
supera(Umbral, _-G) :-
    G >= Umbral.

% Ejercicio 12 --------------------------------------------------------------

%!  fuerza_estimada(+Exitos:integer, +Total:integer, -F:float,
%!                  -Error:float) is det.
%
%   F es la fracción Exitos / Total, que estima la fuerza de una regla, y
%   Error su error estándar, la raíz de F (1 - F) / Total; los dos con
%   tres decimales.
fuerza_estimada(Exitos, Total, F, Error) :-
    F0 is Exitos / Total,
    E0 is sqrt(F0 * (1 - F0) / Total),
    F is round(1000 * F0) / 1000.0,
    Error is round(1000 * E0) / 1000.0.
