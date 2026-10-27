:- encoding(utf8).

:- begin_tests(waltz).

test(inicio_cubo, [true(Ts == [a-5, b-3, c-3, d-3, e-6, f-6, g-6])]) :-
    tamanos(cubo, sin_borde, inicial, Ts).

test(filtrado_cubo, [true(Ts == [a-1, b-2, c-2, d-2, e-3, f-3, g-3])]) :-
    tamanos(cubo, sin_borde, filtrado, Ts).

test(filtrado_cubo_con_borde,
     [true(Ts == [a-1, b-1, c-1, d-1, e-1, f-1, g-1])]) :-
    tamanos(cubo, borde, filtrado, Ts).

test(filtrado_poiuyt,
     [true(Ts == [a-5, b-5, c-2, d-3, e-3, f-2, g-4, h-4, i-4, j-4,
                  k-3, l-3])]) :-
    tamanos(poiuyt, sin_borde, filtrado, Ts).

test(poiuyt_con_borde_vacio, [fail]) :-
    filtrar(poiuyt, borde, _).

test(poiuyt_sin_interpretacion, [true(N == 0)]) :-
    interpretaciones_waltz(poiuyt, sin_borde, N).

test(cantidades, [true(Ns == [4, 15, 4])]) :-
    findall(N, ( member(F, [cubo, bloques, escalon]),
                 interpretaciones_waltz(F, sin_borde, N) ), Ns).

test(cubo_con_borde,
     [true(Ls == [(a-b)-mas, (a-c)-mas, (a-d)-mas, (b-e)-der, (b-g)-izq,
                  (c-e)-izq, (c-f)-der, (d-f)-izq, (d-g)-der])]) :-
    etiquetar_waltz(cubo, borde, Ls).

test(inicio, [true(Cs == [[(a-b)-mas, (a-c)-mas, (a-d)-mas]])]) :-
    inicio(cubo, borde, Vecinos, D0),
    get_assoc(a, Vecinos, [b, c, d]),
    revisar(b, a, D0, D, si(1)),
    get_assoc(a, D, Cs).

test(revisar_sin_cambio, [true(R == no)]) :-
    inicio(cubo, sin_borde, _, D0),
    revisar(e, b, D0, _, R).

test(dominio, [true(N == 1)]) :-
    dominio([(c-e)-izq], u(e, ele, [c, b]), e-Cs),
    length(Cs, N0),
    N0 >= 1,
    include(=([(c-e)-izq, (b-e)-der]), Cs, Unica),
    length(Unica, N).

test(par_global, [true(Ps == [(a-b)-der, (a-b)-izq])]) :-
    par_global(a, b, der, P1),
    par_global(b, a, der, P2),
    Ps = [P1, P2].

test(compatible) :-
    compatible([(a-b)-mas], [(a-b)-mas, (c-d)-izq]).

test(incompatible, [fail]) :-
    compatible([(a-b)-mas], [(a-b)-menos]).

test(propagar_registra_pasos, [true(Ps == [a-1])]) :-
    inicio(cubo, borde, Vecinos, D0),
    propagar([b], Vecinos, D0, _, Ps0),
    Ps0 = [P|_],
    Ps = [P].

test(revisar_vecinas, [true(Cola == [a])]) :-
    inicio(cubo, borde, _, D0),
    revisar_vecinas([a], b, D0, _, [], Cola, _, []).

test(da_etiqueta) :-
    da_etiqueta(a-b, [mas, menos], [(a-b)-menos]).

test(tamano, [true(T == p-2)]) :-
    tamano(p-[x, y], T).

test(ambigua, [true(J == b)]) :-
    ambigua([a-[x], b-[x, y], c-[x, y, z]], J).

test(sin_ambigua, [fail]) :-
    ambigua([a-[x], b-[y]], _).

test(buscar_unica, [true(Ls == [(a-b)-mas])]) :-
    list_to_assoc([a-[[(a-b)-mas]], b-[[(a-b)-mas]]], D),
    buscar(t, D, Ls).

test(escribir_interpretaciones, [true(T == Esperado)]) :-
    atomics_to_string(["1: ab=mas ac=mas ad=mas be=der bg=izq ce=izq",
                       " cf=der df=izq dg=der
"], Esperado),
    with_output_to(string(T), escribir_interpretaciones(cubo, borde)).

test(escribir_tamanos,
     [true(T == "a:5 b:5 c:2 d:3 e:3 f:2 g:4 h:4 i:4 j:4 k:3 l:3
")]) :-
    with_output_to(string(T), escribir_tamanos(poiuyt, sin_borde, filtrado)).

test(escribir_tamanos_imposible, [fail]) :-
    with_output_to(string(_), escribir_tamanos(poiuyt, borde, filtrado)).

:- end_tests(waltz).
