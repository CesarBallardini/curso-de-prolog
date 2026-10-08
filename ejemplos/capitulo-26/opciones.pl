:- encoding(utf8).

% Capítulo 26 - Las opciones de plunit: set, throws, condition, blocked y
% fixme.
%
% El programa es el de la sección 5.3: padre/2. Las pruebas de opciones.plt
% usan una opción cada una, y la salida de run_tests muestra cómo informa
% plunit las pruebas desactivadas y los errores conocidos.
%
%?- padre(juan, H).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).
