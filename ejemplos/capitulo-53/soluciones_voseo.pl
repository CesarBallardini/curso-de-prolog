:- encoding(utf8).

% Capítulo 53 - Solución del ejercicio 7: el voseo.
%
% La persona vos tiene sus terminaciones en el presente (contás, comés,
% vivís) y usa las de tú en el pretérito (contaste). Como las del presente
% llevan tilde, el acento no cae en la raíz y la vocal no cambia: vos
% contás, vos pensás, vos pedís. Ser e ir se listan.
%
% solo-local: carga módulos.
%
%?- forma(P, verbo("contar", presente, vos, singular)).
%?- forma("tenés", A).

:- use_module(lexico).
:- ensure_loaded(paralelo).

lexico:terminacion(a, presente, vos, singular, "ás").
lexico:terminacion(e, presente, vos, singular, "és").
lexico:terminacion(i, presente, vos, singular, "ís").
lexico:terminacion(a, preterito, vos, singular, "aste").
lexico:terminacion(e, preterito, vos, singular, "iste").
lexico:terminacion(i, preterito, vos, singular, "iste").
lexico:terminacion(fuerte, preterito, vos, singular, "iste").

lexico:irregular("ser", presente, vos, singular, "sos").
lexico:irregular("ir", presente, vos, singular, "vas").
lexico:irregular("ser", preterito, vos, singular, "fuiste").
lexico:irregular("ir", preterito, vos, singular, "fuiste").
