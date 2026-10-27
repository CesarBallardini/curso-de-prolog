:- encoding(utf8).

:- begin_tests(desplegar).

test(desplegar,
     true(Cs =@= [ (consecutivos(X, Y, [X, Y|_]) :- []),
                   (consecutivos(X1, Y1, [_|Zs]) :-
                        [append(_, [X1, Y1|_], Zs)]) ])) :-
    definicion(D),
    programa_append(P),
    desplegar(D, 1, P, Cs).

% Un objetivo sin cláusulas que unifiquen desaparece con su cláusula.
test(sin_resolventes, true(Cs == [])) :-
    programa_append(P),
    desplegar((p :- [append([a], [b], [c])]), 1, P, Cs).

test(plegar,
     true(C =@= (consecutivos(X, Y, [_|Zs]) :- [consecutivos(X, Y, Zs)]))) :-
    definicion(D),
    plegar((consecutivos(X, Y, [_|Zs]) :- [append(_, [X, Y|_], Zs)]),
           1, D, C).

% Plegar exige una instancia del cuerpo de la definición.
test(plegar_falla, [fail]) :-
    definicion(D),
    plegar((p(L) :- [append([a], [b], L)]), 1, D, _).

% Plegar la definición consigo misma da una cláusula que se llama a sí
% misma: la transformación que no conserva lo que el programa prueba.
test(plegar_sin_desplegar,
     true(C =@= (consecutivos(X, Y, L) :- [consecutivos(X, Y, L)]))) :-
    definicion(D),
    plegar(D, 1, D, C).

% derivar/1 obtiene las cláusulas de consecutivos/3 del archivo.
test(derivar, true(Cs =@= Cargadas)) :-
    derivar(Cs),
    findall((C :- Lista),
            ( clause(consecutivos(X, Y, L), Cuerpo),
              C = consecutivos(X, Y, L),
              lista_de(Cuerpo, Lista) ),
            Cargadas).

test(consecutivos, all(X-Y == [1-2, 2-3, 3-1, 1-2])) :-
    consecutivos(X, Y, [1, 2, 3, 1, 2]).

test(como_append, true(R1 == R2)) :-
    L = [a, b, a, c, a, b],
    findall(X-Y, consecutivos(X, Y, L), R1),
    findall(X-Y, consecutivos_append(X, Y, L), R2).

:- end_tests(desplegar).

%!  lista_de(+Cuerpo, -Lista:list) is det.
%
%   Lista son los objetivos de la conjunción Cuerpo; [] si es true.
lista_de(true, []) :-
    !.
lista_de((A, B), [A|Bs]) :-
    !,
    lista_de(B, Bs).
lista_de(A, [A]).

:- begin_tests(mostrar).

test(mostrar, true(S == "consecutivos(A, B, [A, B|_]):-[]\n")) :-
    with_output_to(string(S),
                   mostrar([(consecutivos(X, Y, [X, Y|_]) :- [])])).

:- end_tests(mostrar).
