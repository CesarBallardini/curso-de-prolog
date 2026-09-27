:- encoding(utf8).

% Capítulo 28 - Solución del ejercicio 14: el Buscaminas en la terminal.
%
%     swipl soluciones_buscaminas.pl [--semilla=N] filas columnas minas
%
% El tablero es el del capítulo 22, un assoc de cada celda a mina o a la
% cantidad de minas vecinas; descubrir una región es el recorrido del
% capítulo 18, con foldl/4 sobre las vecinas. Las jugadas se leen con una
% gramática. El juego termina con el código 0 si se descubren todas las
% celdas libres, con 1 si se descubre una mina, y con 2 ante un error.
%
% solo-local: SWISH no ejecuta programas con argumentos ni lee del teclado.
%
%?- tablero(3, 3, [1-1], T), descubrir(T, 3-3, [], D), length(D, N).

:- use_module(library(main)).
:- use_module(library(assoc)).
:- use_module(library(ordsets)).
:- use_module(library(random)).
:- use_module(library(dcg/basics)).
:- ensure_loaded(preguntar).

:- initialization(main, main).

% opt_type(Opcion, Clave, Tipo): las opciones del programa.
opt_type(semilla, semilla, integer).

% opt_help(Clave, Texto): la ayuda de cada opción.
opt_help(semilla,     "Semilla del azar, para repetir un tablero").
opt_help(help(usage), " [--semilla=N] filas columnas minas").

% --- El programa -----------------------------------------------------------

%!  main(+Argv:list) is det.
%
%   Juega una partida con el tablero que piden los argumentos, y termina con
%   el código de salida del resultado.
main(Argv) :-
    argv_options(Argv, Posicionales, Opciones),
    catch(( partida(Posicionales, Opciones, Resultado),
            codigo_de_resultado(Resultado, Codigo) ),
          Error,
          ( print_message(error, Error),
            Codigo = 2 )),
    halt(Codigo).

%!  codigo_de_resultado(+Resultado, -Codigo:integer) is det.
%
%   Codigo es 0 para una partida ganada y 1 para una perdida.
codigo_de_resultado(gano, 0).
codigo_de_resultado(perdio, 1).

%!  partida(+Argumentos:list, +Opciones:list, -Resultado) is det.
%
%   Crea el tablero de Argumentos, filas, columnas y minas, y lo juega con
%   el teclado. Resultado es gano o perdio.
%
%   @error uso(argumentos) si no son tres argumentos.
%   @error domain_error(entero_positivo, A) si uno no es un entero positivo.
%   @error domain_error(cantidad_de_minas, M) si las minas no dejan ninguna
%          celda libre.
partida([F, C, M], Opciones, Resultado) :-
    !,
    maplist(entero_positivo, [F, C, M], [Filas, Columnas, Minas]),
    (   Minas < Filas * Columnas
    ->  true
    ;   domain_error(cantidad_de_minas, Minas)
    ),
    (   option(semilla(Semilla), Opciones)
    ->  set_random(seed(Semilla))
    ;   true
    ),
    tablero_al_azar(Filas, Columnas, Minas, Tablero),
    jugar(user_input, juego(Tablero, [], []), Resultado).
partida(_, _, _) :-
    throw(uso(argumentos)).

%!  entero_positivo(+Argumento:atom, -N:integer) is det.
%
%   N es el entero positivo que escribe Argumento.
%
%   @error domain_error(entero_positivo, Argumento) si no lo es.
entero_positivo(Argumento, N) :-
    (   atom_number(Argumento, N),
        integer(N),
        N > 0
    ->  true
    ;   domain_error(entero_positivo, Argumento)
    ).

:- multifile prolog:message//1.

%!  prolog:message(+Mensaje)// is semidet.
%
%   El texto del mensaje de uso.
prolog:message(uso(argumentos)) -->
    [ 'Uso: swipl ~w [--semilla=N] filas columnas minas'
      - ['soluciones_buscaminas.pl'] ].

% --- El tablero, del capítulo 22 --------------------------------------------

%!  tablero(+Filas:integer, +Columnas:integer, +Minas:list, -Tablero) is det.
%
%   Tablero es el tablero de Filas por Columnas con minas en las celdas de
%   Minas, pares Fila-Columna.
tablero(Filas, Columnas, Minas, tablero(Filas, Columnas, Celdas)) :-
    list_to_ord_set(Minas, ConjuntoDeMinas),
    findall(F-C, ( between(1, Filas, F), between(1, Columnas, C) ), Todas),
    maplist(valor_inicial(Filas, Columnas, ConjuntoDeMinas), Todas, Valores),
    pairs_keys_values(Pares, Todas, Valores),
    list_to_assoc(Pares, Celdas).

