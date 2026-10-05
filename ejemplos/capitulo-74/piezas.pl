:- encoding(utf8).

% Capítulo 74 - Versión 8: el cubo como lista de piezas, y una ayuda para
% la búsqueda.
%
% Merritt usa dos representaciones del cubo: el término de 54 casillas,
% que se gira con una unificación, y una lista de piezas, cada una con
% las casillas de un cubito, que sirve para buscar dónde está una pieza.
% piezas/2 pasa de una a otra con una sola unificación, en los dos
% sentidos: el hecho se genera al cargar, como los giros. donde/4 recorre
% a la vez la lista del cubo resuelto y la del cubo dado para encontrar
% una pieza. La ayuda es la heurística de Merritt de sacar una pieza de
% las posiciones de la etapa antes de buscar: si la pieza que se va a
% colocar está en la capa de abajo, pero fuera de su lugar o girada, una
% secuencia fija la sube a la capa de arriba, y la búsqueda sigue desde
% ahí.
%
% solo-local: carga etapas.pl.
%
%?- pieza_tras([r], 'UFR', P).
%?- donde_tras([r, u, -r], 'DFR', Lugar, Estado).
%?- comparar_ayuda(10, Sin, Con).

:- ensure_loaded(etapas).

% --- La lista de piezas -----------------------------------------------------

%!  term_expansion(+Termino, -Hecho) is semidet.
%
%   El término generar_lista se reemplaza, al cargar, por el hecho
%   piezas(Cubo, Piezas): Cubo es un término c/54 de variables y Piezas
%   la lista de sus 26 piezas, primero los seis centros, p/1, después las
%   doce aristas, p/2, y las ocho esquinas, p/3, con las mismas
%   variables.
term_expansion(generar_lista, piezas(Cubo, Piezas)) :-
    functor(Cubo, c, 54),
    findall(Is, centro(Is), Centros),
    findall(Is, ( pieza(_, _, Is), length(Is, 2) ), Aristas),
    findall(Is, ( pieza(_, _, Is), length(Is, 3) ), Esquinas),
    append([Centros, Aristas, Esquinas], Listas),
    maplist(pieza_de(Cubo), Listas, Piezas).

%!  centro(-Casillas:list(integer)) is nondet.
%
%   Casillas es la lista con la casilla del centro de una cara.
centro([I]) :-
    cara(_, K, _),
    I is 9 * K + 5.

%!  pieza_de(+Cubo, +Casillas:list(integer), -Pieza) is det.
%
%   Pieza es el término p con las casillas Casillas de Cubo.
pieza_de(Cubo, Casillas, Pieza) :-
    maplist(casilla_de(Cubo), Casillas, Colores),
    Pieza =.. [p|Colores].

%!  casilla_de(+Cubo, +I:integer, -Color) is det.
%
%   Color es la casilla I de Cubo.
casilla_de(Cubo, I, Color) :-
    arg(I, Cubo, Color).

generar_lista.

% --- Dónde está una pieza --------------------------------------------------

%!  donde(+Cubo, +Nombre, -Lugar, -Estado) is semidet.
%
%   La pieza Nombre del cubo resuelto ('DF', 'UFR', ...) está en Cubo en
%   el lugar Lugar, el nombre de la pieza que ocupa ese lugar en el cubo
%   resuelto. Estado es en_su_lugar, girada (en su lugar, con los colores
%   en otro orden) o fuera. Falla si Nombre no es una pieza.
donde(Cubo, Nombre, Lugar, Estado) :-
    resuelto(Resuelto),
    piezas(Resuelto, Gs),
    piezas(Cubo, Ss),
    colores_de(Nombre, Buscada),
    buscar(Gs, Ss, Buscada, G, S),
    G =.. [p|Lugares],
    nombre_de(Lugares, Lugar),
    (   Lugar \== Nombre
    ->  Estado = fuera
    ;   G == S
    ->  Estado = en_su_lugar
    ;   Estado = girada
    ).

