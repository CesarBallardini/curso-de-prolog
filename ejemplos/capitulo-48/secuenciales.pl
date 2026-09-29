:- encoding(utf8).

% Capítulo 48 - Versión 5: circuitos secuenciales.
%
% Un circuito secuencial es un circuito combinacional más un registro de
% biestables D que comparten el reloj. El registro guarda el estado: una
% lista de bits. En cada pulso del reloj, la parte combinacional recibe
% las entradas externas y el estado actual, y calcula las salidas y el
% estado siguiente, que el registro guarda hasta el pulso siguiente.
%
%   secuencial(Nombre, Combinacional, K)
%       Combinacional es un circuito del módulo circuitos cuyas entradas
%       son las externas seguidas de los K bits del estado actual, y cuyas
%       salidas son las externas seguidas de los K bits del estado
%       siguiente.
%
% Ejecutar el circuito es recorrer la lista de entradas, una por pulso,
% llevando el estado de un pulso al siguiente: foldl/6. secuencial/3, como
% circuito/3 y componente/5, admite cláusulas en otros archivos.
%
% solo-local: carga el módulo circuitos, y SWISH no admite módulos propios.
%
%?- ejecutar(paridad, [0], [[1], [0], [0], [1], [1], [0]], Ss).
%?- ejecutar(contador_gray, [0, 0, 0], [[], [], [], []], Ss).

:- module(secuenciales,
          [ secuencial/3,
            paso/5,
            ejecutar/4
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(circuitos).

:- multifile secuencial/3.
:- multifile circuitos:circuito/3, circuitos:componente/5.

% secuencial(Nombre, Combinacional, K): el circuito secuencial Nombre
% tiene la parte combinacional Combinacional y K bits de estado.
secuencial(divisor, divisor_c, 1).
secuencial(paridad, paridad_c, 1).
secuencial(registro4, registro4_c, 4).
secuencial(contador_gray, contador_gray_c, 3).

% Divisor por dos: la salida es el estado, que se invierte en cada pulso.
circuitos:circuito(divisor_c, [q], [q, d]).
circuitos:componente(divisor_c, i1, inv, [q], [d]).

% Paridad: el estado siguiente es el anterior XOR la entrada, y la salida
% es el estado siguiente: 1 si llegó una cantidad impar de unos.
circuitos:circuito(paridad_c, [x, p], [n, n]).
circuitos:componente(paridad_c, x1, xor, [x, p], [n]).

% Registro de desplazamiento de cuatro etapas: solo cables. La entrada
% pasa a la primera etapa, cada etapa a la siguiente, y la salida es la
% cuarta.
circuitos:circuito(registro4_c, [x, q1, q2, q3, q4], [q4, x, q1, q2, q3]).

% Incremento de un número de tres bits, el menos significativo primero,
% módulo 8.
circuitos:circuito(incremento3, [b0, b1, b2], [n0, n1, n2]).
circuitos:componente(incremento3, i1, inv, [b0], [n0]).
circuitos:componente(incremento3, x1, xor, [b1, b0], [n1]).
circuitos:componente(incremento3, y1, and, [b1, b0], [c1]).
circuitos:componente(incremento3, x2, xor, [b2, c1], [n2]).

% El código Gray de un número de tres bits: cada bit XOR el siguiente, y
% el más significativo sin cambios.
circuitos:circuito(gray3, [b0, b1, b2], [g0, g1, b2]).
circuitos:componente(gray3, x1, xor, [b0, b1], [g0]).
circuitos:componente(gray3, x2, xor, [b1, b2], [g1]).

% Contador Gray: un contador binario de tres bits cuya salida es el código
% Gray del estado.
circuitos:circuito(contador_gray_c, [b0, b1, b2], [g0, g1, g2, n0, n1, n2]).
circuitos:componente(contador_gray_c, inc, incremento3, [b0, b1, b2],
                     [n0, n1, n2]).
circuitos:componente(contador_gray_c, cod, gray3, [b0, b1, b2],
                     [g0, g1, g2]).

%!  paso(+Nombre, +Estado0:list, ?Entradas:list, ?Salidas:list,
%!       ?Estado:list) is nondet.
%
%   En un pulso del reloj, el circuito secuencial Nombre, en el estado
%   Estado0 y con las Entradas, da las Salidas y pasa al Estado.
paso(Nombre, Estado0, Entradas, Salidas, Estado) :-
    secuencial(Nombre, Combinacional, K),
    length(Estado0, K),
    length(Estado, K),
    circuito(Combinacional, NEs, NSs),
    length(NEs, NE),
    length(NSs, NS),
    NEntradas is NE - K,
    NSalidas is NS - K,
    length(Entradas, NEntradas),
    length(Salidas, NSalidas),
    append(Entradas, Estado0, Es),
    append(Salidas, Estado, Ss),
    simular(Combinacional, Es, Ss).

%!  ejecutar(+Nombre, +Estado0:list, ?Pulsos:list(list),
%!           ?Salidas:list(list)) is nondet.
%
%   Salidas son las salidas del circuito secuencial Nombre en cada pulso,
%   a partir del Estado0, cuando Pulsos son sus entradas en cada pulso.
%   Una de las dos listas debe tener longitud conocida.
ejecutar(Nombre, Estado0, Pulsos, Salidas) :-
    foldl(pulso(Nombre), Pulsos, Salidas, Estado0, _).

%!  pulso(+Nombre, +Entradas:list, -Salidas:list, +Estado0:list,
%!        -Estado:list) is nondet.
%
%   Un paso, con los argumentos en el orden de foldl/6.
pulso(Nombre, Entradas, Salidas, Estado0, Estado) :-
    paso(Nombre, Estado0, Entradas, Salidas, Estado).
