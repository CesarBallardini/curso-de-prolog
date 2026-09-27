:- encoding(utf8).

% Capítulo 13 - Un archivo de inicio para SWI-Prolog.
%
% SWI-Prolog lo carga al arrancar desde %APPDATA%\swi-prolog\init.pl en
% Windows y desde ~/.config/swi-prolog/init.pl en Linux. Este define el editor
% que abre edit/1: Visual Studio Code, en la línea del predicado, esperando a
% que se cierre el archivo para recargar el programa con make/0.
%
% solo-local: cambia banderas del sistema y declara un gancho de library(edit).
%?- current_prolog_flag(editor, E).

:- set_prolog_flag(editor, code).

:- multifile prolog_edit:edit_command/2.

%!  prolog_edit:edit_command(+Editor, -Comando) is nondet.
%
%   Comando es la línea de comandos que abre Editor en un archivo y una
%   línea: %e es el editor, %f el archivo y %d la línea. --wait hace que
%   edit/1 espere a que el archivo se cierre antes de ejecutar make/0.
prolog_edit:edit_command(code, '"%e" --wait --goto "%f:%d"').
