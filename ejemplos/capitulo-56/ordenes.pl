:- encoding(utf8).

% Capítulo 56 - Versión 5: el programa terminado.
%
% ordenes/1 lee órdenes en castellano, una por línea, y las cumple sobre la
% carpeta de trabajo que recibe: cada línea pasa por la gramática de la
% versión 2, el planificador de la versión 3 y la ejecución de la versión
% 4, y cada resultado se redacta como una oración. Los plurales, «ningún»
% y «ninguna» y la concordancia del verbo salen de la gramática del
% capítulo 54. ordenes/4 recibe las opciones y los streams:
%
%   simulacion(true)   describe las acciones en lugar de realizarlas
%   registro(Archivo)  agrega a Archivo las líneas que no se entienden
%   eco(true)          escribe cada línea leída, como la muestra la terminal
%
% solo-local: lee y escribe archivos, crea procesos y carga otros archivos.

:- ensure_loaded(gramatica).
:- ensure_loaded(sistema).
:- use_module(library(option)).
:- use_module(library(readutil)).

% Otros archivos pueden agregar oraciones para resultados nuevos.
:- multifile oracion/2.

%!  ordenes(+Raiz) is det.
%
%   Cumple las órdenes que se escriben en la terminal sobre la carpeta Raiz,
%   hasta «salir» o el fin de la entrada.
ordenes(Raiz) :-
    ordenes(Raiz, [], user_input, user_output).

%!  ordenes(+Raiz, +Opciones:list, +Entrada, +Salida) is det.
%
%   Cumple las órdenes que lee de Entrada sobre la carpeta Raiz, y escribe
%   las respuestas en Salida.
ordenes(Raiz, Opciones, In, Out) :-
    format(Out, "Escribe una orden en castellano; «salir» termina.~n", []),
    (   option(simulacion(true), Opciones)
    ->  format(Out, "Modo simulación: ningún archivo se modifica.~n", [])
    ;   true
    ),
    bucle(Raiz, Opciones, In, Out).

%!  bucle(+Raiz, +Opciones:list, +Entrada, +Salida) is det.
%
%   Lee una línea y la atiende, hasta «salir» o el fin de la entrada.
bucle(Raiz, Opciones, In, Out) :-
    format(Out, "> ", []),
    flush_output(Out),
    leer_linea(Opciones, In, Out, Linea),
    (   Linea == end_of_file
    ->  nl(Out)
    ;   normalize_space(string(""), Linea)
    ->  bucle(Raiz, Opciones, In, Out)
    ;   atender(Raiz, Opciones, In, Out, Linea, Seguir),
        (   Seguir == si
        ->  bucle(Raiz, Opciones, In, Out)
        ;   true
        )
    ).

%!  leer_linea(+Opciones:list, +Entrada, +Salida, -Linea) is det.
%
%   Linea es la próxima línea de Entrada, o end_of_file. Con eco(true), la
%   escribe en Salida.
leer_linea(Opciones, In, Out, Linea) :-
    read_line_to_string(In, Linea),
    (   option(eco(true), Opciones),
        string(Linea)
    ->  format(Out, "~s~n", [Linea])
    ;   true
    ).

%!  atender(+Raiz, +Opciones:list, +Entrada, +Salida, +Linea:string,
%!          -Seguir) is det.
%
%   Entiende Linea, la cumple y escribe las respuestas; Seguir es no
%   después de «salir», y si en otro caso.
atender(Raiz, Opciones, In, Out, Linea, Seguir) :-
    (   entender(Linea, Orden)
    ->  leer_modelo(Raiz, Modelo),
        planificar(Orden, Modelo, Plan),
        (   option(simulacion(true), Opciones)
        ->  Modo = simulacion
        ;   Modo = real
        ),
        ejecutar_plan(Modo, Raiz, Plan, leer_linea(Opciones, In, Out), Out,
                      Resultados),
        forall(member(R, Resultados), decir(Out, R)),
        (   memberchk(salir, Resultados)
        ->  Seguir = no
        ;   Seguir = si
        )
    ;   registrar(Opciones, Linea),
        format(Out, "La orden no se entiende. Prueba, por ejemplo, con ~s~n",
               ["«lista los archivos» o «copia notas.txt a respaldo»."]),
        Seguir = si
    ).

%!  registrar(+Opciones:list, +Linea:string) is det.
%
%   Con registro(Archivo), agrega Linea al final de Archivo.
registrar(Opciones, Linea) :-
    (   option(registro(Archivo), Opciones)
    ->  setup_call_cleanup(open(Archivo, append, S),
                           format(S, "~s~n", [Linea]),
                           close(S))
    ;   true
    ).

%!  decir(+Salida, +Resultado) is det.
%
%   Escribe en Salida la oración que describe Resultado.
decir(Out, salida(R, Estado, Lineas)) :-
    !,
    (   Estado == exit(0)
    ->  format(Out, "Salida de ~s:~n", [R])
    ;   format(Out, "~s terminó con el estado ~w. Su salida:~n", [R, Estado])
    ),
    forall(member(L, Lineas), format(Out, "  ~s~n", [L])).
decir(Out, Resultado) :-
    oracion(Resultado, Texto),
    format(Out, "~s~n", [Texto]).

%!  oracion(+Resultado, -Texto:string) is det.
%
%   Texto es la oración que describe Resultado.
oracion(lista(C, []), T) :-
    nombre_de_carpeta(C, L),
    format(string(T), "En ~s no hay nada.", [L]).
