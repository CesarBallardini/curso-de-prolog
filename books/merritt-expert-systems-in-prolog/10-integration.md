# Integration

<!-- page 87 -->
Many real problems cannot be solved by the simple application of a single expert system technique. Problems often require multiple knowledge representation techniques as well as conventional programming techniques.

Often it is necessary to either have the expert system embedded in a conventional application, or to have other applications callable from the expert system. For example, a financial expert system might need a tight integration with a spread sheet, or an engineering expert system might need access to programs that perform engineering calculations.

The degree to which the systems in this book can be integrated with other environments depends on the flexibility of the Prolog used and the application that needs to be accessed. The systems can be designed with the hooks in place for this integration. In the examples presented in this chapter, the knowledge base tools will have hooks to Prolog.

Often the Prolog code can be used to implement features of the system that do not fit neatly in the knowledge tools. This is often the case in the area of user interface, but applies to other portions as well. In the example in this chapter, we will see Prolog used to smooth over a number of the rough edges of the application.

The degree of integration needed between knowledge tools also depends somewhat on the application. In this chapter, the forward chaining system and frame based knowledge representation will be tightly integrated. By having control over the tools, the degree of integration can be implemented to suit the individual application.

The example used in this chapter is the same room furniture placement used in the chapter on forward chaining. While the application was developed with the pure *Oops* system, a much more elegant solution can be implemented by integrating frames, Oops, and Prolog. In particular, there is a lot of knowledge about the types of furniture that could be better stored in a frame system. Also the awkward input and output sections of the system could be better written in Prolog. 7.1 Foops (Frames and Oops)

The first step is to integrate the frame based knowledge representation with the Oops forward chaining inference engine. The integration occurs in two places:

- The concept of a frame instance needs to be implemented.

- The rules must be able to reference the frame instances.

The instances are needed for an integrated system to distinguish between the frame data definition in the knowledge base, and the instances of frames in working storage. The rules will be matching and manipulating instances of frames, rather than the frame definitions themselves. For example, there will be a frame describing the attributes of chairs, but there might be multiple instances of chairs in working storage.

### Instances

In the frame system as it is currently written, the frames are the data. Particular instances of a frame, such as person, are just additional frames. For use in the expert system it is cleaner to distinguish between frame definitions and instances of frames.

<!-- page 88 -->
*Building Expert Systems in Prolog* The definitions specify the slots for a frame, and the instances provide specific values for the slots. The frame instances will be updated in working storage and accessed by the rules. For example, person would be a frame definition, and mary would be an instance of person.

The inheritance still works as before. That is, a person frame could be defined as well as man and woman frames, which inherit from person. In this case, mary would be an instance of woman, inheriting from both the woman frame and the person frame.

The frame definitions will be considered to define classes of things. So, person, man, and woman are classes defined in frame relations. Individuals, such as mary, dennis, michael, and diana are stored as instances of these classes.

To implement the instances, we need both a data structure and predicates to manipulate the data structure. An instance of a frame looks a lot like a frame, and will be stored in the relation frinst/4. The four arguments will be:

- the class name;

- the instance name;

- the list of slot attribute-value pairs associated with the instance;

- a time stamp indicating when the instance was last updated.

For example:

```prolog
frinst(woman,
mary,
[ako-woman, hair-brown, hobby-rugby],
32).
frinst(man,
dennis,
[ako-man, hair-blond, hobby-go],
33).
```

The predicates which manipulate frinsts are:

- getf — retrieve attribute values for a frinst;

- addf — add a new frinst;

- uptf — update an existing frinst;

- delf — delete a frinst, or attribute values for a frinst;

- printf — print information about a frinst.

The code for getf is almost identical for that of get_frame. It just uses the frinst structure to get data rather than the frame structure. The ako slot of a frinst is automatically set to the class name, so if it is necessary to inherit values, the appropriate frames will be called just as they were for get_frame. The only other change is the additional argument for retrieving the time stamp as well.

```prolog
getf(Class, Name, ReqList) :-
getf(Class, Name, ReqList, _).
getf(Class, Name, ReqList, TimeStamp) :-
frinst(Class, Name, SlotList, TimeStamp),
slot_vals(Class, Name, ReqList, SlotList).
```

