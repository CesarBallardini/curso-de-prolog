:- encoding(utf8).

% Capítulo 61 - Soluciones de los ejercicios.
%
% Carga la máquina terminada, maquina.pl. Los programas objeto de los
% ejercicios son listas de cláusulas que se pasan a medir_clausulas/4 y a
% resolver_clausulas/3 de almacen.pl; nativas/3 los ejecuta con Prolog,
% como respuestas_nativas/3. Las versiones traza, sin_rastro y aritmetica
% de los ejercicios 6, 9 y 10 están en soluciones_traza.pl,
% soluciones_sin_rastro.pl y soluciones_aritmetica.pl.
%
% solo-local: carga maquina.pl.
%
%?- medir_tipos(Segundo, Primero).
%?- transformado(disyuncion, signo(-2, S)).

:- ensure_loaded(maquina).
:- use_module(library(apply)).
:- use_module(library(assoc)).
:- use_module(library(lists)).
:- use_module(library(modules)).
:- use_module(almacen,
              [ medir_clausulas/4,
                resolver_clausulas/3,
                compilar_clausula/2,
                desreferenciar/3,
                reconstruir/3,
                renombrar/3,
                unificar/5
              ]).

%!  nativas(+Clausulas:list, +Meta, -Respuestas:list) is det.
%
%   Respuestas son las instancias de Meta que Prolog obtiene con las
%   Clausulas cargadas en un módulo temporal.
nativas(Clausulas, Meta, Respuestas) :-
    in_temporary_module(Modulo,
                        forall(member(C, Clausulas), assertz(Modulo:C)),
                        findall(Meta, Modulo:Meta, Respuestas)).

% Ejercicio 4

% tipos(Cs): hechos tipo(Valor, Tipo), con el tipo en el segundo argumento.
tipos([ (tipo(1, entero) :- true),
        (tipo(2, entero) :- true),
        (tipo(3, entero) :- true),
        (tipo(a, atomo) :- true),
        (tipo(b, atomo) :- true)
      ]).

% tipos_invertidos(Cs): los mismos hechos, con el tipo primero.
tipos_invertidos([ (tipo(entero, 1) :- true),
                   (tipo(entero, 2) :- true),
                   (tipo(entero, 3) :- true),
                   (tipo(atomo, a) :- true),
                   (tipo(atomo, b) :- true)
                 ]).

%!  medir_tipos(-Segundo:list, -Primero:list) is det.
%
%   Segundo y Primero son las medidas, en la versión 5, de buscar los
%   enteros con el tipo en el segundo y en el primer argumento.
medir_tipos(Segundo, Primero) :-
    tipos(Cs1),
    medir_clausulas(indice, Cs1, tipo(_, entero), Segundo),
    tipos_invertidos(Cs2),
    medir_clausulas(indice, Cs2, tipo(entero, _), Primero).

% Ejercicio 5

%!  unificar_con_prueba(+X, +Y, +Marca:integer, +Estado0, -Estado)
%!      is semidet.
%
%   Como unificar/5 de almacen.pl, con la prueba de ocurrencia: falla si
%   una celda se liga a un término que la contiene.
unificar_con_prueba(X0, Y0, Marca, Estado0, Estado) :-
    Estado0 = Almacen-_,
    desreferenciar(X0, Almacen, X),
    desreferenciar(Y0, Almacen, Y),
    (   X == Y
    ->  Estado = Estado0
    ;   X = '$v'(N)
    ->  \+ ocurre(N, Y, Almacen),
        ligar_celda(N, Y, Marca, Estado0, Estado)
    ;   Y = '$v'(N)
    ->  \+ ocurre(N, X, Almacen),
        ligar_celda(N, X, Marca, Estado0, Estado)
    ;   compound(X),
        compound(Y),
        compound_name_arity(X, Nombre, Aridad),
        compound_name_arity(Y, Nombre, Aridad),
        compound_name_arguments(X, Nombre, Xs),
        compound_name_arguments(Y, Nombre, Ys),
        foldl(unificar_con_prueba_argumento(Marca), Xs, Ys, Estado0, Estado)
    ).

