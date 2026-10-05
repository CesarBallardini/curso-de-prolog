:- encoding(utf8).

% Capítulo 80 - Versión 1: del dibujo a sus uniones.
%
% Las uniones no se escriben a mano: se calculan con las coordenadas. Las
% líneas de cada punto se ordenan en el sentido de las agujas del reloj por
% su ángulo, y el tipo de unión sale de los ángulos entre líneas
% consecutivas, con el producto vectorial de enteros: dos líneas opuestas
% forman la barra de una te, un ángulo mayor que 180 grados hace una flecha,
% y tres ángulos menores que 180, una horquilla.
%
% Cada línea A-B se guarda con A antes que B en el orden de los átomos, y su
% etiqueta es la que se ve desde A. La unión de B la ve invertida.
%
% solo-local: carga figuras.pl y catalogo.pl.
%
%?- uniones(cubo, Us).
%?- contorno(cubo, C).
%?- problema(cubo, borde, Lineas, Uniones).

:- ensure_loaded(figuras).
:- ensure_loaded(catalogo).

%!  conectados(?F, ?A, ?B) is nondet.
%
%   En el dibujo F hay una línea entre A y B, en cualquier sentido.
conectados(F, A, B) :-
    (   segmento(F, A, B)
    ;   segmento(F, B, A)
    ).

%!  coordenadas(+F, +P, -X:integer, -Y:integer) is semidet.
%
%   (X, Y) son las coordenadas del punto P del dibujo F. Un punto tiene una
%   sola posición, así que la búsqueda termina en la primera.
coordenadas(F, P, X, Y) :-
    once(punto(F, P, X, Y)).

%!  vecinos(+F, +P, -Vs:list) is det.
%
%   Vs son los puntos unidos a P por una línea, en el sentido de las agujas
%   del reloj: de mayor a menor ángulo.
vecinos(F, P, Vs) :-
    coordenadas(F, P, X, Y),
    findall(Angulo-Q,
            ( conectados(F, P, Q),
              coordenadas(F, Q, XQ, YQ),
              Angulo is atan2(YQ - Y, XQ - X) ),
            Pares),
    sort(1, @>=, Pares, Ordenados),
    pairs_values(Ordenados, Vs).

%!  vector(+F, +P, +Q, -V) is det.
%
%   V es el vector X-Y que va del punto P al punto Q.
vector(F, P, Q, DX-DY) :-
    coordenadas(F, P, X1, Y1),
    coordenadas(F, Q, X2, Y2),
    DX is X2 - X1,
    DY is Y2 - Y1.

%!  giro(+F, +P, +Q, +R, -Giro) is det.
%
%   Giro es el producto vectorial de los vectores de P a Q y de P a R:
%   negativo si R está a menos de 180 grados de Q en el sentido de las
%   agujas del reloj, positivo si está a más, y cero si están alineados.
giro(F, P, Q, R, Giro) :-
    vector(F, P, Q, X1-Y1),
    vector(F, P, R, X2-Y2),
    Giro is X1 * Y2 - Y1 * X2.

%!  opuestos(+F, +P, +Q, +R) is semidet.
%
%   Las líneas de P a Q y de P a R siguen la misma recta en sentidos
%   contrarios.
opuestos(F, P, Q, R) :-
    giro(F, P, Q, R, 0),
    vector(F, P, Q, X1-Y1),
    vector(F, P, R, X2-Y2),
    X1 * X2 + Y1 * Y2 < 0.

%!  union(+F, +P, -Tipo, -Lineas:list) is det.
%
%   P es una unión de Tipo, y Lineas son sus vecinos en el orden del
%   catálogo. Produce un error si P no tiene dos o tres líneas.
union(F, P, Tipo, Lineas) :-
    vecinos(F, P, Vs),
    (   tipo(Vs, F, P, Tipo, Lineas)
    ->  true
    ;   length(Vs, N),
        domain_error(union_de_dos_o_tres_lineas, P-N)
    ).

