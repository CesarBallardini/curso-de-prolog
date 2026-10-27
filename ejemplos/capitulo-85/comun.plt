:- encoding(utf8).

% Pruebas de comun.pl: la gramática de una línea, el paso, la lectura del
% archivo y la comparación con el registro de http_log del mismo día.

:- begin_tests(comun).

test(linea, [true(P == pedido(T, ip(10, 1, 0, 28), post, '/sesion', 401,
                              sin_medir))]) :-
    date_time_stamp(date(2026, 10, 1, 8, 4, 26, 10800, -, -), T),
    phrase(linea(P),
           `10.1.0.28 - - [01/Oct/2026:08:04:26 -0300] "POST /sesion HTTP/1.1" 401 36`).

test(linea_bytes_guion) :-
    phrase(linea(pedido(_, _, get, '/', 304, sin_medir)),
           `1.2.3.4 - ana [05/Oct/2026:10:00:00 +0000] "GET / HTTP/1.0" 304 -`).

test(linea_zona_este, [true(T =:= 0)]) :-
    phrase(linea(pedido(T, _, _, _, _, _)),
           `1.2.3.4 - - [01/Jan/1970:02:00:00 +0200] "GET / HTTP/1.1" 200 1`).

test(linea_tls, [fail]) :-
    phrase(linea(_),
           `203.0.113.50 - - [01/Oct/2026:08:41:07 -0300] "\x16\x03\x01" 400 0`).

test(linea_cortada, [fail]) :-
    phrase(linea(_), `10.1.0.58 - - [01/Oct/2026:16:55:11 -0`).

test(paso_bueno, [true(Ps = [pedido(_, ip(1, 2, 3, 4), get, '/a', 200, sin_medir)])]) :-
    paso_comun(5, "1.2.3.4 - - [01/Oct/2026:08:00:00 -0300] \"GET /a HTTP/1.1\" 200 9", Ps).

test(paso_defectuoso, [true(Ps == [defectuosa(5, "basura")])]) :-
    paso_comun(5, "basura", Ps).

test(leer_comun, [true(N-Ns == 418-[23, 397])]) :-
    leer_comun(registros('2026-10-01-comun.log'), Pedidos, Defectuosas),
    length(Pedidos, N),
    findall(K, member(defectuosa(K, _), Defectuosas), Ns).

test(comparar_con_registro,
     [true(Faltan-Sobran == [clave(1790884511, ip(10, 1, 0, 58), get,
                                   '/alumnos/158', 200)]-[])]) :-
    leer_comun(registros('2026-10-01-comun.log'), Comun, _),
    leer_registro(registros('2026-10-01.log'), Registro),
    comparar(Comun, Registro, Faltan, Sobran).

test(comparar_iguales, [true(F-S == []-[])]) :-
    Ps = [pedido(1.5, a, get, '/x', 200, 0.1)],
    Qs = [pedido(1.0, a, get, '/x', 200, sin_medir)],
    comparar(Qs, Ps, F, S).

test(contar_comun, [true(N-Ns == 418-[23, 397])]) :-
    contar_comun(registros('2026-10-01-comun.log'), N, Ds),
    findall(K, member(defectuosa(K, _), Ds), Ns).

test(diferencias, [true(F-S == [clave(1790884511, ip(10, 1, 0, 58), get,
                                       '/alumnos/158', 200)]-[])]) :-
    diferencias(registros('2026-10-01-comun.log'),
                registros('2026-10-01.log'), F, S).

:- end_tests(comun).
