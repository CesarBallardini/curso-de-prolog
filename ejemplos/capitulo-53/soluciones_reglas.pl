:- encoding(utf8).

% Capítulo 53 - Soluciones de los ejercicios 10 y 11: reglas nuevas en
% la versión 4.
%
% Una regla nueva es una cláusula más de regla/2, con los pares que usa:
% ningún otro predicado cambia. La regla ye escribe y la i que queda
% entre vocales (le+ió, le+ieron); la regla dieresis escribe ü la u que
% suena entre g y e, i (averigu+é). La versión 2 no tiene esas reglas:
% escribe «leió» y no genera «averigüé».
%
% solo-local: carga módulos.
%
%?- forma(P, verbo("leer", preterito, 3, singular)).
%?- forma(P, verbo("averiguar", preterito, 1, singular)).

:- use_module(lexico).
:- ensure_loaded(paralelo).

lexico:verbo("leer", regular).
lexico:verbo("creer", regular).
lexico:verbo("averiguar", regular).

dos_niveles:par([i]:[y]).
dos_niveles:par([u]:['ü']).

% Ejercicio 10: i se escribe y si y solo si está entre una vocal, con un
% límite, y otra vocal.
dos_niveles:regla(ye,
                  [ [no(limite), par([i]:[y])]-medio,
                    [par([i]:[y])]-inicio,
                    [no(vocal), limite, par([i]:[y])]-medio,
                    [limite, par([i]:[y])]-inicio,
                    [par([i]:[y]), no(vocal)]-medio,
                    [par([i]:[y])]-final,
                    [vocal, limite, par([i]:[i]), vocal]-medio
                  ]).

% Ejercicio 11: u se escribe ü si y solo si sigue a g y precede, quizá
% después de un límite, a una e o una i. La regla g ya prohíbe la u
% escrita u en ese lugar.
dos_niveles:regla(dieresis,
                  [ [no(par([g]:[g])), par([u]:['ü'])]-medio,
                    [par([u]:['ü'])]-inicio
                  | Ps ]) :-
    dos_niveles:solo_ante_frontal(par([u]:['ü']), Ps).
