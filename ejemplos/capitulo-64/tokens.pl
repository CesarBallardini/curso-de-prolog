:- encoding(utf8).

% Capítulo 64 - Versión 3: tokens, uniones y el conjunto de conflicto.
%
% Un token es una manera de cumplir el prefijo de un nodo beta: el par
% Sellos-Instancia, con los sellos de los hechos usados y el prefijo con
% sus variables ligadas. La memoria de cada nodo beta guarda sus tokens,
% indexados por sus sellos. Un hecho que entra en una memoria alfa activa
% por la derecha a los nodos que la leen: cada token del padre se une con
% el hecho. Un token nuevo activa por la izquierda a los hijos: se une con
% cada hecho de su memoria alfa, o pasa la prueba. El token que completa
% una regla es una instanciación del conjunto de conflicto, que queda
% guardado entre ciclos. Un hecho que sale recorre el mismo camino con el
% signo menos y quita lo que su entrada agregó.
%
% Esta versión no conoce la negación: un programa con no(F) no pasa de la
% primera activación de ese nodo, porque derecha/8 e izquierda/8 no tienen
% cláusula para él. La versión 4 se la agrega.
%
% solo-local: carga alfa.pl con ensure_loaded/1, y SWISH no permite cargar
% archivos.
%
%?- reconocer_rete(familia, [padre(juan, ana), padre(ana, sofia)], Is).
%?- cambios_rete(familia, [padre(juan, ana)], [menos(padre(juan, ana))], Is).

:- ensure_loaded(alfa).

% La versión 4 agrega las cláusulas de la negación.
:- multifile derecha/8, izquierda/8.

%!  rete_vacio(+Red, -Rete) is det.
%
%   Rete es el estado de la Red sin hechos: rete(Alfas, Betas, Conjunto).
%   La raíz recibe el token vacío []-[], que sigue hacia sus hijos: una
%   regla que empieza con una prueba o una negación puede cumplirse sin
%   ningún hecho, y una regla sin condiciones entra en el conjunto.
rete_vacio(Red, Rete) :-
    memorias_alfa_vacias(Red, Alfas),
    empty_assoc(Betas),
    empty_assoc(Conjunto),
    salida(mas, 0, Red, []-[], rete(Alfas, Betas, Conjunto), Rete).

%!  propagar(+Signo, +Sello:integer, +Hecho, +Red, +Rete0, -Rete) is det.
%
%   Hecho, con el Sello, entra en la red (Signo mas) o sale (Signo menos).
%   Primero cambian las memorias alfa; después se activan por la derecha
%   los nodos que las leen, del más profundo al menos profundo, para que un
%   token nuevo no se una dos veces con el mismo hecho.
propagar(Signo, Sello, Hecho, Red, rete(Alfas0, Betas, Conjunto), Rete) :-
    entrar_alfa(Signo, Sello, Hecho, Red, Alfas0, Alfas, Entradas),
    Red = red(_, Info, _, _),
    findall(B-Paso,
            ( member(A-Paso, Entradas),
              get_assoc(A, Info, a(_, Sucesores)),
              member(B, Sucesores) ),
            Activaciones0),
    sort(1, @>=, Activaciones0, Activaciones),
    foldl(activar_derecha(Signo, Sello, Red), Activaciones,
          rete(Alfas, Betas, Conjunto), Rete).

%!  activar_derecha(+Signo, +Sello:integer, +Red, +Activacion, +Rete0,
%!                  -Rete) is det.
%
%   Activacion es Nodo-Paso: activa por la derecha el Nodo con el Paso que
%   entró en su memoria alfa, o salió de ella, con el Sello. Si el padre
%   no tiene tokens, no hay nada con qué unir el paso, y el nodo no se
%   activa.
activar_derecha(Signo, Sello, Red, Nodo-Paso, Rete0, Rete) :-
    Red = red(_, _, Nodos, _),
    get_assoc(Nodo, Nodos, beta(Tipo, Padre, Prefijo, _, _)),
    Rete0 = rete(_, Betas, _),
    memoria_beta(Padre, Betas, Memoria),
    (   empty_assoc(Memoria)
    ->  Rete = Rete0
    ;   derecha(Tipo, Signo, Sello-Paso, Padre-Nodo, Prefijo, Red, Rete0,
                Rete)
    ).

