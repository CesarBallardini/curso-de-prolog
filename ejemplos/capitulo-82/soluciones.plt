:- encoding(utf8).

% Pruebas de soluciones.pl.

:- use_module(library(filesex)).

:- begin_tests(soluciones).

test(media_avalancha) :-
    media_avalancha(M),
    M > 100,
    M < 156.

test(entregas_iguales, true(I == [ igual('pack.pl'),
                                   igual('prolog/fechas_castellano.pl'),
                                   igual('prolog/fechas_castellano.plt') ])) :-
    entregas_distintas(paquete31(fechas_castellano),
                       paquete31(fechas_castellano), I).

test(entregas_distintas, true(I == [ falta('pack.pl'),
                                     igual('prolog/fechas_castellano.pl'),
                                     igual('prolog/fechas_castellano.plt') ])) :-
    pack_31(Original),
    tmp_file(pack, Dir),
    copy_directory(Original, Dir),
    directory_file_path(Dir, 'pack.pl', P),
    delete_file(P),
    entregas_distintas(Original, Dir, I),
    delete_directory_and_contents(Dir).

test(fuerza_bruta_registro, true(C == ok)) :-
    registrar(ok, 2, R),
    fuerza_bruta_registro(R, 2, C).

test(alcance, true(L-A == 101-lectura)) :-
    emitir_con_alcance(s, 101, lectura, 1800000000, F),
    validar_con_alcance(s, F, 1700000000, L, A).

test(alcance_cambiado, [fail]) :-
    emitir_con_alcance(s, 101, lectura, 1800000000, F),
    atomic_list_concat([L, _, V, M], '.', F),
    atomic_list_concat([L, inscripcion, V, M], '.', F1),
    validar_con_alcance(s, F1, 1700000000, _, _).

test(alcance_desconocido, [error(type_error(_, _))]) :-
    emitir_con_alcance(s, 101, todo, 1800000000, _).

test(inverso_lineal, true(D1 == D2)) :-
    fi_de_bits(16, F),
    inverso_lineal(65537, F, D1),
    inverso(65537, F, D2).

test(descifrar_crt, true(M1 == M2)) :-
    primo_aleatorio(256, P),
    primo_aleatorio(256, Q),
    P =\= Q,
    claves(P, Q, 65537, Pub, privada(N, D)),
    cifrar(123456789, Pub, C),
    descifrar(C, privada(N, D), M1),
    privada_crt(P, Q, D, Clave),
    descifrar_crt(C, Clave, M2).

test(wiener, true(D1 == D)) :-
    clave_debil(256, 60, Pub, D),
    wiener(Pub, D1).

test(wiener_falla, [fail]) :-
    claves_aleatorias(512, Pub, _),
    wiener(Pub, _).

test(firmar_archivo) :-
    generar(autor_solucion, 1024),
    pack_31(Dir),
    directory_file_path(Dir, 'pack.pl', A),
    firmar_archivo(autor_solucion, A, F),
    verificar_archivo(autor_solucion, A, F),
    read_file_to_string(A, Texto, [encoding(utf8)]),
    firmar_texto(autor_solucion, Texto, F2),
    F == F2.

test(acordar_curva, true(A == B)) :-
    acordar_curva(A, B).

test(intermediario, true(T2-CA-CB == "hola"-KA-KB)) :-
    acordar_con_intermediario(rfc3526_14, CA, CB, ia(KA, KB)),
    sellar(CA, "hola", M),
    reenviar(ia(KA, KB), M, _, M2),
    abrir(CB, M2, T2).

test(intermediario_distintas, true(CA \== CB)) :-
    acordar_con_intermediario(rfc3526_14, CA, CB, _).

:- end_tests(soluciones).
