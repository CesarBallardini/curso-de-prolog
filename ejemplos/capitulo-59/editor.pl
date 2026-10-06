:- encoding(utf8).

% Capítulo 59 - Un editor de cláusulas.
%
% El primero de los tres programas del apéndice de Kluźniak y Szpakowicz,
% escrito con lo que SWI-Prolog ofrece hoy. Se edita un predicado dinámico
% por su indicador Nombre/Aridad. El estado del editor es
% editor(PI, Cursor, Clausulas): el cursor es el número de una cláusula,
% contado desde 1, o 0 antes de la primera, y Clausulas es la lista de las
% cláusulas del predicado, como términos Cabeza :- Cuerpo.
%
% Los comandos son términos de Prolog que se leen con read_term/3: s y a
% llevan el cursor a la cláusula siguiente y a la anterior, p y u al
% principio y a la última, l lista el predicado, b borra la cláusula del
% cursor, i inserta las cláusulas que siguen, hasta end, después del
% cursor, e(PI) edita otro predicado y x termina. Los + y - del libro no
% sirven: un + seguido del punto final se lee como el átomo '+.', porque
% los dos son caracteres simbólicos. Cada cambio se guarda en la base con
% transaction/1, que reemplaza todas las cláusulas a la vez o ninguna.
%
% solo-local: lee comandos de un stream y cambia la base dinámica.
%
%?- abrir(nota/2, E0), comando(i([(nota(rosa, 10) :- true)]), E0, E),
%   grabar(E).
%?- editar_texto("u. b. l. x.", nota/2).

:- dynamic nota/2.

% nota(A, N): el alumno A tiene la nota N. Un predicado para editar.
nota(ana, 7).
nota(luis, 5).
nota(eva, 8).

%!  abrir(+PI, -Estado) is det.
%
%   Estado es el editor del predicado PI con el cursor en 0 y las
%   cláusulas que tiene en la base, en orden.
abrir(Nombre/Aridad, editor(Nombre/Aridad, 0, Clausulas)) :-
    functor(Cabeza, Nombre, Aridad),
    findall(Cabeza :- Cuerpo, clause(Cabeza, Cuerpo), Clausulas).

%!  comando(+Comando, +Estado0, -Estado) is semidet.
%
%   Estado es Estado0 después del Comando. b borra la cláusula del cursor,
%   que queda en la siguiente, o en la nueva última si borró la última; con
%   el cursor en 0 no borra nada. i(Cs) inserta Cs después del cursor, que
%   queda en la última insertada. Falla si Comando no es un comando que
%   cambia el estado.
comando(s, editor(PI, C0, Cs), editor(PI, C, Cs)) :-
    length(Cs, N),
    C is min(C0 + 1, N).
comando(a, editor(PI, C0, Cs), editor(PI, C, Cs)) :-
    C is max(C0 - 1, 0).
comando(p, editor(PI, _, Cs), editor(PI, 0, Cs)).
comando(u, editor(PI, _, Cs), editor(PI, N, Cs)) :-
    length(Cs, N).
comando(b, editor(PI, C0, Cs0), editor(PI, C, Cs)) :-
    (   C0 > 0
    ->  nth1(C0, Cs0, _, Cs),
        length(Cs, N),
        C is min(C0, N)
    ;   C = C0,
        Cs = Cs0
    ).
comando(i(Nuevas), editor(PI, C0, Cs0), editor(PI, C, Cs)) :-
    length(Antes, C0),
    append(Antes, Despues, Cs0),
    append([Antes, Nuevas, Despues], Cs),
    length(Nuevas, K),
    C is C0 + K.

%!  grabar(+Estado) is det.
%
%   Reemplaza en la base las cláusulas del predicado del Estado por las del
%   Estado, en una sola transacción.
grabar(editor(Nombre/Aridad, _, Clausulas)) :-
    functor(Cabeza, Nombre, Aridad),
    transaction(( retractall(Cabeza),
                  forall(member(C, Clausulas), assertz(C)) )).

%!  editar(+PI) is det.
%
%   Edita el predicado PI con comandos leídos de la entrada estándar.
editar(PI) :-
    editar_desde(user_input, PI).

