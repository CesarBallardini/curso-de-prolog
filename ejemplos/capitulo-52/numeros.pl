:- encoding(utf8).

% Capítulo 52 - Versión 6: la forma estándar, la descripción estándar y el
% número de descripción (Turing, §5).
%
% En la forma estándar cada instrucción imprime un símbolo, posiblemente
% el mismo que lee o el blanco, y después mueve el cabezal a la izquierda,
% a la derecha o no lo mueve:
%
%   i(Q, S, e(W, Mov), Q1)     Mov es l, r o n
%
% Una fila con más operaciones se parte en varias instrucciones con
% configuraciones auxiliares resto(Ops, Q1): la configuración que todavía
% tiene que ejecutar Ops y después pasar a Q1. Es un término más, y la
% expansión de la versión 5 la trata como a las otras.
%
% La descripción estándar numera las configuraciones desde 1 en el orden
% de la expansión y los símbolos desde 0: el blanco es 0, y los del
% alfabeto siguen en su orden (Turing pide que 0 sea el 1 y 1 el 2). Cada
% instrucción se escribe D A...A D C...C D C...C L|R|N D A...A ; y el
% número de descripción reemplaza A C D L R N ; por 1 2 3 4 5 6 7.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- descripcion(i, b, [0, 1], SD).
%?- numero(i, b, [0, 1], N).

:- module(numeros, [estandar/5, tabla_estandar/4, descripcion/4, numero/4,
                    figuras_estandar/3]).

:- reexport(completa).
:- use_module(plana, [leer/2, operar/5]).

%!  estandar(+M, +Q, +S, -Accion, -Q1) is semidet.
%
%   Desde Q leyendo S, la máquina M ejecuta la instrucción estándar
%   Accion = e(W, Mov) y pasa a Q1. Q puede ser una configuración de M o
%   una auxiliar resto(Ops, Q2).
estandar(M, Q, S, e(W, Mov), Q1) :-
    (   Q = resto(Ops, Q2)
    ->  true
    ;   transicion(M, Q, S, Ops, Q2)
    ),
    grupo(Ops, S, W, Mov, Resto),
    (   Resto == []
    ->  Q1 = Q2
    ;   Q1 = resto(Resto, Q2)
    ).

%!  grupo(+Ops0:list, +S, -W, -Mov, -Ops:list) is det.
%
%   La primera instrucción estándar de las operaciones Ops0, leyendo S,
%   imprime W y mueve Mov; quedan las operaciones Ops.
grupo(Ops0, S, W, Mov, Ops) :-
    (   Ops0 = [p(X)|Ops1]
    ->  W = X
    ;   Ops0 = [e|Ops1]
    ->  W = blanco
    ;   W = S,
        Ops1 = Ops0
    ),
    (   Ops1 = [l|Ops]
    ->  Mov = l
    ;   Ops1 = [r|Ops]
    ->  Mov = r
    ;   Mov = n,
        Ops = Ops1
    ).

%!  tabla_estandar(+M, +Q0, +Alfabeto:list, -Tabla) is semidet.
%
%   Tabla es la tabla completa de M desde Q0 en forma estándar, con los
%   símbolos del Alfabeto y el blanco. Falla si tiene más de 10 000
%   configuraciones.
tabla_estandar(M, Q0, Alfabeto, Tabla) :-
    expandir(estandar(M), Q0, [blanco|Alfabeto], 10000, Tabla),
    Tabla = tabla(_, _).

%!  descripcion(+M, +Q0, +Alfabeto:list, -SD:string) is semidet.
%
%   SD es la descripción estándar de M desde Q0 con el Alfabeto, que
%   empieza con 0 y 1. Falla si la tabla completa tiene más de 10 000
%   configuraciones.
descripcion(M, Q0, Alfabeto, SD) :-
    tabla_estandar(M, Q0, Alfabeto, tabla(Es, Is)),
    phrase(instrucciones(Is, Es, [blanco|Alfabeto]), Codigos),
    string_codes(SD, Codigos).

