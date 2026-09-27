app_dl1(A,B,B,A).

app_dl2(A-B,B,A).

:- op(50,xfx,&).

app_dl3(A&B,B,A).

app_dl4(A-B,B-C,A-C).

%=== BEGIN Dijkstra's Dutch Flag Problem ===================================================%

%----------------------------------------------%
%                                              %
% Dijkstra's Dutch Flag Problem: List of Items %
%            Red - White - Blue                %
%                                              %
%----------------------------------------------%

items([col(sky,blue),
       col(tomato,red),
       col(milk,white),
       col(blood,red),
       col(ocean,blue),
       col(cherry,red),
       col(snow,white)]).

new_items([col(soot,black), col(tomato,red), col(nut,brown),
           col(milk,white), col(snow,white), col(coal,black),
           col(bile,green), col(bark,brown), col(ocean,blue),
           col(grass,green), col(apple,red), col(blood,red),
           col(night,black), col(sky,blue)]).

%------------------------------------------%
%                                          %
%      Dijkstra's Dutch Flag Problem       %
%                                          %
%       BASIC SOLUTION USING append/3      %
%                                          %
%       Version 1: dijkstra_bs/2           %
%                                          %
%------------------------------------------%

reds([],[]).
reds([col(Object,red)|T],[col(Object,red)|L]) :- reds(T,L).
reds([col(_,Colour)|T],L) :- Colour \= red,
                             reds(T,L).

whites([],[]).
whites([col(Object,white)|T],[col(Object,white)|L]) :- whites(T,L).
whites([col(_,Colour)|T],L) :- Colour \= white,
                               whites(T,L).

blues([],[]).
blues([col(Object,blue)|T],[col(Object,blue)|L]) :- blues(T,L).
blues([col(_,Colour)|T],L) :- Colour \= blue,
                              blues(T,L).

dijkstra_bs(Items,Grouped) :- reds(Items,R),
                              whites(Items,W),
                              blues(Items,B),
                              append(R,W,RandW),
                              append(RandW,B,Grouped).

% EXAMPLE:
%
% ?- items(_Items), dijkstra_bs(_Items,_List), print_list(_List).
% col(tomato, red)
% col(blood, red)
% col(cherry, red)
% col(milk, white)
% col(snow, white)
% col(sky, blue)
% col(ocean, blue)
%
% Yes

%------------------------------------------

print_list([]) :- nl.
print_list([H|T]) :- write(H), nl, print_list(T).

%------------------------------------------


%------------------------------------------%
%                                          %
%      Dijkstra's Dutch Flag Problem       %
%                                          %
%       CONCISE SOLUTION USING append/3    %
%                                          %
%       Version 2: dijkstra_bs/2           %
%                                          %
%------------------------------------------%

colour(_,[],[]).
colour(Clr,[col(Object,Clr)|T],[col(Object,Clr)|L]) :- colour(Clr,T,L).
colour(Clr,[col(_,Colour)|T],L) :- Colour \= Clr,
                                   colour(Clr,T,L).

dijkstra_cs(Items,Grouped) :- colour(red,Items,R),
                              colour(white,Items,W),
                              colour(blue,Items,B),
                              append(R,W,RandW),
                              append(RandW,B,Grouped).

%----------------------------------%
%                                  %
%  Dijkstra's Dutch Flag Problem   %
%                                  %
%     USING DIFFERENCE LISTS       %
%                                  %
%     Version 3: dijkstra/2        %
%                                  %
%----------------------------------%

colour_dl(_,[],L-L).
colour_dl(Clr,[col(Object,Clr)|T],[col(Object,Clr)|L1]-L2) :-
   colour_dl(Clr,T,L1-L2).
colour_dl(Clr,[col(_,Colour)|T],L1-L2) :-
   Colour \= Clr,
   colour_dl(Clr,T,L1-L2).

dijkstra_dl(Items,L1-L4) :- colour_dl(red,Items,L1-L2),
                            colour_dl(white,Items,L2-L3),
                            colour_dl(blue,Items,L3-L4).

dijkstra(Items,Grouped) :- dijkstra_dl(Items,Grouped-[]).

% EXAMPLE:
%
% ?- items(_Items), dijkstra(_Items,_List), print_list(_List).
% col(tomato, red)
% col(blood, red)
% col(cherry, red)
% col(milk, white)
% col(snow, white)
% col(sky, blue)
% col(ocean, blue)
%
% Yes

