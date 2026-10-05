:- encoding(utf8).

% Capítulo 58 - Versión 4: un estado por punto, unido con lattice.
%
% El análisis de signos.pl sigue cada combinación de signos por separado.
% Esta versión guarda un solo estado abstracto en cada punto del programa:
% donde dos caminos se juntan, al final de un si, sus estados se unen. El
% dominio es un parámetro D del intérprete, y cada dominio define las
% operaciones dom_*/N, declaradas multifile. Aquí se define el de signos
% con top, el valor que representa cualquier entero.
%
% Un estado es estado(D, Entorno), o nada si el punto no se alcanza. El
% estado de la entrada de un mientras es un punto fijo: cabeza/3, tabulada
% con el modo lattice(ensanchar_estados/3), guarda una sola respuesta por
% bucle y estado inicial, y la reemplaza por la unión cada vez que una
% vuelta produce un estado nuevo, hasta que ninguna vuelta lo cambia.
%
% El intérprete es una gramática, como el del capítulo 45, pero la lista
% no es la salida del programa: son las observaciones del análisis,
% escribe(Exp, V), division(Exp, V) si el divisor puede ser cero, nunca(C)
% si la condición C no se cumple en ningún estado y siempre(C) si se
% cumple en todos.
%
% solo-local: carga signos.pl con ensure_loaded/1.
%
%?- programa_caso(factorial, P, Es), analisis(signos, P, Es, F, Os).
%?- programa_caso(cuadrado, P, Es), analisis(signos, P, Es, F, Os).

:- ensure_loaded(signos).

:- multifile
    dom_constante/3,
    dom_rango/3,
    dom_operar/5,
    dom_cero/2,
    dom_refinar/5,
    dom_unir/4,
    dom_ensanchar/4,
    dom_contiene/3.

%!  analisis(+D, +Programa:list, +Entradas:list, -Final, -Obs:list) is det.
%
%   Final es el estado abstracto en el dominio D al terminar Programa, con
%   las variables de Entradas en sus rangos y las demás en 0, y Obs son las
%   observaciones del análisis, en el orden del programa.
analisis(D, Programa, Entradas, Final, Obs) :-
    inicial(D, Programa, Entradas, E0),
    phrase(abs_bloque(Programa, E0, Final), Obs).

%!  analisis_caso(+D, +Nombre, +Entradas:list, -Final, -Obs:list) is semidet.
%
%   Como analisis/5, sobre el caso Nombre con las Entradas dadas. Falla si
%   Nombre no es un caso.
analisis_caso(D, Nombre, Entradas, Final, Obs) :-
    programa_caso(Nombre, Programa, _),
    analisis(D, Programa, Entradas, Final, Obs).

%!  inicial(+D, +Programa:list, +Entradas:list, -E) is det.
%
%   E es el estado inicial de Programa en el dominio D.
inicial(D, Programa, Entradas, estado(D, Env)) :-
    entorno_inicial(Programa, Ceros),
    maplist(par_abstracto(D), Ceros, Env0),
    foldl(entrada_abstracta(D), Entradas, Env0, Env).

% par_abstracto(D, X-N, X-V): V es la constante N en el dominio D.
par_abstracto(D, X-N, X-V) :-
    dom_constante(D, N, V).

% entrada_abstracta(D, X-R, E0, E): E es E0 con X en el rango R.
entrada_abstracta(D, X-Rango, E0, E) :-
    dom_rango(D, Rango, V),
    fijar(X-V, E0, E).

%!  abs_bloque(+Ss:list, +E0, -E)// is det.
%
%   Ejecutar las sentencias Ss en el dominio abstracto lleva el estado E0 a
%   E; la lista son las observaciones.
abs_bloque([], E, E) -->
    [].
abs_bloque([S|Ss], E0, E) -->
    abs_en(E0, S, E1),
    abs_bloque(Ss, E1, E).

%!  abs_en(+E0, +S, -E)// is det.
%
%   Ejecutar la sentencia S lleva el estado E0 a E. Desde nada no se llega a
%   ningún estado, y no hay nada que observar.
abs_en(nada, _, nada) -->
    [].
