:- encoding(utf8).

% Capítulo 74 - Soluciones de los ejercicios.
%
% Carga mejoras.pl (con él, etapas.pl, macros.pl, vista.pl y cubo.pl) y
% descubrir.pl, sin modificarlos.
%
% solo-local: carga otros archivos.
%
%?- tipo_efecto("R U R' U'", Esquinas, Aristas).
%?- leer_notacion_rep("(R' D' R D)2 U", Ms).
%?- aristas_descubiertas(Probadas, N).

:- ensure_loaded(mejoras).
:- ensure_loaded(descubrir).

% --- Ejercicio 2: los giros de las capas del medio -------------------------

%!  destino_capa(+Eje, +K:integer, +I:integer, -J:integer) is det.
%
%   Al girar la capa de coordenada K en la dirección de la cara Eje, la
%   casilla I pasa al lugar de la casilla J.
destino_capa(Eje, K, I, J) :-
    cara(Eje, _, E),
    casilla(I, _, P, N),
    E = p(A, B, C),
    P = p(X, Y, Z),
    (   A * X + B * Y + C * Z =:= K
    ->  rotar(E, P, P1),
        rotar(E, N, N1),
        casilla(J, _, P1, N1)
    ;   J = I
    ).

%!  capa_calculada(+Eje, +Ks:list(integer), -Antes, -Despues) is det.
%
%   Antes y Despues son términos c/54 con las mismas variables: Despues
%   es Antes con las capas de coordenadas Ks giradas alrededor de Eje.
capa_calculada(Eje, Ks, Antes, Despues) :-
    findall(J, ( between(1, 54, I),
                 destino_capas(Eje, Ks, I, J) ),
            Destinos),
    length(Vs, 54),
    Antes =.. [c|Vs],
    pairs_keys_values(Pares, Destinos, Vs),
    keysort(Pares, Ordenados),
    pairs_values(Ordenados, Ws),
    Despues =.. [c|Ws].

%!  destino_capas(+Eje, +Ks:list(integer), +I:integer, -J:integer) is det.
%
%   J es el destino de la casilla I si su capa está en Ks; si no, I.
destino_capas(Eje, Ks, I, J) :-
    casilla(I, _, p(X, Y, Z), _),
    cara(Eje, _, p(A, B, C)),
    K is A * X + B * Y + C * Z,
    (   memberchk(K, Ks)
    ->  destino_capa(Eje, K, I, J)
    ;   J = I
    ).

%!  term_expansion(+Termino, -Hechos:list) is semidet.
%
%   generar_capas se reemplaza por un hecho giro_medio/3 y un hecho
%   rotacion/3 por cada eje u, r y f.
term_expansion(generar_capas, Hechos) :-
    findall(giro_medio(Eje, A, D),
            ( member(Eje, [u, r, f]), capa_calculada(Eje, [0], A, D) ),
            Medios),
    findall(rotacion(Eje, A, D),
            ( member(Eje, [u, r, f]), capa_calculada(Eje, [-1, 0, 1], A, D) ),
            Rotaciones),
    append(Medios, Rotaciones, Hechos).

generar_capas.

%!  caras_uniformes(+Cubo) is semidet.
%
%   Las nueve casillas de cada cara de Cubo tienen el mismo color.
caras_uniformes(Cubo) :-
    forall(between(0, 5, K),
           ( Primera is 9 * K + 1,
             arg(Primera, Cubo, Color),
             forall(between(1, 9, D),
                    ( I is 9 * K + D, arg(I, Cubo, Color) )) )).

%!  tres_capas(+Cara, +Opuesta) is semidet.
%
%   Girar Cara, la capa del medio de su eje y Opuesta en sentido inverso
%   da la rotación del cubo entero sobre el eje de Cara.
tres_capas(Cara, Opuesta) :-
    resuelto(C0),
    mover(Cara, C0, C1),
    giro_medio(Cara, C1, C2),
    mover(-Opuesta, C2, C3),
    rotacion(Cara, C0, R),
    C3 == R,
    caras_uniformes(R).

% --- Ejercicio 3: repeticiones entre paréntesis ------------------------------

