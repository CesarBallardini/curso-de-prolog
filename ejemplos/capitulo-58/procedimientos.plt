:- encoding(utf8).

:- begin_tests(procedimientos).

test(factorial, [true(R == fin([120], [n-5, r-120]))]) :-
    p_correr_caso(factorial, [n-5], R).

test(factorial_cero, [true(R == fin([1], [n-0, r-1]))]) :-
    p_correr_caso(factorial, [n-0], R).

% Alcance estático: mostrar/0 ve la x del bloque principal, no la de
% probar/0, que la llama.
test(alcance, [true(R == fin([1], [x-1]))]) :-
    p_correr_caso(alcance, [], R).

test(cociente, [true(Rs == [fin([14], [a-7, q-14]), fin([100], [a-0, q-100])])]) :-
    p_correr_caso(cociente, [a-7], R1),
    p_correr_caso(cociente, [a-0], R2),
    Rs = [R1, R2].

test(division_por_cero, [true(R == error(division_por_cero))]) :-
    bloque_caso(cociente, bloque(Ds, _), _),
    traducir_sentencias([llamar(dividir, ["a"])], Ss),
    p_correr(bloque(Ds, Ss), [a-0], R).

test(traducir, [true(Ss == [ asignar(r, num(1)),
                             llamar(f, [bin(-, id(n), num(1))]),
                             si(rel(>, id(n), num(0)), [escribir(id(n))],
                                []) ])]) :-
    traducir_sentencias([ "r := 1", llamar(f, ["n - 1"]),
                          si("n > 0", ["escribir n"], []) ],
                        Ss).

test(traducir_invalido, [fail]) :-
    traducir_sentencias(["x :="], _).

test(registro, [true(R == [k-3, x-0, p-proc([], bloque([], []))])]) :-
    p_registro([var(x), proc(p, [], bloque([], []))], 0, [k-3], R).

% El nombre se busca del registro más interior al más exterior.
test(buscar, [true(I-V == 1-7)]) :-
    p_buscar(y, [[x-1], [y-7, x-2]], I, V).

test(buscar_ausente, [fail]) :-
    p_buscar(z, [[x-1]], _, _).

test(poner, [true(P == [[x-1], [y-9, x-2]])]) :-
    p_poner(y, 9, [[x-1], [y-7, x-2]], P).

test(partir, [true(I-D == [[a-1]]-[[b-2], [c-3]])]) :-
    p_partir(1, [[a-1], [b-2], [c-3]], I, D).

test(evaluar, [true(V == 11)]) :-
    p_evaluar(bin(+, id(x), bin(*, num(2), id(y))), [[x-1], [y-5]], V).

test(sentencia_llamar, [true(Sal-P == [3]-[[x-3]])]) :-
    Proc = proc([k], bloque([], [asignar(x, id(k)), escribir(id(x))])),
    phrase(p_sentencia(llamar(p, [num(3)]), [[x-0, p-Proc]], [R]), Sal),
    variables_de([R], P0),
    P = [P0].

test(bloque, [true(Sal-Reg == [2]-[k-1, y-2])]) :-
    phrase(p_bloque(bloque([var(y)], [asignar(y, bin(+, id(k), num(1))),
                                      escribir(id(y))]),
                    [k-1], [], Reg, []),
           Sal).

test(variables_de, [true(Vs == [x-1, y-2])]) :-
    variables_de([[x-1, p-proc([], bloque([], []))], [y-2]], Vs).

test(finales_factorial, [true(Fs == [estado([n-cero, r-pos]),
                                     estado([n-pos, r-pos])])]) :-
    p_finales_caso(factorial, Fs).

% El análisis prueba que cociente no divide por cero: ningún final error.
test(finales_cociente, [true(N-E == 6-false)]) :-
    p_finales_caso(cociente, Fs),
    length(Fs, N),
    (   memberchk(error, Fs)
    ->  E = true
    ;   E = false
    ).

% Llamado con un divisor que puede ser cero, el análisis lo advierte.
test(finales_con_error, [true(E == true)]) :-
    bloque_caso(cociente, bloque(Ds, _), _),
    traducir_sentencias([llamar(dividir, ["a"])], Ss),
    p_finales(bloque(Ds, Ss), [a-entre(inf, sup)], Fs),
    (   memberchk(error, Fs)
    ->  E = true
    ;   E = false
    ).

% dividir/1 solo se llama con un argumento positivo, en los tres contextos.
test(resumenes_cociente, [true(Ls == [[pos], [pos], [pos]])]) :-
    p_resumenes_caso(cociente, Rs),
    findall(Vs, member(resumen(dividir, Vs, _, _), Rs), Ls).

% La recursión de fact/1 termina gracias a la tabla: cuatro contextos.
test(resumenes_factorial, [true(Ls == [[cero], [cero], [neg], [pos]])]) :-
    p_resumenes_caso(factorial, Rs),
    findall(Vs, member(resumen(fact, Vs, _, _), Rs), Ls).

test(efecto_llamar, set(Vs == [[x-pos]])) :-
    Proc = proc([k], bloque([], [asignar(x, id(k))])),
    a_efecto(llamar(p, [num(5)]), pila([[x-cero, p-Proc]]), pila(Pila)),
    variables_de(Pila, Vs).

test(efecto_llamar_error, set(R == [error])) :-
    Proc = proc([k], bloque([], [asignar(x, bin(/, num(1), id(k)))])),
    a_efecto(llamar(p, [num(0)]), pila([[x-cero, p-Proc]]), R).

test(procedimiento, set(R == [pila([[x-pos]])])) :-
    a_procedimiento(p, [k]-bloque([], [asignar(x, id(k))]), [pos],
                    [[x-cero]], R).

% Cada corrida concreta de la ventana termina en un estado que el análisis
% de signos incluye.
test(cubre, [forall(caso_p(N, _, _))]) :-
    bloque_caso(N, B, Es),
    p_finales(B, Es, Fs),
    forall(valores_muestra(Es, Vals),
           ( p_correr(B, Vals, R),
             cubierta(R, Fs) )).

cubierta(error(division_por_cero), Fs) :-
    memberchk(error, Fs).
cubierta(fin(_, Final), Fs) :-
    findall(X-S, ( member(X-V, Final), signo_de(V, S) ), Signos),
    memberchk(estado(Signos), Fs).

test(a_valor, set(S == [cero, neg, pos])) :-
    a_valor(bin(-, id(k), num(1)), [[k-pos]], S).

test(traducir_bloque, [true(B == bloque([var(x), proc(p, [], P)],
                                        [llamar(p, [])]))]) :-
    P = bloque([], [escribir(id(x))]),
    traducir_bloque(bloque([var(x), proc(p, [], bloque([], ["escribir x"]))],
                           [llamar(p, [])]),
                    B).

:- end_tests(procedimientos).
