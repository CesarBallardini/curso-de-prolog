:- encoding(utf8).

% Capítulo 54 - Versión 1: traducción palabra por palabra.
%
% Un diccionario de formas: cada forma castellana con la forma inglesa que
% le corresponde. palabra_por_palabra/2 reemplaza cada palabra por su
% equivalente, en el mismo orden. Las palabras son strings: así «él», con
% tilde, es una palabra distinta de «el», y ningún átomo del programa
% lleva tilde.
%
%?- palabra_por_palabra(["el", "gato", "negro", "come"], En).
%?- palabra_por_palabra(Es, ["the", "black", "cats"]).

% equivalente(Es, En): la forma castellana Es se traduce por la inglesa En.
equivalente("el", "the").
equivalente("la", "the").
equivalente("los", "the").
equivalente("las", "the").
equivalente("un", "a").
equivalente("una", "a").
equivalente("una", "an").
equivalente("él", "he").
equivalente("ella", "she").
equivalente("gato", "cat").
equivalente("gatos", "cats").
equivalente("manzana", "apple").
equivalente("manzanas", "apples").
equivalente("negro", "black").
equivalente("negra", "black").
equivalente("negros", "black").
equivalente("negras", "black").
equivalente("come", "eats").
equivalente("comen", "eat").

%!  palabra_por_palabra(?Es:list(string), ?En:list(string)) is nondet.
%
%   En es la lista de los equivalentes de las palabras de Es, en el mismo
%   orden. Una de las dos listas debe tener largo conocido.
palabra_por_palabra(Es, En) :-
    maplist(equivalente, Es, En).
