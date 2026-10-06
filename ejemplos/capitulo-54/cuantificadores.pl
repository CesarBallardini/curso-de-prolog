:- encoding(utf8).

% Capítulo 54 - Versión 6: una interlingua con cuantificadores.
%
% Como el traductor inglés-latín de Covington (1994, §8.2), dos gramáticas
% relacionan una oración con una fórmula lógica, y la fórmula es la
% interlingua: traducir es analizar con una gramática y generar con la
% otra. Las fórmulas tienen dos cuantificadores,
%
%   todo(X, Restriccion, Alcance)     alguno(X, Restriccion, Alcance)
%
% y los predicados se nombran con los lemas castellanos: alumno(X),
% leer(X, Y). Cada sintagma nominal aporta su cuantificador, con la
% técnica de Covington: el determinante recibe la restricción del nombre
% y el alcance que le da el resto de la oración. La gramática compone los
% cuantificadores en el orden de las palabras, y alcance/2 agrega la
% lectura con el orden inverso: «todo alumno lee un libro» tiene dos.
%
% solo-local: es independiente del traductor, pero la página lo trata
% junto con él.
%
%?- findall(F, phrase(oracion_logica_es(F), ["todo", "alumno", "lee", "un", "libro"]), Fs).
%?- traducciones_logicas(["todo", "alumno", "lee", "un", "libro"], Ts).

%!  oracion_logica_es(?F)// is nondet.
%
%   Una oración castellana cuya fórmula es F, en cualquiera de sus
%   lecturas. La condición va después de la oración, que la liga.
oracion_logica_es(F) -->
    oracion_es_q(S),
    { alcance(S, F0),
      misma_formula(F0, F) }.

%!  oracion_logica_en(?F)// is nondet.
%
%   Una oración inglesa cuya fórmula es F, en cualquiera de sus lecturas.
oracion_logica_en(F) -->
    oracion_en_q(S),
    { alcance(S, F0),
      misma_formula(F0, F) }.

%!  misma_formula(+F0, ?F) is semidet.
%
%   F es la fórmula F0, con sus variables. Si F llega ligada, tiene que
%   ser una variante de F0: unificarlas sin más podría unir dos variables
%   cuantificadas distintas, y «un libro lee todo alumno» pasaría por una
%   lectura de «todo alumno lee un libro».
misma_formula(F0, F) :-
    (   var(F)
    ->  F = F0
    ;   F0 =@= F,
        F = F0
    ).

%!  alcance(+S, ?F) is nondet.
%
%   F es una lectura de la fórmula S: S misma, o, si S tiene dos
%   cuantificadores anidados, la que los pone en el orden inverso.
alcance(S, S).
alcance(S, F) :-
    S =.. [Q1, X, R1, B1],
    cuantificador(Q1),
    B1 =.. [Q2, Y, R2, P],
    cuantificador(Q2),
    B2 =.. [Q1, X, R1, P],
    F =.. [Q2, Y, R2, B2].

% cuantificador(Q): Q es el nombre de un cuantificador.
cuantificador(todo).
cuantificador(alguno).

% La gramática castellana, en el orden de las palabras.

%!  oracion_es_q(?F)// is nondet.
%
%   Una oración castellana con la fórmula F de su orden de palabras.
oracion_es_q(F) -->
    sn_es_q((X^Alcance)^F),
    sv_es_q(X^Alcance).

%!  sn_es_q(?Sem)// is nondet.
%
%   Un sintagma nominal: el determinante concuerda con el nombre en género.
sn_es_q(Sem) -->
    det_es((X^Restriccion)^Sem, G),
    nom_es(X^Restriccion, G).

%!  sv_es_q(?Sem)// is nondet.
%
%   Un sintagma verbal: un verbo intransitivo, o uno transitivo con su
%   objeto, que cuantifica sobre la segunda variable del verbo.
sv_es_q(X^Alcance) -->
    verbo_es_q(X^Alcance).
sv_es_q(X^Pred) -->
    verbo_es_q(Y^X^Alcance),
    sn_es_q((Y^Alcance)^Pred).

% det_es(Sem, G): las formas de los determinantes.
det_es((X^R)^(X^A)^todo(X, R, A), m) --> ["todo"].
det_es((X^R)^(X^A)^todo(X, R, A), f) --> ["toda"].
det_es((X^R)^(X^A)^alguno(X, R, A), m) --> ["un"].
det_es((X^R)^(X^A)^alguno(X, R, A), f) --> ["una"].

