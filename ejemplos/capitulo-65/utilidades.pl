:- encoding(utf8).

% Capítulo 65 - Ampliación: consultas exhaustivas y contradicciones.
%
% d-Prolog trae utilidades para examinar una base: una consulta que da la
% respuesta sobre cada individuo del que la base dice algo, y una búsqueda
% de contradicciones, pares de literales complementarios que se derivan
% los dos en forma estricta. diccionario/1 reúne los predicados que
% aparecen en la cabeza de una regla rebatible o de un refutador.
% candidato/2 da los literales sin variables sobre los que hay evidencia
% inicial: un hecho, o una regla de cualquier clase cuyo cuerpo se deriva,
% con su cabeza o con su complemento. La base de ejemplo es el diamante de
% Nixon, cuáquero y republicano, y un animal que es a la vez murciélago y
% ave, con reglas estrictas que se contradicen.
%
% solo-local: carga el módulo rebatible, y SWISH no admite módulos propios.
%
%?- respuestas([especificidad], pacifista(X), Ps).
%?- contradicciones(Cs).

:- use_module(rebatible).

% cuaquero(X): X es cuáquero. republicano(X): X es republicano.
cuaquero(nixon).
cuaquero(penn).
republicano(nixon).
republicano(reagan).

% Los cuáqueros normalmente son pacifistas; los republicanos normalmente
% no.
pacifista(X) :~ cuaquero(X).
neg pacifista(X) :~ republicano(X).

% murcielago(X): X es un murciélago. ave(X): X es un ave.
murcielago(bruno).
ave(bruno).

%!  mamifero(?X) is nondet.
%
%   X es un mamífero: todo murciélago lo es.
mamifero(X) :-
    murcielago(X).

% Ningún ave es un mamífero.
neg mamifero(X) :-
    ave(X).

%!  diccionario(-Predicados:list) is det.
%
%   Predicados son los Nombre/Aridad de las cabezas, sin la negación, de
%   las reglas rebatibles y de los refutadores de la base, ordenados.
diccionario(Predicados) :-
    findall(N/A,
            ( ( user:(H :~ _) ; user:(H :^ _) ),
              complemento_positivo(H, P),
              functor(P, N, A) ),
            Ps),
    sort(Ps, Predicados).

%!  complemento_positivo(+Literal, -Atomo) is det.
%
%   Atomo es Literal sin la negación fuerte.
complemento_positivo(Literal, Atomo) :-
    (   Literal = (neg Atomo)
    ->  true
    ;   Atomo = Literal
    ).

%!  candidato(+Criterio:list, +Literal) is nondet.
%
%   Hay evidencia inicial sobre Literal, que puede llegar con variables y
%   queda sin ellas: Literal o su complemento es un hecho, o la cabeza de
%   una regla, rebatible o estricta, o de un refutador, cuyo cuerpo se
%   deriva con Criterio.
candidato(Criterio, Literal) :-
    (   H = Literal
    ;   complemento(Literal, H)
    ),
    evidencia(Criterio, H),
    ground(Literal).

%!  evidencia(+Criterio:list, ?Cabeza) is nondet.
%
%   Una regla de cabeza Cabeza tiene el cuerpo derivable, o Cabeza se
%   deriva en forma estricta.
evidencia(_, H) :-
    estricto(H).
evidencia(Cr, H) :-
    (   user:(H :~ B)
    ;   user:(H :^ B)
    ),
    derivable(Cr, B).

%!  respuestas(+Criterio:list, +Plantilla, -Pares:list) is det.
%
%   Pares tiene un par Literal-Respuesta por cada instancia sin variables
%   de Plantilla sobre la que hay evidencia inicial, con la respuesta de
%   respuesta/3, en orden alfabético.
respuestas(Criterio, Plantilla, Pares) :-
    findall(Plantilla, candidato(Criterio, Plantilla), Ls0),
    sort(Ls0, Ls),
    findall(L-R, ( member(L, Ls), respuesta(Criterio, L, R) ), Pares).

%!  contradicciones(-Literales:list) is det.
%
%   Literales son los literales positivos de los predicados del
%   diccionario o de una regla estricta negativa tales que el literal y su
%   complemento se derivan los dos en forma estricta, en orden alfabético.
contradicciones(Literales) :-
    diccionario(D0),
    findall(N/A,
            ( clause(user:(neg P), _),
              functor(P, N, A) ),
            D1),
    append(D0, D1, D2),
    sort(D2, D),
    findall(L,
            ( member(N/A, D),
              functor(L, N, A),
              estricto(L),
              estricto(neg L) ),
            Ls),
    sort(Ls, Literales).
