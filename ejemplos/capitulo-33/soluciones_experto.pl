:- encoding(utf8).

% Capítulo 33 - Soluciones de los ejercicios 13 y 14: la negación no en el
% sistema experto que explica, y un motivo que muestra las reglas.
%
% Es experto.pl con tres cambios: el operador no y las reglas r11 y r12 del
% ejercicio 8 del capítulo 19, que dicen no vuela en lugar de la observación
% no_vuela; una cláusula para no en demostrar/4, explicar/2, explicacion/3
% y explicar_no/2; y motivo/2, que escribe cada regla en curso completa.
%
%?- identificar([tiene_plumas, peso(90)], Animal).
%?- por_que_no([tiene_plumas, vuela, peso(90)], avestruz).
%?- motivo(tiene_pelo, [r1-mamifero, r5-carnivoro]).

:- op(800, xfx, entonces).
:- op(790, fx, si).
:- op(780, xfy, y).
:- op(770, fy, no).

% regla(Nombre, si Condiciones entonces Conclusion): las Condiciones, unidas
% con y, permiten concluir Conclusion.
regla(r1,  si tiene_pelo entonces mamifero).
regla(r2,  si da_leche entonces mamifero).
regla(r3,  si tiene_plumas entonces ave).
regla(r4,  si vuela y pone_huevos entonces ave).
regla(r5,  si mamifero y come_carne entonces carnivoro).
regla(r6,  si mamifero y tiene_cascos entonces ungulado).
regla(r7,  si carnivoro y color_leonado y manchas_oscuras entonces guepardo).
regla(r8,  si carnivoro y color_leonado y rayas_negras entonces tigre).
regla(r9,  si ungulado y cuello_largo y manchas_oscuras entonces jirafa).
regla(r10, si ungulado y rayas_negras entonces cebra).
regla(r11, si ave y no vuela y nada entonces pinguino).
regla(r12, si ave y no vuela y peso(P) y P > 50 entonces avestruz).

% hipotesis(H): H es una de las conclusiones finales que el sistema busca.
hipotesis(guepardo).
hipotesis(tigre).
hipotesis(jirafa).
hipotesis(cebra).
hipotesis(pinguino).
hipotesis(avestruz).

% caso(N, Observaciones): las observaciones de un animal de ejemplo.
caso(1, [tiene_pelo, come_carne, color_leonado, manchas_oscuras]).
caso(2, [da_leche, tiene_cascos, rayas_negras]).
caso(3, [tiene_plumas, peso(90)]).
caso(4, [tiene_plumas, nada, peso(30)]).
caso(5, [tiene_pelo, tiene_cascos]).

% observable(M): M se observa, o se pregunta; ninguna regla lo concluye.
observable(tiene_pelo).
observable(da_leche).
observable(tiene_plumas).
observable(vuela).
observable(pone_huevos).
observable(come_carne).
observable(tiene_cascos).
observable(color_leonado).
observable(manchas_oscuras).
observable(rayas_negras).
observable(cuello_largo).
observable(nada).
observable(peso(_)).

:- dynamic respondida/2.

% respondida(Pregunta, Respuesta): el usuario ya respondió Pregunta.

%!  demostrar(+Meta, +Fuente, +Pila:list, -Arbol) is nondet.
%
%   Meta se prueba con las reglas y las observaciones de Fuente: lista(Os)
%   o usuario. Pila son los pares Regla-Conclusion en curso, la más reciente
%   primero. Arbol es la prueba, con la forma de la de prueba/3.
demostrar(A y B, Fuente, Pila, ArbolA y ArbolB) :-
    demostrar(A, Fuente, Pila, ArbolA),
    demostrar(B, Fuente, Pila, ArbolB).
demostrar(no Meta, Fuente, Pila, no Meta) :-
    \+ demostrar(Meta, Fuente, Pila, _).
demostrar(X > Y, _, _, X > Y) :-
    X > Y.
