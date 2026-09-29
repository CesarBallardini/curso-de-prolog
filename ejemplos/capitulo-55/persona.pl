:- encoding(utf8).

% Capítulo 55 - Versión 2 de los diálogos: el cambio de persona.
%
% Lo que el usuario dice de sí mismo vuelve en boca del programa: yo pasa a
% tú, mi a tu, me a te, y los verbos en primera persona pasan a la segunda
% (estoy a estás, quiero a quieres), y al revés. persona//1 hace el cambio
% en una sola pasada sobre las palabras, con dos reglas de contexto: la
% palabra que sigue a un determinante es un sustantivo y no se toca (mi
% trabajo pasa a tu trabajo, no a tu trabajas), y tu seguido de un verbo o
% de me o te es el pronombre tú, que pasa a yo. palabra_a_palabra/2 es la
% versión sin contexto, que muestra por qué hace falta.
%
% solo-local: carga archivos de otro capítulo, y SWISH no admite módulos
% propios.
%
%?- phrase(persona(P), [creo, que, mi, jefe, no, me, entiende]).

:- module(persona,
          [ persona//1,
            reflejar/2,
            escritura/3,
            reflejar_pieza/3,
            palabra_a_palabra/2,
            conjugada/2,
            responder/2
          ]).

:- use_module(plantillas, [coincide/2, rellenar/2]).
:- use_module('../capitulo-44/lenguaje', [palabras/2]).

% verbo(Raiz, Clase): la primera persona del singular es Raiz seguida de
% o; la segunda, Raiz seguida de as si Clase es ar, o de es si es er o ir.
verbo(necesit, ar).
verbo(odi, ar).
verbo(trabaj, ar).
verbo(estudi, ar).
verbo(llor, ar).
verbo(piens, ar).
verbo(recuerd, ar).
verbo(quier, er).
verbo(pued, er).
verbo(entiend, er).
verbo(cre, er).
verbo(tem, er).
verbo(sient, ir).
verbo(viv, ir).

% irregular(Primera, Segunda): las dos personas de un verbo que no sigue
% la regla de verbo/2.
irregular(soy, eres).
irregular(estoy, estas).
irregular(voy, vas).
irregular(tengo, tienes).
irregular(digo, dices).
irregular(hago, haces).
irregular(he, has).

%!  conjugada(?Primera:atom, ?Segunda:atom) is nondet.
%
%   Primera y Segunda son la primera y la segunda persona del singular del
%   presente de un mismo verbo, sin tildes.
conjugada(Primera, Segunda) :-
    irregular(Primera, Segunda).
conjugada(Primera, Segunda) :-
    verbo(Raiz, Clase),
    atom_concat(Raiz, o, Primera),
    segunda(Clase, Terminacion),
    atom_concat(Raiz, Terminacion, Segunda).

% segunda(Clase, T): la segunda persona de un verbo de la clase Clase
% termina en T.
segunda(ar, as).
segunda(er, es).
segunda(ir, es).

% cambio(P, Q): el pronombre o posesivo P, dicho por el usuario, se
% devuelve como Q.
cambio(yo, "tú").
cambio(me, "te").
cambio(te, "me").
cambio(mi, "tu").
cambio(mis, "tus").
cambio(tu, "mi").
cambio(tus, "mis").
cambio(conmigo, "contigo").
cambio(contigo, "conmigo").

% escrita(P, Q): la palabra P, sin tildes, se escribe Q.
escrita(estas, "estás").

% determinante(D): la palabra que sigue a D es un sustantivo.
determinante(mi).
determinante(mis).
determinante(tu).
determinante(tus).
determinante(el).
determinante(la).
determinante(los).
determinante(las).
determinante(un).
determinante(una).

%!  palabra(+P:atom, -Q) is det.
%
%   Q es la palabra P con la persona cambiada, sin mirar las palabras
%   vecinas: un pronombre o posesivo, o un verbo en primera o segunda
%   persona. Q es P si P no cambia.
palabra(P, Q) :-
    (   cambio(P, Q0)
    ->  Q = Q0
    ;   conjugada(P, Q1)
    ->  forma_escrita(Q1, Q)
    ;   conjugada(Q1, P)
    ->  forma_escrita(Q1, Q)
    ;   Q = P
    ).

%!  forma_escrita(+P:atom, -Q) is det.
%
%   Q es la forma escrita de P, con su tilde si la lleva.
forma_escrita(P, Q) :-
    (   escrita(P, Q0)
    ->  Q = Q0
    ;   Q = P
    ).