abs_en(estado(D, Env), S, E) -->
    abs_sentencia(S, D, Env, E).

%!  abs_sentencia(+S, +D, +Env:list, -E)// is det.
%
%   Ejecutar la sentencia S en el entorno abstracto Env del dominio D lleva
%   al estado E.
abs_sentencia(asignar(X, Exp), D, Env0, estado(D, Env)) -->
    valor_abs(Exp, D, Env0, V),
    { actualizar(X, V, Env0, Env) }.
abs_sentencia(escribir(Exp), D, Env, estado(D, Env)) -->
    valor_abs(Exp, D, Env, V),
    [escribe(Exp, V)].
abs_sentencia(si(C, Si, No), D, Env, E) -->
    partir(C, estado(D, Env), ESi, ENo),
    abs_bloque(Si, ESi, E1),
    abs_bloque(No, ENo, E2),
    { unir_estados(E1, E2, E) }.
abs_sentencia(mientras(C, Cuerpo), D, Env, Fuera) -->
    { cabeza(mientras(C, Cuerpo), estado(D, Env), I) },
    partir(C, I, Dentro, Fuera),
    abs_bloque(Cuerpo, Dentro, _).

:- table cabeza(_, _, lattice(ensanchar_estados/3)).

%!  cabeza(+Bucle, +E0, -I) is det.
%
%   I es el estado en la condición del mientras Bucle, al que se llega con
%   E0: el menor punto fijo de las vueltas, unido con ensanchar_estados/3.
%   I debe llegar libre.
cabeza(_, E0, E0).
cabeza(mientras(C, Cuerpo), E0, I) :-
    cabeza(mientras(C, Cuerpo), E0, I0),
    phrase(( partir(C, I0, Dentro, _),
             abs_bloque(Cuerpo, Dentro, I) ),
           _).

%!  partir(+C, +E, -Si, -No)// is det.
%
%   Si es el estado E restringido a los valores que cumplen la condición C,
%   y No a los que no la cumplen; nada si no queda ninguno. Observa las
%   divisiones de C, nunca(C) si Si es nada y siempre(C) si No es nada.
partir(rel(_, _, _), nada, nada, nada) -->
    [].
partir(rel(Op, A, B), estado(D, Env), Si, No) -->
    valor_abs(A, D, Env, VA),
    valor_abs(B, D, Env, VB),
    { contraria(Op, NoOp),
      restringir(Op, A, VA, B, VB, D, Env, Si),
      restringir(NoOp, A, VA, B, VB, D, Env, No) },
    vacia(Si, nunca(rel(Op, A, B))),
    vacia(No, siempre(rel(Op, A, B))).

%!  vacia(+E, +Obs)// is det.
%
%   Observa Obs si el estado E es nada.
vacia(nada, Obs) -->
    [Obs].
vacia(estado(_, _), _) -->
    [].

%!  restringir(+Op, +A, +VA, +B, +VB, +D, +Env:list, -E) is det.
%
%   E es el entorno Env, con los valores VA de A y VB de B, restringido a
%   los que cumplen A Op B, o nada si no queda ninguno.
restringir(Op, A, VA, B, VB, D, Env, E) :-
    espejo(Op, OpB),
    (   restringir_lado(A, Op, VB, D, Env, Env1),
        restringir_lado(B, OpB, VA, D, Env1, Env2)
    ->  E = estado(D, Env2)
    ;   E = nada
    ).

%!  restringir_lado(+Exp, +Op, +VO, +D, +Env0:list, -Env:list) is semidet.
%
%   Env es Env0 con los valores de Exp restringidos a los que cumplen
%   Exp Op Y para algún Y de VO. Solo una variable cambia de valor; una
%   expresión compuesta solo se comprueba. Falla si ningún valor cumple.
restringir_lado(id(X), Op, VO, D, Env0, Env) :-
    valor(X, Env0, VX),
    dom_refinar(D, Op, VX, VO, VX1),
    actualizar(X, VX1, Env0, Env).
