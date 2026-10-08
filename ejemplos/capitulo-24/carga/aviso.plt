:- encoding(utf8).

% Durante la ejecución, un nombre relativo se busca desde el directorio de
% trabajo. Las pruebas guardan, mientras se carga este archivo, la ruta
% completa de aviso.pl.
:- dynamic ruta_de_aviso/1.

:- prolog_load_context(directory, Directorio),
   atom_concat(Directorio, '/aviso.pl', Ruta),
   assertz(ruta_de_aviso(Ruta)).

:- begin_tests(aviso).

test(aviso, true(T == hola)) :-
    aviso(T).

% El archivo ya está cargado: ensure_loaded/1 no lo vuelve a cargar, y la
% directiva initialization/1 no escribe nada. La carga se pide en user, donde
% está el archivo: las pruebas corren en su propio módulo.
% with_output_to/2, que captura la salida, se presenta en el capítulo 27.
test(ensure_loaded_no_recarga, true(S == "")) :-
    ruta_de_aviso(Ruta),
    with_output_to(string(S), user:ensure_loaded(Ruta)).

% consult/1 lo carga de nuevo.
test(consult_recarga, true(S == "aviso.pl cargado\n")) :-
    ruta_de_aviso(Ruta),
    with_output_to(string(S), user:consult(Ruta)).

:- end_tests(aviso).
