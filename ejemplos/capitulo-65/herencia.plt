:- encoding(utf8).

:- begin_tests(herencia).

% Un procesador entra en los nodos de procesador y en los de componente.
test(procesador, [true(Cs == [componente, procesador])]) :-
    clases_que_aceptan(objeto(cpu_a, procesador, [nucleos-6, precio-190]),
                       Cs).

test(catalogo, [forall(( catalogo(Os), member(O, Os) ))]) :-
    clases_que_aceptan(O, Cs),
    memberchk(componente, Cs).

% Un objeto de una clase que ninguna regla nombra no entra en ningún nodo
% de es/3.
test(ajeno, [true(Cs == [])]) :-
    clases_que_aceptan(objeto(x, refrigerado, []), Cs).

test(nodos_por_clase, [true(L == [componente-2, procesador-3, placa-2,
                                  fuente-1, refrigerado-0])]) :-
    findall(C-N, ( member(C, [componente, procesador, placa, fuente,
                              refrigerado]),
                   nodos_por_clase(C, N) ),
            L).

% Con la clase como constante, un procesador no es un componente.
test(literal) :-
    aceptado_literal(objeto(cpu_a, procesador, []), procesador),
    \+ aceptado_literal(objeto(cpu_a, procesador, []), componente).

:- end_tests(herencia).
