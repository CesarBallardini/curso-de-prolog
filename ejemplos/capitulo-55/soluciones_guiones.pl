:- encoding(utf8).

% Capítulo 55 - Soluciones de los ejercicios 10 y 11: un guion para una
% consulta médica, y una gramática que lee la historia en castellano.
%
% El guion nuevo se agrega con cláusulas de los predicados que guiones.pl
% declara multifile. La gramática trabaja sobre las palabras de palabras/2,
% del capítulo 44: sin mayúsculas ni tildes.
%
% solo-local: carga archivos de este capítulo y del 44, y SWISH no permite
% cargar otro archivo.
%
%?- comprender("Juan fue a Leones, comió una hamburguesa y se fue.", R).

:- ensure_loaded(guiones).
:- use_module('../capitulo-44/lenguaje', [palabras/2]).

% Ejercicio 10.

guion(consulta,
      [ ir(Paciente, Antes, Clinica),
        esperar(Paciente, Sala),
        atender(Medica, Paciente),
        recetar(Medica, Remedio, Paciente),
        ir(Paciente, Clinica, Despues)
      ],
      [ Paciente-paciente, Antes-casa, Clinica-clinica, Sala-sala,
        Medica-medica, Remedio-remedio, Despues-otro_lugar ]).

activa(clinica, consulta).
activa(medica, consulta).

historia(clinica, [ ir(luis, _, clinica), recetar(_, jarabe, _) ]).

sustantivo(paciente, m, "paciente", no).
sustantivo(clinica, f, "clínica", no).
sustantivo(sala, f, "sala de espera", no).
sustantivo(medica, f, "médica", no).
sustantivo(remedio, m, "remedio", no).
sustantivo(jarabe, m, "jarabe", no).

oracion(esperar(Q, S)) -->
    sujeto(Q), " esperó en ", el(S), ".".
oracion(atender(M, Q)) -->
    sujeto(M), " atendió ", al(Q), ".".
oracion(recetar(M, R, Q)) -->
    sujeto(M), " le recetó ", un(R), " ", al(Q), ".".

% Ejercicio 11.

%!  relato(-Sucesos:list)// is semidet.
%
%   Una historia en castellano: oraciones unidas por y o por comas, la
%   primera con sujeto. Una oración sin sujeto tiene el de la anterior.
relato([S|Ss]) -->
    [Sujeto],
    { \+ no_es_sujeto(Sujeto) },
    predicado(Sujeto, S),
    mas_sucesos(Sujeto, Ss).

%!  mas_sucesos(+Sujeto, -Sucesos:list)// is nondet.
%
%   Las oraciones que siguen, con Sujeto como sujeto si no nombran otro.
mas_sucesos(Sujeto0, [S|Ss]) -->
    (   [y]
    ->  []
    ;   []
    ),
    sujeto(Sujeto0, Sujeto),
    predicado(Sujeto, S),
    mas_sucesos(Sujeto, Ss).
mas_sucesos(_, []) -->
    [].

%!  sujeto(+Sujeto0, -Sujeto)// is nondet.
%
%   Un nombre como sujeto, o ninguno: entonces Sujeto es Sujeto0.
sujeto(_, Sujeto) -->
    [Sujeto],
    { \+ no_es_sujeto(Sujeto) }.
sujeto(Sujeto, Sujeto) -->
    [].

% no_es_sujeto(P): la palabra P no puede ser el sujeto de una oración.
no_es_sujeto(P) :-
    memberchk(P, [y, se, fue, comio, subio, bajo, pidio, a, al, en, una,
                  un]).

%!  predicado(+Sujeto, -Suceso)// is nondet.
%
%   Un predicado y el suceso que describe, con variables donde el texto no
%   dice nada.
predicado(S, ir(S, _, L)) -->
    [fue, a, L].
predicado(S, ir(S, _, _)) -->
    [se, fue].
predicado(S, comer(S, C)) -->
    [comio],
    articulo_indefinido,
    [C].
predicado(S, pedir(S, C, _)) -->
    [pidio],
    articulo_indefinido,
    [C].
predicado(S, subir(S, C, _)) -->
    [subio, al, C].
predicado(S, bajar(S, _, L)) -->
    [bajo, en, L].

%!  articulo_indefinido// is nondet.
%
%   Un artículo indefinido, o ninguno.
articulo_indefinido -->
    [un].
articulo_indefinido -->
    [una].
articulo_indefinido -->
    [].

%!  comprender(+Texto:string, -Relato:string) is semidet.
%
%   Relato cuenta la historia de Texto completada con el primer guion que
%   la explica. Falla si Texto no es una historia o ningún guion la
%   explica.
comprender(Texto, Relato) :-
    palabras(Texto, Palabras),
    once(phrase(relato(Historia), Palabras)),
    once(entender(Historia, _, Entendida)),
    contar(Entendida, Relato).