%!  tipo(+Vs:list, +F, +P, -Tipo, -Lineas:list) is semidet.
%
%   Clasifica la unión P por sus vecinos Vs, ya en el sentido de las agujas
%   del reloj, y rota la lista al orden del catálogo. Falla si P no tiene
%   dos o tres líneas, o si sus dos líneas están alineadas.
tipo(Vs, F, P, Tipo, Lineas) :-
    length(Vs, N),
    tipo_segun(N, Vs, F, P, Tipo, Lineas).

%!  tipo_segun(+N:integer, +Vs:list, +F, +P, -Tipo, -Lineas:list)
%!      is semidet.
%
%   Clasifica una unión de N líneas.
tipo_segun(2, [Q, R], F, P, ele, Lineas) :-
    giro(F, P, Q, R, G),
    G =\= 0,
    (   G < 0
    ->  Lineas = [Q, R]
    ;   Lineas = [R, Q]
    ).
tipo_segun(3, [Q1, Q2, Q3], F, P, Tipo, Lineas) :-
    rotaciones([Q1, Q2, Q3], Rs),
    (   member([A, B, C], Rs),
        opuestos(F, P, A, B)
    ->  Tipo = te,
        Lineas = [A, B, C]
    ;   member([A, B, C], Rs),
        giro(F, P, C, A, G),
        G > 0
    ->  Tipo = flecha,
        Lineas = [A, B, C]
    ;   Tipo = horquilla,
        Lineas = [Q1, Q2, Q3]
    ).

%!  rotaciones(+L:list, -Rs:list) is det.
%
%   Rs son las rotaciones de la lista de tres elementos L.
rotaciones([A, B, C], [[A, B, C], [B, C, A], [C, A, B]]).

%!  uniones(+F, -Us:list) is det.
%
%   Us son las uniones del dibujo F, como u(P, Tipo, Lineas), en el orden
%   de los nombres de los puntos.
uniones(F, Us) :-
    findall(P, punto(F, P, _, _), Ps0),
    sort(Ps0, Ps),
    maplist(union_de(F), Ps, Us).

%!  union_de(+F, +P, -U) is det.
%
%   U es el término u(P, Tipo, Lineas) de la unión P.
union_de(F, P, u(P, Tipo, Lineas)) :-
    union(F, P, Tipo, Lineas).

%!  lineas(+F, -Ls:list) is det.
%
%   Ls son las líneas del dibujo F, como A-B con A antes que B, ordenadas.
lineas(F, Ls) :-
    findall(L, ( segmento(F, A, B), linea(A, B, L) ), Ls0),
    sort(Ls0, Ls).

%!  linea(+A, +B, -L) is det.
%
%   L es la línea entre A y B escrita con el menor de los dos primero.
linea(A, B, L) :-
    (   A @< B
    ->  L = A-B
    ;   L = B-A
    ).

%!  contorno(+F, -Ciclo:list) is det.
%
%   Ciclo son los puntos del borde exterior del dibujo F, recorrido en el
%   sentido de las agujas del reloj: el fondo queda a la izquierda y el
%   dibujo a la derecha. Empieza en el punto de más a la izquierda (el de
%   más abajo, si hay varios) y sigue por la línea más alta.
contorno(F, [P|Ciclo]) :-
    findall(X-Y-Q, punto(F, Q, X, Y), Ps),
    sort(Ps, [_-_-P|_]),
    vecinos(F, P, [Q|_]),
    recorrer(F, P, Q, P, Q, Ciclo).

%!  recorrer(+F, +U, +V, +P0, +Q0, -Ciclo:list) is det.
%
%   Ciclo son los puntos desde V hasta volver a recorrer la línea P0-Q0.
%   Al llegar a V desde U, sigue por la línea que viene después de U en el
%   sentido de las agujas del reloj, la que deja el fondo a la izquierda.
recorrer(F, U, V, P0, Q0, Ciclo) :-
    vecinos(F, V, Vs),
    siguiente(Vs, U, W),
    (   V == P0,
        W == Q0
    ->  Ciclo = []
    ;   Ciclo = [V|Resto],
        recorrer(F, V, W, P0, Q0, Resto)
    ).

