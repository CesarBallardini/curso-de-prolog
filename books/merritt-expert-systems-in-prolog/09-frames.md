# Frames

<!-- page 75 -->
Up until this point in the book, we have worked with data structures that are simply that — data structures. It is often desirable to add some "intelligence" to the data structures, such as default values, calculated values, and relationships between data.

Of the various schemes which evolved over the years, the frame based approach has been one of the more popular. Information about an object in the system is stored in a *frame*. The frame has multiple *slots* used to define the various attributes of the object. The slots can have multiple *facets* for holding the value for the attributes, defaults or procedures that are called to calculate the value.

The various frames are linked together in a hierarchy with a-kind-of (ako) links that allow for inheritance. For example, rabbits and hamsters might be stored in frames that have ako(mammal). In the frame for mammal are all of the standard attribute-values for mammals, such as skin-fur and birth-live. These are inherited by rabbits and hamsters and do not have to be specified in their frames. There can also be defaults for attributes which might be overwritten by specific species. Legs-4 applies to most mammals, but monkeys would have legs-2 specified.

Another feature of a frame based system is *demons*. These are procedures that are activated by various updating procedures. For example, a financial application might have demons on various account balances that are triggered when the value is too low. These could also have editing capabilities that made sure the data being entered is consistent with existing data. Figure 6.1 shows some samples of frames for animals.

facets

*mammal*

value

default

when

updated

skin

fur

birth

live

slots

legs

leg-check

leg-check: value =< 4

facets

*rabbit*

value

default

when

updated

ako

mammal

ears

long

slots

move

hops

facets

*monkey*

value

default

when

updated

ako

mammal

legs

slots

tail

curly

*Figure 6.1 Examples of animal frames*

<!-- page 76 -->
*Building Expert Systems in Prolog* 6.1 The Code

In order to implement a frame system in Prolog, there are two initial decisions to be made. The first is the design of the user interface, and the second is the design of the internal data structure used to hold the frame information.

The access to data in the frame system will be through three predicates:

- get_frame — retrieves attribute values for a frame;

- add_frame — adds or updates attribute values for a frame;

- del_frame — deletes attribute values from a frame.

From the user's perspective, these operations will appear to be acting on structures that are very similar to database records. Each frame is like a record, and the slots in the frame correspond to the fields in the record. The intelligence in the frame system, such as inheritance, defaults, and demons, happens automatically for the user.

The first argument of each of these predicates is the name of the frame. The second argument has a list of the slots requested. Each slot is represented by a term of the form attribute-value. For example, to retrieve values for the height and weight slots in the frame dennis, the following query would be used:

```prolog
?- get_frame(dennis, [weight-W, height-H]).
W = 155
H = 5-10
```

To add a new sport for mary:

```prolog
?- add_frame(mary, [sport-rugby]).
```

To delete a slot's value for mynorca's computer:

```prolog
?- del_frame(mynorca, [computer-'PC AT']).
```

These three primitive frame access predicates can be used to build more complex frame applications. For example, the following query would find all of the women in the frame database who are rugby players:

```prolog
?- get_frame(X, [ako-woman, sport-rugby]).
X = mary ;
X = kelly;
```

A match-making system might have a predicate that looks for men and women who have a hobby in common:

```prolog
in_common(M, W, H) :-
get_frame(M, [ako-man, hobby-H]),
get_frame(W, [ako-woman, hobby-H]).
```

**6.2 Data Structure**

The next decision is to chose a type of data structure for the frames. The frame is a relatively complex structure. It has a name and multiple slots. Each slot, which corresponds to an attribute of the frame, can have a value. This is the same as in a normal database. However in a frame system, the value is just one possible facet for the slot.

66

<!-- page 77 -->
*Chapter 6 - Frames* There might also be default values, predicates which are used to calculate values, and demons which fire when the value in the slot is updated.

Furthermore, the frames can be organized in a hierarchy, where each frame has an a-kindof slot that has a list of the types of frames from which this frame inherits values.

The data structure chosen for this implementation has the predicate name frame with two arguments. The first is the name of the frame, and the second is a list of slots separated by a hyphen operator from their respective facet lists. The facet list is composed of prefix operator facet names. The ones defined in the system are:

- val — the simple value of the slot;

- def — the default if no value is given;

- calc — the predicate to call to calculate a value for the slot;

- add — the predicate to call when a value is added for the slot;

- del — the predicate to call when the slot's value is deleted.

