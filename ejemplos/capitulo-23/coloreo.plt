:- encoding(utf8).

:- begin_tests(coloreo).

test(primer_coloreo,
     true(C == [san_juan-1, mendoza-2, san_luis-3, la_rioja-2, cordoba-1,
                la_pampa-4, neuquen-1, rio_negro-2])) :-
    once(colorear(4, C)).

% San Luis está rodeada por un anillo de cinco provincias: tres colores no
% alcanzan.
test(tres_colores, [fail]) :-
    colorear(3, _).

test(cuantos_coloreos, true(N == 480)) :-
    aggregate_all(count, colorear(4, _), N).

% Todo coloreo respeta los límites.
test(coloreos_validos, [fail]) :-
    colorear(4, C),
    limita(A, B),
    memberchk(A-X, C),
    memberchk(B-X, C).

:- end_tests(coloreo).
