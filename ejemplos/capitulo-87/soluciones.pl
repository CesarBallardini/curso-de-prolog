:- encoding(utf8).

% Capítulo 87 - Soluciones de los ejercicios.
%
% Carga el programa completo sin modificarlo. Los ejercicios que agregan
% vocabulario lo hacen con cláusulas de los predicados multifile de los
% módulos del capítulo: el léxico del capítulo 53, verbo_tipos/3 y sn//3
% de gramatica.pl, definicion/2 de evaluar.pl y sql_atomo/4 de sql.pl.
%
% solo-local: carga módulos.
%
%?- preguntar("¿Quién desaprobó álgebra?").
%?- simplificar(cual(X, y(y(alumno(X), carrera(X, sistemas)), cursar(X, pp))), S).
%?- por_que_no_esta("¿Quién aprobó análisis 1?", "elena", M).

:- module(soluciones,
          [ simplificar/2,
            por_que_no_esta/3,
            pasos_sin_tabla/3,
            responder_lecturas/2,
            conversar_por_que/2,
            sql_presuposicion/2,
            aplicar/3,
            aplicar_mal/3
          ]).

:- use_module('../capitulo-42/base').
:- reexport(preguntas).
:- reexport(gramatica, [analizar/2, lecturas/2]).
:- reexport(evaluar).
:- reexport(sql, [sql/2]).
:- use_module(nombres).
:- use_module(palabras).

% --- Ejercicio 4: desaprobar ---------------------------------------------

lexico:verbo("desaprobar", o_ue).

gramatica:verbo_tipos(desaprobar, alumno, materia).

evaluar:definicion(desaprobar(L, M), [inscripcion(L, M, N), N < 6]) :-
    inscripcion(L, M, N),
    integer(N),
    N < 6.

sql:sql_atomo(desaprobar(L, M), inscripciones, [legajo-L, materia-M],
              "nota < 6").

% --- Ejercicio 5: simplificar ----------------------------------------------

%!  simplificar(+Forma, -Simple) is det.
%
%   Simple es Forma con cada y(alumno(X), carrera(X, C)) reemplazado por
%   carrera(X, C): la carrera ya dice que X es un alumno.
simplificar(cual(X, F), cual(X, S)) :-
    !,
    simplificar(F, S).
simplificar(cuantos(X, F), cuantos(X, S)) :-
    !,
    simplificar(F, S).
simplificar(si_no(F), si_no(S)) :-
    !,
    simplificar(F, S).
simplificar(y(alumno(X), carrera(Y, C)), carrera(X, C)) :-
    X == Y,
    !.
simplificar(y(A, B), y(SA, SB)) :-
    !,
    simplificar(A, SA),
    simplificar(B, SB).
simplificar(todo(X, R, A), todo(X, SR, SA)) :-
    !,
    simplificar(R, SR),
    simplificar(A, SA).
simplificar(alguno(X, R, A), alguno(X, SR, SA)) :-
    !,
    simplificar(R, SR),
    simplificar(A, SA).
simplificar(no(A), no(SA)) :-
    !,
    simplificar(A, SA).
simplificar(Atomo, Atomo).

% --- Ejercicio 6: por qué no está ------------------------------------------

%!  por_que_no_esta(+Texto, +Nombre, -Motivo) is semidet.
%
%   Motivo explica por qué la entidad que se llama Nombre no está en la
%   respuesta de Texto, una pregunta con cual/2 o cuantos/2. Falla si la
%   pregunta no se analiza, si Nombre no nombra nada o si la entidad está
%   en la respuesta.
por_que_no_esta(Texto, Nombre, Motivo) :-
    analizar(Texto, Forma),
    (   Forma = cual(X, F)
    ;   Forma = cuantos(X, F)
    ),
    !,
    palabras(Nombre, Palabras),
    once(phrase(nombre_propio(_, X), Palabras)),
    \+ probar(F, _),
    por_que_no(F, Motivo).

% --- Ejercicio 7: sin tabla ------------------------------------------------

%!  pasos_sin_tabla(+Materia, ?Requisito, ?N:integer) is nondet.
%
%   La definición de pasos/3 sin la tabla. No termina: la segunda cláusula
%   se llama a sí misma antes de consumir una correlativa.
pasos_sin_tabla(M, R, 1) :-
    correlativa(M, R).
