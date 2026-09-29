:- encoding(utf8).

% Capítulo 66 - Versión 4: el árbol de preguntas.
%
% arbol/2 construye, a partir de las reglas colapsadas, un árbol de
% decisión: cada nodo pregunta(P, Si, No) hace una pregunta y sigue por la
% rama de la respuesta; cada hoja(H) da la hipótesis probada, o ninguna.
% Una respuesta afirmativa quita la pregunta de las reglas que la tienen;
% una negativa descarta esas reglas. La primera regla que se queda sin
% preguntas prueba su hipótesis. La estrategia elige la pregunta de cada
% nodo: orden, la primera de la primera regla, como la haría el
% encadenamiento hacia atrás; frecuente, la que está en más reglas;
% informacion, la que más informa sobre la hipótesis de los prototipos que
% llegan al nodo, un animal por regla. consultar/4 recorre el árbol con
% las respuestas de una fuente; medidas/2 y promedio/3 lo miden.
%
% solo-local: carga el sistema experto del capítulo 33, y SWISH no admite
% módulos propios.
%
%?- caso(1, Os), consulta(orden, Os, H, Ps).
%?- medir(E, M, P1, P2).
%?- prototipo(avestruz, Os).

:- module(arbol,
          [ estrategia/1,
            arbol/2,
            consultar/4,
            consulta/4,
            medidas/2,
            medir/4,
            prototipo/2,
            promedio/3,
            responde_si/2,
            observaciones/1
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(pairs)).
:- use_module(library(aggregate)).
:- reexport(colapsar).

% estrategia(E): E elige la pregunta de cada nodo del árbol.
estrategia(orden).
estrategia(frecuente).
estrategia(informacion).

%!  arbol(+Estrategia, -Arbol) is det.
%
%   Arbol es el árbol de preguntas de las reglas colapsadas, con las
%   preguntas elegidas por Estrategia.
arbol(Estrategia, Arbol) :-
    colapsadas(Reglas),
    findall(H-Os, prototipo(H, Os), Prototipos),
    construir(Estrategia, Reglas, Prototipos, Arbol).

%!  construir(+Estrategia, +Reglas:list, +Prototipos:list, -Arbol) is det.
%
%   Arbol decide entre Reglas, pares Hipotesis-Preguntas: la hoja de la
%   primera regla sin preguntas, hoja(ninguna) si no queda ninguna regla,
%   o una pregunta con un subárbol para cada respuesta. Prototipos son los
%   pares Hipotesis-Observaciones que llegan al nodo; solo los usa la
%   estrategia informacion.
construir(Estrategia, Reglas, Prototipos, Arbol) :-
    (   Reglas == []
    ->  Arbol = hoja(ninguna)
    ;   memberchk(H-[], Reglas)
    ->  Arbol = hoja(H)
    ;   elegir(Estrategia, Reglas, Prototipos, P),
        Arbol = pregunta(P, Si, No),
        maplist(sin_pregunta(P), Reglas, ReglasSi),
        exclude(con_pregunta(P), Reglas, ReglasNo),
        partition(prototipo_si(P), Prototipos, PrototiposSi, PrototiposNo),
        construir(Estrategia, ReglasSi, PrototiposSi, Si),
        construir(Estrategia, ReglasNo, PrototiposNo, No)
    ).

%!  con_pregunta(+P, +Regla) is semidet.
%
%   Regla tiene una variante de la pregunta P.
con_pregunta(P, _-Preguntas) :-
    once(( member(Q, Preguntas),
           Q =@= P )).

%!  sin_pregunta(+P, +Regla, -Regla1) is det.
%
%   Regla1 es Regla sin las variantes de la pregunta P.
sin_pregunta(P, H-Preguntas, H-Resto) :-
    exclude(=@=(P), Preguntas, Resto).

%!  prototipo_si(+P, +Prototipo) is semidet.
%
%   Las observaciones de Prototipo responden que sí a la pregunta P.
prototipo_si(P, _-Observaciones) :-
    se_cumple(P, Observaciones).

%!  elegir(+Estrategia, +Reglas:list, +Prototipos:list, -P) is det.
%
%   P es la pregunta que Estrategia elige para decidir entre Reglas, que
%   no es vacía. Entre preguntas empatadas, la primera que aparece.
%   Cuando ninguna pregunta separa los prototipos, informacion elige como
%   orden.
elegir(orden, [_-[P|_]|_], _, P).
elegir(frecuente, Reglas, _, P) :-
    foldl(agregar_preguntas, Reglas, [], Candidatas),
    maplist(cuantas(Reglas), Candidatas, Valores),
    primera_mejor(Valores, Candidatas, P).
elegir(informacion, Reglas, Prototipos, P) :-
    foldl(agregar_preguntas, Reglas, [], Candidatas),
    maplist(ganancia(Prototipos), Candidatas, Valores),
    max_list(Valores, Maximo),
    (   Maximo > 1.0e-9
    ->  primera_mejor(Valores, Candidatas, P)
    ;   elegir(orden, Reglas, Prototipos, P)
    ).

%!  primera_mejor(+Valores:list, +Candidatas:list, -P) is det.
%
%   P es la primera de Candidatas con el mayor de Valores.
primera_mejor(Valores, Candidatas, P) :-
    max_list(Valores, Maximo),
    once(nth1(I, Valores, Maximo)),
    nth1(I, Candidatas, P).

%!  cuantas(+Reglas:list, +P, -K:integer) is det.
%
%   K es la cantidad de Reglas que tienen la pregunta P.
cuantas(Reglas, P, K) :-
    include(con_pregunta(P), Reglas, Con),
    length(Con, K).

%!  ganancia(+Prototipos:list, +P, -G:float) is det.
%
%   G es la información, en bits, que la respuesta a P da sobre la
%   hipótesis de los Prototipos: la entropía de sus hipótesis menos la
%   entropía media que queda en cada rama.
ganancia(Prototipos, P, G) :-
    partition(prototipo_si(P), Prototipos, Si, No),
    length(Prototipos, N),
    length(Si, NSi),
    length(No, NNo),
    entropia(Prototipos, H),
    entropia(Si, HSi),
    entropia(No, HNo),
    G is H - (NSi * HSi + NNo * HNo) / max(N, 1).

%!  entropia(+Prototipos:list, -H:float) is det.
%
%   H es la entropía, en bits, de las hipótesis de Prototipos; 0.0 para
%   una lista vacía.
entropia(Prototipos, H) :-
    length(Prototipos, N),
    pairs_keys(Prototipos, Hs),
    msort(Hs, Ordenadas),
    clumped(Ordenadas, Cuentas),
    foldl(sumar_plogp(N), Cuentas, 0.0, S),
    H is -S.

%!  sumar_plogp(+N:integer, +Cuenta, +S0:float, -S:float) is det.
%
%   S es S0 más q log2 q, con q la fracción K/N de la Cuenta H-K.
sumar_plogp(N, _-K, S0, S) :-
    Q is K / N,
    S is S0 + Q * log(Q) / log(2).

%!  consultar(+Arbol, +Fuente, -Hipotesis, -Preguntas:list) is det.
%
%   Recorre Arbol con las respuestas de Fuente, lista(Observaciones), hasta
%   una hoja: Hipotesis es la de la hoja y Preguntas, las que se hicieron,
%   en orden.
consultar(hoja(H), _, H, []).
consultar(pregunta(P, Si, No), Fuente, H, [P|Ps]) :-
    (   responde_si(Fuente, P)
    ->  consultar(Si, Fuente, H, Ps)
    ;   consultar(No, Fuente, H, Ps)
    ).

%!  consulta(+Estrategia, +Observaciones:list, -Hipotesis,
%!           -Preguntas:list) is det.
%
%   Consulta el árbol de Estrategia con las respuestas de Observaciones.
consulta(Estrategia, Observaciones, Hipotesis, Preguntas) :-
    arbol(Estrategia, Arbol),
    consultar(Arbol, lista(Observaciones), Hipotesis, Preguntas).

%!  responde_si(+Fuente, +P) is semidet.
%
%   La respuesta de Fuente a la pregunta P es afirmativa.
responde_si(lista(Observaciones), P) :-
    se_cumple(P, Observaciones).

%!  medidas(+Arbol, -Medidas) is det.
%
%   Medidas es m(Preguntas, Hojas, Profundidad): los nodos que preguntan,
%   las hojas y la mayor cantidad de preguntas de una consulta.
medidas(hoja(_), m(0, 1, 0)).
medidas(pregunta(_, Si, No), m(N, H, P)) :-
    medidas(Si, m(N1, H1, P1)),
    medidas(No, m(N2, H2, P2)),
    N is N1 + N2 + 1,
    H is H1 + H2,
    P is max(P1, P2) + 1.

%!  medir(?Estrategia, -Medidas, -EnPrototipos:float,
%!        -EnTodos:float) is nondet.
%
%   Medidas son las del árbol de Estrategia, y EnPrototipos y EnTodos, la
%   cantidad media de preguntas que hace para cada población.
medir(Estrategia, Medidas, EnPrototipos, EnTodos) :-
    estrategia(Estrategia),
    arbol(Estrategia, Arbol),
    medidas(Arbol, Medidas),
    promedio(Arbol, prototipos, EnPrototipos),
    promedio(Arbol, todos, EnTodos).

%!  prototipo(?Hipotesis, -Observaciones:list) is nondet.
%
%   Observaciones son las justas para una regla colapsada de Hipotesis:
%   sus preguntas, con el menor valor entero que cumple cada comparación.
prototipo(Hipotesis, Observaciones) :-
    colapsada(Hipotesis, Preguntas),
    maplist(testigo, Preguntas, Observaciones).

%!  testigo(+Pregunta, -Observacion) is det.
%
%   Observacion hace verdadera a Pregunta: la observación misma, o la
%   observación con el valor que cumple la comparación.
testigo(Pregunta, Observacion) :-
    (   Pregunta = (Observacion y X > N)
    ->  X is N + 1
    ;   Pregunta = (Observacion y X < N)
    ->  X is N - 1
    ;   Observacion = Pregunta
    ).

%!  promedio(+Arbol, +Poblacion, -Promedio:float) is det.
%
%   Promedio es la cantidad media de preguntas que hace Arbol para los
%   animales de Poblacion, con dos decimales: prototipos, uno por regla
%   colapsada, o todos, los de observaciones/1.
promedio(Arbol, Poblacion, Promedio) :-
    aggregate_all(count-sum(N),
                  ( poblacion(Poblacion, Os),
                    consultar(Arbol, lista(Os), _, Ps),
                    length(Ps, N) ),
                  Total-Suma),
    Promedio is round(100 * Suma / Total) / 100.0.

%!  poblacion(+Poblacion, -Observaciones:list) is nondet.
%
%   Observaciones son las de un animal de Poblacion.
poblacion(prototipos, Observaciones) :-
    prototipo(_, Observaciones).
poblacion(todos, Observaciones) :-
    observaciones(Observaciones).

%!  observaciones(-Observaciones:list) is multi.
%
%   Observaciones describe un animal posible: cada observación sin valor
%   está o no está, y el peso falta, es 30 o es 90. En total, 3 * 2^13
%   animales, casi todos imposibles, que sirven para probar el árbol.
observaciones(Observaciones) :-
    findall(O, ( observable(O), ground(O) ), Simples),
    subconjunto(Simples, Presentes),
    member(Peso, [[], [peso(30)], [peso(90)]]),
    append(Presentes, Peso, Observaciones).

%!  subconjunto(+Lista:list, -Sub:list) is multi.
%
%   Sub tiene algunos elementos de Lista, en el mismo orden.
subconjunto([], []).
subconjunto([X|Xs], [X|Ys]) :-
    subconjunto(Xs, Ys).
subconjunto([_|Xs], Ys) :-
    subconjunto(Xs, Ys).
