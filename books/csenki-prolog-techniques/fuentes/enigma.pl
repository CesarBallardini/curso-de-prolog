% New Scientis puzzle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

var_matrix(Size,M) :- repeat(Size,Size,RowLengths),
                      maplist(var_list,RowLengths,M).

repeat(X,1,[X]) :- !.
repeat(X,N,[X|R]) :- NewN is N - 1,
                     repeat(X,NewN,R).

var_list(N,L) :- length(L,N). % var_list(+N,-L) list of variables of length N


%

transpose(M,T) :-  [H|_] = M,
                   length(H,NCols),
                   bagof(N,between(1,NCols,N),L),
                   maplist(col(M),L,T).

col(Matrix,N,Column) :- maplist(nth1(N),Matrix,Column).

%

write_matrix([]).
write_matrix([H|T]) :- write(H), nl, write_matrix(T).

% Permutations ...

% remove_one([H|T],H,T).
% remove_one([H|T],E,[H|L]) :- remove_one(T,E,L).

remove_one(List,E,Reduced) :- append(Front,[E|Back],List),
                              append(Front,Back,Reduced).
permute([X],[X]).
permute(L,[E|P]) :- remove_one(L,E,R), permute(R,P).

all_changed([X],[Y]) :- X \= Y.
all_changed([H1|T1],[H2|T2]) :- H1 \= H2, all_changed(T1,T2).

admissible(L,P) :- permute(L,P), all_changed(L,P).

%

list_permute([],_,[]).
list_permute([P1|Rest],L,[H|T]) :- nth1(P1,L,H),
                                   list_permute(Rest,L,T).

%

snd((_,X),X).

% count_var(+VarList,+Var,-Num) counts how many times Var occurs in Varlist ...
% retain_var(+Var,+VarList,-L) is an auxiliary ...

retain_var(_,[],[]).
retain_var(V,[H|T],[H|L]) :- H == V,
                             retain_var(V,T,L).
retain_var(V,[H|T],L) :- H \== V,
                         retain_var(V,T,L).

count_var(VarList,Var,Num) :- retain_var(Var,VarList,List),
                              length(List,Num).

total(IntPairs,Total) :- total(IntPairs,0,Total). % clause 0

total([],S,S).                                    % clause 1
total([(X,Y)|T],Acc,S) :- NewAcc is Acc + X * Y,  % clause 2
                          total(T,NewAcc,S).

%
zip([],_,[]) :- !.
zip(_,[],[]) :- !.
zip([H1|T1],[H2|T2],[(H1,H2)|T]) :- zip(T1,T2,T).

% from_to(?Lower,?Higher,?IList) (known from the chapter on Accumulators) ...

from_to(M,N,L) :- (var(L); is_list(L)),
                  integer(M),
                  integer(N),
                  M =< N,
                  from_to_acc(M,[N],L), !.
from_to(H,N,[H|T]) :- last(N,[H|T]), !, H =< N.

from_to_acc(H,[H|T],[H|T]).
from_to_acc(M,[H|T],L) :-
   NewHead is H - 1,
   !, from_to_acc(M,[NewHead,H|T],L).

% square(+Size,-M,?Total,-Frequencies,-Permutation) ...

square(Size,M,Total,Freq,Perm) :-
   var_matrix(Size,M),
   from_to(1,Size,One_to_Size),
   admissible(One_to_Size,Perm),
   list_permute(Perm,M,P),
   transpose(P,M),
   distinct(M),
   eval_matrix(M,Freq), % evaluate M and compute entry frequencies
   total(Freq,Total).   % compute Total

eval_matrix(Matrix,FreqSorted) :-
   flatten(Matrix,Entries),                        % Entries contains the variables in Matrix - each with its multiplicity
   setof(E,member(E,Entries),Set),                 % Set contains the variables in Matrix - sorted and each once only
   maplist(count_var(Entries),Set,Multiplicities), % Multiplicities is a list of variable multiplicities
   zip(Multiplicities,Set,Frequencies),            % Frequencies: list of pairs (Multiplicity,Variable) sorted by the 2nd entry
   sort(Frequencies,FreqSorted),                   % FreqSorted: list of pairs (Multiplicity,Variable) sorted by the 1st entry
   maplist(snd,FreqSorted,VarsSorted),             % VarsSorted: list of variable names in ascending order of frequencies
   length(VarsSorted,NVars),                       % NVars: number of variables in Matrix
   from_to(1,NVars,VarsSorted).                    % unify variables with the numbers 1, 2, ..., NVars --  Matrix is thereby unified with a matrix of integer entries
                                                   % thereby also the 2nd entry of each of the tuples in FreqSorted
                                                   % is unified with 1, ..., NVars

