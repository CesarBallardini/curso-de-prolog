:- encoding(utf8).

:- begin_tests(fft).

test(costos_ocho, [true(Cs == [ingenua-64-64, simplificada-56-32,
                               arboles-56-56, grafo-24-24,
                               mariposa-24-5])]) :-
    findall(V-S-P, costo(V, 8, S, P), Cs).

test(tabla, [true(Lineas == ["n          ingenua  simplificada       arboles         grafo      mariposa",
                             "4            16+16          12+4         12+12           8+8           8+1"])]) :-
    with_output_to(string(T), tabla_de_costos([4])),
    split_string(T, "\n", "", Lineas0),
    once(append(Lineas, [""], Lineas0)).

test(ejemplo, [true(Ultima == "salida 3: n14")]) :-
    with_output_to(string(T), fft_ejemplo(4)),
    split_string(T, "\n", "", Lineas),
    once(append(_, [Ultima, ""], Lineas)).

test(mermaid, [true(Primera == "flowchart TB")]) :-
    with_output_to(string(T), mermaid_grafo(2)),
    split_string(T, "\n", "", [Primera|_]).

test(costos_dos, [true(Cs == [ingenua-4-4, simplificada-2-0, arboles-2-2,
                               grafo-2-2, mariposa-2-0])]) :-
    findall(V-S-P, costo(V, 2, S, P), Cs).

test(ejemplo_dos, [true(Ls == ["n1 = a(0)", "n2 = a(1)", "n3 = n1 + n2",
                               "n4 = n1 - n2", "salida 0: n3",
                               "salida 1: n4", ""])]) :-
    with_output_to(string(T), fft_ejemplo(2)),
    split_string(T, "\n", "", Ls).

test(mermaid_dos, [true(Ls == ["flowchart TB",
                               "    n1[\"n1 = a(0)\"]",
                               "    n2[\"n2 = a(1)\"]",
                               "    n3[\"n3 = n1 + n2\"]",
                               "    n1 & n2 --> n3",
                               "    n4[\"n4 = n1 - n2\"]",
                               "    n1 & n2 --> n4",
                               "    n3 --> s0([\"salida 0\"])",
                               "    n4 --> s1([\"salida 1\"])", ""])]) :-
    with_output_to(string(T), mermaid_grafo(2)),
    split_string(T, "\n", "", Ls).

:- end_tests(fft).
