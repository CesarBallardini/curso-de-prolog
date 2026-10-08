:- encoding(utf8).

:- begin_tests(soluciones_operadores).

%!  leer(+Texto:string, -Canonico:string) is det.
%
%   Canonico es la forma canónica del término Texto, leído con los
%   operadores de este archivo. with_output_to/2, que captura la salida, se
%   presenta en el capítulo 27.
leer(Texto, Canonico) :-
    term_string(T, Texto),
    with_output_to(string(Canonico), write_canonical(T)).

% Ejercicio 1
test(es_un, true(C == "es_un(_,mago)")) :-
    leer("X es_un mago", C).

test(son, true(C == "son(y(ana,y(luis,eva)),amigos)")) :-
    leer("ana y luis y eva son amigos", C).

% gusta_de tiene precedencia 300 y no puede ser argumento de y, que es 200.
test(choque, [error(syntax_error(operator_clash), _)]) :-
    leer("ana es_un maga y gusta_de ajedrez", _).

test(famoso, true(C == "es_un(merlin,famoso(mago))")) :-
    leer("merlin es_un famoso mago", C).

% Ejercicio 2
test(que_es_rojo, true(X == de(de(el_auto, la_hermana), ana))) :-
    X es rojo.

test(de_quien, true(X-Y == de(el_auto, la_hermana)-ana)) :-
    X de Y es rojo.

test(el_auto_de, [fail]) :-
    el_auto de _ es rojo.

% Con de como xfy, la misma expresión se agrupa a la derecha. La prueba
% cambia la declaración y la restaura al terminar.
test(de_como_xfy,
     [ setup(op(400, xfy, de)),
       cleanup(op(400, yfx, de)),
       true(C == "de(el_auto,de(la_hermana,ana))") ]) :-
    leer("el_auto de la_hermana de ana", C).

% Ejercicio 3
test(implica, true(V == f)) :-
    valor(no (v y f) implica f, V).

test(y_antes_que_o, true(C-V == "o(v,y(f,f))"-v)) :-
    leer("v o f y f", C),
    valor(v o f y f, V).

test(doble_negacion, true(V == v)) :-
    valor(no no v, V).

test(tabla_de_implica,
     all(A-B-V == [v-v-v, v-f-f, f-v-v, f-f-v])) :-
    member(A, [v, f]),
    member(B, [v, f]),
    valor(A implica B, V).

% Ejercicio 6: con -> en 700 xfx, la condición X > 0 -> T ya no se puede
% leer, y una conjunción antes de -> queda fuera del condicional. Las pruebas
% cambian la declaración y la restauran al terminar.
test(flecha_redefinida_choca,
     [ setup(op(700, xfx, ->)),
       cleanup(op(1050, xfy, ->)),
       error(syntax_error(operator_clash), _) ]) :-
    leer("( X > 0 -> t ; e )", _).

test(flecha_redefinida_agrupa,
     [ setup(op(700, xfx, ->)),
       cleanup(op(1050, xfy, ->)),
       true(C == ";(','(a,->(b,c)),d)") ]) :-
    leer("( a, b -> c ; d )", C).

test(flecha_restaurada, true(C == ";(->(','(a,b),c),d)")) :-
    leer("( a, b -> c ; d )", C).

% Ejercicio 9
test(igual_no_se_encadena, [error(syntax_error(operator_clash), _)]) :-
    leer("a = b = c", _).

test(potencia_antes_que_producto, true(C == "+(1,*(2,^(3,2)))")) :-
    leer("1 + 2 * 3 ^ 2", C).

test(menos_prefijo, true(C == "+(-(1),2)")) :-
    leer("- 1 + 2", C).

test(todos_los_de_700_son_xfx) :-
    forall(current_op(700, T, _), T == xfx).

% Ejercicio 12
test(requisitos_de_am2, all(R == [am1, alg])) :-
    correlativa(am2, R).

test(requisitos_de_pp, all(R == [log])) :-
    correlativa(pp, R).

test(materias_que_requieren_log, all(M == [pp, ssl])) :-
    correlativa(M, log).

test(sin_requisitos, all(R == [])) :-
    correlativa(am1, R).

:- end_tests(soluciones_operadores).