%!  derecha(+Tipo, +Signo, +Elemento, +PadreNodo, +Prefijo:list, +Red,
%!          +Rete0, -Rete) is det.
%
%   Un nodo de unión une el Elemento Sello-Paso con cada token de su
%   padre, y pasa a su salida los tokens que resultan. El prefijo se copia
%   una sola vez; findall/3 deshace las ligaduras de cada intento.
derecha(union(_), Signo, Sello-Paso, Padre-Nodo, Prefijo, Red, Rete0,
        Rete) :-
    tokens(Padre, Rete0, Tokens),
    copy_term(Prefijo, P),
    once(append(Anterior, [Paso], P)),
    findall(Sellos1-P,
            ( member(Sellos-Anterior, Tokens),
              append(Sellos, [Sello], Sellos1) ),
            Nuevos),
    foldl(salida(Signo, Nodo, Red), Nuevos, Rete0, Rete).

%!  izquierda(+Tipo, +Signo, +Token, +Nodo:integer, +Prefijo:list, +Red,
%!            +Rete0, -Rete) is det.
%
%   Un nodo de unión une el Token que llega de su padre con cada hecho de
%   su memoria alfa que puede unificar; una prueba ejecuta su meta con las
%   variables del Token, y pasa un token por cada solución.
izquierda(union(A), Signo, Sellos-Instancia, Nodo, Prefijo, Red, Rete0,
          Rete) :-
    Rete0 = rete(Alfas, _, _),
    get_assoc(A, Alfas, Memoria),
    copy_term(Prefijo, P),
    findall(Sellos1-P,
            ( append(Instancia, [Paso], P),
              Paso = alfa(F, _),
              elementos_alfa(Memoria, F, Elementos),
              member(Sello-Paso, Elementos),
              append(Sellos, [Sello], Sellos1) ),
            Nuevos),
    foldl(salida(Signo, Nodo, Red), Nuevos, Rete0, Rete).
izquierda(prueba, Signo, Sellos-Instancia, Nodo, Prefijo, Red, Rete0,
          Rete) :-
    copy_term(Prefijo, P),
    findall(Sellos-P,
            ( append(Instancia, [{Meta}], P),
              call(Meta) ),
            Nuevos),
    foldl(salida(Signo, Nodo, Red), Nuevos, Rete0, Rete).

%!  salida(+Signo, +Nodo:integer, +Red, +Token, +Rete0, -Rete) is det.
%
%   El Token entra en la memoria del Nodo, o sale de ella, y el cambio
%   sigue hacia los hijos del Nodo y hacia las reglas que terminan en él.
salida(Signo, Nodo, Red, Token, rete(Alfas, Betas0, Conjunto), Rete) :-
    cambiar_memoria(Signo, Nodo, Token, Betas0, Betas),
    Red = red(_, _, Nodos, _),
    get_assoc(Nodo, Nodos, beta(_, _, _, Hijos, Ks)),
    foldl(activar_izquierda(Signo, Token, Red), Hijos,
          rete(Alfas, Betas, Conjunto), Rete1),
    foldl(terminal(Signo, Token, Red), Ks, Rete1, Rete).

%!  activar_izquierda(+Signo, +Token, +Red, +Hijo:integer, +Rete0, -Rete)
%!      is det.
%
%   Activa por la izquierda el nodo Hijo con el Token de su padre.
activar_izquierda(Signo, Token, Red, Hijo, Rete0, Rete) :-
    Red = red(_, _, Nodos, _),
    get_assoc(Hijo, Nodos, beta(Tipo, _, Prefijo, _, _)),
    izquierda(Tipo, Signo, Token, Hijo, Prefijo, Red, Rete0, Rete).

