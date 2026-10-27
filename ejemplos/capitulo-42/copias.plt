:- encoding(utf8).

:- begin_tests(copias).

% Toda copia coincide con su original. Si no, se informa cada cláusula
% distinta: el archivo, el original, el predicado y la posición.
test(sin_deriva) :-
    diferencias(Ds),
    forall(member(D, Ds), informar(D)),
    Ds == [].

% Las copias existen: la prueba anterior no pasa por no encontrar ninguna.
test(hay_copias, [true(Os == [alfabeta, minimax, orden, tateti])]) :-
    directorio(Dir),
    directory_file_path(Dir, 'alfabeta.pl', A),
    directory_file_path(Dir, 'profundizacion.pl', P),
    clausulas(A, CA),
    clausulas(P, CP),
    append(CA, CP, Cs),
    findall(O, (member(copia(F)-_, Cs), file_name_extension(O, pl, F)),
            Os0),
    sort(Os0, Os).

% Un cambio en una cláusula copiada se detecta y se ubica.
test(cambio, [true(D == deriva(a, 'b.pl', signo/2, 2,
                              signo(o, 1), signo(o, -1)))]) :-
    comparar([signo(x, 1), signo(o, 1)], [signo(x, 1), signo(o, -1)], 1,
             deriva(a, 'b.pl', signo/2), [D], []).

% Una cláusula que falta en la copia también es una diferencia.
test(falta, [true(Ds == [deriva(a, 'b.pl', signo/2, 2, ninguna,
                                signo(o, -1))])]) :-
    comparar([signo(x, 1)], [signo(x, 1), signo(o, -1)], 1,
             deriva(a, 'b.pl', signo/2), Ds, []).

% Los nombres de las variables no cuentan: se compara con =@=.
test(variantes, [true(Ds == [])]) :-
    comparar([(p(A) :- q(A))], [(p(B) :- q(B))], 1,
             deriva(a, 'b.pl', p/1), Ds, []).

%!  informar(+Diferencia) is det.
%
%   Escribe Diferencia en la salida de errores, en una forma legible.
informar(deriva(Archivo, Original, Indicador, I, Copia, Fuente)) :-
    \+ \+ ( numbervars(Copia-Fuente, 0, _),
            format(user_error,
                   "~w: la cláusula ~w de ~w difiere de ~w~n\c
                    \x20 copia:    ~p~n\c
                    \x20 original: ~p~n",
                   [Archivo, I, Indicador, Original, Copia, Fuente]) ).

:- end_tests(copias).