%!  buscar(+Gs:list, +Ss:list, +Colores:list, -G, -S) is semidet.
%
%   S es la primera pieza de Ss con los mismos Colores, en cualquier
%   orden, y G la pieza de Gs que está en la misma posición de la lista:
%   las dos listas se recorren a la vez.
buscar([G|Gs], [S|Ss], Colores, G1, S1) :-
    S =.. [p|Cs],
    (   msort(Cs, Ordenados),
        msort(Colores, Ordenados)
    ->  G1 = G,
        S1 = S
    ;   buscar(Gs, Ss, Colores, G1, S1)
    ).

%!  colores_de(+Nombre, -Colores:list) is det.
%
%   Colores son las caras de la pieza Nombre, en minúscula y en el orden
%   del nombre.
colores_de(Nombre, Colores) :-
    atom_chars(Nombre, Letras),
    maplist(downcase_atom, Letras, Colores).

%!  nombre_de(+Colores:list, -Nombre) is det.
%
%   Nombre es el nombre de la pieza con las caras Colores: sus letras en
%   mayúscula, en el orden u, d, f, b, r, l.
nombre_de(Colores, Nombre) :-
    findall(C, ( member(C, [u, d, f, b, r, l]), memberchk(C, Colores) ),
            Ordenados),
    maplist(upcase_atom, Ordenados, Letras),
    atomic_list_concat(Letras, Nombre).

%!  piezas_tras(+Movimientos:list, -Piezas:list) is det.
%
%   Piezas es la lista de piezas del cubo resuelto con Movimientos
%   aplicados.
piezas_tras(Movimientos, Piezas) :-
    resuelto(C),
    aplicar(Movimientos, C, C1),
    piezas(C1, Piezas).

%!  en_lugar(+Cubo, +Lugar, -Pieza) is semidet.
%
%   Pieza es la pieza de Cubo que ocupa el lugar Lugar, el nombre de una
%   pieza del cubo resuelto: la búsqueda inversa de donde/4. Falla si
%   Lugar no es una pieza.
en_lugar(Cubo, Lugar, Pieza) :-
    resuelto(Resuelto),
    piezas(Resuelto, Gs),
    piezas(Cubo, Ss),
    colores_de(Lugar, Colores),
    buscar(Ss, Gs, Colores, Pieza, _).

%!  pieza_tras(+Movimientos:list, +Lugar, -Pieza) is semidet.
%
%   Como en_lugar/3, en el cubo resuelto con Movimientos aplicados.
pieza_tras(Movimientos, Lugar, Pieza) :-
    resuelto(C),
    aplicar(Movimientos, C, C1),
    en_lugar(C1, Lugar, Pieza).

%!  donde_tras(+Movimientos:list, +Nombre, -Lugar, -Estado) is semidet.
%
%   Como donde/4, en el cubo resuelto con Movimientos aplicados.
donde_tras(Movimientos, Nombre, Lugar, Estado) :-
    resuelto(C),
    aplicar(Movimientos, C, C1),
    donde(C1, Nombre, Lugar, Estado).

% --- La ayuda ----------------------------------------------------------------

% subida(Etapa, Texto): una secuencia que sube a la capa de arriba la
% pieza de la etapa que está en la capa de abajo, de adelante a la
% derecha, sin mover las otras piezas de la capa de abajo. Se usa en sus
% cuatro orientaciones.
subida(1, "F2").
subida(2, "R U R'").

