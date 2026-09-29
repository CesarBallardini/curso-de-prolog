:- encoding(utf8).

% Capítulo 44 - Versión 2 de la aventura: el estado detrás de una interfaz.
%
% Cuatro predicados dinámicos guardan lo que cambia: aqui/1, esta_en/2,
% cerrada/1 y encendido/1. Solo los modifican iniciar/0, restablecer/1 y
% los cinco predicados de cambio (mover_a/1, trasladar/2, abrir_cosa/1,
% encender_cosa/1, apagar_cosa/1), como pide el Patrón 19. realizar/2
% ejecuta una orden: si un impedimento la bloquea, responde el motivo; si
% no, aplica su efecto. Las respuestas son términos, no texto.
%
% solo-local: SWISH no admite módulos propios.
%
%?- iniciar, realizar(ir(biblioteca), R).

:- module(estado,
          [ iniciar/0,
            instantanea/1,
            restablecer/1,
            realizar/2,
            ganado/0,
            aqui/1,
            esta_en/2,
            cerrada/1,
            encendido/1,
            al_alcance/1,
            a_oscuras/0,
            objetos_en/2,
            impedimento/2
          ]).

:- reexport(mundo).

:- dynamic
    aqui/1,
    esta_en/2,
    cerrada/1,
    encendido/1.

% aqui(S): el jugador está en la sala S.
% esta_en(O, L): el objeto O está en L, una sala, un recipiente o jugador.
% cerrada(X): la puerta o el recipiente X está cerrado.
% encendido(O): la luz O está encendida.

%!  iniciar is det.
%
%   Deja el estado de una partida nueva: los hechos de inicio/1.
iniciar :-
    findall(H, inicio(H), Hs),
    restablecer(Hs).

%!  instantanea(-Hechos:list) is det.
%
%   Hechos son los hechos del estado actual, ordenados.
instantanea(Hechos) :-
    findall(H, vale(H), Hs),
    sort(Hs, Hechos).

%!  restablecer(+Hechos:list) is det.
%
%   Reemplaza el estado por Hechos. Produce un error de dominio, sin
%   cambiar nada, si un hecho no es un hecho de estado válido o si Hechos
%   no tiene exactamente un aqui/1.
restablecer(Hechos) :-
    must_be(list, Hechos),
    maplist(validar_hecho, Hechos),
    (   aggregate_all(count, member(aqui(_), Hechos), 1)
    ->  true
    ;   domain_error(estado_con_un_lugar, Hechos)
    ),
    retractall(aqui(_)),
    retractall(esta_en(_, _)),
    retractall(cerrada(_)),
    retractall(encendido(_)),
    maplist(assertz, Hechos).

%!  validar_hecho(+H) is det.
%
%   Verifica que H sea un hecho de estado válido para el mundo.
validar_hecho(H) :-
    (   hecho_valido(H)
    ->  true
    ;   domain_error(hecho_de_estado, H)
    ).

%!  hecho_valido(+H) is semidet.
%
%   H es un hecho de estado que nombra cosas que existen en el mundo.
hecho_valido(aqui(S)) :-
    atom(S),
    sala(S, _).
hecho_valido(esta_en(O, L)) :-
    atom(O),
    atom(L),
    objeto(O),
    (   L == jugador
    ->  true
    ;   sala(L, _)
    ->  true
    ;   recipiente(L)
    ).
hecho_valido(cerrada(X)) :-
    atom(X),
    (   puerta(X, _, _)
    ->  true
    ;   recipiente(X)
    ).
hecho_valido(encendido(O)) :-
    atom(O),
    luz(O).

%!  vale(?H) is nondet.
%
%   H es un hecho del estado actual.
vale(aqui(S)) :-
    aqui(S).
vale(esta_en(O, L)) :-
    esta_en(O, L).
vale(cerrada(X)) :-
    cerrada(X).
vale(encendido(O)) :-
    encendido(O).

%!  ganado is semidet.
%
%   Todos los hechos de meta/1 valen en el estado actual.
ganado :-
    forall(meta(M), vale(M)).

%!  al_alcance(?X) is nondet.
%
%   X es un paso de la sala actual, o un objeto que está en la sala, en el
%   inventario o dentro de un recipiente abierto que está al alcance.
al_alcance(X) :-
    aqui(S),
    conecta(X, S, _).
al_alcance(X) :-
    esta_en(X, L),
    accesible(L).

%!  accesible(+L) is semidet.
%
%   Lo que está en L está al alcance.
accesible(jugador).
accesible(S) :-
    aqui(S).
accesible(R) :-
    recipiente(R),
    \+ cerrada(R),
    al_alcance(R).

%!  a_oscuras is semidet.
%
%   La sala actual es oscura y ninguna luz encendida está al alcance.
a_oscuras :-
    aqui(S),
    oscura(S),
    \+ ( luz(L), encendido(L), al_alcance(L) ).

%!  objetos_en(+L, -Objetos:list) is det.
%
%   Objetos son los objetos que están directamente en L, ordenados.
objetos_en(L, Objetos) :-
    findall(O, esta_en(O, L), Os),
    sort(Os, Objetos).

% es_orden(O): O es una orden que realizar/2 ejecuta.
es_orden(mirar).
es_orden(inventario).
es_orden(ir(_)).
es_orden(examinar(_)).
es_orden(tomar(_)).
es_orden(dejar(_)).
es_orden(poner(_, _)).
es_orden(abrir(_)).
es_orden(encender(_)).
es_orden(apagar(_)).

