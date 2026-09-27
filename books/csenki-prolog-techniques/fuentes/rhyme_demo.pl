% nursery rhyme -- last verse

verse(['This is the farmer sowing his corn',
       'That kept the cock that crowed in the morn',
       'That waked the priest all shaven and shorn',
       'That married the man all tattered and torn',
       'That kissed the maiden all forlorn',
       'That milked the cow with the crumpled horn',
       'That tossed the dog',
       'That worried the cat',
       'That killed the rat',
       'That ate the malt',
       'That lay in the house that Jack built.']).

%----------------------------------------------%
%                                              %
%      First Preliminary Implementation        %
%                                              %
%----------------------------------------------%

verse_skeleton(['F','E','D','C','B','A']).

show_list([]).
show_list([H|T]) :- write(H), nl, show_list(T).

show_rhyme([]).
show_rhyme([H|T]) :- show_list(H), nl, show_rhyme(T).

% use a counter ...

rhyme_prel_1(V,R) :- length(V,L), rhyme_aux([V],L,R).

rhyme_aux(R,1,R).
rhyme_aux([Head_Old|Tail_Old],Counter,R) :-
   Head_Old = [_|Head],
   New_Counter is Counter - 1,
   rhyme_aux([Head|[Head_Old|Tail_Old]],New_Counter,R).

% use pattern matching ...

rhyme_aux_2([[First]|Rest],[[First]|Rest]).
rhyme_aux_2([Head_Old|Tail_Old],R) :-
   Head_Old = [_|Head],
   rhyme_aux_2([Head|[Head_Old|Tail_Old]],R).

rhyme_prel_2(V,R) :- rhyme_aux_2([V],R).

% a more concise version of rhyme_aux/2 ...
% (May also use 'rhyme_aux_3([[]|R,R).' as the first clause.)

rhyme_aux_3([[]|R],R).
% rhyme_aux_3([[First]|Rest],[[First]|Rest]).
rhyme_aux_3([[H|T]|Tail_Old],R) :- rhyme_aux_3([T|[[H|T]|Tail_Old]],R).

rhyme_prel_3(V,R) :- rhyme_aux_3([V],R).

%----------------------------------------------%
%                                              %
%      Another Preliminary Implementation      %
%                                              %
%----------------------------------------------%

rhyme_prel_4(V,R) :- rhyme_acc(V,[],R).

rhyme_acc([],R,R).
rhyme_acc([HOld|TOld],AccOld,R) :- rhyme_acc(TOld,[[HOld|TOld]|AccOld],R).

%----------------------------------------------%
%                                              %
%              The Final Version               %
%                                              %
%----------------------------------------------%

to_first(Old,New) :- atom_chars(Old,Charlist),
                     change(Charlist,Newlist),
                     concat_atom(Newlist,New).

change([t,h,e|T],['T',h,i,s,' ',i,s,' ',t,h,e|T]) :- !.
change([_|T],X) :- change(T,X).

change_first([H1|T],[H2|T]) :- to_first(H1,H2).

% Four versions ...

rhyme_1 :- verse(V),
           rhyme_prel_1(V,RTemp),
           maplist(change_first,RTemp,R),
           show_rhyme(R).

rhyme_2 :- verse(V),
           rhyme_prel_2(V,RTemp),
           maplist(change_first,RTemp,R),
           show_rhyme(R).

rhyme_3 :- verse(V),
           rhyme_prel_3(V,RTemp),
           maplist(change_first,RTemp,R),
           show_rhyme(R).

rhyme_4 :- verse(V),
           rhyme_prel_4(V,RTemp),
           maplist(change_first,RTemp,R),
           show_rhyme(R).

%----------------------------------------------%
%                                              %
%                Other Approaches              %
%                                              %
%----------------------------------------------%

rhyme_prel_5([L],[[L]]).
% rhyme_prel_5([],[]). % alternative first clause
rhyme_prel_5([H|T],C) :- append(P,[[H|T]],C), rhyme_prel_5(T,P).
% rhyme_prel_5([H|T],C) :- append(P,[[H|T]],C), rhyme_prel_5(T,P), !. % failure on trying to re-satisfying rhyme_prel_5/2

rhyme_5 :- verse(V),
           rhyme_prel_5(V,RTemp),
           maplist(change_first,RTemp,R),
           show_rhyme(R).

rhyme_prel_6([L],[[L]]).
% rhyme_prel_6([],[]). % alternative first clause
rhyme_prel_6([H|T],C) :- rhyme_prel_6(T,P), append(P,[[H|T]],C).

rhyme_6 :- verse(V),
           rhyme_prel_6(V,RTemp),
           maplist(change_first,RTemp,R),
           show_rhyme(R).

% use difference lists ...

rhyme_prel_dl([L],[[L]|X]-X).
rhyme_prel_dl([H|T],C1-C2) :- rhyme_prel_dl(T,C1-[[H|T]|C2]).

rhyme_prel_7(V,R) :- rhyme_prel_dl(V,R-[]).

rhyme_7 :- verse(V),
           rhyme_prel_7(V,RTemp),
           maplist(change_first,RTemp,R),
           show_rhyme(R).

% Timing the various versions' behaviour ...

n_times_acc(0,_,L,L).
n_times_acc(N,X,L1,L2) :- N1 is N - 1, n_times_acc(N1,X,[X|L1],L2).

n_times(N,X,L) :- n_times_acc(N,X,[],L), !.

