:- encoding(utf8).

% Capítulo 53 - Soluciones de los ejercicios 2, 3, 5, 6, 8 y 9.
%
% Carga la versión 4 y agrega palabras al léxico sin modificarlo: el
% léxico declara multifile sus predicados, y la versión 2, sus clases de
% cambio de la raíz. La versión 2 se consulta como reglas:forma/2.
%
% solo-local: carga módulos.
%
%?- forma(P, nombre("razón", femenino, plural)).
%?- forma(P, verbo("empezar", preterito, 1, singular)).
%?- conjugacion("jugar", presente, Fs).

:- use_module(lexico).
:- ensure_loaded(paralelo).

% Ejercicio 2: palabras nuevas, sin reglas nuevas.
lexico:nombre("nariz", femenino).
lexico:nombre("razón", femenino).
lexico:nombre("origen", masculino).
lexico:adjetivo("cortés", invariable).

% Ejercicio 3: un cambio de la raíz y un cambio ortográfico juntos.
lexico:verbo("empezar", e_ie).
lexico:verbo("colgar", o_ue).

% Ejercicio 6: la u de jugar diptonga.
lexico:verbo("jugar", u_ue).
reglas:diptongo(u_ue, u, [u, e]).

%!  escribir_antes(?Subyacente:list, ?Escrita:list) is nondet.
%
%   Ejercicio 5: escribir/2 reducida a la letra k, con cada condición
%   antes de la llamada recursiva. Genera bien; en sentido inverso no
%   encuentra la forma subyacente de «tocar».
escribir_antes([], []).
escribir_antes([k|S], [q, u|E]) :-
    reglas:frontal(S),
    escribir_antes(S, E).
escribir_antes([k|S], [c|E]) :-
    \+ reglas:frontal(S),
    escribir_antes(S, E).
escribir_antes([L|S], [L|E]) :-
    \+ memberchk(L, [k, c, q]),
    escribir_antes(S, E).

%!  candidatos(+Palabra:string, -Subyacentes:list) is det.
%
%   Ejercicio 8: Subyacentes son las formas subyacentes que las reglas de
%   la versión 4 admiten para Palabra, sin el léxico.
candidatos(Palabra, Subyacentes) :-
    reglas(Rs),
    string_chars(Palabra, Letras),
    findall(S, transducir(paralelo(Rs), S, Letras), Subyacentes).

%!  conjugacion(+Lema:string, +Tiempo, -Formas:list(string)) is semidet.
%
%   Ejercicio 9: Formas son las seis formas de Lema en el Tiempo, en el
%   orden de las personas: yo, tú, él, nosotros, vosotros, ellos. Falla si
%   Lema no es un verbo del léxico.
conjugacion(Lema, Tiempo, Formas) :-
    verbo(Lema, _),
    !,
    findall(F,
            ( terminacion(a, Tiempo, Persona, Numero, _),
              once(forma(F, verbo(Lema, Tiempo, Persona, Numero))) ),
            Formas).
