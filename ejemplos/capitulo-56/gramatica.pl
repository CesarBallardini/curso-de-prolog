:- encoding(utf8).

% Capítulo 56 - Versión 2: una gramática de órdenes.
%
% orden//1 relaciona las palabras de una orden con su significado. Los
% artículos, el plural de los nombres y la concordancia de «todos» salen
% de la gramática del castellano del capítulo 54; las palabras, de
% palabras/2 de la versión 1. Los significados son:
%
%   listar(Carpeta, Filtro)      contar(Carpeta, Filtro)
%   copiar(Objeto, a(Destino))   mover(Objeto, a(Destino))
%   borrar(Objeto)               tamano(Objeto)
%   fecha(Objeto)                buscar(patron(Patron))
%   ejecutar(archivo(Ruta))      salir
%
% Un Objeto es archivo(Ruta) o archivos(Carpeta, Filtro); un Filtro es
% todos o patron(Patron), con * en lugar de cualquier secuencia. Las rutas
% y los patrones son strings; la carpeta de trabajo es ".".
%
% solo-local: carga la versión 1 y la gramática del capítulo 54 con
% ensure_loaded/1.
%
%?- entender("Copia los archivos .txt de informes a la carpeta respaldo", O).
%?- phrase(orden(borrar(archivo("viejo.log"))), Ps).

:- ensure_loaded(plantillas).
:- ensure_loaded('../capitulo-54/castellano').

% Otros archivos pueden agregar verbos, pedidos, objetos y palabras
% reservadas.
:- multifile verbo/2, pedido//1, objeto//2, reservada/1.

%!  entender(+Texto:string, -Orden) is semidet.
%
%   Orden es el significado de la primera lectura de Texto como orden.
%   Falla si Texto no es una orden de la gramática.
entender(Texto, Orden) :-
    palabras(Texto, Palabras),
    once(phrase(orden(Orden), Palabras)).

%!  orden(?Orden)// is nondet.
%
%   Una orden con su significado, con «por favor» al final o sin él.
orden(Orden) -->
    pedido(Orden),
    cortesia.

%!  cortesia// is nondet.
%
%   Nada, o «por favor».
cortesia --> [].
cortesia --> ["por", "favor"].

%!  pedido(?Orden)// is nondet.
%
%   Una orden en imperativo o en infinitivo, o una pregunta.
pedido(salir) -->
    verbo(salir).
pedido(listar(C, F)) -->
    verbo(listar),
    conjunto(C, F).
pedido(listar(C, F)) -->
    ["que"],
    sustantivo(archivo, _, pl),
    filtro(F),
    ["hay"],
    de_carpeta(C).
pedido(contar(C, F)) -->
    ["cuantos"],
    sustantivo(archivo, _, pl),
    filtro(F),
    ["hay"],
    de_carpeta(C).
pedido(copiar(O, a(D))) -->
    verbo(copiar),
    objeto(O, _),
    ["a"],
    lugar(D).
pedido(mover(O, a(D))) -->
    verbo(mover),
    objeto(O, _),
    ["a"],
    lugar(D).
pedido(mover(archivo(R), a(D))) -->
    verbo(renombrar),
    objeto(archivo(R), sg),
    ["como"],
    nombre(D).
pedido(borrar(O)) -->
    verbo(borrar),
    objeto(O, _).
pedido(tamano(O)) -->
    ["cuanto"],
    verbo_numero("ocupa", "ocupan", N),
    objeto(O, N).
pedido(tamano(O)) -->
    ["que", "tamano"],
    verbo_numero("tiene", "tienen", N),
    objeto(O, N).
pedido(fecha(O)) -->
    ["cuando", "se"],
    verbo_numero("modifico", "modificaron", N),
    objeto(O, N).
pedido(buscar(patron(P))) -->
    verbo(buscar),
    conjunto(".", patron(P)).
pedido(buscar(patron(P))) -->
    verbo(buscar),
    nombre(P).
pedido(buscar(patron(P))) -->
    ["donde", "esta"],
    nombre(P).
pedido(ejecutar(archivo(R))) -->
    verbo(ejecutar),
    objeto(archivo(R), sg).

% verbo(V, Forma): Forma es una manera de pedir V, en imperativo o en
% infinitivo. La primera forma de cada verbo es la que se genera.
verbo(listar, "lista").
verbo(listar, "muestra").
verbo(listar, "muestrame").
verbo(listar, "listar").
verbo(copiar, "copia").
verbo(copiar, "copiar").
verbo(mover, "mueve").
verbo(mover, "mover").
verbo(renombrar, "renombra").
verbo(renombrar, "renombrar").
verbo(borrar, "borra").
verbo(borrar, "elimina").
verbo(borrar, "borrar").
verbo(buscar, "busca").
verbo(buscar, "buscar").
verbo(ejecutar, "ejecuta").
verbo(ejecutar, "ejecutar").
verbo(salir, "salir").
verbo(salir, "sal").
verbo(salir, "adios").

%!  verbo(?V)// is nondet.
%
%   Una forma del verbo V.
verbo(V) -->
    [F],
    { verbo(V, F) }.

