:- encoding(utf8).

:- begin_tests(paralelo).

test(camiones, [true(As == [nombre("camión", masculino, plural)])]) :-
    findall(A, forma("camiones", A), As).

test(elijo, [true(Ps == ["elijo"])]) :-
    findall(P, forma(P, verbo("elegir", presente, 1, singular)), Ps).

test(fue, [true(As == [verbo("ir", preterito, 3, singular),
                       verbo("ser", preterito, 3, singular)])]) :-
    findall(A, forma("fue", A), As0),
    sort(As0, As).

test(no_existe, [fail]) :-
    forma("tocé", _).

test(raiz, [true(Ss == [[p, r, o, t, e, 'J', e, r]])]) :-
    findall(S, raiz("proteger", S), Ss).

% Sin el léxico, las reglas admiten 26 formas subyacentes para luces;
% con el léxico, una.
test(sin_lexico, [true(N == 26)]) :-
    reglas(Rs),
    findall(S, transducir(paralelo(Rs), S, [l, u, c, e, s]), Ss),
    length(Ss, N).

% Las dos versiones dan las mismas formas y los mismos análisis para
% todo el léxico.
test(como_la_version_2, [true(Distintas == [])]) :-
    findall(A-P,
            ( reglas:analisis(A),
              reglas:generar(A, P),
              \+ findall(Q, forma(Q, A), [P]) ),
            Distintas).

test(analisis_como_la_version_2, [true(Distintas == [])]) :-
    findall(P,
            ( reglas:analisis(A),
              reglas:generar(A, P),
              findall(B, reglas:forma(P, B), Bs2),
              findall(B, forma(P, B), Bs4),
              msort(Bs2, S),
              \+ msort(Bs4, S) ),
            Distintas).

:- end_tests(paralelo).
