:- encoding(utf8).

:- begin_tests(estampillas,
               [ setup(album_actual(Guardado)),
                 cleanup(guardar(Guardado))
               ]).

%!  con_album(:Meta) is semidet.
%
%   Ejecuta Meta y devuelve después el álbum de la base de datos al
%   estado en que estaba.
con_album(Meta) :-
    album_actual(A),
    setup_call_cleanup(true, once(Meta), guardar(A)).

test(coleccion_valor, [true(Ss == [sello(reino_unido, reina, 1967, 50),
                                   sello(alemania, kaiser, 1885, 50),
                                   sello(alemania, castillos, 1879, 50)])]) :-
    coleccion(sello(_, _, _, 50), Ss).

test(coleccion_no_liga, [true(var(P))]) :-
    coleccion(sello(P, castillos, _, _), _).

test(coleccion_condicion, [true(Ss == [sello(alemania, kaiser, 1882, 5),
                                       sello(alemania, kaiser, 1879, 20),
                                       sello(alemania, castillos, 1879, 50)])]) :-
    coleccion(sello(_, _, A, _), between(1875, 1883, A), Ss).

test(mostrar, [true(S == "sello(alemania,castillos,1885,10)\nsello(alemania,castillos,1879,50)\nsello(alemania,castillos,1885,60)\n")]) :-
    with_output_to(string(S), mostrar(sello(_, castillos, _, _))).

test(quitar_todos, [true(L == [item(6, 9), item(7, 1)])]) :-
    quitar_todos(item(_, 5), [item(6, 9), item(1, 5), item(7, 1), item(9, 5)],
                 L).

test(insertar, [true(S == [sello(r, f, 2000, 40), sello(r, f, 2000, 60),
                           sello(r, f, 2001, 70), sello(r, f, 1991, 100)])]) :-
    insertar(sello(r, f, 2001, 70),
             [sello(r, f, 2000, 40), sello(r, f, 2000, 60),
              sello(r, f, 1991, 100)],
             S).

test(insertar_otra_serie, [fail]) :-
    insertar(sello(r, deportes, 2001, 70), [sello(r, f, 2000, 40)], _).

test(vender_por_anio, [true(Ss == [sello(reino_unido, poetas, 1979, 20),
                                   sello(reino_unido, poetas, 1977, 40)])]) :-
    con_album(( vender(sello(_, poetas, 1978, _)),
                coleccion(sello(_, poetas, _, _), Ss) )).

test(vender_primero_no_coincide, [true(Ss == [sello(reino_unido, poetas, 1978, 19),
                                              sello(reino_unido, poetas, 1979, 20),
                                              sello(reino_unido, poetas, 1978, 22),
                                              sello(reino_unido, poetas, 1978, 100)])]) :-
    con_album(( vender(sello(_, poetas, 1977, _)),
                coleccion(sello(_, poetas, _, _), Ss) )).

test(vender_serie_entera, [true(N == 3)]) :-
    con_album(( vender(sello(alemania, kaiser, _, _)),
                aggregate_all(count, album(_), N) )).

test(comprar_en_serie, [true(Vs == [20, 25, 50, 120])]) :-
    con_album(( comprar(sello(reino_unido, reina, 1966, 25)),
                coleccion(sello(_, reina, _, V), Ss),
                findall(V, member(sello(_, _, _, V), Ss), Vs) )).

test(comprar_serie_nueva, [true(Ss == [[sello(suecia, nobel, 1956, 50)]])]) :-
    con_album(( comprar(sello(suecia, nobel, 1956, 50)),
                findall(S, ( album(S), S = [sello(suecia, _, _, _)|_] ), Ss) )).

test(vender_puro, [true(N-K == 4-11)]) :-
    album_actual(A0),
    vender(sello(_, _, 1885, _), A0, A),
    length(A, N),
    append(A, Sellos),
    length(Sellos, K).

test(vender_puro_vacia, [true(N == 3)]) :-
    album_actual(A0),
    vender(sello(alemania, castillos, _, _), A0, A),
    length(A, N).

test(comprar_puro, [true(A == [[sello(p, s, 1, 1), sello(p, s, 2, 3)],
                               [sello(q, t, 1, 1)]])]) :-
    comprar(sello(p, s, 2, 3), [[sello(p, s, 1, 1)], [sello(q, t, 1, 1)]], A).

test(comprar_puro_nueva, [true(A == [[sello(q, t, 1, 1)], [sello(p, s, 1, 1)]])]) :-
    comprar(sello(p, s, 1, 1), [[sello(q, t, 1, 1)]], A).

test(operar, [true(A1 == A2)]) :-
    album_actual(A0),
    vender(sello(_, _, _, 50), A0, A1),
    con_album(( operar(vender(sello(_, _, _, 50))),
                album_actual(A2) )).

test(operar_comprar, [true(A1 == A2)]) :-
    album_actual(A0),
    comprar(sello(alemania, kaiser, 1880, 10), A0, A1),
    con_album(( operar(comprar(sello(alemania, kaiser, 1880, 10))),
                album_actual(A2) )).

:- end_tests(estampillas).
