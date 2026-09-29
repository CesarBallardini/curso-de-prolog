:- encoding(utf8).

% Capítulo 64 - Versión 4: la negación.
%
% Un nodo no(F) guarda cada token de su padre con una cuenta: cuántos
% hechos de su memoria alfa unifican con F bajo las variables del token.
% El token pasa a la salida solo mientras su cuenta es cero. Un hecho que
% entra en la memoria alfa sube la cuenta de los tokens que bloquea, y el
% que pasa de cero a uno sale de la salida; un hecho que sale la baja, y el
% token que llega a cero vuelve a entrar. Así, quitar un hecho puede
% agregar instanciaciones. Este archivo agrega las cláusulas de la
% negación a derecha/8 e izquierda/8 de tokens.pl.
%
% solo-local: carga tokens.pl con ensure_loaded/1, y SWISH no permite
% cargar archivos.
%
%?- reconocer_rete(cajas, [meta(despejar(a)), sobre(a, piso)], Is).
%?- cuentas(cajas, [meta(despejar(a)), sobre(b, a)], 11, C).

:- ensure_loaded(tokens).

%   Un hecho que entra en la memoria alfa o sale de ella cambia la cuenta
%   de los tokens que bloquea.
derecha(negacion(_), Signo, _-alfa(Hecho, _), _-Nodo, Prefijo, Red, Rete0,
        Rete) :-
    tokens(cuentas(Nodo), Rete0, Cuentas0),
    foldl(recontar(Signo, Prefijo, Hecho), Cuentas0, Cuentas, [], Cambios0),
    reverse(Cambios0, Cambios),
    empty_assoc(Vacia),
    foldl(guardar_cuenta, Cuentas, Vacia, Memoria),
    Rete0 = rete(Alfas, Betas0, Conjunto),
    put_assoc(cuentas(Nodo), Betas0, Memoria, Betas),
    foldl(salida_negacion(Nodo, Prefijo, Red), Cambios,
          rete(Alfas, Betas, Conjunto), Rete).

%   Un token que llega del padre se guarda con su cuenta, y pasa si es
%   cero; un token que se va se quita, y sale si había pasado.
izquierda(negacion(A), Signo, Token, Nodo, Prefijo, Red, Rete0, Rete) :-
    llega_a_negacion(Signo, A, Token, Nodo, Prefijo, Red, Rete0, Rete).

%!  llega_a_negacion(+Signo, +A:integer, +Token, +Nodo:integer,
%!                   +Prefijo:list, +Red, +Rete0, -Rete) is det.
%
%   El Token del padre llega al nodo de negación Nodo, cuyo nodo alfa es A.
llega_a_negacion(mas, A, Sellos-Instancia, Nodo, Prefijo, Red, Rete0,
                 Rete) :-
    Rete0 = rete(Alfas, Betas0, Conjunto),
    get_assoc(A, Alfas, Memoria),
    copy_term(Prefijo, P),
    aggregate_all(count,
                  ( append(Instancia, [no(F)], P),
                    elementos_alfa(Memoria, F, Elementos),
                    member(_-alfa(F, _), Elementos) ),
                  N),
    cambiar_memoria(mas, cuentas(Nodo), Sellos-(Instancia-N), Betas0, Betas),
    Rete1 = rete(Alfas, Betas, Conjunto),
    (   N =:= 0
    ->  salida_negacion(Nodo, Prefijo, Red, mas-(Sellos-Instancia), Rete1,
                        Rete)
    ;   Rete = Rete1
    ).
llega_a_negacion(menos, _, Sellos-Instancia, Nodo, Prefijo, Red, Rete0,
                 Rete) :-
    Rete0 = rete(Alfas, Betas0, Conjunto),
    memoria_beta(cuentas(Nodo), Betas0, Memoria0),
    (   get_assoc(Sellos, Memoria0, Lista0),
        nth0(_, Lista0, Otra-N, Lista),
        Otra =@= Instancia
    ->  (   Lista == []
        ->  del_assoc(Sellos, Memoria0, _, Memoria)
        ;   put_assoc(Sellos, Memoria0, Lista, Memoria)
        ),
        put_assoc(cuentas(Nodo), Betas0, Memoria, Betas),
        Rete1 = rete(Alfas, Betas, Conjunto),
        (   N =:= 0
        ->  salida_negacion(Nodo, Prefijo, Red, menos-(Sellos-Instancia),
                            Rete1, Rete)
        ;   Rete = Rete1
        )
    ;   Rete = Rete0
    ).