%!  valor_inicial(+Filas:integer, +Columnas:integer, +Minas:list,
%!                +Celda:pair, -Valor) is det.
%
%   Valor es mina si Celda está en Minas, o la cantidad de minas vecinas.
valor_inicial(Filas, Columnas, Minas, F-C, Valor) :-
    (   ord_memberchk(F-C, Minas)
    ->  Valor = mina
    ;   aggregate_all(count,
                      ( vecina(Filas, Columnas, F-C, V),
                        ord_memberchk(V, Minas) ),
                      Valor)
    ).

%!  vecina(+Filas:integer, +Columnas:integer, +Celda:pair, -Vecina:pair)
%!      is nondet.
%
%   Vecina es una de las celdas que rodean a Celda dentro del tablero.
vecina(Filas, Columnas, F-C, VF-VC) :-
    between(-1, 1, DF),
    between(-1, 1, DC),
    ( DF, DC ) \== ( 0, 0 ),
    VF is F + DF,
    VC is C + DC,
    between(1, Filas, VF),
    between(1, Columnas, VC).

%!  valor(+Tablero, +Celda:pair, -Valor) is semidet.
%
%   Valor es lo que hay en Celda. Falla si Celda está fuera del tablero.
valor(tablero(_, _, Celdas), Celda, Valor) :-
    get_assoc(Celda, Celdas, Valor).

%!  tablero_al_azar(+Filas:integer, +Columnas:integer, +Cantidad:integer,
%!                  -Tablero) is det.
%
%   Tablero es un tablero de Filas por Columnas con Cantidad minas al azar.
tablero_al_azar(Filas, Columnas, Cantidad, Tablero) :-
    Total is Filas * Columnas,
    randseq(Cantidad, Total, Numeros),
    maplist(celda_numero(Columnas), Numeros, Minas),
    tablero(Filas, Columnas, Minas, Tablero).

%!  celda_numero(+Columnas:integer, +K:integer, -Celda:pair) is det.
%
%   Celda es la celda número K del tablero, contando por filas desde 1.
celda_numero(Columnas, K, F-C) :-
    F is (K - 1) // Columnas + 1,
    C is (K - 1) mod Columnas + 1.

% --- Las jugadas -------------------------------------------------------------

%!  descubrir(+Tablero, +Celda:pair, +Vistas:list, -Descubiertas:list)
%!      is det.
%
%   Descubiertas es el conjunto ordenado Vistas más las celdas que descubre
%   un clic en Celda, sin mina: la celda, y si no tiene minas vecinas, las
%   que descubren sus vecinas.
descubrir(Tablero, Celda, Vistas, Descubiertas) :-
    (   ord_memberchk(Celda, Vistas)
    ->  Descubiertas = Vistas
    ;   ord_add_element(Vistas, Celda, Vistas1),
        (   valor(Tablero, Celda, 0)
        ->  Tablero = tablero(Filas, Columnas, _),
            findall(V, vecina(Filas, Columnas, Celda, V), Vecinas),
            foldl(descubrir(Tablero), Vecinas, Vistas1, Descubiertas)
        ;   Descubiertas = Vistas1
        )
    ).

%!  aplicar(+Jugada, +Juego0, -Juego, -Estado) is semidet.
%
%   Juego es Juego0, juego(Tablero, Descubiertas, Marcadas), después de
%   Jugada, descubrir(Celda) o marcar(Celda). Estado es sigue, gano o
%   perdio. Falla si la celda está fuera del tablero.
aplicar(descubrir(Celda), juego(T, D0, M), juego(T, D, M), Estado) :-
    valor(T, Celda, Valor),
    (   Valor == mina
    ->  ord_add_element(D0, Celda, D),
        Estado = perdio
    ;   descubrir(T, Celda, D0, D),
        (   todas_descubiertas(T, D)
        ->  Estado = gano
        ;   Estado = sigue
        )
    ).
aplicar(marcar(Celda), juego(T, D, M0), juego(T, D, M), sigue) :-
    valor(T, Celda, _),
    (   ord_memberchk(Celda, M0)
    ->  ord_del_element(M0, Celda, M)
    ;   ord_add_element(M0, Celda, M)
    ).

