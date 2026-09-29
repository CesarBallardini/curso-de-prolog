:- encoding(utf8).

% Capítulo 53 - Versión 3: morfología de dos niveles con transductores.
%
% Las reglas ortográficas de la versión 2 dejan de ser pasadas en orden:
% cada una es un autómata sobre pares Subyacente:Escrita de letras, del
% módulo transductores del capítulo 51, y todas se aplican a la vez. Una
% regla se escribe como una lista de patrones prohibidos: su autómata es
% complemento(contiene(Regla)), que acepta las sucesiones de pares donde
% ningún patrón aparece; interseccion/2 las pone en paralelo en
% ortografia(Rs). Para decidir qué estados son finales, la intersección
% construye su autómata producto entero, y el producto crece con cada
% regla: con más de cuatro o cinco reglas no es practicable.
%
% El léxico es otro autómata: sus estados son los prefijos de las formas
% subyacentes, como un árbol de letras. compuesta(lexico, Reglas) solo
% propone formas subyacentes que el léxico contiene, y por eso analiza sin
% recorrer el léxico entero. La forma subyacente de cada análisis sale de
% lexica/2 de la versión 2.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- transducir(ortografia([epentesis, u]), [l, u, z, +, s], E).
%?- forma_lexica([l, u, z, +, s], A).

:- module(dos_niveles,
          [ reglas/1,
            regla/2,
            par/1,
            cumple/2,
            forma_lexica/2
          ]).

:- reexport('../capitulo-51/transductores').
:- use_module(reglas, [analisis/1, lexica/2, tilde/2, vocal/1, consonante/1]).
:- use_module(library(apply)).
:- use_module(library(lists)).

:- multifile automatas:alfabeto/2, automatas:inicial/2, automatas:final/2,
             automatas:delta/4, automatas:epsilon/3.

% Otros archivos pueden agregar reglas y pares.
:- multifile regla/2, par/1.

:- table forma_lexica/2 as subsumptive.

%!  forma_lexica(?Subyacente:list, ?Analisis) is nondet.
%
%   Subyacente es la forma subyacente, con límites, de Analisis, para
%   cada análisis del léxico. Tabulada por subsunción: una vez completa
%   la tabla de la consulta con los dos argumentos libres, las consultas
%   más particulares toman de ella sus respuestas.
forma_lexica(Subyacente, Analisis) :-
    analisis(Analisis),
    lexica(Analisis, Subyacente).

:- table continuacion/2 as subsumptive.

%!  continuacion(?Prefijo:list, ?L) is nondet.
%
%   La letra L continúa Prefijo en alguna forma subyacente del léxico.
%   Con los dos argumentos libres, sus respuestas son el árbol de letras
%   del léxico; tabulada por subsunción, como forma_lexica/2.
continuacion(Prefijo, L) :-
    forma_lexica(Forma, _),
    append(Prefijo, [L|_], Forma).

% El léxico como autómata: el estado es el prefijo leído, y cada
% transición copia una letra que lo continúa. El estado inicial completa
% las dos tablas, y así cada paso es una consulta al árbol.

automatas:inicial(lexico, []) :-
    once(continuacion(_, _)).
automatas:final(lexico, Prefijo) :-
    forma_lexica(Prefijo, _),
    !.
automatas:delta(lexico, Prefijo, [L]:[L], Prefijo1) :-
    continuacion(Prefijo, L),
    append(Prefijo, [L], Prefijo1).

% ortografia(Rs): las reglas de la lista Rs en paralelo, como la
% intersección de sus autómatas. Una transición que lleva a un estado con
% hallado se descarta: alguna regla ya encontró un patrón prohibido, y de
% ese estado no se sale; si quedara, las transiciones que no leen nada
% formarían en él ciclos sin fin.

automatas:alfabeto(ortografia(_), Pares) :-
    pares(Pares).
automatas:inicial(ortografia(Rs), Q) :-
    intersecar(Rs, T),
    inicial(T, Q).
automatas:final(ortografia(Rs), Q) :-
    intersecar(Rs, T),
    final(T, Q).
automatas:delta(ortografia(Rs), Q, P, Q1) :-
    intersecar(Rs, T),
    delta(T, Q, P, Q1),
    \+ sub_term(hallado, Q1).