%!  unificar_con_prueba_argumento(+Marca:integer, +X, +Y, +Estado0,
%!                                -Estado) is semidet.
%
%   unificar_con_prueba/5 con los argumentos en el orden de foldl/5.
unificar_con_prueba_argumento(Marca, X, Y, Estado0, Estado) :-
    unificar_con_prueba(X, Y, Marca, Estado0, Estado).

%!  ocurre(+N:integer, +Termino, +Almacen) is semidet.
%
%   La celda N aparece en Termino, con las ligaduras del Almacen.
ocurre(N, Termino0, Almacen) :-
    desreferenciar(Termino0, Almacen, Termino),
    (   Termino = '$v'(M)
    ->  M =:= N
    ;   compound(Termino),
        arg(_, Termino, Argumento),
        ocurre(N, Argumento, Almacen)
    ).

%!  ligar_celda(+N:integer, +Valor, +Marca:integer, +Estado0, -Estado)
%!      is det.
%
%   Liga la celda N a Valor, y la anota en el rastro si es anterior a
%   Marca.
ligar_celda(N, Valor, Marca, Almacen0-Rastro0, Almacen-Rastro) :-
    put_assoc(N, Almacen0, Valor, Almacen),
    (   N < Marca
    ->  Rastro = [N|Rastro0]
    ;   Rastro = Rastro0
    ).

% Ejercicio 7

%!  transformar(+Clausulas0:list, -Clausulas:list) is det.
%
%   Clausulas son las Clausulas0 con cada disyunción (A ; B) y cada
%   negación \+ G de los cuerpos reemplazadas por la llamada a un predicado
%   auxiliar nuevo, cuyas cláusulas siguen a la que lo usa.
transformar(Clausulas0, Clausulas) :-
    foldl(transformar_clausula, Clausulas0, Grupos, 0, _),
    append(Grupos, Clausulas).

%!  transformar_clausula(+Clausula0, -Clausulas:list, +N0:integer,
%!                       -N:integer) is det.
%
%   Clausulas son Clausula0 transformada y sus auxiliares; N0 y N cuentan
%   los auxiliares creados antes y después.
transformar_clausula((Cabeza :- Cuerpo0), [(Cabeza :- Cuerpo)|Auxiliares],
                     N0, N) :-
    transformar_cuerpo(Cuerpo0, Cuerpo, Auxiliares, [], N0, N).

%!  transformar_cuerpo(+Cuerpo0, -Cuerpo, -Auxiliares:list, ?Resto:list,
%!                     +N0:integer, -N:integer) is det.
%
%   Cuerpo es Cuerpo0 sin disyunciones ni negaciones; Auxiliares-Resto es
%   la lista diferencia de las cláusulas auxiliares creadas.
transformar_cuerpo(Cuerpo0, Cuerpo, Auxiliares, Resto, N0, N) :-
    (   var(Cuerpo0)
    ->  Cuerpo = Cuerpo0,
        Auxiliares = Resto,
        N = N0
    ;   Cuerpo0 = (A0, B0)
    ->  transformar_cuerpo(A0, A, Auxiliares, Medio, N0, N1),
        transformar_cuerpo(B0, B, Medio, Resto, N1, N),
        Cuerpo = (A, B)
    ;   Cuerpo0 = (A0 ; B0)
    ->  auxiliar(o, Cuerpo0, N0, N1, Cuerpo),
        transformar_cuerpo(A0, A, Auxiliares1, Medio, N1, N2),
        transformar_cuerpo(B0, B, Medio, Resto, N2, N),
        Auxiliares = [(Cuerpo :- A), (Cuerpo :- B)|Auxiliares1]
    ;   Cuerpo0 = (\+ G0)
    ->  auxiliar(no, Cuerpo0, N0, N1, Cuerpo),
        transformar_cuerpo(G0, G, Auxiliares1, Resto, N1, N),
        Auxiliares = [(Cuerpo :- G, !, fail), (Cuerpo :- true)|Auxiliares1]
    ;   Cuerpo = Cuerpo0,
        Auxiliares = Resto,
        N = N0
    ).

