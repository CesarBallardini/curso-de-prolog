:- encoding(utf8).

% Capítulo 73 - Versión 4: el horario como modelo de restricciones.
%
% Cada clase tiene dos variables de library(clpfd): su momento S y su
% aula A. Las reglas de una sola clase son dominios: S solo toma momentos
% de los días en que el docente está disponible, A solo aulas donde cabe
% el cupo. Las reglas entre clases son restricciones: all_distinct/1 sobre
% los momentos de las clases de un mismo año y de un mismo docente, y
% sobre los días de las clases de una misma materia; y el par
% momento-aula, codificado como un solo número, distinto para todas. La
% biblioteca poda los dominios cada vez que el etiquetado fija una
% variable, que es lo que la versión 3 hacía a mano.
%
% solo-local: carga otros archivos, y SWISH no permite cargar otro archivo.
%
%?- oferta(cuatrimestre, O), horario_clpfd(O, [], H), mostrar_anio(O, H, 1).
%?- medir_clpfd(facultad(15), [modelo(simple)], R).

:- module(restricciones,
          [ horario_clpfd/3,
            modelo/4,
            conteo/2,
            grupo/2,
            en_grupo/3,
            momento_de/2,
            medir_clpfd/3
          ]).

:- use_module(library(clpfd)).
:- use_module(library(option)).
:- reexport(oferta).

%!  horario_clpfd(+Oferta, +Opciones:list, -Horario:list) is nondet.
%
%   Horario es un horario válido de Oferta, obtenido del modelo de
%   modelo/4. Opciones elige modelo(simple) o modelo(conteo), que agrega
%   las restricciones redundantes de conteo/2 (por omisión, conteo), y
%   etiquetar(momentos), que fija primero los momentos y después las
%   aulas, o etiquetar(pares), que fija de una vez el par momento-aula de
%   cada clase (por omisión, pares). En los dos casos se elige primero la
%   variable de dominio más chico.
horario_clpfd(Oferta, Opciones, Horario) :-
    option(modelo(Modelo), Opciones, conteo),
    option(etiquetar(Cuales), Opciones, pares),
    modelo(Oferta, Modelo, Horario, vars(Momentos, Aulas, Pares)),
    (   Cuales == pares
    ->  labeling([ff], Pares)
    ;   must_be(oneof([momentos]), Cuales),
        labeling([ff], Momentos),
        labeling([ff], Aulas)
    ).

%!  modelo(+Oferta, +Modelo, -Horario:list, -Variables) is semidet.
%
%   Horario es una lista de asignada(Clase, A, S, F), una por clase de
%   Oferta, cuyos A y S son variables restringidas por las reglas de la
%   oferta; Variables es vars(Momentos, Aulas, Pares): las mismas
%   variables en listas, para etiquetarlas, y el número del par
%   momento-aula de cada clase. Las listas de variables se arman con
%   maplist/3 e include/3, no con findall/3, que copiaría las variables, y
%   las restricciones se imponen con maplist/2, no con forall/2, que las
%   desharía al terminar. Con Modelo conteo se agregan las restricciones
%   de conteo/3. Falla si la propagación ya prueba que no hay horario.
modelo(Oferta, Modelo, Horario, vars(Momentos, Aulas, Pares)) :-
    Oferta = oferta(semana(_, Franjas), _, ListaAulas, _),
    length(ListaAulas, NA),
    findall(C, clase(Oferta, C, _, _, _, _), Clases),
    maplist(variables_de(Oferta), Clases, Horario),
    maplist(momento_de, Horario, Momentos),
    maplist(aula_de, Horario, Aulas),
    maplist(par_momento_aula(NA), Horario, Pares),
    all_distinct(Pares),
    findall(Clave, grupo(Oferta, Clave), Claves),
    maplist(restringir_grupo(Oferta, Horario), Claves),
    findall(M, grupo(Oferta, materia(M)), Materias),
    maplist(restringir_materia(Franjas, Horario), Materias),
    (   Modelo == conteo
    ->  conteo(Oferta, Horario)
    ;   must_be(oneof([simple]), Modelo)
    ).

%!  conteo(+Oferta, +Horario:list) is semidet.
%
%   En ningún momento de Horario hay más clases que aulas, ni más clases
%   de cupo mayor que C que aulas de capacidad mayor que C, para cada
%   capacidad C de las aulas. Son restricciones redundantes: las implica
%   el par momento-aula distinto, pero la biblioteca las propaga mejor,
%   porque cuentan sin elegir el aula. Falla si la propagación ya prueba
%   que no hay horario.
conteo(Oferta, Horario) :-
    Oferta = oferta(_, _, ListaAulas, _),
    findall(Cap, member(aula(_, Cap), ListaAulas), Caps0),
    sort(Caps0, Caps),
    momentos(Oferta, N),
    maplist(contar_mayores(Oferta, Horario, N, Caps), [0|Caps]).

%!  contar_mayores(+Oferta, +Horario:list, +N:integer, +Caps:list,
%!                 +C:integer) is semidet.
%
%   En cada uno de los N momentos, las clases de Horario con cupo mayor
%   que C no son más que las aulas de Caps con capacidad mayor que C.
contar_mayores(Oferta, Horario, N, Caps, C) :-
    include(cupo_mayor(Oferta, C), Horario, Grandes),
    maplist(momento_de, Grandes, Ss),
    include(<(C), Caps, Mayores),
    length(Mayores, Max),
    Ultimo is N - 1,
    findall(S-_, between(0, Ultimo, S), Pares),
    pairs_values(Pares, Cuentas),
    Cuentas ins 0..Max,
    global_cardinality(Ss, Pares).

