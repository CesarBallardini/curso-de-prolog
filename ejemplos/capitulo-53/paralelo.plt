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

% leer_pares(R, Pares, D0, D): la regla R lee los Pares desde D0.
leer_pares(_, [], D, D).
leer_pares(R, [P|Ps], D0, D) :-
    paso(P, R, D0, D1),
    leer_pares(R, Ps, D1, D).

test(inicial_regla, [true(D == [bucle, inicio, p(1, 0), p(2, 0), p(3, 0),
                                p(4, 0), p(5, 0), p(6, 0)])]) :-
    inicial_regla(z, D).

test(regla_acepta, [nondet]) :-
    inicial_regla(z, D0),
    leer_pares(z, [[l]:[l], [u]:[u], [z]:[c], [+]:[], []:[e], [s]:[s]],
               D0, D),
    acepta_regla(z, D).

% z escrita z ante una e: paso/4 falla en el medio de la palabra.
test(regla_rechaza_en_el_medio, [fail]) :-
    inicial_regla(z, D0),
    leer_pares(z, [[l]:[l], [u]:[u], [z]:[z], [+]:[], []:[e], [s]:[s]],
               D0, _).

% z escrita c al final: el patrón se completa al terminar la palabra.
test(regla_rechaza_al_final, [fail]) :-
    inicial_regla(z, D0),
    leer_pares(z, [[l]:[l], [u]:[u], [z]:[c]], D0, D),
    acepta_regla(z, D).

:- end_tests(paralelo).
