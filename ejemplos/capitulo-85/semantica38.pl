:- encoding(utf8).

% Capítulo 85 - Los evaluadores del capítulo 38, desde un módulo.
%
% semantica.pl y experto.pl del capítulo 38 no son módulos. El capítulo
% 77 ya carga semantica.pl dentro del módulo capitulo38, y SWI-Prolog no
% permite cargar el mismo archivo en dos módulos; este archivo carga ese
% módulo, le agrega experto.pl, y da acceso a cinco de sus predicados:
% clausulas/2, las cláusulas de un programa por su nombre (lluvia,
% caminos, grafo, juego, circular, cadena(N), base(Version));
% semi_ingenua_de/4 y modelo_estandar_de/2, las evaluaciones de abajo
% hacia arriba sobre una lista ordenada de átomos; estratos_de/2, los
% estratos calculados por rondas; y bien_fundado_de/3, el modelo bien
% fundado.
%
% solo-local: carga archivos de otros capítulos, y SWISH no permite cargar
% otro archivo.
%
%?- clausulas(caminos, Cs).

:- module(semantica38,
          [ clausulas/2,
            semi_ingenua_de/4,
            modelo_estandar_de/2,
            estratos_de/2,
            bien_fundado_de/3
          ]).

:- use_module('../capitulo-77/capitulo38', []).
:- load_files(capitulo38:'../capitulo-38/experto', []).

%!  clausulas(+Programa, -Clausulas:list) is det.
%
%   clausulas/2 del capítulo 38: las cláusulas del programa Programa.
clausulas(Programa, Clausulas) :-
    capitulo38:clausulas(Programa, Clausulas).

%!  semi_ingenua_de(+Clausulas:list, +I0:list, -M:list, -Costo) is det.
%
%   semi_ingenua_de/4 del capítulo 38.
semi_ingenua_de(Clausulas, I0, M, Costo) :-
    capitulo38:semi_ingenua_de(Clausulas, I0, M, Costo).

%!  modelo_estandar_de(+Clausulas:list, -M:list) is semidet.
%
%   modelo_estandar_de/2 del capítulo 38.
modelo_estandar_de(Clausulas, M) :-
    capitulo38:modelo_estandar_de(Clausulas, M).

%!  estratos_de(+Clausulas:list, -Estratos:list) is semidet.
%
%   estratos_de/2 del capítulo 38.
estratos_de(Clausulas, Estratos) :-
    capitulo38:estratos_de(Clausulas, Estratos).

%!  bien_fundado_de(+Clausulas:list, -Verdaderos:list, -Indefinidos:list)
%!      is det.
%
%   bien_fundado_de/3 del capítulo 38.
bien_fundado_de(Clausulas, Verdaderos, Indefinidos) :-
    capitulo38:bien_fundado_de(Clausulas, Verdaderos, Indefinidos).