pasos_sin_tabla(M, R, N) :-
    pasos_sin_tabla(M, I, N0),
    correlativa(I, R),
    N is N0 + 1.

% --- Ejercicio 8: todas las lecturas ---------------------------------------

%!  responder_lecturas(+Texto, -Respuestas:list) is det.
%
%   Respuestas tiene un par Forma-Respuesta por cada lectura de Texto.
responder_lecturas(Texto, Respuestas) :-
    lecturas(Texto, Formas),
    findall(F-R, ( member(F, Formas), evaluar(F, R) ), Respuestas).

% --- Ejercicio 9: ¿por qué? ------------------------------------------------

%!  conversar_por_que(+Entrada, +Salida) is det.
%
%   Como conversar/2, pero escribe solo la respuesta; si la línea
%   siguiente es «¿por qué?», escribe la explicación de la última
%   pregunta.
conversar_por_que(Entrada, Salida) :-
    conversar_por_que(Entrada, Salida, ninguna).

%!  conversar_por_que(+Entrada, +Salida, +Ultima) is det.
%
%   Ultima es la explicación de la última pregunta, o ninguna.
conversar_por_que(Entrada, Salida, Ultima) :-
    format(Salida, "> ", []),
    read_line_to_string(Entrada, Linea),
    (   ( Linea == end_of_file ; Linea == "" )
    ->  true
    ;   Linea == "¿por qué?"
    ->  (   Ultima == ninguna
        ->  format(Salida, "No hay una pregunta anterior.~n", [])
        ;   with_output_to(Salida,
                           preguntas:escribir_explicacion(Ultima))
        ),
        conversar_por_que(Entrada, Salida, Ultima)
    ;   responder(Linea, Respuesta, Explicacion),
        with_output_to(Salida, preguntas:escribir_respuesta(Respuesta)),
        conversar_por_que(Entrada, Salida, Explicacion)
    ).

% --- Ejercicio 10: la presuposición en SQL --------------------------------

%!  sql_presuposicion(+Forma, -SQL:string) is semidet.
%
%   SQL es como la sentencia de sql/2, salvo para una pregunta de sí o no
%   con «todos»: da NULL si la restricción no tiene casos, y si los tiene,
%   1 o 0.
sql_presuposicion(si_no(todo(X, R, A)), SQL) :-
    !,
    sql(si_no(R), Hay),
    sql(si_no(todo(X, R, A)), Todos),
    format(string(SQL),
           "SELECT CASE WHEN (~s) = 0 THEN NULL ELSE (~s) END",
           [Hay, Todos]).
sql_presuposicion(Forma, SQL) :-
    sql(Forma, SQL).

% --- Ejercicio 11: la coordinación -----------------------------------------

% Dos nombres propios unidos por «y», después del verbo. La propiedad X^P
% ya está construida cuando se analiza el objeto o el sujeto pospuesto;
% antes del verbo, P todavía es una variable, y la regla no se aplica.

gramatica:sn(plural, Tipo, (X^P)^y(P1, P2)) -->
    nombre_propio(Tipo, E1),
    gramatica:palabra("y"),
    nombre_propio(Tipo, E2),
    { Tipo \== carrera,
      nonvar(P),
      aplicar(X^P, E1, P1),
      aplicar(X^P, E2, P2) }.

%!  aplicar_mal(+Propiedad, +E, -F) is det.
%
%   La aplicación con copy_term/2 sobre la propiedad entera: renombra
%   también las variables de la pregunta. Es el error del ejercicio.
aplicar_mal(X^P, E, F) :-
    copy_term(X^P, E^F).

%!  aplicar(+Propiedad, +E, -F) is det.
%
%   F es la Propiedad X^P aplicada a E: una copia de P con E en lugar de
%   X. Solo X se renombra; las demás variables de P siguen compartidas,
%   porque son las de la pregunta.
aplicar(X^P, E, F) :-
    term_variables(P, Vs0),
    exclude(==(X), Vs0, Libres),
    copy_term(t(Libres, X, P), t(Libres1, X1, F)),
    Libres1 = Libres,
    X1 = E.