%!  auxiliar(+Prefijo:atom, +Meta, +N0:integer, -N:integer, -Llamada)
%!      is det.
%
%   Llamada es la llamada al auxiliar número N = N0 + 1, con las variables
%   de Meta como argumentos; su nombre es '$' seguido del Prefijo y de N.
auxiliar(Prefijo, Meta, N0, N, Llamada) :-
    N is N0 + 1,
    format(atom(Nombre), "$~w~d", [Prefijo, N]),
    term_variables(Meta, Variables),
    Llamada =.. [Nombre|Variables].

% disyuncion(Cs): un programa con una disyunción y una negación.
disyuncion([ (signo(X, S) :- ( X < 0, S = negativo
                              ; X =:= 0, S = cero
                              ; S = positivo
                              )),
             (persona(ana) :- true),
             (persona(luis) :- true),
             (casado(luis) :- true),
             (soltero(P) :- persona(P), \+ casado(P))
           ]).

% corte_en_disyuncion(Cs): un corte dentro de una disyunción, y una
% cláusula más del mismo predicado.
corte_en_disyuncion([ (p(X) :- ( X = 1, ! ; X = 2 )),
                      (p(3) :- true)
                    ]).

%!  transformado(+Programa:atom, ?Meta) is nondet.
%
%   Meta se prueba en la versión 5 con el Programa, disyuncion o
%   corte_en_disyuncion, transformado.
transformado(Programa, Meta) :-
    call(Programa, Clausulas0),
    transformar(Clausulas0, Clausulas),
    resolver_clausulas(indice, Clausulas, Meta).

% Ejercicios 8 y 11

% acumuladores(Cs): invertir/3 y longitud/3 con acumulador.
acumuladores([ (invertir_acc(L, R) :- invertir(L, [], R)),
               (invertir([], R, R) :- true),
               (invertir([X|Xs], R0, R) :- invertir(Xs, [X|R0], R)),
               (invertir_acc_hasta(N, R) :- lista_hasta(N, L),
                                            invertir_acc(L, R)),
               (longitud_acc(L, N) :- longitud(L, 0, N)),
               (longitud([], N, N) :- true),
               (longitud([_|Xs], N0, N) :- N1 is N0 + 1,
                                           longitud(Xs, N1, N)),
               (longitud_acc_hasta(N, K) :- lista_hasta(N, L),
                                            longitud_acc(L, K))
             ]).

%!  medir_con_acumuladores(+Meta, -Medidas:list) is det.
%
%   Medidas son las medidas de Meta en la versión 5, con el programa
%   listas y los predicados con acumulador.
medir_con_acumuladores(Meta, Medidas) :-
    programa(listas, Listas),
    acumuladores(Acumuladores),
    append(Listas, Acumuladores, Clausulas),
    medir_clausulas(indice, Clausulas, Meta, Medidas).

%!  pasos_de(+Meta, -Pasos:integer) is det.
%
%   Pasos son los pasos de Meta en la versión 5, como los mide
%   medir_con_acumuladores/2.
pasos_de(Meta, Pasos) :-
    medir_con_acumuladores(Meta, Medidas),
    memberchk(pasos-Pasos, Medidas).

%!  metas_de(+Meta, -Metas:integer) is det.
%
%   Metas es el largo máximo de la resolvente de Meta en la versión 5.
metas_de(Meta, Metas) :-
    medir_con_acumuladores(Meta, Medidas),
    memberchk(metas-Metas, Medidas).