%----------------------------------------------------------%
%                                                          %
%            Dijkstra's Dutch Flag Problem                 %
%                                                          %
%         GENERALIZED SOLUTION BY DIFFERENCE LISTS         %
%                                                          %
% Version 4: dijkstra/2 should be used again, now with     %
%            prior database update by def_dijkstra_dl/2    %
%                                                          %
%----------------------------------------------------------%
%
% NOTES. (1) colour_dl/3 from version 3 is used here.
%        (2) dijkstra_dl/2 should now be defined in (i.e. written to) the database prior to invoking
%            dijkstra/2. This definition to be carried out by def_dijkstra_dl/1.
%            The argument of def_dijkstra_dl/1 is the items's list of colours.
%        (3) In version 4, conj/2 is used; this is defined in transformations.pl
%            Thus, load database by ?- [dl,transformations].
%        (4) Any colour is possible. The colours will be sorted in alphabetical order.
%            Within each colour group the original order is retained.
%        (5) Sample session with version 4:
%
% ?- listing(dijkstra_dl/2).
%
% dijkstra_dl(A, B-C) :-
%         colour_dl(red, A, B-D),
%         colour_dl(white, A, D-E),
%         colour_dl(blue, A, E-C).
%
% Yes
% ?- new_items(_Items), colours(_Items,_Colours), redefine_dijkstra_dl(_Colours), dijkstra(_Items,_List), print_list(_List).
% col(soot, black)
% col(coal, black)
% col(night, black)
% col(ocean, blue)
% col(sky, blue)
% col(bile, green)
% col(grass, green)
% col(tomato, red)
% col(apple, red)
% col(blood, red)
% col(milk, white)
% col(snow, white)
%
% Yes
% ?- listing(dijkstra_dl/2).
%
% dijkstra_dl(A, B-C) :-
%         colour_dl(black, A, B-D),
%         colour_dl(blue, A, D-E),
%         colour_dl(green, A, E-F),
%         colour_dl(red, A, F-G),
%         colour_dl(white, A, G-H),
%         colour_dl(yellow, A, H-C).
%
% Yes

vars(N,Vars) :- functor(Term,dummy,N),                 % list of vars of specified length N
                bagof(Var,Arg^arg(Arg,Term,Var),Vars).

conjuncts(X,Colours,[H|T],FirstV,LastV) :- length(Colours,M),
                                           N is M + 1,
                                           vars(N,Vs),
                                           conjuncts_acc(X,Colours,Vs,[],[RH|RT]),
                                           RH = colour_dl(_,_,_-LastV),
                                           reverse([RH|RT],[H|T]),
                                           H = colour_dl(_,_,FirstV-_).

conjuncts_acc(_,[],_,G,G).
conjuncts_acc(X,[HCol|TCol],[V1,V2|TVars],Acc,G) :-
   conjuncts_acc(X,TCol,[V2|TVars],[colour_dl(HCol,X,V1-V2)|Acc],G).

replace_dijkstra_dl(Colours) :- dynamic(dijkstra_dl/2),
                                retractall(dijkstra_dl(_,_)),
                                conjuncts(X,Colours,G,First,Last),
                                conj(Body,G),                              % conj/2 in transformations.pl
                                assert(dijkstra_dl(X,First-Last) :- Body).

dijkstra(Colours,Items,List) :- replace_dijkstra_dl(Colours),
                                dijkstra(Items,List).