%!  intersecar(+Rs:list, -T) is det.
%
%   T es la intersección de los autómatas de las reglas de Rs, que no es
%   vacía. El autómata de una regla acepta las sucesiones de pares donde
%   no aparece ninguno de sus patrones.
intersecar([R], complemento(contiene(R))).
intersecar([R1, R2|Rs], interseccion(complemento(contiene(R1)), T)) :-
    intersecar([R2|Rs], T).

%!  reglas(-Rs:list) is det.
%
%   Rs son los nombres de todas las reglas.
reglas(Rs) :-
    findall(R, regla(R, _), Rs).

% contiene(R): el autómata no determinista que acepta las sucesiones de
% pares donde aparece algún patrón de la regla R. Un patrón es una lista
% de clases de pares y dice dónde debe aparecer: en cualquier lugar
% (medio), al comienzo (inicio) o al final (final).

automatas:alfabeto(contiene(_), Pares) :-
    pares(Pares).
automatas:inicial(contiene(_), inicio).
automatas:epsilon(contiene(_), inicio, bucle).
automatas:epsilon(contiene(R), inicio, p(N, 0)) :-
    patron(R, N, _, inicio).
automatas:epsilon(contiene(R), bucle, p(N, 0)) :-
    patron(R, N, _, Donde),
    Donde \== inicio.
automatas:epsilon(contiene(R), p(N, I), hallado) :-
    patron(R, N, Clases, Donde),
    Donde \== final,
    length(Clases, I).
automatas:delta(contiene(_), Q, P, Q) :-
    memberchk(Q, [bucle, hallado]),
    par(P).
automatas:delta(contiene(R), p(N, I), P, p(N, I1)) :-
    patron(R, N, Clases, _),
    nth0(I, Clases, Clase),
    par(P),
    cumple(Clase, P),
    I1 is I + 1.
automatas:delta(contiene(R), p(N, I), P, p(N, I)) :-
    patron(R, N, Clases, _),
    nth1(I, Clases, varias(Clase)),
    par(P),
    cumple(Clase, P).
automatas:final(contiene(_), hallado).
automatas:final(contiene(R), p(N, I)) :-
    patron(R, N, Clases, final),
    length(Clases, I).

%!  patron(?R, ?N:integer, ?Clases:list, ?Donde) is nondet.
%
%   El patrón número N de la regla R es Clases, y se busca en Donde.
patron(R, N, Clases, Donde) :-
    regla(R, Patrones),
    nth1(N, Patrones, Clases-Donde).

:- table pares/1.

%!  pares(-Pares:list) is det.
%
%   Pares es la lista ordenada de los pares de letras de las reglas.
pares(Pares) :-
    findall(P, par(P), Pares0),
    sort(Pares0, Pares).

%!  par(?P) is nondet.
%
%   P es un par Subyacente:Escrita que las reglas admiten: una letra que
%   se escribe igual, una de las letras k, z, 'J' escrita de otro modo, un
%   límite borrado, una u o una e agregadas, una tilde quitada o puesta.
par([L]:[L]) :-
    string_chars("abdefghijlmnñoprstuvxyzáéíóú", Letras),
    member(L, Letras).
par([k]:[c]).
par([k]:[q]).
par([z]:[c]).
par(['J']:[g]).
par(['J']:[j]).
par([+]:[]).
par([]:[u]).
par([]:[e]).
par([V]:[T]) :-
    tilde(T, V).
par([V]:[T]) :-
    tilde(V, T).

%!  cumple(+Clase, +P) is semidet.
%
%   El par P pertenece a la Clase.
cumple(par(P), P).
cumple(frontal, _:[L]) :-
    memberchk(L, [e, i, 'é', 'í']).
cumple(limite, [+]:[]).
cumple(consonante, [L]:_) :-
    consonante(L).
cumple(vocal, _:[L]) :-
    vocal(L).
cumple(llana, [L]:_) :-
    tilde(L, _).
cumple(ene, [n]:_).
cumple(tilde_quitada, [L]:[E]) :-
    tilde(E, L).
cumple(tilde_igual, [L]:[L]) :-
    tilde(_, L).
