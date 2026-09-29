:- encoding(utf8).

% Capítulo 63 - Soluciones de los ejercicios.
%
% Carga costo.pl, que carga las demás versiones, y no modifica ningún
% archivo del capítulo: los programas nuevos son cláusulas de programa/2,
% las estrategias nuevas, de clave_estrategia/3, y las clases nuevas, de
% marco/3, tres predicados que el capítulo declara multifile.
%
% solo-local: carga costo.pl con ensure_loaded/1, y SWISH no permite
% cargar archivos.
%
%?- encadenar_vigilado(familia, orden, no, 50, [padre(juan, ana)], M, R).
%?- mas_barata([pedido(nucleos, 6), pedido(memoria, 16), pedido(video, no)], C, P).

:- ensure_loaded(costo).

% Ejercicio 2 -------------------------------------------------------------

%!  encadenar_vigilado(+Programa, +Estrategia, +Refraccion, +Limite:integer,
%!                     +Hechos:list, -Memoria:list, -Resultado) is det.
%
%   Como encadenar/5, con la refracción si Refraccion es si y sin ella si
%   es no. Resultado es limite(Limite) si el programa disparó Limite
%   reglas sin terminar.
encadenar_vigilado(Programa, Estrategia, Refraccion, Limite, Hechos,
                   Memoria, Resultado) :-
    programa(Programa, Reglas),
    memoria_con(Hechos, Memoria0),
    vigilado_63(Reglas, Estrategia, Refraccion, Limite, 0, [], Memoria0,
                Memoria1, Resultado),
    hechos(Memoria1, Memoria).

%!  vigilado_63(+Reglas:list, +Estrategia, +Refraccion, +Limite:integer,
%!              +N:integer, +Disparadas:list, +Memoria0, -Memoria,
%!              -Resultado) is det.
%
%   El ciclo de reconocer_actuar/9 con un límite de ciclos. N es la
%   cantidad de ciclos hechos.
vigilado_63(Reglas, Estrategia, Refraccion, Limite, N, Disparadas,
            Memoria0, Memoria, Resultado) :-
    conjunto_conflicto(Reglas, Memoria0, Todas),
    candidatas(Refraccion, Todas, Disparadas, Nuevas),
    (   Nuevas == []
    ->  Memoria = Memoria0,
        Resultado = nada_aplicable
    ;   N >= Limite
    ->  Memoria = Memoria0,
        Resultado = limite(N)
    ;   preferida(Estrategia, Nuevas, Elegida),
        Elegida = instanciacion(Nombre, Sellos, _, Acciones),
        ord_add_element(Disparadas, Nombre-Sellos, Disparadas1),
        aplicar_acciones(Acciones, Memoria0, Memoria1, Fin),
        N1 is N + 1,
        (   Fin = parar(R)
        ->  Memoria = Memoria1,
            Resultado = R
        ;   vigilado_63(Reglas, Estrategia, Refraccion, Limite, N1,
                        Disparadas1, Memoria1, Memoria, Resultado)
        )
    ).

%!  candidatas(+Refraccion, +Todas:list, +Disparadas:list, -Nuevas:list)
%!      is det.
%
%   Nuevas son Todas sin las ya disparadas si Refraccion es si, y Todas si
%   es no.
candidatas(si, Todas, Disparadas, Nuevas) :-
    refractar(Todas, Disparadas, Nuevas).
candidatas(no, Todas, _, Todas).

% Ejercicio 4 -------------------------------------------------------------

% prioridad(Regla, P): la Regla tiene la prioridad P; mayor se prefiere.
prioridad(apilar, 1).

% Con prioridad, la clave es prio(P, Lex): la prioridad de la regla y la
% clave de LEX.
clave_estrategia(prioridad, Instanciacion, prio(P, Lex)) :-
    Instanciacion = instanciacion(Nombre, _, _, _),
    prioridad_de(Nombre, P),
    clave_estrategia(lex, Instanciacion, Lex).

%!  prioridad_de(+Regla, -P:integer) is det.
%
%   P es la prioridad de la Regla, o 0 si no tiene.
prioridad_de(Regla, P) :-
    (   prioridad(Regla, P0)
    ->  P = P0
    ;   P = 0
    ).

% Ejercicio 7 -------------------------------------------------------------

marco(apu, [procesador, placa_de_video], []).
marco(apu_invertida, [placa_de_video, procesador], []).