%------------------------------------------%
%                                          %
%      Dijkstra's Dutch Flag Problem       %
%                                          %
%       ANother SOLUTION USING append/3    %
%                                          %
%       Version 5: dijkstra_an/2           %
% (This is in preparation for an Exercise  %
%  in the chapter "Difference Lists".      %
% Solution is by Version 6.                %
%                                          %
%------------------------------------------%

colour([],[],[],[]).
colour([col(Object,red)|T],[col(Object,red)|R],W,B) :-
   colour(T,R,W,B).
colour([col(Object,white)|T],R,[col(Object,white)|W],B) :-
   colour(T,R,W,B).
colour([col(Object,blue)|T],R,W,[col(Object,blue)|B]) :-
   colour(T,R,W,B).
colour([col(_,Colour)|T],R,W,B) :- % Solves an exercise in Ch. Diff. Lists
   Colour \= red,
   Colour \= white,
   Colour \= blue,
   colour(T,R,W,B).

dijkstra_an(Items,Grouped) :- colour(Items,R,W,B),
                              append(R,W,RandW),
                              append(RandW,B,Grouped).

%------------------------------------------%
%                                          %
%      Dijkstra's Dutch Flag Problem       %
%                                          %
%      REWRITE VERSION 5 IN TERMS OF       %
%         DIFFERENCE LISTS                 %
%                                          %
%       Version 6: dijkstra_6/2            %
% (This is the solution of an Exercise in  %
%  the chapter "Difference Lists".         %
%                                          %
%------------------------------------------%

colour_dl([],R-R,W-W,B-B).
colour_dl([col(Object,red)|T],[col(Object,red)|R1]-R2,W1-W2,B1-B2) :-
   colour_dl(T,R1-R2,W1-W2,B1-B2).
colour_dl([col(Object,white)|T],R1-R2,[col(Object,white)|W1]-W2,B1-B2) :-
   colour_dl(T,R1-R2,W1-W2,B1-B2).
colour_dl([col(Object,blue)|T],R1-R2,W1-W2,[col(Object,blue)|B1]-B2) :-
   colour_dl(T,R1-R2,W1-W2,B1-B2).
colour_dl([col(_,Colour)|T],R1-R2,W1-W2,B1-B2) :-
   Colour \= red,
   Colour \= white,
   Colour \= blue,
   colour_dl(T,R1-R2,W1-W2,B1-B2). % Solves an exercise in Ch. Diff. Lists

dijkstra_6_dl(Items,L1-L4) :- colour_dl(Items,L1-L2,L2-L3,L3-L4).

dijkstra_6(Items,Grouped) :- dijkstra_6_dl(Items,Grouped-[]).

%-------------------------------------------%
%                                           %
%      Dijkstra's Dutch Flag Problem        %
%                                           %
% Exercise: sort in  order of given colours %
%   (From Chapter 'Program Manipulations')  %
%                                           %
%-------------------------------------------%

dijkstra_st(Items,Grouped) :- colours(Items,Colours),
                              dijkstra(Colours,Items,Grouped).

colours(Items,Colours) :- setof(Colour,Object^(member(col(Object,Colour),Items)),Colours).

%-------------------------------------------%
%                                           %
%      Dijkstra's Dutch Flag Problem        %
%                                           %
%     Sort in  order of given colours       %
%   ENHANCED Version producing difference   %
%        lists based implementations        %
%   (For Chapter 'Program Manipulations')   %
%                                           %
%-------------------------------------------%
%
% Define at runtime the predicate en_colour_dl/M where M is N + 1 and
% N is the number of colours.

diffterms([],_,[]).
diffterms(_,[],[]).
diffterms([H1|T1],[H2|T2],[H1-H2|D]) :- diffterms(T1,T2,D).

% Define the clause for the base case base_clause/2 ...

diffvars1(N,D) :- functor(Term,dummy,N),
                  Term =.. [_|L],
                  diffterms(L,L,D).

base(N,Term) :- diffvars1(N,D),
                Term =.. [encolour_dl,[]|D].

base_clause(Colours,(Head :- true)) :- length(Colours,N),
                                       base(N,Head).

% Define the clause for the recursive case recursive_clause/3 ...

diffvars2(N,D) :- functor(Term1,dummy,N),
                  functor(Term2,dummy,N),
                  Term1 =.. [_|L1],
                  Term2 =.. [_|L2],
                  diffterms(L1,L2,D).

% comb(+Object,+Colour,+Colours,+List,-Modified) combines the list of differences 'List'
% with Colours
% Object is a variable

comb(Object,Colour,Colours,List,Modified) :- comb(Object,Colour,Colours,List,[],Modified).

comb(Object,_,[],_,Acc,Modified) :- reverse(Acc,Modified).
comb(Object,_,_,[],Acc,Modified) :- reverse(Acc,Modified).
comb(Object,Colour,[Colour|Rest],[H1-H2|T],Acc,Modified) :-
  comb(Object,Colour,Rest,T,[[col(Object,Colour)|H1]-H2|Acc],Modified).
comb(Object,Colour,[_|Rest],[H|T],Acc,Modified) :-
  comb(Object,Colour,Rest,T,[H|Acc],Modified).

body(T,D,Body) :- Body =.. [encolour_dl,T|D].
head(Colour,Colours,T,D,Head) :-
   comb(Object,Colour,Colours,D,Modified),
   Head =.. [encolour_dl,[col(Object,Colour)|T]|Modified].

recursive_clause(Colour,Colours,(Head :- Body)) :-
   length(Colours,N),
   diffvars2(N,D),
   head(Colour,Colours,T,D,Head),
   body(T,D,Body), !.

%catch_all_clause(Colours,(Head :- Body)) :-
%   length(Colours,N),
%   diffvars2(N,D),
%   Head =.. [encolour_dl,[col(_,_)|T]|D],
%   Body =.. [encolour_dl,T|D].

catch_all_clause(Colours,(Head :- Body)) :-      % see Exercise ...
   length(Colours,N),                            %
   diffvars2(N,D),                               %
   Head  =.. [encolour_dl,[col(_,Colour)|T]|D],  %
   Term  =.. [member,Colour,Colours],            %
   Goal1 =.. [not,Term],                         %
   Goal2 =.. [encolour_dl,T|D],                  %
   conj(Body,[Goal1,Goal2]).                     % conj/2 is defined in transformations.pl

% Write to the database the definition of encolour_dl ...

def_encolour_dl(Colours) :-
   length(Colours,N),
   M is N + 1,
   dynamic(encolour_dl/M),
   length(Vars,M),
   Old_Version =.. [encolour_dl|Vars],
   retractall(Old_Version),
   base_clause(Colours,B_Clause),
   assert(B_Clause),
   ((member(Colour,Colours),
     recursive_clause(Colour,Colours,R_Clause),
     assert(R_Clause),
     fail); true),
   catch_all_clause(Colours,C_Clause),
   assert(C_Clause).

% Write to the database the definition of endijkstra_dl ...

def_endijkstra_dl(Colours) :-
   dynamic(endijkstra_dl/2),
   retractall(endijkstra_dl(_,_)),
   length(Colours,N),
   length(Vars1,N),
   Vars1 = [First|Rest],
   append(Rest,[Last],Vars2),
   diffterms(Vars1,Vars2,D),
   Head = endijkstra_dl(Items,First-Last),
   Body =.. [encolour_dl,Items|D],
   assert((Head :- Body)).

% Definition of endijkstra/3 ...

endijkstra(Colours,Items,Grouped) :-
   def_encolour_dl(Colours),
   def_endijkstra_dl(Colours),
   endijkstra_dl(Items,Grouped-[]), !.

%---------------------------------------------%
%                                             %
%      Dijkstra's Dutch Flag Problem          %
%                                             %
%     Sort in  order of given colours         %
%   ENHANCED Version producing non-difference %
%        lists based implementations          %
%   (For Chapter 'Program Manipulations')     %
%                                             %
%---------------------------------------------%
%
% Define at runtime the predicate encolour_pl/M where M is N + 1 and
% N is the number of colours. (Suffix 'pl' refers to a 'plain' version, i.e.
% a one **not** producing difference lists nased implementations

% empties(+List,-Empties) Empties is a list of empty lists whose length is that of List

empties([],[]).
empties([_|T],[[]|E]) :- empties(T,E).

% Define the clause for the base case base_clause_pl/2 ...

base_clause_pl(Colours,(Head :- true)) :- empties(Colours,E),
                                          Head =.. [encolour_pl,[]|E].

% Define the clause for the recursive case recursive_clause_pl/3 ...

% comb_pl(+Object,+Colour,+Colours,+List,-Modified) combines the list 'List'
% with Colours; Object is a variable

comb_pl(Object,Colour,Colours,List,Modified) :- comb_pl(Object,Colour,Colours,List,[],Modified).

comb_pl(Object,_,[],_,Acc,Modified) :- reverse(Acc,Modified).
comb_pl(Object,_,_,[],Acc,Modified) :- reverse(Acc,Modified).
comb_pl(Object,Colour,[Colour|Rest],[H|T],Acc,Modified) :-
  comb_pl(Object,Colour,Rest,T,[[col(Object,Colour)|H]|Acc],Modified).
comb_pl(Object,Colour,[_|Rest],[H|T],Acc,Modified) :-
  comb_pl(Object,Colour,Rest,T,[H|Acc],Modified).

body_pl(T,L,Body) :- Body =.. [encolour_pl,T|L].
head_pl(Colour,Colours,T,L,Head) :-
   comb_pl(Object,Colour,Colours,L,Modified),
   Head =.. [encolour_pl,[col(Object,Colour)|T]|Modified].

recursive_clause_pl(Colour,Colours,(Head :- Body)) :-
   length(Colours,N),
   length(L,N),
   head_pl(Colour,Colours,T,L,Head),
   body_pl(T,L,Body), !.

catch_all_clause_pl(Colours,(Head :- Body)) :-
   length(Colours,N),
   length(L,N),
   Head =.. [encolour_pl,[col(_,_)|T]|L],
   Body =.. [encolour_pl,T|L].

% Write to the database the definition of encolour_pl ...

def_encolour_pl(Colours) :-
   length(Colours,N),
   M is N + 1,
   dynamic(encolour_pl/M),
   length(Vars,M),
   Old_Version =.. [encolour_pl|Vars],
   retractall(Old_Version),
   base_clause_pl(Colours,B_Clause),
   assert(B_Clause),
   ((member(Colour,Colours),
     recursive_clause_pl(Colour,Colours,R_Clause),
     assert(R_Clause),
     fail); true),
   catch_all_clause_pl(Colours,C_Clause),
   assert(C_Clause).

% Write to the database the definition of endijkstra_pl ...

def_endijkstra_pl(Colours) :-
   dynamic(endijkstra_pl/2),
   retractall(endijkstra_pl(_,_)),
   length(Colours,N),
   length(Vars,N),
   Head = endijkstra_pl(Items,Grouped),
   Goal1 =.. [encolour_pl,Items|Vars],
   Goal2 =.. [flatten,Vars,Grouped],
   Body = (Goal1, Goal2),
   assert((Head :- Body)).

%=== END OF Dijkstra's Dutch Flag Problem ===================================================%

%------------------------------------------%
% Project: Lists as Trees & flatten/2      %
%------------------------------------------%

% Exercise 1 ...

sharp(E,E)                  :- not(proper_list(E)), !.
sharp([],[]).
sharp([E],#(Term,[]))       :- sharp(E,Term), !.
sharp([H|T],#(Term1,Term2)) :- sharp(H,Term1),
                               sharp(T,Term2).

% Exercise 2 ...

lf(Term,Term)      :- var(Term), !.
lf(#(Term,_),Term) :- not(functor(Term,#,2)), Term \= [].
lf(#(Term,_),Leaf) :- lf(Term,Leaf).
lf(#(_,Term),Leaf) :- lf(Term,Leaf).

% Exercise 3 & Discussion ...

flatten_1(L,F) :- sharp(L,S), bagof(Leaf,lf(S,Leaf),F).

% version 2 of flatten/2 ...

leaf(Term,Term)      :- var(Term), !.
leaf(.(Term,_),Term) :- not(functor(Term,.,2)),
                        Term \= [].
leaf(.(Term,_),Leaf) :- leaf(Term,Leaf).
leaf(.(_,Term),Leaf) :- leaf(Term,Leaf).

flatten_2(L,F) :- bagof(Leaf,leaf(L,Leaf),F).

% Exercise 4 ...

dot(List) :- sharp(List,Term),
             term_to_atom(Term,A1),
             atom_chars(A1,L1),
             sharps_to_dots(L1,L2),
             concat_atom(L2,A2),
             write_term(A2,[]).

% sharps_to_dots(S,D) :- maplist(sharp_to_dot,S,D). % second version

sharp_to_dot(#,'.') :- !.
sharp_to_dot(C,C).

sharps_to_dots(S,D) :- sharps_to_dots(S,[],R), reverse(R,D), !.

sharps_to_dots([],L,L).
sharps_to_dots([#|T],Acc,L) :- sharps_to_dots(T,[.|Acc],L).
sharps_to_dots([H|T],Acc,L) :- sharps_to_dots(T,[H|Acc],L).

% version 3 of flatten/2 ...

flatten_3([],[]).
flatten_3([H|T],L1) :- flatten_3(H,L2),
                       flatten_3(T,L3),
                       append(L2,L3,L1).
flatten_3(X,[X]).

% Exercise 5 (definition of version 4) ...

flatten_4(X,[X]) :- var(X), !.
flatten_4([],[]).
flatten_4([H|T],L1) :- flatten_4(H,L2),
                       flatten_4(T,L3),
                       append(L2,L3,L1), !.
flatten_4(X,[X]).

% flattening by the difference list technique ...

flatten_5(L,F) :- flatten_dl(L,F-[]), !.

flatten_dl([],L-L).
flatten_dl([H|T],L1-L3) :- flatten_dl(H,L1-L2),
                           flatten_dl(T,L2-L3).
flatten_dl(X,[X|Z]-Z).

% Exercise 6 (definition of version 6) ...

flatten_6(L,F) :- flatten_dl_6(L,F-[]), !.

flatten_dl_6(X,[X|T]-T) :- var(X), !.
flatten_dl_6([],L-L).
flatten_dl_6([H|T],L1-L3) :- flatten_dl_6(H,L1-L2),
                             flatten_dl_6(T,L2-L3).
flatten_dl_6(X,[X|Z]-Z).

% Exercise 7 ...

%----------------------------------------------------------------%
% Generate nested lists for testing implementations of flatten/2 %
%----------------------------------------------------------------%

nested(M,L) :- nested(M,1,[1],L), !.

nested(M,M,L,L).
nested(M,N,Acc,L) :- NewN is N + 1,
                     nested(M,NewN,[Acc,NewN],L).

%------------------------------%
% Implementations of reverse/2 %
%------------------------------%

% use append/3 ...

reverse_1([],[]).
reverse_1([H|T],R) :- reverse_1(T,L), append(L,[H],R).

% use accumulator ...

reverse([],R,R).
reverse([H|T],Acc,R) :- reverse(T,[H|Acc],R).

reverse_2(L,R) :- reverse(L,[],R).

% use difference lists ...
%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
%rev_dl([], A-A).
%rev_dl([A|B], C-D) :-
%        rev_dl(B, C-[A|D]),
%        true.
%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
rev_dl([],L-L).
rev_dl([X],[X|L]-L).
rev_dl([H|T],L1-L3) :- rev_dl(T,L1-L2), rev_dl([H],L2-L3).

reverse_3(L,R) :- rev_dl(L,R-[]), !.

% use difference lists (second, transformed version) ...

reverse_4(L,R) :- rev_dl_2(L,R-[]).

rev_dl_2([],L-L).
rev_dl_2([H|T],L1-L2) :- rev_dl_2(T,L1-[H|L2]).

% use difference lists (third, improved transformed version) ...

reverse_5(L,R) :- rev_dl_3(L,R-[]).

rev_dl_3([],L-L).
rev_dl_3([X],[X|L]-L).
rev_dl_3([E1,E2|T],L1-L2) :- rev_dl_3(T,L1-[E2,E1|L2]).

% enhanced further still ...

reverse_6(L,R) :- rev_dl_4(L,R-[]).

rev_dl_4([],L-L).
rev_dl_4([E1],[E1|L]-L).
rev_dl_4([E1,E2],[E2,E1|L]-L).
rev_dl_4([E1,E2,E3|T],L1-L2) :- rev_dl_4(T,L1-[E3,E2,E1|L2]).

%=== BEGIN Gauss-Seidel Method ===================================================%

%----------------------------------%
%                                  %
% Gauss-Seidel Method ...          %
%                                  %
%----------------------------------%

%--------------------------------%
% dl(+PlainList,-DiffList) ...   %
%--------------------------------%

dl([],L-L).
dl([H|T],[H|L1]-L2) :- dl(T,L1-L2).

%----------------------------------------------%
% dl2(+ListOfLists,-DiffListOfDiffLists) ...   %
%----------------------------------------------%

dl2([],L-L).
dl2([H|T],[HDL|L1]-L2) :- dl(H,HDL), !,
                          dl2(T,L1-L2).

% rot_rows(+ListofLists,-ListOfRotated) ...

rot_rows([],[]).
rot_rows([[H|T]|Ls],[R|Rs]) :- append(T,[H],R), !,
                               rot_rows(Ls,Rs).

rot_matrix(M,R) :- rot_rows(M,[H|T]),
                   append(T,[H],R).

% rot_rows_dl(+DLofDLs,-DLofDLsRotated) ...

rot_rows_dl(L-_,Y-Y) :- var(L).
rot_rows_dl([[H|T1]-[H|T2]|Ls1]-Ls2,[T1-T2|R1]-R2) :-
   rot_rows_dl(Ls1-Ls2,R1-R2).

rot_matrix_dl(MDL,T1-T2) :- rot_rows_dl(MDL,[H|T1]-[H|T2]).

% dot_product_dl(+DL1,+DL2,-DotProduct) ...

dot_product_dl(DL1,DL2,Result) :-
   dot_product_dl(DL1,DL2,0,Result), !.

dot_product_dl(L-_,_,Acc,Acc) :- var(L).
dot_product_dl([HU|TU1]-TU2,[HV|TV1]-TV2,Acc,Result) :-
   NewAcc is Acc + HU * HV, !,
   dot_product_dl(TU1-TU2,TV1-TV2,NewAcc,Result).

% example matrix ...

matrix_a([[ a11, a12, a13, a14],
          [ a21, a22, a23, a24],
          [ a31, a32, a33, a34]]).

% displaying a matrix which is given in the difference list form ...

show_matrix_dl(M-[]):- show_matrix(M), nl.
show_matrix([]).
show_matrix([H-[]|T]) :- write(H), write(' '),
                         show_matrix(T).

% improved versions ...

show_matrix_dl2(DLM):- dynamic(matrix/1),
                       retractall(matrix(_)),
                       assert(matrix(DLM)),
                       matrix(M),
                       show_matrix_dl(M).

show_matrix_dl3(DLM):- copy_term(DLM,M),
                       show_matrix_dl(M).

% Gauss-Seidel by proper lists ...

% g_seidel(+As,+Bs,+Xs,+Ss,+I,-FinalXs,-FinalSs) ...

g_seidel(_,_,Xs,Ss,0,Xs,Ss).
g_seidel(As,Bs,Xs,Ss,I,FinalXs,FinalSs) :-
   g_seidel(in(As,Bs,Xs,Ss),out(NewAs,NewBs,NewXs,NewSs)),
   NewI is I - 1, !,
   g_seidel(NewAs,NewBs,NewXs,NewSs,NewI,FinalXs,FinalSs).

g_seidel(in([[First|Rest]|OtherRows],
            [B|OtherBs],
            [_|OtherXs],
            [S|OtherSs]),
         out(NewAs,NewBs,NewXs,NewSs)) :-
   dot_product(Rest,OtherXs,P),
   NewX is B - P,
   rot_matrix([[First|Rest]|OtherRows],NewAs),
   append(OtherBs,[B],NewBs),
   append(OtherXs,[NewX],NewXs),
   append(OtherSs,[S],NewSs).

dot_product(Xs,Ys,Result) :- dot_product(Xs,Ys,0,Result).

dot_product([],_,Acc,Acc).
dot_product([X|Xs],[Y|Ys],Acc,Result) :-
   NewAcc is X * Y + Acc, !,
   dot_product(Xs,Ys,NewAcc,Result).

% Gauss-Seidel by difference lists ...

% g_seidel_dl(in(+MatrixDL,+DsDL,+XsDL,+IndecesDL),
%             out(-NewMatrixDL,-NewDsDL,-NewXsDL,-NewIndecesDL)) ...

g_seidel(in([[First|Rest1]-Rest2|A1]-A2,
            [B|B1]-[B|B2],
            [_|T1]-[NewX|T2],
            [S|S1]-[S|S2]),
         out(NewAs,B1-B2,T1-T2,S1-S2)) :-
   dot_product_dl(Rest1-Rest2,T1-[NewX|T2],P),
   NewX is B - P,
   rot_matrix_dl([[First|Rest1]-Rest2|A1]-A2,NewAs).

% gauss_seidel(+Matrix,+Ds,+Xs,+Indeces,+N,-NewXs,-NewIndeces) ...

g_seidel_2(A,B,X,S,I,NewX,NewS) :-
   dl2(A,ADL),
   dl(B,BDL),
   dl(X,XDL),
   dl(S,SDL),
   g_seidel(ADL,BDL,XDL,SDL,I,NewX-[],NewS-[]), !.

% Example: E. Kreyszig, "Advanced Engineering Mathematics",
%          sixth edition, Wiley, 1988, p. 1015.

a([[   1, -0.25, -0.25,     0],
   [-0.25,     1,     0, -0.25],
   [-0.25,     0,     1, -0.25],
   [    0, -0.25, -0.25,     1]]).

b([50, 50, 25, 25]).

x0([100, 100, 100, 100]).

s([1, 2, 3, 4]).

coeffs2([[    1, -0.25, -0.25,     0,     0,     0,     0,     0,     0,     0,     0,     0],
         [-0.25,     1,     0, -0.25,     0,     0,     0,     0,     0,     0,     0,     0],
         [-0.25,     0,     1, -0.25,     0,     0,     0,     0,     0,     0,     0,     0],
         [    0, -0.25, -0.25,     1,     0,     0,     0,     0,     0,     0,     0,     0],
         [    0,     0,     0,     0,     1, -0.25, -0.25,     0,     0,     0,     0,     0],
         [    0,     0,     0,     0, -0.25,     1,     0, -0.25,     0,     0,     0,     0],
         [    0,     0,     0,     0, -0.25,     0,     1, -0.25,     0,     0,     0,     0],
         [    0,     0,     0,     0,     0, -0.25, -0.25,     1,     0,     0,     0,     0],
         [    0,     0,     0,     0,     0,     0,     0,     0,     1, -0.25, -0.25,     0],
         [    0,     0,     0,     0,     0,     0,     0,     0, -0.25,     1,     0, -0.25],
         [    0,     0,     0,     0,     0,     0,     0,     0, -0.25,     0,     1, -0.25],
         [    0,     0,     0,     0,     0,     0,     0,     0,     0, -0.25, -0.25,     1]]).

b2([50, 50, 25, 25, 50, 50, 25, 25, 50, 50, 25, 25]).

x02([100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100]).

s2([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]).

% Session log ...

% ?- a(A), b(B), x0(X), s(S), gauss_seidel(A,B,X,S,90,NewX,NewSs).

% A = [[1, -0.25, -0.25, 0], [-0.25, 1, 0, -0.25], [-0.25, 0, 1, -0.25], [0, -0.25, -0.25, 1]]
% B = [50, 50, 25, 25]
% X = [100, 100, 100, 100]
% Ss = [1, 2, 3, 4]
% NewX = [62.5, 62.5, 87.5, 87.5]
% NewSs = [3, 4, 1, 2]

%=== END Gauss-Seidel Method ===================================================%

%--------------------------------%
% rotations ...                  %
%--------------------------------%

% rotate_dl(+DiffList,-RotatedDiffList) ...

rotate_dl([H|T1]-[H|T2],T1-T2).

% Rotate once: rotate(+List,-Rotated) ...

rotate(List,Rotated) :- dl(List,DiffList),
                        rotate_dl(DiffList,Rotated-[]).

% Several rotations: rotate(+List,+N,-Rotated) ...

rotate(List,N,Rotated) :- dl(List,DiffList),
                          rotate_dl(DiffList,N,Rotated-[]).

rotate_dl(DiffList,0,DiffList).
rotate_dl([H|T1]-[H|T2],N,RDiffList) :-
   NewN is N - 1, !,
   rotate_dl(T1-T2,NewN,RDiffList).

%-----------------------------------------%
% moving averages of adjacent entries ... %
%-----------------------------------------%
%
% averages(+L,-A) returns in A the pairwise averages of a list
% of positive integers L ...

averages(L,A) :- aver([-1,1|L],A), !.

aver([_,0,_|T],T).
aver(X,Result) :- av_rotate(X,Y),
                  aver(Y,Result).

av_rotate([H1,H2|Y],L) :-
   Last is (H1 + H2)/2,
   append([H2|Y],[Last],L).

%
% averages_dl(+DL,-ADL) returns in ADL the pairwise averages of a list
% of positive integers DL (both lists are in difference list format) ...

averages_dl(L1-L2,A1-A2) :- aver_dl([-1,1|L1]-L2,A1-A2), !.

aver_dl([_,0,_|X]-Y,X-Y).
aver_dl(X1-X2,ADL) :- av_rotate_dl(X1-X2,Y1-Y2),
                      aver_dl(Y1-Y2,ADL).

av_rotate_dl([H1,H2|Y]-[Last|Z],[H2|Y]-Z) :-
  Last is (H1 + H2)/2.

% averages2(+L,-A) returns in A the pairwise averages of a list
% of positive integers L (by simple recursion) ...

averages2([_],[]).
averages2([H1,H2|T],[A|AS]) :- A is (H1 + H2) / 2,
                               averages2([H2|T],AS).

% aver1(+List,+N,-Averages) ...

aver1(L,N,Averages) :- aver1(L,N,[],Averages).

aver1(_,0,Acc,Averages) :- reverse(Acc,Averages).
aver1([G,H|T],N,Acc,Averages) :-
   A is (G + H) / 2,
   NewN is N - 1,
   append([H|T],[G],L), !,
   aver1(L,NewN,[A|Acc],Averages).

% aver2(+Difflist,+N,-Averages) ...

aver2(L,N,Averages) :- dl(L,DiffList),
                       aver2_dl(DiffList,N,[],Averages).

aver2_dl(_,0,Acc,Averages) :- reverse(Acc,Averages).
aver2_dl([G,H|T1]-[G,H|T2],N,Acc,Averages) :-
   A is (G + H) / 2,
   NewN is N - 1, !,
   aver2_dl([H|T1]-[H|T2],NewN,[A|Acc],Averages).

% aver3(+Difflist,+N,-Averages) (reverse eliminated here!)...

aver3(L,N,Averages) :- dl(L,DiffList),
                       aver3_dl(DiffList,N,Acc-Acc,Averages).

aver3_dl(_,0,Averages-[],Averages).
aver3_dl([G,H|T1]-[G,H|T2],N,Acc1-[A|Acc2],Averages) :-
   A is (G + H) / 2,
   NewN is N - 1, !,
   aver3_dl([H|T1]-[H|T2],NewN,Acc1-Acc2,Averages).

%=== BEGIN Perceptron Training Algorithm ===================================================%

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

%pta(in(_,Ps,Ds,Ws,I),out(Ws,I)) :- classify_all(Ps,Ws,Ds), !. % first version

pta(Argument,Result) :- transform(Argument,NewArgument),
                        !, pta(NewArgument,Result).

%-----------------%
% transform/2 ... %
%-----------------%

transform(in(C,[P|OtherPs],[D|OtherDs],Ws,Acc),
          in(C,NewPs,NewDs,NewWs,NewAcc)) :-
   append(OtherPs,[P],NewPs),
   append(OtherDs,[D],NewDs),
   perceptron(C,P,D,Ws,NewWs),
   NewAcc is Acc + 1.

% 'rotate' by difference lists ...

transform(in(C,[P|TP1]-[P|TP2],[D|TD1]-[D|TD2],Ws,Acc),
          in(C,TP1-TP2,TD1-TD2,NewWs,NewAcc)) :-
   perceptron(C,P,D,Ws,NewWs),
   NewAcc is Acc + 1.

%
% AUXILIARY predicates ...
%

sign(X,-1) :- X < 0.
sign(X,1) :- X >= 0.

%----------------------%
% classify a point ... %
%----------------------%

% classify(+Point,+Weights,-Class) ...

classify(Point,Weights,Class) :-
   net(Point,Weights,Net),
   sign(Net,Class).

%----------------------%
% the perceptron ...   %
%----------------------%

perceptron(C,Point,D,Weights,NewWeights) :-
   classify(Point,Weights,Class),
   Const is C * (D - Class),
   mult(Const,Point,DeltaWs),
   add(Weights,DeltaWs,NewWeights).

%-------------------------%
% classify all points ... %
%-------------------------%

% classify_all(+Points,+Weights,-Classes) ...

classify_all([],_,[]).
classify_all([P|OtherPs],Weights,[Class|OtherCs]) :-
   classify(P,Weights,Class), !,
   classify_all(OtherPs,Weights,OtherCs).

% classify_all(+PointsDL,+Weights,-ClassesDL) ...
% 'rotate' by difference lists


classify_all(L-_,_,L1-L1) :- var(L).
classify_all([P|TP1]-TP2,Weights,[Class|TC1]-TC2) :-
   classify(P,Weights,Class), !,
   classify_all(TP1-TP2,Weights,TC1-TC2).

%-----------------------------------------------%
% scalar multiplication of a list by a constant %
%-----------------------------------------------%

% mult(+C,+List,-NewList) ...

/* see Exercise

mult2(C,List,L) :- mult(C,List,[],L).               % clause 0

mult(_,[],Acc,L) :- reverse(Acc,L).                % clause 1
mult(C,[H|T],Acc,L) :- A is C * H, !,              % clause 2
                       mult2(C,T,[A|Acc],L).
*/
mult(_,[],[]).
mult(C,[H|T],[P|Ps]) :- P is C * H, !,
                        mult(C,T,Ps).

%---------------------------------%
% add two lists (vector addition) %
%---------------------------------%

% add(+L1,+L2,-S) ...

/* see Exercise

add2(List1,List2,L) :- add(List1,List2,[],L).      % clause 0

add([],[],Acc,L) :- reverse(Acc,L).                % clause 1
add([H1|T1],[H2|T2],Acc,L) :- A is H1 + H2, !,     % clause 2
                              add(T1,T2,[A|Acc],L).
*/
add(_,[],[]).
add([H1|T1],[H2|T2],[S|Ss]) :- S is H1 + H2, !,
                               add(T1,T2,Ss).

%----------------------------------------%
% calculating 'net' (is the dot product) %
%----------------------------------------%

% net(+Point,+Weights,-Net) ...

net(Point,Weights,Net) :- net(Point,Weights,0,Net).

net(_,[],Net,Net).
net([HX|TX],[HW|TW],Acc,Net) :-
   NewAcc is Acc + HW * HX, !,
   net(TX,TW,NewAcc,Net).

%=== END Perceptron Training Algorithm ===================================================%
