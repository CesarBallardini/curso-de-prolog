:- encoding(utf8).

% Capítulo 66 - Versión 5: el árbol compilado y la consulta.
%
% El término arbol_compilado(Estrategia) del archivo se expande al
% cargarlo, con term_expansion/2, en las cláusulas de nodo/3: una por
% nodo del árbol de esa estrategia, numerados en preorden. Un nodo que
% pregunta elige con ->/2 la cláusula del hijo; una hoja da la hipótesis.
% La consulta no busca reglas ni recorre un término: salta de una
% cláusula a otra. La fuente de las respuestas es una lista de
% observaciones o el usuario, que responde con read/1. La consulta con el
% usuario le habla de tú. preguntas_encadenando/2 cuenta las preguntas que
% hace, con las mismas respuestas, la consulta del capítulo 33.
%
% solo-local: carga el sistema experto del capítulo 33, y SWISH no admite
% módulos propios.
%
%?- caso(2, Os), identificar_compilado(Os, H).
%?- caso(2, Os), preguntas_encadenando(Os, Ps).

:- module(compilado,
          [ nodo/3,
            identificar_compilado/2,
            consulta_interactiva/1,
            preguntas_encadenando/2
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(pairs)).
:- reexport(arbol).

%!  term_expansion(+Termino, -Clausulas:list) is semidet.
%
%   Expande arbol_compilado(Estrategia) en las cláusulas de nodo/3 del
%   árbol de Estrategia.
term_expansion(arbol_compilado(Estrategia), Clausulas) :-
    arbol(Estrategia, Arbol),
    phrase(clausulas(Arbol, 1, _), Clausulas).

%!  clausulas(+Arbol, +N:integer, -Siguiente:integer)// is det.
%
%   Las cláusulas de nodo/3 de Arbol, cuya raíz es el nodo N; Siguiente es
%   el primer número libre después de sus nodos.
clausulas(hoja(H), N, Siguiente) -->
    { Siguiente is N + 1 },
    [ nodo(N, _, H) ].
clausulas(pregunta(P, Si, No), N, Siguiente) -->
    { NSi is N + 1 },
    [ ( nodo(N, Fuente, H) :-
            (   responde(Fuente, P)
            ->  nodo(NSi, Fuente, H)
            ;   nodo(NNo, Fuente, H)
            ) ) ],
    clausulas(Si, NSi, NNo),
    clausulas(No, NNo, Siguiente).

arbol_compilado(orden).

%!  identificar_compilado(+Observaciones:list, -Hipotesis) is det.
%
%   Hipotesis es la que da el árbol compilado con las respuestas de
%   Observaciones, o ninguna.
identificar_compilado(Observaciones, Hipotesis) :-
    nodo(1, lista(Observaciones), Hipotesis).

%!  consulta_interactiva(-Hipotesis) is det.
%
%   Recorre el árbol compilado con las respuestas del usuario, leídas de
%   la entrada actual, y le dice el resultado.
consulta_interactiva(Hipotesis) :-
    nodo(1, usuario, Hipotesis),
    (   Hipotesis == ninguna
    ->  format("Con tus respuestas no se identifica ningún animal.~n")
    ;   format("Tu animal es: ~w.~n", [Hipotesis])
    ).

%!  responde(+Fuente, +Pregunta) is semidet.
%
%   La respuesta de Fuente a Pregunta es afirmativa. Con el usuario, una
%   pregunta sobre un valor pide el valor, y la comparación decide.
responde(lista(Observaciones), Pregunta) :-
    responde_si(lista(Observaciones), Pregunta).
responde(usuario, Pregunta) :-
    (   Pregunta = (Observacion y Comparacion)
    ->  Observacion =.. [Nombre, Valor],
        format("¿Cuánto vale ~w? Responde con un número, o no. ",
               [Nombre]),
        read(Respuesta),
        number(Respuesta),
        \+ \+ ( Valor = Respuesta,
                call(Comparacion) )
    ;   format("¿~w? Responde si o no. ", [Pregunta]),
        read(Respuesta),
        Respuesta == si
    ).

%!  preguntas_encadenando(+Observaciones:list, -Preguntas:list) is det.
%
%   Preguntas son las que hace consultar/1 del capítulo 33 hasta la
%   primera hipótesis, cuando el usuario responde según Observaciones. La
%   consulta se repite: cada vez que la entrada se acaba, la pregunta que
%   quedó sin respuesta recibe la de Observaciones y se vuelve a empezar.
preguntas_encadenando(Observaciones, Preguntas) :-
    repetir(Observaciones, [], Preguntas).

%!  repetir(+Observaciones:list, +Respuestas:list, -Preguntas:list) is det.
%
%   Consulta con Respuestas como entrada; si faltó una, la agrega y
%   repite.
repetir(Observaciones, Respuestas, Preguntas) :-
    with_output_to(string(Texto),
                   forall(member(R, Respuestas),
                          format("~q. ", [R]))),
    setup_call_cleanup(
        open_string(Texto, Entrada),
        with_output_to(string(_),
                       consultar_con(Entrada)),
        close(Entrada)),
    findall(P-R, user:respondida(P, R), Pares),
    retractall(user:respondida(_, _)),
    (   member(P-end_of_file, Pares)
    ->  respuesta(Observaciones, P, R),
        append(Respuestas, [R], Respuestas1),
        repetir(Observaciones, Respuestas1, Preguntas)
    ;   pairs_keys(Pares, Preguntas)
    ).

%!  consultar_con(+Entrada) is det.
%
%   Ejecuta consultar/1 del capítulo 33 hasta la primera hipótesis, o
%   hasta que falla, leyendo las respuestas de Entrada.
consultar_con(Entrada) :-
    current_input(Antes),
    setup_call_cleanup(set_input(Entrada),
                       ignore(user:consultar(_)),
                       set_input(Antes)).

%!  respuesta(+Observaciones:list, +Pregunta, -Respuesta) is det.
%
%   Respuesta es lo que responde a Pregunta un usuario que ve
%   Observaciones: si, la observación con su valor, o no.
respuesta(Observaciones, Pregunta, Respuesta) :-
    (   member(O, Observaciones),
        O =@= Pregunta
    ->  Respuesta = si
    ;   member(O, Observaciones),
        \+ \+ O = Pregunta
    ->  Respuesta = O
    ;   Respuesta = no
    ).
