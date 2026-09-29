:- encoding(utf8).

% Capítulo 55 - Guiones al estilo de McSAM: completar una historia.
%
% Una historia es una lista de sucesos, cada uno un término como
% ir(Quien, Desde, Hacia) o comer(Quien, Comida), con variables donde la
% historia no dice nada. Un guion es la lista de todos los sucesos de una
% situación conocida, con variables para los papeles, y un valor por
% omisión para cada papel. entender/3 elige el guion por una palabra de la
% historia que lo activa, empareja los sucesos de la historia con los del
% guion, en orden, y completa los papeles que la historia no nombra. La
% historia entendida se cuenta en castellano con una gramática.
%
%?- historia(leones, H), entender(H, Guion, Entendida).

:- multifile
    historia/2,
    activa/2,
    guion/3,
    oracion//1,
    sustantivo/4.

% historia(Nombre, Sucesos): una historia para entender.
historia(leones, [ ir(juan, _, leones),
                   comer(_, hamburguesa),
                   ir(_, _, _) ]).
historia(colectivo, [ subir(ana, colectivo, _),
                      bajar(_, _, plaza) ]).
historia(mozo, [ traer(mozo, empanadas, luis) ]).
historia(sin_guion, [ comer(juan, hamburguesa) ]).

% activa(Palabra, Guion): una historia que nombra Palabra trata de Guion.
activa(leones, restaurante).
activa(mozo, restaurante).
activa(colectivo, colectivo).
activa(chofer, colectivo).

%!  guion(?Nombre, -Sucesos:list, -Papeles:list) is nondet.
%
%   Sucesos son los sucesos del guion Nombre, en orden, y Papeles los
%   pares Papel-Omision, donde Papel es una variable de los sucesos y
%   Omision el valor que toma si la historia no lo nombra.
guion(restaurante,
      [ ir(Cliente, Antes, Local),
        sentarse(Cliente, Mesa),
        pedir(Cliente, Comida, Mozo),
        traer(Mozo, Comida, Cliente),
        comer(Cliente, Comida),
        pagar(Cliente, Cuenta, Mozo),
        ir(Cliente, Local, Despues)
      ],
      [ Cliente-cliente, Antes-casa, Local-restaurante, Mesa-mesa,
        Comida-comida, Mozo-mozo, Cuenta-cuenta, Despues-otro_lugar ]).
guion(colectivo,
      [ ir(Pasajero, Antes, Parada),
        subir(Pasajero, Colectivo, Parada),
        pagar(Pasajero, Boleto, Chofer),
        viajar(Pasajero, Colectivo, Destino),
        bajar(Pasajero, Colectivo, Destino)
      ],
      [ Pasajero-pasajero, Antes-casa, Parada-parada,
        Colectivo-colectivo, Boleto-boleto, Chofer-chofer,
        Destino-destino ]).

%!  entender(+Historia:list, -Nombre, -Entendida:list) is nondet.
%
%   Entendida son los sucesos del guion Nombre, activado por una palabra
%   de Historia, con los sucesos de Historia emparejados en orden y los
%   papeles que Historia no nombra completados con su valor por omisión.
entender(Historia, Nombre, Entendida) :-
    palabra_de(Historia, Palabra),
    activa(Palabra, Nombre),
    guion(Nombre, Entendida, Papeles),
    subsucesion(Historia, Entendida),
    maplist(por_omision, Papeles).

%!  palabra_de(+Historia:list, -Palabra) is nondet.
%
%   Palabra es un argumento instanciado de un suceso de Historia.
palabra_de(Historia, Palabra) :-
    member(Suceso, Historia),
    arg(_, Suceso, Palabra),
    nonvar(Palabra).

%!  subsucesion(?Historia:list, ?Guion:list) is nondet.
%
%   Los sucesos de Historia unifican, en el mismo orden, con algunos de los
%   sucesos de Guion.
subsucesion([], _).
subsucesion([S|Ss], [S|Gs]) :-
    subsucesion(Ss, Gs).
subsucesion([S|Ss], [_|Gs]) :-
    subsucesion([S|Ss], Gs).

%!  por_omision(+Par) is det.
%
%   Si el papel de Par = Papel-Omision sigue libre, queda ligado a Omision.
por_omision(Papel-Omision) :-
    (   var(Papel)
    ->  Papel = Omision
    ;   true
    ).

%!  contar(+Sucesos:list, -Texto:string) is det.
%
%   Texto cuenta los Sucesos en castellano, una oración por suceso.
contar(Sucesos, Texto) :-
    phrase(oraciones(Sucesos), Codigos),
    string_codes(Texto, Codigos).

%!  oraciones(+Sucesos:list)// is det.
%
%   Las oraciones de los Sucesos, separadas por un blanco.
oraciones([S|Ss]) -->
    oracion(S),
    otras_oraciones(Ss).

%!  otras_oraciones(+Sucesos:list)// is det.
%
%   Las oraciones de los Sucesos, cada una precedida por un blanco.
otras_oraciones([]) -->
    [].
otras_oraciones([S|Ss]) -->
    " ",
    oracion(S),
    otras_oraciones(Ss).

%!  oracion(+Suceso)// is det.
%
%   La oración que cuenta Suceso, en pasado.
oracion(ir(Q, D, H)) -->
    sujeto(Q), " fue ", desde(D), " ", hacia(H), ".".
oracion(sentarse(Q, M)) -->
    sujeto(Q), " se sentó a ", un(M), ".".
