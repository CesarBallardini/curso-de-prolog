:- encoding(utf8).

% Capítulo 56 - Soluciones de los ejercicios 4, 5, 6 y 8 a 12.
%
% Cada solución agrega cláusulas a los predicados que los archivos del
% capítulo declaran multifile, o define predicados nuevos que usan los del
% capítulo; ninguna modifica esos archivos.
%
% solo-local: carga el programa del capítulo y fechas.pl del capítulo 21
% con ensure_loaded/1.

:- ensure_loaded(ordenes).
:- ensure_loaded('../capitulo-21/fechas').

:- multifile verbo/2, pedido//1, objeto//2, reservada/1.
:- multifile plan/3, seleccion/3, realizar/6, oracion/2.

% Ejercicio 4: sinónimos de los verbos.
verbo(listar, "enumera").
verbo(copiar, "duplica").
verbo(mover, "traslada").

% Ejercicio 5: archivos anteriores o posteriores a una fecha.

objeto(fechados(C, Rel, F), pl) -->
    determinante(G, pl),
    sustantivo(archivo, G, pl),
    relacion_temporal(Rel),
    [Texto],
    { string_codes(Texto, Cs),
      phrase(fecha(fecha(A, M, D)), Cs),
      format_time(string(F), '%F', date(A, M, D)) },
    de_carpeta(C).

%!  relacion_temporal(?Rel)// is semidet.
%
%   «anteriores al» (antes) o «posteriores al» (despues).
relacion_temporal(antes) -->
    ["anteriores", "al"].
relacion_temporal(despues) -->
    ["posteriores", "al"].

seleccion(fechados(C, Rel, F), M, Rs) :-
    carpeta_existente(C, M),
    findall(R, ( member(archivo(R, _, FR), M),
                 en_carpeta(R, C, _),
                 comparar_fecha(Rel, FR, F) ),
            Rs),
    (   Rs == []
    ->  throw(rechazo(ninguno_fechado(C, Rel, F)))
    ;   true
    ).

%!  comparar_fecha(+Rel, +FR:string, +F:string) is semidet.
%
%   La fecha FR es anterior (antes) o posterior (despues) a F. Las dos
%   están en la forma AAAA-MM-DD, que se ordena como el texto.
comparar_fecha(antes, FR, F) :-
    FR @< F.
comparar_fecha(despues, FR, F) :-
    FR @> F.

oracion(rechazo(ninguno_fechado(C, Rel, F)), T) :-
    nombre_de_carpeta(C, L),
    (   Rel == antes
    ->  Palabra = "anterior"
    ;   Palabra = "posterior"
    ),
    format(string(T), "En ~s no hay ningún archivo ~s al ~s.",
           [L, Palabra, F]).

% Ejercicio 6: ejemplos de órdenes generados por la gramática.

%!  ejemplos_de_ordenes(-Textos:list(string)) is det.
%
%   Textos son las oraciones que la gramática genera para una orden de
%   cada clase.
ejemplos_de_ordenes(Textos) :-
    findall(T,
            ( member(O, [ listar(".", todos),
                          contar("informes", patron("*.txt")),
                          copiar(archivo("notas.txt"), a("respaldo")),
                          mover(archivos(".", patron("*.tmp")), a("viejos")),
                          borrar(archivo("borrador.tmp")),
                          tamano(archivos("informes", todos)),
                          fecha(archivo("notas.txt")),
                          buscar(patron("*.pl")),
                          ejecutar(archivo("hola.pl")),
                          salir ]),
              once(phrase(orden(O), Ps)),
              atomic_list_concat(Ps, ' ', A),
              atom_string(A, T) ),
            Textos).

% Ejercicio 8: la cantidad total de archivos.

reservada("total").

pedido(contar_todo) -->
    ["cuantos"],
    sustantivo(archivo, _, pl),
    ["hay", "en", "total"].

plan(contar_todo, M, [informar(total(N))]) :-
    aggregate_all(count, member(archivo(_, _, _), M), N).

oracion(total(0), "No hay ningún archivo.") :-
    !.
oracion(total(N), T) :-
    cantidad(N, archivo, m, Q),
    format(string(T), "Hay ~s en total.", [Q]).

% Ejercicio 9: el archivo más grande de una carpeta.

pedido(mayor(C)) -->
    ["cual", "es"],
    determinante(G, sg),
    sustantivo(archivo, G, sg),
    ["mas", "grande"],
    de_carpeta(C).

plan(mayor(C), M, [informar(mayor(R, B))]) :-
    seleccion(archivos(C, todos), M, Rs),
    findall(B0-R0, ( member(R0, Rs),
                     memberchk(archivo(R0, B0, _), M) ),
            Pares),
    max_member(B-R, Pares).

oracion(mayor(R, B), T) :-
    cantidad(B, byte, m, Q),
    format(string(T), "El archivo más grande es ~s, con ~s.", [R, Q]).

% Ejercicio 10: varias órdenes unidas por «y».

reservada("y").

%!  entender_varias(+Texto:string, -Ordenes:list) is semidet.
%
%   Ordenes son los significados de las órdenes de Texto, unidas por «y».
entender_varias(Texto, Ordenes) :-
    palabras(Texto, Palabras),
    once(phrase(varias(Ordenes), Palabras)).

