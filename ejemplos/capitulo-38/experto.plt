:- encoding(utf8).

:- begin_tests(experto).

test(conversion, [true(C == (avestruz :- ave, (\+ vuela, (peso(P), P > 50))))]) :-
    regla(r12, R),
    regla_clausula(R, C),
    C = (_ :- _, (_, (peso(P), _))).

test(base_original, [true(N == 12)]) :-
    base(original, Cs),
    length(Cs, N).

test(version_desconocida, [error(type_error(oneof([original, vuela, puede_volar]), otra))]) :-
    base(otra, _).

% La base original es estratificada: pinguino y avestruz usan vuela negado,
% una observación, y quedan un estrato más arriba.
test(original_estratificada, [true(Superiores == [1-[avestruz/0, pinguino/0]])]) :-
    estratos(base(original), [0-_|Superiores]).

test(vuela_no_estratificada, [fail]) :-
    estratos(base(vuela), _).

test(ciclos_vuela, [true(P == [avestruz/0-vuela/0, pinguino/0-vuela/0,
                               vuela/0-avestruz/0, vuela/0-pinguino/0])]) :-
    ciclos_negativos(base(vuela), P).

test(puede_volar_estratificada, [true(Superiores == [1-[avestruz/0, pinguino/0],
                                                     2-[puede_volar/0]])]) :-
    estratos(base(puede_volar), [0-_|Superiores]).

% Con la base estratificada, cada caso tiene una respuesta, sin indefinidos.
test(original_casos, [true(Rs == [ resultado([pinguino], []),
                                   resultado([avestruz], []),
                                   resultado([guepardo], []),
                                   resultado([cebra], []) ])]) :-
    findall(R,
            ( member(Os, [ [tiene_plumas, nada, peso(30)],
                           [tiene_plumas, peso(90)],
                           [tiene_pelo, come_carne, color_leonado,
                            manchas_oscuras],
                           [da_leche, tiene_cascos, rayas_negras] ]),
              diagnostico(original, Os, R) ),
            Rs).

% Con r13 en la versión vuela, el pingüino y el avestruz quedan indefinidos.
test(vuela_indefinidos, [true(Rs == [ resultado([], [pinguino]),
                                      resultado([], [avestruz]) ])]) :-
    findall(R,
            ( member(Os, [ [tiene_plumas, nada, peso(30)],
                           [tiene_plumas, peso(90)] ]),
              diagnostico(vuela, Os, R) ),
            Rs).

% Si vuela se observa, deja de estar indefinido y r11 no se aplica.
test(vuela_observado, [true(R == resultado([], []))]) :-
    diagnostico(vuela, [tiene_plumas, vuela, nada], R).

test(puede_volar_casos, [true(Rs == [ resultado([pinguino], []),
                                      resultado([avestruz], []) ])]) :-
    findall(R,
            ( member(Os, [ [tiene_plumas, nada, peso(30)],
                           [tiene_plumas, peso(90)] ]),
              diagnostico(puede_volar, Os, R) ),
            Rs).

% Un ave sin más datos puede volar en la versión corregida.
test(puede_volar, [true(V == verdadero)]) :-
    valor(con_hechos(base(puede_volar), [tiene_plumas]), puede_volar, V).

% con_hechos/2 agrega un hecho por observación al final del programa.
test(con_hechos, [true(Hechos == [(nada :- true), (peso(30) :- true)])]) :-
    base(original, Base),
    clausulas(con_hechos(base(original), [nada, peso(30)]), Cs),
    append(Base, Hechos, Cs).

test(programa_base, [true(Cs =@= Base)]) :-
    base(vuela, Base),
    clausulas(base(vuela), Cs).

% condiciones_cuerpo/2: y pasa a ser la conjunción y no la negación; una
% condición simple queda igual.
test(condiciones_cuerpo, [true(C-D == (a, (\+ b, c))-x)]) :-
    condiciones_cuerpo(a y no b y c, C),
    condiciones_cuerpo(x, D).

:- end_tests(experto).
