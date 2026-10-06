:- encoding(utf8).

% Las cifras medidas que el capítulo imprime. Las inferencias cambian de
% una versión de SWI-Prolog a otra: se comparan, a propósito, con una
% banda del 10 % alrededor de la cifra impresa (en_banda/2).

:- use_module(preguntas, [ejemplo/2]).

:- begin_tests(costos).

% Sección 87.4: una pregunta, con las tablas vacías y llenas.
test(una_pregunta) :-
    ejemplo(4, Texto),
    dos_veces([Texto], Primera, Segunda),
    en_banda(Primera, 279371),
    en_banda(Segunda, 512).

% Sección 87.4: las dieciséis preguntas del capítulo.
test(dieciseis) :-
    findall(T, ejemplo(_, T), Textos),
    dos_veces(Textos, Primera, Segunda),
    en_banda(Primera, 391405),
    en_banda(Segunda, 22777).

test(banda, [fail]) :-
    en_banda(111, 100).

:- end_tests(costos).