long_verse(N) :- n_times(N,'That interacts with the item ...',L),
                 dynamic(verse/1),
                 retract(verse(_)),
                 assert(verse(L)).

cputime(Predname,Arglist,Time) :- T =.. [Predname|Arglist],
                                  statistics(cputime,Before),
                                  call(T),
                                  statistics(cputime,After), !,
                                  Time is After - Before.

cputime(Predname,Arglist,Version,Time) :- concat_atom([Predname,'_',Version],Pred),
                                          cputime(Pred,Arglist,Time).

%--------------------------%
%                          %
% One Man Went To Mow ...  %
%                          %
%--------------------------%

units(0,'').     units(1,one).    units(2,two).
units(3,three).  units(4,four).   units(5,five).
units(6,six).    units(7,seven).  units(8,eight).
units(9,nine).

tens(0,'').       tens(2,twenty).  tens(3,thirty).
tens(4,forty).    tens(5,fifty).   tens(6,sixty).
tens(7,seventy).  tens(8,eighty).  tens(9,ninety).

hundreds(0,'').
hundreds(N,Text) :- units(N,U), atom_concat(U,hundred,Text).

thousands(N,Text) :- units(N,U), atom_concat(U,thousand,Text).

number([U],Text) :- units(U,Text).
number([1,0],'ten') :- !.
number([1,1],'eleven') :- !.
number([1,2],'twelve') :- !.
number([1,3],'thirteen') :- !.
number([1,5],'fifteen') :- !.
number([1,U],Text) :- units(U,U1),
                      atom_concat(U1,'teen',Text), !.
number([T,U],Text) :- tens(T,Tens),
                      number([U],Rest),
                      atom_concat(Tens,Rest,Text).
number([H,T,U],Text) :- hundreds(H,Hundreds),
                        number([T,U],Rest),
                        atom_concat(Hundreds,Rest,Text).
number([Th,H,T,U],Text) :- thousands(Th,Thousands),
                           number([H,T,U],Rest),
                           atom_concat(Thousands,Rest,Text).

% digits(+IntExpr,-List) and digits(-Int,+ListOfInt)

digits(N,D) :- integer(N), digits(N,[],D).
digits(N,D) :- var(N), value(D,0,N).

digits(N,Acc,[N|Acc]) :- N < 10, !.
digits(N,Acc,D)       :- H is N mod 10,
                         NewN is N // 10,
                         digits(NewN,[H|Acc],D).

value([],N,N).
value([H|T],Acc,N) :- integer(H),
                      H < 10,
                      AccNew is H + 10 * Acc,
                      value(T,AccNew,N).

in_words(N,Text) :- digits(N,D), number(D,Text).

to_upper(Lower,Upper) :- char_code(Lower,L),
                         U is L - 32,
                         char_code(Upper,U).

capital(Atom1,Atom2) :- atom_chars(Atom1,[H|T]), % change the 1st letter to capital
                        to_upper(H,Upper),
                        atom_chars(Atom2,[Upper|T]).

% song_skeleton([1]).
% song_skeleton([N|[H|T]]) :- song_skeleton([H|T]), N is H + 1.

int(N) :- int(1,N).

int(I,I).                % clause 1
%int(1,I) :- int(2,I).    % clause 2
%int(2,I) :- int(3,I).    % clause 3
%int(3,I) :- int(4,I).    % clause 4

int(Last,I) :- succ(Last,New), int(New,I).

song_skeleton(L) :- song_skeleton([1],L).

song_skeleton(L,L).
song_skeleton([H|T],L) :- succ(H,N), song_skeleton([N|[H|T]],L).

%line1(1,'One man went to mow,') :- !.
%line1(N,Text) :- in_words(N,HowMany),
%                 capital(HowMany,C),
%                 atom_concat(C,' men went to mow,',Text).

line1(N,Text) :- in_words(N,HowMany),
                 capital(HowMany,C),
                 ((N =:= 1, atom_concat(C,' man went to mow,',Text));
                  (N > 1, atom_concat(C,' men went to mow,',Text))).

line2('Went to mow a meadow,').

line3(Numbers,Text) :- maplist(in_words,Numbers,[H|T]),
                       maplist(atom_concat(' men,\n  '),T,L1),
                       capital(H,C),
                       concat_atom([C|L1],Text1),
                       atom_concat(Text1,' man and his dog,',Text).

line4('Went to mow a meadow.').

%- - - - - - - - - - - - -

song :- song_skeleton([H|T]),
        line1(H,L1),
        line2(L2),
        line3([H|T],L3),
        line4(L4), nl,
        write(L1), nl,
        write(L2), nl,
        write(L3), nl,
        write(L4), nl, fail.

% second version of song_skeleton/1 using a repeat loop ...

song_skeleton_2(L) :- first_verse,
                      current_verse(L).
song_skeleton_2(L) :- repeat,
                      update_verse,
                      current_verse(L).

first_verse :- dynamic(current_verse/1),
               retractall(current_verse(_)),
               assert(current_verse([1])).

update_verse :- current_verse([H|T]),
                retractall(current_verse(_)),
                NewH is H + 1,
                assert(current_verse([NewH,H|T])).

nat(N) :- first_nat, current_nat(N).
nat(N) :- repeat, update_nat, current_nat(N).

first_nat :- dynamic(current_nat/1),
             retractall(current_nat(_)),
             assert(current_nat(1)).

update_nat :- current_nat(N),
              retractall(current_nat(_)),
              NewN is N + 1,
              assert(current_nat(NewN)).
