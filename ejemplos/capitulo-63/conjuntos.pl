:- encoding(utf8).

% Capítulo 63 - Versión 7: conjuntos de reglas y reglas de control.
%
% Merritt propone agrupar las reglas en conjuntos, cada uno con su propio
% conjunto de conflicto, que se ejecuta hasta que no tiene nada que hacer,
% y reglas de nivel superior que deciden qué conjunto sigue; Rowe llama
% meta-reglas a las que eligen entre reglas. Esta versión lo escribe sin
% cambiar el intérprete:
%
% - el hecho conjunto(C) de la memoria dice qué conjunto está activo, y
%   con_conjuntos/3 agrega la condición conjunto(C) al principio de cada
%   regla del conjunto C, de modo que solo las del activo entran en el
%   conjunto de conflicto;
% - las reglas de control no tienen esa condición, y la estrategia
%   conjuntos(E) las pone detrás de todas las demás: se disparan solo
%   cuando el conjunto activo ya no tiene ninguna instanciación nueva, y
%   reemplazan conjunto(C) por el siguiente.
%
% solo-local: carga estrategias.pl con ensure_loaded/1, y SWISH no permite
% cargar archivos.
%
%?- encadenar(ticket, conjuntos(lex), [conjunto(cargar), item(pan, 2), item(leche, 3)], M, R).

:- ensure_loaded(estrategias).

% control(Programa, Regla): la Regla del Programa es una regla de control.
:- dynamic control/2.

%!  con_conjuntos(+Programa, +Conjuntos:list, +Control:list,
%!                -Reglas:list) is det.
%
%   Reglas son las de cada par Conjunto-Reglas de Conjuntos, con la
%   condición conjunto(Conjunto) al principio, seguidas de las reglas de
%   Control, que quedan anotadas como control(Programa, Nombre).
con_conjuntos(Programa, Conjuntos, Control, Reglas) :-
    retractall(control(Programa, _)),
    forall(member(Nombre :: _ ---> _, Control),
           assertz(control(Programa, Nombre))),
    foldl(agregar_conjunto, Conjuntos, Reglas1, []),
    append(Reglas1, Control, Reglas).

%!  agregar_conjunto(+Par, -Reglas:list, ?Resto:list) is det.
%
%   Reglas son las reglas del Par Conjunto-Reglas0 con la condición
%   conjunto(Conjunto), seguidas de Resto.
agregar_conjunto(Conjunto-Reglas0, Reglas, Resto) :-
    maplist(en_conjunto(Conjunto), Reglas0, Reglas1),
    append(Reglas1, Resto, Reglas).

%!  en_conjunto(+Conjunto, +Regla0, -Regla) is det.
%
%   Regla es Regla0 con la condición conjunto(Conjunto) al principio.
en_conjunto(Conjunto, Nombre :: Condiciones ---> Acciones,
            Nombre :: [conjunto(Conjunto)|Condiciones] ---> Acciones).

% Con conjuntos(E), la clave es c(P, K): P es 0 para una regla de control
% y 1 para las demás, y K es la clave de la estrategia E.
clave_estrategia(conjuntos(E), Instanciacion, c(P, K)) :-
    Instanciacion = instanciacion(Nombre, _, _, _),
    (   control(_, Nombre)
    ->  P = 0
    ;   P = 1
    ),
    clave_estrategia(E, Instanciacion, K).

% reglas_ticket(Conjuntos, Control): un ticket de compra en tres etapas:
% cargar los ítems como líneas, aplicar las ofertas y sumar.
reglas_ticket([ cargar -
                [ linea :: [item(P, C), precio(P, U), {S is C * U}]
                       ---> [quitar(item(P, C)), agregar(linea(P, S))]
                ],
                descuentos -
                [ oferta :: [linea(P, S), oferta(P, D), no(descontada(P)),
                             {S1 is S - S * D // 100}]
                       ---> [reemplazar(linea(P, S), linea(P, S1)),
                             agregar(descontada(P))]
                ],
                total -
                [ sumar :: [linea(P, S), total(T), no(sumada(P)),
                            {T1 is T + S}]
                       ---> [reemplazar(total(T), total(T1)),
                             agregar(sumada(P))]
                ]
              ],
              [ a_descuentos :: [conjunto(cargar)]
                     ---> [reemplazar(conjunto(cargar),
                                      conjunto(descuentos))],
                a_total :: [conjunto(descuentos)]
                     ---> [reemplazar(conjunto(descuentos), conjunto(total)),
                           agregar(total(0))],
                fin :: [conjunto(total), total(T)]
                     ---> [parar(total(T))]
              ]).

% precios: los precios y las ofertas del ticket.
precios([ precio(pan, 100), precio(leche, 80), precio(queso, 300),
          oferta(leche, 25)
        ]).

programa(ticket, Reglas) :-
    reglas_ticket(Conjuntos, Control),
    con_conjuntos(ticket, Conjuntos, Control, Reglas).

% El mismo ticket sin conjuntos: todas las reglas compiten en cada ciclo,
% y el total empieza en 0.
programa(ticket_plano, Reglas) :-
    reglas_ticket(Conjuntos, _),
    findall(R, ( member(_-Rs, Conjuntos), member(R, Rs) ), Reglas).

%!  ticket(+Programa, +Estrategia, +Items:list, -Total) is det.
%
%   Total es el resultado del Programa, ticket o ticket_plano, con la
%   Estrategia para los ítems item(Producto, Cantidad) de Items.
ticket(ticket, Estrategia, Items, Total) :-
    precios(Precios),
    append([[conjunto(cargar)], Precios, Items], Hechos),
    encadenar(ticket, Estrategia, Hechos, _, total(Total)).
ticket(ticket_plano, Estrategia, Items, Total) :-
    precios(Precios),
    append([[total(0)], Precios, Items], Hechos),
    encadenar(ticket_plano, Estrategia, Hechos, Memoria, _),
    memberchk(total(Total), Memoria).
