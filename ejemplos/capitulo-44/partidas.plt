:- encoding(utf8).

:- use_module(estado).

:- begin_tests(partidas, [setup(iniciar), cleanup(iniciar)]).

%!  con_archivo(-Archivo, :Objetivo) is semidet.
%
%   Ejecuta Objetivo con Archivo ligado a un archivo temporal, que se borra
%   al terminar.
con_archivo(Archivo, Objetivo) :-
    tmp_file(partida, Archivo),
    setup_call_cleanup(true, once(Objetivo),
                       ( exists_file(Archivo) -> delete_file(Archivo)
                       ; true )).

%!  escribir(+Archivo, +Texto:string) is det.
%
%   Escribe Texto en Archivo.
escribir(Archivo, Texto) :-
    setup_call_cleanup(open(Archivo, write, Out, [encoding(utf8)]),
                       write(Out, Texto),
                       close(Out)).

test(ida_y_vuelta, true(H == H0)) :-
    iniciar,
    maplist(realizar, [ir(biblioteca), tomar(llave), ir(vestibulo)], _),
    instantanea(H0),
    con_archivo(A, ( guardar(A), iniciar, cargar(A) )),
    instantanea(H).

test(el_archivo_es_texto, true(Primera == "aqui(vestibulo).")) :-
    iniciar,
    con_archivo(A, ( guardar(A), read_file_to_string(A, Texto, []) )),
    split_string(Texto, "\n", "", [Primera|_]).

test(no_ejecuta_directivas, [ error(domain_error(hecho_de_estado,
                                                 (:- halt))),
                              cleanup(assertion(aqui(vestibulo))) ]) :-
    iniciar,
    con_archivo(A, ( escribir(A, ":- halt.\naqui(cupula).\n"), cargar(A) )).

test(hecho_desconocido, [ error(domain_error(hecho_de_estado,
                                             esta_en(dragon, cupula))),
                          cleanup(assertion(aqui(vestibulo))) ]) :-
    iniciar,
    con_archivo(A, ( escribir(A, "aqui(cupula).\nesta_en(dragon, cupula).\n"),
                     cargar(A) )).

test(sintaxis, error(syntax_error(_))) :-
    con_archivo(A, ( escribir(A, "aqui(cupula\n"), cargar(A) )).

test(no_existe, error(existence_error(source_sink, _))) :-
    cargar('no-existe.partida').

:- end_tests(partidas).
