:- encoding(utf8).

% Capítulo 62 - Versión 2: la forma clausal proposicional.
%
% Lleva una fórmula a forma normal negada (sin → ni ↔, con la negación
% solo delante de las fórmulas atómicas) y después a forma normal
% conjuntiva, escrita como una lista de cláusulas. Una cláusula es una
% lista ordenada de literales, +A o -A, sin repeticiones; las cláusulas
% que contienen un literal y su opuesto son verdaderas siempre y no se
% conservan. La forma normal negada ya trata los cuantificadores; la
% conjuntiva, todavía no.
%
% solo-local: carga el módulo lector, y SWISH no admite módulos propios.
%
%?- clausulas_texto("¬((p → q) ∧ p → q)", Cs).
%?- leer_formula("¬(p ↔ q)", F), fnn(F, G).

:- module(clausal,
          [ fnn/2,
            fnc/2,
            clausulas/2,
            clausulas_texto/2,
            tautologica/1
          ]).

:- use_module(library(lists)).
:- use_module(library(ordsets)).
:- use_module(library(error)).
:- reexport(lector).

%!  clausulas_texto(+Texto, -Clausulas:list) is det.
%
%   Clausulas es la forma clausal de la fórmula que Texto escribe.
clausulas_texto(Texto, Clausulas) :-
    leer_formula(Texto, F),
    clausulas(F, Clausulas).

%!  clausulas(+F, -Clausulas:list) is det.
%
%   Clausulas es la forma clausal de F, una fórmula sin cuantificadores:
%   una lista ordenada de cláusulas, ninguna tautológica.
clausulas(F, Clausulas) :-
    fnn(F, G),
    fnc(G, Cs),
    sort(Cs, Clausulas).

%!  fnn(+F, -G) is det.
%
%   G es la forma normal negada de F: equivalente a F, sin → ni ↔, y con
%   la negación solo delante de las fórmulas atómicas. Un cuantificador
%   que queda bajo una negación cambia por su dual.
fnn(at(A), at(A)).
fnn(no(F), G) :-
    fnn_no(F, G).
fnn(y(A, B), y(FA, FB)) :-
    fnn(A, FA),
    fnn(B, FB).
fnn(o(A, B), o(FA, FB)) :-
    fnn(A, FA),
    fnn(B, FB).
fnn(si(A, B), o(NA, FB)) :-
    fnn_no(A, NA),
    fnn(B, FB).
fnn(sii(A, B), y(o(NA, FB), o(FA, NB))) :-
    fnn(A, FA),
    fnn_no(A, NA),
    fnn(B, FB),
    fnn_no(B, NB).
fnn(todo(X, F), todo(X, G)) :-
    fnn(F, G).
fnn(existe(X, F), existe(X, G)) :-
    fnn(F, G).

%!  fnn_no(+F, -G) is det.
%
%   G es la forma normal negada de ¬F.
fnn_no(at(A), no(at(A))).
fnn_no(no(F), G) :-
    fnn(F, G).
fnn_no(y(A, B), o(NA, NB)) :-
    fnn_no(A, NA),
    fnn_no(B, NB).
fnn_no(o(A, B), y(NA, NB)) :-
    fnn_no(A, NA),
    fnn_no(B, NB).
fnn_no(si(A, B), y(FA, NB)) :-
    fnn(A, FA),
    fnn_no(B, NB).
fnn_no(sii(A, B), o(y(FA, NB), y(NA, FB))) :-
    fnn(A, FA),
    fnn_no(A, NA),
    fnn(B, FB),
    fnn_no(B, NB).
fnn_no(todo(X, F), existe(X, G)) :-
    fnn_no(F, G).
fnn_no(existe(X, F), todo(X, G)) :-
    fnn_no(F, G).

%!  fnc(+G, -Clausulas:list) is det.
%
%   Clausulas es la lista de cláusulas de G, una fórmula en forma normal
%   negada y sin cuantificadores. La disyunción se distribuye sobre la
%   conjunción: cada cláusula de A ∨ B une una cláusula de A con una de B.
%   Una fórmula con cuantificadores produce un error de tipo.
fnc(at(A), [[+A]]).
fnc(no(at(A)), [[-A]]).
fnc(y(A, B), Cs) :-
    fnc(A, CA),
    fnc(B, CB),
    append(CA, CB, Cs).
fnc(o(A, B), Cs) :-
    fnc(A, CA),
    fnc(B, CB),
    findall(C,
            ( member(X, CA),
              member(Y, CB),
              ord_union(X, Y, C),
              \+ tautologica(C)
            ),
            Cs).
fnc(todo(X, F), _) :-
    type_error(formula_sin_cuantificadores, todo(X, F)).
fnc(existe(X, F), _) :-
    type_error(formula_sin_cuantificadores, existe(X, F)).

%!  tautologica(+C:list) is semidet.
%
%   La cláusula C contiene un literal y su opuesto.
tautologica(C) :-
    member(+A, C),
    member(-B, C),
    A == B,
    !.
