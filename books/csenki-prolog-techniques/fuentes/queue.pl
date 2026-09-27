:- dynamic(behind/2).

behind(lisa, george).  behind(george, clara).  behind(clara, adam).
behind(adam, susan).   behind(susan, peter).

customers :- first(F), write(F), nl, behind(_,P), write(P), nl, fail.

first(Person) :- behind(Person,_), not(behind(_,Person)).

swap_neighbours(P1,P2) :-
   behind(P0,P1),          % P1 is not at the head of the queue
   behind(P2,P3),          % P2 is not the last in the queue
   behind(P1,P2),          % P2 is behind P1
   retract(behind(P0,P1)),
   retract(behind(P1,P2)),
   retract(behind(P2,P3)),
   assert(behind(P0,P2)),
   assert(behind(P2,P1)),
   assert(behind(P1,P3)).

swap_neighbours(P1,P2) :- not(behind(_,P1)),      % P1 is at the head of the queue
                          behind(P2,P3),          % P2 is not the last in the queue
                          behind(P1,P2),          % P2 is behind P1
                          retract(behind(P1,P2)),
                          retract(behind(P2,P3)),
                          assert(behind(P2,P1)),
                          assert(behind(P1,P3)).

swap_neighbours(P1,P2) :-
   behind(P0,P1),          % P1 is not at the head of the queue
   not(behind(P2,_)),      % P2 is the last in the queue
   behind(P1,P2),          % P2 is behind P1
   retract(behind(P0,P1)),
   retract(behind(P1,P2)),
   assert(behind(P0,P2)),
   assert(behind(P2,P1)).

swap_neighbours(P1,P2) :-
   not(behind(_,P1)),      % P1 is at the head of the queue
   not(behind(P2,_)),      % P2 is the last in the queue
   behind(P1,P2),          % P2 is behind P1
   retract(behind(P1,P2)),
   assert(behind(P2,P1)).

to_front(P) :- behind(P,_),              % P is not the last in the queue
               not(behind(_,P)).         % P is the first in the queue
to_front(P) :- behind(Other,P),          % P is not the first in the queue
               swap_neighbours(Other,P), % move P one place forward
               to_front(P).              % move P to the front of the queue

before(P,B) :- behind(B,P), first(B), !.
before(P,B) :- behind(B,P).
before(P,B) :- behind(P1,P), before(P1,B).

after(P,A) :- behind(P,A), last(A), !.
after(P,A) :- behind(P,A).
after(P,A) :- behind(P,P1), after(P1,A).

last(Person) :- behind(_,Person), not(behind(Person,_)).