%!  verbo_numero(+Sg:string, +Pl:string, ?N)// is nondet.
%
%   La forma singular Sg o la plural Pl de un verbo, según el número N.
verbo_numero(Sg, Pl, N) -->
    [F],
    { numero_verbo(N, Sg, Pl, F) }.

%!  objeto(?Objeto, ?N)// is nondet.
%
%   Un archivo nombrado, en singular, o un conjunto de archivos, en plural.
objeto(archivo(R), sg) -->
    determinante(G, sg),
    sustantivo(archivo, G, sg),
    nombre(R).
objeto(archivo(R), sg) -->
    nombre(R).
objeto(archivos(C, F), pl) -->
    conjunto(C, F).
objeto(archivo(R), sg) -->
    nombre(N),
    ["de"],
    lugar(C),
    { atomics_to_string([C, "/", N], R) }.

%!  conjunto(?C, ?F)// is nondet.
%
%   Los archivos de la carpeta C que pasan el filtro F: «todos los
%   archivos .txt de informes».
conjunto(C, F) -->
    cuantificador(G),
    determinante(G, pl),
    sustantivo(archivo, G, pl),
    filtro(F),
    de_carpeta(C).

%!  cuantificador(?G)// is nondet.
%
%   Nada, o «todos» concordado con el género G.
cuantificador(_) -->
    [].
cuantificador(G) -->
    [F],
    { singular_adjetivo(variable, todo, G, S),
      numero_es(pl, S, F) }.

%!  determinante(?G, ?N)// is nondet.
%
%   El artículo definido de género G y número N, o ninguno, en plural.
determinante(G, N) -->
    articulo_es(el, G, N).
determinante(G, N) -->
    articulo_es(sin, G, N).

% genero(L, G): el nombre L es de género G.
genero(archivo, m).
genero(carpeta, f).

%!  sustantivo(?L, ?G, ?N)// is nondet.
%
%   La forma del nombre L, de género G, en número N.
sustantivo(L, G, N) -->
    [F],
    { genero(L, G),
      atom_string(L, S),
      numero_es(N, S, F) }.

%!  filtro(?F)// is nondet.
%
%   Nada (todos los archivos), una extensión, un patrón con asteriscos o
%   una oración de relativo: «que terminan en .txt», «que empiezan con
%   informe», «que contienen nota».
filtro(todos) -->
    [].
filtro(patron(P)) -->
    [E],
    { string_concat("*", E, P),
      extension(E) }.
filtro(patron(P)) -->
    [P],
    { string(P),
      sub_string(P, _, _, _, "*") }.
filtro(patron(P)) -->
    ["que", "terminan", "en"],
    [S],
    { string_concat("*", S, P) }.
filtro(patron(P)) -->
    ["que", "empiezan", "con"],
    [S],
    { string_concat(S, "*", P) }.
filtro(patron(P)) -->
    ["que", "contienen"],
    [S],
    { entre_asteriscos(S, P) }.

%!  entre_asteriscos(?S:string, ?P:string) is semidet.
%
%   P es S con un asterisco delante y otro detrás. S o P deben llegar
%   instanciados.
entre_asteriscos(S, P) :-
    (   var(P)
    ->  atomics_to_string(["*", S, "*"], P)
    ;   string_concat("*", S0, P),
        string_concat(S, "*", S0)
    ).

%!  extension(+E:string) is semidet.
%
%   E es un punto seguido de letras o dígitos: «.txt».
extension(E) :-
    string_concat(".", Resto, E),
    string_chars(Resto, Cs),
    Cs \== [],
    forall(member(C, Cs), char_type(C, alnum)).

%!  de_carpeta(?C)// is nondet.
%
%   Nada (la carpeta de trabajo, ".") o «de» o «en» y una carpeta.
de_carpeta(".") -->
    [].
de_carpeta(C) -->
    ( ["de"] ; ["en"] ),
    lugar(C).

%!  lugar(?C)// is nondet.
%
%   Un nombre, solo o con «la carpeta» delante.
lugar(C) -->
    nombre(C).
lugar(C) -->
    determinante(G, sg),
    sustantivo(carpeta, G, sg),
    nombre(C).

%!  nombre(?N:string)// is semidet.
%
%   Una palabra que puede nombrar un archivo o una carpeta: letras,
%   dígitos, puntos, guiones y barras, y que no es una palabra de la
%   gramática.
nombre(N) -->
    [N],
    { string(N),
      \+ reservada(N),
      string_chars(N, Cs),
      Cs \== [],
      forall(member(C, Cs), caracter_de_nombre(C)) }.

%!  caracter_de_nombre(+C:char) is semidet.
%
%   C puede aparecer en un nombre de archivo de la gramática.
caracter_de_nombre(C) :-
    (   char_type(C, alnum)
    ->  true
    ;   memberchk(C, ['.', '_', '-', '/'])
    ).

% reservada(P): P es una palabra de la gramática, que no nombra archivos.
reservada("el").
reservada("la").
reservada("los").
reservada("las").
reservada("de").
reservada("en").
reservada("a").
reservada("como").
reservada("que").
reservada("hay").
reservada("por").
reservada("todos").
reservada("archivo").
reservada("archivos").
reservada("carpeta").
