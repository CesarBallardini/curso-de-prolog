:- encoding(utf8).

% Capítulo 77 - Seis maneras de decidir qué celdas son seguras.
%
% Todas reciben el mismo conocimiento, el término c/7 de agente.pl, y
% devuelven las celdas sin visitar que prueban seguras: sin pozo y sin el
% wumpus. Se diferencian en la representación y en quién hace la
% inferencia.
%
%   reglas      reglas de Prolog sobre el conocimiento, resueltas por el
%               propio Prolog: la versión extendida de las del capítulo 20.
%   datalog     las mismas reglas como datos, evaluadas de abajo hacia
%               arriba con modelo_estandar_de/2 del capítulo 38.
%   resolucion  cláusulas de primer orden y el demostrador por resolución
%               del capítulo 62, con un máximo de pasos.
%   clpb        una fórmula proposicional por mundo posible y la
%               implicación decidida con library(clpb), mediante
%               tautologia/2 del capítulo 62.
%   clpfd       una variable 0/1 por celda y peligro, restricciones de
%               suma y una búsqueda de un mundo que ponga un peligro en la
%               celda.
%   mundos      los mundos consistentes de agente.pl.
%
% instantaneas/2 da el conocimiento del agente prudente después de cada
% celda nueva que visita, en una serie de mundos sembrados, y comparar/3
% mide cada enfoque sobre todas esas instantáneas.
%
% solo-local: es un módulo que carga otros.
%
%?- conocer(4, [1-1-[], 2-1-[brisa]], K), seguras_con(reglas, K, S).
%?- comparar_en(clpfd, [1, 2, 3], R).

