:- encoding(utf8).

% Capítulo 20 - Soluciones de los ejercicios 1 a 10. Las de los ejercicios 11
% y 12 están en soluciones_wumpus.pl, y las de 13 a 15 en
% soluciones_proyecto.pl.
%
%?- iniciar_cuenta, depositar(100), extraer(30), saldo(S).
%?- olvidar_sumas, suma_hasta(100, S).
%?- reiniciar, encadenar, como(abuelo(juan, sofia)).

:- dynamic q/2, p/1, h/1, vive_cerca_del_agua/1, numero/1, semilla/1,
    cuenta/1, suma_guardada/2, hecho/1, derivado/3.

% --- Ejercicio 2 --------------------------------------------------------------

%!  nada_bien(?P) is nondet.
%
%   P nada bien: vive cerca del agua y sabe nadar. vive_cerca_del_agua/1 es
%   dinámico y todavía no tiene hechos: la consulta falla en lugar de
%   producir un error.
nada_bien(P) :-
    vive_cerca_del_agua(P),
    sabe_nadar(P).

% sabe_nadar(P): P sabe nadar.
sabe_nadar(ana).
sabe_nadar(luis).

% --- Ejercicio 3 --------------------------------------------------------------

% numero(N): los números del ejercicio.
numero(1).
numero(2).
numero(3).

% --- Ejercicio 4 --------------------------------------------------------------

% semilla(S): la semilla del generador; cambia en cada número generado.
semilla(13).

%!  aleatorio(+R:integer, -N:integer) is det.
%
%   N es un número entre 1 y R calculado a partir de la semilla, que se
%   reemplaza por la siguiente: (125 * S + 1) mod 4096.
aleatorio(R, N) :-
    retract(semilla(S)),
    N is S mod R + 1,
    S1 is (125 * S + 1) mod 4096,
    assertz(semilla(S1)).

%!  primeros_aleatorios(+Cantidad:integer, +R:integer, -L:list) is det.
%
%   L son los próximos Cantidad números de aleatorio(R, N).
primeros_aleatorios(Cantidad, R, L) :-
    length(L, Cantidad),
    maplist(aleatorio(R), L).

% --- Ejercicio 5 --------------------------------------------------------------

%!  iniciar_cuenta is det.
%
%   Abre una cuenta con saldo 0, o la vuelve a abrir si ya estaba abierta.
iniciar_cuenta :-
    retractall(cuenta(_)),
    assertz(cuenta(0)).

%!  cerrar_cuenta is semidet.
%
%   Cierra la cuenta. Falla si no hay una cuenta abierta.
cerrar_cuenta :-
    retract(cuenta(_)).

%!  depositar(+Monto:number) is semidet.
%
%   Suma Monto al saldo. Falla si la cuenta está cerrada o si Monto no es
%   positivo.
depositar(Monto) :-
    Monto > 0,
    retract(cuenta(Saldo0)),
    Saldo is Saldo0 + Monto,
    assertz(cuenta(Saldo)).

%!  extraer(+Monto:number) is semidet.
%
%   Resta Monto del saldo. Falla si la cuenta está cerrada, si Monto no es
%   positivo o si el saldo no alcanza; en esos casos el saldo no cambia.
extraer(Monto) :-
    Monto > 0,
    cuenta(Saldo0),
    Saldo0 >= Monto,
    retract(cuenta(Saldo0)),
    Saldo is Saldo0 - Monto,
    assertz(cuenta(Saldo)).

%!  saldo(-Saldo:number) is semidet.
%
%   Saldo es el saldo de la cuenta. Falla si la cuenta está cerrada.
saldo(Saldo) :-
    cuenta(Saldo).

% --- Ejercicio 6 --------------------------------------------------------------

%!  suma_hasta(+N:integer, -S:integer) is det.
%
%   S es la suma de los enteros de 1 a N, con N mayor o igual que 1. Cada
%   suma calculada se guarda en suma_guardada/2.
suma_hasta(N, S) :-
    (   suma_guardada(N, S0)
    ->  S = S0
    ;   N =:= 1
    ->  S = 1
    ;   N1 is N - 1,
        suma_hasta(N1, S1),
        S0 is S1 + N,
        assertz(suma_guardada(N, S0)),
        S = S0
    ).

%!  olvidar_sumas is det.
%
%   Borra las sumas guardadas.
olvidar_sumas :-
    retractall(suma_guardada(_, _)).

% --- Ejercicios 8 a 10: el sistema del texto, con dos reglas más ------------

% inicial(F): F es uno de los hechos con los que empieza la base.
inicial(padre(juan, ana)).
inicial(padre(juan, pedro)).
inicial(padre(pedro, luis)).
inicial(padre(pedro, eva)).
inicial(madre(marta, ana)).
inicial(madre(marta, pedro)).
inicial(madre(ana, sofia)).

