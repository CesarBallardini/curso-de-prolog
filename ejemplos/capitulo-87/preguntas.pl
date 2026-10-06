:- encoding(utf8).

% Capítulo 87 - Versión 5: el programa completo.
%
% responder/3 encadena las versiones: analiza la pregunta con la
% gramática, evalúa su forma lógica y la explica. preguntar/1 escribe la
% respuesta en castellano, con los hechos que la prueban, y sql/1 escribe
% la sentencia SQL equivalente. conversar/0 es el bucle de la sección 5.3
% de Pereira y Shieber: lee una pregunta por línea y la responde, hasta
% una línea vacía o el fin de la entrada. ejemplo/2 reúne las preguntas
% del capítulo, que las pruebas usan para comparar la evaluación en
% Prolog con la ejecución de la sentencia SQL.
%
% solo-local: carga módulos.
%
%?- preguntar("¿Cuántos aprobaron álgebra?").
%?- preguntar("¿Bruno aprobó álgebra?").

:- module(preguntas,
          [ responder/3,
            preguntar/1,
            sql/1,
            conversar/0,
            conversar/2,
            ejemplo/2
          ]).

:- use_module(gramatica).
:- use_module(evaluar).
:- use_module(sql, [mostrar_sql/1]).
:- use_module(nombres).

% Otros archivos pueden agregar formas de escribir una respuesta.
:- multifile escribir_respuesta/1, escribir_explicacion/1.

% ejemplo(N, Texto): la pregunta N de las que el capítulo responde.
ejemplo(1, "¿Quién cursa lógica?").
ejemplo(2, "¿Cuántos aprobaron álgebra?").
ejemplo(3, "¿Quién no aprobó álgebra?").
ejemplo(4, "¿Cuántos alumnos de sistemas aprobaron álgebra?").
ejemplo(5, "¿Qué materias cursa ana?").
ejemplo(6, "¿Ana aprobó lógica?").
ejemplo(7, "¿Bruno aprueba álgebra?").
ejemplo(8, "¿Qué necesita bases de datos?").
ejemplo(9, "¿Qué materias necesitan lógica?").
ejemplo(10, "¿Todos los alumnos de civil cursan análisis 1?").
ejemplo(11, "¿Algún alumno de industrial aprobó lógica?").
ejemplo(12, "¿Ningún alumno aprobó sintaxis?").
ejemplo(13, "¿Qué alumnos que cursan paradigmas aprobaron lógica?").
ejemplo(14, "¿Todos los alumnos que cursan bases de datos aprobaron lógica?").
ejemplo(15, "¿Cuántas materias aprobó ana?").
ejemplo(16, "¿Todos los alumnos de sistemas aprobaron álgebra?").

%!  responder(+Texto, -Respuesta, -Explicacion) is det.
%
%   Respuesta responde la pregunta Texto y Explicacion la justifica, como
%   evaluar/2 y explicar/2. Si la gramática no analiza Texto, Respuesta es
%   sin_analisis y Explicacion es [].
responder(Texto, Respuesta, Explicacion) :-
    (   analizar(Texto, Forma)
    ->  evaluar(Forma, Respuesta),
        explicar(Forma, Explicacion)
    ;   Respuesta = sin_analisis,
        Explicacion = []
    ).

%!  preguntar(+Texto) is det.
%
%   Escribe la respuesta a Texto y su explicación. Las dos formas de
%   escribir son multifile, y otro archivo puede agregarles cláusulas:
%   once/1 se queda con la primera que corresponde.
preguntar(Texto) :-
    responder(Texto, Respuesta, Explicacion),
    once(escribir_respuesta(Respuesta)),
    once(escribir_explicacion(Explicacion)).

%!  sql(+Texto) is semidet.
%
%   Escribe la sentencia SQL de la pregunta Texto. Falla si la gramática
%   no la analiza o su forma lógica no tiene traducción.
sql(Texto) :-
    analizar(Texto, Forma),
    mostrar_sql(Forma).

% --- La respuesta en castellano ----------------------------------------

%!  escribir_respuesta(+Respuesta) is det.
%
%   Escribe Respuesta en una línea.
escribir_respuesta(lista([])) :-
    format("Ninguno~n").
escribir_respuesta(lista(Claves)) :-
    Claves \== [],
    maplist(nombre_de, Claves, Nombres),
    enumeracion(Nombres, Texto),
    format("~s~n", [Texto]).
escribir_respuesta(numero(N)) :-
    format("~d~n", [N]).
escribir_respuesta(si) :-
    format("Sí~n").
escribir_respuesta(no) :-
    format("No~n").
escribir_respuesta(presupone(_)) :-
    format("La pregunta supone que hay casos, y no hay ninguno~n").
escribir_respuesta(sin_analisis) :-
    format("La pregunta no se puede analizar~n").

%!  enumeracion(+Nombres:list(string), -Texto:string) is det.
%
%   Texto enumera Nombres separados por comas, y el último con «y».
enumeracion([N], N).
enumeracion([N1, N2], Texto) :-
    format(string(Texto), "~s y ~s", [N1, N2]).
enumeracion([N1, N2, N3|Ns], Texto) :-
    enumeracion([N2, N3|Ns], Resto),
    format(string(Texto), "~s, ~s", [N1, Resto]).

