:- encoding(utf8).

% Capítulo 53 - Solución del ejercicio 12: verbos que el léxico no tiene.
%
% Sin el léxico, las reglas de la versión 4 proponen formas subyacentes;
% entre ellas, adivinar/2 se queda con las que son una raíz sin límites,
% un límite y una terminación regular, y escribe el infinitivo que esa
% raíz tendría con las mismas reglas.
%
% solo-local: carga módulos.
%
%?- adivinar("bloguearon", A).
%?- adivinar("tuiteé", A).

:- use_module(lexico).
:- ensure_loaded(paralelo).

%!  adivinar(+Palabra:string, -Analisis) is nondet.
%
%   Analisis es verbo(Lema, Tiempo, Persona, Numero) para un verbo
%   regular, que puede no estar en el léxico, del que Palabra sería una
%   forma. Da cada análisis una vez.
adivinar(Palabra, verbo(Lema, Tiempo, Persona, Numero)) :-
    reglas(Rs),
    string_chars(Palabra, Letras),
    findall(Lema0-Tiempo0-Persona0-Numero0,
            ( transducir(inversa(paralelo(Rs)), Letras, Subyacente),
              append(Raiz, [+|Letras1], Subyacente),
              Raiz \== [],
              \+ memberchk(+, Raiz),
              string_chars(T, Letras1),
              terminacion(Conj, Tiempo0, Persona0, Numero0, T),
              infinitivo(Conj, Inf),
              string_chars(Inf, LetrasInf),
              append(Raiz, LetrasInf, SubInf),
              transducir(paralelo(Rs), SubInf, LetrasLema),
              string_chars(Lema0, LetrasLema) ),
            Analisis0),
    sort(Analisis0, Analisis),
    member(Lema-Tiempo-Persona-Numero, Analisis).
