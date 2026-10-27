:- encoding(utf8).

:- begin_tests(soluciones_indices).

% Como etapas, limpiar termina antes de que contar deje los ruidos.
test(etapas, [true(M-R == [ruido(3), contador(3), ruido(2), ruido(1)]-3)]) :-
    ejecutar_fases_de(contador_fases, primera, [contador(0)], M, R).

% Como prioridades, limpiar vuelve a activarse después de cada paso.
test(prioridades, [true(M-R == [contador(3)]-3)]) :-
    ejecutar_prioridades_de(contador_fases, primera, [contador(0)], M, R).

% Con mcd_fases las dos metarreglas dan lo mismo.
test(prioridades_mcd, [forall(member(E, [primera, reciente, especifica])),
                       true(R == 5)]) :-
    ejecutar_prioridades_de(mcd_fases, E,
                            [numero(25), numero(10), numero(15)], _, R).

test(prioridades_vacia, [true(M-R == [a]-nada_aplicable)]) :-
    ejecutar_prioridades([], primera, [a], M, R).

test(primera_fase, [true(Ns == [quitar_ruido])]) :-
    programa_fases(contador_fases, Fs),
    indexar([ruido(1), contador(1)], Mem),
    primera_fase(Fs, Mem, Is),
    findall(N, member(instancia(N, _, _, _), Is), Ns).

test(primera_fase_ninguna, [fail]) :-
    programa_fases(contador_fases, Fs),
    indexar([otro], Mem),
    primera_fase(Fs, Mem, _).

:- end_tests(soluciones_indices).
