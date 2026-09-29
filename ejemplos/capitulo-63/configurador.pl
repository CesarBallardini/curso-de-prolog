:- encoding(utf8).

% Capítulo 63 - Versión 4: un configurador de computadoras.
%
% La memoria empieza con el catálogo, un objeto por componente en venta,
% el pedido del cliente y la fase buscar(procesador). En cada fase, las
% reglas agregan un candidato por cada componente compatible con lo ya
% elegido; cuando no queda ninguno por agregar, la fase pasa a
% elegir(Tipo), donde se descartan los candidatos más caros y se elige el
% que queda. Las clases de los componentes son las de marcos.pl.
%
% solo-local: carga marcos.pl con ensure_loaded/1, y SWISH no permite
% cargar archivos.
%
%?- configurar([pedido(nucleos, 8), pedido(memoria, 32), pedido(video, si)], C, P, W).
%?- configurar([pedido(nucleos, 6), pedido(memoria, 64), pedido(video, no)], C, P, W).

:- ensure_loaded(marcos).

programa(configurador, Reglas) :-
    con_marcos(
    [ candidato_procesador ::
          [fase(buscar(procesador)), pedido(nucleos, Minimo),
           es(P, procesador, [nucleos-N]), {N >= Minimo}]
          ---> [agregar(candidato(procesador, P))],
      candidato_placa ::
          [fase(buscar(placa)), elegido(procesador, P),
           es(P, procesador, [zocalo-Z]), es(B, placa, [zocalo-Z])]
          ---> [agregar(candidato(placa, B))],
      candidato_memoria ::
          [fase(buscar(memoria)), elegido(placa, B), es(B, placa, [memoria-T]),
           pedido(memoria, Minimo), es(M, memoria, [tipo-T, gb-G]),
           {G >= Minimo}]
          ---> [agregar(candidato(memoria, M))],
      candidato_disipador ::
          [fase(buscar(disipador)), elegido(procesador, P),
           es(P, procesador, [necesita_disipador-si]), es(D, disipador, [])]
          ---> [agregar(candidato(disipador, D))],
      candidato_video ::
          [fase(buscar(placa_de_video)), pedido(video, si),
           es(V, placa_de_video, [])]
          ---> [agregar(candidato(placa_de_video, V))],
      candidato_fuente ::
          [fase(buscar(fuente)), consumo(W), es(F, fuente, [potencia-P]),
           {P >= W * 1.3}]
          ---> [agregar(candidato(fuente, F))],
      a_eleccion :: [fase(buscar(T)), {T \== fin}]
          ---> [reemplazar(fase(buscar(T)), fase(elegir(T)))],
      descartar_caro ::
          [fase(elegir(T)), candidato(T, A), candidato(T, B),
           es(A, componente, [precio-PA]), es(B, componente, [precio-PB]),
           {PA > PB}]
          ---> [quitar(candidato(T, A))],
      elegir ::
          [fase(elegir(T)), candidato(T, X), es(X, componente, [consumo-C]),
           consumo(W), despues(T, T1), {W1 is W + C}]
          ---> [quitar(candidato(T, X)), agregar(elegido(T, X)),
                reemplazar(consumo(W), consumo(W1)),
                reemplazar(fase(elegir(T)), fase(buscar(T1)))],
      faltante :: [fase(elegir(T)), obligatorio(T), despues(T, T1)]
          ---> [agregar(falta(T)),
                reemplazar(fase(elegir(T)), fase(buscar(T1)))],
      omitido :: [fase(elegir(T)), no(obligatorio(T)), despues(T, T1)]
          ---> [reemplazar(fase(elegir(T)), fase(buscar(T1)))],
      terminar :: [fase(buscar(fin))]
          ---> [parar(configurada)]
    ], Reglas).

% fases(Hechos): el orden de las fases, con despues(Tipo, Siguiente), y
% los tipos sin los que una computadora no funciona, con obligatorio(Tipo).
fases([despues(procesador, placa), despues(placa, memoria),
       despues(memoria, disipador), despues(disipador, placa_de_video),
       despues(placa_de_video, fuente), despues(fuente, fin),
       obligatorio(procesador), obligatorio(placa), obligatorio(memoria),
       obligatorio(fuente)]).