%distinct([_]).
%distinct([H1,H2|T]) :- H1 \== H2, distinct([H2|T]).

distinct([_]).
distinct([H|T]) :- notin(H,T), distinct(T).

notin(_,[]).
notin(E,[H|T]) :- E \== H, notin(E,T).

enigma0(Size) :-
   setof(Total,M^Freq^Perm^square(Size,M,Total,Freq,Perm),Totals),
   last(Max,Totals),
   square(Size,Board,Max,_,P),
   write('Maximum total = '), write(Max), nl,
   write('Column to Row permutation:\n'),
   from_to(1,Size,Indeces),
   write_imatrix([Indeces,P]), nl,
   write('Board:\n'),
   write_imatrix(Board).

%%%%%%%%%%%%%%%%%%%% Enhanced Version %%%%%%%%%%%%%%%%%%

%------------------------%
%                        %
% Partitions of a number %
%                        %
%------------------------%

% next_partition(+P,-NextP)

next_partition([(2,1)|T],[(1,2)|T]).                      % (5)-(6)

next_partition([(2,AlphaK)|T],[(1,2),(2,NewAlphaK)|T]) :- % (7)-(8)
   AlphaK > 1,                                            %
   NewAlphaK is AlphaK - 1.                               %

next_partition([(K,1)|T],[(1,1),(NewK,1)|T]) :- % (9)-(10)
   K > 2,                                       %
   NewK is K - 1.                               %

next_partition([(K,AlphaK)|T],[(1,1),(NewK,1),(K,NewAlphaK)|T]) :- % (11)-(12)
   K > 2,                                                          %
   AlphaK > 1,                                                     %
   NewK is K - 1,                                                  %
   NewAlphaK is AlphaK - 1.                                        %

next_partition([(1,Alpha1),(2,1)|T],[(1,NewAlpha)|T]) :- % (1)-(2)
   NewAlpha is Alpha1 + 2.                               %

next_partition([(1,Alpha1),(2,Alpha2)|T],[(1,NewAlpha1),(2,NewAlpha2)|T]) :- % (13)-(14)
   Alpha2 > 1,                                                               %
   NewAlpha1 is Alpha1 + 2,                                                  %
   NewAlpha2 is Alpha2 - 1.                                                  %

next_partition([(1,Alpha1),(L,1)|T],[(Rest,1),(NewL,Ratio)|T]) :- % (15)-(16)
   L > 2,                                                         %
   NewL is L - 1,                                                 %
   Rest is (Alpha1 + L) mod NewL,                                 %
   Rest > 0,                                                      %
   Ratio is (Alpha1 + L) // NewL.                                 %

next_partition([(1,Alpha1),(L,1)|T],[(NewL,Ratio)|T]) :- % (17)-(18)
   L > 2,                                                %
   NewL is L - 1,                                        %
   Rest is (Alpha1 + L) mod NewL,                        %
   Rest =:= 0,                                           %
   Ratio is (Alpha1 + L) // NewL.                        %

next_partition([(1,Alpha1),(L,AlphaL)|T],[(Rest,1),(NewL,Ratio),(L,NewAlphaL)|T]) :- % (3) to (4)
   L > 2,                                                                            %
   AlphaL > 1,                                                                       %
   NewL is L - 1,                                                                    %
   Rest is (Alpha1 + L) mod NewL,                                                    %
   Rest > 0,                                                                         %
   Ratio is (Alpha1 + L) // NewL,                                                    %
   NewAlphaL is AlphaL - 1.                                                          %

