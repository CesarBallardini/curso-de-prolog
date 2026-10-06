:- encoding(utf8).

% Capítulo 53 - Versión 5: reglas en notación de dos niveles.
%
% Koskenniemi escribe cada regla como un par y su contexto, y KIMMO las
% compila en transductores. Aquí una regla es
%
%   regla_dos_niveles(Nombre, Par, Operador, Izquierda, Derechas)
%
% con el Par Subyacente:Escrita, el Operador '=>' (el par solo aparece en
% el contexto), '<=' (en el contexto, la letra subyacente del par solo se
% escribe así) o '<=>' (las dos cosas), el contexto izquierdo como una
% lista de clases y los contextos derechos como una lista de
% alternativas, cada una una lista de clases. compilar/5 traduce la regla
% a la lista de patrones prohibidos de la versión 3, y la registra como
% una regla más: la versión 4 la aplica en paralelo con las otras.
%
% La regla nasal escribe la N del prefijo in- como m ante el límite y una
% p o una b: in+posible es imposible. nasal_n solo admite la N escrita n
% ante el límite: la N es la del prefijo, y no aparece en otro lugar.
%
% solo-local: carga módulos.
%
%?- regla(nasal, Ps).
%?- transducir(paralelo([nasal]), [i, 'N', +, p, o, s, i, b, l, e], E).

:- ensure_loaded(paralelo).

% La N del prefijo in- es una letra subyacente nueva, con dos escrituras.
dos_niveles:par(['N']:[m]).
dos_niveles:par(['N']:[n]).

% regla_dos_niveles(Nombre, Par, Operador, Izquierda, Derechas): una regla
% en la notación de dos niveles. Otros archivos pueden agregar reglas.
:- multifile regla_dos_niveles/5.

regla_dos_niveles(nasal, ['N']:[m], '<=>', [],
                  [[limite, o(par([p]:[p]), par([b]:[b]))]]).
regla_dos_niveles(nasal_n, ['N']:[n], '=>', [], [[limite]]).
regla_dos_niveles(z_k, [z]:[c], '<=>', [],
                  [[limite, frontal], [frontal]]).

% Las reglas compiladas son reglas de la versión 3. z_k repite la regla
% z en esta notación, y solo sirve para compararlas; no se registra.
dos_niveles:regla(Nombre, Patrones) :-
    member(Nombre, [nasal, nasal_n]),
    regla_dos_niveles(Nombre, Par, Op, Izquierda, Derechas),
    compilar(Par, Op, Izquierda, Derechas, Patrones).

%!  compilar(+Par, +Op, +Izquierda:list, +Derechas:list, -Patrones:list)
%!      is semidet.
%
%   Patrones son los patrones prohibidos de la regla Par Op Izquierda _
%   Derechas. '=>' prohíbe el Par fuera del contexto; '<=' prohíbe, en el
%   contexto, otro par con la misma letra subyacente; '<=>' junta los dos.
compilar(Par, Op, Izquierda, Derechas, Patrones) :-
    (   Op == '=>'
    ->  restriccion(Par, Izquierda, Derechas, Patrones)
    ;   Op == '<='
    ->  coercion(Par, Izquierda, Derechas, Patrones)
    ;   Op == '<=>'
    ->  restriccion(Par, Izquierda, Derechas, Ps1),
        coercion(Par, Izquierda, Derechas, Ps2),
        append(Ps1, Ps2, Patrones)
    ).

%!  restriccion(+Par, +Izquierda:list, +Derechas:list, -Patrones:list)
%!      is det.
%
%   Patrones prohíben el Par cuando no lo precede Izquierda o cuando no lo
%   sigue ninguna de las Derechas.
restriccion(Par, Izquierda, Derechas, Patrones) :-
    reverse(Izquierda, Inversa),
    a_la_izquierda(Inversa, [par(Par)], Ps1),
    (   Derechas == []
    ->  Ps2 = []
    ;   a_la_derecha(Derechas, [par(Par)], Ps2)
    ),
    append(Ps1, Ps2, Patrones).

%!  a_la_izquierda(+Inversa:list, +Visto:list, -Patrones:list) is det.
%
%   Patrones prohíben que delante de Visto falte el contexto izquierdo,
%   dado al revés en Inversa.
a_la_izquierda([], _, []).
a_la_izquierda([C|Cs], Visto, [[no(C)|Visto]-medio, Visto-inicio|Ps]) :-
    a_la_izquierda(Cs, [C|Visto], Ps).

%!  a_la_derecha(+Derechas:list, +Visto:list, -Patrones:list) is det.
%
%   Patrones prohíben que después de Visto no siga ninguna de las
%   Derechas. Las alternativas que empiezan con la misma clase se
%   recorren juntas, como en un árbol de letras.
a_la_derecha(Derechas, Visto, Patrones) :-
    (   memberchk([], Derechas)
    ->  Patrones = []
    ;   primeras(Derechas, Clases),
        disyuncion(Clases, O),
        append(Visto, [no(O)], P1),
        findall(Ps,
                ( member(C, Clases),
                  findall(Resto, member([C|Resto], Derechas), Restos),
                  append(Visto, [C], Visto1),
                  a_la_derecha(Restos, Visto1, Ps) ),
                Pss),
        append(Pss, Ps2),
        Patrones = [P1-medio, Visto-final|Ps2]
    ).

%!  primeras(+Derechas:list, -Clases:list) is det.
%
%   Clases son las primeras clases de las Derechas, sin repetir, en su
%   orden.
primeras(Derechas, Clases) :-
    findall(C, member([C|_], Derechas), Cs),
    list_to_set(Cs, Clases).

%!  disyuncion(+Clases:list, -O) is det.
%
%   O es la clase o/2 que reúne las Clases, o la única que hay.
disyuncion([C|Cs], O) :-
    disyuncion(Cs, C, O).

%!  disyuncion(+Clases:list, +C, -O) is det.
%
%   O reúne C con las Clases que la siguen.
disyuncion([], C, C).
disyuncion([C2|Cs], C1, o(C1, O)) :-
    disyuncion(Cs, C2, O).

%!  coercion(+Par, +Izquierda:list, +Derechas:list, -Patrones:list)
%!      is det.
%
%   Patrones prohíben, en cada contexto Izquierda _ Derecha, los otros
%   pares con la misma letra subyacente que Par.
coercion(Par, Izquierda, Derechas, Patrones) :-
    Par = Subyacente:_,
    findall(par(Otro),
            ( dos_niveles:par(Otro), Otro = Subyacente:_, Otro \== Par ),
            Otros),
    (   Otros == []
    ->  Patrones = []
    ;   disyuncion(Otros, O),
        findall(P-medio,
                ( member(Derecha, Derechas),
                  append([Izquierda, [O], Derecha], P) ),
                Patrones)
    ).
