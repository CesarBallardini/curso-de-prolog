:- encoding(utf8).

% Capítulo 68 - Solución del ejercicio 14: el lazo interactivo de la
% eliminación de candidatos.
%
% El lazo lee ejemplos de la entrada actual con read_term/2, uno por
% término, y después de cada uno escribe los dos bordes y el estado del
% espacio de versiones. Termina con el término fin o con el final de la
% entrada. Un término que no es pos(I) o neg(I) con I una instancia del
% lenguaje, o que no se puede leer, se informa y se ignora: el lazo no se
% interrumpe. Todo el aprendizaje lo hacen inicial/1, actualizar/3 y
% estado/2 de la versión 3; el lazo solo lee y escribe.
%
% solo-local: carga candidatos.pl, que carga un archivo de otro capítulo.
%
%?- con_entrada("pos(pieza(esfera, rojo, chico, madera)). fin.", aprender_interactivo(EV)).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(candidatos).

%!  aprender_interactivo(-EV) is det.
%
%   Lee ejemplos de la entrada actual hasta el término fin o el final de
%   la entrada, y escribe los bordes y el estado después de cada uno. EV
%   es el espacio de versiones de los ejemplos bien formados. Mientras
%   lee, el indicador de la terminal es «ejemplo: ».
aprender_interactivo(EV) :-
    inicial(EV0),
    setup_call_cleanup(prompt(Anterior, 'ejemplo: '),
                       lazo(EV0, EV),
                       prompt(_, Anterior)).

%!  lazo(+EV0, -EV) is det.
%
%   EV es el espacio EV0 después de los ejemplos que quedan en la entrada
%   actual, hasta fin o el final de la entrada.
lazo(EV0, EV) :-
    leer(Lectura),
    (   Lectura = termino(T),
        ( T == end_of_file ; T == fin )
    ->  EV = EV0
    ;   paso(Lectura, EV0, EV1),
        lazo(EV1, EV)
    ).

%!  leer(-Lectura) is det.
%
%   Lectura es termino(T), con T el próximo término de la entrada actual,
%   o sintaxis(M), si el texto hasta el próximo punto final no es un
%   término; M describe el error.
leer(Lectura) :-
    catch(( read_term(T, []),
            Lectura = termino(T) ),
          error(syntax_error(M), _),
          Lectura = sintaxis(M)).

%!  paso(+Lectura, +EV0, -EV) is det.
%
%   EV es EV0 actualizado con el ejemplo leído, si está bien formado, y
%   EV0 en otro caso. Escribe el ejemplo con los bordes y el estado, o el
%   motivo por el que se ignora.
paso(Lectura, EV0, EV) :-
    (   Lectura = termino(T),
        ejemplo_valido(T)
    ->  actualizar(T, EV0, EV),
        mostrar_conceptos([T]),
        informar(EV)
    ;   Lectura = sintaxis(M)
    ->  EV = EV0,
        format("error de sintaxis (~w): se ignora~n", [M])
    ;   Lectura = termino(T),
        EV = EV0,
        format("ejemplo mal formado: "),
        mostrar_conceptos([T])
    ).

%!  ejemplo_valido(@T) is semidet.
%
%   T es pos(I) o neg(I), con I una instancia del lenguaje: una pieza sin
%   variables con un valor admitido en cada atributo.
ejemplo_valido(T) :-
    nonvar(T),
    T =.. [Clase, I],
    memberchk(Clase, [pos, neg]),
    ground(I),
    once(instancia(I)).

%!  informar(+EV) is det.
%
%   Escribe los bordes S y G de EV, un concepto por línea, y su estado.
informar(ev(S, G)) :-
    format("  S:~n"),
    maplist(sangrado, S),
    format("  G:~n"),
    maplist(sangrado, G),
    estado(ev(S, G), E),
    (   E = convergio(C)
    ->  format("  converge en "),
        mostrar_conceptos([C])
    ;   format("  ~w~n", [E])
    ).

%!  sangrado(+C) is det.
%
%   Escribe el concepto C con cuatro espacios delante.
sangrado(C) :-
    format("    "),
    mostrar_conceptos([C]).

%!  con_entrada(+Texto:string, :Meta) is semidet.
%
%   Prueba Meta una vez con Texto como entrada actual, en lugar de la
%   terminal. La entrada anterior se restituye aunque Meta falle o lance
%   una excepción.
con_entrada(Texto, Meta) :-
    current_input(Anterior),
    setup_call_cleanup(( open_string(Texto, Flujo),
                         set_input(Flujo) ),
                       once(Meta),
                       ( set_input(Anterior),
                         close(Flujo) )).