%!  bloquea(+Instancia:list, +Prefijo:list, +Hecho) is semidet.
%
%   Hecho unifica con el F del último paso no(F) del Prefijo, con las
%   variables de la Instancia de un token. No liga ninguna variable.
bloquea(Instancia, Prefijo, Hecho) :-
    \+ \+ ( copy_term(Prefijo, P),
            append(Instancia, [no(Hecho)], P) ).

%!  recontar(+Signo, +Prefijo:list, +Hecho, +Cuenta0, -Cuenta, +Cambios0,
%!           -Cambios) is det.
%
%   Cuenta0 y Cuenta son términos Sellos-(Instancia-N). Si Hecho bloquea el
%   token Sellos-Instancia, N sube (mas) o baja (menos) en uno. Cambios
%   agrega a Cambios0 el par menos-Token si la cuenta pasó de cero a uno, y
%   mas-Token si pasó de uno a cero.
recontar(Signo, Prefijo, Hecho, Sellos-(Instancia-N0),
         Sellos-(Instancia-N), Cambios0, Cambios) :-
    (   bloquea(Instancia, Prefijo, Hecho)
    ->  paso_cuenta(Signo, N0, N, Sellos-Instancia, Cambios0, Cambios)
    ;   N = N0,
        Cambios = Cambios0
    ).

%!  paso_cuenta(+Signo, +N0:integer, -N:integer, +Token, +Cambios0,
%!              -Cambios) is det.
%
%   N es N0 más o menos uno, según el Signo, y Cambios registra si el
%   Token deja de pasar o vuelve a pasar.
paso_cuenta(mas, N0, N, Token, Cambios0, Cambios) :-
    N is N0 + 1,
    (   N0 =:= 0
    ->  Cambios = [menos-Token|Cambios0]
    ;   Cambios = Cambios0
    ).
paso_cuenta(menos, N0, N, Token, Cambios0, Cambios) :-
    N is N0 - 1,
    (   N =:= 0
    ->  Cambios = [mas-Token|Cambios0]
    ;   Cambios = Cambios0
    ).

%!  guardar_cuenta(+Cuenta, +Memoria0, -Memoria) is det.
%
%   Guarda la Cuenta Sellos-(Instancia-N) bajo sus Sellos.
guardar_cuenta(Sellos-Valor, Memoria0, Memoria) :-
    cambiar_lista(mas, Sellos, Valor, Memoria0, Memoria).

%!  salida_negacion(+Nodo:integer, +Prefijo:list, +Red, +Cambio, +Rete0,
%!                  -Rete) is det.
%
%   Cambio es Signo-Token. El token de salida del Nodo es el Token con el
%   paso no(F) al final, y entra en la salida o sale según el Signo.
salida_negacion(Nodo, Prefijo, Red, Signo-(Sellos-Instancia), Rete0,
                Rete) :-
    copy_term(Prefijo, P),
    append(Instancia, [_], P),
    salida(Signo, Nodo, Red, Sellos-P, Rete0, Rete).

%!  cuentas(+Programa, +Hechos:list, +Nodo:integer, -Cuentas:list) is det.
%
%   Cuentas son los pares Sellos-N del nodo de negación Nodo de la red del
%   Programa, después de cargar los Hechos: los sellos de cada token del
%   padre y cuántos hechos lo bloquean.
cuentas(Programa, Hechos, Nodo, Cuentas) :-
    red_de(Programa, Red),
    cargar(Red, Hechos, _, Rete),
    tokens(cuentas(Nodo), Rete, Pares),
    findall(Sellos-N, member(Sellos-(_-N), Pares), Cuentas).

% Una negación puede devolver al conjunto de conflicto una instanciación ya
% disparada, con los mismos sellos: avisar no usa ningún hecho, así que sus
% sellos son siempre []. Sin el registro de las disparadas de rete.pl, el
% programa no termina.
programa(reingreso,
    [ avisar :: [no(ocupado)] ---> [agregar(aviso)],
      ocupar :: [aviso, no(ocupado)] ---> [agregar(ocupado)],
      liberar :: [ocupado] ---> [quitar(ocupado)]
    ]).
