:- encoding(utf8).

:- begin_tests(precompilar).

% El .qlf queda junto al fuente, y cargarlo da los mismos hechos.
test(qlf, [ setup(directorio(D)),
            cleanup(delete_directory_and_contents(D)),
            true(N-Nombre == 100-'cuadrados.pl') ]) :-
    directory_file_path(D, 'cuadrados.pl', Pl),
    generar_cuadrados(Pl, 100),
    precompilar(Pl),
    file_name_extension(Base, pl, Pl),
    file_name_extension(Base, qlf, Qlf),
    assertion(exists_file(Qlf)),
    unload_file(Pl),
    user:consult(Qlf),
    aggregate_all(count, user:cuadrado(_, _), N),
    source_file(user:cuadrado(_, _), Origen),
    file_base_name(Origen, Nombre),
    unload_file(Pl).

% El .qlf guarda las cláusulas ya expandidas: al cargarlo, term_expansion/2
% no vuelve a ejecutarse, y el fuente no hace falta. veces/1 registra
% cuántas expansiones hubo; el .qlf guarda su hecho inicial, y sigue en 0.
test(expandido, [ setup(directorio(D)),
                  cleanup(delete_directory_and_contents(D)),
                  true(Hs-Veces == [ana, pedro]-0) ]) :-
    directory_file_path(D, 'familia.pl', Pl),
    setup_call_cleanup(open(Pl, write, S),
                       format(S, "~w~n~w~n~w~n~w~n",
                              [ ':- dynamic veces/1.',
                                'veces(0).',
                                'term_expansion(padres(P, Hs), Cs) :- \c
                                 retract(veces(N)), N1 is N + 1, \c
                                 assertz(veces(N1)), \c
                                 findall(padre(P, H), member(H, Hs), Cs).',
                                'padres(juan, [ana, pedro]).' ]),
                       close(S)),
    precompilar(Pl),
    unload_file(Pl),
    delete_file(Pl),
    file_name_extension(Base, pl, Pl),
    file_name_extension(Base, qlf, Qlf),
    user:consult(Qlf),
    findall(H, user:padre(juan, H), Hs),
    once(user:veces(Veces)),
    unload_file(Pl).

test(escribir_cuadrados,
     true(S == "cuadrado(1, 1).\ncuadrado(2, 4).\n")) :-
    with_output_to(string(S), escribir_cuadrados(current_output, 2)).

:- end_tests(precompilar).

%!  directorio(-D) is det.
%
%   D es un directorio temporal nuevo.
directorio(D) :-
    tmp_file(qlf, D),
    make_directory(D).
