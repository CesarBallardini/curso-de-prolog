:- encoding(utf8).

% Capítulo 42 - Prolog y SQL: la base académica como módulo.
%
% Incluye universidad.pl y exporta sus tablas, el esquema (tabla/3,
% clave/2, referencia/4, admite_nulo/2, rango/4), fila/2, la vista
% aprobada/3 y las actualizaciones que respetan el esquema. Lo cargan
% sqlite.pl, para copiar la base en SQLite, y los programas que consultan
% los mismos datos desde otro módulo.
%
% solo-local: es un módulo que incluye otro archivo, y SWISH no los admite.
%
%?- base:alumno(L, N, sistemas, _).

:- module(base,
          [ alumno/4,
            materia/3,
            correlativa/2,
            inscripcion/3,
            tabla/3,
            clave/2,
            referencia/4,
            admite_nulo/2,
            rango/4,
            fila/2,
            aprobada/3,
            violacion/1,
            insertar/1,
            borrar/1,
            poner_nota/3
          ]).

:- include(universidad).
