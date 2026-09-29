:- encoding(utf8).

% Capítulo 65 - Versión 3: refutadores y presunciones.
%
% Un refutador, Cabeza :^ Cuerpo, no permite concluir Cabeza: solo impide
% que una regla rebatible de cabeza contraria se aplique. Un ave enferma
% podría no volar; un pingüino alterado genéticamente podría volar. Una
% presunción es una regla rebatible de cuerpo true: Superman vuela, salvo
% que algo lo impida. Con una presunción negativa, el supuesto de mundo
% cerrado se decide predicado por predicado: si un ave estuviera anillada,
% el registro lo diría. Las presunciones sobre las piezas de un automóvil
% predicen que arranca; la observación de que uno no arranca derrota esa
% predicción.
%
% solo-local: carga el módulo rebatible, y SWISH no admite módulos propios.
%
%?- respuesta([especificidad], vuela(coco), R).
%?- respuesta([especificidad], vuela(folio), R).
%?- respuesta([especificidad], anillada(opus), R).
%?- respuesta([especificidad], arranca(auto2), R).

:- use_module(rebatible).

% pinguino_alterado(X): X es un pingüino alterado genéticamente.
pinguino_alterado(folio).

% enferma(X): X está enferma.
enferma(coco).
enferma(superman).

% anillada(X): el registro dice que el ave X está anillada.
anillada(tweety).

% neg arranca(A): se observó que el automóvil A no arranca.
neg arranca(auto2).

%!  ave(?X) is nondet.
%
%   X es un ave: Tweety, Coco, o cualquier pingüino.
ave(tweety).
ave(coco).
ave(X) :-
    pinguino(X).

%!  pinguino(?X) is nondet.
%
%   X es un pingüino: Opus, o cualquier pingüino alterado genéticamente.
pinguino(opus).
pinguino(X) :-
    pinguino_alterado(X).

%!  arranca(?A) is nondet.
%
%   El automóvil A arranca si la batería, el motor de arranque y el
%   combustible están bien.
arranca(A) :-
    bien(A, bateria),
    bien(A, arranque),
    bien(A, combustible).

% Las aves normalmente vuelan; los pingüinos normalmente no; Superman,
% presumiblemente, sí.
vuela(X) :~ ave(X).
neg vuela(X) :~ pinguino(X).
vuela(superman) :~ true.

% Mundo cerrado para anillada/1: ningún ave está anillada, salvo que el
% registro lo diga.
neg anillada(_Ave) :~ true.

% Las piezas de todo automóvil presumiblemente están bien.
bien(_Auto, _Pieza) :~ true.

% Un ave enferma podría no volar; un pingüino alterado podría volar.
neg vuela(X) :^ ave(X), enferma(X).
vuela(X) :^ pinguino_alterado(X).