The addf predicate is similar to add_frame, however it has two new features. First, it will generate a unique name for the frinst if none was given, and second it adds a time stamp.

78

<!-- page 89 -->
*Chapter 7 - Integration* The generated name is simply a number in sequence. The time stamp is generated the same way, and uses the predicate getchron, which was already implemented for *Oops*. Note that addf also sets the ako slot to the value of the Class.

```prolog
addf(Class, Nm, UList) :-
(var(Nm), genid(Name);
Name=Nm),
add_slots(Class, Name, [ako-Class|UList], SlotList,NewList),
getchron(TimeStamp),
asserta(frinst(Class, Name, NewList, TimeStamp)),
!.
```

The uptf predicate is distinct from addf in that it only updates existing frinsts and does not create new ones. It puts a new time stamp on the frinst as part of the update.

```prolog
uptf(Class, Name, UList) :-
frinst(Class, Name, SlotList, _),
add_slots(Class, Name, UList, SlotList, NewList),
retract( frinst(Class, Name, _, _) ),
getchron(TimeStamp),
asserta(frinst(Class, Name, NewList, TimeStamp)),
!.
```

The delf and printf predicates are similarly based on del_frame and print_frame. Both offer options for accessing large numbers of instances. For example delf(Class) deletes all frinsts in Class, whereas delf(Class, Name, DList) deletes the attribute values in DList from the specified instance.

### Rules for frinsts

Now that there is a mechanism for handling instances of frames, the next step is to revise the *Oops* rule structure to use those instances. In *Oops*, each of the LHS conditions was a Prolog term held in a fact relation. For *Foops*, the LHS conditions will be frinsts.

In keeping with the *Oops* design of using operators to make the rules more readable, the frinsts will be presented differently in the rules. The form will be:

```prolog
Class - Name with [Attr - Val, ...]
```

For example, the rule in the furniture configuration that puts table lamps on end tables is:

```prolog
rule f11:
[table_lamp - TL with [position-none],
end_table - ET with [position-wall/W]]
==>
[update( table_lamp - TL with [position-end_table/ET] )].
```

Note that the RHS actions also use the same syntax for the instance.

The change is easy to implement due to the interchangeability of facts and rules in Prolog. *Oops* refers to facts, expecting to find data. *Foops* uses the same code, but implements the relation fact as a rule, which calls getf.

Following is the code that matches the premises from the LHS. It is the the same as in the previous version except that the definition of fact has been changed to reflect the new nature of each individual premise.

```prolog
match([], []).
```

<!-- page 90 -->
*Building Expert Systems in Prolog*

```prolog
match([Prem|Rest], [Prem/Time|InstRest]) :-
mat(Prem, Time),
match(Rest, InstRest).
mat(N:Prem, Time) :-
!,
fact(Prem, Time).
mat(Prem, Time) :-
fact(Prem, Time).
mat(Test, 0) :-
test(Test).
fact(Prem, Time) :-
conv(Prem, Class, Name, ReqList),
getf(Class, Name, ReqList, Time).
conv(Class-Name with List, Class, Name, List).
conv(Class-Name, Class, Name, []).
```

The conv relation is used to allow the user to specify instances in an abbreviated form if there is no attribute value list. For example, the following rule uses an instance of the class goal where the name is the only important bit of information:

```prolog
rule f1:
[goal - couch_first,
couch - C with [position-none, length-LenC],
door - D with [position-wall/W],
...
```

The only other change which has to be made is in the implementation of the action commands which manipulate working storage. These now manipulate frinst structures instead of the pure facts as they did in *Oops*. They simply call the appropriate frame instance predicates.

```prolog
assert_ws( fact(Prem, Time) ) :-
conv(Prem, Class, Name, UList),
addf(Class, Name, UList).
update_ws( fact(Prem, Time) ) :-
conv(Prem, Class, Name, UList),
uptf(Class, Name, UList).
retract_ws( fact(Prem, Time) ) :-
conv(Prem, Class, Name, UList),
delf(Class, Name, UList).
```

