:- encoding(utf8).

% Capítulo 25 - Errores: los términos de error ISO, catch/3, throw/1 y
% must_be/2.
%
% edad_de/2 distingue fallar de producir un error: una persona sin edad
% registrada es un error de existencia, no un «no». meses/2 valida su
% argumento con must_be/2. leer_edad/2 convierte un texto en una edad y
% transforma los errores de la conversión en uno solo, propio del dominio.
%
%?- catch(edad_de(zoe, E), Error, true).
%?- leer_edad("41", E).

:- use_module(library(error)).

% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(eva, 8).

%!  edad_de(+P, -E:integer) is det.
%
%   E es la edad de P. Produce existence_error(persona, P) si P no tiene
%   edad registrada, y un error de instanciación si P no está ligado.
edad_de(P, E) :-
    must_be(atom, P),
    (   edad(P, E0)
    ->  E = E0
    ;   existence_error(persona, P)
    ).

%!  meses(+Anios:integer, -Meses:integer) is det.
%
%   Meses es la cantidad de meses de Anios años. Anios debe ser un entero no
%   negativo.
meses(Anios, Meses) :-
    must_be(nonneg, Anios),
    Meses is Anios * 12.

%!  leer_edad(+Texto:string, -E:integer) is det.
%
%   E es la edad escrita en Texto. Produce domain_error(edad, Texto) si el
%   texto no es un entero entre 0 y 150.
leer_edad(Texto, E) :-
    string_codes(Texto, Codigos),
    catch(number_codes(N, Codigos), error(syntax_error(_), _),
          N = no_es_un_numero),
    (   integer(N),
        between(0, 150, N)
    ->  E = N
    ;   domain_error(edad, Texto)
    ).

%!  con_valor_por_omision(:Objetivo, +PorOmision, -Valor) is semidet.
%
%   Valor es la primera respuesta de call(Objetivo, Valor), o PorOmision si
%   Objetivo produce un error de existencia. Los demás errores se propagan.
%   Falla si Objetivo no tiene respuestas.
con_valor_por_omision(Objetivo, PorOmision, Valor) :-
    catch(once(call(Objetivo, Valor)),
          error(existence_error(_, _), _),
          Valor = PorOmision).

%!  edad_o_cero(+P, -E:integer) is det.
%
%   E es la edad de P, o 0 si P no tiene edad registrada. Cualquier otro
%   error se relanza.
edad_o_cero(P, E) :-
    catch(edad_de(P, E),
          error(Formal, Contexto),
          (   Formal = existence_error(persona, _)
          ->  E = 0
          ;   throw(error(Formal, Contexto))
          )).
