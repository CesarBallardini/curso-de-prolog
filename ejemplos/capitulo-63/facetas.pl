:- encoding(utf8).

% Capítulo 63 - Versión 6: valores calculados y demonios.
%
% Merritt da a cada ranura de un marco varias facetas: el valor, el valor
% por omisión, un procedimiento que lo calcula (calc) y demonios que se
% ejecutan al poner o quitar un valor (add, del). Esta versión agrega a
% los marcos de marcos.pl las dos que faltan, como hechos y reglas aparte:
%
% - calculo(Clase, Ranura, Ranuras, Valor): Valor es el de la Ranura en un
%   objeto de la Clase con los valores propios Ranuras, si no tiene uno
%   propio. En cada clase de la cadena de herencia se busca primero el
%   valor por omisión y después el cálculo, de modo que el cálculo de una
%   subclase oculta el valor por omisión de una superclase.
% - demonio(Clase, Ranura, Valor, Ranuras0, Ranuras): al poner Valor en la
%   Ranura de un objeto de la Clase, Ranuras es lo que resulta de los
%   valores propios Ranuras0, que ya tienen el valor nuevo. Un demonio
%   puede rechazar el valor con un error, o ajustar otras ranuras.
%
% con_facetas/2 traduce las reglas como con_marcos/2, y después cambia la
% consulta y la escritura de las ranuras por las que conocen las facetas.
%
% solo-local: carga marcos.pl con ensure_loaded/1, y SWISH no permite
% cargar archivos.
%
%?- valor_con_facetas(memoria, [gb-16], precio, P).
%?- encadenar(ampliar_memoria, orden, [objeto(mem_a, memoria, [gb-8]), pedido_memoria(32)], M, R).

:- ensure_loaded(marcos).

% Otros archivos agregan cálculos y demonios.
:- multifile calculo/4, demonio/5.

% El precio de la memoria se calcula por gigabyte, si el objeto no tiene
% uno propio.
calculo(memoria, precio, Ranuras, Precio) :-
    memberchk(gb-Gb, Ranuras),
    Precio is Gb * 3.

% Un precio propio no puede ser negativo.
demonio(componente, precio, Precio, Ranuras, Ranuras) :-
    (   number(Precio),
        Precio >= 0
    ->  true
    ;   domain_error(precio_no_negativo, Precio)
    ).
% Al cambiar el tamaño de una memoria, su precio propio deja de valer, y
% el cálculo vuelve a regir.
demonio(memoria, gb, _, Ranuras0, Ranuras) :-
    exclude(de_ranura(precio), Ranuras0, Ranuras).

%!  valor_con_facetas(+Clase, +Ranuras:list, +Ranura, -Valor) is semidet.
%
%   Valor es el de la Ranura en un objeto de la Clase con los valores
%   propios Ranuras: el propio, o, en la primera clase de la cadena de
%   herencia que tenga alguno, el valor por omisión o el calculado. Falla
%   si ninguna clase lo define.
valor_con_facetas(_, Ranuras, Ranura, Valor) :-
    memberchk(Ranura-Propio, Ranuras),
    !,
    Valor = Propio.
valor_con_facetas(Clase, Ranuras, Ranura, Valor) :-
    once(( es_un(Clase, Superclase),
           faceta(Superclase, Ranuras, Ranura, Valor0)
         )),
    Valor = Valor0.

%!  faceta(+Clase, +Ranuras:list, +Ranura, -Valor) is semidet.
%
%   Valor es el valor por omisión de la Ranura en la Clase, o, si no lo
%   tiene, el que calcula calculo/4 para los valores propios Ranuras.
faceta(Clase, Ranuras, Ranura, Valor) :-
    (   marco(Clase, _, PorOmision),
        memberchk(Ranura-Valor0, PorOmision)
    ->  Valor = Valor0
    ;   once(calculo(Clase, Ranura, Ranuras, Valor))
    ).

