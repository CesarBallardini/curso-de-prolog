:- encoding(utf8).

:- begin_tests(wumpus).

test(chica, [true(P-C == [ir(2-2), ir(2-1), ir(1-1)]-3)]) :-
    seguras(chica, S),
    buscar(mejor(a_estrella), vuelta(2-3, S), P, C, _).

test(vecinas_seguras, [true(Cs == [1-2, 2-1, 2-3, 3-2])]) :-
    seguras(chica, S),
    findall(C, sucesor(vuelta(2-2, S), 2-2, _, C, _), Cs0),
    msort(Cs0, Cs).

test(heuristica, [true(H == 5)]) :-
    heuristica(vuelta(_, _), 3-4, H).

% En la cueva grande, A* expande solo las celdas del camino más corto;
% anchura y costo uniforme expanden más; el primer camino en profundidad
% tiene 12 pasos.
test(grande, [true(C-KA-KB-KC-L == 4-4-11-9-12)]) :-
    seguras(grande, S),
    buscar(mejor(a_estrella), vuelta(1-5, S), _, C, KA),
    buscar(anchura, vuelta(1-5, S), _, _, KB),
    buscar(mejor(costo), vuelta(1-5, S), _, _, KC),
    primer_camino(vuelta(1-5, S), P),
    length(P, L).

test(celdas_grande, [true(N == 20)]) :-
    seguras(grande, S),
    length(S, N).

% Si la entrada no se alcanza por celdas seguras, la búsqueda falla.
test(aislada, [fail]) :-
    buscar(mejor(a_estrella), vuelta(3-3, [3-3, 3-4]), _, _, _).

:- end_tests(wumpus).
