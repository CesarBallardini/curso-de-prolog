:- encoding(utf8).

:- begin_tests(limpieza, [cleanup(retractall(user:abierto(_)))]).

test(exito, true(A == [])) :-
    usar(r1, true),
    findall(R, abierto(R), A).

test(falla, [fail]) :-
    usar(r1, fail).

test(falla_cierra, true(A == [])) :-
    \+ usar(r1, fail),
    findall(R, abierto(R), A).

test(error_cierra, true(A == [])) :-
    catch(usar(r1, _ is 1/0), _, true),
    findall(R, abierto(R), A).

% Sin setup_call_cleanup/3, un error deja el recurso abierto.
test(sin_limpieza, [ cleanup(retractall(user:abierto(_))),
                     true(A == [r1]) ]) :-
    catch(usar_sin_limpieza(r1, _ is 1/0), _, true),
    findall(R, abierto(R), A).

test(contar_lineas, true(N == 3)) :-
    contar_lineas("uno\ndos\ntres", N).

test(contar_lineas_vacio, true(N == 0)) :-
    contar_lineas("", N).

:- end_tests(limpieza).