%!  leer_notacion_rep(+Texto, -Movimientos:list) is semidet.
%
%   Como leer_notacion/2, pero acepta además una secuencia entre
%   paréntesis seguida de la cantidad de repeticiones: "(R U)3".
leer_notacion_rep(Texto, Movimientos) :-
    string_codes(Texto, Codigos),
    phrase(grupos(Movimientos), Codigos).

%!  grupos(-Ms:list)// is det.
%
%   Ms son los movimientos de una sucesión de grupos separados por
%   blancos: giros sueltos o secuencias entre paréntesis con repeticiones.
grupos(Ms) -->
    blancos,
    grupo(G),
    !,
    grupos(Resto),
    { append(G, Resto, Ms) }.
grupos([]) --> blancos.

%!  grupo(-Ms:list)// is semidet.
%
%   Ms son los movimientos de un grupo: una secuencia entre paréntesis,
%   repetida tantas veces como dice el dígito que la sigue, o un giro
%   escrito en la notación de Singmaster.
grupo(Ms) -->
    "(", grupos(Interior), ")", !,
    veces(N),
    { length(Copias, N),
      maplist(=(Interior), Copias),
      append(Copias, Ms) }.
grupo(Ms) --> escrito(Ms).

%!  veces(-N:integer)// is det.
%
%   N es el dígito, de 1 a 9, que sigue a un paréntesis; 1 si no hay
%   dígito.
veces(N) --> [C], { code_type(C, digit(N)), N > 0 }, !.
veces(1) --> [].

% --- Ejercicio 4: esquinas y aristas ----------------------------------------

%!  tipo_efecto(+Texto, -Esquinas:integer, -Aristas:integer) is semidet.
%
%   Esquinas y Aristas son las esquinas y las aristas que mueve la
%   secuencia de Texto.
tipo_efecto(Texto, Esquinas, Aristas) :-
    efecto_de(Texto, Piezas),
    aggregate_all(count, ( member(P, Piezas), atom_length(P, 3) ), Esquinas),
    aggregate_all(count, ( member(P, Piezas), atom_length(P, 2) ), Aristas).

%!  capa_de_abajo_movida(+Texto) is semidet.
%
%   La secuencia de Texto mueve alguna pieza de la capa de abajo.
capa_de_abajo_movida(Texto) :-
    efecto_de(Texto, Piezas),
    member(P, Piezas),
    sub_atom(P, 0, 1, _, 'D'),
    !.

% --- Ejercicio 5: leer el cubo desplegado -------------------------------------

%!  leer_red(+Lineas:list(string), -Cubo) is semidet.
%
%   Cubo es el cubo que red/2 escribe como Lineas. Falla si Lineas no
%   tienen la forma de red/2.
leer_red(Lineas, Cubo) :-
    length(Lineas, 9),
    functor(Cubo, c, 54),
    foldl(leer_linea(Cubo), Lineas, 0, 9).

%!  leer_linea(+Cubo, +Linea:string, +F0:integer, -F:integer) is semidet.
%
%   La línea F0 del cubo desplegado liga las casillas que muestra; F es
%   F0 + 1. Las líneas 0 a 2 son la cara u, 3 a 5 las caras del medio y
%   6 a 8 la cara d.
leer_linea(Cubo, Linea, F0, F) :-
    split_string(Linea, " ", " ", Palabras0),
    exclude(==(""), Palabras0, Palabras),
    Fila is F0 mod 3,
    (   F0 < 3
    ->  Caras = [u]
    ;   F0 < 6
    ->  Caras = [l, f, r, b]
    ;   Caras = [d]
    ),
    length(Caras, NC),
    NL is 3 * NC,
    length(Palabras, NL),
    ligar_filas(Caras, Palabras, Cubo, Fila),
    F is F0 + 1.

%!  ligar_filas(+Caras:list, +Palabras:list, +Cubo, +Fila:integer) is det.
%
%   Liga la fila Fila de cada una de Caras con tres de Palabras.
ligar_filas([], [], _, _).
ligar_filas([Cara|Caras], [A, B, C|Palabras], Cubo, Fila) :-
    cara(Cara, K, _),
    foldl(ligar_casilla(Cubo, K, Fila), [A, B, C], 0, _),
    ligar_filas(Caras, Palabras, Cubo, Fila).

