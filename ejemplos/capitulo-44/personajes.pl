:- encoding(utf8).

% Capítulo 44 - Personajes que se mueven solos.
%
% En Colossal Cave Adventure los enanos y el pirata recorren la cueva por
% su cuenta: el mundo cambia también sin órdenes del jugador. Aquí un gato
% recorre el observatorio siguiendo una ruta, un paso por turno. Cuando
% está en la cúpula, duerme sobre el telescopio y no deja poner nada en
% él. turno/2 realiza la orden del jugador, mueve los personajes y avisa
% de los que llegan a la sala del jugador o se van de ella. ruta/2 y
% bloquea/3 son multifile: otro archivo agrega personajes con cláusulas
% personajes:ruta(...).
%
% solo-local: carga otros módulos, y SWISH no admite módulos propios.
%
%?- iniciar_personajes, personaje_en(gato, S).
%?- iniciar_personajes, turno(ir(biblioteca), Rs).

:- module(personajes,
          [ iniciar_personajes/0,
            personaje_en/2,
            mover_personajes/0,
            turno/2,
            texto_turno/2
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(estado).

:- dynamic
    paso_en_ruta/2.

% paso_en_ruta(P, I): el personaje P está en la posición I de su ruta,
% contando desde 0.

:- multifile
    ruta/2,
    bloquea/3.

% ruta(P, Salas): el personaje P recorre Salas en ese orden, y vuelve a
% empezar al llegar al final.
ruta(gato, [biblioteca, cupula, biblioteca, vestibulo]).

% bloquea(P, S, Orden): el personaje P, en la sala S, impide Orden.
bloquea(gato, cupula, poner(_, telescopio)).

%!  iniciar_personajes is det.
%
%   Empieza una partida nueva, con cada personaje al principio de su ruta.
iniciar_personajes :-
    iniciar,
    retractall(paso_en_ruta(_, _)),
    forall(ruta(P, _), assertz(paso_en_ruta(P, 0))).

%!  personaje_en(?P, ?S) is nondet.
%
%   El personaje P está en la sala S.
personaje_en(P, S) :-
    paso_en_ruta(P, I),
    ruta(P, Salas),
    nth0(I, Salas, S).

%!  mover_personajes is det.
%
%   Cada personaje avanza un paso en su ruta.
mover_personajes :-
    forall(retract(paso_en_ruta(P, I0)),
           ( ruta(P, Salas),
             length(Salas, N),
             I is (I0 + 1) mod N,
             assertz(paso_en_ruta(P, I)) )).

%!  turno(+Orden, -Respuestas:list) is det.
%
%   Realiza Orden, salvo que un personaje presente la impida, y después
%   mueve los personajes. Respuestas empieza con la respuesta a Orden y
%   sigue con un aviso llega(P) o se_va(P) por cada personaje que entra
%   en la sala del jugador o sale de ella.
turno(Orden, [R|Avisos]) :-
    (   aqui(S),
        personaje_en(P, S),
        bloquea(P, S, Orden)
    ->  R = no_puede(personaje(P))
    ;   realizar(Orden, R)
    ),
    aqui(Sala),
    findall(P, personaje_en(P, Sala), Antes),
    mover_personajes,
    findall(P, personaje_en(P, Sala), Despues),
    avisos(Antes, Despues, Avisos).

%!  avisos(+Antes:list, +Despues:list, -Avisos:list) is det.
%
%   Avisos dice qué personajes de Despues llegaron, porque no estaban en
%   Antes, y cuáles de Antes se fueron.
avisos(Antes, Despues, Avisos) :-
    findall(llega(P), ( member(P, Despues), \+ memberchk(P, Antes) ), Ls),
    findall(se_va(P), ( member(P, Antes), \+ memberchk(P, Despues) ), Vs),
    append(Ls, Vs, Avisos).

%!  texto_turno(+Respuestas:list, -Textos:list(string)) is det.
%
%   Textos son las oraciones de los avisos y de la respuesta de un
%   personaje que impide la orden; las demás respuestas se dejan a la
%   gramática de lenguaje.pl, y aquí se omiten.
texto_turno(Respuestas, Textos) :-
    convlist(texto_aviso, Respuestas, Textos).

%!  texto_aviso(+R, -Texto:string) is semidet.
%
%   Texto es la oración de la respuesta R, si es de un personaje.
texto_aviso(llega(P), Texto) :-
    format(string(Texto), "Entra un ~w.", [P]).
texto_aviso(se_va(P), Texto) :-
    format(string(Texto), "El ~w se va.", [P]).
texto_aviso(no_puede(personaje(P)), Texto) :-
    format(string(Texto),
           "El ~w duerme sobre el telescopio: no puedes poner nada en él.",
           [P]).
