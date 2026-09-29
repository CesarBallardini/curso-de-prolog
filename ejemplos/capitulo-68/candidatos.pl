:- encoding(utf8).

% Capítulo 68 - Versión 3: eliminación de candidatos.
%
% El estado es ev(S, G), los dos bordes del espacio de versiones. Un
% positivo elimina de G los conceptos que no lo cubren y generaliza los de
% S lo mínimo para cubrirlo, conservando solo los que quedan debajo de
% algún concepto de G. Un negativo elimina de S los conceptos que lo
% cubren y especializa los de G lo mínimo para no cubrirlo, conservando
% solo los que quedan encima de algún concepto de S. Cada borde reemplaza
% la lista de ejemplos que la versión 2 guardaba para el otro: ningún
% ejemplo se guarda.
%
% El aprendizaje termina de dos maneras: converge, cuando S y G tienen un
% solo concepto y es el mismo, o colapsa, cuando uno de los bordes queda
% vacío porque ningún concepto del lenguaje es consistente con los
% ejemplos.
%
% solo-local: carga espacio.pl, que carga un archivo de otro capítulo.
%
%?- eliminar_de(esfera_roja, 3, EV).
%?- traza(esfera_roja).

:- module(candidatos,
          [ inicial/1,
            actualizar/3,
            eliminar/2,
            eliminar_de/3,
            estado/2,
            entre_bordes/2,
            traza/1,
            con_extra/2,
            comparar/3
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- reexport(unidireccional).

%!  inicial(-EV) is det.
%
%   EV es el espacio de versiones antes de ver ejemplos: S tiene vacio, G
%   el concepto que cubre todo.
inicial(ev([vacio], [T])) :-
    mas_general_de_todos(T).

%!  eliminar(+Ejs:list, -EV) is det.
%
%   EV es el espacio de versiones de los ejemplos Ejs, como ev(S, G).
eliminar(Ejs, EV) :-
    inicial(EV0),
    foldl(actualizar, Ejs, EV0, EV).

%!  eliminar_de(+Nombre, +K:integer, -EV) is det.
%
%   EV es el espacio de versiones de los primeros K ejemplos de la
%   secuencia Nombre.
eliminar_de(Nombre, K, EV) :-
    prefijo(Nombre, K, Ejs),
    eliminar(Ejs, EV).

%!  actualizar(+Ej, +EV0, -EV) is det.
%
%   EV es el espacio de versiones EV0 después de ver el ejemplo Ej.
actualizar(pos(I), ev(S0, G0), ev(S, G)) :-
    include(cubre_instancia(I), G0, G),
    maplist(generalizacion_con(I), S0, S1),
    include(debajo_de_alguno(G), S1, S2),
    minimos(S2, S3),
    conjunto(S3, S).
actualizar(neg(I), ev(S0, G0), ev(S, G)) :-
    exclude(cubre_instancia(I), S0, S),
    foldl(especializar_hacia(I, S), G0, [], G1),
    maximos(G1, G2),
    conjunto(G2, G).

%!  especializar_hacia(+I, +S:list, +C, +Gs0:list, -Gs:list) is det.
%
%   Gs es Gs0 con C agregado si C no cubre el negativo I, o con las
%   especializaciones mínimas de C que no lo cubren y quedan encima de
%   algún concepto de S.
especializar_hacia(I, S, C, Gs0, Gs) :-
    (   cubre(C, I)
    ->  findall(H, ( especializacion(C, I, H),
                     encima_de_alguno(S, H) ), Hs),
        append(Gs0, Hs, Gs)
    ;   append(Gs0, [C], Gs)
    ).

%!  debajo_de_alguno(+G:list, @C) is semidet.
%
%   Algún concepto de G es al menos tan general como C.
debajo_de_alguno(G, C) :-
    member(X, G),
    generaliza(X, C),
    !.

%!  encima_de_alguno(+S:list, @C) is semidet.
%
%   C es al menos tan general como algún concepto de S.
encima_de_alguno(S, C) :-
    member(X, S),
    generaliza(C, X),
    !.

%!  estado(+EV, -E) is det.
%
%   E es convergio(C) si los dos bordes tienen el mismo concepto C y
%   nada más, colapso si alguno está vacío, y abierto en otro caso.
estado(ev(S, G), E) :-
    (   ( S == [] ; G == [] )
    ->  E = colapso
    ;   S = [C],
        G = [D],
        C =@= D
    ->  E = convergio(C)
    ;   E = abierto
    ).

%!  entre_bordes(+EV, -N:integer) is det.
%
%   N es la cantidad de conceptos del lenguaje que están encima de algún
%   concepto de S y debajo de algún concepto de G.
entre_bordes(ev(S, G), N) :-
    aggregate_all(count,
                  ( concepto(C),
                    encima_de_alguno(S, C),
                    debajo_de_alguno(G, C) ),
                  N).

%!  traza(+Nombre) is det.
%
%   Escribe, para cada ejemplo de la secuencia Nombre, el ejemplo, los dos
%   bordes después de verlo y la cantidad de conceptos entre ellos, y al
%   final el estado del espacio.
traza(Nombre) :-
    secuencia(Nombre, Ejs),
    inicial(EV0),
    foldl(paso_traza, Ejs, EV0, EV),
    estado(EV, E),
    (   E = convergio(C)
    ->  format("converge en "),
        mostrar_conceptos([C])
    ;   format("~w~n", [E])
    ).

%!  paso_traza(+Ej, +EV0, -EV) is det.
%
%   Actualiza EV0 con Ej y escribe el paso.
paso_traza(Ej, EV0, EV) :-
    actualizar(Ej, EV0, EV),
    EV = ev(S, G),
    entre_bordes(EV, N),
    mostrar_conceptos([Ej]),
    format("  S:~n"),
    mostrar_sangrado(S),
    format("  G:~n"),
    mostrar_sangrado(G),
    format("  conceptos entre los bordes: ~d~n", [N]).

%!  mostrar_sangrado(+Cs:list) is det.
%
%   Escribe los conceptos de Cs con cuatro espacios delante.
mostrar_sangrado(Cs) :-
    forall(member(C, Cs),
           ( format("    "),
             mostrar_conceptos([C]) )).

%!  con_extra(+K:integer, :Meta) is semidet.
%
%   Prueba Meta con K atributos más en el lenguaje: extra1, extra2, ...,
%   cada uno con tres valores. Los atributos se quitan al terminar, aunque
%   Meta falle o lance una excepción.
con_extra(K, Meta) :-
    findall(atributo(A, Vs), atributo_extra(K, A, Vs), Extras),
    setup_call_cleanup(maplist(agregar_atributo, Extras),
                       once(Meta),
                       maplist(quitar_atributo, Extras)).

%!  atributo_extra(+K:integer, -A, -Vs:list) is nondet.
%
%   A es uno de los K atributos extra, y Vs sus tres valores, distintos de
%   los de cualquier otro atributo.
atributo_extra(K, A, [V1, V2, V3]) :-
    between(1, K, J),
    format(atom(A), "extra~d", [J]),
    format(atom(V1), "x~d_1", [J]),
    format(atom(V2), "x~d_2", [J]),
    format(atom(V3), "x~d_3", [J]).

%!  agregar_atributo(+Hecho) is det.
%
%   Agrega el Hecho atributo/2 al final de los de espacio.
agregar_atributo(Hecho) :-
    assertz(espacio:Hecho).

%!  quitar_atributo(+Hecho) is det.
%
%   Quita el Hecho atributo/2 de espacio.
quitar_atributo(Hecho) :-
    retract(espacio:Hecho).

%!  comparar(+K:integer, -Bordes:integer, -Enumeracion:integer) is det.
%
%   Con K atributos extra, Bordes son las inferencias que usa eliminar/2
%   sobre la secuencia esfera_roja, y Enumeracion las que usan version/2,
%   minimos/2 y maximos/2 sobre la misma secuencia. Cada instancia de la
%   secuencia tiene el primer valor de cada atributo extra.
comparar(K, Bordes, Enumeracion) :-
    con_extra(K, comparar_(K, Bordes, Enumeracion)).

%!  comparar_(+K:integer, -Bordes:integer, -Enumeracion:integer) is det.
%
%   comparar/3 con los atributos extra ya agregados.
comparar_(K, Bordes, Enumeracion) :-
    secuencia(esfera_roja, Ejs0),
    maplist(ampliar(K), Ejs0, Ejs),
    inferencias(eliminar(Ejs, _), Bordes),
    inferencias(( version(Ejs, V),
                  minimos(V, _),
                  maximos(V, _) ), Enumeracion).

%!  ampliar(+K:integer, +Ej0, -Ej) is det.
%
%   Ej es el ejemplo Ej0 con el valor 1 en cada uno de los K atributos
%   extra.
ampliar(K, Ej0, Ej) :-
    Ej0 =.. [Clase, I0],
    I0 =.. [pieza|Args0],
    findall(V, ( between(1, K, J),
                 format(atom(V), "x~d_1", [J]) ), Extras),
    append(Args0, Extras, Args),
    I =.. [pieza|Args],
    Ej =.. [Clase, I].

%!  inferencias(:Meta, -N:integer) is semidet.
%
%   N es la cantidad de inferencias que usa la primera prueba de Meta. Meta
%   se prueba una vez antes de medir, para que la carga automática de las
%   bibliotecas no entre en la cuenta.
inferencias(Meta, N) :-
    \+ \+ once(Meta),
    statistics(inferences, I0),
    once(Meta),
    statistics(inferences, I1),
    N is I1 - I0.