restringir_lado(num(N), Op, VO, D, Env, Env) :-
    dom_constante(D, N, V),
    dom_refinar(D, Op, V, VO, _).
restringir_lado(bin(Op1, A, B), Op, VO, D, Env, Env) :-
    phrase(valor_abs(bin(Op1, A, B), D, Env, V), _),
    dom_refinar(D, Op, V, VO, _).

% espejo(Op, OpB): A Op B equivale a B OpB A.
espejo(=, =).
espejo(<>, <>).
espejo(<, >).
espejo(>, <).
espejo(<=, >=).
espejo(>=, <=).

%!  valor_abs(+Exp, +D, +Env:list, -V)// is det.
%
%   V es el valor abstracto de Exp en el entorno Env del dominio D. Observa
%   division(Exp, V) en cada división cuyo divisor V puede ser cero.
valor_abs(num(N), D, _, V) -->
    { dom_constante(D, N, V) }.
valor_abs(id(X), _, Env, V) -->
    { valor(X, Env, V) }.
valor_abs(bin(Op, A, B), D, Env, V) -->
    valor_abs(A, D, Env, VA),
    valor_abs(B, D, Env, VB),
    alarma(Op, bin(Op, A, B), D, VB),
    { dom_operar(D, Op, VA, VB, V) }.

%!  alarma(+Op, +Exp, +D, +VB)// is det.
%
%   Observa division(Exp, VB) si Op es la división y el divisor VB puede
%   ser cero.
alarma(Op, Exp, D, VB) -->
    (   { Op == (/),
          dom_cero(D, VB) }
    ->  [division(Exp, VB)]
    ;   []
    ).

%!  unir_estados(+E1, +E2, -E) is det.
%
%   E es la unión de los estados E1 y E2: variable por variable, la unión de
%   sus valores. nada es el neutro.
unir_estados(nada, E, E).
unir_estados(estado(D, A), E2, E) :-
    unir_con(E2, estado(D, A), E).

% unir_con(E2, E1, E): E es la unión de E1, que no es nada, con E2.
unir_con(nada, E, E).
unir_con(estado(D, B), estado(D, A), estado(D, C)) :-
    maplist(unir_par(D), A, B, C).

% unir_par(D, X-A, X-B, X-C): C es la unión de A y B en el dominio D.
unir_par(D, X-A, X-B, X-C) :-
    dom_unir(D, A, B, C).

%!  ensanchar_estados(+Viejo, +Nuevo, -E) is det.
%
%   E es la respuesta que guarda la tabla de cabeza/3 cuando llega Nuevo y
%   tenía Viejo: variable por variable, dom_ensanchar/4, que en un dominio
%   finito es la unión.
ensanchar_estados(nada, E, E).
ensanchar_estados(estado(D, A), E2, E) :-
    ensanchar_con(E2, estado(D, A), E).

% ensanchar_con(E2, E1, E): como unir_con/3, con dom_ensanchar/4.
ensanchar_con(nada, E, E).
ensanchar_con(estado(D, B), estado(D, A), estado(D, C)) :-
    maplist(ensanchar_par(D), A, B, C).

% ensanchar_par(D, X-A, X-B, X-C): C es A ensanchado con B en D.
ensanchar_par(D, X-A, X-B, X-C) :-
    dom_ensanchar(D, A, B, C).

%!  cubre(+Final, +Obs:list, +Corrida) is semidet.
%
%   El resultado abstracto Final, con sus observaciones Obs, cubre la
%   Corrida concreta de muestra/2: si terminó, cada valor final está en el
%   valor abstracto de su variable; si dividió por cero, hay una
%   observación division/2.
cubre(estado(D, Env), _, corrida(_, fin(_, Concreto))) :-
    forall(member(X-N, Concreto),
           ( valor(X, Env, V),
             dom_contiene(D, V, N) )).
cubre(_, Obs, corrida(_, error(division_por_cero))) :-
    memberchk(division(_, _), Obs).