cumple(tilde_puesta, [L]:[E]) :-
    tilde(L, E).
cumple(llana_igual, [L]:[L]) :-
    tilde(L, _).
cumple(cualquiera, _).
cumple(varias(C), P) :-
    cumple(C, P).
cumple(no(C), P) :-
    \+ cumple(C, P).
cumple(o(C1, C2), P) :-
    (   cumple(C1, P)
    ->  true
    ;   cumple(C2, P)
    ).

%!  regla(?R, -Patrones:list) is nondet.
%
%   Patrones son los patrones que la regla R prohíbe, cada uno como
%   Clases-Donde.
regla(limite, [ [limite, limite]-medio,
                [limite]-inicio,
                [limite]-final ]).
regla(k, [ [par([k]:[q]), no(par([]:[u]))]-medio,
           [par([k]:[q])]-final
         | Ps ]) :-
    no_ante_frontal(par([k]:[c]), Ps).
regla(u, [ [no(o(par([k]:[q]), par([g]:[g]))), par([]:[u])]-medio,
           [par([]:[u])]-inicio
         | Ps ]) :-
    solo_ante_frontal(par([]:[u]), Ps).
regla(g, [ [par([g]:[g]), par([u]:[u]), frontal]-medio,
           [par([g]:[g]), par([u]:[u]), limite, frontal]-medio
         | Ps ]) :-
    no_ante_frontal(par([g]:[g]), Ps).
regla(z, Ps) :-
    solo_ante_frontal(par([z]:[c]), Ps1),
    no_ante_frontal(par([z]:[z]), Ps2),
    append(Ps1, Ps2, Ps).
regla(jota, Ps) :-
    solo_ante_frontal(par(['J']:[g]), Ps1),
    no_ante_frontal(par(['J']:[j]), Ps2),
    solo_ante_frontal(par([j]:[j]), Ps3),
    append([Ps1, Ps2, Ps3], Ps).
regla(epentesis,
      [ [no(limite), par([]:[e])]-medio,
        [par([]:[e])]-inicio,
        [no(consonante), limite, par([]:[e])]-medio,
        [limite, par([]:[e])]-inicio,
        [par([]:[e]), no(par([s]:[s]))]-medio,
        [par([]:[e])]-final,
        [par([]:[e]), par([s]:[s]), cualquiera]-medio,
        [consonante, limite, par([s]:[s])]-final
      ]).
regla(quitar_tilde,
      [ [tilde_quitada, no(consonante)]-medio,
        [tilde_quitada]-final,
        [tilde_quitada, consonante, no(limite)]-medio,
        [tilde_quitada, consonante]-final,
        [tilde_quitada, consonante, limite, no(vocal)]-medio,
        [tilde_quitada, consonante, limite]-final,
        [tilde_igual, consonante, limite, vocal]-medio
      ]).
regla(poner_tilde,
      [ [llana_igual, varias(consonante), llana, ene, limite]-medio,
        [tilde_puesta, no(consonante)]-medio,
        [tilde_puesta]-final,
        [tilde_puesta, varias(consonante), no(o(consonante, llana))]-medio,
        [tilde_puesta, varias(consonante)]-final,
        [tilde_puesta, varias(consonante), llana, no(ene)]-medio,
        [tilde_puesta, varias(consonante), llana]-final,
        [tilde_puesta, varias(consonante), llana, ene, no(limite)]-medio,
        [tilde_puesta, varias(consonante), llana, ene]-final
      ]).

%!  solo_ante_frontal(+Clase, -Patrones:list) is det.
%
%   Patrones prohíben un par de la Clase que no esté seguido, quizá
%   después de un límite, por una e o una i escritas.
solo_ante_frontal(C, [ [C, no(o(limite, frontal))]-medio,
                       [C]-final,
                       [C, limite, no(frontal)]-medio,
                       [C, limite]-final ]).

%!  no_ante_frontal(+Clase, -Patrones:list) is det.
%
%   Patrones prohíben un par de la Clase seguido, quizá después de un
%   límite, por una e o una i escritas.
no_ante_frontal(C, [ [C, frontal]-medio,
                     [C, limite, frontal]-medio ]).
