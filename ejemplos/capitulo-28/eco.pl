:- encoding(utf8).

% Capítulo 28 - Solución del ejercicio 3: escribir los argumentos al revés.
%
% swipl eco.pl uno dos tres escribe tres, dos y uno, uno por línea. Sin
% argumentos, escribe un mensaje de error y termina con el código 1.
%
% solo-local: SWISH no ejecuta programas con argumentos.
%
%?- invertir([uno, dos, tres], L).

:- use_module(library(main)).

:- initialization(main, main).

%!  main(+Argumentos:list) is det.
%
%   Escribe Argumentos en orden inverso y termina con el código 0; sin
%   argumentos, termina con el código 1.
main(Argumentos) :-
    (   Argumentos == []
    ->  print_message(error, eco(sin_argumentos)),
        Codigo = 1
    ;   invertir(Argumentos, Inversos),
        forall(member(A, Inversos), writeln(A)),
        Codigo = 0
    ),
    halt(Codigo).

%!  invertir(+Lista:list, -Inversa:list) is det.
%
%   Inversa es Lista en orden inverso.
invertir(Lista, Inversa) :-
    reverse(Lista, Inversa).

:- multifile prolog:message//1.

%!  prolog:message(+Mensaje)// is semidet.
%
%   El texto del mensaje de error del programa.
prolog:message(eco(sin_argumentos)) -->
    [ 'Uso: swipl eco.pl argumento...' ].
