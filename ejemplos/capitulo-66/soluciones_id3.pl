:- encoding(utf8).

% Capítulo 66 - Solución del ejercicio 14: un atributo con muchos valores.
%
% Se agrega a cada sábado el atributo dia, su número en la tabla: catorce
% valores, uno por ejemplo. Divide los ejemplos en grupos de uno, todos
% puros, así que gana toda la información; la razón de ganancia lo
% penaliza, pero no lo suficiente.
%
% solo-local: carga id3.pl, y SWISH no carga otros archivos.
%
%?- comparar_dia(Filas).
%?- arboles_con_dia(G, R).

:- ensure_loaded(id3).

:- multifile valores/2.

% valores(dia, Ds): el día es el número del ejemplo, de 1 a 14.
valores(dia, Ds) :-
    numlist(1, 14, Ds).

%!  con_dia(-Ejemplos:list) is det.
%
%   Ejemplos son los de ejemplos/1 con el par dia=N agregado al objeto
%   del ejemplo N.
con_dia(Ejemplos) :-
    findall([dia=N, cielo=C, temperatura=T, humedad=H, viento=V]-K,
            sabado(N, C, T, H, V, K),
            Ejemplos).

%!  comparar_dia(-Filas:list) is det.
%
%   Filas tiene un término Atributo-Ganancia-Razon por atributo, con el
%   día, sobre los ejemplos con día.
comparar_dia(Filas) :-
    con_dia(Es),
    findall(A-G-R,
            ( member(A, [dia, cielo, temperatura, humedad, viento]),
              ganancia(Es, A, G),
              razon(Es, A, R) ),
            Filas).

%!  arboles_con_dia(-RaizGanancia, -RaizRazon) is det.
%
%   RaizGanancia y RaizRazon son los atributos de la raíz de los árboles
%   que id3/4 aprende de los ejemplos con día, con cada criterio.
arboles_con_dia(RaizGanancia, RaizRazon) :-
    con_dia(Es),
    Atributos = [dia, cielo, temperatura, humedad, viento],
    id3(ganancia, Es, Atributos, nodo(RaizGanancia, _)),
    id3(razon, Es, Atributos, nodo(RaizRazon, _)).

%!  clasifica_dia_nuevo(-Clase) is semidet.
%
%   Clase es la que el árbol de la ganancia, aprendido con el día, da a
%   un sábado nuevo, el 15, con cielo nublado: falla, porque la raíz no
%   tiene una rama para ese día.
clasifica_dia_nuevo(Clase) :-
    con_dia(Es),
    id3(ganancia, Es, [dia, cielo, temperatura, humedad, viento], A),
    clasificar(A, [dia=15, cielo=nublado, temperatura=calor,
                   humedad=normal, viento=no], Clase).