%!  cupo_mayor(+Oferta, +C:integer, +Asignada) is semidet.
%
%   La clase de Asignada tiene un cupo mayor que C.
cupo_mayor(Oferta, C, asignada(Clase, _, _, _)) :-
    clase(Oferta, Clase, _, _, _, Cupo),
    Cupo > C.

%!  grupo(+Oferta, -Clave) is nondet.
%
%   Clave nombra un grupo de clases de Oferta que no pueden coincidir en
%   el momento: anio(A), las del año A, o docente(D), las del docente D;
%   o, con materia(M), las clases de la materia M.
grupo(Oferta, anio(A)) :-
    setof(A, C^M^D^Cu^clase(Oferta, C, M, A, D, Cu), As),
    member(A, As).
grupo(Oferta, docente(D)) :-
    setof(D, C^M^A^Cu^clase(Oferta, C, M, A, D, Cu), Ds),
    member(D, Ds).
grupo(Oferta, materia(M)) :-
    setof(M, C^A^D^Cu^clase(Oferta, C, M, A, D, Cu), Ms),
    member(M, Ms).

%!  en_grupo(+Oferta, +Clave, +Asignada) is semidet.
%
%   La clase de Asignada pertenece al grupo Clave de Oferta.
en_grupo(Oferta, anio(A), asignada(C, _, _, _)) :-
    clase(Oferta, C, _, A, _, _).
en_grupo(Oferta, docente(D), asignada(C, _, _, _)) :-
    clase(Oferta, C, _, _, D, _).

%!  restringir_grupo(+Oferta, +Horario:list, +Clave) is det.
%
%   Las clases del grupo Clave de Horario ocupan momentos distintos. Para
%   la clave materia(M) no hace nada: esas clases se restringen por día.
restringir_grupo(Oferta, Horario, Clave) :-
    (   Clave = materia(_)
    ->  true
    ;   include(en_grupo(Oferta, Clave), Horario, Del),
        maplist(momento_de, Del, Ss),
        all_distinct(Ss)
    ).

%!  restringir_materia(+Franjas:integer, +Horario:list, +M) is det.
%
%   Las clases de la materia M caen en días distintos, y sus momentos van
%   en el orden de las clases, para no obtener el mismo horario con las
%   clases de M permutadas.
restringir_materia(Franjas, Horario, M) :-
    include(de_materia(M), Horario, Del),
    maplist(momento_de, Del, Ss),
    maplist(dia_de(Franjas), Ss, Dias),
    all_distinct(Dias),
    chain(Ss, #<).

%!  de_materia(+M, +Asignada) is semidet.
%
%   Asignada es de una clase de la materia M.
de_materia(M, asignada(M-_, _, _, _)).

%!  momento_de(+Asignada, -S) is det.
%
%   S es el momento de Asignada.
momento_de(asignada(_, _, S, _), S).

%!  aula_de(+Asignada, -A) is det.
%
%   A es el aula de Asignada.
aula_de(asignada(_, A, _, _), A).

%!  variables_de(+Oferta, +Clase, -Asignada) is det.
%
%   Asignada es asignada(Clase, A, S, F) con los dominios de las reglas
%   de una sola clase: S en los días del docente, A en las aulas donde
%   cabe el cupo, y F = S + 1.
variables_de(Oferta, C, asignada(C, A, S, F)) :-
    Oferta = oferta(semana(_, Franjas), _, _, _),
    clase(Oferta, C, _, _, Docente, Cupo),
    momentos(Oferta, N),
    Ultimo is N - 1,
    S in 0..Ultimo,
    findall(D, disponible(Oferta, Docente, D), Dias),
    dominio(Dias, DomDias),
    Dia #= S // Franjas + 1,
    Dia in DomDias,
    findall(Num, ( aula(Oferta, Num, _, Cap), Cupo =< Cap ), Nums),
    dominio(Nums, DomAulas),
    A in DomAulas,
    F #= S + 1.

%!  dominio(+Enteros:list, -Dominio) is semidet.
%
%   Dominio es el dominio de clpfd que contiene exactamente los Enteros.
%   Falla con la lista vacía, porque no hay dominio vacío.
dominio([E|Es], Dominio) :-
    foldl(union_dominio, Es, E, Dominio).

%!  union_dominio(+E:integer, +Dom0, -Dom) is det.
%
%   Dom es Dom0 con el entero E agregado.
union_dominio(E, Dom0, Dom0 \/ E).

%!  par_momento_aula(+NA:integer, +Asignada, -Par) is det.
%
%   Par es un solo número para el momento y el aula de Asignada: dos
%   clases con el mismo número están en la misma aula al mismo tiempo.
par_momento_aula(NA, asignada(_, A, S, _), Par) :-
    Par #= S * NA + A.

%!  dia_de(+Franjas:integer, +S, -Dia) is det.
%
%   Dia es la variable del día del momento S, con Franjas por día.
dia_de(Franjas, S, Dia) :-
    Dia #= S // Franjas.

%!  medir_clpfd(+Nombre, +Opciones:list, -Resultado) is det.
%
%   Resultado es r(Hay, I): Hay es si o no según que horario_clpfd/3, con
%   Opciones, encuentre un horario de la oferta de ejemplo Nombre, e I las
%   inferencias que costó saberlo.
medir_clpfd(Nombre, Opciones, r(Hay, I)) :-
    oferta(Nombre, Oferta),
    statistics(inferences, I0),
    (   once(horario_clpfd(Oferta, Opciones, _))
    ->  Hay = si
    ;   Hay = no
    ),
    statistics(inferences, I1),
    I is I1 - I0.
