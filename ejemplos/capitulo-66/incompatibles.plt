:- encoding(utf8).

:- begin_tests(incompatibles).

% Sin superioridad, las dos reglas incompatibles se derrotan entre sí.
test(sin_criterio, [true(R-S == sin_conclusion-sin_conclusion)]) :-
    respuesta([], capitalista(ping), R),
    respuesta([], marxista(ping), S).

% Con la superioridad declarada, prevalece el restaurante; y como se
% deriva un literal incompatible, la otra respuesta es negativa.
test(declarada, [true(R-S == presumiblemente_si-presumiblemente_no)]) :-
    respuesta([declarada], capitalista(ping), R),
    respuesta([declarada], marxista(ping), S).

test(lucas, [true(R-S == presumiblemente_si-presumiblemente_no)]) :-
    respuesta([], capitalista(lucas), R),
    respuesta([], marxista(lucas), S).

% contrario/2 da el complemento y el literal incompatible, en los dos
% sentidos.
test(contrarios, [true(L-M == [neg capitalista(ping), marxista(ping)]-
                              [neg marxista(ping), capitalista(ping)])]) :-
    findall(C, contrario(capitalista(ping), C), L),
    findall(C, contrario(marxista(ping), C), M).

test(complemento, [true(C-D == (neg marxista(a))-marxista(a))]) :-
    complemento(marxista(a), C),
    complemento(neg marxista(a), D).

test(rival, [true(Rs == [(marxista(ping) :~ nacio_en(ping, china))])]) :-
    findall(R, rival([], raiz,
                     (capitalista(ping) :~ duena(ping, restaurante)), R),
            Rs).

:- end_tests(incompatibles).
