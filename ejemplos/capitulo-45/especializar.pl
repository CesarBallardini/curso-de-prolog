:- encoding(utf8).

% Capítulo 45 - Versión 6: el intérprete de Mini evaluado parcialmente.
%
% especializar_programa/2 evalúa parcialmente el intérprete de
% interprete.pl respecto de un programa Mini, con parcial/3 del capítulo 35
% (parcial.pl). El programa se conoce; los valores de las variables, no
% siempre. El control decide:
%   - las cláusulas del intérprete se despliegan, porque la sintaxis
%     abstracta que recorren se conoce;
%   - valor/3 y actualizar/4 se ejecutan durante la especialización: los
%     nombres del entorno se conocen, aunque sus valores sean variables, y
%     cada variable de Mini pasa a ser una variable de Prolog;
%   - una operación o una comparación sin variables se calcula; con
%     variables, queda en el residuo;
%   - cada si y cada mientras pasa a ser un predicado nuevo, cuyos
%     argumentos son los valores de las variables de Mini antes y después, y
%     las dos puntas de la salida. Sin eso, un mientras se desplegaría sin
%     fin.
% El resultado es un programa Prolog sin intérprete: el principal y una
% definición por construcción. correr_especializado/2 lo carga en un
% módulo temporal y lo ejecuta.
%
% solo-local: carga interprete.pl y parcial.pl del capítulo 35 con
% ensure_loaded/1, y usa módulos temporales.
%
%?- listar_ejemplo(factorial).
%?- programa_ejemplo(mcd, P), correr_especializado(P, S).

:- ensure_loaded(interprete).
:- ensure_loaded('../capitulo-35/parcial').
:- use_module(library(modules)).

%!  especializar_programa(+Programa:list, -Clausulas:list) is det.
%
%   Clausulas es la versión especializada de interpretar/2 para Programa:
%   la cláusula de principal//0, que describe la salida del programa, y las
%   de un predicado por cada si y cada mientras distinto.
especializar_programa(Programa, [(principal(S0, S) :- Cuerpo)|Clausulas]) :-
    construcciones(Programa, Tabla),
    entorno_inicial(Programa, E0),
    once(parcial(ejecutar_bloque(Programa, E0, _, S0, S),
                 control_mini(Tabla), Cuerpo)),
    variables(Programa, Nombres),
    findall(Clausula,
            ( member(K-Nombre, Tabla),
              definicion(K, Nombre, Nombres, Tabla, Clausula) ),
            Clausulas).

%!  construcciones(+Programa:list, -Tabla:list) is det.
%
%   Tabla tiene un par K-Nombre por cada si y cada mientras distinto de
%   Programa, en el orden en que aparecen; Nombre es si_1, mientras_2, ...
construcciones(Programa, Tabla) :-
    findall(K, ( sub_term(K, Programa), compuesta(K) ), Ks0),
    list_to_set(Ks0, Ks),
    nombrar(Ks, 1, Tabla).

% compuesta(K): K es una sentencia que se especializa como predicado propio.
compuesta(si(_, _, _)).
compuesta(mientras(_, _)).

%!  nombrar(+Ks:list, +I:integer, -Tabla:list) is det.
%
%   Tabla da a cada construcción de Ks el nombre de su functor seguido de
%   su número de orden, desde I.
nombrar([], _, []).
nombrar([K|Ks], I, [K-Nombre|Tabla]) :-
    functor(K, F, _),
    format(atom(Nombre), "~w_~w", [F, I]),
    I1 is I + 1,
    nombrar(Ks, I1, Tabla).

%!  definicion(+K, +Nombre, +Nombres:list, +Tabla:list, -Clausula) is nondet.
%
%   Clausula es una cláusula del predicado Nombre, que ejecuta la
%   construcción K: una por cada cláusula del intérprete para K. El
%   entorno de entrada tiene una variable de Prolog por cada variable de
%   Mini de Nombres.
definicion(K, Nombre, Nombres, Tabla, (Cabeza :- Cuerpo)) :-
    findall(X-_, member(X, Nombres), E0),
    clause(ejecutar_sentencia(K, E0, E, S0, S), Cuerpo0),
    once(parcial(Cuerpo0, control_mini(Tabla), Cuerpo)),
    llamada(Nombre, E0, E, S0, S, Cabeza).