%!  ligar_casilla(+Cubo, +K, +Fila, +Letra:string, +C0, -C) is semidet.
%
%   La casilla de la cara K en Fila y la columna C0 tiene el color de
%   Letra.
ligar_casilla(Cubo, K, Fila, Letra, C0, C) :-
    string_lower(Letra, Minuscula),
    atom_string(Color, Minuscula),
    cara(Color, _, _),
    I is 9 * K + 3 * Fila + C0 + 1,
    arg(I, Cubo, Color),
    C is C0 + 1.

% --- Ejercicio 6: el cubo en colores ------------------------------------------

% fondo(Cara, Codigo): el código ANSI del color de fondo de Cara.
fondo(u, 47).
fondo(d, 43).
fondo(f, 42).
fondo(b, 44).
fondo(r, 41).
fondo(l, 45).

%!  red_color(+Cubo, -Lineas:list(string)) is det.
%
%   Lineas es el cubo desplegado con cada casilla escrita como dos
%   blancos sobre el color de su cara.
red_color(Cubo, Lineas) :-
    findall(L, ( between(0, 2, F), fila_color_sola(Cubo, u, F, L) ), Arriba),
    findall(L, ( between(0, 2, F), fila_color_media(Cubo, F, L) ), Medio),
    findall(L, ( between(0, 2, F), fila_color_sola(Cubo, d, F, L) ), Abajo),
    append([Arriba, Medio, Abajo], Lineas).

%!  fila_color_sola(+Cubo, +Cara, +F, -Linea:string) is det.
%
%   Linea es la fila F de Cara, corrida seis columnas.
fila_color_sola(Cubo, Cara, F, Linea) :-
    fila_color(Cubo, Cara, F, Fila),
    string_concat("      ", Fila, Linea).

%!  fila_color_media(+Cubo, +F, -Linea:string) is det.
%
%   Linea es la fila F de las caras l, f, r y b.
fila_color_media(Cubo, F, Linea) :-
    maplist(fila_color(Cubo), [l, f, r, b], [F, F, F, F], Filas),
    atomic_list_concat(Filas, Atomo),
    atom_string(Atomo, Linea).

%!  fila_color(+Cubo, +Cara, +F, -Fila:string) is det.
%
%   Fila son las tres casillas de la fila F de Cara, con sus colores, y
%   la secuencia que vuelve al color normal.
fila_color(Cubo, Cara, F, Fila) :-
    cara(Cara, K, _),
    findall(S,
            ( between(0, 2, C),
              I is 9 * K + 3 * F + C + 1,
              arg(I, Cubo, Color),
              fondo(Color, Codigo),
              format(string(S), "\e[~dm  ", [Codigo]) ),
            Casillas),
    atomic_list_concat(Casillas, A),
    string_concat(A, "\e[0m", Fila).

%!  mostrar_color(+Cubo) is det.
%
%   Escribe Cubo desplegado, en colores.
mostrar_color(Cubo) :-
    red_color(Cubo, Lineas),
    forall(member(L, Lineas), writeln(L)).

% --- Ejercicio 7: orientar es conjugar con una rotación ---

%!  conjugada_por_rotacion(+Ms:list, -Antes, -Despues) is det.
%
%   Antes-Despues es la macro de deshacer la rotación del cubo entero
%   sobre el eje vertical, aplicar Ms y volver a rotar: rotacion(u, C1,
%   Antes) lleva C1 a Antes, así que leído en sentido inverso deshace la
%   rotación.
conjugada_por_rotacion(Ms, Antes, Despues) :-
    rotacion(u, C1, Antes),
    aplicar(Ms, C1, C2),
    rotacion(u, C2, Despues).

%!  orientar_es_conjugar(+Ms:list) is semidet.
%
%   orientar(1, Ms, Ms1) y Ms conjugada por la rotación del cubo sobre
%   el eje vertical son la misma macro.
orientar_es_conjugar(Ms) :-
    orientar(1, Ms, Ms1),
    compilar(Ms1, A-D1),
    conjugada_por_rotacion(Ms, A, D2),
    D1 == D2.

% --- Ejercicio 8: el peso de cada etapa ---

