:- encoding(utf8).

:- ensure_loaded(aves).

:- begin_tests(rebatible).

test(rivales_opus, [true(Rs == [(neg vuela(opus) :~ pinguino(opus))])]) :-
    findall(R, rival([], raiz, (vuela(opus) :~ ave(opus)), R), Rs).

test(supera, [true]) :-
    supera([especificidad], (neg vuela(opus) :~ pinguino(opus)),
           (vuela(opus) :~ ave(opus))).

test(no_supera, [fail]) :-
    supera([especificidad], (vuela(opus) :~ ave(opus)),
           (neg vuela(opus) :~ pinguino(opus))).

test(contrario, [true(C-D == (neg vuela(opus))-vuela(opus))]) :-
    contrario(vuela(opus), C),
    contrario(neg vuela(opus), D).

test(estricto_sin_reglas_rebatibles, [fail]) :-
    estricto(vuela(tweety)).

test(criterio_desconocido, [error(type_error(_, _))]) :-
    derivable(prioridad, vuela(tweety)).

test(meta_libre, [error(instantiation_error)]) :-
    respuesta([], _, _).

test(partes, [true(L == [p-q, r-s, t-u])]) :-
    findall(C-B, ( member(R, [(p :- q), (r :~ s), (t :^ u)]),
                   partes(R, C, B) ), L).

test(partes_hecho, [fail]) :-
    partes(p, _, _).

:- end_tests(rebatible).
