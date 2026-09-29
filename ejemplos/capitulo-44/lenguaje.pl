:- encoding(utf8).

% Capítulo 44 - Versión 4 de la aventura: órdenes y respuestas en
% castellano.
%
% Dos gramáticas. La primera, orden//1, trabaja sobre las palabras de la
% orden, sin mayúsculas ni tildes, y la relaciona con un término de
% realizar/2; los sustantivos no están escritos en ella: salen de los
% nombres del mundo, pasados por el mismo predicado palabras/2. La segunda,
% respuesta//1, genera el texto de una respuesta, dirigido al jugador en
% segunda persona: artículos según el género, la contracción al,
% enumeraciones con comas y la conjunción y. entender/2 elige, entre las lecturas posibles de una
% orden, la primera que el estado permite ejecutar.
%
% solo-local: SWISH no admite módulos propios.
%
%?- iniciar, ejecutar("Ir a la biblioteca", Texto).

:- module(lenguaje,
          [ palabras/2,
            orden//1,
            respuesta//1,
            entender/2,
            responder/2,
            ejecutar/2
          ]).

:- reexport(partidas).

:- multifile
    forma/2.

%!  palabras(+Texto:string, -Palabras:list(atom)) is det.
%
%   Palabras son las palabras de Texto en minúsculas y sin tildes; los
%   signos de puntuación y los blancos las separan.
palabras(Texto, Palabras) :-
    string_lower(Texto, Minusculas),
    string_codes(Minusculas, Codigos0),
    maplist(sin_tilde, Codigos0, Codigos),
    phrase(lista_de_palabras(Palabras), Codigos).

%!  sin_tilde(+C0:integer, -C:integer) is det.
%
%   C es el código C0 sin tilde ni diéresis.
sin_tilde(C0, C) :-
    (   tilde(C0, C1)
    ->  C = C1
    ;   C = C0
    ).

% tilde(C0, C): la vocal C0 lleva tilde o diéresis, y C es la vocal sin ella.
tilde(0'á, 0'a).
tilde(0'é, 0'e).
tilde(0'í, 0'i).
tilde(0'ó, 0'o).
tilde(0'ú, 0'u).
tilde(0'ü, 0'u).

%!  lista_de_palabras(-Palabras:list(atom))// is det.
%
%   Las palabras del texto, con los separadores descartados.
lista_de_palabras(Palabras) -->
    separadores,
    (   palabra(P)
    ->  { Palabras = [P|Ps] },
        lista_de_palabras(Ps)
    ;   { Palabras = [] }
    ).

%!  separadores// is det.
%
%   Los códigos que no son letras ni dígitos.
separadores -->
    [C],
    { \+ code_type(C, alnum) },
    !,
    separadores.
separadores -->
    [].

%!  palabra(-P:atom)// is semidet.
%
%   Una palabra: letras y dígitos seguidos.
palabra(P) -->
    letra(C),
    letras(Cs),
    { atom_codes(P, [C|Cs]) }.

%!  letras(-Cs:list(integer))// is det.
%
%   Las letras y los dígitos que siguen, tantos como haya.
letras([C|Cs]) -->
    letra(C),
    !,
    letras(Cs).
letras([]) -->
    [].

%!  letra(-C:integer)// is semidet.
%
%   Una letra o un dígito.
letra(C) -->
    [C],
    { code_type(C, alnum) }.

% forma(Verbo, Palabras): Palabras es una manera de decir Verbo.
forma(mirar, [mirar]).
forma(mirar, [mirar, alrededor]).
forma(mirar, [m]).
forma(inventario, [inventario]).
forma(inventario, [i]).
forma(inventario, [que, llevo]).
forma(ir, [ir]).
forma(ir, [entrar]).
forma(ir, [subir]).
forma(ir, [bajar]).
forma(ir, [volver]).
forma(examinar, [examinar]).
forma(examinar, [mirar]).
forma(examinar, [mirar, en]).
forma(tomar, [tomar]).
forma(tomar, [agarrar]).
forma(tomar, [sacar]).
forma(dejar, [dejar]).
forma(dejar, [soltar]).
forma(poner, [poner]).
forma(poner, [dejar]).
forma(poner, [meter]).
forma(abrir, [abrir]).
forma(encender, [encender]).
forma(encender, [prender]).
forma(apagar, [apagar]).
forma(guardar, [guardar]).
forma(cargar, [cargar]).
forma(ayuda, [ayuda]).
forma(salir, [salir]).
forma(salir, [fin]).

