:- encoding(utf8).

:- begin_tests(experto).

% Con la base original, cada caso tiene una respuesta, sin indefinidos.
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

% Con r13 en la versión vuela, el pingüino y el avestruz quedan indefinidos:
% los mismos valores que calcula bien_fundado/3 en la sección 38.7.
test(vuela_indefinidos, [true(Rs == [ resultado([], [pinguino]),
                                      resultado([], [avestruz]) ])]) :-
    findall(R,
            ( member(Os, [ [tiene_plumas, nada, peso(30)],
                           [tiene_plumas, peso(90)] ]),
              diagnostico(vuela, Os, R) ),
            Rs).

% El ciclo positivo de r4 y r13 termina: ave es falsa para un guepardo.
test(vuela_guepardo, [true(R-V == resultado([guepardo], [])-falso)]) :-
    Os = [tiene_pelo, come_carne, color_leonado, manchas_oscuras],
    diagnostico(vuela, Os, R),
    valor(cierto(vuela, Os, ave), V).

% Sin tabla, el mismo caso entra en el ciclo y no termina.
test(sin_tabla_ciclo, [true(R == inference_limit_exceeded)]) :-
    Os = [tiene_pelo, come_carne, color_leonado, manchas_oscuras],
    call_with_inference_limit(probar_sin_tabla(vuela, Os, pinguino),
                              1000000, R).

% Sin ciclos, el intérprete sin tabla da la misma respuesta.
test(sin_tabla_original, [nondet]) :-
    probar_sin_tabla(original, [tiene_plumas, nada, peso(30)], pinguino).

test(puede_volar, [true(Rs == [ resultado([pinguino], []),
                                resultado([avestruz], []) ])]) :-
    findall(R,
            ( member(Os, [ [tiene_plumas, nada, peso(30)],
                           [tiene_plumas, peso(90)] ]),
              diagnostico(puede_volar, Os, R) ),
            Rs).

% Si vuela se observa, deja de estar indefinido y r11 no se aplica.
test(vuela_observado, [true(R == resultado([], []))]) :-
    diagnostico(vuela, [tiene_plumas, vuela, nada, peso(30)], R).

test(version_desconocida,
     [error(type_error(oneof([original, vuela, puede_volar]), otra))]) :-
    diagnostico(otra, [], _).

% probar/3 recorre las condiciones: la conjunción, la negación con tnot/1
% y las comparaciones.
test(probar_conjuncion_negada, [nondet]) :-
    probar(original, [tiene_plumas, nada, peso(30)], ave y no vuela).

test(probar_negada_falla, [fail]) :-
    probar(original, [tiene_plumas, vuela, pone_huevos], no vuela).

test(probar_comparacion, [all(P == [90])]) :-
    probar(original, [peso(90)], peso(P) y P > 50).

:- end_tests(experto).