%!  llamada(+Nombre, +E0:list, +E:list, ?S0, ?S, -Llamada) is det.
%
%   Llamada es Nombre con los valores del entorno E0, los de E y las puntas
%   S0 y S de la salida como argumentos.
llamada(Nombre, E0, E, S0, S, Llamada) :-
    pairs_values(E0, Vs0),
    pairs_values(E, Vs),
    append([Vs0, Vs, [S0, S]], Argumentos),
    Llamada =.. [Nombre|Argumentos].

%!  control_mini(+Tabla:list, +Meta, -Accion) is semidet.
%
%   Accion es lo que parcial/3 hace con Meta al especializar el intérprete
%   de Mini: desplegar, o dejar(Residuo). Cuando no hay respuesta, Meta
%   queda como está. parcial/3 usa solo la primera respuesta.
control_mini(Tabla, ejecutar_sentencia(K, E0, E, S0, S), dejar(Llamada)) :-
    memberchk(K-Nombre, Tabla),
    findall(X-_, member(X-_, E0), E),
    llamada(Nombre, E0, E, S0, S, Llamada).
control_mini(_, ejecutar_sentencia(_, _, _, _, _), desplegar).
control_mini(_, ejecutar_bloque(_, _, _, _, _), desplegar).
control_mini(_, evaluar(_, _, _), desplegar).
control_mini(_, operar(_, _, _, _), desplegar).
control_mini(_, cierta(_, _), desplegar).
control_mini(_, falsa(_, _), desplegar).
control_mini(_, contraria(_, _), desplegar).
control_mini(_, comparar(_, _, _), desplegar).
control_mini(_, valor(X, E, V), dejar(true)) :-
    valor(X, E, V).
control_mini(_, actualizar(X, V, E0, E), dejar(true)) :-
    actualizar(X, V, E0, E).
control_mini(_, X is Exp, dejar(true)) :-
    ground(Exp),
    catch(X is Exp, _, fail).
control_mini(_, Comparacion, dejar(true)) :-
    comparacion(Comparacion),
    ground(Comparacion),
    call(Comparacion).

% comparacion(G): G es una comparación aritmética de Prolog.
comparacion(_ =:= _).
comparacion(_ =\= _).
comparacion(_ < _).
comparacion(_ > _).
comparacion(_ =< _).
comparacion(_ >= _).

%!  correr_especializado(+Programa:list, -Salida:list(integer)) is det.
%
%   Salida es lo que escribe Programa, ejecutado con su versión
%   especializada, cargada en un módulo temporal.
correr_especializado(Programa, Salida) :-
    especializar_programa(Programa, Clausulas),
    in_temporary_module(M,
                        forall(member(C, Clausulas), assertz(M:C)),
                        once(phrase(M:principal, Salida))).

%!  listar_especializado(+Programa:list) is det.
%
%   Escribe la versión especializada de Programa, una cláusula tras otra.
listar_especializado(Programa) :-
    especializar_programa(Programa, Clausulas),
    forall(member(C, Clausulas), portray_clause(C)).

%!  listar_ejemplo(+Nombre) is semidet.
%
%   Escribe la versión especializada del programa de ejemplo Nombre.
listar_ejemplo(Nombre) :-
    programa_ejemplo(Nombre, Programa),
    listar_especializado(Programa).

%!  inferencias(:Meta, -N:integer) is semidet.
%
%   N es la cantidad de inferencias que usa la primera solución de Meta.
inferencias(Meta, N) :-
    statistics(inferences, I0),
    once(Meta),
    statistics(inferences, I1),
    N is I1 - I0.