### Adding Prolog to Foops

Now that frames and *Oops* have been integrated into a new system, *Foops*, the next step is to integrate Prolog as well. This has already been done for the frame based system with the various demons that can be associated with frame slots. The Prolog predicates referred to in the demon slots can simply be added directly to the knowledge base.

Adding Prolog to the rules is done by simply adding support for a call statement in both the test (for the LHS) and take (for the RHS) predicates.

```prolog
...
test(call(X)) :- call(X).
...
...
take(call(X)) :- call(X).
...
```

80

<!-- page 91 -->
*Chapter 7 - Integration* Calls to Prolog predicates can now be added on either side of a rule. The Prolog can be simple predicates performing some function right in the knowledge base, or they can initiate more complex processing, including accessing other applications.

Figure 7.1 shows the major components of the *Foops* shell. Frames and Prolog code have been added to the knowledge base. Working storage is composed of frame instances, and the inference engine includes the frame manipulation predicates.

User Interface

command_loop

read

write

Inference Engine

getf

go addf

match delf

process uptf

Knowledge Base

Working Storage

frinst

initial_data

frame

rule

Prolog

*Figure 7.1 Major predicates of Foops shell* 7.2 Room Configuration

Now that *Foops* is built, let's use it to attack the room configuration problem again. Many of the aspects of the original system were handled clumsily in the original version. In particular:

- The initial data gathering was awkward using rules that triggered other data gathering

```prolog
rules.
```

- The wall space calculations were done in the rules.

- Each rule was responsible for maintaining the consistency of the wall space and the furniture against the wall.

The new system will allow for a much cleaner expression of most of the system, and use Prolog to keep the rough edges out of the rule and frame knowledge structures.

Much of the knowledge about the furniture in the room is better stored in frames. This knowledge is then automatically applied by the rules accessing instances of furniture. The rules then become simpler, and just deal with the IF THEN situations and not data relationships.

<!-- page 92 -->
*Building Expert Systems in Prolog* The knowledge base contains the basic frame definitions, which will be used by the instances of furniture. The frames act as sophisticated data definition statements for the system.

The highest frame defines the class furniture. It establishes defaults and demons that apply to all furniture.

```prolog
frame(furniture,
[legal_types - [val [couch,
chair,
coffee_table,
end_table,
standing_lamp,
table_lamp,
tv,
knickknack]],
position - [def none, add pos_add],
length - [def 3],
place_on - [def floor]]).
```

The most interesting slot is position. Each piece of furniture has the default of having the position none, meaning it has not been placed in the room. This means the programmer need not add this value for each piece of furniture initially. As it is positioned, the instance acquires a value that is used instead of the inherited default.

Also note that there is a demon, which is called when a position is added for a piece of furniture. This demon will automatically maintain the relation between wall space and furniture position. It will be described in detail a little later.

Next in the knowledge base are some classes of furniture. Note that the default length for a couch will override the general default length of 3 for any piece of furniture without a length specified.

```prolog
frame(couch, [ako - [val furniture],
length - [def 6]]).
frame(chair, [ako - [val furniture]]).
```

A table is another class of furniture, which is a bit different from other furniture in that things can be placed on a table. It has additional slots for available space, the list of items it is holding (things placed on the table), and the slot indicating that it can support other items.

```prolog
frame(table, [ako - [val furniture],
space - [def 4],
length - [def 4],
can_support - [def yes],
holding - [def []]]).
```

There are two types of tables which are recognized in the system:

```prolog
frame(end_table, [ako - [val table],
length - [def 2]]).
frame(coffee_table, [ako - [val table],
length - [def 4]]).
```

Remember that frames can have multiple inheritance paths. This feature can be used to establish other classes, which define attributes shared by certain types of furniture. For

82

<!-- page 93 -->
*Chapter 7 - Integration* example, the class electric is defined, which describes the properties of items that require electricity.

```prolog
frame(electric, [needs_outlet - [def yes]]).
```

Lamps are electric items included in the knowledge base. Note that lamps are further divided between two types of lamps. A table lamp is different because it must be placed on a table.

