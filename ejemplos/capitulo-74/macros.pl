:- encoding(utf8).

% Capítulo 74 - Versión 4: los macrooperadores.
%
% Una secuencia de giros aplicada a un cubo cuyas 54 casillas son
% variables libres da un par Antes-Despues con las mismas variables en otro
% orden: es la secuencia entera convertida en una sola unificación, igual
% que un giro. compilar/2 construye ese par; el término macro(Nombre,
% Texto) se reemplaza al cargar por un hecho macro/3 con el par ya
% construido. efecto/2 lee en el par qué piezas mueve la secuencia, sin
% aplicarla a ningún cubo: una pieza se mueve si alguna de sus casillas
% recibe una variable distinta de la suya.
%
% solo-local: carga vista.pl.
%
%?- efecto_de("R U R' U'", Piezas).
%?- efecto_macro(tres_esquinas, Piezas).
%?- conmutador([r], [u], S), escribir_notacion(S, T).
%?- inferencias(giro_esquina, 1000, EnLista, Compilada).

:- ensure_loaded(vista).

% --- Compilar una secuencia ------------------------------------------------

%!  compilar(+Movimientos:list, -Macro) is det.
%
%   Macro es Antes-Despues: dos términos c/54 con las mismas variables,
%   tales que Despues es Antes con Movimientos aplicados.
compilar(Movimientos, Antes-Despues) :-
    functor(Antes, c, 54),
    aplicar(Movimientos, Antes, Despues).

%!  term_expansion(+Termino, -Hechos:list) is semidet.
%
%   El término macro(Nombre, Texto) se reemplaza, al cargar, por el hecho
%   macro(Nombre, Antes, Despues), con la secuencia de Texto compilada, y
%   el hecho texto_macro(Nombre, Texto).
term_expansion(macro(Nombre, Texto),
               [macro(Nombre, Antes, Despues), texto_macro(Nombre, Texto)]) :-
    leer_notacion(Texto, Movimientos),
    compilar(Movimientos, Antes-Despues).

:- discontiguous
    macro/3,
    texto_macro/2.

% Macros de ejemplo, en la notación de Singmaster.
macro(conmutador_ru, "R U R' U'").
macro(tres_esquinas, "R U' L' U R' U' L U").
macro(sune, "R U R' U R U2 R'").
macro(giro_esquina, "R' D' R D R' D' R D").
macro(dos_esquinas, "R' D' R D R' D' R D U D' R' D R D' R' D R U'").

%!  usar(+Nombre, ?Antes, ?Despues) is semidet.
%
%   Despues es Antes con la macro Nombre aplicada: una unificación.
usar(Nombre, Antes, Despues) :-
    macro(Nombre, Antes, Despues).

% --- Construir secuencias ---------------------------------------------------

%!  conmutador(+A:list, +B:list, -S:list) is det.
%
%   S es A, B, la inversa de A y la inversa de B, en ese orden.
conmutador(A, B, S) :-
    inversa(A, IA),
    inversa(B, IB),
    append([A, B, IA, IB], S).

%!  conjugado(+A:list, +B:list, -S:list) is det.
%
%   S es A, B y la inversa de A: B hecho en otro lugar del cubo.
conjugado(A, B, S) :-
    inversa(A, IA),
    append([A, B, IA], S).

% --- Leer el efecto de una macro --------------------------------------------

%!  efecto(+Macro, -Piezas:list(atom)) is det.
%
%   Piezas son los nombres de las piezas que Macro, un par Antes-Despues,
%   cambia de lugar o de orientación.
efecto(Antes-Despues, Piezas) :-
    findall(Nombre,
            ( pieza(_, Nombre, Casillas),
              \+ quieta(Casillas, Antes, Despues) ),
            Piezas).

%!  efecto_de(+Texto, -Piezas:list(atom)) is semidet.
%
%   Piezas son las piezas que mueve la secuencia escrita en Texto, en la
%   notación. Falla si Texto no está en la notación.
efecto_de(Texto, Piezas) :-
    leer_notacion(Texto, Movimientos),
    compilar(Movimientos, Macro),
    efecto(Macro, Piezas).

%!  efecto_macro(+Nombre, -Piezas:list(atom)) is semidet.
%
%   Piezas son las piezas que mueve la macro Nombre.
efecto_macro(Nombre, Piezas) :-
    macro(Nombre, Antes, Despues),
    efecto(Antes-Despues, Piezas).

%!  quieta(+Casillas:list(integer), +Antes, +Despues) is semidet.
%
%   Cada una de Casillas tiene en Despues la misma variable que en Antes.
quieta(Casillas, Antes, Despues) :-
    forall(member(I, Casillas),
           ( arg(I, Antes, X),
             arg(I, Despues, Y),
             X == Y )).

%!  term_expansion(+Termino, -Hechos:list) is semidet.
%
%   El término generar_piezas se reemplaza, al cargar, por un hecho
%   pieza(P, Nombre, Casillas) por cada arista y cada esquina.
term_expansion(generar_piezas, Hechos) :-
    findall(pieza(P, Nombre, Casillas),
            pieza_calculada(P, Nombre, Casillas),
            Hechos).

%!  pieza_calculada(-P, -Nombre, -Casillas:list(integer)) is nondet.
%
%   P es el cubito de una arista o de una esquina; Nombre, su nombre en
%   la notación: las letras de sus caras, primero u o d, después f o b y
%   al final r o l (UFR, DB, FL, ...); Casillas, los números de sus
%   casillas.
pieza_calculada(P, Nombre, Casillas) :-
    between(-1, 1, X),
    between(-1, 1, Y),
    between(-1, 1, Z),
    P = p(X, Y, Z),
    findall(I-Cara, casilla(I, Cara, P, _), Pares),
    length(Pares, N),
    N >= 2,
    pairs_keys_values(Pares, Casillas, Caras),
    findall(C, ( member(C, [u, d, f, b, r, l]), memberchk(C, Caras) ),
            Ordenadas),
    maplist(upcase_atom, Ordenadas, Letras),
    atomic_list_concat(Letras, Nombre).

generar_piezas.

% --- Medir ----------------------------------------------------------------

%!  inferencias(+Nombre, +Veces:integer, -EnLista:integer,
%!              -Compilada:integer) is det.
%
%   EnLista y Compilada son las inferencias que cuesta aplicar Veces la
%   macro Nombre al cubo resuelto: giro por giro, con aplicar/3 sobre la
%   lista de la secuencia, y de una vez, con la macro compilada.
inferencias(Nombre, Veces, EnLista, Compilada) :-
    texto_macro(Nombre, Texto),
    leer_notacion(Texto, Movimientos),
    resuelto(C),
    contar(( between(1, Veces, _), aplicar(Movimientos, C, _), fail
           ; true ), EnLista),
    contar(( between(1, Veces, _), usar(Nombre, C, _), fail
           ; true ), Compilada).

%!  contar(:Meta, -Inferencias:integer) is det.
%
%   Inferencias es la cantidad de inferencias que cuesta probar Meta una
%   vez.
contar(Meta, Inferencias) :-
    statistics(inferences, I0),
    once(Meta),
    statistics(inferences, I1),
    Inferencias is I1 - I0.