Here is the format of a frame data structure:

```prolog
frame(name, [
slotname1 - [
facet1 val11,
facet2 val12,
...],
slotname2 - [
facet1 val21,
facet2 val 22,
...],
...]).
```

For example:

```prolog
frame(man, [
ako-[val [person]],
hair-[def short, del bald],
weight-[calc male_weight] ]).
frame(woman, [
ako-[val [person]],
hair-[def long],
weight-[calc female_weight] ]).
```

In this case, both man and woman have ako slots with the value of person. The hair slot has default values of long and short hair for women and men, but this would be overridden by the values in individual frames. Both have facets that point to predicates that are to be used to calculate weight, if none is given. The man's hair slot has a facet that points to a demon, bald, to be called if the value for hair is deleted.

One additional feature permits values to be either single-valued or multi-valued. Single values are represented by terms, multiple values are stored in lists. The add_frame and del_frame predicates take this into account when updating the frame. For example hair has a single value but hobbies and ako can have multiple values.

<!-- page 78 -->
*Building Expert Systems in Prolog* 6.3 The Manipulation Predicates

get_frame

frame

slot_vals

prep_req

find_slot

slot_vals

% get value from a facet

```prolog
                                     % inherit a value
             facet_val
                            facet_val
                                                find_slot
                                   % ako-X
  % value
          % default value
                        % calculate value
Figure 6.2  Major predicates of get_frame
```

The first predicate to look at is get_frame. It takes as input a query pattern, which is a list of slots and requested values. This request list (ReqList) is then compared against the SlotList associated with the frame. As each request is compared against the slot list, Prolog's unification instantiates the variables in the list. Figure 6.2 shows the major predicates used with get_frame.

```prolog
get_frame(Thing, ReqList) :-
frame(Thing, SlotList),
slot_vals(Thing, ReqList, SlotList).
```

The slot_vals predicate takes care of matching the request list against the slot list. It is a standard recursive list predicate, dealing with one item from the request list at a time. That item is first converted from the more free-form style allowed in the input list to a more formal structure describing the request. That structure is req/4 where the arguments are:

- name of the frame;

- the requested slot;

- the requested facet;

- the requested value.

The code for slot_vals recognizes request lists, and also single slot requests not in list form. This means both of the following frame queries are legal:

```prolog
?- get_frame( dennis, hair-X ).
...
?- get_frame( dennis, [hair-X, height-Y] ).
...
```

68

<!-- page 79 -->
*Chapter 6 - Frames* The slot_vals predicate is a standard list recursion predicate that fulfills each request on the list in turn. The real work is done by find_slot, which fulfills the request from the frame's slot list.

```prolog
slot_vals(_, [], _).
slot_vals(T, [Req|Rest], SlotList) :-
prep_req(Req, req(T, S, F, V)),
find_slot(req(T, S, F, V), SlotList),
!,
slot_vals(T, Rest, SlotList).
slot_vals(T, Req, SlotList) :-
prep_req(Req, req(T, S, F, V)),
find_slot(req(T, S, F, V), SlotList).
```

The request list is composed of items of the form Slot - X. The prep_req predicate, which builds the formal query structure, must recognize three cases:

- X is a variable, in which case the value of the slot is being sought.

- X is of the form Facet(Val), in which case a particular facet is being sought.

- X is a non-variable, in which case the slot value is being sought for comparison with the given value.

Here is the code which prepares the formal query structure:

```prolog
prep_req(Slot-X, req(T, Slot, val, X)) :-
var(X),
!.
prep_req(Slot-X, req(T, Slot, Facet, Val)) :-
nonvar(X),
X =.. [Facet, Val],
facet_list(FL),
member(Facet, FL),
!.
prep_req(Slot-X, req(T, Slot, val, X)).
facet_list([val, def, calc, add, del, edit]).
```

For example, the query

```prolog
?- get_frame(dennis, [hair-X]).
```

would generate the more formal request for:

```prolog
req(dennis, hair, val, X)
```

Having now prepared a more formal request, and a slot list to fulfill it, find_slot attempts to satisfy the request. The first clause handles the case where the request is not for a variable, but really just a test to see if a certain value exists. In this case another request with a different variable (Val) is started, and the results compared with the original request. Two cases are recognized: either the value was a single value, or the value was a member of a list of values.

```prolog
find_slot(req(T, S, F, V), SlotList) :-
nonvar(V),
find_slot(req(T, S, F, Val), SlotList),
!,
(Val == V;
member(V, Val)).
```