% Ejercicio 8 -------------------------------------------------------------

% El configurador con el consumo sumado por una regla aparte.
programa(configurador_sumando, Reglas) :-
    programa(configurador, Reglas0),
    exclude(regla_llamada(elegir), Reglas0, Reglas1),
    con_marcos(
        [ elegir ::
              [fase(elegir(T)), candidato(T, X), despues(T, T1)]
              ---> [quitar(candidato(T, X)), agregar(elegido(T, X)),
                    reemplazar(fase(elegir(T)), fase(buscar(T1)))],
          sumar ::
              [elegido(_, X), es(X, componente, [consumo-C]), consumo(W),
               {W1 is W + C}]
              ---> [reemplazar(consumo(W), consumo(W1))]
        ], Nuevas),
    append(Nuevas, Reglas1, Reglas).

%!  configurar_sumando(+Estrategia, -Componentes:list, -Consumo:number,
%!                     -Resultado) is det.
%
%   Ejecuta configurador_sumando con la Estrategia, la refracción y un
%   límite de 200 ciclos, para el pedido de 8 núcleos, 32 GB y placa de
%   video.
configurar_sumando(Estrategia, Componentes, Consumo, Resultado) :-
    memoria_del_pedido([pedido(nucleos, 8), pedido(memoria, 32),
                        pedido(video, si)], Hechos),
    encadenar_vigilado(configurador_sumando, Estrategia, si, 200, Hechos,
                       Memoria, Resultado),
    componentes(Memoria, Componentes, _),
    memberchk(consumo(Consumo), Memoria).

%!  regla_llamada(+Nombre, +Regla) is semidet.
%
%   Regla se llama Nombre.
regla_llamada(Nombre, Nombre :: _ ---> _).

% Ejercicio 9 -------------------------------------------------------------

% Una segunda cláusula de marco/3 para placa le agrega una ranura.
marco(gabinete, [componente], [formatos-[atx]]).
marco(placa, [componente], [formato-atx]).

% El configurador con una regla más, para el gabinete.
programa(configurador_gabinete, Reglas) :-
    programa(configurador, Reglas0),
    con_marcos(
        [ candidato_gabinete ::
              [fase(buscar(gabinete)), elegido(placa, B),
               es(B, placa, [formato-F]), es(G, gabinete, [formatos-Fs]),
               {memberchk(F, Fs)}]
              ---> [agregar(candidato(gabinete, G))]
        ], [Regla]),
    Reglas = [Regla|Reglas0].

%!  memoria_con_gabinete(+Pedido:list, -Hechos:list) is det.
%
%   Hechos es la memoria inicial del configurador para el Pedido, con dos
%   gabinetes y una placa micro-ATX más en el catálogo, y el gabinete como
%   fase obligatoria después de la fuente.
memoria_con_gabinete(Pedido, Hechos) :-
    memoria_del_pedido(Pedido, Hechos0),
    subtract(Hechos0, [despues(fuente, fin)], Hechos1),
    append(Hechos1,
           [objeto(placa_c, placa, [zocalo-lga1700, memoria-ddr4,
                                    formato-microatx, precio-90]),
            objeto(gab_a, gabinete, [formatos-[microatx], precio-40]),
            objeto(gab_b, gabinete, [formatos-[atx, microatx], precio-70]),
            despues(fuente, gabinete), despues(gabinete, fin),
            obligatorio(gabinete)],
           Hechos).

%!  configurar_gabinete(+Pedido:list, -Componentes:list) is det.
%
%   Componentes son los que elige configurador_gabinete para el Pedido.
configurar_gabinete(Pedido, Componentes) :-
    memoria_con_gabinete(Pedido, Hechos),
    encadenar(configurador_gabinete, mea, Hechos, Memoria, configurada),
    componentes(Memoria, Componentes, _).

% Ejercicio 10 ------------------------------------------------------------

%!  mas_barata(+Pedido:list, -Componentes:list, -Precio:number) is semidet.
%
%   Componentes es la configuración compatible de menor Precio para el
%   Pedido con el catálogo del capítulo. Falla si no hay ninguna.
mas_barata(Pedido, Componentes, Precio) :-
    catalogo(Catalogo),
    mas_barata(Catalogo, Pedido, Componentes, Precio).

