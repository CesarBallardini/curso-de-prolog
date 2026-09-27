%database update predicates: leaves/1 and joins/1 ...

leaves(Person) :- report_leaves(Person),!,
                  left_to(Person,X), right_to(Person,Y),
                  assert(right_to(X,Y)),
                  remove(Person), write_back.

remove(Person) :- retract(right_to(Person,_)),
                  retract(right_to(_,Person)).

report_leaves(Person) :- left_to(Person,X), right_to(Person,Y),write(Person),
                         write(' has left the table.'), nl.
report_leaves(Person) :- (not(left_to(Person,X)); not(right_to(Person,Y))), write(Person),
                         write(' cannot leave since he/she is not present.'), nl.

write_back :- tell('people.pl'), listing(right_to/2), told.


%----------------------------------------------------------------%
%                                                                %
% Exercise: swapping seats ...                                   %
%                                                                %
%----------------------------------------------------------------%

swap_neighbours(Pers1,Pers2) :-  % one or two people at the table - do nothing
   right_to(Pers1,Pers2),
   right_to(Pers2,Pers1).

swap_neighbours(Left,Right) :-   % more than two people at the table; Left is to the left of Right
   right_to(Left,Right),
   right_to(L,Left),
   right_to(Right,R),
   retract(right_to(Left,Right)),
   retract(right_to(L,Left)),
   retract(right_to(Right,R)),
   assert(right_to(Right,Left)),
   assert(right_to(L,Right)),
   assert(right_to(Left,R)).

swap(Pers1,Pers2) :- swap_neighbours(Pers1,Pers2).
swap(Pers1,Pers2) :- swap_neighbours(Pers2,Pers1).
swap(Pers1,Pers2) :- right_to(Pers1,R1),
                     right_to(L1,Pers1),
                     right_to(Pers2,R2),
                     right_to(L2,Pers2),
                     retract(right_to(Pers1,R1)),
                     retract(right_to(L1,Pers1)),
                     retract(right_to(Pers2,R2)),
                     retract(right_to(L2,Pers2)),
                     assert(right_to(Pers1,R2)),
                     assert(right_to(L2,Pers1)),
                     assert(right_to(Pers2,R1)),
                     assert(right_to(L1,Pers2)).

%----------------------------------------------------------------%
%                                                                %
% Exercise: joining the empty table ...                          %
%                                                                %
joins(Pers) :- not(right_to(_,_)),                               %
               assert(right_to(Pers,Pers)),                      %
               tell('people.pl'), listing(right_to/2), told,     %
               write(Pers), write(' has joined the table.'), nl. %
%----------------------------------------------------------------%

joins(Person,L,R) :- report_joins(Person,L,R),
                     retract(right_to(L,R)),
                     assert(right_to(L,Person)),
                     assert(right_to(Person,R)), write_back.

report_joins(Person,L,R) :- right_to(L,R),
                            write(Person), write(' has joined the table.'), nl.

report_joins(Person,L,R) :- not(right_to(L,R)), write('Place for '),
                            write(Person), write(' could not be found'), nl.

%=====================================================

%predicate look_right/1 to display current situation ...

look_right(Pers) :- look_right(Pers,[Pers|T]),
                    reverse(T,List),
                    write_list(List).

look_right(Pers,[X,Pers]) :- right_to(Pers,X).
look_right(Pers,[X,H|T])  :- right_to(H,X),
                             look_right(Pers,[H|T]).

write_list([]).
write_list([H|T]) :- write(H), write(' '), write_list(T).

guests :- right_to(_,_), !,
          (right_to(X,Y), write(X), nl, fail; true).

%=====================================================

%predicates for relative seating positions ...

left_to(X,Y) :- right_to(Y,X).
neighbours_of(X,[L,R]) :- left_to(X,L), right_to(X,R).

facing(X,L,R) :- right_to(L,X),
                 right_to(X,R),
                 (L == R, !; true).
facing(X,L,R) :- facing(X,Y,Z),
                 right_to(L,Y),
                 right_to(Z,R),
                 (L == R, !; true).

opposite_to(X,Y) :- facing(X,Y,Y),
                    X \== Y.

opposites :- opposite_to(_,_),
             ((right_to(X,Y),
               opposite_to(X,Z),
               write(X),
               write(', '),
               write(Z),
               nl, fail); true).

%----------------------------------------------------------------%
%                                                                %
% Exercise: relocation ...                                       %
%                                                                %
%----------------------------------------------------------------%

lives_in(london, paul).        lives_in(birmingham, adam).
lives_in(leeds, susan).        lives_in(bradford, george).
lives_in(london, tracy).       lives_in(birmingham, david).
lives_in(bradford, peter).     lives_in(bradford, jane).
lives_in(leeds, joe).          lives_in(london, jack).

%%%%%%%%%%%%%%%%%%%%%%
% File modifications %
%%%%%%%%%%%%%%%%%%%%%%

my_predicate(Fun/Arity,ClauseCount) :-
   current_predicate(Fun,Head),
   not(predicate_property(Head,built_in)),
   not(predicate_property(Head,imported_from(_))),
   not(predicate_property(Head,foreign)),
   predicate_property(Head,number_of_clauses(ClauseCount)),
   functor(Head,Fun,Arity).

save_predicates_to(Filename,all) :-
   tell(Filename),
   ((my_predicate(Fun/Arity,_),
     Fun \= 'my_predicate',
     Fun \= 'save_predicates_to',
     listing(Fun/Arity),
     fail); true),
   told.

/* save_predicates_to(Filename,List) :-
   tell(Filename),
   ((my_predicate(Fun/Arity,_),
     member(Fun/Arity,List),
     listing(Fun/Arity),
     fail); true),
   told. */

% Exercise:
% First solution ...

save_predicates_to(Filename,List) :-
   (member(X,List), not(my_predicate(X,_))) -> (write('Error: some predicates not in the database'), nl, fail);
   write_to_file(Filename,List).

% Second solution ...

/* save_predicates_to(Filename,List) :-
   (forall(member(X,List),my_predicate(X,_)) -> write_to_file(Filename,List));
   write('Error: some predicates not in the database'), nl, fail. */

write_to_file(Filename,List) :-
   tell(Filename),
   ((member(Fun/Arity,List),
     listing(Fun/Arity),
     fail); true),
   told.
