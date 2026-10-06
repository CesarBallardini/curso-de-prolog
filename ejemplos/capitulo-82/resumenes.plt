:- encoding(utf8).

% Pruebas de resumenes.pl: los resúmenes de textos conocidos, el
% manifiesto del pack del capítulo 31 y su verificación sobre una copia
% que las pruebas modifican.

:- use_module(library(filesex)).

%!  copia_del_pack(-Dir:atom) is det.
%
%   Dir es un directorio temporal nuevo con una copia del pack del
%   capítulo 31.
copia_del_pack(Dir) :-
    pack_31(Original),
    tmp_file(pack, Dir),
    copy_directory(Original, Dir).

:- begin_tests(resumenes).

test(resumen_vacio, true(H == e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855)) :-
    resumen("", H).

test(resumen_abc, true(H == ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad)) :-
    resumen(abc, H).

test(resumen_formas, true(H1 == H2)) :-
    resumen("Inscripciones", H1),
    resumen('Inscripciones', H2).

test(resumen_utf8, true(H1 == H2)) :-
    resumen("ñ", H1),
    crypto_data_hash([195, 177], H2, [algorithm(sha256), encoding(octet)]).

test(resumen_instanciado) :-
    resumen(abc, ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad).

test(resumen_instanciado_distinto, [fail]) :-
    resumen(abd, ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad).

test(bits_iguales, true(N == 0)) :-
    resumen(abc, H),
    bits_distintos(H, H, N).

test(bits_avalancha, true(N == 122)) :-
    resumen(abc, H1),
    resumen(abd, H2),
    bits_distintos(H1, H2, N).

% Los valores esperados son los de la orden sha256sum.
test(como_sha256sum, true(Es == ['pack.pl'-'12184a89ee8bf395c29c202bb95ef2098731418153c487b130b8ed36dd70b9b2',
                                 'prolog/fechas_castellano.pl'-'37e03fb3c85f072f62dea0f58cbf1c2252929fbdfa8e6cf1424588731a81259e',
                                 'prolog/fechas_castellano.plt'-'6860f571afc3653a260e7deadcb7989813d015a347895c9545285b798a16edbf'])) :-
    manifiesto(paquete31(fechas_castellano), Es).

test(archivos, true(Rs == ['pack.pl', 'prolog/fechas_castellano.pl',
                           'prolog/fechas_castellano.plt'])) :-
    pack_31(Dir),
    archivos(Dir, Rs).

test(manifiesto_ida_y_vuelta, true(Es1 == Es)) :-
    pack_31(Dir),
    manifiesto(Dir, Es),
    manifiesto_texto(Es, T),
    texto_manifiesto(T, Es1).

test(texto_formato, true(T == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855  a/b.pl\n")) :-
    manifiesto_texto(['a/b.pl'-e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855], T).

test(texto_mal_formado, [fail]) :-
    texto_manifiesto("abc  pack.pl\n", _).

test(intacto) :-
    pack_31(Dir),
    manifiesto(Dir, Es),
    intacto(Dir, Es).

test(modificado, true(I == [ igual('pack.pl'),
                             distinto('prolog/fechas_castellano.pl'),
                             igual('prolog/fechas_castellano.plt') ])) :-
    pack_31(Original),
    manifiesto(Original, Es),
    copia_del_pack(Dir),
    directory_file_path(Dir, 'prolog/fechas_castellano.pl', F),
    setup_call_cleanup(open(F, append, S), format(S, "% agregado~n", []),
                       close(S)),
    verificar(Dir, Es, I),
    delete_directory_and_contents(Dir).

test(falta_y_sobra, true(I == [ igual('LEEME'), falta('pack.pl'),
                                sobra('pack1.pl'),
                                igual('prolog/fechas_castellano.pl'),
                                igual('prolog/fechas_castellano.plt') ])) :-
    copia_del_pack(Dir),
    directory_file_path(Dir, 'LEEME', L),
    setup_call_cleanup(open(L, write, S), format(S, "leer~n", []), close(S)),
    manifiesto(Dir, Es),
    directory_file_path(Dir, 'pack.pl', P),
    directory_file_path(Dir, 'pack1.pl', P1),
    rename_file(P, P1),
    verificar(Dir, Es, I),
    delete_directory_and_contents(Dir).

test(no_intacto, [fail]) :-
    pack_31(Original),
    manifiesto(Original, Es),
    copia_del_pack(Dir),
    directory_file_path(Dir, 'pack.pl', P),
    delete_file(P),
    (   intacto(Dir, Es)
    ->  delete_directory_and_contents(Dir)
    ;   delete_directory_and_contents(Dir),
        fail
    ).

:- end_tests(resumenes).
