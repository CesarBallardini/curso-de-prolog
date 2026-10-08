:- encoding(utf8).

% Capítulo 24 - Examinar los módulos cargados.
%
% module_property/2 informa lo que el sistema registra de un módulo: su
% archivo, su clase, lo que exporta. predicate_property/2, con la propiedad
% imported_from(M), informa de qué módulo llegó un predicado importado; el
% capítulo 33 presenta las demás propiedades, y el capítulo 32, functor/3.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- interfaz(relaciones, Predicados).

:- module(examinar, [interfaz/2, importados/3]).

% Los módulos que se examinan en el capítulo.
:- use_module(usa_relaciones).

%!  interfaz(+Modulo:atom, -Predicados:list) is det.
%
%   Predicados son los indicadores Nombre/Aridad que exporta Modulo,
%   ordenados.
interfaz(Modulo, Predicados) :-
    module_property(Modulo, exports(Exporta)),
    msort(Exporta, Predicados).

%!  importados(+Modulo:atom, +Origen:atom, -Predicados:list) is det.
%
%   Predicados son los indicadores Nombre/Aridad que Modulo importa de
%   Origen, ordenados.
importados(Modulo, Origen, Predicados) :-
    findall(Nombre/Aridad,
            ( predicate_property(Modulo:Cabeza, imported_from(Origen)),
              functor(Cabeza, Nombre, Aridad) ),
            Encontrados),
    msort(Encontrados, Predicados).