next_partition([(1,Alpha1),(L,AlphaL)|T],[(NewL,Ratio),(L,NewAlphaL)|T]) :- % (19)-(20)
   L > 2,                                                                   %
   AlphaL > 1,                                                              %
   NewL is L - 1,                                                           %
   Rest is (Alpha1 + L) mod NewL,                                           %
   Rest =:= 0,                                                              %
   Ratio is (Alpha1 + L) // NewL,                                           %
   NewAlphaL is AlphaL - 1.                                                 %

% all partitions of a number (not used but useful for testing next_partition/2) ...

partitions(N,Ps) :- partitions_acc([[(N,1)]],Ps).

partitions_acc([[(1,N)]|T],[[(1,N)]|T]).
partitions_acc([H|T],Ps) :- next_partition(H,P), partitions_acc([P,H|T],Ps).

% part(+P1,?P2) generating (on backtracking) all partitions starting
% from a particular partition P1
% Definition is modelled on that of int/2 in
% Exercise 6 in Ch. 'Exploratory Code Development' ...
% part/2 is NOT used if using generator/3 since ad_partition/2 then does not use part/2
part(P,P).
part(Last,Next) :- next_partition(Last,New), part(New,Next).

% partition_of(+N,?P) generates (on backtracking) all partitions of N ...

partition_of(N,P) :- part([(N,1)],P).

% ad_partition(+N,?P) generates (on backtracking) all admissible partitions of N
% (i.e. any of the corresponding permutations is without a 1-cycle) ...
% next definition is NOT used if using generator/3
% ad_partition(N,[(K,AlpaK)|T]) :- part([(N,1)],[(K,AlpaK)|T]), K =\= 1.

ad_partition(N,[(K,AlpaK)|T]) :- generator(next_partition,[(N,1)],[(K,AlpaK)|T]), K > 1.

%------------------------------%
%                              %
% Improved version of square/5 %
%                              %
%------------------------------%
% square2/5 returns one (and no more than one) admissible solution for
% each type of permutation

% rep_perm(+N,+Type,-Perm) returns a representative permutation of [1, ..., N],
% of a given Type. Use auxiliary predicate split/3 with accumulator argument ...

% split(+N,+Type,-List) returns a partition List of the list [1,...,N]
% according to Type

split(N,Type,S) :- from_to(1,N,L),
                   split(L,Type,[],S).

split([],[(_,0)],Acc,S) :- reverse(Acc,S), !. % clause 1
split(L,[(_,0)|T],Acc,S) :- split(L,T,Acc,S). % clause 2
split(L,[(K,AlphaK)|T],Acc,S) :-              % clause 3
   AlphaK >0,
   append(L1,L2,L),
   length(L1,K),
   NewAlphaK is AlphaK - 1,
   split(L2,[(K,NewAlphaK)|T],[L1|Acc],S).

rotate([H|T],L) :- append(T,[H],L).

rep_perm(N,Type,Perm) :- split(N,Type,S),
                         maplist(rotate,S,R),
                         flatten(R,Perm).

square2(Size,M,Total,Frequencies,Permutation) :-
   var_matrix(Size,M),
%  from_to(1,Size,One_to_Size),          % has been removed from square/5
%  admissible(One_to_Size,Perm),         % has been removed from square/5
   ad_partition(Size,Partition),         % to be added to square2/5
   rep_perm(Size,Partition,Permutation), % to be added to square2/5
   list_permute(Permutation,M,P),
   transpose(P,M),
   distinct(M),
   eval_matrix(M,Frequencies), % evaluate matrix M and compute entry frequencies
   total(Frequencies,Total).   % compute 'total'

%-------------------------%
%                         %
% Formatted matrix output %
%                         %
%-------------------------%

maximum([H|T],M) :- maximum(T,H,M). % max entry of a list

maximum([],Acc,Acc).
maximum([H|T],Acc,M) :- NewAcc is max(H,Acc), maximum(T,NewAcc,M).

largest(Matrix,Max) :- flatten(Matrix,F), % max absolute entry of a matrix
                       maplist(abs,F,A),
                       maximum(A,Max).

% ndigits(+N,-ND) number of digits of a decimal number ...

ndigits(N,ND) :- digits(N,D), length(D,ND).

