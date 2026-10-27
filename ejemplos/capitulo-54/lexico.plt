:- encoding(utf8).

:- begin_tests(lexico).

test(femeninos, [true(Ns == ["casa", "luz", "canción", "imagen"])]) :-
    findall(N, nombre(N, femenino), Ns).

test(diptongo, [true(Vs == ["contar", "volver", "dormir"])]) :-
    findall(V, verbo(V, o_ue), Vs).

% ser e ir comparten el pretérito.
test(fue, [true(Ls == ["ser", "ir"])]) :-
    findall(L, irregular(L, preterito, 3, singular, "fue"), Ls).

test(terminacion, all(T == ["ió"])) :-
    terminacion(i, preterito, 3, singular, T).

test(fuerte, all(T == ["o"])) :-
    terminacion(fuerte, preterito, 3, singular, T).

:- end_tests(lexico).