%!  orden(?Orden)// is nondet.
%
%   Las palabras de Orden. Orden es un término de realizar/2 o una orden
%   del juego: ayuda, salir, guardar(Partida) o cargar(Partida).
orden(Verbo) -->
    { sin_argumentos(Verbo) },
    verbo(Verbo).
orden(ir(S)) -->
    verbo(ir),
    destino(S).
orden(ir(S)) -->
    articulo(G),
    sala(S),
    { nombre(S, G, _) }.
orden(Orden) -->
    { con_un_argumento(Verbo),
      Orden =.. [Verbo, X] },
    verbo(Verbo),
    cosa(X).
orden(poner(O, R)) -->
    verbo(poner),
    cosa(O),
    [en],
    cosa(R).
orden(Orden) -->
    { partida(Verbo),
      Orden =.. [Verbo, P] },
    verbo(Verbo),
    nombre_de_partida(P).

% sin_argumentos(V): la orden V no lleva complemento.
sin_argumentos(mirar).
sin_argumentos(inventario).
sin_argumentos(ayuda).
sin_argumentos(salir).

% con_un_argumento(V): la orden V lleva una cosa como complemento.
con_un_argumento(examinar).
con_un_argumento(tomar).
con_un_argumento(dejar).
con_un_argumento(abrir).
con_un_argumento(encender).
con_un_argumento(apagar).

% partida(V): la orden V lleva el nombre de una partida.
partida(guardar).
partida(cargar).

%!  verbo(?Verbo)// is nondet.
%
%   Una de las formas de decir Verbo.
verbo(Verbo) -->
    { forma(Verbo, Palabras) },
    Palabras.

%!  destino(?S)// is nondet.
%
%   Una sala precedida de a, al, hacia o en, con o sin artículo.
destino(S) -->
    [al],
    sala(S),
    { nombre(S, m, _) }.
destino(S) -->
    [P],
    { preposicion(P) },
    articulo(G),
    sala(S),
    { nombre(S, G, _) }.

% preposicion(P): P introduce el destino de ir.
preposicion(a).
preposicion(hacia).
preposicion(en).

%!  articulo(?G)// is nondet.
%
%   Un artículo de género G, o nada.
articulo(_) -->
    [].
articulo(G) -->
    [A],
    { determinante(A, G) }.

% determinante(A, G): A es un artículo de género G.
determinante(el, m).
determinante(la, f).
determinante(un, m).
determinante(una, f).

%!  sala(?S)// is nondet.
%
%   El nombre de la sala S.
sala(S) -->
    nombrada(S),
    { sala(S, _) }.

%!  cosa(?X)// is nondet.
%
%   El nombre de un objeto o de una puerta, con o sin artículo; el
%   artículo concuerda con el género del nombre.
cosa(X) -->
    articulo(G),
    nombrada(X),
    { nombre(X, G, _),
      \+ sala(X, _) }.

%!  nombrada(?X)// is nondet.
%
%   El nombre completo de X, o su primera palabra si el nombre tiene más
%   de una: «llave de bronce» o «llave».
nombrada(X) -->
    { nombre(X, _, Texto),
      palabras(Texto, Ps) },
    (   Ps
    ;   { Ps = [Nucleo, _|_] },
        [Nucleo]
    ).

%!  nombre_de_partida(?P)// is nondet.
%
%   El nombre de una partida guardada: una palabra, o partida si no se
%   escribe ninguno.
nombre_de_partida(P) -->
    [P].
nombre_de_partida(partida) -->
    [].

%!  entender(+Texto:string, -Orden) is det.
%
%   Orden es la lectura de Texto que se va a ejecutar: la primera que
%   ningún impedimento bloquea, o la primera de todas si todas tienen uno.
%   Es no_entendido si Texto no es una orden.
entender(Texto, Orden) :-
    palabras(Texto, Palabras),
    findall(O, phrase(orden(O), Palabras), Os0),
    list_to_set(Os0, Os),
    (   Os == []
    ->  Orden = no_entendido
    ;   member(O, Os),
        \+ impedimento(O, _)
    ->  Orden = O
    ;   Os = [Orden|_]
    ).

%!  responder(+Orden, -Texto:string) is det.
%
%   Ejecuta Orden y da el texto de sus respuestas.
responder(Orden, Texto) :-
    resultado(Orden, Respuestas),
    phrase(respuestas(Respuestas), Codigos),
    string_codes(Texto, Codigos).

%!  ejecutar(+Texto:string, -Salida:string) is det.
%
%   Entiende la orden Texto, la ejecuta y da el texto de la respuesta.
ejecutar(Texto, Salida) :-
    entender(Texto, Orden),
    responder(Orden, Salida).

