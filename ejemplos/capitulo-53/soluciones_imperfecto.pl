:- encoding(utf8).

% Capítulo 53 - Solución del ejercicio 4: el pretérito imperfecto.
%
% Un tiempo nuevo es una tabla de terminaciones más; ser e ir, que no la
% siguen, se listan. Ninguna regla cambia: contaba no diptonga porque la
% terminación aba tiene dos vocales, y tenía tampoco, porque ía lleva
% tilde.
%
% solo-local: carga módulos.
%
%?- forma(P, verbo("contar", imperfecto, 1, plural)).
%?- forma("hacía", A).

:- use_module(lexico).
:- ensure_loaded(paralelo).

lexico:terminacion(Conj, imperfecto, Persona, Numero, T) :-
    imperfecto(Conj, Ts),
    persona(I, Persona, Numero),
    nth1(I, Ts, T).

lexico:irregular(Lema, imperfecto, Persona, Numero, Forma) :-
    imperfecto_irregular(Lema, Formas),
    persona(I, Persona, Numero),
    nth1(I, Formas, Forma).

% imperfecto(Conj, Ts): las terminaciones del imperfecto.
imperfecto(a, ["aba", "abas", "aba", "ábamos", "abais", "aban"]).
imperfecto(e, ["ía", "ías", "ía", "íamos", "íais", "ían"]).
imperfecto(i, ["ía", "ías", "ía", "íamos", "íais", "ían"]).

% imperfecto_irregular(Lema, Formas): las seis formas, listadas.
imperfecto_irregular("ser", ["era", "eras", "era", "éramos", "erais",
                             "eran"]).
imperfecto_irregular("ir", ["iba", "ibas", "iba", "íbamos", "ibais",
                            "iban"]).
