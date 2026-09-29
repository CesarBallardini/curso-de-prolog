:- encoding(utf8).

% Capítulo 74 - Versión 5: descubrir macros.
%
% Un conmutador A B A' B' deshace A y B salvo en las piezas que los dos
% mueven: si comparten pocas piezas, el conmutador mueve pocas. descubrir/3
% genera los conmutadores de una secuencia A de hasta Largo cuartos de
% vuelta con un cuarto de vuelta B, compila cada uno y lee su efecto con
% efecto/2 de macros.pl, sin aplicarlo a ningún cubo. Se quedan los que
% mueven exactamente tres piezas, todas esquinas de la cara de arriba: las
% secuencias que la última etapa del resolvedor necesita para colocar las
% esquinas sin desarmar el resto.
%
% solo-local: carga macros.pl.
%
%?- descubrir(2, Encontradas, Probadas).
%?- aggregate_all(count, descubierta(3, _), N).
%?- efecto_de("U' L' U R U' L U R'", Piezas).

:- ensure_loaded(macros).

%!  descubrir(+Largo:integer, -Encontradas:list, -Probadas:integer) is det.
%
%   Encontradas son los conmutadores A B A' B', con A de 1 a Largo
%   cuartos de vuelta y B un cuarto de vuelta, que mueven tres esquinas de
%   la cara de arriba y nada más; cada uno como una lista de giros, sin
%   repetidos. Probadas es la cantidad de conmutadores examinados.
descubrir(Largo, Encontradas, Probadas) :-
    findall(S-Sirve,
            ( between(1, Largo, N),
              length(A, N),
              reducida(A),
              cuarto_de_vuelta(B),
              conmutador(A, [B], S),
              compilar(S, Macro),
              efecto(Macro, Piezas),
              (   tres_esquinas_de_arriba(Piezas)
              ->  Sirve = si
              ;   Sirve = no
              ) ),
            Todas),
    length(Todas, Probadas),
    findall(S, member(S-si, Todas), Encontradas0),
    sort(Encontradas0, Encontradas).

%!  descubierta(+Largo:integer, -Texto:string) is nondet.
%
%   Texto es, en la notación, uno de los conmutadores que encuentra
%   descubrir/3 con Largo.
descubierta(Largo, Texto) :-
    descubrir(Largo, Encontradas, _),
    member(S, Encontradas),
    escribir_notacion(S, Texto).

%!  reducida(?Movimientos:list) is nondet.
%
%   Movimientos es una lista de cuartos de vuelta sin dos giros seguidos
%   de la misma cara: esos se escriben con menos giros.
reducida([]).
reducida([M|Ms]) :-
    cuarto_de_vuelta(M),
    reducida_desde(M, Ms).

%!  reducida_desde(+Anterior, ?Movimientos:list) is nondet.
%
%   Movimientos es una lista reducida cuyo primer giro no es de la cara
%   de Anterior.
reducida_desde(_, []).
reducida_desde(Anterior, [M|Ms]) :-
    cuarto_de_vuelta(M),
    cara_de(Anterior, C0),
    cara_de(M, C),
    C \== C0,
    reducida_desde(M, Ms).

%!  tres_esquinas_de_arriba(+Piezas:list(atom)) is semidet.
%
%   Piezas son tres esquinas de la cara de arriba.
tres_esquinas_de_arriba(Piezas) :-
    length(Piezas, 3),
    forall(member(P, Piezas),
           ( atom_length(P, 3),
             sub_atom(P, 0, 1, _, 'U') )).
