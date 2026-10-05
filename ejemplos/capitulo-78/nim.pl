:- encoding(utf8).

% Capítulo 78 - Nim: las reglas, la búsqueda y la suma de Nim.
%
% Hay varias pilas de fichas; cada jugador, en su turno, saca de una sola
% pila entre una ficha y todas, y gana quien saca la última. Una posición
% es la lista de las pilas; una pila vacía queda en la lista con 0, para
% que las pilas conserven su número. Una jugada es sacar(K, M): sacar M
% fichas de la pila K.
%
% La versión 1 decide si una posición es ganadora buscando en el árbol de
% la partida: con ganadora/1, que lo recorre, con ganadora_tabulada/1, que
% resuelve cada posición distinta una sola vez, y con alfabeta/6 del
% capítulo 41, para la que Nim se describe al final del archivo como un
% juego más. La versión 2 lo decide sin buscar, con la suma de Nim: el o
% exclusivo de los tamaños de las pilas.
%
% solo-local: es un módulo que carga otro.
%
%?- jugada_ganadora([1, 3, 5], J).
%?- suma_nim([1, 3, 5, 7], S).
%?- jugada_segura([2, 6], J).
%?- alfabeta(nim([1, 2, 3]), pilas([1, 2, 3], uno), 20, J, V, N).