%!  mas_barata(+Catalogo:list, +Pedido:list, -Componentes:list,
%!             -Precio:number) is semidet.
%
%   Como mas_barata/3, con otro Catalogo.
mas_barata(Catalogo, Pedido, Componentes, Precio) :-
    aggregate_all(min(P, C), compatible(Catalogo, Pedido, C, P),
                  min(Precio, Componentes)).

%!  compatible(+Catalogo:list, +Pedido:list, -Componentes:list,
%!             -Precio:number) is nondet.
%
%   Componentes es una configuración que cumple el Pedido con el Catalogo,
%   con las mismas condiciones que las reglas del configurador, y Precio,
%   la suma de sus precios.
compatible(Catalogo, Pedido, Componentes, Precio) :-
    memberchk(pedido(nucleos, Nucleos), Pedido),
    memberchk(pedido(memoria, Gb), Pedido),
    memberchk(pedido(video, Video), Pedido),
    ranura(Catalogo, Cpu, procesador, nucleos, N), N >= Nucleos,
    ranura(Catalogo, Cpu, procesador, zocalo, Z),
    ranura(Catalogo, Placa, placa, zocalo, Z),
    ranura(Catalogo, Placa, placa, memoria, T),
    ranura(Catalogo, Mem, memoria, tipo, T),
    ranura(Catalogo, Mem, memoria, gb, G), G >= Gb,
    disipador(Catalogo, Cpu, Disipador),
    video(Catalogo, Video, Placas),
    append([[Cpu, Placa, Mem], Disipador, Placas], Partes),
    consumo_total(Catalogo, Partes, W),
    ranura(Catalogo, Fuente, fuente, potencia, P), P >= W * 1.3,
    append(Partes, [Fuente], Componentes),
    consumo_o_precio(Catalogo, precio, Componentes, Precio).

%!  ranura(+Catalogo:list, ?Objeto, +Clase, +Ranura, ?Valor) is nondet.
%
%   Objeto es un objeto del Catalogo de la Clase, o de una subclase, cuya
%   Ranura tiene el Valor.
ranura(Catalogo, Objeto, Clase, Ranura, Valor) :-
    member(objeto(Objeto, C, Ranuras), Catalogo),
    es_de_clase(C, Clase),
    valor_ranura(C, Ranuras, Ranura, Valor).

%!  disipador(+Catalogo:list, +Cpu, -Disipador:list) is nondet.
%
%   Disipador es [D] con un disipador D del Catalogo si Cpu lo necesita, y
%   [] si no.
disipador(Catalogo, Cpu, Disipador) :-
    (   ranura(Catalogo, Cpu, procesador, necesita_disipador, si)
    ->  ranura(Catalogo, D, disipador, precio, _),
        Disipador = [D]
    ;   Disipador = []
    ).

%!  video(+Catalogo:list, +Video, -Placas:list) is nondet.
%
%   Placas es [V] con una placa de video V del Catalogo si Video es si, y
%   [] si es no.
video(Catalogo, si, [V]) :-
    ranura(Catalogo, V, placa_de_video, precio, _).
video(_, no, []).

%!  consumo_total(+Catalogo:list, +Objetos:list, -W:number) is det.
%
%   W es la suma de los consumos de los Objetos.
consumo_total(Catalogo, Objetos, W) :-
    consumo_o_precio(Catalogo, consumo, Objetos, W).

%!  consumo_o_precio(+Catalogo:list, +Ranura, +Objetos:list, -Suma:number)
%!      is det.
%
%   Suma es la suma de la Ranura de los Objetos del Catalogo.
consumo_o_precio(Catalogo, Ranura, Objetos, Suma) :-
    findall(V, ( member(O, Objetos),
                 memberchk(objeto(O, C, Rs), Catalogo),
                 valor_ranura(C, Rs, Ranura, V) ),
            Vs),
    sum_list(Vs, Suma).

%!  catalogo_con_disipador_caro(-Catalogo:list) is det.
%
%   Catalogo es el del capítulo con el disipador a 110 en lugar de 35.
catalogo_con_disipador_caro(Catalogo) :-
    catalogo(Catalogo0),
    selectchk(objeto(dis_a, disipador, _), Catalogo0,
              objeto(dis_a, disipador, [precio-110]), Catalogo).

