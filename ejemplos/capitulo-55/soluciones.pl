:- encoding(utf8).

% Capítulo 55 - Soluciones de los ejercicios 3, 4 y 5: reglas nuevas para
% ELIZA, el pronombre después de una preposición y los verbos regulares
% declarados por su infinitivo.
%
% solo-local: carga archivos de este capítulo y del 44, y SWISH no admite
% módulos propios.
%
%?- reflejar_prep([para, mi, es, dificil], Q).

:- module(soluciones,
          [ reflejar_prep/2,
            persona_prep//1,
            conjugada_inf/2,
            primera_respuesta/2
          ]).

:- use_module(eliza).
:- use_module(persona).

% Ejercicio 3: dos reglas más para ELIZA, agregadas al predicado multifile
% regla/4 del módulo eliza.
eliza:regla(no_puedo, 3, [_, no, puedo, X],
            [ ["¿Qué te impide ", X, "?"],
              ["¿Lo has intentado de verdad?"]
            ]).
eliza:regla(siempre, 4, [_, siempre, _],
            [ ["¿Puedes pensar en un ejemplo concreto?"],
              ["¿Siempre? ¿No hay ninguna excepción?"]
            ]).

%!  primera_respuesta(+Frase:string, -Respuesta:string) is det.
%
%   Respuesta es la respuesta de ELIZA a Frase, desde el estado inicial.
primera_respuesta(Frase, Respuesta) :-
    estado_inicial(E0),
    responder(Frase, E0, _, Respuesta).

% Ejercicio 4.

% preposicion(P): después de P, mi es el pronombre mí.
preposicion(para).
preposicion(por).
preposicion(sin).
preposicion(a).

%!  persona_prep(-Cambiadas:list)// is det.
%
%   Como persona//1, del módulo persona, con una regla más: después de una
%   preposición, mí pasa a ti y ti a mí.
persona_prep([P, Q|Qs]) -->
    [P, Pronombre],
    { preposicion(P),
      pronombre_tras_preposicion(Pronombre, Q) },
    !,
    persona_prep(Qs).
persona_prep(["yo", Q|Qs]) -->
    [tu, P],
    { persona:tras_tu(P) },
    !,
    { persona:palabra(P, Q) },
    persona_prep(Qs).
persona_prep([Q, N|Qs]) -->
    [D, N],
    { persona:determinante(D) },
    !,
    { persona:palabra(D, Q) },
    persona_prep(Qs).
persona_prep([Q|Qs]) -->
    [P],
    !,
    { persona:palabra(P, Q) },
    persona_prep(Qs).
persona_prep([]) -->
    [].

% pronombre_tras_preposicion(P, Q): el pronombre P, sin tildes, pasa a Q.
pronombre_tras_preposicion(mi, "ti").
pronombre_tras_preposicion(ti, "mí").

%!  reflejar_prep(+Palabras:list(atom), -Cambiadas:list) is det.
%
%   Cambiadas son las Palabras con la persona cambiada, con la regla de las
%   preposiciones.
reflejar_prep(Palabras, Cambiadas) :-
    phrase(persona_prep(Cambiadas), Palabras).

% Ejercicio 5.

% verbo_regular(I): I es el infinitivo de un verbo regular.
verbo_regular(caminar).
verbo_regular(comer).
verbo_regular(escribir).

%!  conjugada_inf(?Primera:atom, ?Segunda:atom) is nondet.
%
%   Primera y Segunda son la primera y la segunda persona del singular del
%   presente de un verbo de verbo_regular/1.
conjugada_inf(Primera, Segunda) :-
    verbo_regular(Infinitivo),
    atom_concat(Raiz, Clase, Infinitivo),
    terminacion(Clase, Terminacion),
    atom_concat(Raiz, o, Primera),
    atom_concat(Raiz, Terminacion, Segunda).

% terminacion(Clase, T): la segunda persona de un verbo de la clase Clase
% termina en T.
terminacion(ar, as).
terminacion(er, es).
terminacion(ir, es).