%!  varias(?Ordenes:list)// is nondet.
%
%   Una o más órdenes separadas por «y».
varias([O|Os]) -->
    pedido(O),
    (   ["y"]
    ->  varias(Os)
    ;   { Os = [] }
    ).

%!  planificar_varias(+Ordenes:list, +Modelo:list, -Plan:list) is det.
%
%   Plan cumple las Ordenes en sucesión: cada una se planifica sobre el
%   modelo que deja el plan de la anterior. El primer rechazo detiene el
%   plan.
planificar_varias([], _, []).
planificar_varias([O|Os], M0, Plan) :-
    planificar(O, M0, P),
    (   memberchk(rechazo(_), P)
    ->  Plan = P
    ;   aplicar(P, M0, M1),
        planificar_varias(Os, M1, Resto),
        append(P, Resto, Plan)
    ).

%!  planificar_varias_ejemplo(+Ordenes:list, -Plan:list) is det.
%
%   Plan cumple las Ordenes en sucesión sobre el modelo de ejemplo.
planificar_varias_ejemplo(Ordenes, Plan) :-
    modelo_ejemplo(M),
    planificar_varias(Ordenes, M, Plan).

%!  aplicar(+Plan:list, +Modelo0:list, -Modelo:list) is det.
%
%   Modelo es Modelo0 después de realizar Plan, suponiendo que cada
%   borrado se confirma. Una copia conserva la fecha del original.
aplicar(Plan, M0, M) :-
    foldl(aplicar_accion, Plan, M0, M1),
    msort(M1, M).

%!  aplicar_accion(+Accion, +Modelo0:list, -Modelo:list) is det.
%
%   Modelo es Modelo0 después de Accion.
aplicar_accion(Accion, M0, M) :-
    (   Accion = copiar(R, D)
    ->  memberchk(archivo(R, B, F), M0),
        M = [archivo(D, B, F)|M0]
    ;   Accion = mover(R, D)
    ->  selectchk(archivo(R, B, F), M0, M1),
        M = [archivo(D, B, F)|M1]
    ;   Accion = borrar(R)
    ->  selectchk(archivo(R, _, _), M0, M)
    ;   M = M0
    ).

% Ejercicio 11: nombres con mayúsculas.

%!  palabras_con_mayusculas(+Texto:string, -Palabras:list(string)) is det.
%
%   Como palabras/2, pero las palabras con un punto interior, una barra o
%   un dígito se conservan tal como se escribieron: son nombres.
palabras_con_mayusculas(Texto, Palabras) :-
    split_string(Texto, " ", " ¿?¡!,;", Partes0),
    exclude(==(""), Partes0, Partes1),
    ultima_sin_punto(Partes1, Partes),
    maplist(palabra_conservada, Partes, Palabras0),
    exclude(==(""), Palabras0, Palabras).

%!  palabra_conservada(+P0:string, -P:string) is det.
%
%   P es P0 si es un nombre, y si no, P0 en minúsculas y sin tildes.
palabra_conservada(P1, P) :-
    (   parece_nombre(P1)
    ->  P = P1
    ;   palabras(P1, [P])
    ->  true
    ;   P = ""
    ).

%!  parece_nombre(+P:string) is semidet.
%
%   P tiene un punto, una barra o un dígito.
parece_nombre(P) :-
    string_chars(P, Cs),
    member(C, Cs),
    (   memberchk(C, ['.', '/'])
    ;   char_type(C, digit)
    ),
    !.

%!  entender_con_mayusculas(+Texto:string, -Orden) is semidet.
%
%   Como entender/2, con las palabras de palabras_con_mayusculas/2.
entender_con_mayusculas(Texto, Orden) :-
    palabras_con_mayusculas(Texto, Palabras),
    once(phrase(orden(Orden), Palabras)).

% Ejercicio 12: programas con argumentos.

reservada("con").

pedido(ejecutar_con(archivo(R), Args)) -->
    verbo(ejecutar),
    objeto(archivo(R), sg),
    ["con"],
    argumentos(Args).

%!  argumentos(?Args:list(string))// is nondet.
%
%   Uno o más argumentos: nombres, números o palabras sueltas.
argumentos([A|As]) -->
    [A],
    (   argumentos(As)
    ;   { As = [] }
    ).

plan(ejecutar_con(archivo(R), Args), M, [ejecutar_con(R, Args)]) :-
    plan(ejecutar(archivo(R)), M, _).

realizar(real, Raiz, _, _, ejecutar_con(R, Args), salida(R, Estado, Lineas)) :-
    !,
    ruta_real(Raiz, R, Abs),
    salida_de(swipl, ['-t', halt, Abs|Args], Texto, Estado),
    split_string(Texto, "\n", "\r", Lineas0),
    exclude(==(""), Lineas0, Lineas).

oracion(simulada(ejecutar_con(R, Args)), T) :-
    atomic_list_concat(Args, ' ', A),
    format(string(T), "Se ejecutaría ~s con los argumentos ~w.", [R, A]).
