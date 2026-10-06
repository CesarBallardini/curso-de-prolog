:- encoding(utf8).

% Capítulo 86 - Versión 8: las vistas.
%
% CREATE VIEW compila la consulta una vez y la guarda como una cláusula
% del módulo relaciones, cuya cabeza lleva los valores de una fila y cuyo
% cuerpo es la meta compilada. El catálogo la registra con un generador
% de la misma forma que el de una tabla: quien la usa en un FROM no puede
% distinguirla de una tabla guardada, como observan Kluźniak y Szpakowicz
% sobre las relaciones calculadas. Es la primera extensión que su texto
% propone para Toy-Sequel.
%
% solo-local: carga los módulos del capítulo y agrega cláusulas.
%
%?- vista(crear_vista(aprobadas, Q), R).

:- module(vistas,
          [ vista/2
          ]).

:- use_module(catalogo).
:- use_module(consultas).
:- use_module(library(lists)).
:- use_module(library(apply)).

%!  vista(+Sentencia, -Resultado) is det.
%
%   Ejecuta crear_vista(V, Q), con Resultado creada(V), o borrar_vista(V),
%   con Resultado borrada(V).
vista(crear_vista(V, Q), creada(V)) :-
    (   relacion(V, _, _, _)
    ->  throw(error(sql(ya_existe(V)), _))
    ;   true
    ),
    compilar_consulta(Q, [], Meta, Valores, Columnas),
    maplist(nombre_columna, Columnas, Nombres),
    (   append(_, [N|Resto], Nombres),
        memberchk(N, Resto)
    ->  throw(error(sql(columna_repetida(N)), _))
    ;   true
    ),
    Cabeza =.. [V|Valores],
    assertz(relaciones:(Cabeza :- Meta)),
    length(Valores, Aridad),
    length(Variables, Aridad),
    Generador =.. [V|Variables],
    maplist(columna_vista, Columnas, Variables, Cols),
    assertz(relacion(V, vista, relaciones:Generador, Cols)).
vista(borrar_vista(V), borrada(V)) :-
    (   relacion(V, vista, Generador, _)
    ->  retractall(Generador),
        retractall(relacion(V, _, _, _))
    ;   throw(error(sql(no_es_vista(V)), _))
    ).

% nombre_columna(Col, N): N es el nombre de la columna del resultado.
nombre_columna(col(N, _, _), N).

% columna_vista(Col, V, C): la columna del catálogo, con la variable V.
columna_vista(col(N, T, Nulo), V, col(N, T, Nulo, V)).
