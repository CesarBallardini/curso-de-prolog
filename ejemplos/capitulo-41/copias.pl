:- encoding(utf8).

% Capítulo 41 - Las copias de código entre los ejemplos, sin deriva.
%
% Varios ejemplos del capítulo terminan con una copia del código de otro,
% para que cada archivo se ejecute solo en SWISH: el ta-te-ti de tateti.pl,
% la poda de alfabeta.pl, la evaluación de orden.pl. Cada copia empieza con
% un comentario que dice de dónde viene, como
% «% --- El ta-te-ti, copiado de tateti.pl ---», y sigue hasta el próximo
% comentario de esa forma. diferencias/1 compara cada predicado de cada
% copia con el mismo predicado del archivo original, cláusula por cláusula
% y como términos: el formato del texto no importa, pero cualquier cambio
% en una cláusula sí.
%
% solo-local: lee los archivos del directorio, a los que SWISH no accede.
%
%?- diferencias(Ds).

%!  diferencias(-Diferencias:list) is det.
%
%   Diferencias son las cláusulas copiadas que no coinciden con el original,
%   en todos los archivos .pl del directorio de este archivo, cada una como
%   deriva(Archivo, Original, Nombre/Aridad, I, Copia, Fuente): la
%   cláusula I de Nombre/Aridad es Copia en Archivo y Fuente en Original.
%   Si una de las dos no existe, en su lugar está ninguna.
diferencias(Diferencias) :-
    directorio(Directorio),
    directory_file_path(Directorio, '*.pl', Patron),
    expand_file_name(Patron, Archivos),
    foldl(diferencias_archivo, Archivos, Diferencias, []).

%!  directorio(-Directorio) is det.
%
%   Directorio es el de este archivo, que es también el de los ejemplos.
directorio(Directorio) :-
    source_file(directorio(_), Archivo),
    file_directory_name(Archivo, Directorio).

%!  diferencias_archivo(+Archivo, -Diferencias:list, ?Resto:list) is det.
%
%   Diferencias son las de las copias de Archivo, seguidas de Resto.
diferencias_archivo(Archivo, Diferencias, Resto) :-
    clausulas(Archivo, Clausulas),
    findall(Original-Indicador,
            ( member(copia(Original)-Clausula, Clausulas),
              indicador(Clausula, Indicador) ),
            Pares),
    sort(Pares, Copiados),
    foldl(diferencias_predicado(Archivo, Clausulas), Copiados,
          Diferencias, Resto).

%!  diferencias_predicado(+Archivo, +Clausulas:list, +Copiado,
%!      -Diferencias:list, ?Resto:list) is det.
%
%   Diferencias son las cláusulas del predicado Copiado, un par
%   Original-Nombre/Aridad, que en la copia de Archivo no coinciden con las
%   propias de Original, seguidas de Resto.
diferencias_predicado(Archivo, Clausulas, Original-Indicador,
                      Diferencias, Resto) :-
    del_predicado(Clausulas, copia(Original), Indicador, Copias),
    directorio(Directorio),
    directory_file_path(Directorio, Original, Ruta),
    clausulas(Ruta, Fuentes0),
    del_predicado(Fuentes0, propia, Indicador, Fuentes),
    file_base_name(Archivo, Base),
    comparar(Copias, Fuentes, 1, deriva(Base, Original, Indicador),
             Diferencias, Resto).

%!  del_predicado(+Clausulas:list, +Origen, +Indicador, -Del:list) is det.
%
%   Del son las cláusulas de Clausulas con ese Origen cuyo predicado es
%   Indicador, en su orden.
del_predicado(Clausulas, Origen, Indicador, Del) :-
    findall(C,
            ( member(Origen-C, Clausulas),
              indicador(C, Indicador) ),
            Del).

%!  comparar(+Copias:list, +Fuentes:list, +I:integer, +Diferencia,
%!      -Diferencias:list, ?Resto:list) is det.
%
%   Diferencias son las posiciones, desde I, en las que Copias y Fuentes
%   no tienen cláusulas variantes, completando Diferencia, seguidas de
%   Resto.
comparar([], [], _, _, Resto, Resto) :-
    !.
comparar(Copias, Fuentes, I, Diferencia, Diferencias, Resto) :-
    primera(Copias, Copia, Copias1),
    primera(Fuentes, Fuente, Fuentes1),
    (   Copia =@= Fuente
    ->  Diferencias = Diferencias1
    ;   Diferencia = deriva(Archivo, Original, Indicador),
        Diferencias = [deriva(Archivo, Original, Indicador, I,
                                  Copia, Fuente) | Diferencias1]
    ),
    I1 is I + 1,
    comparar(Copias1, Fuentes1, I1, Diferencia, Diferencias1, Resto).

%!  primera(+Lista:list, -Primera, -Resto:list) is det.
%
%   Primera es el primer elemento de Lista, o ninguna si está vacía.
primera([], ninguna, []).
primera([X|Xs], X, Xs).

%!  indicador(+Clausula, -Indicador) is det.
%
%   Indicador es Nombre/Aridad del predicado que define Clausula.
indicador(Clausula, Nombre/Aridad) :-
    (   Clausula = (Cabeza :- _)
    ->  true
    ;   Cabeza = Clausula
    ),
    functor(Cabeza, Nombre, Aridad).

%!  clausulas(+Archivo, -Clausulas:list) is det.
%
%   Clausulas son las de Archivo, sin las directivas, cada una como
%   Origen-Clausula: Origen es copia(Original) si está en una copia de
%   Original, y propia si no.
clausulas(Archivo, Clausulas) :-
    setup_call_cleanup(open(Archivo, read, Flujo, [encoding(utf8)]),
                       leer(Flujo, propia, Clausulas),
                       close(Flujo)).

%!  leer(+Flujo, +Origen0, -Clausulas:list) is det.
%
%   Clausulas son las que quedan por leer en Flujo; Origen0 es el origen
%   de la sección en la que está la lectura.
leer(Flujo, Origen0, Clausulas) :-
    read_term(Flujo, Termino, [comments(Comentarios)]),
    foldl(seccion, Comentarios, Origen0, Origen),
    (   Termino == end_of_file
    ->  Clausulas = []
    ;   Termino = (:- _)
    ->  leer(Flujo, Origen, Clausulas)
    ;   Clausulas = [Origen-Termino | Resto],
        leer(Flujo, Origen, Resto)
    ).

%!  seccion(+Comentario, +Origen0, -Origen) is det.
%
%   Origen es el de la sección que abre Comentario, si empieza con
%   «% --- »: copia(Original) si dice «copiado de Original», y propia si
%   no. Cualquier otro comentario deja Origen0.
seccion(_-Comentario, Origen0, Origen) :-
    (   sub_string(Comentario, 0, _, _, "% --- ")
    ->  split_string(Comentario, " ", "", Palabras),
        (   append(_, ["copiado", "de", Nombre | _], Palabras)
        ->  atom_string(Original, Nombre),
            Origen = copia(Original)
        ;   Origen = propia
        )
    ;   Origen = Origen0
    ).
