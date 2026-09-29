:- encoding(utf8).

% Capítulo 65 - Soluciones de los ejercicios 2, 3, 6, 7, 9 y 10.
%
% Una sola base con varios dominios que no comparten predicados: Hans y el
% dialecto de Pensilvania (2), Inés, la estudiante sin el eslabón derrotado
% (3), tres automóviles (6), el diamante de Drácula con tnot/1 (9) y el
% intérprete de Flach para el razonamiento por defecto (10).
%
% solo-local: carga módulos propios, y SWISH no los admite.
%
%?- respuesta([especificidad], nacio_en(hans, eeuu), R).
%?- sospechosas(auto3, Ps).
%?- explicar_por_defecto(no(vuela(dracula)), E).

:- use_module(explicaciones).

% Ejercicio 2 ----------------------------------------------------------

% habla_pensilvania(X): X habla el dialecto alemán de Pensilvania.
habla_pensilvania(hans).

%!  habla_dialecto_aleman(?X) is nondet.
%
%   X habla un dialecto del alemán: quien habla el de Pensilvania.
habla_dialecto_aleman(X) :-
    habla_pensilvania(X).

%!  nacio_en(?X, ?Lugar) is nondet.
%
%   X nació en Lugar en forma estricta: quien nació en Pensilvania nació
%   en los Estados Unidos.
nacio_en(X, eeuu) :-
    nacio_en(X, pensilvania).

nacio_en(X, pensilvania) :~ habla_pensilvania(X).
neg nacio_en(X, eeuu) :~ habla_dialecto_aleman(X).

% Ejercicio 3 ----------------------------------------------------------

% estudiante(X): X es estudiante universitario.
estudiante(ines).

% empleado(X): X tiene un empleo.
empleado(ines).

adulto(X) :~ estudiante(X).
empleado(X) :~ adulto(X).
se_mantiene(X) :~ empleado(X).
neg se_mantiene(X) :~ estudiante(X).

% Ejercicio 6 ----------------------------------------------------------

% neg arranca(A): se observó que el automóvil A no arranca.
neg arranca(auto2).
neg arranca(auto3).

% enciende_luces(A): se observó que las luces del automóvil A encienden.
enciende_luces(auto3).

%!  arranca(?A) is nondet.
%
%   El automóvil A arranca si la batería, el motor de arranque y el
%   combustible están bien.
arranca(A) :-
    bien(A, bateria),
    bien(A, arranque),
    bien(A, combustible).

%!  bien(?A, ?Pieza) is nondet.
%
%   La Pieza del automóvil A está bien en forma estricta: la batería, si
%   las luces encienden.
bien(A, bateria) :-
    enciende_luces(A).

bien(_Auto, _Pieza) :~ true.

%!  sospechosas(+Auto, -Piezas:list) is det.
%
%   Piezas son las piezas cuyas presunciones sostienen la regla de
%   arranca(Auto), que una observación derrotó; la lista está vacía si
%   ninguna regla de arranca(Auto) está derrotada.
sospechosas(Auto, Piezas) :-
    por_que_no([especificidad], arranca(Auto), Motivos),
    findall(Pieza,
            ( member(derrotada((_ :- Cuerpo), _), Motivos),
              literal(bien(Auto, Pieza), Cuerpo),
              once(derivacion([especificidad], bien(Auto, Pieza), Arbol)),
              supuestos(Arbol, [_|_]) ),
            Piezas).

%!  literal(?Literal, +Conjuncion) is nondet.
%
%   Literal es uno de los literales de Conjuncion.
literal(Literal, (A, B)) :-
    !,
    (   literal(Literal, A)
    ;   literal(Literal, B)
    ).
literal(Literal, Literal).

% Ejercicio 7 ----------------------------------------------------------

%!  escribir_derivacion(+Arbol) is det.
%
%   Escribe Arbol, un árbol de derivacion/3, con una línea por nodo.
escribir_derivacion(Arbol) :-
    escribir_derivacion(Arbol, 0).

%!  escribir_derivacion(+Arbol, +Sangria:integer) is det.
%
%   Escribe Arbol con Sangria espacios antes de su raíz.
escribir_derivacion(predefinido(Meta), S) :-
    format("~t~*|~q, predefinido~n", [S, Meta]).
escribir_derivacion(estricta(Meta), S) :-
    format("~t~*|~q, en forma estricta~n", [S, Meta]).
escribir_derivacion(regla(Regla, Arboles), S) :-
    partes(Regla, Cabeza, _),
    format("~t~*|~q, por ~q~n", [S, Cabeza, Regla]),
    S1 is S + 2,
    forall(member(A, Arboles), escribir_derivacion(A, S1)).

% Ejercicio 9 ----------------------------------------------------------

% murcielago(X): X es un murciélago.
murcielago(rufo).
murcielago(dracula).

% muerto(X): X está muerto.
muerto(dracula).

:- table vuela_t/1, no_vuela_t/1.

%!  vuela_t(?X) is nondet.
%
%   X vuela: es un murciélago del que no se prueba que no vuela.
vuela_t(X) :-
    murcielago(X),
    tnot(no_vuela_t(X)).

%!  no_vuela_t(?X) is nondet.
%
%   X no vuela: está muerto. La regla de los muertos, superior, ya no
%   tiene la excepción.
no_vuela_t(X) :-
    muerto(X).

% Ejercicio 10 ---------------------------------------------------------

% regla_f(Cabeza, Cuerpo): regla sin excepciones del intérprete de Flach.
regla_f(mamifero(X), murcielago(X)).
regla_f(murcielago(dracula), true).
regla_f(murcielago(rufo), true).
regla_f(muerto(dracula), true).

% por_defecto(Nombre, Cabeza, Cuerpo): supuesto por defecto, con nombre.
por_defecto(mamiferos_no_vuelan(X), no(vuela(X)), mamifero(X)).
por_defecto(murcielagos_vuelan(X), vuela(X), murcielago(X)).
por_defecto(muertos_no_vuelan(X), no(vuela(X)), muerto(X)).

%!  explicar_por_defecto(+Meta, -Supuestos:list) is nondet.
%
%   Supuestos son los nombres de los supuestos por defecto con los que
%   Meta se prueba sin contradecir las reglas.
explicar_por_defecto(Meta, Supuestos) :-
    explicar_f(Meta, [], Supuestos).

%!  explicar_f(+Meta, +S0:list, -S:list) is nondet.
%
%   Meta se prueba con las reglas y con supuestos por defecto; S son los
%   supuestos de S0 más los que la prueba agrega.
explicar_f(true, S, S).
explicar_f((A, B), S0, S) :-
    explicar_f(A, S0, S1),
    explicar_f(B, S1, S).
explicar_f(Meta, S, S) :-
    Meta \= true,
    Meta \= (_, _),
    probar_f(Meta).
explicar_f(Meta, S0, [Nombre|S]) :-
    por_defecto(Nombre, Meta, Cuerpo),
    explicar_f(Cuerpo, S0, S),
    \+ contradice(Meta).

%!  probar_f(+Meta) is nondet.
%
%   Meta se prueba solo con las reglas.
probar_f(true).
probar_f(Meta) :-
    Meta \= true,
    regla_f(Meta, Cuerpo),
    probar_f(Cuerpo).

%!  contradice(+Meta) is semidet.
%
%   Las reglas prueban lo contrario de Meta.
contradice(no(A)) :-
    !,
    probar_f(A).
contradice(A) :-
    probar_f(no(A)).