oracion(lista(C, [N|Ns]), T) :-
    nombre_de_carpeta(C, L),
    length([N|Ns], K),
    cantidad(K, elemento, m, Q),
    atomic_list_concat([N|Ns], ', ', Nombres),
    format(string(T), "En ~s hay ~s: ~w.", [L, Q, Nombres]).
oracion(cantidad(C, F, K), T) :-
    nombre_de_carpeta(C, L),
    cantidad(K, archivo, m, Q),
    (   K =:= 0
    ->  Hay = "no hay"
    ;   Hay = "hay"
    ),
    (   F = patron(P)
    ->  coincide(K, V),
        format(string(T), "En ~s ~s ~s que ~s con ~s.", [L, Hay, Q, V, P])
    ;   format(string(T), "En ~s ~s ~s.", [L, Hay, Q])
    ).
oracion(tamano([R], B), T) :-
    !,
    cantidad(B, byte, m, Q),
    format(string(T), "~s ocupa ~s.", [R, Q]).
oracion(tamano(Rs, B), T) :-
    length(Rs, K),
    cantidad(B, byte, m, Q),
    format(string(T), "Los ~d archivos ocupan ~s.", [K, Q]).
oracion(fecha(R, F), T) :-
    format(string(T), "~s se modificó el ~s.", [R, F]).
oracion(encontrados(P, []), T) :-
    !,
    format(string(T), "Ningún archivo coincide con ~s.", [P]).
oracion(encontrados(P, Rs), T) :-
    length(Rs, K),
    cantidad(K, archivo, m, Q),
    coincide(K, V),
    atomic_list_concat(Rs, ', ', Rutas),
    format(string(T), "Hay ~s que ~s con ~s: ~w.", [Q, V, P, Rutas]).
oracion(copiado(R, D), T) :-
    format(string(T), "~s se copió en ~s.", [R, D]).
oracion(movido(R, D), T) :-
    format(string(T), "~s pasó a ser ~s.", [R, D]).
oracion(borrado(R), T) :-
    format(string(T), "~s se borró.", [R]).
oracion(conservado(R), T) :-
    format(string(T), "~s no se borró.", [R]).
oracion(simulada(copiar(R, D)), T) :-
    format(string(T), "Se copiaría ~s en ~s.", [R, D]).
oracion(simulada(mover(R, D)), T) :-
    format(string(T), "~s pasaría a ser ~s.", [R, D]).
oracion(simulada(borrar(R)), T) :-
    format(string(T), "Se borraría ~s, después de confirmarlo.", [R]).
oracion(simulada(ejecutar(R)), T) :-
    format(string(T), "Se ejecutaría ~s.", [R]).
oracion(rechazo(M), T) :-
    rechazo(M, T).
oracion(salir, "Hasta luego.").

%!  rechazo(+Motivo, -Texto:string) is det.
%
%   Texto explica por qué la orden no se cumple.
rechazo(no_existe(R), T) :-
    format(string(T), "No existe ~s.", [R]).
rechazo(ninguno(C, todos), T) :-
    !,
    nombre_de_carpeta(C, L),
    format(string(T), "En ~s no hay archivos.", [L]).
rechazo(ninguno(C, patron(P)), T) :-
    nombre_de_carpeta(C, L),
    format(string(T), "Ningún archivo de ~s coincide con ~s.", [L, P]).
rechazo(ya_existe(R), T) :-
    format(string(T), "Ya existe ~s, y no se sobrescribe.", [R]).
rechazo(no_es_carpeta(D), T) :-
    format(string(T), "~s no es una carpeta: varios archivos van a una.",
           [D]).
rechazo(no_ejecutable(R), T) :-
    format(string(T), "~s no es un programa: solo se ejecutan archivos .pl.",
           [R]).
rechazo(fuera_de_la_carpeta(R), T) :-
    format(string(T), "~s está fuera de la carpeta de trabajo: ~s",
           [R, "la orden no se cumple."]).

%!  nombre_de_carpeta(+C:string, -L:string) is det.
%
%   L nombra la carpeta C en una oración.
nombre_de_carpeta(".", "la carpeta de trabajo") :-
    !.
nombre_de_carpeta(C, L) :-
    format(string(L), "la carpeta ~s", [C]).

%!  coincide(+K:integer, -V:string) is det.
%
%   V es la forma de «coincidir» que concuerda con K archivos: en
%   subjuntivo después de «no hay ningún archivo», y en singular o en
%   plural según K en los demás casos.
coincide(K, V) :-
    (   K =:= 0
    ->  V = "coincida"
    ;   K =:= 1
    ->  numero_verbo(sg, "coincide", "coinciden", V)
    ;   numero_verbo(pl, "coincide", "coinciden", V)
    ).

%!  cantidad(+K:integer, +Lema:atom, +G, -Texto:string) is det.
%
%   Texto es K seguido del nombre Lema, de género G, en el número que
%   corresponde: «ningún archivo», «1 archivo», «3 archivos».
cantidad(0, Lema, G, Texto) :-
    !,
    (   G == m
    ->  D = "ningún"
    ;   D = "ninguna"
    ),
    format(string(Texto), "~s ~w", [D, Lema]).
cantidad(1, Lema, _, Texto) :-
    !,
    format(string(Texto), "1 ~w", [Lema]).
cantidad(K, Lema, _, Texto) :-
    atom_string(Lema, Singular),
    numero_es(pl, Singular, Plural),
    format(string(Texto), "~d ~s", [K, Plural]).
