female(ann).
female(cathy).
female(lisa).
female(lora).
female(mary).
female(rose).
female(susan).

male(charles).
male(david).
male(fred).
male(george).
male(ian).
male(joe).
male(john).
male(paul).
male(peter).

mother_of(john,ann).
mother_of(mary,ann).
mother_of(cathy,ann).
mother_of(peter,mary).
mother_of(paul,mary).
mother_of(charles,cathy).
mother_of(susan,cathy).
mother_of(george,lora).
mother_of(ian,lora).
mother_of(lisa,rose).

father_of(john,fred).
father_of(mary,fred).
father_of(cathy,fred).
father_of(peter,joe).
father_of(paul,joe).
father_of(charles,david).
father_of(susan,david).
father_of(george,paul).
father_of(ian,paul).
father_of(lisa,charles).

parents(Child,Mother,Father) :-
   mother_of(Child,Mother),
   father_of(Child,Father).

sisters(X,Y) :- female(X), female(Y),
                X \= Y,
                parents(X,M,F),
                parents(Y,M,F).

is_grandfather(G) :- father_of(X,G),
                     (mother_of(_,X); father_of(_,X)).

ancestor_of(P,A) :- mother_of(P,A).
ancestor_of(P,A) :- father_of(P,A).
ancestor_of(P,A) :- mother_of(P,M), ancestor_of(M,A).
ancestor_of(P,A) :- father_of(P,M), ancestor_of(M,A).

ancestors_of(P,As) :- bagof(A,ancestor_of(P,A),As).

descendants_of(P,Ds) :- bagof(D,ancestor_of(D,P),Ds).

is_grandmother(G) :- mother_of(X,G),
                     (mother_of(_,X); father_of(_,X)).

% inferior implementation of grandparents/0 returning multiple instances ...
% grandparents :- (is_grandmother(G);is_grandfather(G)), write(G), nl, fail.
% grandparents.

grandparents :- setof(G,(is_grandmother(G); is_grandfather(G)),Gs),
                writelist(Gs).

writelist([]).
writelist([H|T]) :- write(H), write(', '), writelist(T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---   Postgraduate Coursework February 2004 ---%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Exercise 1:

person(P) :- male(P).
person(P) :- female(P).

% Exercise 2:

women(Ps) :- bagof(P,female(P),Ps).

% Exercise 3:

ladies :- bagof(P,female(P),Ps),
          write('There are '),
          length(Ps,L),
          write(L),
          write(' women in the database.\n').

% Exercise 4:

grandmother_of(X,G) :- mother_of(X,Y), mother_of(Y,G). % maternal grandmother
grandmother_of(X,G) :- father_of(X,Y), mother_of(Y,G). % paternal grandmother

grandfather_of(X,G) :- mother_of(X,Y), father_of(Y,G). % maternal grandfather
grandfather_of(X,G) :- father_of(X,Y), father_of(Y,G). % paternal grandfather

cousin_of(X,Y) :- grandmother_of(X,GM), grandmother_of(Y,GM),
                  grandfather_of(X,GF), grandfather_of(Y,GF),
                  not((parents(X,M,F),parents(Y,M,F))).

cousins_of(P,Cs) :- bagof(C,cousin_of(P,C),Cs).

% Exercise 5:

is_front([],_).
is_front([H|T1],[H|T2]) :- is_front(T1,T2).

sublist(S,L) :- is_front(S,L).
sublist(S,[_|T]) :- sublist(S,T).