%!  siguiente(+Vs:list, +U, -W) is det.
%
%   W es el elemento que sigue a U en la lista circular Vs.
siguiente(Vs, U, W) :-
    append(_, [U|Despues], Vs),
    !,
    (   Despues = [W|_]
    ->  true
    ;   Vs = [W|_]
    ).

%!  fijas(+F, +Modo, -Fijas:list) is det.
%
%   Fijas son las etiquetas que el Modo impone de antemano, como pares
%   Linea-Etiqueta. Con sin_borde no hay ninguna. Con borde, cada línea del
%   contorno es un contorno con el cuerpo adentro: recorrida en el sentido
%   de las agujas del reloj, el cuerpo queda a la derecha.
fijas(F, Modo, Fijas) :-
    fijas_segun(Modo, F, Fijas).

%!  fijas_segun(+Modo, +F, -Fijas:list) is det.
%
%   Fijas son las etiquetas que el Modo impone en el dibujo F.
fijas_segun(sin_borde, _, []).
fijas_segun(borde, F, Fijas) :-
    contorno(F, [P|Ps]),
    append([P|Ps], [P], Ciclo),
    pares_consecutivos(Ciclo, Pares),
    maplist(borde_derecha, Pares, Fijas0),
    sort(Fijas0, Fijas).

%!  pares_consecutivos(+L:list, -Pares:list) is det.
%
%   Pares son los pares A-B de elementos consecutivos de L.
pares_consecutivos([A|Resto], Pares) :-
    pares_desde(Resto, A, Pares).

%!  pares_desde(+L:list, +A, -Pares:list) is det.
%
%   Pares son los pares de elementos consecutivos de [A|L].
pares_desde([], _, []).
pares_desde([B|Resto], A, [A-B|Pares]) :-
    pares_desde(Resto, B, Pares).

%!  borde_derecha(+Par, -Fija) is det.
%
%   Fija es la etiqueta de la línea A-B con el cuerpo a la derecha al ir de
%   A a B, vista desde el primero de los dos en el orden de los átomos.
borde_derecha(A-B, L-E) :-
    linea(A, B, L),
    (   A @< B
    ->  E = der
    ;   E = izq
    ).

%!  problema(+F, +Modo, -Lineas:list, -Uniones:list) is semidet.
%
%   Lineas son pares Linea-E con una variable E por línea, ligada si el
%   Modo la fija; Uniones son términos u(P, Tipo, Vistas), donde cada vista
%   es directa(E) o inversa(E) según desde qué punta ve la unión a la
%   línea. Falla si el Modo fija dos etiquetas distintas a una línea.
problema(F, Modo, Lineas, Uniones) :-
    lineas(F, Ls),
    pairs_keys_values(Lineas, Ls, _),
    fijas(F, Modo, Fijas),
    maplist(fijar(Lineas), Fijas),
    uniones(F, Us),
    maplist(con_vistas(Lineas), Us, Uniones).

%!  fijar(+Lineas:list, +Fija) is semidet.
%
%   La línea de Fija tiene en Lineas la etiqueta de Fija.
fijar(Lineas, L-E) :-
    memberchk(L-E, Lineas).

%!  con_vistas(+Lineas:list, +U, -V) is det.
%
%   V es la unión U con cada vecino reemplazado por la vista de la
%   variable de su línea.
con_vistas(Lineas, u(P, Tipo, Vecinos), u(P, Tipo, Vistas)) :-
    maplist(vista_de(Lineas, P), Vecinos, Vistas).

%!  vista_de(+Lineas:list, +P, +Q, -Vista) is det.
%
%   Vista es directa(E) si P es la primera punta de la línea P-Q, e
%   inversa(E) si es la segunda; E es la variable de la línea en Lineas.
vista_de(Lineas, P, Q, Vista) :-
    linea(P, Q, L),
    memberchk(L-E, Lineas),
    (   P @< Q
    ->  Vista = directa(E)
    ;   Vista = inversa(E)
    ).

%!  vista(?Vista, ?Local) is nondet.
%
%   Local es la etiqueta de la línea vista desde la unión: la misma de la
%   línea si la vista es directa, la inversa si no.
vista(directa(E), E).
vista(inversa(E), Local) :-
    inversa(Local, E).
