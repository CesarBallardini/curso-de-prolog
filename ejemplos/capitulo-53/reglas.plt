:- encoding(utf8).

:- begin_tests(reglas).

% generado(A, P): la forma que la versión 2 genera para A.
generado(A, P) :-
    once(generar(A, P)).

test(ortografia, [true(Ps == ["toqué", "llegué", "cacé", "venzo",
                              "protejo", "sigues", "hizo"])]) :-
    maplist(generado,
            [ verbo("tocar", preterito, 1, singular),
              verbo("llegar", preterito, 1, singular),
              verbo("cazar", preterito, 1, singular),
              verbo("vencer", presente, 1, singular),
              verbo("proteger", presente, 1, singular),
              verbo("seguir", presente, 2, singular),
              verbo("hacer", preterito, 3, singular) ],
            Ps).

test(plurales, [true(Ps == ["luces", "lápices", "camiones", "exámenes",
                            "árboles", "sofás", "meses"])]) :-
    maplist(generado,
            [ nombre("luz", femenino, plural),
              nombre("lápiz", masculino, plural),
              nombre("camión", masculino, plural),
              nombre("examen", masculino, plural),
              nombre("árbol", masculino, plural),
              nombre("sofá", masculino, plural),
              nombre("mes", masculino, plural) ],
            Ps).

test(adjetivos, [true(Ps == ["inglesa", "alemanes", "jóvenes", "felices"])]) :-
    maplist(generado,
            [ adjetivo("inglés", femenino, singular),
              adjetivo("alemán", masculino, plural),
              adjetivo("joven", femenino, plural),
              adjetivo("feliz", masculino, plural) ],
            Ps).

test(raices, [true(Ps == ["cuento", "contamos", "pienso", "pido",
                          "pidió", "durmieron", "elijo", "tengo",
                          "tuvo"])]) :-
    maplist(generado,
            [ verbo("contar", presente, 1, singular),
              verbo("contar", presente, 1, plural),
              verbo("pensar", presente, 1, singular),
              verbo("pedir", presente, 1, singular),
              verbo("pedir", preterito, 3, singular),
              verbo("dormir", preterito, 3, plural),
              verbo("elegir", presente, 1, singular),
              verbo("tener", presente, 1, singular),
              verbo("tener", preterito, 3, singular) ],
            Ps).

% Cada análisis tiene una sola forma.
test(una_forma, [true(Varias == [])]) :-
    findall(A, ( analisis(A),
                 findall(P, generar(A, P), [_, _|_]) ),
            Varias).

test(fue, [true(As == [verbo("ser", preterito, 3, singular),
                       verbo("ir", preterito, 3, singular)])]) :-
    findall(A, forma("fue", A), As).

test(cuentas, [true(As == [verbo("contar", presente, 2, singular)])]) :-
    findall(A, forma("cuentas", A), As).

% escribir/2 en sentido inverso da la forma subyacente del lema.
test(subyacente, [true(Ss == [[p, r, o, t, e, 'J', e, r]])]) :-
    findall(S, subyacente("proteger", S), Ss).

test(tejer, [true(Ss == [[t, e, j, e, r]])]) :-
    findall(S, subyacente("tejer", S), Ss).

test(escribir, all(E == [[q, u, e, s, o]])) :-
    escribir([k, e, s, o], E).

test(frontal, [true(Fs == [[e], [i], ['é'], [i, a]])]) :-
    include(reglas:frontal, [[e], [i], [a], ['é'], [], [i, a], [o, e]], Fs).

test(acento_en_la_raiz,
     [true(Ts == ["o", "as", "en"])]) :-
    include(reglas:acento_en_la_raiz,
            ["o", "as", "amos", "é", "aron", "ió", "en", ""], Ts).

test(epentesis, [true(Ss == [[l, u, z, +, e, s], [l, i, b, r, o, +, s],
                             [l, u, z]])]) :-
    maplist(reglas:epentesis, [[l, u, z, +, s], [l, i, b, r, o, +, s],
                               [l, u, z]], Ss).

test(tildes, [true(Ss == [[k, a, m, i, o, n, +, e, s],
                          [j, 'ó', v, e, n, +, e, s],
                          [s, o, f, 'á', +, s]])]) :-
    maplist(reglas:tildes, [[k, a, m, i, 'ó', n, +, e, s],
                            [j, o, v, e, n, +, e, s],
                            [s, o, f, 'á', +, s]], Ss).

test(superficie, [true(Es == [[l, u, c, e, s], [c, a, m, i, o, n, e, s],
                              [t, o, q, u, 'é']])]) :-
    maplist(una_superficie, [[l, u, z, +, s], [k, a, m, i, 'ó', n, +, s],
                             [t, o, k, +, 'é']], Es).

% una_superficie(S, E): E es la única forma escrita de S.
una_superficie(S, E) :-
    findall(E0, superficie(S, E0), [E]).

test(lexica_regular, all(S == [[k, u, e, n, t, +, o]])) :-
    lexica(verbo("contar", presente, 1, singular), S).

% Una forma listada bloquea la regular: no hay límite que separar.
test(lexica_irregular, all(S == [[s, o, y]])) :-
    lexica(verbo("ser", presente, 1, singular), S).

test(lexica_sin_lema, [fail]) :-
    lexica(nombre("xyz", masculino, plural), _).

test(raiz_verbal, [true(Rs == [[k, u, e, n, t], [k, o, n, t], [d, u, r, m],
                               [a, m], [p, i, d]])]) :-
    reglas:raiz_verbal(o_ue, a, presente, 1, "o", [k, o, n, t], R1),
    reglas:raiz_verbal(o_ue, a, presente, 1, "amos", [k, o, n, t], R2),
    reglas:raiz_verbal(o_ue, i, preterito, 3, "ió", [d, o, r, m], R3),
    reglas:raiz_verbal(regular, a, presente, 1, "o", [a, m], R4),
    reglas:raiz_verbal(e_i, i, preterito, 3, "ieron", [p, e, d], R5),
    Rs = [R1, R2, R3, R4, R5].

:- end_tests(reglas).
