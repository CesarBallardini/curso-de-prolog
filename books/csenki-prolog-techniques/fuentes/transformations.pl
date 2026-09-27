
%---------------------------------%
% CASE STUDY: AUTOMATED UNFOLDING %
%---------------------------------%

%----------------------------------------------------------------%
% Breaking up and putting together conjunctions of terms: conj/2 %
%----------------------------------------------------------------%

% conj(+Term,-List): List is unified with the list of conjuncts of Term ...

conj(Term,List) :- var(List),
                   nonvar(Term),
                   conjuncts(Term,[],R),
                   reverse(R,List).

% conj(-Term,+List): Term is unified with the conjunction of terms in List (right associative) ...

conj(Term,List) :- nonvar(List),
                   var(Term),
                   reverse(List,[H|T]),
                   conjunction(T,H,Term).

% conj(+Term,+List): succeeds if Term is ** identical to ** the conjunction of the terms in List ...

conj(Term,List) :- nonvar(Term),
                   nonvar(List),
                   conj(T,List),
                   Term == T.

% auxiliary predicate using accumulator: conjuncts(+Term,+Acc,-List) ...

conjuncts(Term,L,[Term|L]) :- not(functor(Term,',',2)).
conjuncts(Term,Acc,L) :- functor(Term,',',2),
                         arg(1,Term,Term1),
                         arg(2,Term,Term2),
                         conjuncts(Term2,[Term1|Acc],L).

% auxiliary predicate using accumulator: conjunction(+List,+Acc,-Term) ...

conjunction([],Conj,Conj).
conjunction([H|T],Acc,Conj) :- conjunction(T,(H,Acc),Conj).

%---------------------------------------------------------%
% Breaking up a list at a specified position: splitlist/5 %
%---------------------------------------------------------%

% splitlist(+Index,+List,-Front,-Entry,-Behind):
% Entry is unified with the Index-th entry of List
% Front is unified with the list comprising the entries in front of the Index-th entry
% Behind is unified with the list comprising the entries behind the Index-th entry

splitlist(Index,List,Front,Entry,Behind) :-
   splitlist(Index,List,[],Front,Entry,Behind).

splitlist(1,[H|T],Acc,Front,H,T) :- reverse(Acc,Front).
splitlist(Index,[H|T],Acc,Front,Entry,Behind) :-
   NewIndex is Index - 1,
   splitlist(NewIndex,T,[H|Acc],Front,Entry,Behind).

%----------------------------------------------------------------%
% Concatenating three lists: concat3(+Front,+Middle,+Back,-List) %
%----------------------------------------------------------------%

concat3(Front,Middle,Back,List) :- append(Front,Middle,L),
                                   append(L,Back,List).

%--------------------------------------------------------------%
% Elementary unfolding operation:                              %
%   elementary_unfolding(+Fun1/+Arity1,+I,+J,+Fun2/+Arity2,?K) %
%--------------------------------------------------------------%

elementary_unfolding(Fun1/Arity1,I,J,Fun2/Arity2,K) :-
   functor(Pred1,Fun1,Arity1),
   functor(Pred2,Fun2,Arity2),
   dynamic(Fun1/Arity1),
   nth_clause(Pred1,I,Ref1),
   clause(Head1,Body1,Ref1),
   conj(Body1,L1),
   splitlist(J,L1,Front1,Entry1,Behind1),
   nth_clause(Pred2,K,Ref2),
   clause(Head2,Body2,Ref2),
   conj(Body2,L2),
   Head2 = Entry1,
   concat3(Front1,L2,Behind1,L),
   conj(NewBody,L),
   assert(Head1 :- NewBody).

%---------------------------------------------------------------------------------%
% Remove the n-th clause of a predicate from the database: remove(+Fun/+Arity,+N) %
%---------------------------------------------------------------------------------%

remove(Fun/Arity,N) :- functor(Head,Fun,Arity),
                       nth_clause(Head,N,Ref),
                       erase(Ref),
                       report_removal(Fun/Arity,N).

report_removal(Fun/Arity,N) :- nl, write('Clause removed:'), nl,
                               write('Clause '),
                               write(N),
                               write(' of predicate '),
                               write(Fun),
                               write('/'),
                               write(Arity), nl.

