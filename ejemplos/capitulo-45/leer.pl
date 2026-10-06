:- encoding(utf8).

% Capítulo 45 - La lectura de datos.
%
% El lenguaje PL de Sterling y Shapiro tiene una sentencia read; Mini la
% recibe como leer x, que toma el siguiente número de la entrada y lo
% asigna a x. La entrada es una lista de números, y es parte del estado:
% en el intérprete es un par más del entorno, con un nombre, '<entrada>',
% que ningún identificador de Mini puede tener; en la máquina, el valor de
% la clave entrada de la memoria. Este archivo agrega una cláusula a cada
% etapa, sin modificar las otras: la palabra reservada y la sentencia de la
% gramática, la sentencia del intérprete, su código y la instrucción leer
% de la máquina. Un programa que lee más números de los que tiene la
% entrada no tiene salida: la ejecución falla.
%
% solo-local: carga maquina.pl con ensure_loaded/1.
%
%?- analizar("leer x; escribir x * x", P).
%?- ejecutar_con_entrada("leer x; escribir x * x", [7], S).
%?- compilar("leer x; escribir x * x", C).

:- ensure_loaded(maquina).

:- multifile
    reservada/1,
    sentencia//1,
    ejecutar_sentencia//3,
    nombre/2,
    codigo_sentencia//1,
    clase/2,
    paso//3.

% La palabra reservada y la sentencia.
reservada(leer).

sentencia(leer(X)) -->
    [leer, id(X)].

% En el intérprete: leer x asigna a x el primer número de la entrada, que
% queda sin él.
ejecutar_sentencia(leer(X), E0, E) -->
    { valor('<entrada>', E0, [V|Vs]),
      actualizar('<entrada>', Vs, E0, E1),
      actualizar(X, V, E1, E) }.

nombre(leer(X), X).

% En la máquina: leer apila el primer número de la entrada.
codigo_sentencia(leer(X)) -->
    [leer, guardar(X)].

clase(leer, fija).

paso(leer, s(PC, P, M0), s(PC1, [V|P], M)) -->
    { PC1 is PC + 1,
      get_assoc(entrada, M0, [V|Vs]),
      put_assoc(entrada, M0, Vs, M) }.

%!  ejecutar_con_entrada(+Texto, +Entrada:list, -Salida:list) is semidet.
%
%   Salida es lo que escribe el programa Mini de Texto, interpretado, con
%   los números de Entrada para leer. Falla si Texto no es un programa Mini
%   o si lee más números de los que tiene Entrada.
ejecutar_con_entrada(Texto, Entrada, Salida) :-
    analizar(Texto, Programa),
    interpretar_con_entrada(Programa, Entrada, Salida).

%!  interpretar_con_entrada(+Programa, +Entrada, -Salida) is semidet.
%
%   Como interpretar/2, con Entrada como los números que lee Programa.
interpretar_con_entrada(Programa, Entrada, Salida) :-
    entorno_inicial(Programa, Entorno),
    once(phrase(ejecutar_bloque(Programa, ['<entrada>'-Entrada|Entorno], _),
                Salida)).

%!  correr_con_entrada(+Texto, +Entrada:list, -Salida:list) is semidet.
%
%   Salida es lo que escribe el programa Mini de Texto, compilado y
%   ejecutado en la máquina, con los números de Entrada para leer.
correr_con_entrada(Texto, Entrada, Salida) :-
    compilar(Texto, Objeto),
    maquina_con_entrada(Objeto, Entrada, Salida).

%!  maquina_con_entrada(+Objeto, +Entrada, -Salida) is semidet.
%
%   Como maquina/2, con Entrada en la memoria, bajo la clave entrada.
%   Falla si el código lee más números de los que tiene Entrada.
maquina_con_entrada(Objeto, Entrada, Salida) :-
    compound_name_arguments(Codigo, codigo, Objeto),
    list_to_assoc([entrada-Entrada], Memoria),
    phrase(ciclo(Codigo, s(0, [], Memoria)), Salida).

% suma_leida(Texto): un programa que lee una cantidad n y después n
% números, y escribe su suma.
suma_leida("leer n; s := 0;
mientras n > 0 hacer
  leer x; s := s + x; n := n - 1
fin;
escribir s").
