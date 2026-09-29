:- encoding(utf8).

% Capítulo 66 - El proyecto completo: la evidencia combinada (versiones 1
% y 2) y el árbol de preguntas compilado (versiones 3 a 5), sobre el
% sistema experto del capítulo 33.
%
% solo-local: carga el sistema experto del capítulo 33, y SWISH no admite
% módulos propios.
%
%?- estimaciones([tiene_pelo-0.9, come_carne-0.7, color_leonado-0.8,
%?-               manchas_oscuras-0.6, rayas_negras-0.3], E).
%?- caso(3, Os), identificar_compilado(Os, H).

:- use_module(cotas).
:- use_module(compilado).
