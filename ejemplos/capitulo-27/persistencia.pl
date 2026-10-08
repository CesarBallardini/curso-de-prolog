:- encoding(utf8).

% Capítulo 27 - library(persistency): hechos dinámicos que persisten en un
% archivo.
%
% La directiva persistent/1 declara nota_guardada/3 con el tipo de cada
% argumento, y genera assert_nota_guardada/3 y retract_nota_guardada/3. Con
% un archivo asociado por db_attach/2, cada cambio se agrega al archivo, y
% al volver a asociarlo los hechos se recuperan.
%
% solo-local: el sandbox de SWISH no permite leer ni escribir archivos.
%
%?- tmp_file(notas, F), abrir_notas(F), registrar(101, am1, 8), notas(N).

:- use_module(library(persistency)).

:- persistent
    nota_guardada(legajo:integer, materia:atom, nota:between(1, 10)).

%!  abrir_notas(+Archivo) is det.
%
%   Asocia Archivo a las notas guardadas: carga las que tiene, y los cambios
%   siguientes se le agregan. db_attach/2 asocia el archivo a los hechos
%   persistentes del módulo que lo llama; por eso se llama desde aquí.
abrir_notas(Archivo) :-
    db_attach(Archivo, []).

%!  cerrar_notas is det.
%
%   Cierra el archivo asociado y olvida las notas cargadas.
cerrar_notas :-
    db_detach.

%!  registrar(+Legajo:integer, +Materia:atom, +Nota:integer) is det.
%
%   Guarda la nota del alumno Legajo en Materia, y reemplaza la anterior si
%   había una. Produce un error de tipo si algún argumento no es del tipo
%   declarado.
registrar(Legajo, Materia, Nota) :-
    retractall_nota_guardada(Legajo, Materia, _),
    assert_nota_guardada(Legajo, Materia, Nota).

%!  notas(-Notas:list) is det.
%
%   Notas son los términos Legajo-Materia-Nota guardados, en orden.
notas(Notas) :-
    findall(L-M-N, nota_guardada(L, M, N), Todas),
    sort(Todas, Notas).
