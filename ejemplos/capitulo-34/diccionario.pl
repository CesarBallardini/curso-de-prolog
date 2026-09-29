:- encoding(utf8).

% Capítulo 34 - Diccionarios incompletos.
%
% Un diccionario incompleto es una estructura abierta de pares clave-valor.
% buscar/3 lo recorre: si encuentra la clave, unifica el valor; si llega al
% final abierto, agrega el par. La misma llamada consulta y agrega, y el
% valor de una clave nueva puede quedar libre y ligarse más tarde.
% codificar/2 da a cada palabra distinta un número, en el orden de su
% primera aparición: primero reúne las palabras con sus valores libres, y al
% final los numera. buscar_arbol/3 hace lo mismo sobre un árbol binario
% abierto, con menos comparaciones por búsqueda.
%
%?- buscar(b, [a-1, b-2|D], V).
%?- buscar(c, [a-1, b-2|D], V).
%?- codigos([el, gato, y, el, perro], D, C).
%?- codificar([el, gato, y, el, perro], C).
%?- buscar_arbol(b, A, 2), buscar_arbol(a, A, 1), buscar_arbol(b, A, V).

%!  buscar(+Clave, ?Dic:list, ?Valor) is semidet.
%
%   Dic es un diccionario incompleto: una lista abierta de pares
%   Clave-Valor, con claves distintas. Si Clave está en Dic, Valor unifica
%   con su valor; si no, el par Clave-Valor se agrega al final. Falla si la
%   clave está con otro valor.
buscar(Clave, [Clave0-Valor0|Resto], Valor) :-
    (   Clave = Clave0
    ->  Valor = Valor0
    ;   buscar(Clave, Resto, Valor)
    ).

%!  codificar(+Palabras:list, -Codigos:list(integer)) is det.
%
%   Codigos tiene, para cada palabra, el número de la primera aparición de
%   esa palabra entre las distintas: 1 para la primera, 2 para la segunda
%   palabra distinta, y así.
codificar(Palabras, Codigos) :-
    codigos(Palabras, Dic, Codigos),
    numerar(Dic, 1).

%!  codigos(+Palabras:list, ?Dic:list, -Codigos:list) is det.
%
%   Codigos tiene el valor de cada palabra en el diccionario incompleto
%   Dic; las palabras nuevas se agregan con el valor libre.
codigos([], _, []).
codigos([P|Ps], Dic, [C|Cs]) :-
    buscar(P, Dic, C),
    codigos(Ps, Dic, Cs).

%!  numerar(+Dic:list, +N:integer) is det.
%
%   Liga los valores del diccionario incompleto Dic a N, N+1, …, en orden,
%   hasta el final abierto.
numerar(Final, _) :-
    var(Final),
    !.
numerar([_-N|Resto], N) :-
    N1 is N + 1,
    numerar(Resto, N1).

%!  buscar_arbol(+Clave, ?Arbol, ?Valor) is semidet.
%
%   Arbol es un diccionario incompleto en forma de árbol binario de
%   búsqueda: t(Clave, Valor, Izq, Der), con los subárboles libres donde
%   todavía no hay entradas. Si Clave está, Valor unifica con su valor; si
%   no, el par se agrega en el lugar libre que le corresponde.
buscar_arbol(Clave, Arbol, Valor) :-
    (   var(Arbol)
    ->  Arbol = t(Clave, Valor, _, _)
    ;   Arbol = t(Clave0, Valor0, Izq, Der),
        compare(Orden, Clave, Clave0),
        buscar_en(Orden, Clave, Valor, Valor0, Izq, Der)
    ).

%!  buscar_en(+Orden, +Clave, ?Valor, ?Valor0, ?Izq, ?Der) is semidet.
%
%   Sigue la búsqueda de Clave según su Orden respecto de la raíz, cuyo
%   valor es Valor0.
buscar_en(=, _, Valor, Valor, _, _).
buscar_en(<, Clave, Valor, _, Izq, _) :-
    buscar_arbol(Clave, Izq, Valor).
buscar_en(>, Clave, Valor, _, _, Der) :-
    buscar_arbol(Clave, Der, Valor).

%!  codigos_arbol(+Palabras:list, ?Arbol, -Codigos:list) is det.
%
%   La misma relación que codigos/3, con el diccionario en un árbol.
codigos_arbol([], _, []).
codigos_arbol([P|Ps], Arbol, [C|Cs]) :-
    buscar_arbol(P, Arbol, C),
    codigos_arbol(Ps, Arbol, Cs).

%!  mezcladas(+N:integer, -Claves:list(integer)) is det.
%
%   Claves tiene N enteros distintos entre 0 y 10006, en un orden
%   desordenado: I * 7919 mod 10007, para I de 1 a N. N no pasa de 10006.
mezcladas(N, Claves) :-
    numlist(1, N, Is),
    maplist(mezclar, Is, Claves).

%!  mezclar(+I:integer, -K:integer) is det.
%
%   K es I * 7919 mod 10007.
mezclar(I, K) :-
    K is I * 7919 mod 10007.