%!  realizar(+Orden, -Respuesta) is det.
%
%   Ejecuta Orden sobre el estado. Respuesta es no_puede(Motivo) si un
%   impedimento la bloquea, y el resultado de su efecto si no. Produce un
%   error de dominio si Orden no es una orden.
realizar(Orden, Respuesta) :-
    (   es_orden(Orden)
    ->  true
    ;   domain_error(orden, Orden)
    ),
    (   impedimento(Orden, Motivo)
    ->  Respuesta = no_puede(Motivo)
    ;   efecto(Orden, Respuesta)
    ).

%!  impedimento(+Orden, -Motivo) is nondet.
%
%   Motivo impide ejecutar Orden en el estado actual. realizar/2 usa el
%   primero; por eso el orden de las cláusulas es el orden de los avisos.
impedimento(ir(S), ya_esta(S)) :-
    aqui(S).
impedimento(ir(S), no_hay_paso(S)) :-
    aqui(A),
    \+ conecta(_, A, S).
impedimento(ir(S), cerrado(P)) :-
    aqui(A),
    conecta(P, A, S),
    cerrada(P).
impedimento(Orden, oscuro) :-
    requiere_luz(Orden),
    a_oscuras.
impedimento(Orden, no_lo_tiene(O)) :-
    se_lleva(Orden, O),
    \+ esta_en(O, jugador).
impedimento(Orden, no_esta(X)) :-
    se_alcanza(Orden, X),
    \+ al_alcance(X).
impedimento(tomar(O), ya_lo_tiene(O)) :-
    esta_en(O, jugador).
impedimento(tomar(X), fijo(X)) :-
    (   fijo(X)
    ->  true
    ;   \+ objeto(X)
    ).
impedimento(poner(_, R), no_es_recipiente(R)) :-
    \+ recipiente(R).
impedimento(poner(_, R), cerrado(R)) :-
    cerrada(R).
impedimento(abrir(X), no_se_abre(X)) :-
    \+ puerta(X, _, _),
    \+ recipiente(X).
impedimento(abrir(X), ya_abierto(X)) :-
    \+ cerrada(X).
impedimento(abrir(X), falta(L, X)) :-
    llave_de(L, X),
    \+ esta_en(L, jugador).
impedimento(Orden, no_se_enciende(O)) :-
    se_enciende(Orden, O),
    \+ luz(O).
impedimento(encender(O), ya_encendido(O)) :-
    encendido(O).
impedimento(apagar(O), ya_apagado(O)) :-
    \+ encendido(O).

% requiere_luz(Orden): Orden no se puede hacer a oscuras.
requiere_luz(examinar(_)).
requiere_luz(tomar(_)).
requiere_luz(poner(_, _)).
requiere_luz(abrir(_)).

% se_lleva(Orden, O): Orden necesita que el jugador lleve O.
se_lleva(dejar(O), O).
se_lleva(poner(O, _), O).

% se_alcanza(Orden, X): Orden necesita que X esté al alcance.
se_alcanza(examinar(X), X).
se_alcanza(tomar(X), X).
se_alcanza(poner(_, X), X).
se_alcanza(abrir(X), X).
se_alcanza(encender(X), X).
se_alcanza(apagar(X), X).

% se_enciende(Orden, O): Orden enciende o apaga O.
se_enciende(encender(O), O).
se_enciende(apagar(O), O).

%!  efecto(+Orden, -Respuesta) is det.
%
%   Aplica Orden, que ningún impedimento bloquea, y da su resultado.
efecto(mirar, Respuesta) :-
    vista(Respuesta).
efecto(inventario, inventario(Os)) :-
    objetos_en(jugador, Os).
efecto(ir(S), Respuesta) :-
    mover_a(S),
    vista(Respuesta).
efecto(examinar(X), Respuesta) :-
    (   cerrada(X)
    ->  Respuesta = cerrado(X)
    ;   recipiente(X)
    ->  objetos_en(X, Os),
        Respuesta = contenido(X, Os)
    ;   Respuesta = sin_nada(X)
    ).
efecto(tomar(O), tomado(O)) :-
    trasladar(O, jugador).
efecto(dejar(O), dejado(O, S)) :-
    aqui(S),
    trasladar(O, S).
efecto(poner(O, R), puesto(O, R)) :-
    trasladar(O, R).
efecto(abrir(X), abierto(X)) :-
    abrir_cosa(X).
efecto(encender(O), luz_encendida(O)) :-
    encender_cosa(O).
efecto(apagar(O), luz_apagada(O)) :-
    apagar_cosa(O).

%!  vista(-Respuesta) is det.
%
%   Respuesta es lo que se ve en la sala actual: vista(Sala, Objetos,
%   Salidas), u oscuridad si no hay luz.
vista(Respuesta) :-
    (   a_oscuras
    ->  Respuesta = oscuridad
    ;   aqui(S),
        objetos_en(S, Os),
        findall(D, conecta(_, S, D), Salidas),
        Respuesta = vista(S, Os, Salidas)
    ).

%!  mover_a(+S) is det.
%
%   El jugador pasa a estar en la sala S.
mover_a(S) :-
    retractall(aqui(_)),
    assertz(aqui(S)).

%!  trasladar(+O, +L) is det.
%
%   El objeto O pasa a estar en L.
trasladar(O, L) :-
    retractall(esta_en(O, _)),
    assertz(esta_en(O, L)).

%!  abrir_cosa(+X) is det.
%
%   La puerta o el recipiente X deja de estar cerrado.
abrir_cosa(X) :-
    retractall(cerrada(X)).

%!  encender_cosa(+O) is det.
%
%   La luz O queda encendida.
encender_cosa(O) :-
    assertz(encendido(O)).

%!  apagar_cosa(+O) is det.
%
%   La luz O queda apagada.
apagar_cosa(O) :-
    retractall(encendido(O)).
