%-----------------------------------%
%             Examples              %
%-----------------------------------%
%
% Summing the first n numbers - naive solution ...
%
sum([],0).
sum([H|T],S) :- sum(T,S0), S is H + S0.

% auxiliary predicate from_to/3 ...

% from_to(Low,High,List) :- bagof(N,between(Low,High,N),List), !.
% from_to(_,_,[]).

% use an accumulator argument ...

sum([],S,S).
sum([H|T],Acc,S) :- NewAcc is Acc + H, !,
                    sum(T,NewAcc,S).

new_sum(L,S) :- sum(L,0,S).
%
% reverse by rev/2 ...

rev(L,R) :- rev(L,[],R).              % clause 0

rev([],R,R).                          % clause 1
rev([H|T],Acc,R) :- rev(T,[H|Acc],R). % clause 2
%
% min ...

min([H|T],S) :- min(T,H,S).        % clause 0
min([],S,S).                       % clause 1
min([H|T],Acc,S) :- H < Acc,       % clause 2
                    !, min(T,H,S).
min([_|T],Acc,S) :- min(T,Acc,S).  % clause 3
%
% from_to(?Lower,?Higher,?IList) ...

% from_to(M,N,L) :- var(L),
% from_to(M,N,L) :- is_list(L),
% from_to(M,N,L) :-
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
%
% palindrome ...

palin(L) :- palin(L,[]).

palin(L,L).
palin([_|T],T).
palin([H|T],Acc) :- palin(T,[H|Acc]).
%
% numbers/2 counts the number of numbers in an atom ...

numbers(Atom,N) :- atom_codes(Atom,Values),        % clause 0
                   numbers(Values,nodigit,0,N), !. %

numbers([],_,N,N).               % clause 1

numbers([H|T],nodigit,Acc,N) :-  % clause 2
   digit(H),                     %
   NewAcc is Acc + 1,            %
   !, numbers(T,digit,NewAcc,N). %
numbers([H|T],digit,Acc,N) :-    % clause 3
   digit(H),                     %
   !, numbers(T,digit,Acc,N).    %
numbers([_|T],_,Acc,N) :-        % clause 4
   !, numbers(T,nodigit,Acc,N).  %

digit(C) :- 48 =< C, C =< 57.
%
% second version of numbers (call it nums/2 and its auxiliary nums/3) ...

nums(Atom,N) :- atom_codes(Atom,L),  % clause 0
                nums([47|L],0,N), !. %

nums([],N,N).                                   % clause 1
nums([_],N,N).                                  % clause 2
nums([H,E|T],Acc,N) :- not(digit(H)), digit(E), % clause 3
                       NewAcc is Acc + 1,       %
                       !, nums([E|T],NewAcc,N). %
nums([_,E|T],Acc,N) :- nums([E|T],Acc,N).       % clause 4



%-----------------------------------%
% The Perceptron Training Algorithm %
%-----------------------------------%

%-----------------------------------------%
% Any number of points in n dimensions    %
% - uses lists                            %
% - two classes                           %
% - points labelled 1 and -1              %
% - TrainingData is a list of the form    %
%   (for points in the plane)             %
%   [[X1,X2,X3,DesiredOutX],              %
%    [Y1,Y2,Y3,DesiredOutY],              %
%    [U1,U2,U3,DesiredOutU], ... ]        %
% - linear separability                   %
% - additional co-ordinate is unit bias 1 %
%-----------------------------------------%
%
% Begin Test Data >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
%
%
% Test case 0: 8 points in the plane (use learning rate = 0.25) ...

ws([-0.51, -0.35, 0.13]).

ps([[ 6.981, 0.554, 1],
    [14.414, 4.466, 1],
    [ 2.337, 4.040, 1],
    [ 8.500, 3.496, 1],
    [ 9.190, 2.000, 1],
    [ 1.149, 6.100, 1],
    [14.786, 2.179, 1],
    [ 7.842, 6.331, 1]]).

ds([-1, 1, -1, 1, -1, -1, 1, 1]).

% Test case 1: logical 'AND' (use learning rate = 0.5) ...

ws1([0.72,-0.61,0.42]).
ps1([[1,1,1],[1,0,1],[0,1,1],[0,0,1]]).
ds1([1,-1,-1,-1]).
%
% Test case 2: logical 'NAND' (use learning rate = 0.4) ...

ws2([0.085,-0.04,0.1]).
ps2([[1,1,1],[1,0,1],[0,1,1],[0,0,1]]).
ds2([-1,1,1,1]).
%
% Test case 3: ten points in the plane (use learning rate = 0.2) ...

ws3([0.75,0.5,-0.6]).
ps3([[1.0,1.0,1],
     [9.4,6.4,1],
     [2.5,2.1,1],
     [8.0,7.7,1],
     [0.5,2.2,1],
     [7.9,8.4,1],
     [7.0,7.0,1],
     [2.8,0.8,1],
     [1.2,3.0,1],
     [7.8,6.1,1]]).
