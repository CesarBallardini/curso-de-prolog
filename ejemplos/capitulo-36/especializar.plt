:- encoding(utf8).

:- begin_tests(especializar).

test(regla,
     true(C =@= (antepasado(A, D, prueba(antepasado(A, D), [P1, P2])) :-
                     padre(A, H, P1), antepasado(H, D, P2)))) :-
    especializar((antepasado(A, D) :- padre(A, H), antepasado(H, D)), C).

test(hecho,
     true(C == (padre(juan, ana, prueba(padre(juan, ana), [])) :- true))) :-
    especializar((padre(juan, ana) :- true), C).

% ejecutar/1 se despliega: queda la comparación.
test(predefinido,
     true(C =@= (mayor_que(A, B, prueba(mayor_que(A, B),
                                        [P1, P2, sis(EA > EB)])) :-
                     edad(A, EA, P1), edad(B, EB, P2), EA > EB))) :-
    especializar((mayor_que(A, B) :- edad(A, EA), edad(B, EB), EA > EB), C).

% limpiar/2 marca cada objetivo: prog/1 del programa, sis/1 predefinido.
test(limpiar, true(C == (prog(padre(a, b)), sis(3 > 1), true))) :-
    limpiar((padre(a, b), 3 > 1, true), C).

test(con_prueba, true(M == padre(a, b, P))) :-
    con_prueba(padre(a, b), P, M).

% Los árboles especializados son los del intérprete, en el mismo orden.
test(como_el_interprete, true(Ps == Rs)) :-
    instalar([padre/2, antepasado/2]),
    findall(A-D-P, esp:antepasado(A, D, P), Ps),
    findall(A-D-P, resolver(antepasado(A, D), P), Rs).

test(mayor_que, true(Ps == Rs)) :-
    instalar([edad/2, mayor_que/2]),
    findall(P, esp:mayor_que(juan, _, P), Ps),
    findall(P, resolver(mayor_que(juan, _), P), Rs).

% Instalar dos veces no duplica las cláusulas.
test(instalar_dos_veces, true(N == 4)) :-
    instalar([padre/2]),
    instalar([padre/2]),
    aggregate_all(count, esp:padre(_, _, _), N).

test(longitud, true(T1 == T2)) :-
    instalar([longitud/2]),
    numlist(1, 50, L),
    resolver(longitud(L, _), T1),
    esp:longitud(L, _, T2).

% El intérprete usa diez veces más inferencias que la versión
% especializada.
test(diez_veces, true(I1 > 9 * I2)) :-
    instalar([longitud/2]),
    numlist(1, 1000, L),
    inferencias(resolver(longitud(L, _), _), I1),
    inferencias(esp:longitud(L, _, _), I2).

:- end_tests(especializar).

%!  inferencias(:G, -N:integer) is det.
%
%   N es la cantidad de inferencias de una ejecución de G.
inferencias(G, N) :-
    statistics(inferences, I0),
    once(G),
    statistics(inferences, I1),
    N is I1 - I0.