%!  palabra_a_palabra(+Palabras:list(atom), -Cambiadas:list) is det.
%
%   Cambia la persona de cada palabra por separado. Se equivoca con los
%   sustantivos que tienen la forma de un verbo: mi trabajo pasa a tu
%   trabajas.
palabra_a_palabra(Palabras, Cambiadas) :-
    maplist(palabra, Palabras, Cambiadas).

%!  persona(-Cambiadas:list)// is det.
%
%   Las palabras de la lista de entrada, con la persona cambiada en una
%   sola pasada. Cada palabra se cambia una vez: tú no vuelve a pasar a yo.
persona(["yo", Q|Qs]) -->
    [tu, P],
    { tras_tu(P) },
    !,
    { palabra(P, Q) },
    persona(Qs).
persona([Q, N|Qs]) -->
    [D, N],
    { determinante(D) },
    !,
    { palabra(D, Q) },
    persona(Qs).
persona([Q|Qs]) -->
    [P],
    !,
    { palabra(P, Q) },
    persona(Qs).
persona([]) -->
    [].

%!  tras_tu(+P:atom) is semidet.
%
%   Después de P, tu es el pronombre tú: P es me, te, no o un verbo en
%   segunda persona.
tras_tu(me).
tras_tu(te).
tras_tu(no).
tras_tu(P) :-
    conjugada(_, P),
    !.

%!  reflejar(+Palabras:list(atom), -Cambiadas:list) is det.
%
%   Cambiadas son las Palabras con la persona cambiada.
reflejar(Palabras, Cambiadas) :-
    phrase(persona(Cambiadas), Palabras).

% regla(Patron, Respuesta): como en la versión 1; las palabras de cada
% variable se devuelven con la persona cambiada.
regla([_, creo, que, X], ["¿Por qué crees que ", X, "?"]).
regla([_, estoy, X], ["¿Por qué estás ", X, "?"]).
regla([_, soy, X], ["¿Desde cuándo eres ", X, "?"]).
regla([_, eres, X], ["¿Qué te hace pensar que soy ", X, "?"]).
regla([_, necesito, X], ["¿Qué harías si consiguieras ", X, "?"]).
regla([_, tengo, miedo, de, X], ["¿Desde cuándo te asusta ", X, "?"]).
regla([X, me, dice, que, Y],
      ["¿Qué piensas de que ", X, " te diga que ", Y, "?"]).
regla([_], ["Continúa, por favor."]).

%!  responder(+Frase:string, -Respuesta:string) is det.
%
%   Respuesta es la respuesta de la primera regla cuyo patrón sigue Frase,
%   con la persona de las palabras repetidas cambiada.
responder(Frase, Respuesta) :-
    palabras(Frase, Palabras),
    once(( regla(Patron, Plantilla),
           coincide(Patron, Palabras) )),
    maplist(reflejar_pieza(Frase), Plantilla, Piezas),
    rellenar(Piezas, Respuesta).

%!  reflejar_pieza(+Frase:string, +Elemento, -Pieza) is det.
%
%   Pieza es Elemento con la persona cambiada y las palabras escritas como
%   en Frase, si es una lista de palabras, o Elemento si es un texto.
reflejar_pieza(Frase, Elemento, Pieza) :-
    (   is_list(Elemento)
    ->  reflejar(Elemento, Cambiadas),
        escritura(Frase, Cambiadas, Pieza)
    ;   Pieza = Elemento
    ).

%!  escritura(+Frase:string, +Palabras:list, -Escritas:list) is det.
%
%   Escritas son las Palabras con la escritura que tienen en Frase, en
%   minúsculas y con sus tildes. Una palabra que no está en Frase, como las
%   que cambian de persona, queda como está.
escritura(Frase, Palabras, Escritas) :-
    string_lower(Frase, Minusculas),
    split_string(Minusculas, " ", " .,;:¿?¡!\"«»()", Partes),
    maplist(escrita_en(Partes), Palabras, Escritas).

%!  escrita_en(+Partes:list(string), +P, -E) is det.
%
%   E es la primera de Partes que, sin tildes, es la palabra P; o P, si P
%   no es un átomo o ninguna parte lo es.
escrita_en(Partes, P, E) :-
    (   atom(P),
        member(Parte, Partes),
        palabras(Parte, [P])
    ->  E = Parte
    ;   E = P
    ).