% nom_es(Sem, G): los nombres y su género.
nom_es(X^alumno(X), m) --> ["alumno"].
nom_es(X^libro(X), m) --> ["libro"].
nom_es(X^gato(X), m) --> ["gato"].
nom_es(X^casa(X), f) --> ["casa"].

% verbo_es_q(Sem): los verbos en tercera persona del singular.
verbo_es_q(X^dormir(X)) --> ["duerme"].
verbo_es_q(Y^X^leer(X, Y)) --> ["lee"].
verbo_es_q(Y^X^ver(X, Y)) --> ["ve"].
verbo_es_q(Y^X^tener(X, Y)) --> ["tiene"].

% La gramática inglesa, con los mismos predicados.

%!  oracion_en_q(?F)// is nondet.
%
%   Una oración inglesa con la fórmula F de su orden de palabras.
oracion_en_q(F) -->
    sn_en_q((X^Alcance)^F),
    sv_en_q(X^Alcance).

%!  sn_en_q(?Sem)// is nondet.
%
%   Un sintagma nominal: un determinante y un nombre.
sn_en_q(Sem) -->
    det_en((X^Restriccion)^Sem),
    nom_en(X^Restriccion).

%!  sv_en_q(?Sem)// is nondet.
%
%   Un sintagma verbal, como sv_es_q//1.
sv_en_q(X^Alcance) -->
    verbo_en_q(X^Alcance).
sv_en_q(X^Pred) -->
    verbo_en_q(Y^X^Alcance),
    sn_en_q((Y^Alcance)^Pred).

% det_en(Sem): every y a. Los nombres empiezan con consonante.
det_en((X^R)^(X^A)^todo(X, R, A)) --> ["every"].
det_en((X^R)^(X^A)^alguno(X, R, A)) --> ["a"].

% nom_en(Sem): los nombres ingleses.
nom_en(X^alumno(X)) --> ["student"].
nom_en(X^libro(X)) --> ["book"].
nom_en(X^gato(X)) --> ["cat"].
nom_en(X^casa(X)) --> ["house"].

% verbo_en_q(Sem): los verbos con un sujeto singular.
verbo_en_q(X^dormir(X)) --> ["sleeps"].
verbo_en_q(Y^X^leer(X, Y)) --> ["reads"].
verbo_en_q(Y^X^ver(X, Y)) --> ["sees"].
verbo_en_q(Y^X^tener(X, Y)) --> ["has"].

%!  es_en_logica(+Es:list(string), ?En:list(string)) is nondet.
%
%   En traduce Es por la interlingua: una fórmula de Es, en alguna de sus
%   lecturas, generada en inglés.
es_en_logica(Es, En) :-
    phrase(oracion_logica_es(F), Es),
    phrase(oracion_logica_en(F), En).

%!  en_es_logica(+En:list(string), ?Es:list(string)) is nondet.
%
%   Es traduce En por la interlingua.
en_es_logica(En, Es) :-
    phrase(oracion_logica_en(F), En),
    phrase(oracion_logica_es(F), Es).

%!  traducciones_logicas(+Palabras:list(string), -Ts:list) is det.
%
%   Ts son las traducciones distintas de Palabras, una oración castellana
%   o inglesa, por la interlingua.
traducciones_logicas(Palabras, Ts) :-
    findall(T, ( es_en_logica(Palabras, T)
               ; en_es_logica(Palabras, T) ),
            Ts0),
    list_to_set(Ts0, Ts).

% Un modelo: los hechos de una situación.
hecho(alumno(ana)).
hecho(alumno(beto)).
hecho(libro(quijote)).
hecho(libro(rayuela)).
hecho(leer(ana, quijote)).
hecho(leer(beto, rayuela)).

%!  verdadera(+F) is semidet.
%
%   La fórmula F es verdadera en el modelo.
verdadera(todo(_, R, A)) :-
    !,
    \+ ( verdadera(R),
         \+ verdadera(A) ).
verdadera(alguno(_, R, A)) :-
    !,
    verdadera(R),
    verdadera(A).
verdadera(F) :-
    hecho(F).

%!  valor(+F, -V) is det.
%
%   V es verdadera o falsa según la fórmula F en el modelo. F no queda
%   ligada.
valor(F, V) :-
    (   \+ \+ verdadera(F)
    ->  V = verdadera
    ;   V = falsa
    ).

%!  lecturas(+Es:list(string), -Ls:list) is det.
%
%   Ls son las lecturas de la oración castellana Es, cada una como
%   Formula-Valor en el modelo.
lecturas(Es, Ls) :-
    findall(F-V, ( phrase(oracion_logica_es(F), Es),
                   valor(F, V) ),
            Ls).
