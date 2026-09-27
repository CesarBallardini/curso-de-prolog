

action1(P) :- mystery(X,P),
             mystery(P,Y),
             assert(mystery(X,Y)),
             action2(P).

action2(P) :- retract(mystery(P,_)),
              retract(mystery(_,P)).