% regla(Nombre, Condiciones, Conclusion): si se cumplen todas las
% Condiciones, Conclusion es un hecho. tio_o_tia y primos son del ejercicio 9.
regla(progenitor_p, [padre(P, H)],                   progenitor(P, H)).
regla(progenitor_m, [madre(M, H)],                   progenitor(M, H)).
regla(abuelo,       [padre(A, P), progenitor(P, N)], abuelo(A, N)).
regla(hermanos,     [progenitor(P, A), progenitor(P, B), A \== B],
                                                     hermanos(A, B)).
regla(antepasado_1, [progenitor(A, D)],              antepasado(A, D)).
regla(antepasado_2, [progenitor(A, H), antepasado(H, D)], antepasado(A, D)).
regla(tio_o_tia,    [hermanos(T, P), progenitor(P, S)], tio_o_tia(T, S)).
regla(primos,       [progenitor(P, A), hermanos(P, Q), progenitor(Q, B)],
                                                     primos(A, B)).

%!  reiniciar is det.
%
%   Deja en la base solo los hechos iniciales.
reiniciar :-
    retractall(hecho(_)),
    retractall(derivado(_, _, _)),
    forall(inicial(F), assertz(hecho(F))).

%!  encadenar is det.
%
%   El encadenamiento del texto: de a una conclusión por vez.
encadenar :-
    (   regla(Nombre, Condiciones, Conclusion),
        maplist(se_cumple, Condiciones),
        \+ hecho(Conclusion)
    ->  assertz(hecho(Conclusion)),
        assertz(derivado(Conclusion, Nombre, Condiciones)),
        encadenar
    ;   true
    ).

%!  se_cumple(+Condicion) is nondet.
%
%   Condicion es un hecho de la base, o una comparación A \== B que se
%   cumple.
se_cumple(A \== B) :-
    A \== B.
se_cumple(Condicion) :-
    Condicion \= ( _ \== _ ),
    hecho(Condicion).

%!  como(+Hecho) is semidet.
%
%   Escribe cómo se obtuvo Hecho: la regla y, debajo, cómo se obtuvo cada
%   una de sus condiciones, hasta los hechos iniciales. Falla si Hecho no
%   está en la base.
como(Hecho) :-
    hecho(Hecho),
    como(Hecho, 0).

%!  como(+Hecho, +Sangria:integer) is det.
%
%   Escribe la explicación de Hecho a partir de la columna Sangria.
como(A \== B, Sangria) :-
    format("~t~*|~w \\== ~w: se cumple~n", [Sangria, A, B]).
como(Hecho, Sangria) :-
    Hecho \= ( _ \== _ ),
    (   derivado(Hecho, Regla, Condiciones)
    ->  format("~t~*|~w: por ~w~n", [Sangria, Hecho, Regla]),
        Siguiente is Sangria + 2,
        forall(member(C, Condiciones), como(C, Siguiente))
    ;   format("~t~*|~w: dato inicial~n", [Sangria, Hecho])
    ).

%!  encadenar_por_rondas(-Rondas:integer) is det.
%
%   Agrega las conclusiones por rondas: en cada una, todas las que las reglas
%   producen con los hechos del comienzo de la ronda. Rondas es la cantidad
%   de rondas que agregaron algún hecho.
encadenar_por_rondas(Rondas) :-
    por_rondas(0, Rondas).

%!  por_rondas(+Hechas:integer, -Rondas:integer) is det.
%
%   Rondas es Hechas más las rondas que todavía agregan algún hecho.
por_rondas(Hechas, Rondas) :-
    findall(Conclusion-Nombre-Condiciones,
            ( regla(Nombre, Condiciones, Conclusion),
              maplist(se_cumple, Condiciones),
              \+ hecho(Conclusion) ),
            Nuevos),
    (   Nuevos == []
    ->  Rondas = Hechas
    ;   forall(member(Conclusion-Nombre-Condiciones, Nuevos),
               agregar(Conclusion, Nombre, Condiciones)),
        Siguiente is Hechas + 1,
        por_rondas(Siguiente, Rondas)
    ).

%!  agregar(+Conclusion, +Nombre, +Condiciones:list) is det.
%
%   Agrega Conclusion a la base, si todavía no estaba: dos reglas, o dos
%   formas de cumplir la misma, pueden producir el mismo hecho en una ronda.
agregar(Conclusion, Nombre, Condiciones) :-
    (   hecho(Conclusion)
    ->  true
    ;   assertz(hecho(Conclusion)),
        assertz(derivado(Conclusion, Nombre, Condiciones))
    ).
