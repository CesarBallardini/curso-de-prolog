:- encoding(utf8).

% Capítulo 75 - Versión 3: cada lazo una sola vez.
%
% Un lazo de M marcas se puede escribir de 2M maneras: empezando en
% cualquiera de sus marcas y recorriéndolo en cualquiera de los dos
% sentidos. La búsqueda de lazo.pl encuentra cada escritura por separado.
% La forma canónica de un lazo es una sola de esas escrituras: la que
% empieza en su menor casilla, en el orden estándar de los términos, y
% sigue hacia la menor de sus dos vecinas. Dos escrituras son el mismo
% lazo si y solo si tienen la misma forma canónica. Fijar la semilla
% divide el trabajo por M; fijar el sentido, comparando la primera y la
% última casilla, divide las respuestas por dos, pero no el trabajo.
%
% solo-local: carga lazo.pl, que carga archivos de otro capítulo.
%
%?- canonica([2-1, 1-1, 1-2, 2-2], F).
%?- conteo(csenki1, todas, N, I).
%?- conteo(csenki1, sentido, N, I).

:- ensure_loaded(lazo).

%!  canonica(+Lazo:list, -Forma:list) is det.
%
%   Forma es la escritura de Lazo que empieza en su menor casilla y sigue
%   hacia la menor de las dos vecinas de esa casilla en el lazo.
canonica(Lazo, Forma) :-
    min_member(Menor, Lazo),
    once(append(Antes, [Menor|Despues], Lazo)),
    append([Menor|Despues], Antes, Rotado),
    Rotado = [Menor|Resto],
    Resto = [Segunda|_],
    last(Resto, Ultima),
    (   Segunda @< Ultima
    ->  Forma = Rotado
    ;   reverse(Resto, Invertido),
        Forma = [Menor|Invertido]
    ).

%!  en_un_sentido(+Lazo:list) is semidet.
%
%   Lazo está escrito en el sentido elegido: su segunda casilla precede a
%   la última en el orden estándar.
en_un_sentido([_, Segunda|Resto]) :-
    last(Resto, Ultima),
    Segunda @< Ultima.

%!  semilla(+Nombre, -Semilla) is det.
%
%   Semilla es la primera marca del tablero Nombre, la que se fija.
semilla(Nombre, Semilla) :-
    problema(Nombre, _, _, [Marca|_]),
    clase(Marca, _, Semilla).

%!  escrituras(+Modo, +Nombre, -Lazos:list) is det.
%
%   Lazos son las escrituras de los lazos del tablero Nombre que halla la
%   búsqueda según Modo: todas (desde cada marca), semilla (desde la
%   primera marca) o sentido (desde la primera marca y en el sentido
%   elegido).
escrituras(todas, Nombre, Lazos) :-
    findall(Ls, lazos(Nombre, _, Ls), Listas),
    append(Listas, Lazos).
escrituras(semilla, Nombre, Lazos) :-
    semilla(Nombre, S),
    lazos_desde(Nombre, S, Lazos).
escrituras(sentido, Nombre, Lazos) :-
    semilla(Nombre, S),
    lazos_desde(Nombre, S, Lazos0),
    include(en_un_sentido, Lazos0, Lazos).

%!  conteo(+Nombre, +Modo, -N:integer, -Inferencias:integer) is det.
%
%   N es la cantidad de escrituras que da escrituras/3 con Modo, e
%   Inferencias lo que cuesta obtenerlas.
conteo(Nombre, Modo, N, Inferencias) :-
    statistics(inferences, I0),
    escrituras(Modo, Nombre, Lazos),
    statistics(inferences, I1),
    length(Lazos, N),
    Inferencias is I1 - I0.

%!  distintos(+Nombre, -Formas:list) is det.
%
%   Formas son las formas canónicas, sin repetir, de los lazos del
%   tablero Nombre.
distintos(Nombre, Formas) :-
    escrituras(semilla, Nombre, Lazos),
    maplist(canonica, Lazos, Formas0),
    sort(Formas0, Formas).