%!  ayuda(+Etapa, +Colocadas:list, +Pieza, +Cubo, -Movimientos:list) is det.
%
%   Movimientos es una subida de Etapa que lleva Pieza fuera de la capa de
%   abajo sin mover las piezas Colocadas, si Pieza está en la capa de
%   abajo y no en su lugar; [] en otro caso.
ayuda(Etapa, Colocadas, Pieza, Cubo, Movimientos) :-
    (   donde(Cubo, Pieza, Lugar, Estado),
        Estado \== en_su_lugar,
        sub_atom(Lugar, 0, 1, _, 'D'),
        criterio(Colocadas, Criterio),
        subida(Etapa, Texto),
        leer_notacion(Texto, Ms0),
        between(0, 3, K),
        orientar(K, Ms0, Ms),
        aplicar(Ms, Cubo, Cubo1),
        subsumes_term(Criterio, Cubo1),
        donde(Cubo1, Pieza, Lugar1, _),
        \+ sub_atom(Lugar1, 0, 1, _, 'D')
    ->  Movimientos = Ms
    ;   Movimientos = []
    ).

%!  resolver_con_ayuda(+Cubo, -Pasos:list) is det.
%
%   Como resolver/2, pero antes de buscar cada pieza aplica la ayuda/5 de
%   su etapa. Los giros de la ayuda quedan al principio de los del paso.
resolver_con_ayuda(Cubo, Pasos) :-
    findall(E-P, ( etapa(E, Ps), member(P, Ps) ), Plan),
    colocar_con_ayuda(Plan, [], Cubo, Pasos).

%!  colocar_con_ayuda(+Plan:list, +Colocadas:list, +Cubo, -Pasos:list)
%!      is det.
%
%   Como colocar_todas/4, con la ayuda antes de cada búsqueda.
colocar_con_ayuda([], _, _, []).
colocar_con_ayuda([Etapa-Pieza|Plan], Colocadas, Cubo,
                  [paso(Etapa, Pieza, Movimientos)|Pasos]) :-
    ayuda(Etapa, Colocadas, Pieza, Cubo, Subida),
    aplicar(Subida, Cubo, Cubo0),
    Colocadas1 = [Pieza|Colocadas],
    criterio(Colocadas1, Criterio),
    colocar(Etapa, Cubo0, Criterio, Buscados, Cubo1),
    append(Subida, Buscados, Movimientos),
    colocar_con_ayuda(Plan, Colocadas1, Cubo1, Pasos).

%!  comparar_ayuda(+Semillas:integer, -Sin, -Con) is det.
%
%   Sin y Con son medida(Giros, Inferencias): los cuartos de vuelta y las
%   inferencias que suman resolver/2 y resolver_con_ayuda/2 sobre las
%   mezclas de 25 giros de las semillas 1 a Semillas.
comparar_ayuda(Semillas, Sin, Con) :-
    medir_metodo(resolver, Semillas, Sin),
    medir_metodo(resolver_con_ayuda, Semillas, Con).

%!  medir_metodo(+Metodo, +Semillas:integer, -Medida) is det.
%
%   Medida es medida(Giros, Inferencias) para Metodo sobre las semillas 1
%   a Semillas. Lanza un error si alguna solución no deja el cubo
%   resuelto.
medir_metodo(Metodo, Semillas, medida(Giros, Inferencias)) :-
    findall(G-I, ( between(1, Semillas, S),
                   resolver_semilla(Metodo, S, G, I) ), Pares),
    pairs_keys_values(Pares, Gs, Is),
    sum_list(Gs, Giros),
    sum_list(Is, Inferencias).

%!  resolver_semilla(+Metodo, +Semilla:integer, -Giros:integer,
%!                   -Inferencias:integer) is det.
%
%   Metodo resuelve la mezcla de 25 giros de Semilla con Giros cuartos de
%   vuelta y Inferencias inferencias.
resolver_semilla(Metodo, Semilla, Giros, Inferencias) :-
    mezcla(Semilla, 25, Ms),
    resuelto(C),
    aplicar(Ms, C, C1),
    contar(call(Metodo, C1, Pasos), Inferencias),
    findall(G, member(paso(_, _, G), Pasos), Listas),
    append(Listas, Todos),
    length(Todos, Giros),
    aplicar(Todos, C1, C2),
    (   C2 == C
    ->  true
    ;   domain_error(cubo_resuelto, C2)
    ).
