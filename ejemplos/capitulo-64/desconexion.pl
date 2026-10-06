:- encoding(utf8).

% Capítulo 64 - Extensión: las activaciones nulas.
%
% Una activación por la derecha es nula cuando el nodo de unión no tiene
% tokens en su padre: el hecho nuevo no tiene con qué unirse. Una
% activación por la izquierda es nula cuando la memoria alfa del nodo está
% vacía: el token nuevo no tiene con qué unirse. La versión 3 ya evita las
% primeras con una consulta; las segundas se ejecutan y no producen nada.
% activaciones/3 carga los hechos uno por uno y cuenta las dos clases.
% Las activaciones por la derecha se cuentan antes de cada una; las de la
% izquierda, por la diferencia entre los tokens de cada nodo antes y
% después del hecho, porque cada token que entra o sale de un nodo activa
% a cada uno de sus hijos. nodos_vacios/3 cuenta, al final de la carga,
% los nodos de unión con el padre vacío, con la memoria alfa vacía y con
% las dos cosas.
%
% solo-local: carga medida.pl con ensure_loaded/1, y SWISH no permite cargar
% archivos.
%
%?- activaciones(configurador, pedido(0), A).
%?- nodos_vacios(configurador, pedido(0), N).

:- ensure_loaded(medida).

%!  hechos_de(+Fuente, -Hechos:list) is det.
%
%   Hechos son los de la Fuente: familia, los de familia/1; pedido(K), los
%   de pedido_ampliado/2; cadena(N), los de cadena/2; lista(Hs), los Hs.
hechos_de(familia, Hechos) :-
    familia(Hechos).
hechos_de(pedido(K), Hechos) :-
    pedido_ampliado(K, Hechos).
hechos_de(cadena(N), Hechos) :-
    cadena(N, Hechos).
hechos_de(lista(Hechos), Hechos).

%!  activaciones(+Programa, +Fuente, -Cuenta) is det.
%
%   Cuenta es a(Derecha, DerechaNulas, Izquierda, IzquierdaNulas): las
%   activaciones de los nodos de unión por la derecha y por la izquierda
%   al cargar los hechos de la Fuente en la red de red_de/2, y cuántas de
%   cada clase son nulas.
activaciones(Programa, Fuente, Cuenta) :-
    hechos_de(Fuente, Hechos),
    red_de(Programa, Red),
    memoria_vacia(Memoria0),
    rete_vacio(Red, Rete0),
    foldl(entrar_contando(Red), Hechos, Memoria0-Rete0-a(0, 0, 0, 0),
          _-_-Cuenta).

%!  entrar_contando(+Red, +Hecho, +Estado0, -Estado) is det.
%
%   Estado0 y Estado son términos Memoria-Rete-Cuenta. Hecho entra en la
%   memoria y, si no estaba, en la red; la Cuenta suma sus activaciones.
entrar_contando(Red, Hecho, M0-R0-C0, M-R-C) :-
    afirmar(Hecho, M0, M),
    M0 = mt(Reloj0, _),
    M = mt(Sello, _),
    (   Sello > Reloj0
    ->  R0 = rete(Alfas0, Betas0, Conjunto),
        entrar_alfa(mas, Sello, Hecho, Red, Alfas0, Alfas, Entradas),
        Red = red(_, Info, Nodos, _),
        findall(B-Paso,
                ( member(A-Paso, Entradas),
                  get_assoc(A, Info, a(_, Sucesores)),
                  member(B, Sucesores) ),
                Activaciones0),
        sort(1, @>=, Activaciones0, Activaciones),
        foldl(derecha_contando(Sello, Red), Activaciones,
              rete(Alfas, Betas0, Conjunto)-C0, R-C1),
        contar_izquierda(Nodos, R0, R, C1, C)
    ;   R = R0,
        C = C0
    ).

%!  derecha_contando(+Sello:integer, +Red, +Activacion, +Estado0,
%!                   -Estado) is det.
%
%   Estado0 y Estado son pares Rete-Cuenta. Cuenta la activación por la
%   derecha, y si es nula, y la ejecuta con activar_derecha/6.
derecha_contando(Sello, Red, Nodo-Paso, Rete0-a(D0, DN0, I, IN),
                 Rete-a(D, DN, I, IN)) :-
    Red = red(_, _, Nodos, _),
    get_assoc(Nodo, Nodos, beta(_, Padre, _, _, _)),
    Rete0 = rete(_, Betas, _),
    memoria_beta(Padre, Betas, Memoria),
    D is D0 + 1,
    (   empty_assoc(Memoria)
    ->  DN is DN0 + 1
    ;   DN = DN0
    ),
    activar_derecha(mas, Sello, Red, Nodo-Paso, Rete0, Rete).

