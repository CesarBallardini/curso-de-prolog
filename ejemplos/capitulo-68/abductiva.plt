:- encoding(utf8).

:- use_module(library(lists)).

:- begin_tests(abductiva).

test(inducibles, [true(N-U =@= 8-(abuelo(_, _) :- []))]) :-
    inducibles(abuelo, Is),
    length(Is, N),
    last(Is, U).

test(sublista, all(S == [[a, b], [a], [b], []])) :-
    abductiva:sublista([a, b], S).

% Un objetivo del modelo no supone nada.
test(inducir_fondo, [nondet, true(H == [])]) :-
    modelo_fondo(M),
    inducir(padre(juan, pedro), [], M, [], H).

test(inducir_supone, [nondet,
                      true(H == [(abuelo(juan, luis) :- [padre(juan, pedro),
                                                        progenitor(pedro, luis)])])]) :-
    modelo_fondo(M),
    inducir(abuelo(juan, luis), [(abuelo(A, B) :- [padre(A, C),
                                                   progenitor(C, B)])],
            M, [], H).

test(inducir_falla, [fail]) :-
    modelo_fondo(M),
    inducir(abuelo(ana, luis), [(abuelo(A, B) :- [padre(A, C),
                                                  progenitor(C, B)])],
            M, [], _).

% Una cláusula ya supuesta se usa sin volver a agregarla.
test(inducir_ya_supuesta, [nondet, true(H == H0)]) :-
    modelo_fondo(M),
    H0 = [(abuelo(juan, luis) :- [])],
    inducir(abuelo(juan, luis), [], M, H0, H).

test(inducir_cuenta, [true(N == 10)]) :-
    inducibles(abuelo, Is),
    modelo_fondo(M),
    findall(H, inducir(abuelo(pedro, sofia), Is, M, [], H), Hs),
    length(Hs, N).

test(inducir_cuerpo_vacio, [nondet, true(H == [])]) :-
    abductiva:inducir_cuerpo([], [], [], [], H).

test(explicaciones, [true(N-P == 10-(abuelo(pedro, sofia) :- []))]) :-
    explicaciones(abuelo(pedro, sofia), abuelo, Cs),
    length(Cs, N),
    last(Cs, P).

test(explicaciones_comunes, [true(N == 8)]) :-
    findall(C, explicaciones_comunes(abuelo(juan, luis),
                                     abuelo(pedro, sofia), C), Cs),
    length(Cs, N).

test(explicacion_comun_esperada, [nondet]) :-
    explicaciones_comunes(abuelo(juan, luis), abuelo(pedro, sofia), C),
    C =@= (abuelo(A, B) :- [padre(A, X), progenitor(X, B)]).

:- end_tests(abductiva).
