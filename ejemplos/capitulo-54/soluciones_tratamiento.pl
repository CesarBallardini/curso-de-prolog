:- encoding(utf8).

% Capítulo 54 - Solución del ejercicio 14.
%
% Carga la versión 7 y agrega la lectura de usted del sujeto omitido en
% tercera persona del singular.
%
% solo-local: carga traductor.pl con ensure_loaded/1.
%
%?- traducciones("Come manzanas.", Ts).
%?- findall(Es, traducir_con_trato_ingles(tu, Es, "He eats apples."), L).

:- multifile sujeto/2.

:- ensure_loaded(tratamiento).

% «Come manzanas» también puede dirigirse a usted.
sujeto(tacito(sg), pron(you)).

%!  traducir_con_trato_ingles(+Trato, -Es:string, +En:string) is nondet.
%
%   Como traducir_con_trato/3, pero el trato solo se exige cuando el
%   sujeto inglés es you: el sujeto omitido en tercera persona traduce
%   también he, she e it, que no se dirigen a nadie.
traducir_con_trato_ingles(Trato, Es, En) :-
    palabras(En, PalabrasEn),
    phrase(oracion_en(ArbolEn), PalabrasEn),
    transferir(ArbolEs, ArbolEn),
    arg(1, ArbolEs, SujetoEs),
    arg(1, ArbolEn, SujetoEn),
    trato_ingles(SujetoEs, SujetoEn, Trato),
    phrase(oracion_es(ArbolEs), PalabrasEs),
    texto(PalabrasEs, Es).

%!  trato_ingles(+SujetoEs, +SujetoEn, ?Trato) is semidet.
%
%   Con you, el sujeto castellano omitido en singular es usted; con
%   cualquier otro sujeto inglés, el trato no importa.
trato_ingles(SujetoEs, SujetoEn, Trato) :-
    (   SujetoEn == pron(you)
    ->  (   SujetoEs == tacito(sg)
        ->  Trato = usted
        ;   trato(SujetoEs, Trato)
        )
    ;   true
    ).