ds3([1,-1,1,-1,1,-1,-1,1,1,-1]).
%
% Test case 4: 14 points in the 3-D space (use learning rate = 0.5) ...

ws4([0.31,0.57,0.4,0.53]).

ps4([[8.68,2.78,3.61,1.0],[1.07,2.62,9.25,1.0],[5.59,3.4,5.22,1.0],
[4.41,5.08,0.09,1.0],[4.51,4.05,0.84,1.0],[0.47,3.12,4.19,1.0],[6.71,3.99,7.11,1.0],
[4.24,5.73,9.66,1.0],[2.56,0.61,2.21,1.0],[4.92,3.15,8.37,1.0],[6.96,1.5,6.53,1.0],
[7.77,2.82,9.07,1.0],[8.78,0.86,0.87,1.0],[3.42,3.27,9.42,1.0]]).

ds4([1,1,1,-1,-1,-1,1,1,-1,1,1,1,1,1]).

%
% END TEST DATA <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

% pta/6 iterates until all points are correctly classified ...
%
% pta(+LearningRate,+Points,+DesiredOutputs,+Weights,
%     -FinalWeights,-Iterations)

pta(LearningRate,Points,DesiredOutputs,Weights,
    FinalWeights,Iterations) :-
   pta(in(LearningRate,Points,DesiredOutputs,Weights,0),
       out(FinalWeights,Iterations)).

% Auxiliary predicate pta/2 ...
%
% pta(in(+LearningRate,+Points,+DesiredOutputs,+Weights,+Acc),
%     out(-FinalWeights,?Iterations))

pta(in(_,_,_,Ws,Acc),out(Ws,I)) :- integer(I),
                                   Acc =:= I, !.

pta(in(_,Ps,Ds,Ws,Acc),out(Ws,I)) :- var(I),
                                     classify_all(Ps,Ws,Ds),
                                     I = Acc, !.

%pta(in(_,Ps,Ds,Ws,I),out(Ws,I)) :- classify_all(Ps,Ws,Ds), !.

pta(Argument,Result) :- transform(Argument,NewArgument),
                        !, pta(NewArgument,Result).

transform(in(C,[P|OtherPs],[D|OtherDs],Ws,Acc),
          in(C,NewPs,NewDs,NewWs,NewAcc)) :-
   append(OtherPs,[P],NewPs),
   append(OtherDs,[D],NewDs),
   perceptron(C,P,D,Ws,NewWs),
   NewAcc is Acc + 1.

%
% auxiliary predicates ...
%

sign(X,-1) :- X < 0.
sign(X,1) :- X >= 0.

classify(Point,Weights,Class) :-
   net(Point,Weights,Net),
   sign(Net,Class).

classify_all([],_,[]).
classify_all([P|OtherPs],Weights,[Class|OtherCs]) :-
   classify(P,Weights,Class), !,
   classify_all(OtherPs,Weights,OtherCs).

perceptron(C,Point,D,Weights,NewWeights) :-
   classify(Point,Weights,Class),
   Const is C * (D - Class),
   mult(Const,Point,DeltaWs),
   add(Weights,DeltaWs,NewWeights).

% mult(+C,+List,-NewList) ...

mult(C,List,L) :- mult(C,List,[],L).               % clause 0

mult(_,[],Acc,L) :- reverse(Acc,L).                % clause 1
mult(C,[H|T],Acc,L) :- A is C * H, !,              % clause 2
                       mult(C,T,[A|Acc],L).

% add(+L1,+L2,-S) ...

add(List1,List2,L) :- add(List1,List2,[],L).       % clause 0

add([],[],Acc,L) :- reverse(Acc,L).                % clause 1
add([H1|T1],[H2|T2],Acc,L) :- A is H1 + H2, !,     % clause 2
                              add(T1,T2,[A|Acc],L).



% net(+Weights,+Point,-Net) ...

net(Point,Weights,Net) :- net(Point,Weights,0,Net).

net(_,[],Net,Net).
net([HX|TX],[HW|TW],Acc,Net) :-
   NewAcc is Acc + HW * HX, !,
   net(TX,TW,NewAcc,Net).

/******************************************/
/* An Example For The Use of Accumulators */
/******************************************/

% An Exercise for SDC/AI coursework 3, 2003-2004

%----------------------------------------%
%                                        %
% FIRST VERSION (uses atom_codes/2) ...  %
%                                        %
%----------------------------------------%

% cnt(+Atom,-Upper,-Lower) counts the number of upper and lower case char's...

cnt(Atom,U,L) :- atom_codes(Atom,Values), % clause 0
                 cnt(Values,0,0,U,L), !.  %

cnt([],U,L,U,L).                                        % clause 1
cnt([H|T],AccU,AccL,U,L) :- upper(H),                   % clause 2
                            NewAccU is AccU + 1,        %
                            !, cnt(T,NewAccU,AccL,U,L). %