digits(N,D) :- integer(N), digits(N,[],D). % from Chapter 'Exploratory Code Development'

digits(N,Acc,[N|Acc]) :- N < 10, !.
digits(N,Acc,D)       :- H is N mod 10,
                         NewN is N // 10,
                         digits(NewN,[H|Acc],D).
/*
% Another implementation of ndigits/2 ...

ndigits(N,ND) :- ndigits(N,1,ND).

ndigits(N,Acc,Acc) :- NewN is N // 10,
                      NewN =:= 0.
ndigits(N,Acc,ND) :- NewN is N // 10,
                    NewN > 0,
                    NewAcc is Acc + 1,
                    ndigits(NewN,NewAcc,ND).
*/

% write_ilist(+Width,+List) :-

write_ilist(Width, List) :-
   length(List,Length),
   int_to_atom(Width,WidthA),
   concat_atom(['%',WidthA,'r'],Atom),
   repeat(Atom,Length,Format1),
   append(Format1,[']'],Format2),
   concat_atom(['['|Format2],Format),
   writef(Format,List).

write_imatrix(_,[]).
write_imatrix(Width, [H|T]) :-
   write_ilist(Width, H), nl,
   write_imatrix(Width, T).

write_imatrix(M) :-
  largest(M,Max),
  ndigits(Max,ND),
  Width is ND + 2,
  write_imatrix(Width,M).

%----------------------------------------%
%                                        %
% Improved Solution Defined by enigma2/1 %
%                                        %
%----------------------------------------%

enigma(Size) :-
   setof(Total,M^Freq^Perm^square2(Size,M,Total,Freq,Perm),Totals),
   last(Max,Totals),
   square2(Size,Board,Max,_,P),
   write('Maximum total = '), write(Max), nl,
   write('Column to Row permutation:\n'),
   from_to(1,Size,Indeces),
   write_imatrix([Indeces,P]), nl,
   write('Board:\n'),
   write_imatrix(Board).

%============================================================>>>>>>

int(I,I).
int(Last,I) :- succ(Last,New), int(New,I).

generator(Pred,From,Elem) :-
   retractall(temp(_,_)),
   assert(temp(First,First)),
   assert(temp(Last,E) :- (call(Pred,Last,New), temp(New,E))),
   temp(From,Elem).

%---- EXERCISE ----

next_int(High,I,NextI) :- succ(I,NextI), NextI =< High.

%---- EXERCISE ----

next_pair((0,0),(0,1)) :- !.
next_pair((0,N),(0,NextN)) :-
   even(N),
   succ(N,NextN), !.
next_pair((M,0),(NextM,0)) :-
   odd(M),
   succ(M,NextM), !.
next_pair((M,N),(NextM,NextN)) :-
   Sum is M + N,
   (odd(Sum) -> succ(M,NextM), succ(NextN,N);
                succ(NextM,M), succ(N,NextN)), !.

even(N) :- 0 is N mod 2.

odd(N) :- 1 is N mod 2.

pairs((I,J)) :- int(0,Sum),       % Works but does not use generator/3
                between(0,Sum,I), %
                J is Sum - I.     %

pairs_alt((I,J)) :- generator(succ,0,Sum),        % Does not work! Confusing definitions of temp/2.
                    listing(temp),                %
                    generator(next_int(Sum),0,I), %
                    listing(temp),                %
                    J is Sum - I.                 %

pairs2((I,J)) :- generator2(succ,0,Sum),        % Works.
                 generator2(next_int(Sum),0,I),
                 J is Sum - I.

generator2(Pred,From,Elem) :-
   tmp_predname(TempName),
   Term1 =.. [TempName,First,First],
   Term2 =.. [TempName,Last,E],
   Term3 =.. [TempName,New,E],
   Term4 =.. [TempName,From,Elem],
   assert(Term1),
   assert(Term2 :- (call(Pred,Last,New), Term3)),
   write('Defined '), write(TempName), write('/2 in the database.\n'),
   Term4.

tmp_predname(Temp) :-
   int(0,N),
   int_to_atom(N,Tag),
   concat_atom(['temp_',Tag],Temp),
   not(current_predicate(Temp,_)), !.