```prolog
frame(lamp, [ako - [val [furniture, electric]]]).
frame(standing_lamp, [ako - [val lamp]]).
frame(table_lamp, [ako - [val lamp],
place_on - [def table]]).
```

A knickknack is another item that should be placed on a table.

```prolog
frame(knickknack, [ako - [val furniture],
length - [def 1],
place_on - [def table]]).
```

The television frame shows another use of calculated values. A television might be free standing or it might have to be placed on a table. This ambiguity is resolved by a calculate routine, which asks the user for a value. When a rule needs to know what to place the television on, the user will be asked. This creates the same kind of dialog effect seen in the backward chaining systems earlier in the book.

Note also that the television uses multiple inheritance, both as a piece of furniture and an electrical item.

```prolog
frame(tv, [ako - [val [furniture, electric]],
place_on - [calc tv_support]]).
```

Another frame defines walls. There is a slot for the number of outlets on the wall and the available space. If no space is defined, it is calculated. The holding slot is used to list the furniture placed against the wall.

```prolog
frame(wall, [length - [def 10],
outlets - [def 0],
space - [calc space_calc],
holding - [def []]]).
```

Doors, goals, and recommendations are other types of data that are used in the system.

```prolog
frame(door, [ako - [val furniture],
length - [def 4]]).
frame(goal, []).
frame(recommend, []).
```

### Frame Demons

Next in the knowledge base are the Prolog predicates used in the various frame demons.

Here is the predicate that is called to calculate a value for the place_on slot for a television. It asks the user, and uses the answer to update the television frinst so that the user will not be asked again.

```prolog
tv_support(tv, N, place_on-table) :-
nl,
```

<!-- page 94 -->
*Building Expert Systems in Prolog*

```prolog
write('Should the TV go on a table? '),
read(yes),
uptf(tv, N, [place_on-table]).
tv_support(tv, N, place_on-floor) :-
uptf(tv, N, [place_on-floor]).
```

The pos_add demon is called whenever the position of a piece of furniture is updated. It illustrates how demons and frames can be used to create a database that maintains its own semantic integrity. In this case, whenever the position of a piece of furniture is changed, the available space of the wall it is placed next to, or the table it is placed on, is automatically updated. Also the holding list of the wall or table is also updated.

This means that the single update of a furniture position results in the simultaneous update of the wall or table space and wall or table holding list. Note the use of variables for the class and name make it possible to use the same predicate for both tables and walls.

```prolog
pos_add(C, N, position-CP/P) :-
getf(CP, P, [space-OldS]),
getf(C, N, [length-L]),
NewS is OldS - L,
NewS >= 0,
uptf(CP, P, [holding-[C/N], space-NewS]).
pos_add(C, N, position-CP/P) :-
nl,
write_line(['Not enough room on', CP, P, for, C, N]),
!,
fail.
```

This predicate also holds the pure arithmetic needed to maintain the available space. This used to be included in the bodies of the rules in *Oops*. Now it is only specified once, and is part of a demon defined in the highest frame, furniture. It never has to be worried about in any other frame definition or rules.

The pos_add demon also is designed to fail and report an error if something doesn't fit. The original uptf predicate, which was called to update the position, also fails, and no part of the update takes place. This insures the integrity of the database.

Initially, there is no space included in the wall and table frinsts. The following demon will calculate it based on the holding list. This could also have been used instead of the above predicate, but it is more efficient to calculate and store the number than to recalculate it each time.

```prolog
space_calc(C, N, space-S) :-
getf(C, N, [length-L, holding-HList]),
sum_lengths(HList, 0, HLen),
S is L - HLen.
sum_lengths([], L, L).
sum_lengths([C/N|T], X, L) :-
getf(C, N, [length-HL]),
XX is X + HL,
sum_lengths(T, XX, L).
```

### Initial Data

Now let's look at the data initialization for the system. It establishes other slots for the wall frames giving spatial relationships between them, and establishes the goal gather_data.

```prolog
initial_data([goal - gather_data,
wall - north with [opposite-south,
right-west,
```