% catalogo(Objetos): los componentes en venta, como objetos de marcos.pl.
catalogo([ objeto(cpu_a, procesador, [zocalo-am5, nucleos-6, precio-190,
                                      necesita_disipador-no]),
           objeto(cpu_b, procesador, [zocalo-am5, nucleos-8, precio-320,
                                      consumo-120]),
           objeto(cpu_c, procesador, [zocalo-lga1700, nucleos-6,
                                      precio-170]),
           objeto(placa_a, placa, [zocalo-am5, memoria-ddr5, precio-180]),
           objeto(placa_b, placa, [zocalo-lga1700, memoria-ddr4,
                                   precio-120]),
           objeto(mem_a, memoria, [tipo-ddr5, gb-16, precio-60]),
           objeto(mem_b, memoria, [tipo-ddr5, gb-32, precio-110]),
           objeto(mem_c, memoria, [tipo-ddr4, gb-16, precio-40]),
           objeto(dis_a, disipador, [precio-35]),
           objeto(gpu_a, placa_de_video, [consumo-220, precio-400]),
           objeto(fuente_a, fuente, [potencia-450, precio-50]),
           objeto(fuente_b, fuente, [potencia-650, precio-80]),
           objeto(fuente_c, fuente, [potencia-850, precio-120])
         ]).

%!  memoria_del_pedido(+Pedido:list, -Hechos:list) is det.
%
%   Hechos es la memoria inicial del configurador para el Pedido: el
%   catálogo, las fases, el pedido, el consumo en 0 y la primera fase.
memoria_del_pedido(Pedido, Hechos) :-
    catalogo(Catalogo),
    fases(Fases),
    append([Catalogo, Fases, Pedido, [consumo(0), fase(buscar(procesador))]],
           Hechos).

%!  configurar(+Pedido:list, -Componentes:list, -Precio:number,
%!             -Consumo:number) is det.
%
%   Componentes son los pares Tipo-Nombre elegidos para el Pedido, en el
%   orden de las fases, y falta(Tipo) por cada tipo obligatorio sin
%   candidatos. Precio es la suma de los precios y Consumo, la de los
%   consumos en vatios.
configurar(Pedido, Componentes, Precio, Consumo) :-
    memoria_del_pedido(Pedido, Hechos),
    encadenar(configurador, mea, Hechos, Memoria, configurada),
    componentes(Memoria, Componentes, Precio),
    memberchk(consumo(Consumo), Memoria).

%!  configuracion(+Programa, +Estrategia, +Pedido:list, -Componentes:list,
%!                -Resultado) is det.
%
%   Componentes son los que elige el Programa con la Estrategia para el
%   Pedido, como en configurar/4, y Resultado, cómo terminó.
configuracion(Programa, Estrategia, Pedido, Componentes, Resultado) :-
    memoria_del_pedido(Pedido, Hechos),
    encadenar(Programa, Estrategia, Hechos, Memoria, Resultado),
    componentes(Memoria, Componentes, _).

% El mismo configurador, con las reglas en el orden inverso.
programa(configurador_invertido, Reglas) :-
    programa(configurador, Reglas0),
    reverse(Reglas0, Reglas).

%!  componentes(+Memoria:list, -Componentes:list, -Precio:number) is det.
%
%   Componentes son los elegidos y los faltantes de Memoria, del más
%   antiguo al más reciente, y Precio, la suma de los precios elegidos.
componentes(Memoria, Componentes, Precio) :-
    reverse(Memoria, Antiguos),
    findall(C, ( member(H, Antiguos), componente_de(H, C) ), Componentes),
    findall(P, ( member(elegido(_, X), Memoria),
                 memberchk(objeto(X, Clase, Ranuras), Memoria),
                 valor_ranura(Clase, Ranuras, precio, P) ),
            Precios),
    sum_list(Precios, Precio).

%!  componente_de(+Hecho, -Componente) is semidet.
%
%   Componente es Tipo-Nombre si Hecho es elegido(Tipo, Nombre), y
%   falta(Tipo) si Hecho es falta(Tipo).
componente_de(elegido(T, X), T-X).
componente_de(falta(T), falta(T)).

%!  rastrear_pedido(+Programa, +Estrategia, +Pedido:list, -Resultado) is det.
%
%   Ejecuta el Programa con la Estrategia para el Pedido, y escribe una
%   línea por ciclo con rastrear_reglas/5.
rastrear_pedido(Programa, Estrategia, Pedido, Resultado) :-
    memoria_del_pedido(Pedido, Hechos),
    rastrear_reglas(Programa, Estrategia, Hechos, _, Resultado).