%!  resultado(+Orden, -Respuestas:list) is det.
%
%   Ejecuta Orden; Respuestas son los términos de sus respuestas. La
%   orden que gana la partida agrega victoria.
resultado(Orden, Respuestas) :-
    (   del_juego(Orden, Rs)
    ->  Respuestas = Rs
    ;   (   ganado
        ->  Antes = ganada
        ;   Antes = en_juego
        ),
        realizar(Orden, R),
        (   Antes == en_juego,
            ganado
        ->  Respuestas = [R, victoria]
        ;   Respuestas = [R]
        )
    ).

%!  del_juego(+Orden, -Respuestas:list) is semidet.
%
%   Orden es una orden del juego, no del mundo, y Respuestas son sus
%   respuestas. Un error al guardar o al cargar se informa como respuesta.
del_juego(no_entendido, [no_entendido]).
del_juego(ayuda, [ayuda]).
del_juego(salir, [fin]).
del_juego(guardar(P), [R]) :-
    file_name_extension(P, partida, Archivo),
    catch(( guardar(Archivo), R = guardada(Archivo) ),
          error(_, _),
          R = no_guardada(Archivo)).
del_juego(cargar(P), Respuestas) :-
    file_name_extension(P, partida, Archivo),
    catch(( cargar(Archivo), realizar(mirar, V),
            Respuestas = [cargada(Archivo), V] ),
          error(_, _),
          Respuestas = [no_cargada(Archivo)]).

%!  respuestas(+Respuestas:list)// is det.
%
%   Las oraciones de Respuestas, separadas por un blanco.
respuestas([R|Rs]) -->
    oracion(R),
    otras_respuestas(Rs).

%!  otras_respuestas(+Respuestas:list)// is det.
%
%   Las oraciones de Respuestas, cada una precedida por un blanco.
otras_respuestas([]) -->
    [].
otras_respuestas([R|Rs]) -->
    " ",
    oracion(R),
    otras_respuestas(Rs).

%!  oracion(+R)// is det.
%
%   El texto de la respuesta R, con la primera letra en mayúscula.
oracion(R) -->
    { phrase(respuesta(R), [C0|Cs]),
      char_code(Minuscula, C0),
      upcase_atom(Minuscula, Mayuscula),
      char_code(Mayuscula, C) },
    [C],
    Cs.

%!  respuesta(+R)// is det.
%
%   El texto de la respuesta R, sin la mayúscula inicial.
respuesta(vista(S, Os, Salidas)) -->
    "estás en ",
    el(S),
    ". ",
    { sala(S, Descripcion) },
    texto(Descripcion),
    a_la_vista(Os),
    " Desde aquí puedes ir ",
    enumeracion(al, Salidas),
    ".".
respuesta(oscuridad) -->
    "está muy oscuro: no ves nada.".
respuesta(contenido(R, Os)) -->
    contenido(Os, R).
respuesta(cerrado(X)) -->
    el(X),
    " está cerrad",
    terminacion(X),
    ".".
respuesta(sin_nada(X)) -->
    "no ves nada de particular en ",
    el(X),
    ".".
respuesta(inventario(Os)) -->
    inventario(Os).
respuesta(tomado(O)) -->
    "tomas ",
    el(O),
    ".".
respuesta(dejado(O, S)) -->
    "dejas ",
    el(O),
    " en ",
    el(S),
    ".".
respuesta(puesto(O, R)) -->
    "pones ",
    el(O),
    " en ",
    el(R),
    ".".
respuesta(abierto(X)) -->
    "abres ",
    el(X),
    ".".
respuesta(luz_encendida(O)) -->
    "enciendes ",
    el(O),
    ".".
respuesta(luz_apagada(O)) -->
    "apagas ",
    el(O),
    ".".
respuesta(no_puede(Motivo)) -->
    motivo(Motivo).
respuesta(victoria) -->
    { final(Texto) },
    texto(Texto).
respuesta(no_entendido) -->
    "no entiendo esa orden; escribe «ayuda» para ver las órdenes \c
     posibles.".
respuesta(ayuda) -->
    "puedes dar estas órdenes: mirar, ir a una sala, examinar, tomar, \c
     dejar, poner algo en algo, abrir, encender, apagar, inventario, \c
     guardar, cargar y salir.".
respuesta(fin) -->
    "fin de la partida.".
respuesta(guardada(Archivo)) -->
    "partida guardada en ",
    texto(Archivo),
    ".".
respuesta(no_guardada(Archivo)) -->
    "no fue posible guardar la partida en ",
    texto(Archivo),
    ".".
respuesta(cargada(Archivo)) -->
    "partida cargada de ",
    texto(Archivo),
    ".".