84

<!-- page 95 -->
*Chapter 7 - Integration*

```prolog
left-east],
wall - south with [opposite-north,
right-east,
left-west],
wall - east with [opposite-west,
right-north,
left-south],
wall - west with [opposite-east,
right-south,
left-north]
]).
```

### Input Data

The first rule uses the call feature to call a Prolog predicate to perform the data gathering operations, which used to be done with rules in *Oops*. *Foops* uses the *Lex* rule selection, but this rule will fire first because no other rules have any furniture to work with. It then asserts the goal couch_first after gathering the other data. Because *Lex* gives priority to rules accessing recently updated elements in working storage, the rules that have as a goal couch_first will fire next.

```prolog
rule 1:
[goal - gather_data]
==>
[call(gather_data),
assert( goal - couch_first )].
```

The Prolog predicate proceeds with prompts to the user and calls to frame predicates to populate working storage.

```prolog
gather_data :-
read_furniture,
read_walls.
read_furniture :-
get_frame(furniture, [legal_types-LT]),
write('Enter name of furniture at the prompt. '), nl,
write(' It must be one of:'), nl,
write(LT), nl,
write('Enter end to stop input.'), nl,
write('At the length prompt enter y or a new number.'), nl,
repeat,
write('>'),
read(X),
process_furn(X),
!.
```

Note that this predicate has the additional intelligence of finding the default value for the length of a piece of furniture and allowing the user to accept the default, or choose a new value.

```prolog
process_furn(end).
process_furn(X) :-
get_frame(X, [length-DL]),
write(length-DL), write('>'),
read(NL),
get_length(NL, DL, L),
addf(X, _, [length-L]),
fail.
get_length(y, L, L) :- !.
get_length(L, _, L).
```

<!-- page 96 -->
*Building Expert Systems in Prolog* The dialog to get the empty room layout is straight-forward Prolog.

```prolog
read_walls :-
nl, write('Enter data for the walls.'), nl,
write('What is the length of the north & south walls? '),
read(NSL),
uptf(wall, north, [length-NSL]),
uptf(wall, south, [length-NSL]),
write('What is the length of the east & west walls? '),
read(EWL),
uptf(wall, east, [length-EWL]),
uptf(wall, west, [length-EWL]),
write('Which wall has the door? '),
read(DoorWall),
write('What is its length? '),
read(DoorLength),
addf(door, D, [length-DoorLength]),
uptf(door, D, [position-wall/DoorWall]),
write('Which walls have outlets? (a list)'),
read(PlugWalls),
process_plugs(PlugWalls).
process_plugs([]) :- !.
process_plugs([H|T]) :-
uptf(wall, H, [outlets-1]),
!,
process_plugs(T).
process_plugs(X) :-
uptf(wall, X, [outlets-1]).
```

### The Rules

With the data definition, initial data, and input taken care of, we can proceed to the body of rules. They are much simpler than the original versions.

The first rules place the couch either opposite the door or to its right, depending on which wall has more space. Note that the update of the couch position is done with a single action. The frame demons take care of the rest of the update.

```prolog
rule f1:
[goal - couch_first,
couch - C with [position-none, length-LenC],
door - D with [position-wall/W],
wall - W with [opposite-OW, right-RW],
wall - OW with [space-SpOW],
wall - RW with [space-SpRW],
SpOW >= SpRW,
LenC =< SpOW]
==>
[update(couch - C with [position-wall/OW])].
rule f2:
[goal - couch_first,
couch - C with [position-none, length-LenC],
door - D with [position-wall/W],
wall - W with [opposite-OW, right-RW],
wall - OW with [space-SpOW],
wall - RW with [space-SpRW],
SpRW >= SpOW,
LenC =< SpRW]
==>
[update(couch - C with [position-wall/RW])].
```

86

<!-- page 97 -->
*Chapter 7 - Integration* The next rules position the television opposite the couch. They cover the two cases of a free standing television and one that must be placed on a table. If the television needs to be placed on a table, and there is no table big enough, then a recommendation to buy an end table for the television is added. Because of specificity in *Lex* (the more specific rule has priority), rule f4 will fire before f4a. If f4 was successful, then f4a will no longer apply. If f4 failed, then f4a will fire the next time.

