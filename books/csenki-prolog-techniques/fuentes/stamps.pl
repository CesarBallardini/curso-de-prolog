:- dynamic(album/1).    % for Part b
:- dynamic(selling/1).  % for Part d

% Initial database:

album([stamp('Britain','Queen',1965,20),
       stamp('Britain','Queen',1967,50),
       stamp('Britain','Queen',1963,120)]).
album([stamp('Britain','Poets',1978,19),
       stamp('Britain','Poets',1979,20),
       stamp('Britain','Poets',1978,22),
       stamp('Britain','Poets',1977,40),
       stamp('Britain','Poets',1978,100)]).
album([stamp('Germany','Kaiser',1882,5),
       stamp('Germany','Kaiser',1879,20),
       stamp('Germany','Kaiser',1885,50)]).
album([stamp('Germany','Castles',1885,10),
       stamp('Germany','Castles',1879,50),
       stamp('Germany','Castles',1885,60)]).

%----------------------------------------------
% Exercise 1

collection(Pattern) :-
   bagof(Stamp,Pattern^Set^(album(Set), member(Stamp,Set), Stamp = Pattern),Stamps),
   show_list(Stamps).

show_list([]).
show_list([H|T]) :- write(H), nl, show_list(T).

% Exercise 2 (i)  define, by using the directive dynamic/1, album/1 to be a dynamic predicate, and,
%            (ii) type interactively: retractall(album([stamp('Germany','Kaiser',_,_)|_])).

% Exercise 3

remove_all(Pattern,Lin,Lout) :- bagof(E,(member(E,Lin),E \= Pattern),Lout), !.
remove_all(_,_,[]).  % 'catch all' clause

% Exercise 4

sell(stamp(Country,Name,Year,Denom)) :- nonvar(Country),
                                        nonvar(Name),
                                        retractall(selling(_)),
                                        assert(selling(stamp(Country,Name,Year,Denom))),
                                        album(Set),
                                        selling(Stamp),
                                        Set = [stamp(Country,Name,Year,Denom)|_],
                                        remove_all(Stamp,Set,NewSet),
                                        retractall(album(Set)),
                                        ([] \= NewSet, assert(album(NewSet)); true).

% Exercise 5

insert(Stamp,[],[Stamp]).
insert(stamp(C,N,Y,D),[stamp(C,N,Y1,D1)|T1],[stamp(C,N,Y1,D1)|T2]) :- D > D1,
                                                                      insert(stamp(C,N,Y,D),T1,T2), !.
insert(stamp(C,N,Y,D),[stamp(C,N,Y1,D1)|T],[stamp(C,N,Y,D),stamp(C,N,Y1,D1)|T]).

% Exercise 6

buy(stamp(Country,Name,Year,Denom)) :- album(Set),
                                       Set = [stamp(Country,Name,_,_)|_],
                                       retractall(album(Set)),
                                       insert(stamp(Country,Name,Year,Denom),Set,NewSet),
                                       assert(album(NewSet)).
buy(stamp(Country,Name,Year,Denom)) :- assert(album([stamp(Country,Name,Year,Denom)])).