% El dominio de los signos con top: un valor es neg, cero, pos o top. Cada
% operación dom_*/N documenta la interfaz que implementa cada dominio.

%!  dom_constante(+D, +N:integer, -V) is det.
%
%   V es el valor abstracto del entero N en el dominio D.
dom_constante(signos, N, S) :-
    signo_de(N, S).

%!  dom_rango(+D, +Rango, -V) is det.
%
%   V es el menor valor abstracto de D que representa todos los enteros de
%   Rango, entre(Min, Max).
dom_rango(signos, Rango, V) :-
    findall(S, signo_en(Rango, S), Ss),
    alfa(Ss, V).

%!  dom_operar(+D, +Op, +A, +B, -V) is det.
%
%   V representa todos los resultados de la operación Op de Mini entre un
%   valor representado por A y uno representado por B, en el dominio D.
dom_operar(signos, Op, A, B, V) :-
    findall(S, ( gama(A, SA),
                 gama(B, SB),
                 op_signos(Op, SA, SB, S),
                 signo(S) ),
            Ss),
    alfa(Ss, V).

%!  dom_cero(+D, +V) is semidet.
%
%   El valor abstracto V del dominio D puede representar el cero.
dom_cero(signos, cero).
dom_cero(signos, top).

%!  dom_refinar(+D, +Op, +A, +B, -V) is semidet.
%
%   V representa los valores de A que cumplen la comparación Op con algún
%   valor de B, en el dominio D. Falla si ninguno la cumple.
dom_refinar(signos, Op, A, B, V) :-
    findall(SA, ( gama(A, SA),
                  gama(B, SB),
                  posible(Op, SA, SB) ),
            Ss),
    Ss \== [],
    alfa(Ss, V).

%!  dom_unir(+D, +A, +B, -V) is det.
%
%   V es la unión de A y B en el dominio D: el menor valor que representa
%   lo que representan los dos.
dom_unir(signos, A, B, V) :-
    (   A == B
    ->  V = A
    ;   V = top
    ).

%!  dom_ensanchar(+D, +Viejo, +Nuevo, -V) is det.
%
%   V representa lo que representan Viejo y Nuevo, y una sucesión de
%   ensanchamientos se estabiliza en una cantidad finita de pasos. En un
%   dominio finito, la unión.
dom_ensanchar(signos, A, B, V) :-
    dom_unir(signos, A, B, V).

%!  dom_contiene(+D, +V, +N:integer) is semidet.
%
%   El valor abstracto V del dominio D representa el entero N.
dom_contiene(signos, top, _).
dom_contiene(signos, S, N) :-
    signo(S),
    signo_de(N, S).

%!  gama(+V, -S) is nondet.
%
%   S es un signo que el valor abstracto V representa: top representa los
%   tres.
gama(top, S) :-
    signo(S).
gama(S, S) :-
    signo(S).

%!  alfa(+Ss:list, -V) is det.
%
%   V es el valor abstracto que representa los signos de Ss: el signo, si
%   hay uno solo, y top si hay varios. Sin ninguno, solo una división por
%   cero, también top: allí la ejecución se detiene.
alfa(Ss0, V) :-
    sort(Ss0, Ss),
    (   Ss = [S]
    ->  V = S
    ;   V = top
    ).

%!  ramas(+K:integer, -Programa:list, -Entradas:list) is det.
%
%   Programa suma a s cada una de K entradas, x1, x2..., que sea positiva:
%   K si sin sino seguidos. Cada entrada puede tener cualquier signo.
ramas(K, Programa, Entradas) :-
    numlist(1, K, Is),
    maplist(rama, Is, Ss, Entradas),
    Programa = [asignar(s, num(0))|Ss].

% rama(I, S, E): S suma xI a s si es positiva, y E la declara entrada.
rama(I, si(rel(>, id(X), num(0)), [asignar(s, bin(+, id(s), id(X)))], []),
     X-entre(inf, sup)) :-
    atom_concat(x, I, X).
