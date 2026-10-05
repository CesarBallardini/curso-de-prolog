:- encoding(utf8).

% Pruebas de firmas.pl: el llavero con un par de claves de 1024 bits
% generado al empezar la unidad, las firmas de textos, el relleno visto
% con powm y la entrega del pack del capítulo 31 publicada en un
% directorio temporal.

:- use_module(library(filesex)).
:- use_module(rsa, [verificar/3]).
:- use_module(resumenes, [resumen/2, pack_31/1]).

%!  preparar_llavero is det.
%
%   Genera el par del autor, y guarda su clave pública con otro nombre,
%   como la guarda quien verifica.
preparar_llavero :-
    generar(autor_de_prueba, 1024),
    exportar(autor_de_prueba, Pub),
    importar(copia_de_prueba, Pub).

%!  directorio_temporal(-Dir:atom) is det.
%
%   Dir es un directorio vacío nuevo.
directorio_temporal(Dir) :-
    tmp_file(entrega, Dir),
    make_directory(Dir).

:- begin_tests(firmas, [setup(preparar_llavero)]).

test(clave_formato, true(E == 65537)) :-
    exportar(autor_de_prueba, Pub),
    publica(Pub, publica(N, E)),
    1024 =:= msb(N) + 1.

test(clave_rsa_coherente) :-
    clave_rsa(512, private_key(rsa(HN, HE, _, _, _, _, _, _)),
              public_key(rsa(HN, HE, -, -, -, -, -, -))).

test(clave_desde_primos, true(Pub == public_key(rsa(ca1, '10001', -, -, -, -, -, -)))) :-
    clave_desde_primos(61, 53, _, Pub).

test(clave_desde_primos_imposible, [fail]) :-
    clave_desde_primos(65537, 131075, _, _).

test(huella, true(H1-N == H2-4)) :-
    huella(autor_de_prueba, H1),
    huella(copia_de_prueba, H2),
    atomic_list_concat(Partes, ':', H1),
    length(Partes, N).

test(huella_otra, true(H1 \== H2)) :-
    generar(otro_de_prueba, 512),
    huella(autor_de_prueba, H1),
    huella(otro_de_prueba, H2).

test(compartir, [fail]) :-
    generar(otro_autor, 512),
    compartir(otro_autor, otro_alumno),
    firmar_texto(otro_alumno, abc, _).

test(firmar_y_verificar) :-
    firmar_texto(autor_de_prueba, "Inscripciones 1.0.0", F),
    verificar_texto(copia_de_prueba, "Inscripciones 1.0.0", F).

test(firmar_sin_privada, [fail]) :-
    firmar_texto(copia_de_prueba, "Inscripciones 1.0.0", _).

test(firma_determinista, true(F1 == F2)) :-
    firmar_texto(autor_de_prueba, "Inscripciones", F1),
    firmar_texto(autor_de_prueba, "Inscripciones", F2).

test(verificar_otro_texto, [fail]) :-
    firmar_texto(autor_de_prueba, "Inscripciones 1.0.0", F),
    verificar_texto(copia_de_prueba, "Inscripciones 1.0.1", F).

test(verificar_otra_clave, [fail]) :-
    generar(otro_de_prueba, 1024),
    firmar_texto(autor_de_prueba, "Inscripciones", F),
    verificar_texto(otro_de_prueba, "Inscripciones", F).

test(bloque_firmado, true(H == Esperado)) :-
    firmar_texto(autor_de_prueba, abc, F),
    bloque_firmado(copia_de_prueba, F, B),
    atom_length(B, 256),
    relleno_pkcs1(B, H),
    resumen(abc, Esperado).

test(bloque_como_rsa) :-
    firmar_texto(autor_de_prueba, abc, F),
    bloque_firmado(copia_de_prueba, F, B),
    atom_concat('0x', B, TB), atom_number(TB, M),
    atom_concat('0x', F, TF), atom_number(TF, S),
    exportar(copia_de_prueba, Pub),
    publica(Pub, Clave),
    verificar(M, S, Clave).

test(relleno_malo, [fail]) :-
    relleno_pkcs1('0002ffffffffffffffff00', _).

test(entrega_intacta, true(R == intacta)) :-
    pack_31(Dir),
    directorio_temporal(D),
    publicar(Dir, autor_de_prueba, D),
    comprobar_entrega(Dir, D, copia_de_prueba, R),
    delete_directory_and_contents(D).

test(publicar_sin_privada, [fail]) :-
    pack_31(Dir),
    directorio_temporal(D),
    (   publicar(Dir, copia_de_prueba, D)
    ->  delete_directory_and_contents(D)
    ;   delete_directory_and_contents(D),
        fail
    ).

test(entrega_alterada, true(R == alterada([distinto('pack.pl')]))) :-
    pack_31(Original),
    tmp_file(pack, Dir),
    copy_directory(Original, Dir),
    directorio_temporal(D),
    publicar(Dir, autor_de_prueba, D),
    directory_file_path(Dir, 'pack.pl', P),
    setup_call_cleanup(open(P, append, S), format(S, "% otro~n", []),
                       close(S)),
    comprobar_entrega(Dir, D, copia_de_prueba, R),
    delete_directory_and_contents(D),
    delete_directory_and_contents(Dir).

test(manifiesto_cambiado, true(R == firma_invalida)) :-
    pack_31(Dir),
    directorio_temporal(D),
    publicar(Dir, autor_de_prueba, D),
    directory_file_path(D, 'SHA256SUMS', Sumas),
    setup_call_cleanup(open(Sumas, append, S),
                       format(S, "~a  extra.pl~n", [e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855]),
                       close(S)),
    comprobar_entrega(Dir, D, copia_de_prueba, R),
    delete_directory_and_contents(D).

:- end_tests(firmas).
