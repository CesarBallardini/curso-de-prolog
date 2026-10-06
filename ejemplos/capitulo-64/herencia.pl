:- encoding(utf8).

% Capítulo 64 - Extensión: la herencia en los patrones.
%
% Un patrón es(X, Clase, Consultas) del capítulo 63 pide un objeto de la
% Clase o de una subclase suya. con_marcos/2 lo traduce a objeto(X, C, R)
% seguido de la prueba {es_de_clase(C, Clase), consultar(C, R, ...)}, y
% la versión 7 lleva esa prueba al nodo alfa: el nodo de un patrón sobre
% componente acepta los procesadores, las placas y las fuentes, porque la
% prueba consulta los marcos. Un patrón escrito con la clase como
% constante, objeto(X, componente, R), solo aceptaría objetos creados con
% esa clase exacta, y ningún objeto del catálogo lo es.
%
% solo-local: carga pruebas.pl con ensure_loaded/1, y SWISH no permite
% cargar archivos.
%
%?- clases_que_aceptan(objeto(cpu_a, procesador, [nucleos-6]), Cs).

:- ensure_loaded(pruebas).

%!  clases_que_aceptan(+Objeto, -Clases:list) is det.
%
%   Clases son las clases de los patrones es/3 del configurador cuyos
%   nodos alfa, en la red de red_con_pruebas/2, aceptan el Objeto, sin
%   repetidos y en orden alfabético.
clases_que_aceptan(Objeto, Clases) :-
    red_con_pruebas(configurador, Red),
    alfas_del_hecho(Red, Objeto, Nodos),
    Red = red(_, Alfas, _, _),
    findall(Clase,
            ( member(A, Nodos),
              get_assoc(A, Alfas, a(alfa(_, Pruebas), _)),
              memberchk(es_de_clase(_, Clase), Pruebas) ),
            Clases0),
    sort(Clases0, Clases).

%!  nodos_por_clase(+Clase, -Nodos:integer) is det.
%
%   Nodos es la cantidad de nodos alfa del configurador cuya prueba pide
%   un objeto de la Clase.
nodos_por_clase(Clase, Nodos) :-
    red_con_pruebas(configurador, red(_, Alfas, _, _)),
    aggregate_all(count,
                  ( gen_assoc(_, Alfas, a(alfa(_, Pruebas), _)),
                    memberchk(es_de_clase(_, C), Pruebas),
                    C == Clase ),
                  Nodos).

%!  aceptado_literal(+Objeto, +Clase) is semidet.
%
%   El patrón objeto(_, Clase, _), con la clase escrita como constante,
%   acepta el Objeto: solo cuando el objeto es de esa clase exacta.
aceptado_literal(Objeto, Clase) :-
    Objeto = objeto(_, Clase, _).
