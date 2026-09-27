%----------------+
% INSERTION SORT %
%----------------%

% ins(+E,+L,-I) inserts E into the **sorted** list L to produce the list I.
% Use the accumulator technique with ins/4 ...

ins(E,L,I) :- ins(E,L,[],I).                 % Number 0

ins(E,[H|T],Acc,I) :- E > H,                 % Number 1
                      ins(E,T,[H|Acc], I).   %
ins(E,[H|T],Acc,I) :- E < H,                 %
                      reverse(Acc,R),        %
                      append(R,[E|[H|T]],I). % Number 2
ins(E,[],Acc,I)    :- reverse([E|Acc],I).   % Number 3

isort([H|T],S) :- isort(T, [H], S).          % Number 0

isort([H|T], Acc, S) :- ins(H, Acc, NewAcc), % Number 1
                        isort(T, NewAcc, S). %
isort([], S, S).                             % Number 2


%-------------------------------------------------------------------------------------------%
% SELECTION SORT based on putting the smallest element in front of the other list elements. %
% and using recursion. selSort(+List,-Sorted) ...                                           %
%-------------------------------------------------------------------------------------------%

% Define the predicate smallest/2 using the accumulator technique ...

smallest([H|T], Smallest) :- smallest(T, H, Smallest).    % clause 0
smallest([H|T], A, Smallest) :- A < H,
                                smallest(T, A, Smallest). % clause 1, no 'exchange'
smallest([H|T], A, Smallest) :- H < A,
                                smallest(T, H, Smallest). % clause 2, 'exchange'
smallest([], Smallest, Smallest).                         % clause 3, base case

% Now define selSort/2 ...

%---------------------------------------%
% Now define selSort/2 by recursion ... %
%---------------------------------------%

selSort([],[]).
selSort(List, [Smallest|RestSorted]) :-
   smallest(List,Smallest),
   append(Front,[Smallest|Back],List),
   append(Front,Back,RestList),
   selSort(RestList,RestSorted).

%-------------------------------------------------------------%
% QUICKSORT is based on                                       %
% (1) taking the head of List                                 %
% (2) sorting all entries smaller than the head giving SList, %
% (3) sorting all entries larger than the head giving LList,  %
% (4) concatenating SList, [H], LList.                        %
% Define qSort(+List,-Sorted) by recursion. Use split/4       %
% as defined below                                            %
%-------------------------------------------------------------%

% Define split/4 ... by the accumulator technique.
% split(+E,+List,-Smaller,-Larger)

split(E, List, Smaller, Larger) :- split(E, List, [], [], Smaller, Larger).

split(_, [], AccS, AccL, AccS, AccL).
split(E, [H|T], AccS, AccL, Smaller, Larger) :-
   E < H,
   split(E, T, AccS, [H|AccL], Smaller, Larger).
split(E, [H|T], AccS, AccL, Smaller, Larger) :-
   E > H,
   split(E, T, [H|AccS], AccL, Smaller, Larger).

%---------------------------------------%
% Now define qSort/2 by recursion ...   %
%---------------------------------------%

qSort([],[]).
qSort([H|T], Sorted) :- split(H, T, Smaller, Larger),
                        qSort(Smaller, SSorted),
                        qSort(Larger, LSorted),
                        append(SSorted, [H|LSorted], Sorted).

%---------------------------------------------------------------%
% BOTTOM UP MERGESORT is based on                               %
% (1) Converting the list into a list of lists comprising one   %
%     element each. Example: [10, 8, 4, 7, 6, 3, 5] is          %
%     converted to [[10], [8], [4], [7], [6], [3], [5]]         %
%     Achieve this by smallLists/2, defined by recursion.       %
%                                                               %
% (2) Merge adjacent lists recursively as exemplified below ... %
%     [[10], [8], [4], [7], [6], [3], [5]]                      %
%     [[8, 10], [4, 7], [3, 6], [5]]                            %
%     [[4, 7, 8, 10], [3, 5, 6]]                                %
%     [[3, 4, 5, 6, 7, 8, 10]]                                  %
%     Each step above is done by mergeTwos/2                    %
%                                                               %
%     Here, use an auxiliary predicate mergeSorted/3 to achieve %
%     the merger of two **sorted** lists. Use the accumulator   %
%     technique to define mergeSorted/3                         %
%---------------------------------------------------------------%


% (1) ...

smallLists([],[]).
smallLists([H|T], [[H]|S]) :- smallLists(T,S).

% (2) ...

mSort(List, Sorted) :- smallLists(List, SmallLists),
                       mergeAll(SmallLists, [Sorted]).

mergeAll([E], [E]) :- !.
mergeAll(Acc, M) :- mergeTwos(Acc, NewAcc),
                    mergeAll(NewAcc, M).

mergeTwos([],[]).
mergeTwos([E], [E]).
mergeTwos([H1,H2|T], [H|M]) :- mergeSorted(H1, H2, H),
                               mergeTwos(T, M).

mergeSorted(List1, List2, M) :- mergeSorted(List1, List2, [], M).

mergeSorted([H1|T1], [H2|T2], Acc, M) :-
   H1 < H2,
   mergeSorted(T1, [H2|T2], [H1|Acc], M).
mergeSorted([H1|T1], [H2|T2], Acc, M) :-
   H2 < H1,
   mergeSorted([H1|T1], T2, [H2|Acc], M).
mergeSorted([], List2, Acc, M) :- reverse(Acc, R),
                                  append(R, List2, M).
mergeSorted(List1, [], Acc, M) :- reverse(Acc, R),
                                  append(R, List1, M).
