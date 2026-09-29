:- encoding(utf8).

% Capítulo 69 - Versión 2: el entrenamiento por épocas.
%
% Una época recorre todos los ejemplos una vez, con foldl/4, corrigiendo
% los pesos y contando los errores. Una época sin errores prueba que los
% pesos clasifican bien todos los ejemplos, porque ninguno los cambió. El
% ciclo que repite las épocas es iterar/5 del capítulo 46: el paso es una
% época, y el cambio, la cantidad de errores. Los errores de cada época
% forman la curva de aprendizaje.
%
% solo-local: carga los programas de los capítulos 32 y 46, y SWISH no
% carga otros archivos.
%
%?- curva(y, 1, [0, 0, 0], Pesos, Curva).
%?- curva(o_exclusivo, 1, [0, 0, 0], Pesos, Curva).

:- use_module(library(pairs)).
:- ensure_loaded(perceptron).
:- ensure_loaded('../capitulo-46/iteracion').

% maximo_de_epocas(N): el entrenamiento se abandona después de N épocas.
maximo_de_epocas(1000).

%!  epoca(+Tasa:number, +Ejemplos:list, +Pesos0:list, -Pesos:list,
%!        -Errores:integer) is det.
%
%   Pesos son los Pesos0 corregidos con cada uno de los Ejemplos, en
%   orden, y Errores es la cantidad de ejemplos mal clasificados en el
%   momento de usarlos.
epoca(Tasa, Ejemplos, Pesos0, Pesos, Errores) :-
    foldl(aprender(Tasa), Ejemplos, Pesos0-0, Pesos-Errores).

%!  aprender(+Tasa:number, +Ejemplo, +Acumulado0, -Acumulado) is det.
%
%   Acumulado0 es Pesos0-Errores0. Si Pesos0 clasifica bien el Ejemplo,
%   Acumulado es Acumulado0; si no, los pesos se corrigen y los errores
%   aumentan en uno.
aprender(Tasa, Ejemplo, Pesos0-Errores0, Pesos-Errores) :-
    (   bien_clasificado(Pesos0, Ejemplo)
    ->  Pesos = Pesos0,
        Errores = Errores0
    ;   corregir(Tasa, Ejemplo, Pesos0, Pesos),
        Errores is Errores0 + 1
    ).

%!  paso_epoca(+Tasa, +Ejemplos, +Pesos0, -Pesos, -Resultado,
%!             -Errores:integer) is det.
%
%   El paso de una época para iterar/5: Resultado es Errores-Pesos, y el
%   cambio que mide el ciclo son los Errores.
paso_epoca(Tasa, Ejemplos, Pesos0, Pesos, Errores-Pesos, Errores) :-
    epoca(Tasa, Ejemplos, Pesos0, Pesos, Errores).

%!  entrenar(+Tasa:number, +Ejemplos:list, +Pesos0:list, -Pesos:list,
%!           -Curva:list(integer)) is semidet.
%
%   Pesos clasifican bien todos los Ejemplos y Curva es la cantidad de
%   errores de cada época, desde Pesos0; su último elemento es 0. Falla si
%   no hay una época sin errores en maximo_de_epocas/1 épocas.
entrenar(Tasa, Ejemplos, Pesos0, Pesos, Curva) :-
    maximo_de_epocas(Maximo),
    iterar(paso_epoca(Tasa, Ejemplos), 0, Maximo, Pesos0, Resultados),
    pairs_keys_values(Resultados, Curva, Sucesion),
    last(Sucesion, Pesos).

%!  curva(+Nombre:atom, +Tasa:number, +Pesos0:list, -Pesos:list,
%!        -Curva:list(integer)) is semidet.
%
%   Como entrenar/5, con los ejemplos del conjunto Nombre de datos/2.
curva(Nombre, Tasa, Pesos0, Pesos, Curva) :-
    datos(Nombre, Ejemplos),
    entrenar(Tasa, Ejemplos, Pesos0, Pesos, Curva).

%!  costos(+Nombre:atom, +Tasa:number, +Pesos0:list, -Uno:integer,
%!         -Epocas:integer) is semidet.
%
%   Uno y Epocas son las inferencias que usan entrenar_uno/5 y entrenar/5
%   con los ejemplos del conjunto Nombre de datos/2.
costos(Nombre, Tasa, Pesos0, Uno, Epocas) :-
    datos(Nombre, Ejemplos),
    inferencias(entrenar_uno(Tasa, Ejemplos, Pesos0, _, _), Uno),
    inferencias(entrenar(Tasa, Ejemplos, Pesos0, _, _), Epocas).
