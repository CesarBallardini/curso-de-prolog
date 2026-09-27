:- encoding(utf8).

% Capítulo 25 - Soluciones de los ejercicios 3 a 9. Las de los ejercicios 11
% a 13, sobre el proyecto, están en soluciones_proyecto.pl.
%
% solo-local: el ejercicio 7 abre un stream, que el sandbox de SWISH no permite.
%
%?- leer_nota("7", N).
%?- limpiar_telefono("(223) 456-7890", T).

:- use_module(library(error)).

% --- Ejercicio 3 ----------------------------------------------------------

%!  leer_nota(+Texto:text, -Nota:integer) is det.
%
%   Nota es la nota escrita en Texto. Produce domain_error(nota, Texto) si
%   el texto no es un entero entre 1 y 10.
leer_nota(Texto, Nota) :-
    must_be(text, Texto),
    text_to_string(Texto, Cadena),
    (   number_string(N, Cadena),
        integer(N),
        between(1, 10, N)
    ->  Nota = N
    ;   domain_error(nota, Texto)
    ).

% --- Ejercicio 4 ----------------------------------------------------------

%!  seguro(:Objetivo, -Resultado) is det.
%
%   Resultado es ok si Objetivo tiene éxito, falla si falla, y error(Formal)
%   si produce un error, con la parte formal del término.
seguro(Objetivo, Resultado) :-
    catch(( once(Objetivo)
          ->  Resultado = ok
          ;   Resultado = falla
          ),
          error(Formal, _),
          Resultado = error(Formal)).

% --- Ejercicio 5 ----------------------------------------------------------

%!  promedio_seguro(+L:list(number), -P) is det.
%
%   P es el promedio de L, o sin_datos si L está vacía. Solo se captura la
%   división por cero; cualquier otro error, como un elemento que no es un
%   número, se propaga.
promedio_seguro(L, P) :-
    catch(( sum_list(L, S),
            length(L, N),
            P is S / N ),
          error(evaluation_error(zero_divisor), _),
          P = sin_datos).

% --- Ejercicio 6 ----------------------------------------------------------

%!  rango(+Desde:integer, +Hasta:integer, -L:list(integer)) is det.
%
%   L son los enteros de Desde a Hasta. Produce un error de tipo si alguno
%   no es un entero, y domain_error(rango, Desde-Hasta) si Desde > Hasta.
rango(Desde, Hasta, L) :-
    must_be(integer, Desde),
    must_be(integer, Hasta),
    (   Desde =< Hasta
    ->  numlist(Desde, Hasta, L)
    ;   domain_error(rango, Desde-Hasta)
    ).

% --- Ejercicio 7 ----------------------------------------------------------

%!  primera_linea(+Texto:string, -Linea:string) is det.
%
%   Linea es la primera línea de Texto, o la cadena vacía si Texto está
%   vacío. El stream se cierra aunque quede texto sin leer.
primera_linea(Texto, Linea) :-
    setup_call_cleanup(open_string(Texto, Stream),
                       read_line_to_string(Stream, Leida),
                       close(Stream)),
    (   Leida == end_of_file
    ->  Linea = ""
    ;   Linea = Leida
    ).

% --- Ejercicio 8 ----------------------------------------------------------

:- multifile prolog:message//1.

%!  prolog:message(+Mensaje)// is semidet.
%
%   El texto del mensaje nota_invalida(N).
prolog:message(nota_invalida(N)) -->
    [ 'La nota ~w no es válida: debe ser un entero de 1 a 10'-[N] ].

% --- Ejercicio 9 ----------------------------------------------------------

%!  limpiar_telefono(+Texto:text, -Numero:string) is det.
%
%   Numero son los diez dígitos del teléfono escrito en Texto, sin
%   espacios, guiones, puntos ni paréntesis. Produce domain_error(telefono,
%   Motivo) si el texto tiene letras, si no tiene diez dígitos, o si el
%   código de área empieza con 0 o 1.
limpiar_telefono(Texto, Numero) :-
    must_be(text, Texto),
    text_to_string(Texto, Cadena),
    string_chars(Cadena, Caracteres),
    (   member(C, Caracteres),
        char_type(C, alpha)
    ->  domain_error(telefono, letras)
    ;   true
    ),
    include([C]>>char_type(C, digit(_)), Caracteres, Digitos),
    length(Digitos, Cantidad),
    (   Cantidad =\= 10
    ->  domain_error(telefono, cantidad_de_digitos(Cantidad))
    ;   Digitos = [Primero|_],
        memberchk(Primero, ['0', '1'])
    ->  domain_error(telefono, codigo_de_area(Primero))
    ;   string_chars(Numero, Digitos)
    ).