%!  consultar_facetas(+Clase, +Ranuras:list, ?Consultas:list) is semidet.
%
%   Como consultar/3 de marcos.pl, con valor_con_facetas/4.
consultar_facetas(Clase, Ranuras, Consultas) :-
    maplist(consultar_faceta(Clase, Ranuras), Consultas).

%!  consultar_faceta(+Clase, +Ranuras:list, ?Consulta) is semidet.
%
%   Consulta es Ranura-Valor, y la Ranura tiene el Valor.
consultar_faceta(Clase, Ranuras, Ranura-Valor) :-
    valor_con_facetas(Clase, Ranuras, Ranura, Valor).

%!  poner_con_demonios(+Clase, +Ranuras0:list, +Ranura, +Valor,
%!                     -Ranuras:list) is det.
%
%   Ranuras es Ranuras0 con Ranura-Valor como valor propio, después de
%   ejecutar el demonio de la Ranura de la primera clase de la cadena de
%   herencia que tenga uno. Sin demonio, es lo que da fijar_ranura/4.
poner_con_demonios(Clase, Ranuras0, Ranura, Valor, Ranuras) :-
    fijar_ranura(Ranuras0, Ranura, Valor, Ranuras1),
    (   es_un(Clase, Superclase),
        clause(demonio(Superclase, Ranura, _, _, _), _)
    ->  once(demonio(Superclase, Ranura, Valor, Ranuras1, Ranuras))
    ;   Ranuras = Ranuras1
    ).

%!  con_facetas(+Reglas0:list, -Reglas:list) is det.
%
%   Reglas son las Reglas0 traducidas por con_marcos/2, con las consultas
%   y las escrituras de ranuras que conocen las facetas.
con_facetas(Reglas0, Reglas) :-
    con_marcos(Reglas0, Reglas1),
    maplist(regla_con_facetas, Reglas1, Reglas).

%!  regla_con_facetas(+Regla0, -Regla) is det.
%
%   Regla es Regla0 con consultar/3 cambiado por consultar_facetas/3 en
%   las condiciones, y fijar_ranura/4 por poner_con_demonios/5 en las
%   acciones.
regla_con_facetas(Nombre :: Condiciones0 ---> Acciones0,
                  Nombre :: Condiciones ---> Acciones) :-
    maplist(condicion_con_facetas, Condiciones0, Condiciones),
    acciones_con_facetas(Acciones0, Acciones).

%!  condicion_con_facetas(+Condicion0, -Condicion) is det.
%
%   Condicion es Condicion0 con la consulta de las facetas.
condicion_con_facetas(Condicion0, Condicion) :-
    (   Condicion0 = {es_de_clase(C, K), consultar(C, R, Q)}
    ->  Condicion = {es_de_clase(C, K), consultar_facetas(C, R, Q)}
    ;   Condicion = Condicion0
    ).

%!  acciones_con_facetas(+Acciones0:list, -Acciones:list) is det.
%
%   Acciones son Acciones0 con cada fijar_ranura/4 que precede a un
%   reemplazar/2 del objeto cambiado por poner_con_demonios/5, que
%   necesita la clase del objeto.
acciones_con_facetas([], []).
acciones_con_facetas([A0|As0], [A|As]) :-
    (   A0 = {fijar_ranura(R0, Ranura, Valor, R1)},
        As0 = [reemplazar(objeto(O, C, R0), objeto(O, C, R1))|_]
    ->  A = {poner_con_demonios(C, R0, Ranura, Valor, R1)}
    ;   A = A0
    ),
    acciones_con_facetas(As0, As).

% Amplía las memorias hasta el tamaño pedido e informa su precio.
programa(ampliar_memoria, Reglas) :-
    con_facetas(
        [ ampliar :: [pedido_memoria(G), es(M, memoria, [gb-G0]), {G0 < G}]
               ---> [poner(M, gb, G)],
          informar :: [es(M, memoria, [gb-G, precio-P])]
               ---> [agregar(precio(M, G, P))]
        ], Reglas).