:- module(nim,
          [ sacar/3,
            vacias/1,
            ganadora/1,
            ganadora_tabulada/1,
            forma/2,
            posiciones/1,
            jugada_ganadora/2,
            una_ficha/2,
            tabulada/3,
            suma_nim/2,
            segura/1,
            jugada_segura/2,
            elegir/2,
            suma/3
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- reexport(capitulo41, [alfabeta/6]).
:- reexport(partida).

% --- Versión 1: las reglas y la búsqueda -----------------------------------

%!  sacar(+Pilas:list(integer), ?Jugada, -Pilas1:list(integer)) is nondet.
%
%   Pilas1 son las Pilas después de Jugada, sacar(K, M): sacar M fichas,
%   entre 1 y todas, de la pila K. Enumera las jugadas pila por pila, y en
%   cada pila de una ficha en adelante.
sacar(Pilas, sacar(K, M), Pilas1) :-
    nth1(K, Pilas, P, Resto),
    between(1, P, M),
    P1 is P - M,
    nth1(K, Pilas1, P1, Resto).

%!  vacias(+Pilas:list(integer)) is semidet.
%
%   No queda ninguna ficha: el jugador que sacó la última ganó.
vacias(Pilas) :-
    sum_list(Pilas, 0).

%!  ganadora(+Pilas:list(integer)) is semidet.
%
%   El jugador que mueve en Pilas gana, juegue lo que juegue el rival:
%   tiene una jugada que deja una posición que no es ganadora para el otro.
%   Si no quedan fichas, el que mueve ya perdió. Recorre el árbol de la
%   partida, sin recordar las posiciones ya resueltas.
ganadora(Pilas) :-
    sacar(Pilas, _, Pilas1),
    \+ ganadora(Pilas1),
    !.

:- table ganadora_forma/1.

%!  ganadora_tabulada(+Pilas:list(integer)) is semidet.
%
%   Como ganadora/1, pero cada posición distinta se resuelve una sola vez:
%   la tabla guarda la forma de la posición, y dos posiciones con las
%   mismas pilas en otro orden, o con otras pilas vacías, comparten la
%   respuesta.
ganadora_tabulada(Pilas) :-
    forma(Pilas, Forma),
    ganadora_forma(Forma).

%!  ganadora_forma(+Forma:list(integer)) is semidet.
%
%   ganadora/1 sobre la forma de una posición, tabulada.
ganadora_forma(Forma) :-
    once(( sacar(Forma, _, Pilas1),
           forma(Pilas1, Forma1),
           \+ ganadora_forma(Forma1) )).

%!  forma(+Pilas:list(integer), -Forma:list(integer)) is det.
%
%   Forma son las pilas no vacías de Pilas, de menor a mayor: el orden de
%   las pilas y las vacías no cambian quién gana.
forma(Pilas, Forma) :-
    exclude(==(0), Pilas, NoVacias),
    msort(NoVacias, Forma).

%!  posiciones(-Cantidad:integer) is det.
%
%   Cantidad es el número de formas distintas resueltas por
%   ganadora_tabulada/1 desde el último abolish_all_tables/0: una tabla por
%   forma. current_table/2 busca la variante exacta que recibe; por eso la
%   llamada va con la variable libre y el filtro después.
posiciones(Cantidad) :-
    aggregate_all(count,
                  ( current_table(Variante, _),
                    Variante = ganadora_forma(_) ),
                  Cantidad).

%!  jugada_ganadora(+Pilas:list(integer), -Jugada) is semidet.
%
%   Jugada es la primera jugada que deja al rival en una posición que no
%   es ganadora, según ganadora_tabulada/1. Falla si Pilas no es ganadora.
jugada_ganadora(Pilas, Jugada) :-
    once(( sacar(Pilas, Jugada, Pilas1),
           \+ ganadora_tabulada(Pilas1) )).

%!  una_ficha(+Pilas:list(integer), -Jugada) is semidet.
%
%   Jugada saca una ficha de la primera pila no vacía: la jugada de quien
%   no puede ganar, a la espera de un error del rival. Falla si no quedan
%   fichas.
una_ficha(Pilas, sacar(K, 1)) :-
    once(( nth1(K, Pilas, P),
           P > 0 )).

%!  tabulada(+Juego, +Posicion, -Jugada) is semidet.
%
%   La estrategia del jugador de Nim, con los argumentos de las
%   estrategias de partida.pl: el juego, la posición y la jugada elegida.
%   Juega la primera jugada ganadora, si la hay, y si no, una ficha.
tabulada(nim(_), pilas(Pilas, _), Jugada) :-
    (   jugada_ganadora(Pilas, J)
    ->  Jugada = J
    ;   una_ficha(Pilas, Jugada)
    ).

% --- Versión 2: la suma de Nim ---------------------------------------------

%!  suma_nim(+Pilas:list(integer), -Suma:integer) is det.
%
%   Suma es la suma de Nim de las pilas: el o exclusivo de sus tamaños,
%   que en binario suma cada columna módulo 2.
suma_nim(Pilas, Suma) :-
    foldl(xor_pila, Pilas, 0, Suma).

%!  xor_pila(+Pila:integer, +S0:integer, -S:integer) is det.
%
%   S es S0 xor Pila.
xor_pila(Pila, S0, S) :-
    S is S0 xor Pila.

%!  segura(+Pilas:list(integer)) is semidet.
%
%   Pilas es una posición segura: su suma de Nim es 0, y el jugador que
%   mueve pierde si el rival no se equivoca.
segura(Pilas) :-
    suma_nim(Pilas, 0).

%!  jugada_segura(+Pilas:list(integer), -Jugada) is nondet.
%
%   Jugada deja una posición segura. Una pila P la permite si P xor S, con
%   S la suma de Nim, es menor que P: se sacan las fichas que sobran. Falla
%   si Pilas ya es segura.
jugada_segura(Pilas, sacar(K, M)) :-
    suma_nim(Pilas, S),
    S =\= 0,
    nth1(K, Pilas, P),
    Q is P xor S,
    Q < P,
    M is P - Q.

%!  elegir(+Pilas:list(integer), -Jugada) is semidet.
%
%   Jugada es la primera jugada segura, si la hay; si la posición es
%   segura, saca una ficha de la primera pila no vacía, a la espera de un
%   error del rival. Falla si no quedan fichas.
elegir(Pilas, Jugada) :-
    (   jugada_segura(Pilas, J)
    ->  Jugada = J
    ;   una_ficha(Pilas, Jugada)
    ).

%!  suma(+Juego, +Posicion, -Jugada) is semidet.
%
%   La estrategia de la suma de Nim, con los argumentos de las estrategias
%   de partida.pl: el juego, la posición y la jugada elegida.
suma(nim(_), pilas(Pilas, _), Jugada) :-
    elegir(Pilas, Jugada).

% --- Nim como juego del capítulo 41 ----------------------------------------

% La posición del capítulo 41 es pilas(Pilas, Jugador): las pilas y el
% jugador que mueve, uno o dos. uno es max.

% inicial(nim(Pilas), P): la partida empieza con Pilas, y mueve uno.
capitulo41:inicial(nim(Pilas), pilas(Pilas, uno)).

%!  capitulo41:jugada(+Juego, +Posicion, ?Jugada, -Siguiente) is nondet.
%
%   En Nim, Jugada saca fichas de una pila con sacar/3, y el turno pasa
%   al rival.
capitulo41:jugada(nim(_), pilas(Pilas, J), Jugada, pilas(Pilas1, Otro)) :-
    sacar(Pilas, Jugada, Pilas1),
    rival(J, Otro).

%!  capitulo41:turno(+Juego, +Posicion, -Lado) is det.
%
%   En Nim, uno es max y dos es min.
capitulo41:turno(nim(_), pilas(_, J), Lado) :-
    lado(J, Lado).

%!  capitulo41:fin(+Juego, +Posicion, -Resultado) is semidet.
%
%   En Nim, la partida termina sin fichas, y gana el rival del que mueve,
%   que sacó la última. Falla si quedan fichas.
capitulo41:fin(nim(_), pilas(Pilas, J), gana(Otro)) :-
    vacias(Pilas),
    rival(J, Otro).

%!  capitulo41:valor_final(+Resultado, +Posicion, -Valor) is det.
%
%   En Nim, una victoria vale 100 para max y -100 para min.
capitulo41:valor_final(gana(J), pilas(_, _), Valor) :-
    lado(J, Lado),
    extremo(Lado, Valor).

% evaluar(nim(_), P, 0): Nim se busca hasta el final; la evaluación es nula.
capitulo41:evaluar(nim(_), pilas(_, _), 0).

% rival(J, K): K es el rival de J.
rival(uno, dos).
rival(dos, uno).

% lado(J, L): el jugador J es L, max o min.
lado(uno, max).
lado(dos, min).

% extremo(L, V): V es el valor de una victoria de L.
extremo(max, 100).
extremo(min, -100).

% --- Nim en la terminal -------------------------------------------------------

% partida.pl muestra cada posición con pantalla/3 y lee las jugadas de la
% persona con leer_jugada/4: el número de la pila y la cantidad de fichas.

%!  partida:pantalla(+Juego, +Posicion, -Lineas:list(string)) is det.
%
%   Lineas muestra cada pila con su número, su tamaño y una barra por
%   ficha.
partida:pantalla(nim(_), pilas(Pilas, _), Lineas) :-
    findall(L, ( nth1(K, Pilas, P),
                 length(Barras, P),
                 maplist(=(0'|), Barras),
                 format(string(L0), "Pila ~d: ~d ~s", [K, P, Barras]),
                 split_string(L0, "", " ", [L]) ),
            Lineas).

%!  partida:leer_jugada(+Juego, +Posicion, +Linea:string, -Jugada)
%!      is semidet.
%
%   Linea tiene dos números, la pila y las fichas que se sacan: "2 3" es
%   sacar(2, 3). Falla si no tiene esa forma.
partida:leer_jugada(nim(_), _, Linea, sacar(K, M)) :-
    split_string(Linea, " ", " ", [A, B]),
    number_string(K, A),
    number_string(M, B).