<!-- page 80 -->
*Building Expert Systems in Prolog* The next clause covers the most common case, in which the value is a variable, and the slot is a member of the slot list. Notice that the call to member both verifies that there is a structure of the form Slot-FacetList and unifies FacetList with the list of facets associated with the slot. This is because S is bound at the start of the call to member, and FacetList is not. Next, facet_val is called, which gets the value from the facet list.

```prolog
find_slot(req(T, S, F, V), SlotList) :-
member(S-FacetList, SlotList),
!,
facet_val(req(T, S, F, V), FacetList).
```

If the requested slot was not in the given slot list for the frame, then the next clause uses the values in the ako (a-kind-of) slot to see if there is a super class from which to inherit a value. The value in the ako slot might be a list, or a single value. The higher frame's slot list is then used in an attempt to satisfy the request. Note that this recurses up through the hierarchy. Note also that a frame may have multiple values in the ako slot, allowing for a more complex structure than a pure hierarchy. The system works through the list in order, trying to satisfy a request from the first ako value first.

```prolog
find_slot(req(T, S, F, V), SlotList) :-
member(ako-FacetList, SlotList),
facet_val(req(T, ako, val, Ako), FacetList),
(member(X, Ako);
X = Ako),
frame(X, HigherSlots),
find_slot(req(T, S, F, V), HigherSlots),
!.
```

The final clause in find_slot calls the error handling routine. The error handling routine should probably be set not to put up error messages in general, since often quiet failure is required. During debugging it is useful to have it turned on.

```prolog
find_slot(Req, _) :-
error(['frame error looking for:', Req]).
```

The facet_val predicate is responsible for getting the value for the facet. It deals with four possible cases:

- The requested facet and value are on the facet list. This covers the val facet as well as specific requests for other facets.

- The requested facet is val, it is on the facet list, and its value is a list. In this case member is used to get a value.

- There is a default (def) facet, which is used to get the value.

- There is a predicate to call (calc) to get the value. It expects the formal request as an

```prolog
argument.
```

If the facet has a direct value in the facet list, then there is no problem. If there is not a direct value, and the facet being asked for is the val facet, then alternate ways of getting the value are used. First the default is tried and, if there is no default, a calc predicate is used to compute the value. If a calc predicate is needed, then the call to it is built using the univ (=..) built-in predicate, with the request pattern as the first argument, and other arguments included in the calc predicate following.

```prolog
facet_val(req(T, S, F, V), FacetList) :-
FV =.. [F, V],
member(FV, FacetList),
!.
```

70

<!-- page 81 -->
*Chapter 6 - Frames*

```prolog
facet_val(req(T, S, val, V), FacetList) :-
member(val ValList, FacetList),
member(V, ValList),
!.
facet_val(req(T, S, val, V), FacetList) :-
member(def V, FacetList),
!.
facet_val(req(T, S, val, V), FacetList) :-
member(calc Pred, FacetList),
Pred =.. [Functor | Args],
CalcPred =.. [Functor, req(T, S, val, V) | Args],
call(CalcPred).
```

An example of a predicate used to calculate values is the female_weight predicate. It computes a default weight equal to twice the height of the individual.

```prolog
female_weight(req(T, S, F, V)) :-
get_frame(T, [height-H]),
V is H * 2.
```

We have now seen the code that gets values from a frame. It first sets up a list of requested slot values and then processes them one at a time. For each slot which is not defined for the frame, inheritance is used to find a parent frame that defines the slot. For the slots that are defined, each of the facets is tried in order to determine a value.

The next major predicate in the frame system adds values to slots. For single valued slots, this is a replace. For multi-valued slots, the new value is added to the list of values.

The add_frame predicate uses the same basic form as get_frame. For updates, first the old slot list is retrieved from the existing frame. Then the predicate add_slots is called with the old list (SlotList) and the update list (UList). It returns the new list (NewList).

```prolog
add_frame(Thing, UList) :-
old_slots(Thing, SlotList),
add_slots(Thing, UList, SlotList, NewList),
retract(frame(Thing, _)),
asserta(frame(Thing, NewList)),
!.
```

The old_slots predicate usually just retrieves the slot list. However, if the frame doesn't exist, it creates a new frame with an empty slot list.

```prolog
old_slots(Thing, SlotList) :-
frame(Thing, SlotList),
!.
old_slots(Thing, []) :-
asserta(frame(Thing, [])).
```