%!  por_etapa(+Semillas:integer, -Tabla:list) is det.
%
%   Tabla tiene, por cada etapa, E-media(M)-maximo(X): la media y el
%   máximo de cuartos de vuelta que usa resolver/2 en esa etapa sobre las
%   mezclas de 25 giros de las semillas 1 a Semillas.
por_etapa(Semillas, Tabla) :-
    findall(E-N,
            ( between(1, Semillas, S),
              mezcla(S, 25, Ms),
              resuelto(C),
              aplicar(Ms, C, C1),
              resolver(C1, Pasos),
              etapa(E, _),
              aggregate_all(sum(L), ( member(paso(E, _, G), Pasos),
                                      length(G, L) ), N) ),
            Pares),
    findall(E-media(M)-maximo(X),
            ( etapa(E, _),
              findall(N, member(E-N, Pares), Ns),
              sum_list(Ns, Suma),
              M is Suma / Semillas,
              max_list(Ns, X) ),
            Tabla).

% --- Ejercicio 9: sin dos giros de U seguidos ---------------------------------

%!  colocar_podado(+Etapa, +Cubo, +Criterio, -Movimientos:list, -Cubo1)
%!      is det.
%
%   Como colocar/5, pero la búsqueda descarta las secuencias con dos
%   candidatos seguidos que solo giran U.
colocar_podado(Etapa, Cubo, Criterio, Movimientos, Cubo1) :-
    colocar_propio(si, Etapa, Cubo, Criterio, Movimientos, Cubo1).

%!  colocar_sin_poda(+Etapa, +Cubo, +Criterio, -Movimientos:list, -Cubo1)
%!      is det.
%
%   La misma búsqueda que colocar_podado/5, sin la poda: la referencia
%   para medirla.
colocar_sin_poda(Etapa, Cubo, Criterio, Movimientos, Cubo1) :-
    colocar_propio(no, Etapa, Cubo, Criterio, Movimientos, Cubo1).

%!  colocar_propio(+Podar, +Etapa, +Cubo, +Criterio, -Movimientos:list,
%!                 -Cubo1) is det.
%
%   Profundización iterativa sobre los candidatos de Etapa; con Podar =
%   si, sin dos candidatos de solo U seguidos.
colocar_propio(Podar, Etapa, Cubo, Criterio, Movimientos, Cubo1) :-
    length(Plan, _),
    podada(Plan, Podar, Etapa, no, Cubo, Cubo1),
    Cubo1 = Criterio,
    !,
    append(Plan, Movimientos).

%!  podada(?Plan:list, +Podar, +Etapa, +AnteriorU, +Cubo, -Cubo1)
%!      is nondet.
%
%   Cubo1 es Cubo con los candidatos de Plan aplicados; con Podar = si,
%   sin dos candidatos de solo U seguidos. AnteriorU dice si el candidato
%   anterior era de solo U.
podada([], _, _, _, Cubo, Cubo).
podada([Ms|Plan], Podar, Etapa, AnteriorU, Cubo0, Cubo) :-
    candidato(Etapa, Ms, Cubo0, Cubo1),
    (   solo_u(Ms)
    ->  \+ ( Podar == si, AnteriorU == si ),
        EsU = si
    ;   EsU = no
    ),
    podada(Plan, Podar, Etapa, EsU, Cubo1, Cubo).

%!  solo_u(+Ms:list) is semidet.
%
%   Ms solo gira la cara u.
solo_u(Ms) :-
    forall(member(M, Ms), cara_de(M, u)).

%!  resolver_con(+Colocar, +Cubo, -Pasos:list) is det.
%
%   Como resolver/2, colocando cada pieza con Colocar, colocar o
%   colocar_podado.
resolver_con(Colocar, Cubo, Pasos) :-
    findall(E-P, ( etapa(E, Ps), member(P, Ps) ), Plan),
    foldl(colocar_una(Colocar), Plan, Cubo-[]-Pasos, _-_-[]).

%!  colocar_una(+Colocar, +EP, +Estado0, -Estado) is det.
%
%   Coloca la pieza P de la etapa E; el estado es
%   Cubo-Colocadas-Pasos, con Pasos como lista abierta.
colocar_una(Colocar, E-P, C0-Col0-[paso(E, P, Ms)|Pasos],
            C1-[P|Col0]-Pasos) :-
    criterio([P|Col0], Criterio),
    call(Colocar, E, C0, Criterio, Ms, C1).