:- module(enfoques,
          [ seguras_con/3,
            instantaneas/2,
            comparar/3,
            comparar_en/3
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(clpfd)).
:- reexport(agente).
:- use_module(capitulo38).
:- use_module('../capitulo-62/comparacion', [tautologia/2, refutar_fo/3]).

%!  seguras_con(+Enfoque, +K, -Seguras:list) is det.
%
%   Seguras son las celdas sin visitar que Enfoque prueba seguras con el
%   conocimiento K, en orden.
seguras_con(mundos, K, Seguras) :-
    seguras(K, Seguras).
seguras_con(reglas, K, Seguras) :-
    sin_visitar(K, Cs),
    include(segura_por_reglas(K), Cs, Seguras).
seguras_con(datalog, K, Seguras) :-
    programa_datalog(K, Clausulas),
    modelo_estandar_de(Clausulas, Modelo),
    findall(C, ( member(segura(N), Modelo), celda_numero(C, N) ), Cs),
    sort(Cs, Seguras).
seguras_con(resolucion, K, Seguras) :-
    sin_visitar(K, Cs),
    clausulas_primer_orden(K, Base),
    include(segura_por_resolucion(Base), Cs, Seguras).
seguras_con(clpb, K, Seguras) :-
    sin_visitar(K, Cs),
    formula(K, Base),
    include(segura_por_clpb(Base), Cs, Seguras).
seguras_con(clpfd, K, Seguras) :-
    sin_visitar(K, Cs),
    include(segura_por_clpfd(K), Cs, Seguras).

%!  sin_visitar(+K, -Cs:list) is det.
%
%   Cs son las celdas de la cueva que K no visitó, en orden.
sin_visitar(c(N, _, Vs, _, _, _, _), Cs) :-
    findall(X-Y,
            ( between(1, N, X),
              between(1, N, Y),
              \+ memberchk(X-Y-_, Vs) ),
            Cs).

%!  percibio(+K, ?C, ?P) is nondet.
%
%   En la celda visitada C se percibió P.
percibio(c(_, _, Vs, _, _, _, _), C, P) :-
    member(C-Ps, Vs),
    member(P, Ps).

%!  visitada(+K, ?C) is nondet.
%
%   C es una celda visitada.
visitada(c(_, _, Vs, _, _, _, _), C) :-
    member(C-_, Vs).

% --- Reglas resueltas por Prolog --------------------------------------------

%!  segura_por_reglas(+K, +C) is semidet.
%
%   Las reglas prueban que C no tiene pozo ni wumpus.
segura_por_reglas(K, C) :-
    sin_pozo(K, C),
    sin_wumpus(K, C).

%!  sin_pozo(+K, +C) is semidet.
%
%   Una vecina visitada de C no tuvo brisa.
sin_pozo(K, C) :-
    K = c(N, _, _, _, _, _, _),
    once(( vecina(N, C, V),
           visitada(K, V),
           \+ percibio(K, V, brisa) )).

%!  sin_wumpus(+K, +C) is semidet.
%
%   Una vecina visitada de C no tuvo hedor, o el wumpus está probado en
%   otra celda.
sin_wumpus(K, C) :-
    K = c(N, _, _, _, _, _, _),
    (   vecina(N, C, V),
        visitada(K, V),
        \+ percibio(K, V, hedor)
    ->  true
    ;   wumpus_en(K, W),
        W \== C
    ->  true
    ).

%!  wumpus_en(+K, -W) is semidet.
%
%   Una celda visitada tuvo hedor y W es la única de sus vecinas donde el
%   wumpus puede estar.
wumpus_en(K, W) :-
    K = c(N, _, _, _, _, _, _),
    once(( percibio(K, V, hedor),
           findall(D,
                   ( vecina(N, V, D),
                     \+ visitada(K, D),
                     \+ ( vecina(N, D, E),
                          visitada(K, E),
                          \+ percibio(K, E, hedor) ) ),
                   [W]) )).

% --- Las mismas reglas como datos, de abajo hacia arriba --------------------

%!  celda_numero(?C, ?N) is det.
%
%   N es el número 10 * X + Y de la celda X-Y: el evaluador del capítulo
%   38 compara números, no celdas.
celda_numero(X-Y, N) :-
    (   integer(N)
    ->  X is N // 10,
        Y is N mod 10
    ;   N is 10 * X + Y
    ).

%!  programa_datalog(+K, -Clausulas:list) is det.
%
%   Clausulas son los hechos de la cueva y del conocimiento K y las reglas
%   de seguridad, como términos Cabeza :- Cuerpo.
programa_datalog(K, Clausulas) :-
    K = c(N, _, Vs, _, _, _, _),
    findall((celda(A) :- true),
            ( between(1, N, X), between(1, N, Y), celda_numero(X-Y, A) ),
            Celdas),
    findall((vecina(A, B) :- true),
            ( between(1, N, X), between(1, N, Y),
              vecina(N, X-Y, V),
              celda_numero(X-Y, A), celda_numero(V, B) ),
            Vecinas),
    findall((visitada(A) :- true),
            ( member(C-_, Vs), celda_numero(C, A) ),
            Visitadas),
    findall((H :- true),
            ( member(C-Ps, Vs), member(P, Ps),
              celda_numero(C, A), H =.. [P, A] ),
            Percepciones),
    reglas_datalog(Reglas),
    append([Celdas, Vecinas, Visitadas, Percepciones, Reglas], Clausulas).

%!  reglas_datalog(-Reglas:list) is det.
%
%   Las reglas de seguridad, en el orden en que el evaluador necesita las
%   variables ligadas.
reglas_datalog([
    (sin_pozo(C) :- vecina(C, V), visitada(V), \+ brisa(V)),
    (sin_wumpus_vecina(C) :- vecina(C, V), visitada(V), \+ hedor(V)),
    (otro_wumpus(V, C) :-
        vecina(V, C), vecina(V, D), D =\= C, \+ visitada(D),
        \+ sin_wumpus_vecina(D)),
    (wumpus(C) :-
        hedor(V), vecina(V, C), \+ visitada(C), \+ sin_wumpus_vecina(C),
        \+ otro_wumpus(V, C)),
    (sin_wumpus(C) :- sin_wumpus_vecina(C)),
    (sin_wumpus(C) :- wumpus(W), celda(C), C =\= W),
    (segura(C) :- celda(C), \+ visitada(C), sin_pozo(C), sin_wumpus(C))
]).

% --- Resolución de primer orden ---------------------------------------------

%!  clausulas_primer_orden(+K, -Base:list) is det.
%
%   Base son las cláusulas de primer orden: un pozo da brisa en cada
%   vecina, el wumpus da hedor en cada vecina, las vecindades y las
%   percepciones, positivas y negativas, de las celdas visitadas.
clausulas_primer_orden(K, Base) :-
    K = c(N, _, Vs, _, _, _, _),
    findall([+vecina(A, B)],
            ( between(1, N, X), between(1, N, Y),
              vecina(N, X-Y, B), A = X-Y ),
            Vecinas),
    findall([Signo],
            ( member(C-Ps, Vs),
              member(P, [brisa, hedor]),
              A =.. [P, C],
              (   memberchk(P, Ps)
              ->  Signo = +A
              ;   Signo = -A
              ) ),
            Percepciones),
    append([ [ [-vecina(X1, Y1), -pozo(Y1), +brisa(X1)],
               [-vecina(X2, Y2), -wumpus(Y2), +hedor(X2)] ],
             Percepciones, Vecinas ],
           Base).

%!  segura_por_resolucion(+Base:list, +C) is semidet.
%
%   Hay refutaciones de a lo sumo tres pasos de Base con pozo(C) y de Base
%   con wumpus(C).
segura_por_resolucion(Base, C) :-
    refutar_fo([[+pozo(C)]|Base], 3, _),
    refutar_fo([[+wumpus(C)]|Base], 3, _).

% --- Lógica proposicional con library(clpb) ---------------------------------

%!  formula(+K, -F) is det.
%
%   F es la conjunción de lo que se sabe, en la sintaxis de fórmulas del
%   capítulo 62: las celdas visitadas no tienen peligros, cada percepción
%   equivale a la disyunción de los peligros vecinos, y hay un wumpus y
%   solo uno.
formula(K, F) :-
    K = c(N, _, Vs, _, _, _, _),
    findall(G,
            ( member(C-_, Vs),
              member(G, [no(at(pozo(C))), no(at(wumpus(C)))]) ),
            Libres),
    findall(sii(at(P), Disyuncion),
            ( member(C-_, Vs),
              member(P0-Peligro, [brisa-pozo, hedor-wumpus]),
              P =.. [P0, C],
              findall(at(A), ( vecina(N, C, V), A =.. [Peligro, V] ), As),
              disyuncion(As, Disyuncion) ),
            Equivalencias),
    findall(Lit,
            ( member(C-Ps, Vs),
              member(P0, [brisa, hedor]),
              P =.. [P0, C],
              (   memberchk(P0, Ps)
              ->  Lit = at(P)
              ;   Lit = no(at(P))
              ) ),
            Percepciones),
    findall(X-Y, ( between(1, N, X), between(1, N, Y) ), Todas),
    findall(at(wumpus(C)), member(C, Todas), Ws),
    disyuncion(Ws, AlMenosUno),
    findall(o(no(at(wumpus(A))), no(at(wumpus(B)))),
            ( member(A, Todas), member(B, Todas), A @< B ),
            ASumoUno),
    append([Libres, Equivalencias, Percepciones, [AlMenosUno], ASumoUno],
           Gs),
    conjuncion(Gs, F).

%!  disyuncion(+Fs:list, -F) is det.
%
%   F es la disyunción de las fórmulas de Fs, una lista no vacía.
disyuncion([F], F) :-
    !.
disyuncion([F|Fs], o(F, G)) :-
    disyuncion(Fs, G).

%!  conjuncion(+Fs:list, -F) is det.
%
%   F es la conjunción de las fórmulas de Fs, una lista no vacía.
conjuncion([F], F) :-
    !.
conjuncion([F|Fs], y(F, G)) :-
    conjuncion(Fs, G).

%!  segura_por_clpb(+Base, +C) is semidet.
%
%   Base implica que C no tiene pozo ni wumpus: la implicación es una
%   tautología.
segura_por_clpb(Base, C) :-
    tautologia(clpb, si(Base, y(no(at(pozo(C))), no(at(wumpus(C)))))).

% --- Restricciones sobre enteros --------------------------------------------

%!  segura_por_clpfd(+K, +C) is semidet.
%
%   No hay un mundo que cumpla las restricciones de K con un pozo en C, ni
%   uno con el wumpus en C.
segura_por_clpfd(K, C) :-
    \+ mundo_con(K, pozo, C),
    \+ mundo_con(K, wumpus, C).

%!  mundo_con(+K, +Peligro, +C) is semidet.
%
%   Hay un mundo consistente con K que pone Peligro en C: una variable 0/1
%   por celda para los pozos y otra para el wumpus, las celdas visitadas
%   en 0, cada percepción como una suma de vecinas, un solo wumpus.
mundo_con(K, Peligro, C) :-
    K = c(N, _, Vs, _, _, _, _),
    findall(X-Y, ( between(1, N, X), between(1, N, Y) ), Todas),
    length(Todas, L),
    length(Pozos, L),
    length(Wumpus, L),
    Pozos ins 0..1,
    Wumpus ins 0..1,
    pairs_keys_values(PP, Todas, Pozos),
    pairs_keys_values(PW, Todas, Wumpus),
    sum(Wumpus, #=, 1),
    maplist(restringir(N, PP, PW), Vs),
    (   Peligro == pozo
    ->  memberchk(C-Var, PP)
    ;   memberchk(C-Var, PW)
    ),
    Var #= 1,
    append(Pozos, Wumpus, Vars),
    once(label(Vars)).

%!  restringir(+N:integer, +PP:list, +PW:list, +Visitada) is det.
%
%   Impone las restricciones de Visitada, un par V-Ps de una celda y sus
%   percepciones: sin peligros en V, y la suma de los peligros vecinos es
%   positiva si y solo si se percibió su señal. Las restricciones se
%   imponen con maplist/2, no con forall/2, que las desharía al terminar.
restringir(N, PP, PW, V-Ps) :-
    memberchk(V-P0, PP),
    memberchk(V-W0, PW),
    P0 #= 0,
    W0 #= 0,
    findall(Vec, vecina(N, V, Vec), Vecinas),
    maplist(variable_de(PP), Vecinas, XsP),
    maplist(variable_de(PW), Vecinas, XsW),
    senal(brisa, Ps, XsP),
    senal(hedor, Ps, XsW).

%!  variable_de(+Pares:list, +C, -X) is det.
%
%   X es la variable de la celda C en Pares, una lista de pares
%   Celda-Variable. No se usa un lambda de library(yall), que copiaría las
%   variables con restricciones.
variable_de(Pares, C, X) :-
    memberchk(C-X, Pares).

%!  senal(+P, +Ps:list, +Xs:list) is det.
%
%   Si P está en Ps, la suma de Xs es positiva; si no, es 0.
senal(P, Ps, Xs) :-
    (   memberchk(P, Ps)
    ->  sum(Xs, #>=, 1)
    ;   sum(Xs, #=, 0)
    ).

% --- La comparación ---------------------------------------------------------

%!  instantaneas(+Semillas:list, -Ks:list) is det.
%
%   Ks son los conocimientos del agente prudente de la versión 3 después
%   de cada celda nueva que visita en los mundos sembrados con Semillas,
%   precedidos por el de la figura 7.4 de Russell y Norvig.
instantaneas(Semillas, [K0|Ks]) :-
    conocer(4, [1-1-[], 2-1-[brisa], 1-2-[hedor]], K0),
    findall(K,
            ( member(S, Semillas),
              mundo_sembrado(S, M),
              jugar(M, final(_, _, Acciones)),
              recorrido(Acciones, Celdas),
              append(Prefijo, _, Celdas),
              Prefijo \== [],
              maplist(con_percepciones(M), Prefijo, Vs),
              conocer(4, Vs, K) ),
            Ks).

%!  recorrido(+Acciones:list, -Celdas:list) is det.
%
%   Celdas son las celdas distintas por las que pasan las Acciones, desde
%   (1, 1), en el orden de la primera visita.
recorrido(Acciones, Celdas) :-
    findall(C, member(ir(C), Acciones), Cs),
    foldl(agregar_nueva, Cs, [1-1], Celdas).

%!  agregar_nueva(+C, +Cs0:list, -Cs:list) is det.
%
%   Cs es Cs0 con C al final, si no estaba.
agregar_nueva(C, Cs0, Cs) :-
    (   memberchk(C, Cs0)
    ->  Cs = Cs0
    ;   append(Cs0, [C], Cs)
    ).

%!  con_percepciones(+M, +C, -Par) is det.
%
%   Par es C-Ps, con Ps la brisa y el hedor que se perciben en C en el
%   mundo M.
con_percepciones(M, C, C-Ps) :-
    percepciones(M, e(C, no, si, vivo), Ps0),
    include(de_la_celda, Ps0, Ps1),
    msort(Ps1, Ps).

%!  comparar(+Enfoque, +Ks:list, -Resultado) is det.
%
%   Resultado es r(Seguras, Distintas, Inferencias): cuántas celdas prueba
%   seguras Enfoque en todas las instantáneas Ks, en cuántas instantáneas
%   su respuesta difiere de la de los mundos consistentes, y cuántas
%   inferencias usó.
comparar(Enfoque, Ks, r(Seguras, Distintas, Inferencias)) :-
    statistics(inferences, I0),
    maplist(seguras_con(Enfoque), Ks, Ss),
    statistics(inferences, I1),
    Inferencias is I1 - I0,
    maplist(seguras_con(mundos), Ks, Referencia),
    maplist(length, Ss, Ls),
    sum_list(Ls, Seguras),
    foldl(contar_distinta, Ss, Referencia, 0, Distintas).

%!  contar_distinta(+S:list, +R:list, +D0:integer, -D:integer) is det.
%
%   D es D0 más 1 si S y R son distintas.
contar_distinta(S, R, D0, D) :-
    (   S == R
    ->  D = D0
    ;   D is D0 + 1
    ).

%!  comparar_en(+Enfoque, +Semillas:list, -Resultado) is det.
%
%   comparar/3 sobre las instantáneas de los mundos sembrados con
%   Semillas.
comparar_en(Enfoque, Semillas, Resultado) :-
    instantaneas(Semillas, Ks),
    comparar(Enfoque, Ks, Resultado).