%!  instrucciones(+Is:list, +Es:list, +Ss:list)// is det.
%
%   Las instrucciones Is escritas en la descripción estándar, con las
%   configuraciones numeradas por su posición en Es y los símbolos por
%   su posición en Ss, desde 0.
instrucciones([], _, _) -->
    [].
instrucciones([i(Q, S, e(W, Mov), Q1)|Is], Es, Ss) -->
    { once(nth1(I, Es, Q)),
      once(nth0(J, Ss, S)),
      once(nth0(K, Ss, W)),
      once(nth1(N, Es, Q1))
    },
    "D", letras(0'A, I), "D", letras(0'C, J), "D", letras(0'C, K),
    movimiento(Mov),
    "D", letras(0'A, N), ";",
    instrucciones(Is, Es, Ss).

%!  letras(+C, +N:integer)// is det.
%
%   N veces el carácter de código C.
letras(C, N) -->
    (   { N =:= 0 }
    ->  []
    ;   [C],
        { N1 is N - 1 },
        letras(C, N1)
    ).

% movimiento(Mov): la letra de la descripción estándar del movimiento.
movimiento(l) --> "L".
movimiento(r) --> "R".
movimiento(n) --> "N".

%!  numero(+M, +Q0, +Alfabeto:list, -N:integer) is semidet.
%
%   N es el número de descripción de M desde Q0 con el Alfabeto.
numero(M, Q0, Alfabeto, N) :-
    descripcion(M, Q0, Alfabeto, SD),
    string_codes(SD, Letras),
    maplist(digito, Letras, Digitos),
    number_codes(N, Digitos).

% digito(L, D): D es el dígito que reemplaza a la letra L.
digito(0'A, 0'1).
digito(0'C, 0'2).
digito(0'D, 0'3).
digito(0'L, 0'4).
digito(0'R, 0'5).
digito(0'N, 0'6).
digito(0';, 0'7).

%!  figuras_estandar(+Tabla, +N:integer, -Fs:list) is semidet.
%
%   Fs son las primeras N figuras que imprime la tabla en forma estándar
%   Tabla desde su primera configuración con la cinta en blanco. Volver a
%   imprimir el símbolo leído no cuenta como imprimir.
figuras_estandar(tabla([Q0|_], Is), N, Fs) :-
    cinta_vacia(Cinta),
    figuras_estandar(Is, Q0, Cinta, N, Fs0),
    length(Fs, N),
    append(Fs, _, Fs0).

%!  figuras_estandar(+Is:list, +Q, +Cinta, +N:integer, -Fs:list) is semidet.
%
%   Fs son las figuras que imprimen las instrucciones Is desde Q con la
%   Cinta hasta haber impreso por lo menos N.
figuras_estandar(Is, Q, Cinta, N, Fs) :-
    (   N =< 0
    ->  Fs = []
    ;   leer(Cinta, S),
        memberchk(i(Q, S, e(W, Mov), Q1), Is),
        operaciones(S, W, Mov, Ops),
        operar(Ops, Cinta, Cinta1, Fs1, []),
        length(Fs1, K),
        N1 is N - K,
        append(Fs1, Fs2, Fs),
        figuras_estandar(Is, Q1, Cinta1, N1, Fs2)
    ).

%!  operaciones(+S, +W, +Mov, -Ops:list) is det.
%
%   Ops son las operaciones de la instrucción que lee S, imprime W y
%   mueve Mov: nada si W es S, e si W es el blanco, y p(W) si no.
operaciones(S, W, Mov, Ops) :-
    (   W == S
    ->  Ops = Ops1
    ;   W == blanco
    ->  Ops = [e|Ops1]
    ;   Ops = [p(W)|Ops1]
    ),
    (   Mov == n
    ->  Ops1 = []
    ;   Ops1 = [Mov]
    ).
