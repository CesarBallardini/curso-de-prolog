:- encoding(utf8).

% Los enlaces se agregan y quitan en el módulo user, el del programa: dentro
% de la unidad de pruebas, assertz/1 los crearía en el módulo de la unidad.

:- begin_tests(incremental, [setup(restaurar), cleanup(restaurar)]).

test(inicial, [setup(restaurar), true(Ys-Fs == [b, c]-[b, c])]) :-
    findall(Y, alcanza(a, Y), Ys0),
    msort(Ys0, Ys),
    findall(Y, alcanza_fijo(a, Y), Fs0),
    msort(Fs0, Fs).

% Después de agregar un enlace, la tabla incremental lo ve y la común no.
test(agregar, [setup(restaurar), true(Ys-Fs == [b, c, d]-[b, c])]) :-
    findall(Y, alcanza(a, Y), _),
    findall(Y, alcanza_fijo(a, Y), _),
    assertz(user:enlace(c, d)),
    findall(Y, alcanza(a, Y), Ys0),
    msort(Ys0, Ys),
    findall(Y, alcanza_fijo(a, Y), Fs0),
    msort(Fs0, Fs).

test(quitar, [setup(restaurar), true(Ys == [b])]) :-
    findall(Y, alcanza(a, Y), _),
    retract(user:enlace(b, c)),
    findall(Y, alcanza(a, Y), Ys).

% abolish_all_tables/0 pone al día la tabla común.
test(borrar, [setup(restaurar), true(Fs == [b, c, d])]) :-
    findall(Y, alcanza_fijo(a, Y), _),
    assertz(user:enlace(c, d)),
    abolish_all_tables,
    findall(Y, alcanza_fijo(a, Y), Fs0),
    msort(Fs0, Fs).

% Un ciclo agregado después no impide terminar.
test(ciclo, [setup(restaurar), true(Ys == [a, b, c])]) :-
    findall(Y, alcanza(a, Y), _),
    assertz(user:enlace(c, a)),
    findall(Y, alcanza(a, Y), Ys0),
    msort(Ys0, Ys).

:- end_tests(incremental).
