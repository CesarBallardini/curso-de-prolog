:- encoding(utf8).

:- begin_tests(tateti_terminal).

%!  con_teclas(+Teclas:string, +Estado0, -Estado, -Salida:string) is det.
%
%   Juega Estado0 con las teclas escritas en Teclas; Salida es todo lo que
%   bucle/3 escribió.
con_teclas(Teclas, Estado0, Estado, Salida) :-
    setup_call_cleanup(
        open_string(Teclas, In),
        with_output_to(string(Salida), bucle(get_code(In), Estado0, Estado)),
        close(In)).

%!  nuevo(-Estado) is det.
%
%   Estado es una partida nueva de 3 por 3 contra la búsqueda completa.
nuevo(e(tateti(3), profundidad(9), P, 5, jugar)) :-
    inicial(tateti(3), P).

test(pantalla, true(L == ["┌─ Ta-te-ti ┐",
                          "│  ·  ·  ·  │",
                          "│  · [·] ·  │",
                          "│  ·  ·  ·  │",
                          "└───────────┘",
                          "┌─ Estado ────────────────┐",
                          "│ Tu turno: juegas con X. │",
                          "└─────────────────────────┘",
                          "Flechas: mover  Espacio o cifra: marcar  q: \c
                           salir"])) :-
    nuevo(E),
    pantalla(E, L).

% A una esquina, la computadora responde en el centro.
test(respuesta, true(T == [x, v, v, v, o, v, v, v, v])) :-
    nuevo(E0),
    paso(letra('1'), E0, e(_, _, pos(T, _), _, _)).

test(ocupada, true(E == E1)) :-
    nuevo(E0),
    paso(letra('1'), E0, E1),
    paso(letra('5'), E1, E).

test(cursor_en_el_borde, true(C == 1)) :-
    nuevo(E0),
    foldl(paso, [arriba, arriba, izquierda, izquierda], E0,
          e(_, _, _, C, _)).

test(cursor_abajo, true(C == 8)) :-
    nuevo(E0),
    paso(abajo, E0, e(_, _, _, C, _)).

% Una partida mal jugada: la computadora completa 3-5-7.
test(pierde, true(R-M == gana(o)-"Gana la computadora.")) :-
    nuevo(E0),
    con_teclas("124", E0, E, _),
    E = e(J, _, P, _, _),
    fin(J, P, R),
    mensaje(J, P, jugar, M).

% Las flechas y el espacio marcan como las cifras; la última pantalla
% dibujada dice cómo terminó.
test(con_flechas, true(R == gana(o))) :-
    nuevo(E0),
    con_teclas("\e[A\e[D \e[C \e[B\e[D ", E0, E, Salida),
    E = e(J, _, P, _, _),
    fin(J, P, R),
    atomic_list_concat(Pantallas, '\e[2J', Salida),
    last(Pantallas, Ultima),
    once(sub_atom(Ultima, _, _, _, 'Gana la computadora.')).

test(salir, true(Pd == salir)) :-
    nuevo(E0),
    con_teclas("1q", E0, e(_, _, _, _, Pd), _).

test(fin_de_la_entrada, true(Pd == salir)) :-
    nuevo(E0),
    con_teclas("", E0, e(_, _, _, _, Pd), _).

% En 4 por 4 la computadora profundiza durante 0,2 segundos.
test(cuatro, true(Os == 1)) :-
    inicial(tateti(4), P),
    paso(letra('6'), e(tateti(4), tiempo(0.2), P, 1, jugar),
         e(_, _, pos(T, x), _, _)),
    include(==(o), T, Lista),
    length(Lista, Os).

:- end_tests(tateti_terminal).
