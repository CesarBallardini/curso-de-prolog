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

:- end_tests(reglas).