%!  configurar_con(+Catalogo:list, +Pedido:list, -Componentes:list,
%!                 -Precio:number) is det.
%
%   Como configurar/4, con otro Catalogo en la memoria inicial.
configurar_con(Catalogo, Pedido, Componentes, Precio) :-
    fases(Fases),
    append([Catalogo, Fases, Pedido, [consumo(0), fase(buscar(procesador))]],
           Hechos),
    encadenar(configurador, mea, Hechos, Memoria, configurada),
    componentes(Memoria, Componentes, Precio).

%!  comparar_disipador_caro(-Optima:list, -PrecioOptimo:number,
%!                          -Elegida:list, -PrecioElegido:number) is det.
%
%   Para el pedido de 6 núcleos, 16 GB y sin video, con el disipador a
%   110, Optima es la configuración más barata y Elegida, la del
%   configurador.
comparar_disipador_caro(Optima, PrecioOptimo, Elegida, PrecioElegido) :-
    Pedido = [pedido(nucleos, 6), pedido(memoria, 16), pedido(video, no)],
    catalogo_con_disipador_caro(Catalogo),
    mas_barata(Catalogo, Pedido, Optima, PrecioOptimo),
    configurar_con(Catalogo, Pedido, Elegida, PrecioElegido).

% Ejercicio 11 ------------------------------------------------------------

%!  familias(+K:integer, -Hechos:list) is det.
%
%   Hechos son los de K copias de la familia del capítulo 20, con cada
%   nombre N de la copia I escrito N-I.
familias(K, Hechos) :-
    familia(Familia),
    findall(H, ( between(1, K, I),
                 member(H0, Familia),
                 copia(I, H0, H) ),
            Hechos).

%!  copia(+I:integer, +Hecho0, -Hecho) is det.
%
%   Hecho es Hecho0 con cada nombre N reemplazado por N-I.
copia(I, Hecho0, Hecho) :-
    Hecho0 =.. [F, A, B],
    Hecho =.. [F, A-I, B-I].

% Ejercicio 12 ------------------------------------------------------------

%!  con_origen(+Reglas0:list, -Reglas:list) is det.
%
%   Reglas son las Reglas0 con una acción agregar(origen(F, Regla, Hechos))
%   después de cada agregar(F): Hechos son los hechos que cumplen los
%   patrones de la Regla.
con_origen(Reglas0, Reglas) :-
    maplist(regla_con_origen, Reglas0, Reglas).

%!  regla_con_origen(+Regla0, -Regla) is det.
%
%   Regla es Regla0 con los origen/3 agregados.
regla_con_origen(Nombre :: Condiciones ---> Acciones0,
                 Nombre :: Condiciones ---> Acciones) :-
    include(patron_de_hecho, Condiciones, Patrones),
    maplist(con_su_origen(Nombre, Patrones), Acciones0, Partes),
    append(Partes, Acciones).

%!  patron_de_hecho(+Condicion) is semidet.
%
%   Condicion es un patrón, ni una prueba ni una negación.
patron_de_hecho(Condicion) :-
    patron(Condicion).

%!  con_su_origen(+Nombre, +Patrones:list, +Accion, -Acciones:list) is det.
%
%   Acciones es [Accion] seguida de su origen si Accion es agregar/1.
con_su_origen(Nombre, Patrones, Accion, Acciones) :-
    (   Accion = agregar(F)
    ->  Acciones = [Accion, agregar(origen(F, Nombre, Patrones))]
    ;   Acciones = [Accion]
    ).

programa(familia_con_origen, Reglas) :-
    programa(familia, Reglas0),
    con_origen(Reglas0, Reglas).

%!  explicar(+Hecho, -Arbol) is nondet.
%
%   Arbol es la explicación de Hecho en la memoria final de
%   familia_con_origen: por(Hecho, Regla, Arboles) si una regla lo agregó,
%   con los árboles de los hechos que usó, o inicial(Hecho).
explicar(Hecho, Arbol) :-
    familia(Hechos),
    encadenar(familia_con_origen, orden, Hechos, Memoria, _),
    explicar(Memoria, Hecho, Arbol).

%!  explicar(+Memoria:list, +Hecho, -Arbol) is nondet.
%
%   Como explicar/2, en la Memoria dada.
explicar(Memoria, Hecho, Arbol) :-
    (   memberchk(origen(Hecho, _, _), Memoria)
    ->  member(origen(Hecho, Regla, Usados), Memoria),
        maplist(explicar(Memoria), Usados, Arboles),
        Arbol = por(Hecho, Regla, Arboles)
    ;   Arbol = inicial(Hecho)
    ).
