:- encoding(utf8).

% Capítulo 35 - Las reglas compiladas: el sistema experto del capítulo 33,
% con cada regla convertida en una cláusula de Prolog al cargarla.
%
% demostrar/4 es el intérprete del capítulo 33, con las observaciones en
% una lista. term_expansion/2 evalúa parcialmente la cláusula de
% demostrar/4 que usa una regla, con parcial/3 de parcial.pl, sobre cada
% término regla/2 que se carga: la regla queda como dato, para el
% intérprete, y además como una cláusula de concluir/4, que prueba lo mismo
% sin buscar la regla ni recorrer sus condiciones. identificar/2 usa el
% intérprete; identificar_compilado/2, las cláusulas compiladas.
%
% solo-local: carga parcial.pl con ensure_loaded/1, y SWISH no permite
% cargar otro archivo.
%
%?- caso(3, Obs), identificar_compilado(Obs, Animal).
%?- listing(concluir/4).
%?- caso(2, Obs), concluir(cebra, lista(Obs), [], Arbol).

:- ensure_loaded(parcial).

:- op(800, xfx, entonces).
:- op(790, fx, si).
:- op(780, xfy, y).

%!  demostrar(+Meta, +Fuente, +Pila:list, -Arbol) is nondet.
%
%   Meta se prueba con las reglas y las observaciones de Fuente, lista(Os).
%   Pila son los pares Regla-Conclusion en curso, la más reciente primero.
%   Arbol es la prueba.
demostrar(A y B, Fuente, Pila, ArbolA y ArbolB) :-
    demostrar(A, Fuente, Pila, ArbolA),
    demostrar(B, Fuente, Pila, ArbolB).
demostrar(X > Y, _, _, X > Y) :-
    X > Y.
demostrar(X < Y, _, _, X < Y) :-
    X < Y.
demostrar(Meta, Fuente, Pila, observado(Meta)) :-
    observable(Meta),
    observar(Fuente, Meta, Pila).
demostrar(Meta, Fuente, Pila, deducido(Meta, Regla, Arbol)) :-
    regla(Regla, si Condiciones entonces Meta),
    demostrar(Condiciones, Fuente, [Regla-Meta|Pila], Arbol).

%!  observar(+Fuente, ?Meta, +Pila:list) is nondet.
%
%   Meta se observa según Fuente: está en la lista.
observar(lista(Observaciones), Meta, _) :-
    member(Meta, Observaciones).

% observable(M): M se observa; ninguna regla lo concluye.
observable(tiene_pelo).
observable(da_leche).
observable(tiene_plumas).
observable(vuela).
observable(pone_huevos).
observable(come_carne).
observable(tiene_cascos).
observable(color_leonado).
observable(manchas_oscuras).
observable(rayas_negras).
observable(cuello_largo).
observable(no_vuela).
observable(nada).
observable(peso(_)).

%!  control(+Meta, -Accion) is semidet.
%
%   Al compilar una regla, demostrar/4 se despliega sobre una conjunción,
%   una comparación o una observación, y queda como llamada a concluir/4
%   sobre una conclusión de otra regla. observable/1 y regla/2 se
%   despliegan: cuando no tienen cláusulas para la condición, la rama del
%   intérprete que las llama desaparece. Por eso observable/1 se define
%   antes que las reglas.
control(demostrar(C, Fuente, Pila, Arbol), Accion) :-
    (   simple(C),
        \+ observable(C)
    ->  Accion = dejar(concluir(C, Fuente, Pila, Arbol))
    ;   Accion = desplegar
    ).
control(observable(_), desplegar).
control(regla(_, _), desplegar).

%!  simple(+Condicion) is semidet.
%
%   Condicion no es una conjunción ni una comparación.
simple(Condicion) :-
    Condicion \= (_ y _),
    Condicion \= (_ > _),
    Condicion \= (_ < _).

%!  term_expansion(+Termino, -Clausulas:list) is semidet.
%
%   Una regla regla(R, si Condiciones entonces Meta) se carga como dato y
%   como una cláusula de concluir/4: la de demostrar/4 que usa la regla,
%   evaluada parcialmente sobre sus condiciones.
term_expansion(regla(R, si Condiciones entonces Meta),
               [ regla(R, si Condiciones entonces Meta),
                 (concluir(Meta, Fuente, Pila, deducido(Meta, R, Arbol)) :-
                      Cuerpo) ]) :-
    parcial(demostrar(Condiciones, Fuente, [R-Meta|Pila], Arbol),
            control, Cuerpo).

:- discontiguous regla/2, concluir/4.

%!  concluir(?Meta, +Fuente, +Pila:list, -Arbol) is nondet.
%
%   La misma relación que demostrar/4 para una condición simple. Esta
%   cláusula es la de las observaciones; cada regla agrega una más.
concluir(Meta, Fuente, Pila, observado(Meta)) :-
    observable(Meta),
    observar(Fuente, Meta, Pila).

% regla(Nombre, si Condiciones entonces Conclusion): las Condiciones, unidas
% con y, permiten concluir Conclusion.
regla(r1,  si tiene_pelo entonces mamifero).
regla(r2,  si da_leche entonces mamifero).
regla(r3,  si tiene_plumas entonces ave).
regla(r4,  si vuela y pone_huevos entonces ave).
regla(r5,  si mamifero y come_carne entonces carnivoro).
regla(r6,  si mamifero y tiene_cascos entonces ungulado).
regla(r7,  si carnivoro y color_leonado y manchas_oscuras entonces guepardo).
regla(r8,  si carnivoro y color_leonado y rayas_negras entonces tigre).
regla(r9,  si ungulado y cuello_largo y manchas_oscuras entonces jirafa).
regla(r10, si ungulado y rayas_negras entonces cebra).
regla(r11, si ave y no_vuela y nada entonces pinguino).
regla(r12, si ave y no_vuela y peso(P) y P > 50 entonces avestruz).

% hipotesis(H): H es una de las conclusiones finales que el sistema busca.
hipotesis(guepardo).
hipotesis(tigre).
hipotesis(jirafa).
hipotesis(cebra).
hipotesis(pinguino).
hipotesis(avestruz).

% caso(N, Observaciones): las observaciones de un animal de ejemplo.
caso(1, [tiene_pelo, come_carne, color_leonado, manchas_oscuras]).
caso(2, [da_leche, tiene_cascos, rayas_negras]).
caso(3, [tiene_plumas, no_vuela, peso(90)]).
caso(4, [tiene_plumas, no_vuela, nada, peso(30)]).
caso(5, [tiene_pelo, tiene_cascos]).

%!  identificar(+Observaciones:list, -Animal) is nondet.
%
%   Animal es una de las hipótesis que se prueban a partir de
%   Observaciones, con el intérprete.
identificar(Observaciones, Animal) :-
    hipotesis(Animal),
    once(demostrar(Animal, lista(Observaciones), [], _)).

%!  identificar_compilado(+Observaciones:list, -Animal) is nondet.
%
%   La misma relación que identificar/2, con las reglas compiladas.
identificar_compilado(Observaciones, Animal) :-
    hipotesis(Animal),
    once(concluir(Animal, lista(Observaciones), [], _)).

%!  identificar_casos(:Identificar, +Veces:integer) is det.
%
%   Identifica Veces los animales de todos los casos con Identificar, sin
%   guardar las respuestas: sirve para medir.
identificar_casos(Identificar, Veces) :-
    forall(( between(1, Veces, _),
             caso(_, Observaciones),
             call(Identificar, Observaciones, _) ),
           true).