cnt([H|T],AccU,AccL,U,L) :- lower(H),                   % clause 3
                            NewAccL is AccL + 1,        %
                            !, cnt(T,AccU,NewAccL,U,L). %
cnt([_|T],AccU,AccL,U,L) :- cnt(T,AccU,AccL,U,L).       % clause 4

upper(C) :- C >= 65, C =< 90.
lower(C) :- C >= 97, C =< 122.

%--------------------------------------------------------%
%                                                        %
% SECOND VERSION ...                                     %
%                                                        %
%--------------------------------------------------------%
%
% count(+Atom,cases(-Upper,-Lower)) counts the number of upper and lower case char's...

count(Atom,cases(U,L)) :-              % clause 0
   atom_codes(Atom,Values),            %
   count(Values,acc(0,0),acc(U,L)), !. %

count([],Acc,Acc).                 % clause 1
count([H|T],acc(U,L),Result) :-    % clause 2
   upper(H),                       %
   NewU is U + 1,                  %
   !, count(T,acc(NewU,L),Result). %
count([H|T],acc(U,L),Result) :-    % clause 3
   lower(H),                       %
   NewL is L + 1,                  %
   !, count(T,acc(U,NewL),Result). %
count([_|T],acc(U,L),Result) :-    % clause 4
   count(T,acc(U,L),Result).       %

%--------------------------------------------------------%
%                                                        %
% THIRD VERSION (uses atom_chars/2 and char_code/2) ...  %
%                                                        %
%--------------------------------------------------------%

% count_case2(+Atom,-Upper,-Lower)

count_case2(Atom,Upper,Lower) :-
   atom_chars(Atom,L),
   count_case2(L,0,0,Upper,Lower), !.

count_case2([],AccUpper,AccLower,AccUpper,AccLower).
count_case2([H|T],AccUpper,AccLower,Upper,Lower) :-
   char_code(H,Ascii),
   Ascii >= 65,
   Ascii =< 90,
   NewAccUpper is AccUpper + 1,
   count_case2(T,NewAccUpper,AccLower,Upper,Lower).
count_case2([H|T],AccUpper,AccLower,Upper,Lower) :-
   char_code(H,Ascii),
   Ascii >= 97,
   Ascii =< 122,
   NewAccLower is AccLower + 1,
   count_case2(T,AccUpper,NewAccLower,Upper,Lower).
count_case2([_|T],AccUpper,AccLower,Upper,Lower) :-
   count_case2(T,AccUpper,AccLower,Upper,Lower).

%----------------------------------------------%
%                                              %
% SDC/AI coursework 2004/2005: even_odd/3 ...  %
%                                              %
%----------------------------------------------%

% even_odd(+NumList,-Even,-Odd) counts the number of even and odd numbers in a list ...

even_odd(L,E,O) :- even_odd(L,0,0,E,O), !.                        % clause 0

even_odd([],E,O,E,O).                                             % clause 1
even_odd([H|T],AccE,AccO,E,O) :- even(H),                         % clause 2
                                 NewAccE is AccE + 1,             %
                                 !, even_odd(T,NewAccE,AccO,E,O). %
even_odd([H|T],AccE,AccO,E,O) :- odd(H),                          % clause 3
                                 NewAccO is AccO + 1,             %
                                 !, even_odd(T,AccE,NewAccO,E,O). %
even_odd([_|T],AccE,AccO,E,O) :- even_odd(T,AccE,AccO,E,O).       % clause 4

even(N) :- 0 is N mod 2.
odd(N)  :- not(even(N)).

%--------------------------------------------------%
%                                                  %
% Insertion Sort, version 1                        %
% (auxiliary is also by the accumulator technique) %
%                                                  %
%--------------------------------------------------%

isort1(L,S) :- isort1(L,[],S).

isort1([],Acc,Acc).
isort1([H|T],Acc,S) :-
   insert1(H,Acc,NewAcc),
   isort1(T,NewAcc,S).

insert1(E,L,I) :- insert1(E,L,[],I).

insert1(E,[H|T],Acc,S) :-
   H < E,
   insert1(E,T,[H|Acc],S).
insert1(E,[H|T],Acc,S) :-
   H >= E,
   reverse(Acc,R),
   append(R,[E|[H|T]],S).
insert1(E,[],Acc,S) :-
   reverse([E|Acc],S).

%--------------------------------------------------%
%                                                  %
% Insertion Sort, version 2                        %
% (auxiliary is not by the accumulator technique)  %
%                                                  %
%--------------------------------------------------%

isort2(L,S) :- isort2(L,[],S), !.

isort2([],S,S).
isort2([H|T],Acc,S) :-
   insert2(H,Acc,NewAcc),
   isort2(T,NewAcc,S).

insert2(E,[],[E]).
insert2(E,[H|T],[E|[H|T]]) :- E =< H.
insert2(E,[H|T],[H|L]) :- insert2(E,T,L).