demostrar(X < Y, _, _, X < Y) :-
    X < Y.
demostrar(Meta, Fuente, Pila, observado(Meta)) :-
    observable(Meta),
    observar(Fuente, Meta, Pila).
demostrar(Meta, Fuente, Pila, deducido(Meta, Regla, Arbol)) :-
    regla(Regla, si Condiciones entonces Meta),
    demostrar(Condiciones, Fuente, [Regla-Meta|Pila], Arbol).

%!  observar(+Fuente, ?Meta, +Pila:list) is nondet.
%
%   Meta se observa según Fuente: está en la lista, o el usuario lo
%   confirma.
observar(lista(Observaciones), Meta, _) :-
    member(Meta, Observaciones).
observar(usuario, Meta, Pila) :-
    preguntar(Meta, Pila).

%!  identificar(+Observaciones:list, -Animal) is nondet.
%
%   Animal es una de las hipótesis que se prueban a partir de Observaciones.
identificar(Observaciones, Animal) :-
    hipotesis(Animal),
    once(demostrar(Animal, lista(Observaciones), [], _)).

%!  como(+Observaciones:list, +Animal) is semidet.
%
%   Escribe cómo se llega a Animal a partir de Observaciones. Falla si
%   Animal no se prueba.
como(Observaciones, Animal) :-
    once(demostrar(Animal, lista(Observaciones), [], Arbol)),
    explicar(Arbol, 0).

%!  explicar(+Arbol, +Sangria:integer) is det.
%
%   Escribe Arbol a partir de la columna Sangria.
explicar(A y B, Sangria) :-
    explicar(A, Sangria),
    explicar(B, Sangria).
explicar(observado(M), Sangria) :-
    format("~t~*|~w: observado~n", [Sangria, M]).
explicar(no M, Sangria) :-
    format("~t~*|no ~w: no se prueba ~w~n", [Sangria, M, M]).
explicar(X > Y, Sangria) :-
    format("~t~*|~w > ~w: se cumple~n", [Sangria, X, Y]).
explicar(X < Y, Sangria) :-
    format("~t~*|~w < ~w: se cumple~n", [Sangria, X, Y]).
explicar(deducido(M, Regla, Arbol), Sangria) :-
    format("~t~*|~w: por ~w~n", [Sangria, M, Regla]),
    Siguiente is Sangria + 2,
    explicar(Arbol, Siguiente).

%!  consultar(-Animal) is nondet.
%
%   Pregunta al usuario las observaciones que hacen falta y da cada
%   hipótesis que se prueba con sus respuestas; escribe cómo se llegó a
%   ella. Olvida las respuestas de una consulta anterior.
consultar(Animal) :-
    retractall(respondida(_, _)),
    hipotesis(Animal),
    once(demostrar(Animal, usuario, [], Arbol)),
    explicar(Arbol, 0).

%!  preguntar(?Meta, +Pila:list) is semidet.
%
%   El usuario confirma Meta: responde si, o el término Meta con sus
%   variables ligadas. Cada pregunta se hace una sola vez; la respuesta
%   queda en respondida/2.
preguntar(Meta, Pila) :-
    (   respondida(Pregunta, Respuesta),
        Pregunta =@= Meta
    ->  true
    ;   leer_respuesta(Meta, Pila, Respuesta),
        assertz(respondida(Meta, Respuesta))
    ),
    aceptar(Respuesta, Meta).

%!  leer_respuesta(+Meta, +Pila:list, -Respuesta) is det.
%
%   Pregunta Meta y lee la respuesta. Mientras la respuesta es por_que,
%   escribe el motivo de la pregunta y vuelve a preguntar.
leer_respuesta(Meta, Pila, Respuesta) :-
    format("¿~w? ", [Meta]),
    read(Respuesta0),
    (   Respuesta0 == por_que
    ->  motivo(Meta, Pila),
        leer_respuesta(Meta, Pila, Respuesta)
    ;   Respuesta = Respuesta0
    ).