%!  terminal(+Signo, +Token, +Red, +K:integer, +Rete0, -Rete) is det.
%
%   El Token completa la regla número K: su instanciación entra en el
%   conjunto de conflicto, o sale de él. La clave K-Inversos, con los
%   sellos cambiados de signo, ordena el conjunto como el capítulo 63:
%   por el orden de las reglas y, dentro de una regla, del hecho más
%   reciente al más antiguo.
terminal(Signo, Token, Red, K, rete(Alfas, Betas, Conjunto0),
         rete(Alfas, Betas, Conjunto)) :-
    Red = red(_, _, _, Terminales),
    get_assoc(K, Terminales, regla(Nombre, N, Pasos, Acciones)),
    copy_term(Token, Sellos-Instancia),
    copy_term(Pasos-Acciones, Instancia-Acciones1),
    maplist(opuesto, Sellos, Inversos),
    cambiar_lista(Signo, K-Inversos,
                  instanciacion(Nombre, Sellos, N, Acciones1),
                  Conjunto0, Conjunto).

%!  opuesto(+X:integer, -Y:integer) is det.
%
%   Y es -X.
opuesto(X, Y) :-
    Y is -X.

%!  cambiar_lista(+Signo, +Clave, +Elemento, +Tabla0, -Tabla) is det.
%
%   Tabla0 y Tabla asocian claves con listas. Con mas, el Elemento se
%   agrega al final de la lista de la Clave. Con menos, se quita de esa
%   lista el primer elemento que es una variante suya, y la clave se borra
%   si su lista queda vacía; si no hay ninguno, Tabla es Tabla0.
cambiar_lista(mas, Clave, Elemento, Tabla0, Tabla) :-
    (   get_assoc(Clave, Tabla0, Lista0)
    ->  append(Lista0, [Elemento], Lista)
    ;   Lista = [Elemento]
    ),
    put_assoc(Clave, Tabla0, Lista, Tabla).
cambiar_lista(menos, Clave, Elemento, Tabla0, Tabla) :-
    (   get_assoc(Clave, Tabla0, Lista0),
        nth0(_, Lista0, Otro, Lista),
        Otro =@= Elemento
    ->  (   Lista == []
        ->  del_assoc(Clave, Tabla0, _, Tabla)
        ;   put_assoc(Clave, Tabla0, Lista, Tabla)
        )
    ;   Tabla = Tabla0
    ).

%!  memoria_beta(+Clave, +Betas, -Memoria) is det.
%
%   Memoria es la tabla de la Clave en Betas, o una tabla vacía si todavía
%   no tiene ninguna.
memoria_beta(Clave, Betas, Memoria) :-
    (   get_assoc(Clave, Betas, Memoria)
    ->  true
    ;   empty_assoc(Memoria)
    ).

%!  tokens(+Clave, +Rete, -Tokens:list) is det.
%
%   Tokens son los pares Sellos-Instancia de la memoria beta de la Clave.
tokens(Clave, rete(_, Betas, _), Tokens) :-
    memoria_beta(Clave, Betas, Memoria),
    findall(Sellos-I,
            ( gen_assoc(Sellos, Memoria, Is),
              member(I, Is) ),
            Tokens).

%!  cambiar_memoria(+Signo, +Clave, +Token, +Betas0, -Betas) is det.
%
%   Agrega el Token Sellos-Valor a la memoria beta de la Clave, bajo sus
%   Sellos, o lo quita.
cambiar_memoria(Signo, Clave, Sellos-Valor, Betas0, Betas) :-
    memoria_beta(Clave, Betas0, Memoria0),
    cambiar_lista(Signo, Sellos, Valor, Memoria0, Memoria),
    put_assoc(Clave, Betas0, Memoria, Betas).

%!  conjunto_rete(+Rete, -Instanciaciones:list) is det.
%
%   Instanciaciones es el conjunto de conflicto guardado en Rete, en el
%   orden de conjunto_conflicto/3 del capítulo 63.
conjunto_rete(rete(_, _, Conjunto), Instanciaciones) :-
    assoc_to_values(Conjunto, Listas),
    append(Listas, Instanciaciones).