oracion(pedir(Q, C, M)) -->
    sujeto(Q), " le pidió ", un(C), " ", al(M), ".".
oracion(traer(M, C, Q)) -->
    sujeto(M), " le trajo ", un(C), " ", al(Q), ".".
oracion(comer(Q, C)) -->
    sujeto(Q), " comió ", un(C), ".".
oracion(pagar(Q, C, M)) -->
    sujeto(Q), " le pagó ", el(C), " ", al(M), ".".
oracion(subir(Q, C, P)) -->
    sujeto(Q), " subió ", al(C), " en ", lugar(P), ".".
oracion(viajar(Q, C, D)) -->
    sujeto(Q), " viajó en ", el(C), " hasta ", lugar(D), ".".
oracion(bajar(Q, C, P)) -->
    sujeto(Q), " bajó ", del(C), " en ", lugar(P), ".".

% sustantivo(X, G, Texto, Plural): X es un sustantivo común de género G,
% que se escribe Texto; Plural es si o no.
sustantivo(cliente, m, "cliente", no).
sustantivo(pasajero, m, "pasajero", no).
sustantivo(mozo, m, "mozo", no).
sustantivo(chofer, m, "chofer", no).
sustantivo(mesa, f, "mesa", no).
sustantivo(comida, f, "comida", no).
sustantivo(hamburguesa, f, "hamburguesa", no).
sustantivo(empanadas, f, "empanadas", si).
sustantivo(cuenta, f, "cuenta", no).
sustantivo(boleto, m, "boleto", no).
sustantivo(colectivo, m, "colectivo", no).
sustantivo(restaurante, m, "restaurante", no).
sustantivo(parada, f, "parada", no).
sustantivo(destino, m, "destino", no).

% lugar_fijo(X, Texto): el lugar X se nombra con Texto.
lugar_fijo(casa, "su casa").
lugar_fijo(otro_lugar, "otro lugar").

%!  sujeto(+X)// is det.
%
%   X como sujeto, con mayúscula inicial: El mozo, Juan.
sujeto(X) -->
    { phrase(el(X), [C0|Cs]),
      char_code(Minuscula, C0),
      upcase_atom(Minuscula, Mayuscula),
      char_code(Mayuscula, C) },
    [C],
    Cs.

%!  el(+X)// is det.
%
%   X con el artículo definido si es un sustantivo común, o su nombre
%   propio.
el(X) -->
    articulo(X, "el ", "la ", "los ", "las "),
    nombre(X).

%!  un(+X)// is det.
%
%   X con el artículo indefinido si es un sustantivo común; en plural, sin
%   artículo.
un(X) -->
    articulo(X, "un ", "una ", "", ""),
    nombre(X).

%!  al(+X)// is det.
%
%   X precedido de a y del artículo definido: al mozo, a la parada, a Juan.
al(X) -->
    (   { sustantivo(X, m, _, no) }
    ->  "al ",
        nombre(X)
    ;   "a ",
        el(X)
    ).

%!  del(+X)// is det.
%
%   X precedido de de y del artículo definido: del colectivo.
del(X) -->
    (   { sustantivo(X, m, _, no) }
    ->  "del ",
        nombre(X)
    ;   "de ",
        el(X)
    ).

%!  lugar(+X)// is det.
%
%   El lugar X: su casa, otro lugar, el restaurante o un nombre propio.
lugar(X) -->
    (   { lugar_fijo(X, Texto) }
    ->  texto(Texto)
    ;   el(X)
    ).

%!  desde(+X)// is det.
%
%   El lugar X precedido de de: de su casa, del restaurante.
desde(X) -->
    (   { lugar_fijo(X, Texto) }
    ->  "de ",
        texto(Texto)
    ;   del(X)
    ).

%!  hacia(+X)// is det.
%
%   El lugar X precedido de a: a otro lugar, al restaurante.
hacia(X) -->
    (   { lugar_fijo(X, Texto) }
    ->  "a ",
        texto(Texto)
    ;   al(X)
    ).

%!  articulo(+X, +Ms, +Fs, +Mp, +Fp)// is det.
%
%   El artículo de X según su género y número, elegido entre Ms, Fs, Mp y
%   Fp; ninguno si X es un nombre propio.
articulo(X, Ms, Fs, Mp, Fp) -->
    (   { sustantivo(X, G, _, P) }
    ->  { once(articulo_de(G, P, [Ms, Fs, Mp, Fp], A)) },
        texto(A)
    ;   []
    ).

%!  articulo_de(+G, +P, +Articulos:list, -A) is det.
%
%   A es el artículo de Articulos que corresponde al género G y al plural P.
articulo_de(m, no, [A, _, _, _], A).
articulo_de(f, no, [_, A, _, _], A).
articulo_de(m, si, [_, _, A, _], A).
articulo_de(f, si, [_, _, _, A], A).

%!  nombre(+X)// is det.
%
%   El texto de X: el de un sustantivo común, o el átomo con mayúscula
%   inicial si es un nombre propio.
nombre(X) -->
    (   { sustantivo(X, _, Texto, _) }
    ->  texto(Texto)
    ;   { atom_codes(X, [C0|Cs]),
          char_code(Minuscula, C0),
          upcase_atom(Minuscula, Mayuscula),
          char_code(Mayuscula, C) },
        [C],
        Cs
    ).

%!  texto(+T:string)// is det.
%
%   Los códigos del texto T.
texto(T) -->
    { string_codes(T, Cs) },
    Cs.