%!  aceptar(+Respuesta, ?Meta) is semidet.
%
%   Respuesta confirma Meta: es si, o un término que unifica con Meta.
aceptar(si, _).
aceptar(Respuesta, Meta) :-
    Respuesta \== si,
    Respuesta \== no,
    Respuesta = Meta.

%!  motivo(+Meta, +Pila:list) is det.
%
%   Escribe para qué se pregunta Meta: cada regla en curso, completa, de la
%   más reciente a la que concluye la hipótesis.
motivo(Meta, Pila) :-
    format("~w se pregunta para aplicar:~n", [Meta]),
    forall(member(Regla-_, Pila),
           ( regla(Regla, Texto),
             format("  ~w: ~w~n", [Regla, Texto]) )).

%!  por_que_no(+Observaciones:list, +Animal) is semidet.
%
%   Escribe por qué Animal no se prueba a partir de Observaciones. Falla si
%   Animal se prueba.
por_que_no(Observaciones, Animal) :-
    no_se_prueba(Animal, Observaciones, Explicacion),
    explicar_no(Explicacion, 0).

%!  no_se_prueba(+Meta, +Observaciones:list, -Explicacion) is semidet.
%
%   Meta no se prueba a partir de Observaciones, y Explicacion dice por
%   qué: no_observado(M), no_se_cumple(Comparacion), se_prueba(M) para
%   no M, o no_probado(M, Ramas),
%   con un par Regla-Explicacion por cada regla que concluye M. Falla si
%   Meta se prueba.
no_se_prueba(Meta, Observaciones, Explicacion) :-
    \+ demostrar(Meta, lista(Observaciones), [], _),
    explicacion(Meta, Observaciones, Explicacion).

%!  explicacion(+Condicion, +Observaciones:list, -Explicacion) is det.
%
%   Explicacion dice por qué Condicion, que no se prueba, falla. En una
%   conjunción, explica la primera condición que falla con las ligaduras
%   de la primera prueba de las anteriores.
explicacion(Condicion, Observaciones, Explicacion) :-
    (   Condicion = (A y B)
    ->  (   demostrar(A, lista(Observaciones), [], _)
        ->  explicacion(B, Observaciones, Explicacion)
        ;   explicacion(A, Observaciones, Explicacion)
        )
    ;   Condicion = (no C)
    ->  Explicacion = se_prueba(C)
    ;   comparacion(Condicion)
    ->  Explicacion = no_se_cumple(Condicion)
    ;   observable(Condicion)
    ->  Explicacion = no_observado(Condicion)
    ;   findall(Regla-E,
                ( regla(Regla, si Condiciones entonces Condicion),
                  explicacion(Condiciones, Observaciones, E) ),
                Ramas),
        Explicacion = no_probado(Condicion, Ramas)
    ).

% comparacion(C): C es una comparación que las reglas pueden usar.
comparacion(_ > _).
comparacion(_ < _).

%!  explicar_no(+Explicacion, +Sangria:integer) is det.
%
%   Escribe Explicacion a partir de la columna Sangria.
explicar_no(no_observado(M), Sangria) :-
    format("~t~*|~w: no observado~n", [Sangria, M]).
explicar_no(se_prueba(M), Sangria) :-
    format("~t~*|no ~w: se prueba ~w~n", [Sangria, M, M]).
explicar_no(no_se_cumple(C), Sangria) :-
    C =.. [Op, X, Y],
    format("~t~*|~w ~w ~w: no se cumple~n", [Sangria, X, Op, Y]).
explicar_no(no_probado(M, Ramas), Sangria) :-
    format("~t~*|~w: no se prueba~n", [Sangria, M]),
    Sangria1 is Sangria + 2,
    Sangria2 is Sangria + 4,
    forall(member(Regla-E, Ramas),
           ( format("~t~*|por ~w:~n", [Sangria1, Regla]),
             explicar_no(E, Sangria2) )).
