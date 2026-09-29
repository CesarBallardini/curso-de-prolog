:- encoding(utf8).

% Capítulo 55 - Versión 1 de los diálogos: plantillas con variables de
% segmento.
%
% Una regla empareja un patrón con una respuesta. El patrón es una lista de
% palabras, sin mayúsculas ni tildes, y de variables; cada variable
% representa un segmento de la frase, de cero o más palabras. La respuesta
% es una lista de textos y de esas mismas variables: al emparejar el patrón,
% cada variable queda ligada a sus palabras, y la respuesta las repite. Las
% palabras de la frase salen de palabras/2, del capítulo 44.
%
% solo-local: carga un archivo del capítulo 44, y SWISH no admite módulos
% propios.
%
%?- coincide([_, estoy, X], [hoy, estoy, muy, cansado]), X = Y.

:- module(plantillas,
          [ coincide/2,
            rellenar/2,
            responder/2
          ]).

:- use_module('../capitulo-44/lenguaje', [palabras/2]).

%!  coincide(+Patron:list, +Palabras:list(atom)) is nondet.
%
%   Palabras sigue el Patron: cada palabra del patrón aparece en su lugar,
%   y cada variable del patrón queda ligada a la lista de palabras que
%   ocupa su lugar, que puede ser vacía. Las alternativas dan segmentos
%   cada vez más largos a las primeras variables.
coincide([], []).
coincide([E|Es], Palabras) :-
    (   var(E)
    ->  append(E, Resto, Palabras)
    ;   Palabras = [E|Resto]
    ),
    coincide(Es, Resto).

%!  rellenar(+Plantilla:list, -Texto:string) is det.
%
%   Texto es la concatenación de los elementos de Plantilla: cada texto tal
%   como está escrito y cada lista de palabras con las palabras separadas
%   por un blanco.
rellenar(Plantilla, Texto) :-
    maplist(pieza, Plantilla, Piezas),
    atomics_to_string(Piezas, Texto).

%!  pieza(+Elemento, -Pieza:string) is det.
%
%   Pieza es el texto de un elemento de una plantilla: un texto, o una
%   lista de palabras.
pieza(Elemento, Pieza) :-
    (   is_list(Elemento)
    ->  atomic_list_concat(Elemento, ' ', Atomo),
        atom_string(Atomo, Pieza)
    ;   text_to_string(Elemento, Pieza)
    ).

% regla(Patron, Respuesta): si la frase sigue Patron, se responde con la
% plantilla Respuesta.
regla([_, estoy, X], ["¿Por qué estás ", X, "?"]).
regla([_, necesito, X], ["¿Qué harías si consiguieras ", X, "?"]).
regla([_, madre, _], ["Háblame más de tu familia."]).
regla([_, padre, _], ["Háblame más de tu familia."]).
regla([_, porque, _], ["¿Es esa la verdadera razón?"]).
regla([_], ["Continúa, por favor."]).

%!  responder(+Frase:string, -Respuesta:string) is det.
%
%   Respuesta es la respuesta de la primera regla cuyo patrón sigue Frase.
responder(Frase, Respuesta) :-
    palabras(Frase, Palabras),
    once(( regla(Patron, Plantilla),
           coincide(Patron, Palabras) )),
    rellenar(Plantilla, Respuesta).