%!  editar_texto(+Texto, +PI) is det.
%
%   Edita el predicado PI con los comandos de Texto, como si se escribieran
%   en la entrada estándar.
editar_texto(Texto, PI) :-
    setup_call_cleanup(open_string(Texto, In),
                       editar_desde(In, PI),
                       close(In)).

%!  editar_desde(+In, +PI) is det.
%
%   Edita el predicado PI con comandos leídos del stream In, hasta x o el
%   fin del stream. Después de cada comando escribe el cursor y su
%   cláusula.
editar_desde(In, PI) :-
    abrir(PI, Estado),
    mostrar_cursor(Estado),
    sesion(In, Estado).

%!  sesion(+In, +Estado) is det.
%
%   Lee y ejecuta comandos de In desde el Estado.
sesion(In, Estado0) :-
    read_term(In, Comando, []),
    (   memberchk(Comando, [x, end_of_file])
    ->  true
    ;   ejecutar_comando(Comando, In, Estado0, Estado),
        mostrar_cursor(Estado),
        sesion(In, Estado)
    ).

%!  ejecutar_comando(+Comando, +In, +Estado0, -Estado) is det.
%
%   Ejecuta un Comando leído: i lee las cláusulas que siguen, l lista, e(PI)
%   abre un editor anidado y relee el predicado al volver, y los demás
%   cambian el estado con comando/3 y lo guardan. Un comando desconocido se
%   informa y no cambia nada.
ejecutar_comando(i, In, Estado0, Estado) :-
    !,
    leer_clausulas(In, Nuevas),
    comando(i(Nuevas), Estado0, Estado),
    grabar(Estado).
ejecutar_comando(l, _, Estado, Estado) :-
    !,
    listar(Estado).
ejecutar_comando(e(PI), In, Estado0, Estado) :-
    !,
    editar_desde(In, PI),
    releer(Estado0, Estado).
ejecutar_comando(Comando, _, Estado0, Estado) :-
    (   comando(Comando, Estado0, Estado)
    ->  grabar(Estado)
    ;   format("comando desconocido: ~q~n", [Comando]),
        Estado = Estado0
    ).

%!  leer_clausulas(+In, -Clausulas:list) is det.
%
%   Clausulas son los términos de In hasta end, como cláusulas: un hecho H
%   es H :- true.
leer_clausulas(In, Clausulas) :-
    read_term(In, T, []),
    (   memberchk(T, [end, end_of_file])
    ->  Clausulas = []
    ;   como_clausula(T, C),
        Clausulas = [C|Resto],
        leer_clausulas(In, Resto)
    ).

% como_clausula(T, C): C es el término T como Cabeza :- Cuerpo.
como_clausula(T, C) :-
    (   T = (_ :- _)
    ->  C = T
    ;   C = (T :- true)
    ).

%!  releer(+Estado0, -Estado) is det.
%
%   Estado tiene las cláusulas que el predicado de Estado0 tiene ahora en la
%   base, y el mismo cursor, o el último si ahora hay menos cláusulas.
releer(editor(PI, C0, _), editor(PI, C, Cs)) :-
    abrir(PI, editor(PI, 0, Cs)),
    length(Cs, N),
    C is min(C0, N).

%!  mostrar_cursor(+Estado) is det.
%
%   Escribe el predicado, el cursor y la cláusula del cursor.
mostrar_cursor(editor(PI, 0, _)) :-
    !,
    format("~q 0: (antes de la primera)~n", [PI]).
mostrar_cursor(editor(PI, C, Cs)) :-
    nth1(C, Cs, Clausula),
    format("~q ~w: ", [PI, C]),
    portray_clause(Clausula).

%!  listar(+Estado) is det.
%
%   Escribe todas las cláusulas con su número; la del cursor, marcada.
listar(editor(_, C, Cs)) :-
    forall(nth1(I, Cs, Clausula),
           ( (   I =:= C
             ->  Marca = '>'
             ;   Marca = ' '
             ),
             format("~w~t~w~4|  ", [Marca, I]),
             portray_clause(Clausula) )).