The rule to position the television puts the end table on the wall opposite the couch and the television on the end table.

```prolog
rule f3:
[couch - C with [position-wall/W],
wall - W with [opposite-OW],
tv - TV with [position-none, place_on-floor]]
==>
[update(tv - TV with [position-wall/OW])].
rule f4:
[couch - C with [position-wall/W],
wall - W with [opposite-OW],
tv - TV with [position-none, place_on-table],
end_table - T with [position-none]]
==>
[update(end_table - T with [position-wall/OW]),
update(tv - TV with [position-end_table/T])].
rule f4a:
[tv - TV with [position-none, place_on-table]]
==>
[assert(recommend - R with [buy-['table for tv']])].
```

The coffee table should be placed in front of the couch, no matter where it is.

```prolog
rule f5:
[coffee_table - CT with [position-none], couch - C]
==>
[update(coffee_table - CT with [position-frontof(couch/C)])].
```

The chairs go on adjacent walls to the couch.

```prolog
rule f6:
[chair - Ch with [position-none],
couch - C with [position-wall/W],
wall - W with [right-RW, left-LW],
wall - RW with [space-SpR],
wall - LW with [space-SpL],
SpR > SpL]
==>
[update(chair - Ch with [position-wall/RW])].
rule f7:
[chair - Ch with [position-none],
couch - C with [position-wall/W],
wall - W with [right-RW, left-LW],
wall - RW with [space-SpR],
wall - LW with [space-SpL],
SpL > SpR]
==>
[update(chair - Ch with [position-wall/LW])].
```

The end tables go next to the couch if there are no other end tables there. Otherwise they go next to the chairs. Note that the rule first checks to make sure there isn't an unplaced television that needs an end table for support. The television rule will position the end table for holding the television.

<!-- page 98 -->
*Building Expert Systems in Prolog*

```prolog
rule f9:
[end_table - ET with [position-none],
not tv - TV with [position-none, place_on-table],
couch - C with [position-wall/W],
not end_table - ET2 with [position-wall/W]]
==>
[update(end_table - ET with [position-wall/W])].
rule f10:
[end_table - ET with [position-none],
not tv - TV with [position-none, place_on-table],
chair - C with [position-wall/W],
not end_table - ET2 with [position-wall/W]]
==>
[update(end_table - ET with [position-wall/W])].
```

Table lamps go on end tables.

```prolog
rule f11:
[table_lamp - TL with [position-none],
end_table - ET with [position-wall/W]]
==>
[update( table_lamp - TL with [position-end_table/ET] )].
```

Knickknacks go on anything that will hold them. Note the use of variables in the class and name positions. The query to the slot can_support will cause this rule to find anything which has the attribute value can_support - yes. This slot is set in the table frame, so both end tables and coffee tables will be available to hold the knickknack.

```prolog
rule f11a:
[knickknack - KK with [position-none],
Table - T with [can_support-yes, position-wall/W]]
==>
[update( knickknack - KK with [position-Table/T] )].
```

The rules for determining if extensions cords are necessary are simplified by the use of variables and frame inheritance. The rule looks for anything that needs an outlet. This will be true of any items that need an outlet, which is a property inherited from frame electric. It is not necessary to write separate rules for each case.

It is necessary to write a separate rule to cover those things that are positioned on other things. The wall can only be found from the supporting item. This is the case where a television or table lamp is placed on a table. While this is handled in rules here, it would also have been possible to use frame demons to cover this case instead.

```prolog
rule f12:
[Thing - X with [needs_outlet-yes, position-wall/W],
wall - W with [outlets-0]]
==>
[assert(recommend - R with [buy-['extension cord'-W]])].
rule f13:
[Thing - X with [needs_outlet-yes, position-C/N],
C - N with [position-wall/W],
wall - W with [outlets-0]]
==>
[assert(recommend - R with [buy-['extension cord'-Thing/W]])].
```

Due to specificity priorities in *Lex*, the following rule will fire last. It calls a Prolog predicate to output the results of the session.