%!  contar_izquierda(+Nodos, +Rete0, +Rete, +Cuenta0, -Cuenta) is det.
%
%   Cuenta suma a Cuenta0 una activación por la izquierda por cada token
%   que entró o salió de un nodo y cada hijo de unión de ese nodo, y una
%   nula si la memoria alfa del hijo está vacía.
contar_izquierda(Nodos, Rete0, Rete, a(D, DN, I0, IN0), a(D, DN, I, IN)) :-
    Rete = rete(Alfas, _, _),
    findall(Cambios-Hijos,
            ( gen_assoc(B, Nodos, beta(_, _, _, Hijos, _)),
              cambios_de(B, Rete0, Rete, Cambios) ),
            Pares),
    foldl(sumar_hijos(Nodos, Alfas), Pares, I0-IN0, I-IN).

%!  cambios_de(+B:integer, +Rete0, +Rete, -Cambios:integer) is det.
%
%   Cambios es la cantidad de tokens que entraron o salieron del nodo B.
cambios_de(B, Rete0, Rete, Cambios) :-
    tokens(B, Rete0, T0),
    tokens(B, Rete, T),
    msort(T0, S0),
    msort(T, S),
    ord_subtract(S, S0, Entraron),
    ord_subtract(S0, S, Salieron),
    length(Entraron, E),
    length(Salieron, Sa),
    Cambios is E + Sa.

%!  sumar_hijos(+Nodos, +Alfas, +Par, +Cuenta0, -Cuenta) is det.
%
%   Par es Cambios-Hijos: cada hijo de unión recibe Cambios activaciones,
%   nulas si su memoria alfa está vacía.
sumar_hijos(Nodos, Alfas, Cambios-Hijos, I0-N0, I-N) :-
    foldl(sumar_hijo(Nodos, Alfas, Cambios), Hijos, I0-N0, I-N).

%!  sumar_hijo(+Nodos, +Alfas, +Cambios:integer, +Hijo:integer,
%!             +Cuenta0, -Cuenta) is det.
%
%   Suma las activaciones del Hijo, si es un nodo de unión.
sumar_hijo(Nodos, Alfas, Cambios, Hijo, I0-N0, I-N) :-
    get_assoc(Hijo, Nodos, beta(Tipo, _, _, _, _)),
    (   Tipo = union(A)
    ->  I is I0 + Cambios,
        get_assoc(A, Alfas, Memoria),
        (   empty_assoc(Memoria)
        ->  N is N0 + Cambios
        ;   N = N0
        )
    ;   I = I0,
        N = N0
    ).

%!  nodos_vacios(+Programa, +Fuente, -Cuenta) is det.
%
%   Cuenta es n(Uniones, PadreVacio, AlfaVacia, Ambos): después de cargar
%   los hechos de la Fuente, la cantidad de nodos de unión de la red de
%   red_de/2, de los que tienen el padre sin tokens, de los que tienen la
%   memoria alfa vacía y de los que tienen las dos cosas.
nodos_vacios(Programa, Fuente, n(U, P, A, Ambos)) :-
    hechos_de(Fuente, Hechos),
    red_de(Programa, Red),
    cargar(Red, Hechos, _, Rete),
    Red = red(_, _, Nodos, _),
    Rete = rete(Alfas, Betas, _),
    findall(PV-AV,
            ( gen_assoc(_, Nodos, beta(union(Al), Padre, _, _, _)),
              vacio_padre(Padre, Betas, PV),
              get_assoc(Al, Alfas, MA),
              vacio(MA, AV) ),
            Pares),
    length(Pares, U),
    aggregate_all(count, member(si-_, Pares), P),
    aggregate_all(count, member(_-si, Pares), A),
    aggregate_all(count, member(si-si, Pares), Ambos).

%!  vacio_padre(+Padre:integer, +Betas, -Vacio) is det.
%
%   Vacio es si cuando el nodo Padre no tiene tokens, y no si tiene.
vacio_padre(Padre, Betas, Vacio) :-
    memoria_beta(Padre, Betas, Memoria),
    vacio(Memoria, Vacio).

%!  vacio(+Tabla, -Vacio) is det.
%
%   Vacio es si cuando la Tabla está vacía, y no si tiene algo.
vacio(Tabla, Vacio) :-
    (   empty_assoc(Tabla)
    ->  Vacio = si
    ;   Vacio = no
    ).
