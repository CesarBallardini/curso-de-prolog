% Capítulo 31 - La descripción del pack fechas_castellano.
%
% pack_install/2 lee estos hechos: el nombre, la versión, una descripción
% y los autores. La versión sigue el esquema mayor.menor.corrección. El
% archivo no admite directivas, ni siquiera encoding/1: pack_install/2
% rechaza cualquier término que no sea una de sus descripciones. Por eso
% los textos de los hechos no llevan tildes.
%
% solo-local: SWISH no instala packs.

name(fechas_castellano).
version('1.0.0').
title('Fechas en castellano: cuentas con fechas y nombres propios').
author('Curso de Prolog', 'https://katra.ballardini.com.ar/curso-de-prolog/').