%!  todas_descubiertas(+Tablero, +Descubiertas:list) is semidet.
%
%   Descubiertas tiene todas las celdas libres de Tablero.
todas_descubiertas(tablero(Filas, Columnas, Celdas), Descubiertas) :-
    assoc_to_values(Celdas, Valores),
    include(==(mina), Valores, Minas),
    length(Minas, CantidadDeMinas),
    Libres is Filas * Columnas - CantidadDeMinas,
    length(Descubiertas, Libres).

%!  jugada(-Jugada)// is semidet.
%
%   Una jugada escrita como d F C (descubrir) o m F C (marcar).
jugada(Jugada) -->
    blanks,
    orden(Orden),
    blanks,
    integer(F),
    blanks,
    integer(C),
    blanks,
    { Jugada =.. [Orden, F-C] }.

%!  orden(-Orden)// is semidet.
%
%   La letra de una jugada.
orden(descubrir) --> "d".
orden(marcar) --> "m".

% --- La partida ------------------------------------------------------------

%!  jugar(+In, +Juego, -Resultado) is det.
%
%   Muestra Juego, lee jugadas de In y las aplica hasta que la partida
%   termina. Resultado es gano o perdio.
jugar(In, Juego0, Resultado) :-
    mostrar(Juego0, false),
    preguntar(In, "Jugada (d F C descubre, m F C marca):", Texto),
    string_codes(Texto, Codigos),
    (   phrase(jugada(Jugada), Codigos)
    ->  (   aplicar(Jugada, Juego0, Juego, Estado)
        ->  seguir(Estado, In, Juego, Resultado)
        ;   format("La celda está fuera del tablero.~n"),
            jugar(In, Juego0, Resultado)
        )
    ;   format("Jugada no válida.~n"),
        jugar(In, Juego0, Resultado)
    ).

%!  seguir(+Estado, +In, +Juego, -Resultado) is det.
%
%   Sigue la partida si Estado es sigue; si terminó, muestra el tablero
%   completo y el resultado.
seguir(sigue, In, Juego, Resultado) :-
    jugar(In, Juego, Resultado).
seguir(gano, _, Juego, gano) :-
    mostrar(Juego, true),
    format("Todas las celdas libres están descubiertas: partida ganada.~n").
seguir(perdio, _, Juego, perdio) :-
    mostrar(Juego, true),
    format("La celda tenía una mina: partida perdida.~n").

%!  mostrar(+Juego, +Minas:boolean) is det.
%
%   Escribe el tablero de Juego con los números de fila y de columna: el
%   número de minas vecinas en las celdas descubiertas, . si es cero, M en
%   las marcadas y # en las demás. Con Minas en true, muestra además las
%   minas con *.
mostrar(juego(tablero(Filas, Columnas, Celdas), D, M), Minas) :-
    numlist(1, Columnas, Numeros),
    fila_de_texto('', Numeros, Encabezado),
    writeln(Encabezado),
    forall(between(1, Filas, F),
           ( findall(S,
                     ( between(1, Columnas, C),
                       get_assoc(F-C, Celdas, V),
                       simbolo(F-C, V, D, M, Minas, S) ),
                     Simbolos),
             fila_de_texto(F, Simbolos, Fila),
             writeln(Fila) )).

%!  fila_de_texto(+Rotulo, +Simbolos:list, -Fila:atom) is det.
%
%   Fila es Rotulo seguido de Simbolos, cada uno en tres columnas.
fila_de_texto(Rotulo, Simbolos, Fila) :-
    maplist([S, A]>>format(atom(A), "~t~w~3|", [S]), [Rotulo|Simbolos],
            Columnas),
    atomic_list_concat(Columnas, Fila).

%!  simbolo(+Celda, +Valor, +Descubiertas, +Marcadas, +Minas:boolean,
%!          -Simbolo) is det.
%
%   Simbolo es el carácter con que se muestra Celda.
simbolo(Celda, Valor, D, M, Minas, Simbolo) :-
    (   ord_memberchk(Celda, D)
    ->  visible(Valor, Simbolo)
    ;   Minas == true, Valor == mina
    ->  Simbolo = '*'
    ;   ord_memberchk(Celda, M)
    ->  Simbolo = 'M'
    ;   Simbolo = '#'
    ).

%!  visible(+Valor, -Simbolo) is det.
%
%   Simbolo muestra el Valor de una celda descubierta.
visible(mina, '*') :-
    !.
visible(0, '.') :-
    !.
visible(N, N).