respuesta(no_cargada(Archivo)) -->
    "no fue posible cargar la partida de ",
    texto(Archivo),
    ".".

%!  motivo(+M)// is det.
%
%   El texto del motivo M por el que una orden no se ejecuta.
motivo(ya_esta(S)) -->
    "ya estás en ",
    el(S),
    ".".
motivo(no_hay_paso(S)) -->
    "desde aquí no puedes ir ",
    al(S),
    ".".
motivo(cerrado(X)) -->
    respuesta(cerrado(X)).
motivo(oscuro) -->
    "está demasiado oscuro para eso.".
motivo(no_lo_tiene(O)) -->
    "no llevas ",
    el(O),
    ".".
motivo(no_esta(X)) -->
    el(X),
    " no está al alcance.".
motivo(ya_lo_tiene(O)) -->
    "ya llevas ",
    el(O),
    ".".
motivo(fijo(O)) -->
    "no puedes llevarte ",
    el(O),
    ".".
motivo(no_es_recipiente(R)) -->
    "no puedes poner nada en ",
    el(R),
    ".".
motivo(no_se_abre(X)) -->
    el(X),
    " no se abre.".
motivo(ya_abierto(X)) -->
    el(X),
    " ya está abiert",
    terminacion(X),
    ".".
motivo(falta(L, X)) -->
    "no puedes abrir ",
    el(X),
    ": está cerrad",
    terminacion(X),
    " con llave; necesitas ",
    el(L),
    ".".
motivo(no_se_enciende(O)) -->
    el(O),
    " no se enciende.".
motivo(ya_encendido(O)) -->
    el(O),
    " ya está encendid",
    terminacion(O),
    ".".
motivo(ya_apagado(O)) -->
    el(O),
    " ya está apagad",
    terminacion(O),
    ".".

%!  contenido(+Objetos:list, +R)// is det.
%
%   La oración que dice que Objetos están en el recipiente R.
contenido([], R) -->
    el(R),
    " está vací",
    terminacion(R),
    ".".
contenido([O|Os], R) -->
    "en ",
    el(R),
    " ves ",
    enumeracion(un, [O|Os]),
    ".".

%!  inventario(+Objetos:list)// is det.
%
%   La oración que dice que el jugador lleva Objetos.
inventario([]) -->
    "no llevas nada.".
inventario([O|Os]) -->
    "llevas ",
    enumeracion(un, [O|Os]),
    ".".

%!  a_la_vista(+Objetos:list)// is det.
%
%   La oración que enumera Objetos, precedida por un blanco, o nada si no
%   hay objetos.
a_la_vista([]) -->
    [].
a_la_vista([O|Os]) -->
    " Ves ",
    enumeracion(un, [O|Os]),
    ".".

%!  enumeracion(:Nombrar, +Xs:list)// is det.
%
%   Los elementos de Xs, cada uno nombrado por el no terminal Nombrar,
%   separados por comas y con y antes del último. Xs no es vacía.
enumeracion(Nombrar, [X|Xs]) -->
    call(Nombrar, X),
    resto_de_enumeracion(Xs, Nombrar).

%!  resto_de_enumeracion(+Xs:list, :Nombrar)// is det.
%
%   Los elementos de Xs, cada uno precedido por una coma, o por y si es
%   el último.
resto_de_enumeracion([], _) -->
    [].
resto_de_enumeracion([X|Xs], Nombrar) -->
    (   { Xs == [] }
    ->  " y "
    ;   ", "
    ),
    call(Nombrar, X),
    resto_de_enumeracion(Xs, Nombrar).

%!  el(+X)// is det.
%
%   El nombre de X con el artículo definido.
el(X) -->
    { nombre(X, G, Texto) },
    (   { G == m }
    ->  "el "
    ;   "la "
    ),
    texto(Texto).

%!  un(+X)// is det.
%
%   El nombre de X con el artículo indefinido.
un(X) -->
    { nombre(X, G, Texto) },
    (   { G == m }
    ->  "un "
    ;   "una "
    ),
    texto(Texto).

%!  al(+X)// is det.
%
%   El nombre de X precedido por a y el artículo: al o a la.
al(X) -->
    { nombre(X, G, Texto) },
    (   { G == m }
    ->  "al "
    ;   "a la "
    ),
    texto(Texto).

%!  terminacion(+X)// is det.
%
%   La terminación de un adjetivo que concuerda con X: o, o a.
terminacion(X) -->
    { nombre(X, G, _) },
    (   { G == m }
    ->  "o"
    ;   "a"
    ).

%!  texto(+Texto:text)// is det.
%
%   Los códigos de Texto.
texto(Texto) -->
    { string_codes(Texto, Codigos) },
    Codigos.