%!  afirmar_rete(+Red, +Hecho, +Estado0, -Estado) is det.
%
%   Estado0 y Estado son pares Memoria-Rete. Hecho entra en la memoria de
%   trabajo del capítulo 63 y, si no estaba, en la red con su sello nuevo.
afirmar_rete(Red, Hecho, Memoria0-Rete0, Memoria-Rete) :-
    afirmar(Hecho, Memoria0, Memoria),
    Memoria0 = mt(Reloj0, _),
    Memoria = mt(Reloj, _),
    (   Reloj > Reloj0
    ->  propagar(mas, Reloj, Hecho, Red, Rete0, Rete)
    ;   Rete = Rete0
    ).

%!  retirar_rete(+Red, +Hecho, +Estado0, -Estado) is semidet.
%
%   Como afirmar_rete/4, pero Hecho sale de la memoria y de la red. Falla
%   si no está en la memoria.
retirar_rete(Red, Hecho, Memoria0-Rete0, Memoria-Rete) :-
    once(elemento(Sello, Hecho, Memoria0)),
    retirar(Hecho, Memoria0, Memoria),
    propagar(menos, Sello, Hecho, Red, Rete0, Rete).

%!  cargar(+Red, +Hechos:list, -Memoria, -Rete) is det.
%
%   Memoria y Rete son la memoria de trabajo y el estado de la Red después
%   de agregar los Hechos en orden, desde la memoria vacía.
cargar(Red, Hechos, Memoria, Rete) :-
    memoria_vacia(Memoria0),
    rete_vacio(Red, Rete0),
    foldl(afirmar_rete(Red), Hechos, Memoria0-Rete0, Memoria-Rete).

%!  reconocer_rete(+Programa, +Hechos:list, -Instanciaciones:list) is det.
%
%   Instanciaciones es el conjunto de conflicto del Programa en la memoria
%   con los Hechos, reunido por la red.
reconocer_rete(Programa, Hechos, Instanciaciones) :-
    red_de(Programa, Red),
    cargar(Red, Hechos, _, Rete),
    conjunto_rete(Rete, Instanciaciones).

%!  cambios_rete(+Programa, +Hechos:list, +Cambios:list,
%!               -Instanciaciones:list) is semidet.
%
%   Como reconocer_rete/3, y después aplica los Cambios, términos mas(H) y
%   menos(H), en orden. Falla si un cambio quita un hecho que no está.
cambios_rete(Programa, Hechos, Cambios, Instanciaciones) :-
    red_de(Programa, Red),
    cargar(Red, Hechos, Memoria0, Rete0),
    foldl(cambio(Red), Cambios, Memoria0-Rete0, _-Rete),
    conjunto_rete(Rete, Instanciaciones).

%!  cambio(+Red, +Cambio, +Estado0, -Estado) is semidet.
%
%   Aplica el Cambio mas(H) o menos(H) al par Memoria-Rete.
cambio(Red, Cambio, Estado0, Estado) :-
    (   Cambio = mas(Hecho)
    ->  afirmar_rete(Red, Hecho, Estado0, Estado)
    ;   Cambio = menos(Hecho),
        retirar_rete(Red, Hecho, Estado0, Estado)
    ).

%!  mismo_conjunto(+Programa, +Hechos:list, +Cambios:list) is semidet.
%
%   Después de los Cambios, el conjunto de conflicto de la red es una
%   variante del que reúne conjunto_conflicto/3 del capítulo 63 en la misma
%   memoria de trabajo: las mismas instanciaciones, en el mismo orden.
mismo_conjunto(Programa, Hechos, Cambios) :-
    red_de(Programa, Red),
    cargar(Red, Hechos, Memoria0, Rete0),
    foldl(cambio(Red), Cambios, Memoria0-Rete0, Memoria-Rete),
    conjunto_rete(Rete, Is),
    programa(Programa, Reglas),
    conjunto_conflicto(Reglas, Memoria, Is63),
    Is =@= Is63.