%!  escribir_explicacion(+Explicacion) is det.
%
%   Escribe Explicacion, sangrada dos columnas: los hechos que prueban
%   cada respuesta, o por qué la respuesta es no.
escribir_explicacion(Pruebas) :-
    is_list(Pruebas),
    forall(member(P, Pruebas), P = _-_),
    forall(member(Clave-Arbol, Pruebas),
           escribir_caso(Clave, Arbol)).
escribir_explicacion(prueba(Arbol)) :-
    (   Arbol = todos(Casos)
    ->  forall(member(Clave-T, Casos), escribir_caso(Clave, T))
    ;   hojas(Arbol, Hojas),
        escribir_hojas("  ", Hojas)
    ).
escribir_explicacion(falla(Motivo)) :-
    escribir_motivo("  ", Motivo).
escribir_explicacion(sin_casos(_)).

%!  escribir_caso(+Clave, +Arbol) is det.
%
%   Escribe el nombre de Clave y las hojas de su prueba.
escribir_caso(Clave, Arbol) :-
    nombre_de(Clave, Nombre),
    hojas(Arbol, Hojas),
    format("  ~s: ", [Nombre]),
    escribir_hojas("", Hojas).

%!  escribir_hojas(+Sangria, +Hojas:list) is det.
%
%   Escribe en una línea las Hojas de una prueba, separadas por comas, sin
%   las que solo dicen que algo es un alumno o una materia.
escribir_hojas(Sangria, Hojas) :-
    exclude(restriccion_de_tipo, Hojas, Utiles),
    format("~s", [Sangria]),
    escribir_lista(Utiles),
    nl.

%!  restriccion_de_tipo(+Hoja) is semidet.
%
%   Hoja es un hecho de alumnos o de materias.
restriccion_de_tipo(alumno(_, _, _, _)).
restriccion_de_tipo(materia(_, _, _)).

%!  escribir_lista(+Hojas:list) is det.
%
%   Escribe Hojas separadas por comas.
escribir_lista([]).
escribir_lista([H]) :-
    escribir_hoja(H).
escribir_lista([H1, H2|Hs]) :-
    escribir_hoja(H1),
    format(", "),
    escribir_lista([H2|Hs]).

%!  escribir_hoja(+Hoja) is det.
%
%   Escribe Hoja: un hecho o una comparación, como término; el motivo por
%   el que una meta no se prueba, como texto.
escribir_hoja(no_alcanza(Hecho, Comparacion)) :-
    !,
    escribir_termino(Hecho),
    format(", y "),
    escribir_termino(Comparacion).
escribir_hoja(sin_nota(Hecho)) :-
    !,
    escribir_termino(Hecho),
    format(", sin nota").
escribir_hoja(sin_hechos(Atomo)) :-
    !,
    format("ningún hecho prueba "),
    escribir_termino(Atomo).
escribir_hoja(ninguno(Casos)) :-
    !,
    length(Casos, N),
    format("ninguno de los ~d casos", [N]).
escribir_hoja(contraejemplo(Clave, Motivo)) :-
    !,
    nombre_de(Clave, Nombre),
    format("~s: ", [Nombre]),
    escribir_hoja(Motivo).
escribir_hoja(se_prueba(Arbol)) :-
    !,
    hojas(Arbol, Hojas),
    exclude(restriccion_de_tipo, Hojas, Utiles),
    format("se prueba: "),
    escribir_lista(Utiles).
escribir_hoja(Termino) :-
    escribir_termino(Termino).

%!  escribir_termino(+Termino) is det.
%
%   Escribe Termino con un espacio después de cada coma de los
%   argumentos, y una comparación con espacios alrededor del operador,
%   como el resto del curso.
escribir_termino(Termino) :-
    (   Termino =.. [Op, A, B],
        memberchk(Op, [>=, <])
    ->  format("~w ~w ~w", [A, Op, B])
    ;   write_term(Termino, [quoted(true), spacing(next_argument)])
    ).

%!  escribir_motivo(+Sangria, +Motivo) is det.
%
%   Escribe por qué una pregunta de sí o no da no: una línea, o una por
%   caso si ningún caso de alguno/3 cumple.
escribir_motivo(Sangria, ninguno(Casos)) :-
    Casos \== [],
    !,
    forall(member(Clave-Motivo, Casos),
           escribir_motivo(Sangria, contraejemplo(Clave, Motivo))).
escribir_motivo(Sangria, Motivo) :-
    format("~s", [Sangria]),
    escribir_hoja(Motivo),
    nl.

% --- El bucle ---------------------------------------------------------------

%!  conversar is det.
%
%   Lee preguntas de la entrada estándar y las responde, hasta una línea
%   vacía o el fin de la entrada.
conversar :-
    conversar(user_input, user_output).

%!  conversar(+Entrada, +Salida) is det.
%
%   Lee preguntas de Entrada, una por línea, y escribe en Salida la
%   respuesta de cada una, después de la indicación «> ».
conversar(Entrada, Salida) :-
    format(Salida, "> ", []),
    flush_output(Salida),
    read_line_to_string(Entrada, Linea),
    (   ( Linea == end_of_file ; Linea == "" )
    ->  true
    ;   with_output_to(Salida, preguntar(Linea)),
        conversar(Entrada, Salida)
    ).