```prolog
rule f14:
[]
```

88

<!-- page 99 -->
*Chapter 7 - Integration*

```prolog
==>
[call(output_data)].
```

### Output Data

The output_data predicate is again straight forward Prolog, which gets the relevant information and displays it.

```prolog
output_data :-
write('The final results are:'), nl,
output_walls,
output_tables,
output_recommends,
output_unplaced.
output_walls :-
getf(wall, W, [holding-HL]),
write_line([W, wall, holding|HL]),
fail.
output_walls.
output_tables :-
getf(C, N, [holding-HL]),
not C = wall,
write_line([C, N, holding|HL]),
fail.
output_tables.
output_recommends :-
getf(recommend, _, [buy-BL]),
write_line([purchase|BL]),
fail.
output_recommends.
output_unplaced :-
write('Unplaced furniture:'), nl,
getf(T, N, [position-none]),
write(T-N), nl,
fail.
output_unplaced.
```

Figure 7.2 summarizes how the tools in *Foops* are applied to the furniture layout program. Frames are used for objects and relationships, rules are used to define situations and responses, and Prolog is used for odds and ends like I/O and calculations.

Frames information about objects - ex. furniture relationships between objects - ex. length of furniture and wall space

Rules situations and responses - when to place what and when

Prolog I/O - gather data calculations - wall space updates

*Figure 7.2 Summary of knowledge representation tools used in Foops*

<!-- page 100 -->
*Building Expert Systems in Prolog* 7.3 A Sample Run

Here is a portion of a sample run of the furniture placement system.

The system starts in the *Foops* command loop, and then begins the initial data gathering.

```prolog
=>go.
Enter name of furniture at the prompt. It must be one of:
[couch, chair, coffee_table, end_table, standing_lamp, table_lamp,
tv, knickknack]
Enter end to stop input.
At the length prompt enter y or a new number.
>couch.
length-6>y.
>chair.
length-3>5.
...
>end.
Enter data for the walls.
What is the length of the north & south walls? 12.
What is the length of the east & west walls? 9.
Which wall has the door? east.
What is its length? 3.
Which walls have outlets? (a list)[east].
adding-(goal-couch_first)
Rule fired 1
```

One of the rules accessing the television causes this prompt to appear.

```prolog
Should the TV go on a table? yes.
```

The system has informational messages regarding which rules are firing and what data is being updated.

```prolog
updating-(couch-110 with [position-wall/north])
Rule fired f2
updating-(end_table-116 with [position-wall/south])
updating-(tv-117 with [position-end_table/116])
Rule fired f4
...
```

Here is a message that appeared when a knickknack was unsuccessfully placed on an end table. A different knickknack was then found to fit on the same table.

```prolog
Not enough room on end_table 116 for knickknack 121
Rule fired f11a
updating-(knickknack-120 with [position-end_table/116])
Rule fired f11a
```

Here is one of the extension cord recommendations:

```prolog
adding-(recommend-_3888 with [buy-[extension cord-
table_lamp/north]])
Rule fired f13
```

The last rule to fire provides the final results.

90

<!-- page 101 -->
*Chapter 7 - Integration*

```prolog
The final results are:
north wall holding end_table/114 couch/110
east wall holding chair/112 door/122
west wall holding end_table/115 chair/113
south wall holding end_table/116
end_table 114 holding table_lamp/119
end_table 115 holding knickknack/121
end_table 116 holding knickknack/120 tv/117
purchase extension cord-table_lamp/north
purchase extension cord-tv/south
Unplaced furniture:
table_lamp-118
chair-111
```

**7.4 Summary**

A combination of techniques can lead to a much cleaner representation of knowledge for a particular problem. The Prolog code for each of the techniques can be integrated relatively easily to provide a more complex system.

## Exercises

7.1 Integrate *Clam* with frames. 7.2 Implement multiple rule sets as described in the chapter five exercises. Let each rule

set be either forward or backward chaining, and use the appropriate inference engine

for both. 7.3 Build another expert system using *Foops*.

*Building Expert Systems in Prolog*
