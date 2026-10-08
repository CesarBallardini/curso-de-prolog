:- encoding(utf8).

% Capítulo 24 - Un archivo sin módulo, para comparar consult/1,
% ensure_loaded/1 y use_module/1.
%
% La directiva initialization/1 escribe una línea cada vez que el archivo
% termina de cargarse: consult/1 lo carga de nuevo cada vez, ensure_loaded/1
% solo si no estaba cargado, y use_module/1 lo rechaza porque no empieza con
% la declaración de un módulo.
%
% solo-local: el ejemplo trata de la carga de archivos.
%
%?- aviso(Texto).

:- initialization(format("aviso.pl cargado~n")).

% aviso(T): T es el texto del aviso.
aviso(hola).