Next, comes add_slots, which does analogous list matching to slot_vals called by get_frame.

```prolog
add_slots(_, [], X, X).
add_slots(T, [U|Rest], SlotList, NewList) :-
prep_req(U, req(T, S, F, V)),
add_slot(req(T, S, F, V), SlotList, Z),
add_slots(T, Rest, Z, NewList).
add_slots(T, X, SlotList, NewList) :-
prep_req(X, req(T, S, F, V)),
add_slot(req(T, S, F, V), SlotList, NewList).
```

The add_slot predicate deletes the old slot and associated facet list from the old slot list. It then adds the new facet and value to that facet list and rebuilds the slot list. Note that

<!-- page 82 -->
*Building Expert Systems in Prolog* delete unifies FacetList with the old facet list. FL2 is the new facet list returned from add_facet. The new slot and facet list, S-FL2 is then made the head of the add_slot output list, with SL2, the slot list after deleting the old slot as the tail.

```prolog
add_slot(req(T, S, F, V), SlotList, [S-FL2|SL2]) :-
delete(S-FacetList, SlotList, SL2),
add_facet(req(T, S, F, V), FacetList, FL2).
```

The add_facet predicate takes the request and deletes the old facet from the list, builds a new facet and adds it to the facet list in the same manner as add_slot. The main trickiness is that add_facet makes a distinction between a facet whose value is a list, and one whose value is a term. In the case of a list, the new value is added to the list, whereas in the case of a term, the old value is replaced. The add_newval predicate does this work, taking the OldVal, the new value V and coming up with the NewVal.

```prolog
add_facet(req(T, S, F, V), FacetList, [FNew|FL2]) :-
FX =.. [F, OldVal],
delete(FX, FacetList, FL2),
add_newval(OldVal, V, NewVal),
!,
check_add_demons(req(T, S, F, V), FacetList),
FNew =.. [F, NewVal].
add_newval(X, Val, Val) :-
var(X),
!.
add_newval(OldList, ValList, NewList) :-
list(OldList),
list(ValList),
append(ValList, OldList, NewList),
!.
add_newval([H|T], Val, [Val, H|T]).
add_newval(Val, [H|T], [Val, H|T]).
add_newval(_, Val, Val).
```

The intelligence in the frame comes after the cut in add_facet. If a new value has been successfully added, then check_add_demons looks for any demon procedures that must be run before the update is completed.

In check_add_demons, get_frame is called to retrieve any demon predicates in the facet add. Note that since get_frame uses inheritance, demons can be put in higher level frames that apply to all sub frames.

```prolog
check_add_demons(req(T, S, F, V), FacetList) :-
get_frame(T, S-add(Add)),
!,
Add =.. [Functor | Args],
AddFunc =.. [Functor, req(T, S, F, V) | Args],
call(AddFunc).
check_add_demons(_, _).
```

The delete predicate used in the add routines must simply return a list that does not have the item to be deleted in it. If there was no item, then returning the same list is the right thing to do. Therefor delete looks like:

```prolog
delete(X, [], []).
delete(X, [X|Y], Y) :-
!.
delete(X, [Y|Z], [Y|W]) :-
delete(X, Z, W).
```

72

<!-- page 83 -->
*Chapter 6 - Frames* The del_frame predicate is similar to both get_frame and add_frame. However, one major difference is in the way items are deleted from lists. When add_frame was deleting things from lists (for later replacements with updated values), the behavior of delete above was appropriate. For del_frame, a failure should occur if there is nothing to delete from the list. For this function we use remove, which is similar to delete, but fails if there was nothing to delete.

```prolog
remove(X, [X|Y], Y) :- !.
remove(X, [Y|Z], [Y|W]) :-
remove(X, Z, W).
```

The rest of del_frame looks like:

```prolog
del_frame(Thing) :-
retract(frame(Thing, _)).
del_frame(Thing) :-
error(['No frame', Thing, 'to delete']).
del_frame(Thing, UList) :-
old_slots(Thing, SlotList),
del_slots(Thing, UList, SlotList, NewList),
retract(frame(Thing, _)),
asserta(frame(Thing, NewList)).
del_slots([], X, X, _).
del_slots(T, [U|Rest], SlotList, NewList) :-
prep_req(U, req(T, S, F, V)),
del_slot(req(T, S, F, V), SlotList, Z),
del_slots(T, Rest, Z, NewList).
del_slots(T, X, SlotList, NewList) :-
prep_req(X, req(T, S, F, V)),
del_slot(req(T, S, F, V), SlotList, NewList).
del_slot(req(T, S, F, V), SlotList, [S-FL2|SL2]) :-
remove(S-FacetList, SlotList, SL2),
del_facet(req(T, S, F, V), FacetList, FL2).
del_slot(Req, _, _) :-
error(['del_slot - unable to remove', Req]).
del_facet(req(T, S, F, V), FacetList, FL) :-
FV =.. [F, V],
remove(FV, FacetList, FL),
!,
check_del_demons(req(T, S, F, V), FacetList).
del_facet(req(T, S, F, V), FacetList, [FNew|FL]) :-
FX =.. [F, OldVal],
remove(FX, FacetList, FL),
remove(V, OldVal, NewValList),
FNew =.. [F, NewValList],
!,
check_del_demons(req(T, S, F, V), FacetList).
del_facet(Req, _, _) :-
error(['del_facet - unable to remove', Req]).
check_del_demons(req(T, S, F, V), FacetList) :-
get_frame(T, S-del(Del)),
!,
Del =.. [Functor|Args],
DelFunc =.. [Functor, req(T, S, F, V)|Args],
call(DelFunc).
check_del_demons(_, _).
```

This code is essentially the same as for the add function, except that the new facet values have elements deleted instead of replaced. Also, the del facet is checked for demons instead of the add facet.

<!-- page 84 -->
*Building Expert Systems in Prolog* Here is an example of a demon called when a man's hair is deleted. It checks with the user before proceeding.

```prolog
bald(req(T, S, F, V)) :-
write_line([T, 'will be bald, ok to proceed?']),
read(yes).
```

**6.4 Using Frames**

The use of inheritance makes the frame based system an intelligent way of storing data. For many expert systems, a large portion of the intelligence can be stored in frames instead of in rules. Let's consider, for example, the bird identification expert system.

In the bird system there is a hierarchy of information about birds. The rules about the order tubenose, family albatross, and particular albatrosses can all be expressed in frames as follows:

```prolog
frame(tubenose,
[
level-[val order],
nostrils-[val external_tubular],
live-[val at_sea],
bill-[val hooked]
]).
frame(albatross,
[
ako-[val tubenose],
level-[val family],
size-[val large],
wings-[val long-narrow]
]).
frame(laysan_albatross,
[
ako-[val albatross],
level-[val species],
color-[val white]
]).
frame(black_footed_albatross,
[
ako-[val albatross],
level-[val species],
color-[val dark]
]).
```

In a forward chaining system, we would feed some facts to the system and the system would identify the bird based on those facts. We can get the same behavior with the frame system and the predicate get_frame.

For example, if we know a bird has a dark color, and long narrow wings, we can ask the query:

```prolog
?- get_frame(X, [color-dark, wings-long_narrow]).
X = black_footed_albatross ;
no
```

Notice that this will find all of the birds that have the requested property. The ako slots and inheritance will automatically apply the various slots from wherever in the hierarchy they appear. In the above example, the color attribute was filled from the black footed albatross frame and the wings attribute was filled from the albatross frame. This feature can be used to find all birds with long narrow wings:

74

<!-- page 85 -->
*Chapter 6 - Frames*

```prolog
?- get_frame(X, [wings-long_narrow]).
X = albatross ;
X = black_footed_albatross ;
X = laysan_albatross ;
no
```

The queries in this case are more general than in the various expert systems used so far. The query finds all frames that fit the given facts. The query could specify a level, but the query can also be used to bind variables for various fits. For example, to get the level in the hierarchy of the frames that have long narrow wings:

```prolog
?- get_frame(X, [wings-long_narrow, level-L]).
X = albatross, L = family ;
X = black_footed_albatross, L = species;
X = laysan_albatross, L = species ;
no
```

**6.5 Summary**

For the expert systems we have seen already, we have used the Prolog database to store information. That database has been relatively simple. By writing special access predicates it is possible to create a much more sophisticated database using frame technology. These frames can then be used to store knowledge about the particular environment.

## Exercises

6.1 Add other facets to the slots to allow for specification of things like explanation of the

slot, certainty factors, and constraints. 6.2 Add an automatic query-the-user facility that is called whenever a slot value is sought

and there is no other frame to provide the answer. This will allow the frame system to

be used as a backward chaining expert system.

*Building Expert Systems in Prolog*