%--------------------------------------------------------------------------%
% Perform all elementary unfolding operations: all_euos(+Fun/+Arity,+I,+J) %
%--------------------------------------------------------------------------%

all_euos(Fun/Arity,I,J) :-
   dynamic(unfolded/1),
   retractall(unfolded(_)),
   assert(unfolded([])),
   current_predicate(Fun2,Head2),                   %--
   not(predicate_property(Head2,built_in)),         % exclude other than
   not(predicate_property(Head2,imported_from(_))), % your own predicates
   not(predicate_property(Head2,foreign)),          %--
   functor(Head2,Fun2,Arity2),
   elementary_unfolding(Fun/Arity,I,J,Fun2/Arity2,K),
   unfolded(L),
   retractall(unfolded(_)),
   assert(unfolded([[Fun2/Arity2,K]|L])),
   fail.
all_euos(_/_,_,_) :-
   unfolded([_|_]), nl,
   write('Clause(s) used:'), nl,
   unfolded(R),
   reverse(R,L),
   report_euos(L).

report_euos([]).
report_euos([[Fun/Arity,K]|T]) :- write('Clause '),
                                  write(K),
                                  write(' of predicate '),
                                  write(Fun),
                                  write('/'),
                                  write(Arity), nl,
                                  report_euos(T).

%--------------------------------------------------------%
% Complete one step unfolding: unfold(+Fun/+Arity,+I,+J) %
%--------------------------------------------------------%

unfold(Fun/Arity,I,J) :- all_euos(Fun/Arity,I,J),
                         listing(Fun/Arity),
                         remove(Fun/Arity,I),
                         listing(Fun/Arity).

%--------------------------------------------%
% Predicates for testing automated unfolding %
%--------------------------------------------%

a(U,U,U,U,U).
a(U,V,U,V,U) :- m(U,V).
a(U,V,W,V,U) :- n(U,n(V,W)), b(U,V), e(V,U).
a(U,V,W,X,Y) :- b(U,V), c(V,W), d(W,X), e(X,Y).

c(A,B) :- f(A), m(A,B).
c(A,B) :- A is B + 1.
c(A,A) :- f(A), g(A).

%------------------------------------------------------------------------------------------%
% Rearranging clauses of a predicate in the database: clause_arrange(+Fun/+Arity,+IntList) %
%------------------------------------------------------------------------------------------%

clause_arrange(Fun/Arity,IntList) :-
   all_clauses(Fun/Arity,Clauses),
   arrange(IntList,Clauses,Permuted),
   dynamic(Fun/Arity),
   functor(Pred,Fun,Arity),
   retractall(Pred),
   assert_all(Permuted).

% Auxiliary predicates ...

% assert_all(+List): assert the clauses in List...

assert_all([]).
assert_all([H|T]) :- assert(H),
                     assert_all(T).

% all_clauses(+Fun/+Arity,-Clauses): collect all clauses uf Fun/Arity into the list Clauses ...

all_clauses(Fun/Arity,Clauses) :-
   functor(Pred,Fun,Arity),
   findall((Head :- Body),(nth_clause(Pred,_,Ref),clause(Head,Body,Ref)), Clauses).

% arrange(+IntList,+InList,-OutList): rearranging entries of a list ...

arrange(IntList,InList,OutList) :-
   findall(E,(member(M,IntList), nth1(M,InList,E)),OutList).


%----------------------------------------------------------------------%
% Complete one step unfolding: cosu(+Fun/+Arity,+ClauseNr,+GoalNr)     %
%                                                                      %
% Places the new clauses to the position of the clause to be replaced. %
%----------------------------------------------------------------------%

cosu(Fun/Arity,I,J) :-
   functor(Pred,Fun,Arity),
   predicate_property(Pred,number_of_clauses(C1)),
   unfold(Fun/Arity,I,J),
   predicate_property(Pred,number_of_clauses(C2)),
   A1 is 1,
   B1 is I - 1,
   A2 is I,
   B2 is C1 - 1,
   A3 is C1,
   B3 is C2,
   from_to(A1,B1,L1),
   from_to(A2,B2,L2),
   from_to(A3,B3,L3),
   concat3(L1,L3,L2,L),
   clause_arrange(Fun/Arity,L).

from_to(Low,High,List) :- bagof(N,between(Low,High,N),List), !.
from_to(_,_,[]).