%!  inferencias_resolver(+Colocar, +Semillas:integer, -Inferencias) is det.
%
%   Inferencias es el total de inferencias de resolver_con/3 sobre las
%   mezclas de 25 giros de las semillas 1 a Semillas.
inferencias_resolver(Colocar, Semillas, Inferencias) :-
    findall(C1, ( between(1, Semillas, S),
                  mezcla(S, 25, Ms),
                  resuelto(C),
                  aplicar(Ms, C, C1) ), Cubos),
    statistics(inferences, I0),
    forall(member(C1, Cubos), resolver_con(Colocar, C1, _)),
    statistics(inferences, I1),
    Inferencias is I1 - I0.

% --- Ejercicio 10: tres aristas de arriba ------------------------------------

%!  aristas_descubiertas(-Probadas:integer, -N:integer) is det.
%
%   N es la cantidad de conmutadores de A, de 1 a 3 cuartos de vuelta, con
%   un cuarto de vuelta de U, que mueven exactamente tres aristas de la
%   cara de arriba y nada más; Probadas, los conmutadores examinados.
aristas_descubiertas(Probadas, N) :-
    findall(Sirve,
            ( between(1, 3, L),
              length(A, L),
              reducida(A),
              member(B, [u, -u]),
              conmutador(A, [B], S),
              compilar(S, M),
              efecto(M, Piezas),
              (   tres_aristas_de_arriba(Piezas)
              ->  Sirve = si
              ;   Sirve = no
              ) ),
            Todas),
    length(Todas, Probadas),
    aggregate_all(count, member(si, Todas), N).

%!  tres_aristas_de_arriba(+Piezas:list(atom)) is semidet.
%
%   Piezas son tres aristas de la cara de arriba.
tres_aristas_de_arriba(Piezas) :-
    length(Piezas, 3),
    forall(member(P, Piezas),
           ( atom_length(P, 2),
             sub_atom(P, 0, 1, _, 'U') )).

% --- Ejercicio 11: recordar lo aprendido ---

:- dynamic aprendido/4.

%!  colocar_aprendiendo(+Etapa, +Cubo, +Criterio, -Movimientos:list,
%!                      -Cubo1) is det.
%
%   Como colocar/5, con los candidatos de Etapa más los aprendidos. Si
%   la secuencia hallada tiene tres o más candidatos, se agrega compilada
%   como un candidato aprendido de Etapa.
colocar_aprendiendo(Etapa, Cubo, Criterio, Movimientos, Cubo1) :-
    length(Plan, _),
    con_aprendidos(Plan, Etapa, Cubo, Cubo1),
    Cubo1 = Criterio,
    !,
    append(Plan, Movimientos),
    length(Plan, L),
    (   L >= 3
    ->  compilar(Movimientos, A-D),
        assertz(aprendido(Etapa, Movimientos, A, D))
    ;   true
    ).

%!  con_aprendidos(?Plan:list, +Etapa, +Cubo, -Cubo1) is nondet.
%
%   Cubo1 es Cubo con los candidatos de Plan aplicados; cada uno es un
%   candidato de Etapa o uno aprendido.
con_aprendidos([], _, Cubo, Cubo).
con_aprendidos([Ms|Plan], Etapa, Cubo0, Cubo) :-
    (   candidato(Etapa, Ms, Cubo0, Cubo1)
    ;   aprendido(Etapa, Ms, Cubo0, Cubo1)
    ),
    con_aprendidos(Plan, Etapa, Cubo1, Cubo).

%!  aprender(+Semillas:integer, -Aprendidos:integer, -Giros:integer,
%!           -Inferencias:integer) is det.
%
%   Resuelve en orden las mezclas de 25 giros de las semillas 1 a
%   Semillas, aprendiendo. Aprendidos es la cantidad de candidatos nuevos,
%   Giros el total de cuartos de vuelta e Inferencias el total de
%   inferencias.
aprender(Semillas, Aprendidos, Giros, Inferencias) :-
    retractall(aprendido(_, _, _, _)),
    statistics(inferences, I0),
    findall(N, ( between(1, Semillas, S),
                 mezcla(S, 25, Ms),
                 resuelto(C),
                 aplicar(Ms, C, C1),
                 resolver_con(colocar_aprendiendo, C1, Pasos),
                 giros(Pasos, G),
                 length(G, N) ), Ns),
    statistics(inferences, I1),
    Inferencias is I1 - I0,
    sum_list(Ns, Giros),
    aggregate_all(count, aprendido(_, _, _, _), Aprendidos).
