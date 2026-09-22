# Appendices - Full Source Code

<!-- page 157 -->
<!-- page 159 -->
*Building Expert Systems in Prolog* A Native

### Birds Knowledgebase (birds.nkb)

```prolog
% BIRDS.NKB - a sample bird identification system for use with the
% Native shell.
% top_goal where Native starts the inference.
top_goal(X) :-
bird(X).
order(tubenose) :-
nostrils(external_tubular),
live(at_sea),
bill(hooked).
order(waterfowl) :-
feet(webbed),
bill(flat).
order(falconiforms) :-
eats(meat),
feet(curved_talons),
bill(sharp_hooked).
order(passerformes) :-
feet(one_long_backward_toe).
family(albatross) :-
order(tubenose),
size(large),
wings(long_narrow).
family(swan) :-
order(waterfowl),
neck(long),
color(white),
flight(ponderous).
family(goose) :-
order(waterfowl),
size(plump),
flight(powerful).
family(duck) :-
order(waterfowl),
feed(on_water_surface),
flight(agile).
family(vulture) :-
order(falconiforms),
feed(scavange),
wings(broad).
family(falcon) :-
order(falconiforms),
wings(long_pointed),
head(large),
tail(narrow_at_tip).
family(flycatcher) :-
order(passerformes),
bill(flat),
eats(flying_insects).
family(swallow) :-
order(passerformes),
wings(long_pointed),
tail(forked),
bill(short).
```

<!-- page 160 -->
*Building Expert Systems in Prolog* *Native — Birds Knowledgebase (birds.nkb)*

```prolog
bird(laysan_albatross) :-
family(albatross),
color(white).
bird(black_footed_albatross) :-
family(albatross),
color(dark).
bird(fulmar) :-
order(tubenose),
size(medium),
flight(flap_glide).
bird(whistling_swan) :-
family(swan),
voice(muffled_musical_whistle).
bird(trumpeter_swan) :-
family(swan),
voice(loud_trumpeting).
bird(canada_goose) :-
family(goose),
season(winter),          % rules can be further broken down
country(united_states),  % to include regions and migration
head(black),             % patterns
cheek(white).
bird(canada_goose) :-
family(goose),
season(summer),
country(canada),
head(black),
cheek(white).
bird(snow_goose) :-
family(goose),
color(white).
bird(mallard) :-
family(duck),            % different rules for male
voice(quack),
head(green).
bird(mallard) :-
family(duck),            % and female
voice(quack),
color(mottled_brown).
bird(pintail) :-
family(duck),
voice(short_whistle).
bird(turkey_vulture) :-
family(vulture),
flight_profile(v_shaped).
bird(california_condor) :-
family(vulture),
flight_profile(flat).
bird(sparrow_hawk) :-
family(falcon),
eats(insects).
bird(peregrine_falcon) :-
family(falcon),
eats(birds).
bird(great_crested_flycatcher) :-
family(flycatcher),
tail(long_rusty).
bird(ash_throated_flycatcher) :-
family(flycatcher),
throat(white).
bird(barn_swallow) :-
family(swallow),
tail(forked).
```

150

<!-- page 161 -->
*Appendices - Full Source Code* *Native — Birds Knowledgebase (birds.nkb)*

```prolog
bird(cliff_swallow) :-
family(swallow),
tail(square).
bird(purple_martin) :-
family(swallow),
color(dark).
country(united_states) :-
region(new_england).
country(united_states) :-
region(south_east).
country(united_states) :-
region(mid_west).
country(united_states) :-
region(south_west).
country(united_states) :-
region(north_west).
country(united_states) :-
region(mid_atlantic).
country(canada) :-
province(ontario).
country(canada) :-
province(quebec).
country(canada) :-
province(etc).
region(new_england) :-
state(X),
member(X,[massachusetts,vermont,etc]).
region(south_east) :-
state(X),
member(X,[florida,mississippi,etc]).
region(canada) :-
province(X),
member(X,[ontario,quebec,etc]).
nostrils(X) :-
ask(nostrils,X).
live(X) :-
ask(live,X).
bill(X) :-
ask(bill,X).
size(X) :-
menuask(size,X,[large,plump,medium,small]).
eats(X) :-
ask(eats,X).
feet(X) :-
ask(feet,X).
wings(X) :-
ask(wings,X).
neck(X) :-
```

<!-- page 162 -->
*Building Expert Systems in Prolog* *Native — Birds Knowledgebase (birds.nkb)*

```prolog
ask(neck,X).
color(X) :-
ask(color,X).
flight(X) :-
menuask(flight,X,[ponderous,powerful,agile,flap_glide,other]).
feed(X) :-
ask(feed,X).
head(X) :-
ask(head,X).
tail(X) :-
menuask(tail,X,[narrow_at_tip,forked,long_rusty,square,other]).
voice(X) :-
ask(voice,X).
season(X) :-
menuask(season,X,[winter,summer]).
cheek(X) :-
ask(cheek,X).
flight_profile(X) :-
menuask(flight_profile,X,[flat,v_shaped,other]).
throat(X) :-
ask(throat,X).
state(X) :-
menuask(state,X,[massachusetts,vermont,florida,mississippi,etc]).
province(X) :-
menuask(province,X,[ontario,quebec,etc]).
multivalued(voice).
multivalued(color).
multivalued(eats).
```

152

<!-- page 163 -->
*Appendices - Full Source Code*

```prolog
% Native - a simple shell for use with Prolog
% knowledge bases. It includes explanations.
:-op(900,xfy, :).
main :-
greeting,
repeat,
write('> '),
read(X),
do(X),
X == quit.
greeting :-
write('This is the native Prolog shell.'), nl,
native_help.
do(help) :-
native_help,
!.
do(load) :-
load_kb,
!.
do(solve) :-
solve,
!.
do(how(Goal)) :-
how(Goal),
!.
do(whynot(Goal)) :-
whynot(Goal),
!.
do(quit).
do(X) :-
write(X),
write(' is not a legal command.'), nl,
fail.
native_help :-
write('Type help. load. solve. how(Goal). whynot(Goal). or quit.'), nl,
write('at the prompt.'), nl.
load_kb :-
write('Enter file name in single quotes (ex. ''birds.nkb''.): '),
read(F),
reconsult(F).
solve :-
abolish(known,3),
prove(top_goal(X),[]),
write('The answer is '), write(X), nl.
solve :-
write('No answer found.'), nl.
ask(Attribute,Value,_) :-
known(yes,Attribute,Value),  % succeed if we know its true
!.                           % and dont look any further
ask(Attribute,Value,_) :-
```

<!-- page 164 -->
*Building Expert Systems in Prolog* *Native — Native Shell (native.pro)*

```prolog
known(_,Attribute,Value),    % fail if we know its false
!,
fail.
ask(Attribute,_,_) :-
not multivalued(Attribute),
known(yes,Attribute,_),      % fail if its some other value.
!,                           % this ensures this is the wrong value
fail.
ask(A,V,Hist) :-
write(A :V),                 % if we get here, we need to ask.
write('? (yes or no) '),
get_user(Y,Hist),            % get the answer
asserta(known(Y,A,V)),       % remember it so we dont ask again.
Y = yes.                     % succeed or fail based on answer.
% "menuask" is like ask, only it gives the user a menu to to choose
% from rather than a yes on no answer.  In this case there is no
% need to check for a negative since "menuask" ensures there will
% be some positive answer.
menuask(Attribute,Value,_,_) :-
known(yes,Attribute,Value),  % succeed if we know
!.
menuask(Attribute,_,_,_) :-
known(yes,Attribute,_),      % fail if its some other value
!, fail.
menuask(Attribute,AskValue,Menu,Hist) :-
nl,
write('What is the value for '), write(Attribute), write('?'), nl,
display_menu(Menu),
write('Enter the number of choice> '),
get_user(Num,Hist),nl,
pick_menu(Num,AnswerValue,Menu),
asserta(known(yes,Attribute,AnswerValue)),
AskValue = AnswerValue.  % succeed or fail based on answer
display_menu(Menu) :-
disp_menu(1,Menu),
!.  % make sure we fail on backtracking
disp_menu(_,[]).
disp_menu(N,[Item|Rest]) :-
% recursively write the head of the list and disp_menu the tail
write(N), write('  : '), write(Item), nl,
NN is N + 1,
disp_menu(NN,Rest).
pick_menu(N,Val,Menu) :-
integer(N),              % make sure they gave a number
pic_menu(1,N,Val,Menu),  % start at one
!.
pick_menu(Val,Val,_).  % if they didn't enter a number, use
% what they entered as the value
pic_menu(_,_,none_of_the_above,[]).  % if we've exhausted the list
pic_menu(N,N,Item,[Item|_]).       % the counter matches the number
pic_menu(Ctr,N,Val,[_|Rest]) :-
NextCtr is Ctr + 1,                % try the next one
pic_menu(NextCtr,N,Val,Rest).
get_user(X,Hist) :-
repeat,
write('> '),
read(X),
```

154

<!-- page 165 -->
*Appendices - Full Source Code* *Native — Native Shell (native.pro)*

```prolog
process_ans(X,Hist),
!.
process_ans(why,Hist) :-
write_list(4,Hist),
!,
fail.
process_ans(X,_).
% Prolog in Prolog for explanations.
% It is a bit confusing because of the ambiguous use of the comma, both
% to separate arguments and as an infix operator between the goals of
% a clause.
prove(true,_) :-
!.
prove((Goal,Rest),Hist) :-
prov(Goal,[Goal|Hist]),
prove(Rest,Hist).
prove(Goal,Hist) :-
prov(Goal,[Goal|Hist]).
prov(true,_) :-
!.
prov(menuask(X,Y,Z),Hist) :-
menuask(X,Y,Z,Hist),
!.
prov(ask(X,Y),Hist) :-
ask(X,Y,Hist),
!.
prov(Goal,Hist) :-
clause(Goal,Body),
prove(Body,Hist).
% EXPLANATIONS
how(Goal) :-
clause(Goal,Body),
prove(Body,[]),
write_body(4,Body).
whynot(Goal) :-
clause(Goal,Body),
write_line([Goal,'fails because: ']),
explain(Body).
whynot(_).
explain(true).
explain((Head,Body)) :-
check(Head),
explain(Body).
check(H) :-
prove(H,[]),
write_line([H,succeeds]),
!.
check(H) :-
write_line([H,fails]),
fail.
write_list(N,[]).
```

<!-- page 166 -->
*Building Expert Systems in Prolog* *Native — Native Shell (native.pro)*

```prolog
write_list(N,[H|T]) :-
tab(N), write(H), nl,
write_list(N,T).
write_body(N,(First,Rest)) :-
tab(N), write(First), nl,
write_body(N,Rest).
write_body(N,Last) :-
tab(N), write(Last), nl.
write_line(L) :-
flatten(L,LF),
write_lin(LF).
write_lin([]) :-
nl.
write_lin([H|T]) :-
write(H), tab(1),
write_lin(T).
flatten([],[]) :-
!.
flatten([[]|T],T2) :-
flatten(T,T2),
!.
flatten([[X|Y]|T], L) :-
flatten([X|[Y|T]],L),
!.
flatten([H|T],[H|T2]) :-
flatten(T,T2).
```

156

<!-- page 167 -->
*Appendices - Full Source Code* B Clam

### Car Knowledgebase (car.ckb)

```prolog
goal problem.
rule 1
if not turn_over and
battery_bad
then problem is battery cf 100.
rule 2
if lights_weak
then battery_bad cf 50.
rule 3
if radio_weak
then battery_bad cf 50.
rule 4
if turn_over and
smell_gas
then problem is flooded cf 80.
rule 5
if turn_over and
gas_gauge is empty
then problem is out_of_gas cf 90.
rule 6
if turn_over and
gas_gauge is low
then problem is out_of_gas cf 30.
output problem is battery get the battery recharged.
output problem is out_of_gas start walking or hitching to a gas station.
output problem is flooded wait 5 minutes and try again.
ask turn_over
menu (yes no)
prompt 'Does the engine turn over?'.
ask lights_weak
menu (yes no)
prompt 'Are the lights weak?'.
ask radio_weak
menu (yes no)
prompt 'Is the radio weak?'.
ask smell_gas
menu (yes no)
prompt 'Do you smell gas?'.
ask gas_gauge
menu (empty low full)
prompt 'What does the gas gauge say?'.
```

<!-- page 168 -->
*Building Expert Systems in Prolog*

```prolog
goal bird.
rule 1
if   nostrils is external_tubular and
live is at_sea and
bill is hooked
then order is tubenose cf 80.
rule 2
if   feet is webbed and
bill is flat
then order is waterfowl cf 80.
rule 3
if   eats is meat and
feet is curved_talons and
bill is sharp_hooked
then order is falconiforms cf 80.
rule 4
if   feet is one_long_backward_toe
then order is passerformes cf 80.
rule 5
if   order is tubenose and
size is large and
wings is long_narrow
then family is albatross cf 80.
rule 6
if   order is waterfowl and
neck is long and
color is white and
flight is ponderous
then family is swan cf 80.
rule 7
if   order is waterfowl and
size is plump and
flight is powerful
then family is goose cf 80.
rule 8
if   order is waterfowl and
feed is on_water_surface and
flight is agile
then family is duck cf 80.
rule 9
if   order is falconiforms and
feed is scavange and
wings is broad
then family is vulture cf 80.
rule 10
if   order is falconiforms and
wings is long_pointed and
head is large and
tail is narrow_at_tip
then family is falcon cf 80.
rule 11
if   order is passerformes and
bill is flat and
eats is flying_insects
```

158

<!-- page 169 -->
*Appendices - Full Source Code* *Clam — Birds Knowledgebase (birds.ckb)*

```prolog
then family is flycatcher cf 80.
rule 12
if   order is passerformes and
wings is long_pointed and
tail is forked and
bill is short
then family is swallow cf 80.
rule 13
if   family is albatross and
color is white
then bird is laysan_albatross cf 80.
rule 14
if   family is albatross and
color is dark
then bird is black_footed_albatross cf 80.
rule 15
if   order is tubenose and
size is medium and
flight is flap_glide
then bird is fulmar cf 80.
rule 16
if   family is swan and
voice is muffled_musical_whistle
then bird is whistling_swan cf 80.
rule 17
if   family is swan and
voice is loud_trumpeting
then bird is trumpeter_swan cf 80.
rule 18
if   family is goose and
season is winter and
country is united_states and
head is black and
cheek is white
then bird is canada_goose cf 80.
rule 19
if   family is goose and
season is summer and
country is canada and
head is black and
cheek is white
then bird is canada_goose cf 80.
rule 20
if   family is goose and
color is white
then bird is snow_goose cf 80.
rule 21
if   family is duck and
voice is quack and
head is green
then bird is mallard cf 80.
rule 22
if   family is duck and
voice is quack and
color is mottled_brown
then bird is mallard cf 80.
```

<!-- page 170 -->
*Building Expert Systems in Prolog* *Clam — Birds Knowledgebase (birds.ckb)*

```prolog
rule 23
if   family is duck and
voice is short_whistle
then bird is pintail cf 80.
rule 24
if   family is vulture and
flight_profile is v_shaped
then bird is turkey_vulture cf 80.
rule 25
if   family is vulture and
flight_profile is flat
then bird is california_condor cf 80.
rule 26
if   family is falcon and
eats is insects
then bird is sparrow_hawk cf 80.
rule 27
if   family is falcon and
eats is birds
then bird is peregrine_falcon cf 80.
rule 28
if   family is flycatcher and
tail is long_rusty
then bird is great_crested_flycatcher cf 80.
rule 29
if   family is flycatcher and
throat is white
then bird is ash_throated_flycatcher cf 80.
rule 30
if   family is swallow and
tail is forked
then bird is barn_swallow cf 80.
rule 31
if   family is swallow and
tail is square
then bird is cliff_swallow cf 80.
rule 32
if   family is swallow and
color is dark
then bird is purple_martin cf 80.
rule 33
if   region is new_england
then country is united_states.
rule 34
if   region is south_east
then country is united_states.
rule 35
if   region is mid_west
then country is united_states.
rule 36
if   region is south_west
then country is united_states.
rule 37
if   region is north_west
```

160

<!-- page 171 -->
*Appendices - Full Source Code* *Clam — Birds Knowledgebase (birds.ckb)*

```prolog
then country is united_states.
rule 38
if   region is mid_atlantic
then country is united_states.
rule 39
if   region is ontario
then country is canada.
rule 40
if   region is quebec
then country is canada.
ask bill
menu (hooked flat sharp_hooked short other)
prompt 'What type of bill?'.
ask cheek
menu (white other)
prompt 'What type of cheek?'.
ask color
menu (white dark mottled_brown other)
prompt 'What color is it?'.
ask region
menu (new_england south_east mid_west south_west
north_west mid_atlantic ontario quebec other)
prompt 'What region was it seen in?'.
ask eats
menu (meat flying_insects insects birds other)
prompt 'What does it eat?'.
ask feed
menu (on_water_surface scavange other)
prompt 'Where does it feed?'.
ask feet
menu (webbed curved_talons one_long_backward_toe other)
prompt 'What type of feet?'.
ask flight
menu (ponderous powerful agile flap_glide other)
prompt 'What type of flight?'.
ask flight_profile
menu (v_shaped flat other)
prompt 'What is the flight profile?'.
ask head
menu (large black green other)
prompt 'What type of head?'.
ask live
menu (at_sea other)
prompt 'Where does it live?'.
ask neck
menu (long other)
prompt 'What type of neck does it have?'.
ask nostrils
menu (external_tubular other)
prompt 'What type of nostrils?'.
ask season
```

<!-- page 172 -->
*Building Expert Systems in Prolog* *Clam — Birds Knowledgebase (birds.ckb)*

```prolog
menu (summer fall winter spring)
prompt 'What season was it seen in?'.
ask size
menu (large medium small plump other)
prompt 'What size is it?'.
ask tail
menu (narrow_at_tip forked long_rusty square other)
prompt 'What type of tail?'.
ask throat
menu (white other)
prompt 'What type of throat?'.
ask voice
menu (muffled_musical_whistle loud_trumpeting quack short_whistle other)
prompt 'What type of voice?'.
ask wings
menu (long_narrow broad long_pointed other)
prompt 'What type of wings does it have?'.
multivalued voice.
multivalued color.
multivalued eats.
```

162

<!-- page 173 -->
*Appendices - Full Source Code*

```prolog
% Clam - expert system shell with EMYCIN type certainty factors
% This system is an imitation of the EMYCIN imitators. It does backward
% chaininging (goal directed) inference with uncertainty. The uncertainty
% is modelled using the MYCIN certainty factors.
% The only data structure is an attribute:value pair.
% NOTE - CF calculation in update only good for positive CF
main :-
do_over,
super.
% The main command loop
super :-
repeat,
write('consult  restart  load  list  trace on/off  how  exit'), nl,
write('> '),
read_line([X|Y]),
doit([X|Y]),
X == exit.
doit([consult]) :-
top_goals,
!.
doit([restart]) :-
do_over,
!.
doit([load]) :-
load_rules,
!.
doit([list]) :-
list_facts,
!.
doit([trace,X]) :-
set_trace(X),
!.
doit([how|Y]) :-
how(Y),
!.
doit([exit]).
doit([X|Y]) :-
write('invalid command : '),
write([X|Y]), nl.
% top_goals works through each of the goals in sequence
top_goals :-
ghoul(Attr),
top(Attr),
print_goal(Attr),
fail.
top_goals.
% top starts the backward chaining by looking for rules that reference
% the attribute in the RHS.  If it is known with certainty 100, then
% no other rules are tried, and other candidates are eliminated.  Otherwise
% other rules which might yield different values for the attribute
```

<!-- page 174 -->
*Building Expert Systems in Prolog* *Clam — Clam Shell (clam.pro)*

```prolog
% are tried as well
top(Attr) :-
findgoal(av(Attr,Val),CF,[goal(Attr)]),
!.
top(_) :-
true.
% prints all hypotheses for a given attribute
print_goal(Attr) :-
nl,
fact(av(Attr,X),CF,_),
CF >= 20,
outp(av(Attr,X),CF), nl,
fail.
print_goal(Attr) :-
write('done with '), write(Attr), nl,
nl.
outp(av(A,V),CF) :-
output(A,V,PrintList),
pretty(av(A,V), X),
printlist(X),
tab(1), write(cf(CF)), write(': '),
printlist(PrintList),
!.
outp(av(A,V),CF) :-
pretty(av(A,V), X),
printlist(X),
tab(1), write(cf(CF)).
printlist([]).
printlist([H|T]) :-
write(H), tab(1),
printlist(T).
% findgoal is the guts of the inference.  It copes with already known
% attribute value pairs, multivalued attributes and single valued
% attributes.  It uses the EMYCIN certainty factor arithmetic to
% propagate uncertainties.
% 1 - if its recorded and the value matches, we're done, if the
%     value doesn't match, but its single valued and known with
%     certainty 100 definitely fail
findgoal(X,Y,_) :-
bugdisp(['  ',X]),
fail.
findgoal(not Goal,NCF,Hist) :-
findgoal(Goal,CF,Hist),
NCF is - CF,
!.
findgoal(Goal,CF,Hist) :-
fact(Goal,CF,_),
!.
%findgoal(av(Attr,Val),CF) :-
%  bound(Val),
%  fact(av(Attr,V,_),CF),
%  Val \= V,
%  single_valued(Attr),
%  CF=100,
%  !,
%  fail.
```

164

<!-- page 175 -->
*Appendices - Full Source Code* *Clam — Clam Shell (clam.pro)*

```prolog
% 2 - if its askable, just ask and record the answer
findgoal(Goal,CF,Hist) :-
can_ask(Goal,Hist),
!,
findgoal(Goal,CF,Hist).
% 3 - find a rule with the required attribute on the RHS.  try to prove
%     the LHS.  If its proved, use the certainty of the LHS combined
%     with the certainty of the RHS to compute the cf of the derived
%     result
findgoal(Goal,CurCF,Hist) :-
fg(Goal,CurCF,Hist).
fg(Goal,CurCF,Hist) :-
rule(N,lhs(IfList), rhs(Goal,CF)),
bugdisp(['call rule',N]),
prove(N,IfList,Tally,Hist),
bugdisp(['exit rule',N]),
adjust(CF,Tally,NewCF),
update(Goal,NewCF,CurCF,N),
CurCF == 100,
!.
fg(Goal,CF,_) :-
fact(Goal,CF,_).
% can_ask shows how to query the user for various types of goal patterns
can_ask(av(Attr,Val),Hist) :-
not asked(av(Attr,_)),
askable(Attr,Menu,Edit,Prompt),
query_user(Attr,Prompt,Menu,Edit,Hist),
asserta( asked(av(Attr,_)) ).
% answer the how question at the top level, to explain how an answer was
% derived. It can be called successive times to get the whole proof.
how([]) :-
write('Goal? '), read_line(X), nl,
pretty(Goal,X),
how(Goal).
how(X) :-
pretty(Goal,X),
nl,
how(Goal).
how(not Goal) :-
fact(Goal,CF,Rules),
CF < -20,
pretty(not Goal,PG),
write_line([PG,was,derived,from,'rules: '|Rules]),
nl,
list_rules(Rules),
fail.
how(Goal) :-
fact(Goal,CF,Rules),
CF > 20,
pretty(Goal,PG),
write_line([PG,was,derived,from,'rules: '|Rules]),
nl,
list_rules(Rules),
fail.
how(_).
```

<!-- page 176 -->
*Building Expert Systems in Prolog* *Clam — Clam Shell (clam.pro)*

```prolog
list_rules([]).
list_rules([R|X]) :-
list_rule(R),
%  how_lhs(R),
list_rules(X).
list_rule(N) :-
rule(N, lhs(Iflist), rhs(Goal,CF)),
write_line(['rule  ',N]),
write_line(['  If']),
write_ifs(Iflist),
write_line(['  Then']),
pretty(Goal,PG),
write_line(['   ',PG,CF]), nl.
write_ifs([]).
write_ifs([H|T]) :-
pretty(H,HP),
tab(4), write_line(HP),
write_ifs(T).
pretty(av(A,yes),[A]) :-
!.
pretty(not av(A,yes), [not,A]) :-
!.
pretty(av(A,no),[not,A]) :-
!.
pretty(not av(A,V),[not,A,is,V]).
pretty(av(A,V),[A,is,V]).
how_lhs(N) :-
rule(N,lhs(Iflist),_),
!,
how_ifs(Iflist).
how_ifs([]).
how_ifs([Goal|X]) :-
how(Goal),
how_ifs(X).
% get input from the user. Either a straight answer from the menu, or
% an answer with cf N appended to it.
query_user(Attr,Prompt,[yes,no],_,Hist) :-
!,
write(Prompt), nl,
get_user(X,Hist),
get_vcf(X,Val,CF),
asserta(fact(av(Attr,Val),CF,[user])).
query_user(Attr,Prompt,Menu,Edit,Hist) :-
write(Prompt), nl,
menu_read(VList,Menu,Hist),
assert_list(Attr,VList).
menu_read(X,Menu,Hist) :-
write_list(2,Menu),
get_user(X,Hist).
get_user(X,Hist) :-
repeat,
write(': '),
```

166

<!-- page 177 -->
*Appendices - Full Source Code* *Clam — Clam Shell (clam.pro)*

```prolog
read_line(X),
process_ans(X,Hist).
process_ans([why],Hist) :-
nl, write_hist(Hist),
!,
fail.
process_ans(X,_).
write_hist([]) :-
nl.
write_hist([goal(X)|T]) :-
write_line([goal,X]),
!,
write_hist(T).
write_hist([N|T]) :-
list_rule(N),
!,
write_hist(T).
write_list(N,[]).
write_list(N,[H|T]) :-
tab(N), write(H), nl,
write_list(N,T).
assert_list(_,[]).
assert_list(Attr,[not,Val,cf,CF|X]) :-
!,
NCF is - CF,
asserta(fact(av(Attr,Val),NCF,[user])),
assert_list(Attr,X).
assert_list(Attr,[not,Val|X]) :-
!,
asserta(fact(av(Attr,Val),-100,[user])),
assert_list(Attr,X).
assert_list(Attr,[Val,cf,CF|X]) :-
!,
asserta(fact(av(Attr,Val),CF,[user])),
assert_list(Attr,X).
assert_list(Attr,[Val|X]) :-
asserta(fact(av(Attr,Val),100,[user])),
assert_list(Attr,X).
get_vcf([no],yes,-100).
get_vcf([no,CF],yes,NCF) :-
NCF is -CF.
get_vcf([no,cf,CF],yes,NCF) :-
NCF is -CF.
get_vcf([Val,CF],Val,CF).
get_vcf([Val,cf,CF],Val,CF).
get_vcf([Val],Val,100).
get_vcf([not,Val],Val,-100).
get_vcf([not,Val,CF],Val,NCF) :-
NCF is -CF.
get_vcf([not,Val,cf,CF],Val,NCF) :-
NCF is -CF.
% prove works through a LHS list of premises, calling findgoal on
% each one.  the total cf is computed as the minimum cf in the list
prove(N,IfList,Tally,Hist) :-
prov(IfList,100,Tally,[N|Hist]),
```

<!-- page 178 -->
*Building Expert Systems in Prolog* *Clam — Clam Shell (clam.pro)*

```prolog
!.
prove(N,_,_) :-
bugdisp(['fail rule',N]),
fail.
prov([],Tally,Tally,Hist).
prov([H|T],CurTal,Tally,Hist) :-
findgoal(H,CF,Hist),
minimum(CurTal,CF,Tal),
Tal >= 20,
prov(T,Tal,Tally,Hist).
% update - if its already known with a given cf, here is the formula
% for adding in the new cf. This is used in those cases where multiple
% RHS reference the same attr :val
update(Goal,NewCF,CF,RuleN) :-
fact(Goal,OldCF,_),
combine(NewCF,OldCF,CF),
retract(fact(Goal,OldCF,OldRules)),
asserta(fact(Goal,CF,[RuleN|OldRules])),
(CF == 100,single_valued(Attr),erase_other(Attr)
;
true
),
!.
update(Goal,CF,CF,RuleN) :-
asserta(fact(Goal,CF,[RuleN])).
erase_other(Attr) :-
fact(av(Attr,Val),CF,_),
CF < 100,
retract(fact(av(Attr,Val),CF,_)),
fail.
erase_other(Attr) :-
true.
adjust(CF1,CF2,CF) :-
X is CF1 * CF2 / 100,
int_round(X,CF).
combine(CF1,CF2,CF) :-
CF1 >= 0,
CF2 >= 0,
X is CF1 + CF2 * (100 - CF1) / 100,
int_round(X,CF).
combine(CF1,CF2,CF) :-
CF1 < 0,
CF2 < 0,
X is - (-CF1 -CF2 * (100 + CF1) / 100),
int_round(X,CF).
combine(CF1,CF2,CF) :-
(CF1 < 0; CF2 < 0),
(CF1 > 0; CF2 > 0),
abs_minimum(CF1,CF2,MCF),
X is 100 * (CF1 + CF2) / (100 - MCF),
int_round(X,CF).
abs_minimum(A,B,X) :-
absolute(A, AA),
absolute(B, BB),
minimum(AA,BB,X).
```

168

<!-- page 179 -->
*Appendices - Full Source Code* *Clam — Clam Shell (clam.pro)*

```prolog
absolute(X, X) :-
X >= 0.
absolute(X, Y) :-
X < 0,
Y is -X.
%minimum(A,B,A) :-
%  A =< B.
%minimum(A,B,B) :-
%  B > A.
%min([],X,X).
%min([H|T],Z,X) :-
%  H < Z,
%  min(T,H,X).
%min([H|T],Z,X) :-
%   H >= Z,
%   min(T,Z,X).
minimum(X,Y,X) :-
X =< Y,
!.
minimum(X,Y,Y) :-
Y =< X.
int_round(X,I) :-
X >= 0,
I is integer(X + 0.5).
int_round(X,I) :-
X < 0,
I is integer(X - 0.5).
set_trace(off) :-
ruletrace,
retract(ruletrace).
set_trace(on) :-
not ruletrace,
asserta(ruletrace).
set_trace(_).
single_valued(A) :-
multivalued(A),
!,
fail.
single_valued(A) :-
true.
list_facts :-
fact(X,Y,_),
write(fact(X,Y)), nl,
fail.
list_facts :-
true.
do_over :-
abolish(asked,1),
abolish(fact,3).
```

<!-- page 180 -->
*Building Expert Systems in Prolog* *Clam — Clam Shell (clam.pro)*

```prolog
clear :-
abolish(asked,1),
abolish(fact,3),
abolish(rule,1),
abolish(multivalued,1),
abolish(askable,1),
abolish(ghoul,1).
blank_lines(0).
blank_lines(N) :-
nl,
NN is N - 1,
blank_lines(NN).
bugdisp(L) :-
ruletrace,
write_line(L),
!.
bugdisp(_).
write_line(L) :-
flatten(L,LF),
write_lin(LF).
write_lin([]) :-
nl.
write_lin([H|T]) :-
write(H), tab(1),
write_lin(T).
flatten([],[]) :-
!.
flatten([[]|T],T2) :-
flatten(T,T2),
!.
flatten([[X|Y]|T], L) :-
flatten([X|[Y|T]],L),
!.
flatten([H|T],[H|T2]) :-
flatten(T,T2).
member(X,[X|Y]).
member(X,[Y|Z]) :-
member(X,Z).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LDRULS - this module reads a rule file and translates it to internal
%          Prolog format for the Clam shell
load_rules :-
write('Enter file name in single quotes (ex. ''car.ckb''.): '),
read(F),
load_rules(F).
load_rules(F) :-
clear_db,
see(F),
lod_ruls,
write('rules loaded'), nl,
seen,
```

170

<!-- page 181 -->
*Appendices - Full Source Code* *Clam — Clam Shell (clam.pro)*

```prolog
!.
lod_ruls :-
repeat,
read_sentence(L),
%  bug(L),
process(L),
L == ['!EOF'].
process(['!EOF']) :-
!.
process(L) :-
trans(R,L,[]),
bug(R),
assertz(R),
!.
process(L) :-
write('trans error on:'), nl,
write(L), nl.
clear_db :-
abolish(cf_model,1),
abolish(ghoul,1),
abolish(askable,4),
abolish(output,3),
abolish(rule,3).
bug(cf_model(X)) :-
write(cf_model(X)), nl,
!.
bug(ghoul(X)):-
write(ghoul(X)), nl,
!.
bug(askable(A,_,_,_)):-
write('askable '), write(A), nl,
!.
bug(output(A,V,PL)):-
write('output '), write(V), nl,
!.
bug(rule(N,_,_)):-
write('rule '), write(N), nl,
!.
bug(X) :-
write(X), nl.
% trans - translates a list of atoms in external rule form to internal
%         rule form
trans(cf_model(X)) -->
[cf,model,X].
trans(cf_model(X)) -->
[cf,model,is,X].
trans(cf_model(X)) -->
[cf,X].
trans(ghoul(X)) -->
[goal,is,X].
trans(ghoul(X)) -->
[goal,X].
trans(askable(A,M,E,P)) -->
[ask,A],
menux(M),
editchk(E),
prompt(A,P).
```

<!-- page 182 -->
*Building Expert Systems in Prolog* *Clam — Clam Shell (clam.pro)*

```prolog
trans(output(A,V,PL)) -->
[output],
phraz(av(A,V)),
plist(PL).
trans(rule(N,lhs(IF),rhs(THEN,CF))) -->
id(N),
if(IF),
then(THEN,CF).
trans(multivalued(X)) -->
[multivalued,X].
trans('Parsing error'-L,L,_).
%default(D) -->
%  [default,D].
%default(none) -->
%  [].
menux(M) -->
[menu,'('],
menuxlist(M).
menuxlist([Item]) -->
[Item,')'].
menuxlist([Item|T]) -->
[Item],
menuxlist(T).
editchk(E) -->
[edit,E].
editchk(none) -->
[].
prompt(_,P) -->
[prompt,P].
prompt(P,P) -->
[].
id(N) -->
[rule,N].
if(IF) -->
[if],
iflist(IF).
iflist([IF]) -->
phraz(IF),
[then].
iflist([Hif|Tif]) -->
phraz(Hif),
[and],
iflist(Tif).
iflist([Hif|Tif]) -->
phraz(Hif),
[','],
iflist(Tif).
then(THEN,CF) -->
phraz(THEN),
[cf],
```

172

<!-- page 183 -->
*Appendices - Full Source Code* *Clam — Clam Shell (clam.pro)*

```prolog
[CF].
then(THEN,100) -->
phraz(THEN).
phraz(not av(Attr,yes)) -->
[not,Attr].
phraz(not av(Attr,yes)) -->
[not,a,Attr].
phraz(not av(Attr,yes)) -->
[not,an,Attr].
phraz(not av(Attr,Val)) -->
[not,Attr,is,Val].
phraz(not av(Attr,Val)) -->
[not,Attr,are,Val].
phraz(av(Attr,Val)) -->
[Attr,is,Val].
phraz(av(Attr,Val)) -->
[Attr,are,Val].
phraz(av(Attr,yes)) -->
[Attr].
plist([Text]) -->
[Text].
plist([Htext|Ttext]) -->
[Htext],
plist(Ttext).
%%
%% end LDRULS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
read_line(L) :-
read_word_list([13,10], L),
!.
read_sentence(S) :-
read_word_list([`.], S),
!.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% From the Cogent Prolog Toolbox
%%
%% rwl.pro - read word list, based on Clocksin & Mellish
%%
%% Read word list reads in a list of chars (terminated with a !, . or ?)
%% and converts it to a list of atomic entries (including numbers).
%% Uppercase is converted to lower case.
%% A 'word' is one item in our generated list
%% This version has been modified for CLAM by allowing an additional
%% argument, Xs, that is a list of the ending characters.  This allows the
%% code to be used for both command input, terminated by the Enter key, and
%% reading the knowledge base files, terminated after multiple lines by
%% a period.
%% It has further been modified to skip everything between a % and the
%% end of line, allowing for Prolog style comments.
read_word_list(LW,[W|Ws]) :-
get0(C),
readword(C, W, C1),        % Read word starting with C, C1 is first new
restsent(LW, C1, Ws).      % character - use it to get rest of sentence
restsent(_, '!EOF', []).
```

<!-- page 184 -->
*Building Expert Systems in Prolog* *Clam — Clam Shell (clam.pro)*

```prolog
restsent(LW,C,[]) :-         % Nothing left if hit last-word marker
member(C,LW),
!.
restsent(LW,C,[W1|Ws]) :-
readword(C,W1,C1),         % Else read next word and rest of sentence
restsent(LW,C1,Ws).
readword('!EOF','!EOF','!EOF').
readword(`%,W,C2) :-         % allow Prolog style comments
!,
skip(13),
get0(C1),
readword(C1,W,C2).
readword(`',W,C2) :-
!,
get0(C1),
to_next_quote(C1,Cs),
name(W, [`'|Cs]),
get0(C2).
readword(C,W,C1) :-          % Some words are single characters
single_char(C),            % i.e. punctuation
!,
name(W, [C]),              % get as an atom
get0(C1).
readword(C, W, C1) :-
is_num(C),                 % if we have a number --
!,
number_word(C, W, C1, _).  % convert it to a genuine number
readword(C,W,C2) :-          % otherwise if character does not
in_word(C,NewC),           % delineate end of word - keep
get0(C1),                  % accumulating them until
restword(C1,Cs,C2),        % we have all the words
name(W, [NewC|Cs]).        % then make it an atom
readword(C,W,C2) :-          % otherwise
get0(C1),
readword(C1,W,C2).         % start a new word
restword(C, [NewC|Cs], C2) :-
in_word(C, NewC),
get0(C1),
restword(C1, Cs, C2).
restword(C, [], C).
to_next_quote(`', [`']).
to_next_quote(C,[C|Rest]) :-
get0(C1),
to_next_quote(C1,Rest).
single_char(`,).
single_char(`;).
single_char(`:).
single_char(`?).
single_char(`!).
single_char(`.).
single_char(`().
single_char(`)).
in_word(C,C) :-
C >= `a,
C =< `z.
in_word(C,C) :-
C >= `A,
C =< `Z.
```

174

<!-- page 185 -->
*Appendices - Full Source Code* *Clam — Clam Shell (clam.pro)*

```prolog
in_word(`-,`-).
in_word(`_,`_).
% Have character C (known integer) - keep reading integers and build
% up the number until we hit a non-integer. Return this in C1, and
% return the computed number in W.
number_word(C, W, C1, Pow10) :-
is_num(C),
!,
get0(C2),
number_word(C2, W1, C1, P10),
Pow10 is P10 * 10,
W is integer(((C - `0) * Pow10) + W1).
number_word(C, 0, C, 0.1).
is_num(C) :-
C =< `9,
C >= `0.
% These symbols delineate end of sentence
%lastword(`.).
%lastword(`!).
%lastword(`?).
%lastword(13).    % carriage return
%lastword(10).    % line feed
%%
%% end RWL.PRO from Cogent Prolog Toolbox
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
```

<!-- page 186 -->
*Building Expert Systems in Prolog*

```prolog
% build rules use dcg in reverse to make clam rules from Prolog rules
% You can use bldrules.pro to convert, for example, the native Prolog
% rules of the birds.pro into clam syntax.
main :-
write($From file: $), read(From),
write($To file: $), read(To),
doit(From,To).
doit(From,To) :-
see(From),
tell(To),
test.
test :-
cntr_set(1,1),
repeat,
read(X),
tran(X,Ans,[]),
write_nice(Ans), nl,
X == '!EOF'.
test :-
told,
seen,
write(done).
xxif(Body) -->
[if],
xxbody(Body).
xxthen(Head) -->
{Head =.. [F,A]},
[then,F,is,A].
xxbody((H,T)) -->
{!,H =.. [F,A]},
[F,is,A,and],
xxbody(T).
xxbody(H) -->
{H =.. [F,A]},
[F,is,A].
tran(A,B,C) :-
trans(A,B,C),
!.
tran(X,X,_).
trans('!EOF','!EOF',_).
trans((Head :- true)) -->
{Head =.. [F,A]},
[F,is,A],
!.
trans((Head :- Body)) -->
{cntr_get(1,ID)},
[rule, ID],
xxif(Body),
```

<!-- page 187 -->
*Building Expert Systems in Prolog* *Clam — Build Rules (bldrules.pro)*

```prolog
xxthen(Head),
{ID2 is ID + 1,
cntr_set(1,ID2)}.
write_nice(X) :-
wr_nice(X),
!.
wr_nice([]) :-
!,
write('.'), nl.
wr_nice([if|T]):-
!,
nl, write('  if    '),
wr_nice(T).
wr_nice([then|T]):-
!,
nl, write('  then  '),
wr_nice(T).
wr_nice([and|T]):-
!,
write(and), nl, write('        '),
wr_nice(T).
wr_nice([H|T]) :-
!,
write(H), write(' '),
wr_nice(T).
wr_nice(X) :-
write(X).
```

<!-- page 189 -->
*Building Expert Systems in Prolog* C Oops

### Room Knowledgebase (room.okb)

```prolog
% ROOM is an expert system for placing furniture in a living room.
% It is written using the OOPS production system rules language.
% It is only designed to illustrate the use of a forward chaining
% rules based language for solving configuration problems. As such
% it makes many simplifying assumptions (such as furniture has no
% width). It just decides which wall each item goes on, and does
% not decide the relative placement on the wall.
% Furniture to be placed in the room is stored in terms of the form
% "furniture(item,length)". The rules look for unplaced furniture,
% and if found attempt to place it according to the rules of thumb.
% Once placed, the available space on a wall is updated, the furniture
% is ed on a wall with a term of the form "position(item,wall)",
% and the original "furniture" term is removed.
% These are the terms which are initially stored in working storage.
% They set a goal used to force firing of certain preliminary rules,
% and various facts about the problem domain used by the actual
% configuration rules.
initial_data([goal(place_furniture),
not_end_yet,
legal_furniture([couch, chair, table_lamp, end_table,
coffee_table, tv, standing_lamp, end]),
opposite(north,south),
opposite(south,north),
opposite(east,west),
opposite(west,east),
right(north,west),
right(west,south),
right(south,east),
right(east,north),
left(north,east),
left(east,south),
left(south,west),
left(west,north)]).
% Rules 1-8 are an example of how to generate procedural behavior
% from a non-procedural rule language. These rules force a series
% of prompts and gather data from the user on the room and furniture
% to be configured. They are included to illustrate the kludgy
% nature of production systems in a conventional setting.
% This is in contrast to rules f1-f14 which elegantly configure the room.
rule 1:
[1: goal(place_furniture),     % The initial goal causes a rule to
2: legal_furniture(LF)]       % to fire with introductory information.
==>                             % It will set a new goal.
[retract(1),
nl,
write('Enter a single item of furniture at each prompt.'),nl,
write('Include the width (in feet) of each item.'),nl,
write('The format is Item:Length.'),nl,nl,
write('The legal values are:'),nl,
write(LF),nl,nl,
```

<!-- page 190 -->
*Building Expert Systems in Prolog* *Oops — Room Knowledgebase (room.okb)*

```prolog
write('When there is no more furniture, enter "end:end."'),nl,
assert(goal(read_furniture))].
rule 2:
[1: furniture(end,end),               % When the furniture is read
2: goal(read_furniture)]             % set the new goal of reading
==>                                    % reading wall sizes
[retract(all),
assert(goal(read_walls))].
rule 3:
[1: goal(read_furniture),             % Loop to read furniture.
2: legal_furniture(LF)]
==>
[prompt('furniture> ', F:L),
member(F,LF),
assert(furniture(F,L))].
rule 4:                              % If rule 3 matched and failed
[1: goal(read_furniture),          % the action, then member must
2: legal_furniture(LF)]           % have failed.
==>
[write('Unknown piece of furniture, must be one of:'),nl,
write(LF),nl].
rule 5:
[1: goal(read_walls)]
==>
[retract(1),
prompt('What is the length of the north and south sides? ', LengthNS),
prompt('What is the length of the east and west sides? ', LengthEW),
assert(wall(north,LengthNS)),
assert(wall(south,LengthNS)),
assert(wall(east,LengthEW)),
assert(wall(west,LengthEW)),
assert(goal(find_door))].
rule 6:
[1: goal(find_door)]
==>
[retract(1),
prompt('Which wall has the door? ', DoorWall),
prompt('What is the width of the door? ', DoorWidth),
retract(wall(DoorWall,X)),
NewWidth = X - DoorWidth,
assert(wall(DoorWall, NewWidth)),
assert(position(door,DoorWall)),
assert(goal(find_plugs)),
write('Which walls have plugs? "end." when no more plugs:'),nl].
rule 7:
[1: goal(find_plugs),
2: position(plug,end)]
==>
[retract(all)].
rule 8:
[1: goal(find_plugs)]
==>
[prompt('Side: ', Wall),
assert(position(plug,Wall))].
```

180

<!-- page 191 -->
*Appendices - Full Source Code* *Oops — Room Knowledgebase (room.okb)*

```prolog
% Rules f1-f13 illustrate the strength of rule based programming.
% Each rule captures a rule of thumb used in configuring furniture
% in a living room.  The rules are all independent, transparent,
% and can be easily maintained.  Complexity can be added without
% concern for the flow of control.
% f1, f2 - place the couch first, it should be either opposite the
% door, or to its right, depending on which wall is longer.
rule f1:
[1: furniture(couch,LenC),          % an unplaced couch
position(door, DoorWall),       % find the wall with the door
opposite(DoorWall, OW),         % the wall opposite the door
right(DoorWall, RW),            % the wall to the right of the door
2: wall(OW, LenOW),                % available space opposite
wall(RW, LenRW),                % available space to the right
LenOW >= LenRW,                 % if opposite wall bigger than right
LenC =< LenOW]                  % length of couch less than wall space
==>
[retract(1),                        % remove the furniture term
assert(position(couch, OW)),       % assert the new position
retract(2),                        % remove the old wall,length
NewSpace = LenOW - LenC,           % calculate the space now available
assert(wall(OW, NewSpace))].       % assert the wall with new space left
rule f2:
[1: furniture(couch,LenC),
2: position(door, DoorWall),
3: opposite(DoorWall, OW),
4: right(DoorWall, RW),
5: wall(OW, LenOW),
6: wall(RW, LenRW),
LenOW =< LenRW,
LenC =< LenRW]
==>
[retract(1),
assert(position(couch, RW)),
retract(6),
NewSpace = LenRW - LenC,
assert(wall(RW, NewSpace))].
% f3 - the tv should be opposite the couch
rule f3:
[1: furniture(tv,LenTV),
2: position(couch, CW),
3: opposite(CW, W),
4: wall(W, LenW),
LenW >= LenTV]
==>
[retract(1),
assert(position(tv, W)),
retract(4),
NewSpace = LenW - LenTV,
assert(wall(W, NewSpace))].
% f4, f5 - the coffee table should be in front of the couch or if there
% is no couch, in front of a chair.
rule f4:
[1: furniture(coffee_table,_),
2: position(couch, CW)]
==>
```

<!-- page 192 -->
*Building Expert Systems in Prolog* *Oops — Room Knowledgebase (room.okb)*

```prolog
[retract(1),
assert(position(coffee_table, front_of_couch:CW))].
rule f5:
[1: furniture(coffee_table,_),
2: position(chair, CW)]
==>
[retract(1),
assert(position(coffee_table, front_of_chair:CW))].
% f6, f7 - chairs should be on adjacent walls from the couch
rule f6:
[1: furniture(chair,LC),
position(couch, CW),
right(CW, ChWa),
left(CW, ChWb),
4: wall(ChWa, La),
wall(ChWb, Lb),
La >= Lb,
La >= LC]
==>
[retract(1),
assert(position(chair, ChWa)),
NewSpace = La - LC,
retract(4),
assert(wall(ChWa, NewSpace))].
rule f7:
[1: furniture(chair,LC),
position(couch, CW),
right(CW, ChWa),
left(CW, ChWb),
wall(ChWa, La),
4: wall(ChWb, Lb),
La =< Lb,
Lb >= LC]
==>
[retract(1),
assert(position(chair, ChWb)),
NewSpace = Lb - LC,
retract(4),
assert(wall(ChWb, NewSpace))].
rule f8:
[1: furniture(chair,LC),
2: position(couch, CW),
3: left(CW, ChW),
4: wall(ChW, L),
L >= LC]
==>
[retract(1),
assert(position(chair, ChW)),
NewSpace = L - LC,
retract(4),
assert(wall(ChW, NewSpace))].
% put end_tables next to the couch first, then on the walls with
% the chairs
rule f9:
[1: furniture(end_table,TL),
2: position(couch, W),
```

182

<!-- page 193 -->
*Appendices - Full Source Code* *Oops — Room Knowledgebase (room.okb)*

```prolog
3: not(position(end_table, W)),
4: wall(W, L),
L >= TL]
==>
[retract(1),
assert(position(end_table, W, nolamp)),
NewSpace = L - TL,
retract(4),
assert(wall(W, NewSpace))].
rule f10:
[1: furniture(end_table,TL),
2: position(chair, W),
3: not(position(end_table, W)),
4: wall(W, L),
L >= TL]
==>
[retract(1),
assert(position(end_table, W, nolamp)),
NewSpace = L - TL,
retract(4),
assert(wall(W, NewSpace))].
% put the table lamps on the end tables
rule f11:
[1: furniture(table_lamp,_),
2: position(end_table, W, nolamp)]
==>
[retract(all),
assert(position(table_lamp, W)),
assert(position(end_table, W, lamp))].
% get extension cords if needed
rule f12:
[1: position(tv, W),
2: not(position(plug, W))]
==>
[assert(buy(extension_cord, W)),
assert(position(plug, W))].
rule f13:
[1: position(table_lamp, W),
2: not(position(plug, W))]
==>
[assert(buy(extension_cord, W)),
assert(position(plug, W))].
% When no other rules fire, here is the summary
rule f14:
[1: not_end_yet]
==>
[retract(1),
write('Recommendations:'), nl, nl,
write('furniture positions:'), nl, nl,
list(position(_,_)),
list(position(_,_,_)), nl,
write('purchase recommendations:'), nl, nl,
list(buy(_,_)),nl,
write('furniture which wouldn''t fit:'), nl, nl,
list(furniture(_,_)),nl,nl].
```

<!-- page 194 -->
*Building Expert Systems in Prolog*

```prolog
% from Winston & Horn's LISP
% Rules for animal identification. The first three rules are an
% input loop. Enter attributes that match the patterns in the rules.
% For example: has(robie,hair), or lays_eggs(suzie). These facts will
% help identify robie and suzie. Enter "end" to end the input loop.
%
% The attributes can also be put in the list of initial_data.
% Example:
%
%   initial_data([has(dennis,hair),
%                 has(dennis,hoofs),
%                 has(dennis,black_stripes),
%                 parent(dennis,diana)
%                ]
%               ).
%
% This should lead to the identification of dennis and diana as zebras.
initial_data([goal(animal_id)]).
rule 1:
[1: goal(animal_id)]
==>
[assert(read_facts),
retract(1)].
rule 2:
[1: end,
2: read_facts]
==>
[retract(all)].
rule 3:
[1: read_facts]
==>
[prompt('Attribute ? ',X),
assert(X)].
rule id1:
[1: has(X,hair)]
==>
[assert(isa(X,mammal)),
retract(all)].
rule id2:
[1: gives(X,milk)]
==>
[assert(isa(X,mammal)),
retract(all)].
rule id3:
[1: has(X,feathers)]
==>
[assert(isa(X,bird)),
retract(all)].
```

184

<!-- page 195 -->
*Appendices - Full Source Code* *Oops — Animal Knowledgebase (animal.okb)*

```prolog
rule id4:
[1: flies(X),
2: lays_eggs(X)]
==>
[assert(isa(X,bird)),
retract(all)].
rule id5:
[1: eats_meat(X)]
==>
[assert(isa(X,carnivore)),
retract(all)].
rule id6:
[1: has(X,pointed_teeth),
2: has(X,claws),
3: has(X,forward_eyes)]
==>
[assert(isa(X,carnivore)),
retract(all)].
rule id7:
[1: isa(X,mammal),
2: has(X,hoofs)]
==>
[assert(isa(X,ungulate)),
retract(all)].
rule id8:
[1: isa(X,mammal),
2: chews_cud(X)]
==>
[assert(isa(X,ungulate)),
assert(even_toed(X)),
retract(all)].
rule id9:
[1: isa(X,mammal),
2: isa(X,carnivore),
3: has(X,tawny_color),
4: has(X,dark_spots)]
==>
[assert(isa(X,cheetah)),
retract(all)].
rule id10:
[1: isa(X,mammal),
2: isa(X,carnivore),
3: has(X,tawny_color),
4: has(X,black_stripes)]
==>
[assert(isa(X,tiger)),
retract(all)].
rule id11:
[1: isa(X,ungulate),
2: has(X,long_neck),
3: has(X,long_legs),
4: has(X,dark_spots)]
```

<!-- page 196 -->
*Building Expert Systems in Prolog* *Oops — Animal Knowledgebase (animal.okb)*

```prolog
==>
[assert(isa(X,giraffe)),
retract(all)].
rule id12:
[1: isa(X,ungulate),
2: has(X,black_stripes)]
==>
[assert(isa(X,zebra)),
retract(all)].
rule id13:
[1: isa(X,bird),
2: does_not_fly(X),
3: has(X,long_neck),
4: has(X,long_legs),
5: has_attr(X,black_and_white)]
==>
[assert(isa(X,ostrich)),
retract(all)].
rule id14:
[1: isa(X,bird),
2: does_not_fly(X),
3: swims(X),
4: has_attr(X,black_and_white)]
==>
[assert(isa(X,penguin)),
retract(all)].
rule id15:
[1: isa(X,bird),
2: flies_well(X)]
==>
[assert(isa(X,albatross)),
retract(all)].
rule id16:
[1: isa(Animal,Type),
2: parent(Animal,Child)]
==>
[assert(isa(Child,Type)),
retract(all)].
rule id17:
[1: even_toed(X),
2: has_attr(X,slow),
3: isa(X,ungulate)]
==>
[assert(isa(X,sloth)),
retract(all)].
```

186

<!-- page 197 -->
*Appendices - Full Source Code*

```prolog
% OOPS2 - A toy production system interpreter. It uses a forward chaining,
%         data driven, rule based approach for expert system development.
%
% Version 2, the simplest version without LEX, MEA, or conflict sets
%
% author Dennis Merritt
% Copyright (c) Dennis Merritt, 1986
% operator definitions
:-op(800,xfx,==>).          % used to separate LHS and RHS of rule
:-op(500,xfy,:).            % used to separate attributes and values
:-op(810,fx,rule).          % used to define rule
:-op(700,xfy,#).            % used for unification instead of =
main :-
welcome,
supervisor.
welcome  :-
nl, nl,
write($         OOPS - A Toy Production System$), nl, nl,
write($This is an interpreter for files containing rules coded in the$), nl,
write($OOPS format.$), nl, nl,
write($The => prompt accepts three commands:$), nl, nl,
write($   load. -  prompts for name of rules file$), nl,
write($            enclose in single quotes$), nl,
write($   list. -  lists working memory$), nl,
write($   go.   -  starts the inference$), nl,
write($   exit. -  does what you'd expect$), nl, nl.
% the supervisor, uses a repeat fail loop to read and process commands
% from the user
supervisor :-
repeat,
write('=>'),
read(X),
%    write(echo1-X),
doit(X),
%    write(echo2-X),
X = exit.
doit(X) :-
do(X).
% actions to take based on commands
do(exit) :-
!.
do(go) :-
initialize,
go,
!.
do(load) :-
load,
!.
do(list) :-
lst,       % lists all of working storage
```

<!-- page 198 -->
*Building Expert Systems in Prolog* *Oops — Oops Interpreter (oops.pro)*

```prolog
!.
do(list(X)) :-
lst(X),    % lists all which match the pattern
!.
do(_) :-
write('invalid command').
% loads the rules (Prolog terms) into the Prolog database
load :-
write('Enter file name in single quotes (ex. ''room.okb''.): '),
read(F),
reconsult(F).            % loads a rule file into interpreter work space
% assert each of the initial conditions into working storage
initialize :-
initial_data(X),
assert_list(X).
% working storage is represented by database terms stored
% under the key "fact"
assert_list([]) :-
!.
assert_list([H|T]) :-
assertz(fact(H)),
!,
assert_list(T).
% the main inference loop, find a rule and try it.  if it fired, say so
% and repeat the process.  if not go back and try the next rule.  when
% no rules succeed, stop the inference
go :-
call(rule ID: LHS ==> RHS),
try(LHS,RHS),
write('Rule fired '), write(ID), nl,
!,
go.
go.
% find the current conflict set.
%conflict_set(CS) :-
%  bagof(rule ID: LHS ==> RHS,
%        [rule ID: LHS ==> RHS, match(LHS)],CS).
% match the LHS against working storage, if it succeeds, process the
% actions from the RHS
try(LHS,RHS) :-
match(LHS),
process(RHS,LHS),
!.
% recursively go through the LHS list, matching conditions against
% working storage
match([]) :-
!.
```

188

<!-- page 199 -->
*Appendices - Full Source Code* *Oops — Oops Interpreter (oops.pro)*

```prolog
match([N:Prem|Rest]) :-
!,
(fact(Prem)
;
test(Prem)         % a comparison test rather than a fact
),
match(Rest).
match([Prem|Rest]) :-
(fact(Prem)         % condition number not specified
;
test(Prem)
),
match(Rest).
% various tests allowed on the LHS
test(not(X)) :-
fact(X),
!,
fail.
test(not(X)) :-
!.
test(X # Y) :-
X = Y,
!.
test(X > Y) :-
X > Y,
!.
test(X >= Y) :-
X >= Y,
!.
test(X < Y) :-
X < Y,
!.
test(X =< Y) :-
X =< Y,
!.
test(X = Y) :-
X is Y,
!.
test(member(X,Y)) :-
member(X,Y),
!.
% recursively execute each of the actions in the RHS list
process([],_) :-
!.
process([Action|Rest],LHS) :-
take(Action,LHS),
!,
process(Rest,LHS).
% if its retract, use the reference numbers stored in the Lrefs list,
% otherwise just take the action
take(retract(N),LHS) :-
(N == all
;
integer(N)
),
retr(N,LHS),!.
take(A,_) :-
take(A),!.
```

<!-- page 200 -->
*Building Expert Systems in Prolog* *Oops — Oops Interpreter (oops.pro)*

```prolog
take(retract(X)) :-
retract(fact(X)),
!.
take(assert(X)) :-
asserta(fact(X)),
write(adding-X), nl,
!.
take(X # Y) :-
X = Y,
!.
take(X = Y) :-
X is Y,
!.
take(write(X)) :-
write(X),
!.
take(nl) :-
nl,
!.
take(read(X)) :-
read(X),
!.
take(prompt(X,Y)) :-
nl, write(X), read(Y),
!.
take(member(X,Y)) :-
member(X,Y),
!.
take(list(X)) :-
lst(X),
!.
% logic for retraction
retr(all,LHS) :-
retrall(LHS),
!.
retr(N,[]) :-
write('retract error, no '-N), nl,
!.
retr(N,[N:Prem|_]) :-
retract(fact(Prem)),
!.
retr(N,[_|Rest]) :-
!,
retr(N,Rest).
retrall([]).
retrall([N:Prem|Rest]) :-
retract(fact(Prem)),
!, retrall(Rest).
retrall([Prem|Rest]) :-
retract(fact(Prem)),
!, retrall(Rest).
retrall([_|Rest]) :-    % must have been a test
retrall(Rest).
% list all of the terms in working storage
lst :-
fact(X),
write(X), nl,
fail.
lst :-
!.
```

190

<!-- page 201 -->
*Appendices - Full Source Code* *Oops — Oops Interpreter (oops.pro)*

```prolog
% lists all of the terms which match the pattern
lst(X) :-
fact(X),
write(X), nl,
fail.
lst(_) :-
!.
% utilities
member(X,[X|Y]).
member(X,[Y|Z]) :-
member(X,Z).
```

<!-- page 203 -->
*Building Expert Systems in Prolog* D Foops

### Room Knowledgebase (room.fkb)

```prolog
% ROOM.FKB - a version of the room knowledge base for FOOPS.  Much of the
% knowledge about furniture is stored in frames, thus simplifying
% the rule portion of the knowledge base.
frame(furniture, [
    legal_types - [val [couch,chair,coffee_table,end_table,standing_lamp,
           table_lamp,tv,knickknack]],
    position - [def none, add pos_add],
    length - [def 3],
    place_on - [def floor],
    can_hold - [def 0]]).
frame(couch, [
    ako - [val furniture],
    length - [def 6]]).
frame(chair, [
    ako - [val furniture],
    length - [def 3]]).
% A table is different from most furniture in that it can hold things
% on it.
frame(table, [
    ako - [val furniture],
    space - [def 4],
    length - [def 4],
    can_support - [def yes],
    holding - [def []]]).
frame(end_table, [
    ako - [val table],
    length - [def 2]]).
frame(coffee_table, [
    ako - [val table],
    length - [def 4]]).
% electric is used as a super class for anything electrical.  It contains
% the defaults for those attributes unique to electrical things.
frame(electric, [
    needs_outlet - [def yes]]).
frame(lamp, [
    ako - [val [furniture, electric]]]).
frame(standing_lamp, [
    ako - [val lamp]]).
frame(table_lamp, [
    ako - [val lamp],
    place_on - [def table]]).
frame(tv, [
    ako - [val [furniture, electric]],
    place_on - [calc tv_support]]).
```

<!-- page 204 -->
*Building Expert Systems in Prolog* *Foops — Room Knowledgebase (room.fkb)*

```prolog
frame(knickknack, [
    ako - [val furniture],
    length - [def 1],
    place_on - [def table]]).
frame(wall, [
    length - [def 10],
    outlets - [def 0],
    space - [calc space_calc],
    holding - [def []]]).
frame(door, [
    ako - [val furniture],
    length - [def 4]]).
frame(goal, []).
frame(recommend, []).
% calculate the available space if needed.  The available space is
% computed from the length of the item minus the sum of the lengths of
% the items it is holding.  The held items are in the holding list.
% The items in the list are identified only by their unique names.
% This is used by walls and tables.
space_calc(C,N,space-S) :-
    getf(C,N,[length-L,holding-HList]),
    sum_lengths(HList,0,HLen),
    S is L - HLen.
sum_lengths([],L,L).
sum_lengths([C/N|T],X,L) :-
    getf(C,N,[length-HL]),
    XX is X + HL,
    sum_lengths(T,XX,L).
% When placing the tv, check with the user to see if it goes on the
% floor or a table.
tv_support(tv,N,place_on-table) :-
    nl,
    write('Should the TV go on a table? '),
    read(yes),
    uptf(tv,N,[place_on-table]).
tv_support(tv,N,place_on-floor) :-
    uptf(tv,N,[place_on-floor]).
% Whenever a piece is placed in position, update the holding list of the
% item which holds it (table or wall) and the available space.  If something
% is placed in front of something else, then do nothing.
pos_add(_,_,position-frontof(X)) :-
    uptf(C,N,[holding-[X]]).
pos_add(C,N,position-CP/P) :-
    getf(CP,P,[space-OldS]),
    getf(C,N,[length-L]),
    NewS is OldS - L,
    NewS >= 0,
    uptf(CP,P,[holding-[C/N],space-NewS]).
```

194

<!-- page 205 -->
*Appendices - Full Source Code* *Foops — Room Knowledgebase (room.fkb)*

```prolog
pos_add(C,N,position-CP/P) :-
    nl, write_line(['Not enough room on',CP,P,for,C,N]),
    !, fail.
% The forward chaining rules of the system.  They make use of call
% to activate some pure Prolog predicates at the end of the knowledge
% base.  In particular, data gathering, and wall space calculations
% are done in Prolog.
% These are the terms which are initially stored in working storage.
% They set a goal used to force firing of certain preliminary rules,
% and various facts about the problem domain used by the actual
% configuration rules.
initial_data([goal - gather_data,
    wall - north with [opposite-south,right-west,left-east],
    wall - south with [opposite-north,right-east,left-west],
    wall - east with [opposite-west,right-north,left-south],
    wall - west with [opposite-east,right-south,left-north] ]).
% first gather data, then try the couch first.
rule 1:
    [goal - gather_data]
    ==>
    [call(gather_data),
    assert( goal - couch_first )].
% Rules f1-f13 illustrate the strength of rule based programming.
% Each rule captures a rule of thumb used in configuring furniture
% in a living room.  The rules are all independent, transparent,
% and can be easily maintained.  Complexity can be added without
% concern for the flow of control.
% f1, f2 - place the couch first, it should be either opposite the
% door, or to its right, depending on which wall has more space.
rule f1:
    [goal - couch_first,
    couch - C with [position-none,length-LenC],
    door - D with [position-wall/W],
    wall - W with [opposite-OW,right-RW],
    wall - OW with [space-SpOW],
    wall - RW with [space-SpRW],
    SpOW >= SpRW,
    LenC =< SpOW]
    ==>
    [update(couch - C with [position-wall/OW])].
rule f2:
    [goal - couch_first,
    couch - C with [position-none,length-LenC],
    door - D with [position-wall/W],
    wall - W with [opposite-OW,right-RW],
    wall - OW with [space-SpOW],
    wall - RW with [space-SpRW],
    SpRW >= SpOW,
    LenC =< SpRW]
    ==>
    [update(couch - C with [position-wall/RW])].
% f3 - f3a the tv should be opposite the couch.  if it needs a table, an
% end table should be placed under it, if no table is available put
```

<!-- page 206 -->
*Building Expert Systems in Prolog* *Foops — Room Knowledgebase (room.fkb)*

```prolog
% it on the floor anyway and recommend the purchase of a table.  The rules
% first check to see if the couch has been placed.
rule f3:
    [couch - C with [position-wall/W],
    wall - W with [opposite-OW],
    tv - TV with [position-none,place_on-floor]]
    ==>
    [update(tv - TV with [position-wall/OW])].
rule f4:
    [couch - C with [position-wall/W],
    wall - W with [opposite-OW],
    tv - TV with [position-none,place_on-table],
    end_table - T with [position-none]]
    ==>
    [update(end_table - T with [position-wall/OW]),
    update(tv - TV with [position-end_table/T])].
rule f4a:
    [tv - TV with [position-none,place_on-table]]
    ==>
    [assert(recommend - R with [buy-['table for tv']])].
% f5 - the coffee table should be in front of the couch.
rule f5:
    [coffee_table - CT with [position-none],
    couch - C]
    ==>
    [update(coffee_table - CT with [position-frontof(couch/C)])].
% f6, f7 - chairs should be on adjacent walls from the couch, which ever
% has the most space
rule f6:
    [chair - Ch with [position-none],
    couch - C with [position-wall/W],
    wall - W with [right-RW,left-LW],
    wall - RW with [space-SpR],
    wall - LW with [space-SpL],
    SpR >= SpL]
    ==>
    [update(chair - Ch with [position-wall/RW])].
rule f7:
    [chair - Ch with [position-none],
    couch - C with [position-wall/W],
    wall - W with [right-RW,left-LW],
    wall - RW with [space-SpR],
    wall - LW with [space-SpL],
    SpL > SpR]
    ==>
    [update(chair - Ch with [position-wall/LW])].
% put end_tables next to the couch first, then on the walls with
% the chairs
rule f9:
    [end_table - ET with [position-none],
    not tv - TV with [position-none,place_on-table],
    couch - C with [position-wall/W],
```

196

<!-- page 207 -->
*Appendices - Full Source Code* *Foops — Room Knowledgebase (room.fkb)*

```prolog
    not end_table - ET2 with [position-wall/W]]
    ==>
    [update(end_table - ET with [position-wall/W])].
rule f10:
    [end_table - ET with [position-none],
    not tv - TV with [position-none,place_on-table],
    chair - C with [position-wall/W],
    not end_table - ET2 with [position-wall/W]]
    ==>
    [update(end_table - ET with [position-wall/W])].
% put the table lamps on the end tables
rule f11:
    [table_lamp - TL with [position-none],
    end_table - ET with [position-wall/W]]
    ==>
    [update( table_lamp - TL with [position-end_table/ET] )].
% put the knickknacks on anything which will hold them.
rule f11a:
    [knickknack - KK with [position-none],
    Table - T with [can_support-yes, position-wall/W]]
    ==>
    [update( knickknack - KK with [position-Table/T] )].
% get extension cords if needed
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
% When no other rules fire, here is the summary
rule f14:
    []
    ==>
    [call(output_data)].
% Prolog predicates called by various rules to perform functions better
% handled by Prolog.
% Gather the input data from the user.
gather_data :-
    read_furniture,
    read_walls.
```

<!-- page 208 -->
*Building Expert Systems in Prolog* *Foops — Room Knowledgebase (room.fkb)*

```prolog
read_furniture :-
    get_frame(furniture,[legal_types-LT]),
    write('Enter name of furniture at the prompt.  It must be one of:'), nl,
    write(LT), nl,
    write('Enter ''end.'' to stop input.'), nl,
    write('At the length prompt enter ''y.'' or a new number.'), nl,
    repeat,
    write('>'), read(X),
    process_furn(X),
!.
process_furn(end).
process_furn(X) :-
get_frame(X,[length-DL]),
write(length-DL),write('>'),
read(NL),
get_length(NL,DL,L),
addf(X,_,[length-L]),
fail.
get_length(y,L,L) :- !.
get_length(L,_,L).
read_walls :-
    nl, write('Enter data for the walls.'), nl,
    write('What is the length of the north & south walls? '),
    read(NSL),
    uptf(wall,north,[length-NSL]),
    uptf(wall,south,[length-NSL]),
    write('What is the length of the east & west walls? '),
    read(EWL),
    uptf(wall,east,[length-EWL]),
    uptf(wall,west,[length-EWL]),
    write('Which wall has the door? '),
    read(DoorWall),
    write('What is its length? '),
    read(DoorLength),
    addf(door,D,[length-DoorLength]),
    uptf(door,D,[position-wall/DoorWall]),
    write('Which walls have outlets? (a list)'),
    read(PlugWalls),
    process_plugs(PlugWalls).
process_plugs([]) :- !.
process_plugs([H|T]) :-
uptf(wall,H,[outlets-1]),
!,
process_plugs(T).
process_plugs(X) :-
uptf(wall,X,[outlets-1]).
output_data :-
    write('The final results are:'),nl,
%
    print_frames,
    output_walls,
    output_tables,
    output_recommends,
    output_unplaced.
output_walls :-
    getf(wall,W,[holding-HL]),
    write_line([W,wall,holding|HL]),
```

198

<!-- page 209 -->
*Appendices - Full Source Code* *Foops — Room Knowledgebase (room.fkb)*

```prolog
    fail.
output_walls.
output_tables :-
    getf(C,N,[holding-HL]),
    not C = wall,
    write_line([C,N,holding|HL]),
    fail.
output_tables.
output_recommends :-
    getf(recommend,_,[buy-BL]),
    write_line([purchase|BL]),
    fail.
output_recommends.
output_unplaced :-
    write('Unplaced furniture:'), nl,
    getf(T,N,[position-none]),
    write(T-N), nl,
    fail.
output_unplaced.
```

<!-- page 210 -->
*Building Expert Systems in Prolog*

```prolog
% FOOPS.PRO - an integration of frames, forward chaining with LEX and MEA,
% and Prolog.
% Copyright (c) Dennis Merritt, 1986 - Permission granted for
% non-commercial use
% The first section of the code contains the basic OOPS code, the
% second section contains the FRAMES code.
% OPERATOR DEFINITIONS
:-op(800,xfx,==>).          % used to separate LHS and RHS of rule
:-op(500,xfy,:).            % used to separate attributes and values
:-op(810,fx,rule).          % used to define rule
:-op(700,xfy,#).            % used for unification instead of =
:-op(700,xfy,\=).           % not equal
:-op(600,xfy,with).         % used for frame instances in rules
main :-
welcome,
supervisor.
welcome  :-
write($FOOPS - A Toy Production System$),nl,nl,
write($This is an interpreter for files containing rules coded in the$),nl,
write($FOOPS format.$), nl, nl,
write($The => prompt accepts four commands:$), nl, nl,
write($   load. -  prompts for name of rules file$), nl,
write($            enclose in single quotes$), nl,
write($   go.   -  starts the inference$), nl,
write($   list. -  list working memory$), nl,
write($   exit. -  does what you'd expect$), nl, nl.
% THE SUPERVISOR, USES A REPEAT FAIL LOOP TO READ AND PROCESS COMMANDS
% FROM THE USER
supervisor :-
repeat,
write('=>'),
read(X),
doit(X),
X = exit.
doit(X) :- do(X).
% ACTIONS TO TAKE BASED ON COMMANDS
do(exit) :- !.
do(go) :-
initialize,
timer(T1),
go,
timer(T2),
T is 10 * (T2 - T1),
write(time-T), nl, !.
do(load) :- load, !.
do(list) :- lst, !.       % lists all of working storage
do(list(X)) :- lst(X), !. % lists all which match the pattern
do(_) :- write('invalid command'), nl.
```

200

<!-- page 211 -->
*Appendices - Full Source Code* *Foops — Foops (foops.pro)*

```prolog
% LOADS THE RULES (PROLOG TERMS) INTO THE PROLOG DATABASE
load :-
write('Enter the file name in single quotes (ex. ''room.fkb''.): '),
read(F),
reconsult(F).            % loads a rule file into interpreter work space
% ASSERT EACH OF THE INITIAL CONDITIONS INTO WORKING STORAGE
initialize :-
setchron(1),
abolish(instantiation,1),
delf(all),
assert(mea(no)),
assert(gid(100)),
initial_data(X),
assert_list(X), !.
initialize :-
error(301,[initialization,error]).
% WORKING STORAGE IS REPRESENTED BY DATABASE TERMS STORED
% UNDER THE KEY "fact"
assert_list([]) :- !.
assert_list([H|T]) :-
getchron(Time),
assert_ws( fact(H,Time) ),
!, assert_list(T).
% THE MAIN INFERENCE LOOP, FIND A RULE AND TRY IT.  IF IT FIRED, SAY SO
% AND REPEAT THE PROCESS.  IF NOT GO BACK AND TRY THE NEXT RULE.  WHEN
% NO RULES SUCCEED, STOP THE INFERENCE
go :-
conflict_set(CS),
write_cs(CS),
select_rule(CS,r(Inst,ID,LHS,RHS)),
write($Rule Selected $), write(ID), nl,
(process(RHS,LHS); true),
asserta( instantiation(Inst) ),
write($Rule fired $), write(ID), nl,
!, go.
go.
write_cs([]).
write_cs([r(I,ID,L,R)|X]) :-
write(ID), nl,
writeinst(I),
write_cs(X).
writeinst([]).
writeinst([H|T]) :-
tab(5),
write(H), nl,
writeinst(T).
conflict_set(CS) :-
bagof(r(Inst,ID,LHS,RHS),
(rule ID: LHS ==> RHS, match(LHS,Inst)), CS).
```

<!-- page 212 -->
*Building Expert Systems in Prolog* *Foops — Foops (foops.pro)*

```prolog
select_rule(CS,R) :-
refract(CS,CS1),
mea_filter(0,CS1,[],CSR),
lex_sort(CSR,R).
list_cs([]).
list_cs([K-r(_,ID,_,_)|T]) :-
write(ID-K), nl,
list_cs(T).
% ELIMINATE those rules which have already been tried
refract([],[]).
refract([r(Inst,_,_,_)|T],TR) :-
instantiation(Inst),
!, refract(T,TR).
refract([H|T],[H|TR]) :-
refract(T,TR).
% SORT THE REST OF THE CONFLICT SET ACCORDING TO THE LEX STRATEGY
lex_sort(L,R) :-
build_keys(L,LK),
% keysort(LK,X),
sort(LK,X),
reverse(X,[K-R|_]).
% BUILD LISTS OF TIME STAMPS FOR LEX SORT KEYS
build_keys([],[]).
build_keys([r(Inst,A,B,C)|T],[Key-r(Inst,A,B,C)|TR]) :-
build_chlist(Inst,ChL),
sort(ChL,X),
reverse(X,Key),
build_keys(T,TR).
% BUILD A LIST OF JUST THE TIMES OF THE VARIOUS MATCHED ATTRIBUTES
% FOR USE IN RULE SELECTION
build_chlist([],[]).
build_chlist([_/Chron|T],[Chron|TC]) :-
build_chlist(T,TC).
% ADD THE TEST FOR MEA IF APPROPRIATE THAT EMPHASIZES THE FIRST ATTRIBUTE
% SELECTED.
mea_filter(_,X,_,X) :- not mea(yes), !.
mea_filter(_,[],X,X).
mea_filter(Max,[r([A/T|Z],B,C,D)|X],Temp,ML) :-
T < Max,
!, mea_filter(Max,X,Temp,ML).
mea_filter(Max,[r([A/T|Z],B,C,D)|X],Temp,ML) :-
T = Max,
!, mea_filter(Max,X,[r([A/T|Z],B,C,D)|Temp],ML).
mea_filter(Max,[r([A/T|Z],B,C,D)|X],Temp,ML) :-
T > Max,
!, mea_filter(T,X,[r([A/T|Z],B,C,D)],ML).
% RECURSIVELY GO THROUGH THE LHS LIST, MATCHING CONDITIONS AGAINST
% WORKING STORAGE
```

202

<!-- page 213 -->
*Appendices - Full Source Code* *Foops — Foops (foops.pro)*

```prolog
match([],[]).
match([Prem|Rest],[Prem/Time|InstRest]) :-
mat(Prem,Time),
match(Rest,InstRest).
mat(N:Prem,Time) :-
!, fact(Prem,Time).
mat(Prem,Time) :-
fact(Prem,Time).
mat(Test,0) :-
test(Test).
fact(Prem,Time) :-
conv(Prem,Class,Name,ReqList),
getf(Class,Name,ReqList,Time).
assert_ws( fact(Prem,Time) ) :-
conv(Prem,Class,Name,UList),
addf(Class,Name,UList).
update_ws( fact(Prem,Time) ) :-
conv(Prem,Class,Name,UList),
uptf(Class,Name,UList).
retract_ws( fact(Prem,Time) ) :-
conv(Prem,Class,Name,UList),
delf(Class,Name,UList).
conv(Class-Name with List, Class, Name, List).
conv(Class-Name, Class, Name, []).
% VARIOUS TESTS ALLOWED ON THE LHS
test(not(X)) :-
fact(X,_),
!, fail.
test(not(X)) :- !.
test(X#Y) :- X=Y, !.
test(X>Y) :- X>Y, !.
test(X>=Y) :- X>=Y, !.
test(X<Y) :- X<Y, !.
test(X=<Y) :- X=<Y, !.
test(X \= Y) :- not X=Y, !.
%test(X = Y) :- X=Y, !.
test(X = Y) :- X is Y, !.
test(is_on(X,Y)) :- is_on(X,Y), !.
test(call(X)) :- call(X).
% RECURSIVELY EXECUTE EACH OF THE ACTIONS IN THE RHS LIST
process([],_) :- !.
process([Action|Rest],LHS) :-
take(Action,LHS),
!, process(Rest,LHS).
process([Action|Rest],LHS) :-
error(201,[Action,fails]).
% IF ITS RETRACT, USE THE REFERENCE NUMBERS STORED IN THE Lrefs LIST,
% OTHERWISE JUST TAKE THE ACTION
```

<!-- page 214 -->
*Building Expert Systems in Prolog* *Foops — Foops (foops.pro)*

```prolog
take(retract(N),LHS) :-
(N == all; integer(N)),
retr(N,LHS), !.
take(A,_) :- take(A), !.
take(retract(X)) :- retract_ws(fact(X,_)), !.
take(assert(X)) :-
getchron(T),
assert_ws(fact(X,T)),
write(adding-X), nl,
!.
take(update(X)) :-
getchron(T),
update_ws(fact(X,T)),
write(updating-X), nl,
!.
take(X # Y) :- X=Y, !.
take(X = Y) :- X is Y, !.
take(write(X)) :- write(X), !.
take(write_line(X)) :- write_line(X), !.
take(nl) :- nl, !.
take(read(X)) :- read(X), !.
take(prompt(X,Y)) :- nl, write(X), read(Y), !.
take(cls) :- cls, !.
take(is_on(X,Y)) :- is_on(X,Y), !.
take(list(X)) :- lst(X), !.
take(call(X)) :- call(X).
% LOGIC FOR RETRACTION
retr(all,LHS) :-retrall(LHS), !.
retr(N,[]) :- error(202,['retract error, no ',N]), !.
retr(N,[N:Prem|_]) :- retract_ws(fact(Prem,_)), !.
retr(N,[_|Rest]) :- !, retr(N,Rest).
retrall([]).
retrall([N:Prem|Rest]) :-
retract_ws(fact(Prem,_)),
!, retrall(Rest).
retrall([Prem|Rest]) :-
retract_ws(fact(Prem,_)),
!, retrall(Rest).
retrall([_|Rest]) :-    % must have been a test
retrall(Rest).
% LIST ALL OF THE TERMS IN WORKING STORAGE
lst :-
fact(X,_),
write(X), nl,
fail.
lst.
% LISTS ALL OF THE TERMS WHICH MATCH THE PATTERN
lst(X) :-
fact(X,_),
write(X), nl,
fail.
lst(_).
```

204

<!-- page 215 -->
*Appendices - Full Source Code* *Foops — Foops (foops.pro)*

```prolog
% UTILITIES
member(X,[X|Y]).
member(X,[Y|Z]) :-
member(X,Z).
reverse(F,R) :-
rever(F,[],R).
rever([],R,R).
rever([X|Y],T,R) :-
rever(Y,[X|T],R).
% MAINTAIN A TIME COUNTER
setchron(N) :-
retract( chron(_) ),
asserta( chron(N) ), !.
setchron(N) :-
asserta( chron(N) ).
getchron(N) :-
retract( chron(N) ),
NN is N + 1,
asserta( chron(NN) ), !.
%
% THIS SECTION IMPLEMENTS A FRAME BASED SCHEME FOR KNOWLEDGE REPRESENTATION
%
:- op(600,fy,val).
:- op(600,fy,calc).
:- op(600,fy,def).
:- op(600,fy,add).
:- op(600,fy,del).
% prep_req takes a request of the form Slot-Val, and forms it into the
% more accurate req(Class,Slot,Facet,Value).  If no facet was mentioned
% in the original request, then the facet of "any" is used to indicate
% the system should use everything possible to find a value.
prep_req(Slot-X,req(C,N,Slot,val,X)) :- var(X), !.
prep_req(Slot-X,req(C,N,Slot,Facet,Val)) :-
nonvar(X),
X =.. [Facet,Val],
facet_list(FL),
is_on(Facet,FL), !.
prep_req(Slot-X,req(C,N,Slot,val,X)).
facet_list([val,def,calc,add,del,edit]).
% RETRIEVE A LIST OF SLOT VALUES
get_frame(Class, ReqList) :-
frame(Class, SlotList),
slot_vals(Class,_,ReqList,SlotList).
getf(Class,Name,ReqList) :-
getf(Class,Name,ReqList,_).
```

<!-- page 216 -->
*Building Expert Systems in Prolog* *Foops — Foops (foops.pro)*

```prolog
getf(Class,Name,ReqList,TimeStamp) :-
frinst(Class, Name, SlotList, TimeStamp),
slot_vals(Class, Name, ReqList, SlotList).
slot_vals(_,_,ReqL,SlotL) :-
var(ReqL),
!,
ReqL = SlotL.
slot_vals(_,_,[],_).
slot_vals(C,N,[Req|Rest],SlotList) :-
prep_req(Req,req(C,N,S,F,V)),
find_slot(req(C,N,S,F,V),SlotList),
!, slot_vals(C,N,Rest,SlotList).
slot_vals(C,N, Req, SlotList) :-
not(list(Req)),
prep_req(Req,req(C,N,S,F,V)),
find_slot(req(C,N,S,F,V), SlotList).
find_slot(req(C,N,S,F,V), SlotList) :-
nonvar(V), !,
find_slot(req(C,N,S,F,Val), SlotList), !,
(Val = V; list(Val),is_on(V,Val)).
find_slot(req(C,N,S,F,V), SlotList) :-
is_on(S-FacetList, SlotList), !,
facet_val(req(C,N,S,F,V),FacetList).
find_slot(req(C,N,S,F,V), SlotList) :-
is_on(ako-FacetList, SlotList),
facet_val(req(C,N,ako,val,Ako),FacetList),
(is_on(X,Ako); X = Ako),
frame(X, HigherSlots),
find_slot(req(C,N,S,F,V), HigherSlots), !.
find_slot(Req,_) :-
error(99,['frame error looking for:',Req]).
facet_val(req(C,N,S,F,V),FacetList) :-
FV =.. [F,V],
is_on(FV,FacetList), !.
facet_val(req(C,N,S,val,V),FacetList) :-
is_on(val ValList,FacetList),
is_on(V,ValList), !.
facet_val(req(C,N,S,val,V),FacetList) :-
is_on(calc Pred,FacetList),
CalcPred =.. [Pred,C,N,S-V],
call(CalcPred), !.
facet_val(req(C,N,S,val,V),FacetList) :-
is_on(def V,FacetList), !.
% ADD A LIST OF SLOT VALUES
add_frame(Class, UList) :-
old_slots(Class,SlotList),
add_slots(Class,_,UList,SlotList,NewList),
retract(frame(Class,_)),
asserta(frame(Class,NewList)), !.
addf(Class,Nm,UList) :-
(var(Nm),genid(Name);Name=Nm),
add_slots(Class,Name,[ako-Class|UList],SlotList,NewList),
getchron(TimeStamp),
asserta( frinst(Class,Name,NewList,TimeStamp) ),
!.
```

206

<!-- page 217 -->
*Appendices - Full Source Code* *Foops — Foops (foops.pro)*

```prolog
uptf(Class,Name,UList) :-
frinst(Class,Name,SlotList,_),
add_slots(Class,Name,UList,SlotList,NewList),
retract( frinst(Class,Name,_,_) ),
getchron(TimeStamp),
asserta( frinst(Class,Name,NewList,TimeStamp) ),
!.
uptf(Class,Name,UList) :-
error(105,[update,failed,Class,Name,UList]).
genid(G) :-
retract(gid(N)),
G is N + 1,
asserta(gid(G)).
old_slots(Class,SlotList) :-
frame(Class,SlotList), !.
old_slots(Class,[]) :-
asserta(frame(Class,[])).
add_slots(_,_,[],X,X).
add_slots(C,N,[U|Rest],SlotList,NewList) :-
prep_req(U,req(C,N,S,F,V)),
add_slot(req(C,N,S,F,V),SlotList,Z),
!, add_slots(C,N,Rest,Z,NewList).
add_slots(C,N,X,SlotList,NewList) :-
prep_req(X,req(C,N,S,F,V)),
add_slot(req(C,N,S,F,V),SlotList,NewList).
add_slot(req(C,N,S,F,V),SlotList,[S-FL2|SL2]) :-
delete(S-FacetList,SlotList,SL2),
add_facet(req(C,N,S,F,V),FacetList,FL2).
add_facet(req(C,N,S,F,V),FacetList,[FNew|FL2]) :-
FX =.. [F,OldVal],
delete(FX,FacetList,FL2),
add_newval(OldVal,V,NewVal),
!, check_add_demons(req(C,N,S,F,V),FacetList),
FNew =.. [F,NewVal].
add_newval(X,Val,Val) :- var(X), !.
add_newval(OldList,ValList,NewList) :-
list(OldList),
list(ValList),
append(ValList,OldList,NewList), !.
add_newval([H|T],Val,[Val,H|T]).
add_newval(_,Val,Val).
check_add_demons(req(C,N,S,F,V),FacetList) :-
get_frame(C,S-add(Add)), !,
AddFunc =.. [Add,C,N,S-V],
call(AddFunc).
check_add_demons(_,_).
% DELETE A LIST OF SLOT VALUES
del_frame(Class) :-
retract(frame(Class,_)).
del_frame(Class) :-
error(203,['No frame',Class,'to delete']).
```

<!-- page 218 -->
*Building Expert Systems in Prolog* *Foops — Foops (foops.pro)*

```prolog
del_frame(Class, UList) :-
old_slots(Class,SlotList),
del_slots(Class,_,UList,SlotList,NewList),
retract(frame(Class,_)),
asserta(frame(Class,NewList)).
delf(all) :-
retract( frinst(_,_,_,_) ),
fail.
delf(all).
delf(Class,Name) :-
retract( frinst(Class,Name,_,_) ),
!.
delf(Class,Name) :-
error(103,['No instance of ',Class,' for ',Name]).
delf(Class,Name,UList) :-
old_flots(Class,Name,SlotList),
del_slots(Class,Name,UList,SlotList,NewList),
retract( frinst(Class,Name,_,_) ),
getchron(TimeStamp),
asserta( frinst(Class,Name,NewList,TimeStamp) ).
del_slots(_,_,[],X,X).
del_slots(C,N,[U|Rest],SlotList,NewList) :-
prep_req(U,req(C,N,S,F,V)),
del_slot(req(C,N,S,F,V),SlotList,Z),
del_slots(C,N,Rest,Z,NewList).
del_slots(C,N,X,SlotList,NewList) :-
prep_req(X,req(C,N,S,F,V)),
del_slot(req(C,N,S,F,V),SlotList,NewList).
del_slot(req(C,N,S,F,V),SlotList,[S-FL2|SL2]) :-
remove(S-FacetList,SlotList,SL2),
del_facet(req(C,N,S,F,V),FacetList,FL2).
del_slot(Req,_,_) :-
error(104,['del_slot - unable to remove',Req]).
del_facet(req(C,N,S,F,V),FacetList,FL) :-
FV =.. [F,V],
remove(FV,FacetList,FL),
!, check_del_demons(req(C,N,S,F,V),FacetList).
del_facet(req(C,N,S,F,V),FacetList,[FNew|FL]) :-
FX =.. [F,OldVal],
remove(FX,FacetList,FL),
remove(V,OldVal,NewValList),
FNew =.. [F,NewValList],
!, check_del_demons(req(C,N,S,F,V),FacetList).
del_facet(Req,_,_) :-
error(105,['del_facet - unable to remove',Req]).
check_del_demons(req(C,N,S,F,V),FacetList) :-
get_frame(C,S-del(Del)), !,
DelFunc =.. [Del,C,N,S-V],
call(DelFunc).
check_del_demons(_,_).
```

208

<!-- page 219 -->
*Appendices - Full Source Code* *Foops — Foops (foops.pro)*

```prolog
% PRINT A FRAME
print_frames :-
frame(Class, SlotList),
print_frame(Class),
fail.
print_frames.
print_frame(Class) :-
frame(Class,SlotList),
write_line(['Frame:',Class]),
print_slots(SlotList), nl.
printfs :-
frame(Class,_),
printf(Class,_),
fail.
printfs.
printf(Class,Name) :-
frinst(Class,Name,SlotList,Time),
write_line(['Frame:',Class,Name,Time]),
print_slots(SlotList), nl.
printf(Class) :-
frinst(Class,Name,SlotList,Time),
write_line(['Frame:',Class,Name,Time]),
print_slots(SlotList), nl, fail.
printf(_).
print_slots([]).
print_slots([Slot|Rest]) :-
write_line(['  Slot:',Slot]),
print_slots(Rest).
% UTILITIES
delete(X,[],[]).
delete(X,[X|Y],Y) :- !.
delete(X,[Y|Z],[Y|W]) :- delete(X,Z,W).
remove(X,[X|Y],Y) :- !.
remove(X,[Y|Z],[Y|W]) :- remove(X,Z,W).
is_on(X,[X|Y]).
is_on(X,[Y|Z]) :- is_on(X,Z).
error_threshold(100).
error(NE,_) :- error_threshold(N), N > NE, !, fail.
error(NE,E) :-
nl, write('*** '), write(error-NE), tab(1),
write_line(E),
!, fail.
write_line([]) :- nl.
```

<!-- page 220 -->
*Building Expert Systems in Prolog* *Foops — Foops (foops.pro)*

```prolog
write_line([H|T]) :-
write(H), tab(1),
write_line(T).
time_test :-
write('TT> '),
read(X),
timer(T1),
X,
timer(T2),
nl, nl,
T is T2 - T1,
write(time-T).
```

210

<!-- page 221 -->
*Appendices - Full Source Code* E Rete-Foops

### Room Knowledgebase (room.rkb)

```prolog
% ROOM.RKB - a version of ROOM for use with RETE-FOOPS.
frame(furniture, [legal_types - [val [couch,chair,coffee_table,end_table,
standing_lamp,table_lamp,tv,knickknack]
],
position - [def none, add pos_add],
length - [def 3],
place_on - [def floor],
can_hold - [def 0]
]
).
frame(couch, [ako - [val furniture],
length - [def 6]
]
).
frame(chair, [ako - [val furniture],
length - [def 3]
]
).
% A table is different from most furniture in that it can hold things
% on it.
frame(table, [ako - [val furniture],
space - [def 4],
length - [def 4],
can_support - [def yes],
holding - [def []]
]
).
frame(end_table, [ako - [val table],
length - [def 2]
]
).
frame(coffee_table, [ako - [val table],
length - [def 4]
]
).
% electric is used as a super class for anything electrical.  It contains
% the defaults for those attributes unique to electrical things.
frame(electric, [needs_outlet - [def yes]]).
frame(lamp, [ako - [val [furniture, electric]]]).
frame(standing_lamp, [ako - [val lamp]]).
```

<!-- page 222 -->
*Building Expert Systems in Prolog* *Rete-Foops — Room Knowledgebase (room.rkb)*

```prolog
frame(table_lamp, [ako - [val lamp],
place_on - [def table]
]
).
frame(tv, [ako - [val [furniture, electric]],
place_on - [calc tv_support]]
).
frame(knickknack, [ako - [val furniture],
length - [def 1],
place_on - [def table]
]
).
frame(wall, [length - [def 10],
outlets - [def 0],
space - [calc space_calc],
holding - [def []]
]
).
frame(door, [ako - [val furniture],
length - [def 4]
]
).
frame(goal, []).
frame(recommend, []).
% Calculate the available space if needed.  The available space is
% computed from the length of the item minus the sum of the lengths of
% the items it is holding.  The held items are in the holding list.
% The items in the list are identified only by their unique names.
% This is used by walls and tables.
space_calc(C,N,space-S) :-
getf(C,N,[length-L,holding-HList]),
sum_lengths(HList,0,HLen),
S is L - HLen.
sum_lengths([],L,L).
sum_lengths([C/N|T],X,L) :-
getf(C,N,[length-HL]),
XX is X + HL,
sum_lengths(T,XX,L).
% When placing the tv, check with the user to see if it goes on the
% floor or a table.
tv_support(tv,N,place_on-table) :-
nl,
write('Should the TV go on a table? '),
read(yes),
uptf(tv,N,[place_on-table]).
tv_support(tv,N,place_on-floor) :-
uptf(tv,N,[place_on-floor]).
```

212

<!-- page 223 -->
*Appendices - Full Source Code* *Rete-Foops — Room Knowledgebase (room.rkb)*

```prolog
% Whenever a piece is placed in position, update the holding list of the
% item which holds it (table or wall) and the available space.  If something
% is placed in front of something else, then do nothing.
pos_add(_,_,position-frontof(X)) :-
uptf(C,N,[holding-[X]]).
pos_add(C,N,position-CP/P) :-
getf(CP,P,[space-OldS]),
getf(C,N,[length-L]),
NewS is OldS - L,
NewS >= 0,
uptf(CP,P,[holding-[C/N],space-NewS]).
pos_add(C,N,position-CP/P) :-
nl,write_line(['Not enough room on',CP,P,for,C,N]),
!,fail.
% The forward chaining rules of the system.  They make use of call
% to activate some pure Prolog predicates at the end of the knowledge
% base.  In particular, data gathering, and wall space calculations
% are done in Prolog.
% These are the terms that are initially stored in working storage.
% They set a goal used to force firing of certain preliminary rules,
% and various facts about the problem domain used by the actual
% configuration rules.
initial_data([
wall - north with [opposite-south,right-west,left-east],
wall - south with [opposite-north,right-east,left-west],
wall - east with [opposite-west,right-north,left-south],
wall - west with [opposite-east,right-south,left-north],
goal - door_first,
door - d1 with [length - 3],
couch - c1 with [length - 6],
chair - ch1 with [length - 3],
chair - ch2 with [length - 3],
chair - ch3 with [length - 3],
chair - ch4 with [length - 3],
chair - ch5 with [length - 3],
chair - ch6 with [length - 3],
chair - ch7 with [length - 3],
tv - tv1 with [length - 2, place_on - floor] ]).
% first gather data, then try the couch first.
rule 1#
[goal - gather_data]
==>
[call(gather_data),
assert( goal - couch_first )].
rule a1#
[goal - door_first]
==>
[update( door - d1 with [position - wall/east]),
assert( goal - couch_first )].
% Rules f1-f13 illustrate the strength of rule based programming.
% Each rule captures a rule of thumb used in configuring furniture
% in a living room.  The rules are all independent, transparent,
% and can be easily maintained.  Complexity can be added without
% concern for the flow of control.
```

<!-- page 224 -->
*Building Expert Systems in Prolog* *Rete-Foops — Room Knowledgebase (room.rkb)*

```prolog
% f1, f2 - place the couch first, it should be either opposite the
% door, or to its right, depending on which wall has more space.
rule f1#
[goal - couch_first,
couch - C with [position-none,length-LenC],
door - D with [position-wall/W],
wall - W with [right-RW]]
==>
[update(couch - C with [position-wall/RW])].
rule f2#
[goal - couch_first,
couch - C with [position-none,length-LenC],
door - D with [position-wall/W],
wall - W with [opposite-OW]]
==>
[update(couch - C with [position-wall/OW])].
% f3 - f3a the tv should be opposite the couch.  If it needs a table, an
% end table should be placed under it, if no table is available put
% it on the floor anyway and recommend the purchase of a table.  The rules
% first check to see if the couch has been placed.
rule f3#
[couch - C with [position-wall/W],
wall - W with [opposite-OW],
tv - TV with [position-none,place_on-floor]]
==>
[update(tv - TV with [position-wall/OW])].
rule f4#
[couch - C with [position-wall/W],
wall - W with [opposite-OW],
tv - TV with [position-none,place_on-table],
end_table - T with [position-none]]
==>
[update(end_table - T with [position-wall/OW]),
update(tv - TV with [position-end_table/T])].
rule f4a#
[tv - TV with [position-none,place_on-table]]
==>
[assert(recommend - R with [buy-['table for tv']])].
% f5 - the coffee table should be in front of the couch.
rule f5#
[coffee_table - CT with [position-none],
couch - C]
==>
[update(coffee_table - CT with [position-frontof(couch/C)])].
% f6, f7 - chairs should be on adjacent walls from the couch, which ever
% has the most space
rule f6#
[chair - Ch with [position-none],
couch - C with [position-wall/W],
wall - W with [right-RW]]
==>
```

214

<!-- page 225 -->
*Appendices - Full Source Code* *Rete-Foops — Room Knowledgebase (room.rkb)*

```prolog
[update(chair - Ch with [position-wall/RW])].
rule f7#
[chair - Ch with [position-none],
couch - C with [position-wall/W],
wall - W with [left-LW]]
==>
[update(chair - Ch with [position-wall/LW])].
% put end_tables next to the couch first, then on the walls with
% the chairs
%rule f9#
% [end_table - ET with [position-none],
%  not tv - TV with [position-none,place_on-table],
%  couch - C with [position-wall/W],
%  not end_table - ET2 with [position-wall/W]]
% ==>
% [update(end_table - ET with [position-wall/W])].
%rule f10#
% [end_table - ET with [position-none],
%  not tv - TV with [position-none,place_on-table],
%  chair - C with [position-wall/W],
%  not end_table - ET2 with [position-wall/W]]
% ==>
% [update(end_table - ET with [position-wall/W])].
% put the table lamps on the end tables
rule f11#
[table_lamp - TL with [position-none],
end_table - ET with [position-wall/W]]
==>
[update( table_lamp - TL with [position-end_table/ET] )].
% put the knickknacks on anything which will hold them.
%rule f11a#
% [knickknack - KK with [position-none],
%  Table - T with [can_support-yes, position-wall/W]]
% ==>
% [update( knickknack - KK with [position-Table/T] )].
% get extension cords if needed
%rule f12#
% [Thing - X with [needs_outlet-yes, position-wall/W],
%  wall - W with [outlets-0]]
% ==>
% [assert(recommend - R with [buy-['extension cord'-W]])].
%rule f13#
% [Thing - X with [needs_outlet-yes, position-C/N],
%  C - N with [position-wall/W],
%  wall - W with [outlets-0]]
% ==>
% [assert(recommend - R with [buy-['extension cord'-Thing/W]])].
% When no other rules fire, here is the summary
```

<!-- page 226 -->
*Building Expert Systems in Prolog* *Rete-Foops — Room Knowledgebase (room.rkb)*

```prolog
finished :-
output_data.
% Prolog predicates called by various rules to perform functions better
% handled by Prolog.
% Gather the input data from the user.
gather_data :-
read_furniture,
read_walls.
read_furniture :-
get_frame(furniture,[legal_types-LT]),
write('Enter name of furniture at the prompt.  It must be one of:'), nl,
write(LT), nl,
write('Enter end to stop input.'), nl,
write('At the length prompt enter y or a new number.'), nl,
repeat,
write('>'), read(X),
process_furn(X),
!.  % end was input
process_furn(end).
process_furn(X) :-
get_frame(X,[length-DL]),
write(length-DL), write('>'),
read(NL),
get_length(NL,DL,L),
assert_ws(X - _ with [length-L]),
fail.
get_length(y,L,L) :- !.
get_length(L,_,L).
read_walls :-
nl, write('Enter data for the walls.'), nl,
write('What is the length of the north & south walls? '),
read(NSL),
update_ws(wall-north with [length-NSL]),
update_ws(wall-south with [length-NSL]),
write('What is the length of the east & west walls? '),
read(EWL),
update_ws(wall-east with [length-EWL]),
update_ws(wall-west with [length-EWL]),
write('Which wall has the door? '),
read(DoorWall),
write('What is its length? '),
read(DoorLength),
assert_ws(door-D with [length-DoorLength]),
update_ws(door-D with [position-wall/DoorWall]),
write('Which walls have outlets? (a list)'),
read(PlugWalls),
process_plugs(PlugWalls).
process_plugs([]) :- !.
process_plugs([H|T]) :-
update_ws(wall-H with [outlets-1]),
!,
process_plugs(T).
process_plugs(X) :-
```

216

<!-- page 227 -->
*Appendices - Full Source Code* *Rete-Foops — Room Knowledgebase (room.rkb)*

```prolog
update_ws(wall-X with [outlets-1]).
output_data :-
write('The final results are:'), nl,
output_walls,
output_tables,
output_recommends,
output_unplaced.
output_walls :-
getf(wall,W,[holding-HL]),
write_line([W,wall,holding|HL]),
fail.
output_walls.
output_tables :-
getf(C,N,[holding-HL]),
not C = wall,
write_line([C,N,holding|HL]),
fail.
output_tables.
output_recommends :-
getf(recommend,_,[buy-BL]),
write_line([purchase|BL]),
fail.
output_recommends.
output_unplaced :-
write('Unplaced furniture:'), nl,
getf(T,N,[position-none]),
write(T-N), nl,
fail.
output_unplaced.
```

<!-- page 228 -->
*Building Expert Systems in Prolog*

```prolog
% RETEPRED.PRO - the predicates that implement the Rete pattern
%                matching algorithm.
% It should be modified some day to use pointers to working memory in
% the memory predicates rather than the full tokens - this would save
% a lot of space.
% retecomp - compile rules into a rete network
:-op(800,xfx,==>).         % used to separate LHS and RHS of rule
:-op(500,xfy,#).           % used to separate attributes and values
:-op(810,fx,rule).         % used to define rule
:-op(700,xfy,#).           % used for unification instead of =
:-op(700,xfy,\=).          % not equal
:-op(600,xfy,with).        % used for frame instances in rules
```

### Rete Compiler (retepred.pro)

```prolog
abolish(root,3),
abolish(bi,4),
abolish(tes,4),
abolish(rul,3),
abolish(varg,1),
abolish(nid,1),
asserta(nid(0)),
rete_compil.
%  display_net.
display_net :-
display_roots,nl,
display_bis,nl,
display_teses,nl,
display_ruls.
display_roots :-
root(N,A,B),
write( root(N,A,B) ), nl,
fail.
display_roots.
display_bis :-
bi(A,B,C,D),
write(bi(A)), nl,
write_list([left|B]),
write_list([right|C]),
write(D), nl, nl,
fail.
display_bis.
display_teses :-
tes(A,B,C,D),
write(tes(A)), nl,
write_list([left|B]),
write_list([right|C]), nl,
write(D), nl, nl,
fail.
display_teses.
display_ruls :-
rul(A,B,C),
```

<!-- page 229 -->
*Building Expert Systems in Prolog* *Rete-Foops — Rete Compiler (retepred.pro)*

```prolog
write(rul(A)), nl,
write_list([left|B]),
write_list([right|C]), nl,
fail.
display_ruls.
write_list([]).
write_list([H|T]) :-
write(H), nl,
wr_lis(T).
wr_lis([]).
wr_lis([H|T]) :-
tab(5),write(H), nl,
wr_lis(T).
% compile each rule into the rete net
rete_compil :-
rule N# LHS ==> RHS,
rete_comp(N,LHS,RHS),
fail.
rete_compil :-
message(201).
% compile an individual rule into the net
rete_comp(N,[H|T],RHS) :-
term(H,Hw),
check_root(RN,Hw,HList),
retcom(root(RN),[Hw/_],HList,T,N,RHS),
message(202,N),
!.
rete_comp(N,_,_) :-
message(203,N).
% the main compile loop
% PNID - the id of the previous node
% OutTok - list of tokens from previous node
% PrevList - transfer list from previous node
% [H|T] - list of remaining clauses in rule
% N - The rule ID, for building the rule at the end
% RHS - the rhs of the rule for building the rule at the end
retcom(PNID,OutTok,PrevList,[],N,RHS) :-
build_rule(OutTok,PrevList,N,RHS),
update_node(PNID,PrevList,rule-N),
!.
retcom(PNID,PrevNode,PrevList,[H|T],N,RHS) :-
term(H,Hw),
check_root(RN,Hw,HList),
check_node(PrevNode,PrevList,[Hw/_],HList,NID,OutTok,NList),
update_node(PNID,PrevList,NID-l),
update_root(RN,HList,NID-r),
!,
retcom(NID,OutTok,NList,T,N,RHS).
retcom(PNID,PrevNode,PrevList,[H|T],N,RHS) :-  % some kind of tester call
check_tnode(PrevNode,PrevList,[H/0],HList,NID,OutTok,NList),
update_node(PNID,PrevList,test-NID),
!,
retcom(test-NID,OutTok,NList,T,N,RHS).
term(Class-Name with List,Class-Name with List).
```

<!-- page 230 -->
*Building Expert Systems in Prolog* *Rete-Foops — Rete Compiler (retepred.pro)*

```prolog
term(Class-Name, Class-Name with []).
check_root(NID,Term,[]) :-
not(root(_,Term,_)),
gen_nid(NID),
assertz( root(NID,Term,[]) ),
!.
check_root(N,Term,List) :-
asserta(temp(Term)),
retract(temp(T1)),
root(N,Term,List),
root(N,T2,_),
comp_devar(T1,T2),
!.
check_root(NID,Term,[]) :-
gen_nid(NID),
assertz( root(NID,Term,[]) ).
% if this node was already on the list do nothing, otherwise add it
% to the list
update_root(RN,HList,NID) :-
member(NID,HList),
!.
update_root(RN,HList,NID) :-
retract(root(RN,H,HList)),
asserta(root(RN,H,[NID|HList])).
update_node(root(RN),HList,NID) :-
update_root(RN,HList,NID),
!.
update_node(X,PrevList,NID) :-
member(NID,PrevList),
!.
update_node(test-N,PrevList,NID) :-
retract(tes(N,L,T,_)),
asserta(tes(N,L,T,[NID|PrevList])),
!.
update_node(PNID,PrevList,NID) :-
retract(bi(PNID,L,R,_)),
asserta(bi(PNID,L,R,[NID|PrevList])).
% check to see if there is a node which already fits, otherwise
% create a new one
% PNode - token list from previous node
% PList - list of successor nodes from previous node
% H - new token being added
% HList - successor nodes from root for token H
% NID - returned ID of the node
% OutTok - returned tokenlist from the node
% NList - returned list of successor nodes from the node
% first case - there isn't a matching rule using Prolog's match, so
%   build a new one
check_node(PNode,PList,H,HList,NID,OutTok,[]) :-
not (bi(_,PNode,H,_)),
append(PNode,H,OutTok),
gen_nid(NID),
assertz(bi(NID,PNode,H,[])),
!.
% second case - there was a matching rule using Prolog's match, so
```

220

<!-- page 231 -->
*Appendices - Full Source Code* *Rete-Foops — Rete Compiler (retepred.pro)*

```prolog
%   match again using generated constants instead of variables.  If
%   this matches then we have a match, otherwise we had a match
%   where variables don't line up and its no good. (asserts and
%   retracts allow different variables to have same information and
%   prevent binding of variables in one from affecting the other)
check_node(PNode,PList,H,HList,NID,OutTok,NList) :-
append(PNode,H,OutTok),
asserta(temp(OutTok)),
retract(temp(Tot1)),
bi(NID,PNode,H,NList),
bi(NID,T2,T3,_),
append(T2,T3,Tot2),
comp_devar(Tot1,Tot2),
!.
% third case - the variables didn't line up from the second rule, so
%   make a new node.
check_node(PNode,PList,H,HList,NID,OutTok,[]) :-
append(PNode,H,OutTok),
gen_nid(NID),
assertz(bi(NID,PNode,H,[])).
% check for test node - similar to check for regular node
check_tnode(PNode,PList,H,HList,NID,OutTok,[]) :-
not (tes(_,PNode,H,_)),
append(PNode,H,OutTok),
gen_nid(NID),
assertz(tes(NID,PNode,H,[])),
!.
% second case - there was a matching rule using Prolog's match, so
%   match again using generated constants instead of variables.  If
%   this matches then we have a match, otherwise we had a match
%   where variables don't line up and its no good. (asserts and
%   retracts allow different variables to have same information and
%   prevent binding of variables in one from affecting the other)
check_tnode(PNode,PList,H,HList,NID,OutTok,NList) :-
append(PNode,H,OutTok),
asserta(temp(OutTok)),
retract(temp(Tot1)),
tes(NID,PNode,H,NList),
tes(NID,T2,T3,_),
append(T2,T3,Tot2),
comp_devar(Tot1,Tot2),
!.
% third case - the variables didn't line up from the second rule, so
%   make a new node.
check_tnode(PNode,PList,H,HList,NID,OutTok,[]) :-
append(PNode,H,OutTok),
gen_nid(NID),
assertz(tes(NID,PNode,H,[])).
build_rule(OutTok,PrevList,N,RHS) :-
assertz(rul(N,OutTok,RHS)).
gen_nid(NID) :-
```

<!-- page 232 -->
*Building Expert Systems in Prolog* *Rete-Foops — Rete Compiler (retepred.pro)*

```prolog
retract(nid(N)),
NID is N + 1,
asserta(nid(NID)).
% the hard part, undo Prolog's pattern matching so variables match just
% variables and not constants.  de-var replaces all the variables with
% generated constants - this ensures only variables will match variables.
comp_devar(T1,T2) :-
de_vari(T1),
de_vari(T2),
T1 = T2.
de_vari([]).
de_vari([H|T]) :-
de_var(H),
de_vari(T).
de_vari(X) :-
de_var(X).
de_var(X/_) :-
de_var(X).
de_var(X-Y with List) :-
init_vargen,
de_v(X-Y),
de_vl(List),
!.
de_var(X-Y) :-
init_vargen,
de_v(X-Y),
!.
de_vl([]).
de_vl([H|T]) :-
de_v(H),
de_vl(T).
de_v(X-Y) :-
d_v(X),
d_v(Y).
d_v(V) :-
var(V),
var_gen(V),
!.
d_v(_).
init_vargen :-
abolish(varg,1),
asserta(varg(1)).
var_gen(V) :-
retract(varg(N)),
NN is N + 1,
asserta(varg(NN)),
string_integer(NS,N),
string_list(NS,NL),
append("#VAR_",NL,X),
name(V,X).
```

222

<!-- page 233 -->
*Appendices - Full Source Code* *Rete-Foops — Rete Compiler (retepred.pro)*

```prolog
% predicates to update the rete network
% add a token to the rete net.  a token is of the form C-N with [S-V,...]
% ReqList gets bound with the values from the term added to the database.
addrete(Class,Name,TimeStamp) :-
root(ID,Class-Name with ReqList, NextList),
ffsend(Class,Name,ReqList,TimeStamp,NextList),
fail.
addrete(_,_,_).
% fullfill the request list from the token, and send the instantiated
% token through the net.
ffsend(Class,Name,ReqList,TimeStamp,NextList) :-
getf(Class,Name,ReqList),
send(tok(add,[(Class-Name with ReqList)/TimeStamp]), NextList),
!.
delrete(Class,Name,TimeStamp) :-
root(ID,Class-Name with ReqList, NextList),
delr(Class,Name,ReqList,TimeStamp),
fail.
delrete(_,_,_).
delr(Class,Name,ReqList,TimeStamp) :-
getf(Class,Name,ReqList),
!,
send(tok(del,[(Class-Name with ReqList)/TimeStamp]), NextList).
delr(Class,Name,ReqList,TimeStamp).
% send the new token to each of the succesor nodes
send(_,[]).
send(Tokens,[Node|Rest]) :-
sen(Node,Tokens),
send(Tokens,Rest).
% add or delete the new token from the appropriate memory, build new
% tokens from left or right and send them to successor nodes.
sen(rule-N,tok(AD,TokenList)) :-
rul(N,TokenList,Actions),
(AD = add, add_conflict_set(N,TokenList,Actions);
AD = del, del_conflict_set(N,TokenList,Actions)
),
!.
sen(Node-l,tok(AD,TokenList)) :-
bi(Node,TokenList,Right,NextList),
(AD = add, asserta(memory(Node-l,TokenList));
AD = del, retract(memory(Node-l,TokenList))
),
!,
matchRight(Node,AD,TokenList,Right,NextList).
sen(Node-r,tok(AD,TokenList)) :-
bi(Node,Left,TokenList,NextList),
(AD = add, asserta(memory(Node-r,TokenList));
AD = del, retract(memory(Node-r,TokenList))
),
!,
matchLeft(Node,AD,TokenList,Left,NextList).
sen(test-N,tok(AD,TokenList)) :-
```

<!-- page 234 -->
*Building Expert Systems in Prolog* *Rete-Foops — Rete Compiler (retepred.pro)*

```prolog
tes(N,TokenList,[Test/0],NextList),
test(Test),
append(TokenList,[Test/0],NewToks),
!,
send(tok(AD,NewToks),NextList).
matchRight(Node,AD,TokenList,Right,NextList) :-
memory(Node-r,Right),
append(TokenList,Right,NewToks),
send(tok(AD,NewToks),NextList),
fail.
matchRight(_,_,_,_,_).
matchLeft(Node,AD,TokenList,Left,NextList) :-
memory(Node-l,Left),
append(Left,TokenList,NewToks),
send(tok(AD,NewToks),NextList),
fail.
matchLeft(_,_,_,_,_).
```

224

<!-- page 235 -->
*Appendices - Full Source Code*

```prolog
% RETEFOOP.PRO - forward chaining, frames, and Rete algorithm, also using
%                LEX and MEA to sort the conflict set.
%
% Copyright (c) Dennis Merritt, 1988
% operator definitions
:-op(800,xfx,==>).          % used to separate LHS and RHS of rule
:-op(500,xfy,#).            % used to separate attributes and values
:-op(810,fx,rule).          % used to define rule
:-op(700,xfy,#).            % used for unification instead of =
:-op(700,xfy,\=).           % not equal
:-op(600,xfy,with).         % used for frame instances in rules
main :- welcome, supervisor.
welcome  :-
write($         RETEFOOP - A Toy Production System$), nl, nl,
write($This is an interpreter for files containing rules coded in the$), nl,
write($FOOPS format.$), nl, nl,
write($The => prompt accepts three commands:$), nl, nl,
write($   load.       - prompts for name of rules file$), nl,
write($                 enclose in single quotes$), nl,
write($   compile.    - compiles rules into a rete net$), nl,
write($   displaynet. - displays the rete net$), nl,
write($   list.       - lists stuff$), nl,
write($   list(X).    - lists things which match X$), nl,
write($   options.    - allows setting of message levels$), nl,
write($   go.         -  starts the inference$), nl,
write($   exit.       - does what you'd expect$), nl, nl.
% the supervisor, uses a repeat fail loop to read and process commands
% from the user
supervisor :-
repeat,
write('=>'),
read(X),
doit(X),
X = exit.
doit(X) :-
timer(T1),
do(X),
timer(T2),
T is (T2 - T1) / 600,
message(101,T),
!.
% actions to take based on commands
do(exit) :- !.
do(go) :-
initialize,
go,
!.
do(load) :-
load,
!.
```

<!-- page 236 -->
*Building Expert Systems in Prolog* *Rete-Foops — Rete Runtime (retefoop.pro)*

```prolog
do(compile) :-
compile,
!.
do(displaynet) :-
display_net,
!.
do(list) :-
lst,  % lists all of working storage
!.
do(list(X)) :-
lst(X),  % lists all that match the pattern
!.
do(options) :-
set_messtypes,
!.
do(_) :-
message(102).
% loads the rules (Prolog terms) into the Prolog database
load :-
write('Enter the file name in single quotes (ex. ''room.rkb''.): '),
read(F),
reconsult(F),  % loads a rule file into interpreter work space
rete_compile.  % ** rete change **
compile :-
rete_compile.
% assert each of the initial conditions into working storage
initialize :-
message(120),
abolish(memory,2),
abolish(inst,3),
setchron(1),
delf(all),
abolish(conflict_set,1),
assert(conflict_set([])),
assert(mea(no)),
initial_data(X),
assert_list(X),
message(121),
!.
initialize :-
message(103).
% working storage is represented frame instances - frinsts and also
% stored in a rete net
assert_list([]) :- !.
assert_list([H|T]) :-
assert_ws(H),
!,
assert_list(T).
% the main inference loop, find a rule and try it.  If it fired, say so
% and repeat the process.  If not, go back and try the next rule.  When
% no rules succeed, stop the inference.
go :-
conflict_set(CS),
select_rule(CS,inst(ID,LHS,RHS)),
```

226

<!-- page 237 -->
*Appendices - Full Source Code* *Rete-Foops — Rete Runtime (retefoop.pro)*

```prolog
message(104,ID),
(process(ID,RHS,LHS); true),  % action side might fail
del_conflict_set(ID,LHS,RHS),
!,
go.
go :-
conflict_set([]),
finished,  % supplied in kb for what to do at end
!.
go :-
message(119).
del_conflict_set(N,TokenList,Action) :-
conflict_set(CS),
remove(inst(N,TokenList,Action),CS,CS2),
message(105,N),
retract(conflict_set(_)),
asserta(conflict_set(CS2)).
del_conflict_set(N,TokenList,Action) :-
message(106,N).
add_conflict_set(N,TokenList,Action) :-
message(107,N),
retract(conflict_set(CS)),
asserta(conflict_set([inst(N,TokenList,Action)|CS])).
select_rule(CS,R) :-
message(122,CS),
mea_filter(0,CS,[],CSR),
lex_sort(CSR,R).
% sort the rest of the conflict set according to the lex strategy
lex_sort(L,R) :-
build_keys(L,LK),
sort(LK,X),
reverse(X,[K-R|_]).
% build lists of time stamps for lex sort keys
build_keys([],[]).
build_keys([inst(N,TokenList,C)|T],[Key-inst(N,TokenList,C)|TR]) :-
build_chlist(TokenList,ChL),
sort(ChL,X),
reverse(X,Key),
build_keys(T,TR).
% build a list of just the times of the various matched attributes
% for use in rule selection
build_chlist([],[]).
build_chlist([_/Chron|T],[Chron|TC]) :-
build_chlist(T,TC).
% add the test for mea if appropriate that emphasizes the first attribute
% selected.
mea_filter(_,X,_,X) :-
not mea(yes),
!.
mea_filter(_,[],X,X).
mea_filter(Max,[inst(N,[A/T|Z],C)|X],Temp,ML) :-
```

<!-- page 238 -->
*Building Expert Systems in Prolog* *Rete-Foops — Rete Runtime (retefoop.pro)*

```prolog
T < Max,
!,
mea_filter(Max,X,Temp,ML).
mea_filter(Max,[inst(N,[A/T|Z],C)|X],Temp,ML) :-
T = Max,
!,
mea_filter(Max,X,[inst(N,[A/T|Z],C)|Temp],ML).
mea_filter(Max,[inst(N,[A/T|Z],C)|X],Temp,ML) :-
T > Max,
!,
mea_filter(T,X,[inst(N,[A/T|Z],C)],ML).
get_ws(Prem,Time) :-
conv(Prem,Class,Name,ReqList),
getf(Class,Name,ReqList,Time).
assert_ws(Prem) :-
message(109,Prem),
conv(Prem,Class,Name,AList),
addf(Class,Name,AList,TimeStamp),
addrete(Class,Name,TimeStamp).
update_ws(Prem) :-
conv(Prem,Class,Name,UList),
frinst(Class,Name,_,TS),
uptrf(Class,Name,UList,TimeStamp),    % note - does delrete in uptrf
addrete(Class,Name,TimeStamp),
!.
update_ws(Prem) :-
message(108,Prem).
retract_ws(Prem/T) :- retract_ws(Prem).
retract_ws(Prem) :-
conv(Prem,Class,Name,UList),
delrete(Class,Name,TimeStamp),
delf(Class,Name,UList).
conv(Class-Name with List, Class, Name, List).
conv(Class-Name, Class, Name, []).
% various tests allowed on the LHS
test(not(X)) :-
get_ws(X,_),
!,
fail.
test(not(X)) :- !.
test(X#Y) :-
X = Y,
!.
test(X>Y) :-
X > Y,
!.
test(X>=Y) :-
X >= Y,
!.
test(X<Y) :-
X < Y,
!.
test(X=<Y) :-
X =< Y,
!.
```

228

<!-- page 239 -->
*Appendices - Full Source Code* *Rete-Foops — Rete Runtime (retefoop.pro)*

```prolog
test(X \= Y) :-
not X = Y,
!.
test(X = Y) :-
X = Y,
!.
test(X = Y) :-
X is Y,
!.
test(is_on(X,Y)) :-
is_on(X,Y),
!.
test(call(X)) :-
call(X).
% recursively execute each of the actions in the RHS list
process(N,[],_) :-
message(118,N),
!.
process(N,[Action|Rest],LHS) :-
take(Action,LHS),
!,
process(N,Rest,LHS).
process(N,[Action|Rest],LHS) :-
message(110,N),
!,
fail.
% if its retract, use the reference numbers stored in the Lrefs list,
% otherwise just take the action
take(retract(N),LHS) :-
(N == all; integer(N)),
retr(N,LHS),
!.
take(A,_) :-
take(A),
!.
take(retract(X)) :-
retract_ws(X),
!.
take(assert(X)) :-
assert_ws(X),
!.
take(update(X)) :-
update_ws(X),
!.
take(X # Y) :-
X = Y,
!.
take(X = Y) :-
X is Y,
!.
take(write(X)) :-
write(X),
!.
take(write_line(X)) :-
write_line(X),
!.
take(nl) :-
nl,
!.
take(read(X)) :-
```

<!-- page 240 -->
*Building Expert Systems in Prolog* *Rete-Foops — Rete Runtime (retefoop.pro)*

```prolog
read(X),
!.
take(prompt(X,Y)) :-
nl,
write(X),
read(Y),
!.
take(cls) :-
cls,
!.
take(is_on(X,Y)) :-
is_on(X,Y),
!.
take(list(X)) :-
lst(X),
!.
take(call(X)) :-
call(X).
% logic for retraction
retr(all,LHS) :-
retrall(LHS),
!.
retr(N,[]) :-
message(111,N),
!.
retr(N,[N#Prem|_]) :-
retract_ws(Prem),
!.
retr(N,[_|Rest]) :-
!,
retr(N,Rest).
retrall([]).
retrall([N#Prem|Rest]) :-
retract_ws(Prem),
!,
retrall(Rest).
retrall([Prem|Rest]) :-
retract_ws(Prem),
!,
retrall(Rest).
retrall([_|Rest]) :-  % must have been a test
retrall(Rest).
% list all of the terms in working storage
lst :- printfs.
% lists all of the terms which match the pattern
lst(X) :-
get_ws(X,_),
write(X), nl,
fail.
lst(_) :- !.
% maintain a time counter
setchron(N) :-
retract(chron(_)),
asserta(chron(N)),
```

230

<!-- page 241 -->
*Appendices - Full Source Code* *Rete-Foops — Rete Runtime (retefoop.pro)*

```prolog
!.
setchron(N) :-
asserta(chron(N)).
getchron(N) :-
retract(chron(N)),
NN is N + 1,
asserta(chron(NN)),
!.
% this implements a frame based scheme for knowledge representation
:- op(600,fy,val).
:- op(600,fy,calc).
:- op(600,fy,def).
:- op(600,fy,add).
:- op(600,fy,del).
% prep_req takes a request of the form Slot-Val, and forms it into the
% more accurate req(Class,Slot,Facet,Value).  If no facet was mentioned
% in the original request, then the facet of "any" is used to indicate
% the system should use everything possible to find a value.
prep_req(Slot-X,req(C,N,Slot,val,X)) :-
var(X),
!.
prep_req(Slot-X,req(C,N,Slot,Facet,Val)) :-
nonvar(X),
X =.. [Facet,Val],
facet_list(FL),
is_on(Facet,FL),
!.
prep_req(Slot-X,req(C,N,Slot,val,X)).
facet_list([val,def,calc,add,del,edit]).
% retrieve a list of slot values
get_frame(Class, ReqList) :-
frame(Class, SlotList),
slot_vals(Class,_,ReqList,SlotList).
getf(Class,Name,ReqList) :-
getf(Class,Name,ReqList,_).
getf(Class,Name,ReqList,TimeStamp) :-
frinst(Class, Name, SlotList, TimeStamp),
slot_vals(Class, Name, ReqList, SlotList).
slot_vals(_,_,[],_).
slot_vals(C,N,[Req|Rest],SlotList) :-
prep_req(Req,req(C,N,S,F,V)),
find_slot(req(C,N,S,F,V),SlotList),
!,
slot_vals(C,N,Rest,SlotList).
slot_vals(C,N, Req, SlotList) :-
prep_req(Req,req(C,N,S,F,V)),
find_slot(req(C,N,S,F,V), SlotList).
find_slot(req(C,N,S,F,V), SlotList) :-
nonvar(V),
```

<!-- page 242 -->
*Building Expert Systems in Prolog* *Rete-Foops — Rete Runtime (retefoop.pro)*

```prolog
!,
find_slot(req(C,N,S,F,Val), SlotList),
!,
(Val = V; list(Val),is_on(V,Val)).
find_slot(req(C,N,S,F,V), SlotList) :-
is_on(S-FacetList, SlotList),
!,
facet_val(req(C,N,S,F,V),FacetList).
find_slot(req(C,N,S,F,V), SlotList) :-
is_on(ako-FacetList, SlotList),
facet_val(req(C,N,ako,val,Ako),FacetList),
(is_on(X,Ako); X = Ako),
frame(X, HigherSlots),
find_slot(req(C,N,S,F,V), HigherSlots),
!.
find_slot(Req,_) :-
message(112,Req),
fail.
facet_val(req(C,N,S,F,V),FacetList) :-
FV =.. [F,V],
is_on(FV,FacetList),
!.
facet_val(req(C,N,S,val,V),FacetList) :-
is_on(val ValList,FacetList),
is_on(V,ValList),
!.
facet_val(req(C,N,S,val,V),FacetList) :-
is_on(calc Pred,FacetList),
CalcPred =.. [Pred,C,N,S-V],
call(CalcPred),
!.
facet_val(req(C,N,S,val,V),FacetList) :-
is_on(def V,FacetList),
!.
% add a list of slot values
add_frame(Class, UList) :-
old_slots(Class,SlotList),
add_slots(Class,_,UList,SlotList,NewList),
retract(frame(Class,_)),
asserta(frame(Class,NewList)),
!.
addf(Class,Nm,UList) :-
addf(Class,Nm,UList,TimeStamp).
addf(Class,Nm,UList,TimeStamp) :-
(var(Nm), genid(Name); Name = Nm),
add_slots(Class,Name,[ako-Class|UList],SlotList,NewList),
getchron(TimeStamp),
asserta(frinst(Class,Name,NewList,TimeStamp)),
!.
uptf(Class,Name,UList) :-
uptf(Class,Name,UList,TS).
uptf(Class,Name,UList,TimeStamp) :-
frinst(Class,Name,SlotList,TS),
add_slots(Class,Name,UList,SlotList,NewList),
retract(frinst(Class,Name,_,_)),
```

232

<!-- page 243 -->
*Appendices - Full Source Code* *Rete-Foops — Rete Runtime (retefoop.pro)*

```prolog
getchron(TimeStamp),
asserta(frinst(Class,Name,NewList,TimeStamp)),
!.
uptf(Class,Name,UList,TimeStamp) :-
message(113,[Class,Name,UList]).
uptrf(Class,Name,UList) :-
uptf(Class,Name,UList,TS).
uptrf(Class,Name,UList,TimeStamp) :-
frinst(Class,Name,SlotList,TS),
add_slots(Class,Name,UList,SlotList,NewList),
delrete(Class,Name,TS),
retract(frinst(Class,Name,_,_)),
getchron(TimeStamp),
asserta(frinst(Class,Name,NewList,TimeStamp)),
!.
uptrf(Class,Name,UList,TimeStamp) :-
message(113,[Class,Name,UList]).
genid(G) :-
retract(gid(N)),
G is N + 1,
asserta(gid(G)).
gid(100).
old_slots(Class,SlotList) :-
frame(Class,SlotList),
!.
old_slots(Class,[]) :-
asserta(frame(Class,[])).
old_flots(Class,Name,SlotList) :-
frinst(Class,Name,SlotList,_).
add_slots(_,_,[],X,X).
add_slots(C,N,[U|Rest],SlotList,NewList) :-
prep_req(U,req(C,N,S,F,V)),
add_slot(req(C,N,S,F,V),SlotList,Z),
!,
add_slots(C,N,Rest,Z,NewList).
add_slots(C,N,X,SlotList,NewList) :-
prep_req(X,req(C,N,S,F,V)),
add_slot(req(C,N,S,F,V),SlotList,NewList).
add_slot(req(C,N,S,F,V),SlotList,[S-FL2|SL2]) :-
delete(S-FacetList,SlotList,SL2),
add_facet(req(C,N,S,F,V),FacetList,FL2).
add_facet(req(C,N,S,F,V),FacetList,[FNew|FL2]) :-
FX =.. [F,OldVal],
delete(FX,FacetList,FL2),
add_newval(OldVal,V,NewVal),
!,
check_add_demons(req(C,N,S,F,V),FacetList),
FNew =.. [F,NewVal].
```

<!-- page 244 -->
*Building Expert Systems in Prolog* *Rete-Foops — Rete Runtime (retefoop.pro)*

```prolog
add_newval(X,Val,Val) :-
var(X),
!.
add_newval(OldList,ValList,NewList) :-
list(OldList),
list(ValList),
append(ValList,OldList,NewList),
!.
add_newval([H|T],Val,[Val,H|T]).
add_newval(_,Val,Val).
check_add_demons(req(C,N,S,F,V),FacetList) :-
get_frame(C,S-add(Add)),
!,
AddFunc =.. [Add,C,N,S-V],
call(AddFunc).
check_add_demons(_,_).
% delete a list of slot values
del_frame(Class) :-
retract(frame(Class,_)).
del_frame(Class) :-
message(114,Class).
del_frame(Class, UList) :-
old_slots(Class,SlotList),
del_slots(Class,_,UList,SlotList,NewList),
retract(frame(Class,_)),
asserta(frame(Class,NewList)).
delf(all) :-
retract(frinst(_,_,_,_)),
fail.
delf(all).
delf(Class,Name) :-
retract(frinst(Class,Name,_,_)),
!.
delf(Class,Name) :-
message(115,Class-Name).
delf(Class,Name,[]) :-
!,
delf(Class,Name).
delf(Class,Name,UList) :-
old_flots(Class,Name,SlotList),
del_slots(Class,Name,UList,SlotList,NewList),
retract(frinst(Class,Name,_,_)),
getchron(TimeStamp),
asserta(frinst(Class,Name,NewList,TimeStamp)).
del_slots(_,_,[],X,X).
del_slots(C,N,[U|Rest],SlotList,NewList) :-
prep_req(U,req(C,N,S,F,V)),
del_slot(req(C,N,S,F,V),SlotList,Z),
del_slots(C,N,Rest,Z,NewList).
del_slots(C,N,X,SlotList,NewList) :-
prep_req(X,req(C,N,S,F,V)),
del_slot(req(C,N,S,F,V),SlotList,NewList).
```

234

<!-- page 245 -->
*Appendices - Full Source Code* *Rete-Foops — Rete Runtime (retefoop.pro)*

```prolog
del_slot(req(C,N,S,F,V),SlotList,[S-FL2|SL2]) :-
remove(S-FacetList,SlotList,SL2),
del_facet(req(C,N,S,F,V),FacetList,FL2).
del_slot(Req,_,_) :-
message(116,Req).
del_facet(req(C,N,S,F,V),FacetList,FL) :-
FV =.. [F,V],
remove(FV,FacetList,FL),
!,
check_del_demons(req(C,N,S,F,V),FacetList).
del_facet(req(C,N,S,F,V),FacetList,[FNew|FL]) :-
FX =.. [F,OldVal],
remove(FX,FacetList,FL),
remove(V,OldVal,NewValList),
FNew =.. [F,NewValList],
!,
check_del_demons(req(C,N,S,F,V),FacetList).
del_facet(Req,_,_) :-
message(117,Req).
check_del_demons(req(C,N,S,F,V),FacetList) :-
get_frame(C,S-del(Del)),
!,
DelFunc =.. [Del,C,N,S-V],
call(DelFunc).
check_del_demons(_,_).
% print a frame
print_frames :-
frame(Class, SlotList),
print_frame(Class),
fail.
print_frames.
print_frame(Class) :-
frame(Class,SlotList),
write_line(['Frame:',Class]),
print_slots(SlotList), nl.
printfs :-
frame(Class,_),
printf(Class,_),
fail.
printfs.
printf(Class,Name) :-
frinst(Class,Name,SlotList,Time),
write_line(['Frame:',Class,Name,Time]),
print_slots(SlotList), nl.
printf(Class) :-
frinst(Class,Name,SlotList,Time),
write_line(['Frame:',Class,Name,Time]),
print_slots(SlotList), nl,
fail.
printf(_).
```

<!-- page 246 -->
*Building Expert Systems in Prolog* *Rete-Foops — Rete Runtime (retefoop.pro)*

```prolog
print_slots([]).
print_slots([Slot|Rest]) :-
write_line(['  Slot:',Slot]),
print_slots(Rest).
% utilities
delete(X,[],[]).
delete(X,[X|Y],Y) :- !.
delete(X,[Y|Z],[Y|W]) :-
delete(X,Z,W).
remove(X,[X|Y],Y) :- !.
remove(X,[Y|Z],[Y|W]) :-
remove(X,Z,W).
is_on(X,[X|Y]).
is_on(X,[Y|Z]) :-
is_on(X,Z).
write_line([]) :- nl.
write_line([H|T]) :-
write(H),tab(1),
write_line(T).
time_test :-
write('TT> '),
read(X),
timer(T1),
X,
timer(T2),
nl, nl,
T is (T2 - T1) / 10,
write(time-T).
append([H|T], W, [H|Z]) :-
append(T, W, Z).
append([], W, W).
member(X, [X|_]).
member(X, [_|T]) :-
member(X,T).
reverse(L1,L2) :-
revzap(L1,[],L2).
revzap([X|L],L2,L3) :-
revzap(L,[X|L2],L3).
revzap([],L,L).
% Message handling and messages
message(N) :-
message(N,'').
message(N,Args) :-
mess(N,break,Text),
```

236

<!-- page 247 -->
*Appendices - Full Source Code* *Rete-Foops — Rete Runtime (retefoop.pro)*

```prolog
write(break), tab(1), write(N), write(': '), write(Text), write(Args), nl.
%  break.
message(N,Args) :-
mess(N,error,Text),
write(error), tab(1), write(N), write(': '), write(Text), write(Args), nl,
!,
fail.
message(N,Args) :-
mess(N,Type,Text),
mess_types(TT),
member(Type,TT),
write(Type), tab(1), write(N), write(': '), write(Text), write(Args), nl,
!.
message(_,_).
mess_types([info,trace,warning,debug]).
set_messtypes :-
message(123,[info,warn,trace,error,debug]),
mess_types(X),
message(124,X),
read(MT),
retract(mess_types(_)),
asserta(mess_types(MT)).
mess(101,info , 'Time for command: ').             % retefoops doit
mess(102,error, 'Invalid Command').                % retefoops do
mess(103,error, 'Initialization Error').           % retefoops initialize
mess(104,trace, 'Rule Firing: ').                  % retefoops go
mess(105,trace, 'Conflict Set Delete: ').          % retefoops del_confli...
mess(106,trace, 'Failed to CS Delete: ').          % retefoops del_confli...
mess(107,trace, 'Conflict Set Add: ').             % retefoops add_confli...
mess(108,error, 'Update Fails for: ').             % retefoops update_ws
mess(109,trace, 'Asserting: ').                    % retefoops add_ws
mess(110,trace, 'Failing Action Part: ').          % retefoops process
mess(111,error, 'Retract Error, no: ').            % retefoops take
mess(112,debugx, 'Frame error looking for: ').     % retefoops find_slot
mess(113,error, 'Frame instance update error: ').  % retefoops uptf
mess(114,error, 'No frame to delete: ').           % retefoops del_frame
mess(115,error, 'No instance to delete: ').        % retefoops delf
mess(116,error, 'Unable to delete slot: ').        % retefoops del_slot
mess(117,error, 'Unable to delete facet: ').       % retefoops del_facet
mess(118,trace, 'Rule Fired: ').                   % retefoops process
mess(119,error, 'Premature end to run: ').         % retefoops go
mess(120,info, 'Initializing').                    % retefoops initialize
mess(121,info, 'Initialization Complete').         % retefoops initialize
mess(122,debugx, 'Conflict Set').                  % retefoops select_rule
mess(123,info, 'Legal Message Types: ').           % retefoops set_message
mess(124,info, 'Current Message Types: ').         % retefoops set_message
mess(201,info, 'Rule Rete Network Complete').      % retecomp rete_compil
mess(202,info, 'Rule: ').                          % retecomp rete_comp
mess(203,error, 'Rule Failed to Compile: ').       % retecomp rete_comp
```

<!-- page 249 -->
*Building Expert Systems in Prolog* F Windows

### Windows Demonstration (windemo.pro)

```prolog
% WINDEMO.PRO - demonstrates how to use windows
:- module windemo.
:- public main/0, restart/0.
:- extrn window/2:far, window/3:far.
main:-
cls,
go.
restart:-
halt.
go:-
create_windows,
ctr_set(1,1),            % used by list2
ctr_set(3,1),            % used by dummy
repeat,
window(wmain,read,X),
do(X),
fail.
create_windows:-
window(wform, create,
[type(form),
coord(8,20,16,53),
title(' Form not Function '),
border(white:magenta),contents(white:magenta),
form([lit(2:5,'First'),
var(one,2:20,8,''),
lit(4:5,'Second'),
var(two,4:20,8,'two'),
lit(6:5,'Third'),
var(three,6:20,8,'')
]
)
]
),
window(wform2, create,
[type(form),
coord(12,24,14,49),
title(' Form two '),
border(white:green),contents(white:green),
form([lit(2:3,'First and Last'),
var(three,2:20,8,'')
]
)
]
),
window(wprompt, create,
[type(prompt),
coord(18,10,18,70),
border(black:green),
```

<!-- page 250 -->
*Building Expert Systems in Prolog* *Windows — Windows Demonstration (windemo.pro)*

```prolog
contents(black:green),
title(' input ')
]
),
window(wmain, create,
[type(menu),
coord(15,25,20,40),
border(blue),
contents(yellow),
menu(['new numbers',
'add numbers',
'try prompt',
'try dynamic',
'try form',
exit,
one,two,three,four,five,six,seven
]
)
]
),
window(wexit, create,
[type(display),
coord(20,40,21,50),
border(black:red),
contents(black:red),
title(' exit ')
]
),
window(wdummy, create,
[type(menu),
coord(18,32,23,42),
border(bright:green),
contents(green:white),
title(' dummy '),
menu([return,one,two,three,four,five,six])
]
),
window(wdummylog, create,
[coord(1,1,10,15)]
),
window(wlist1, create,
[type(display),
coord(2,2,23,50),
border(reverse:blue),
contents(reverse:blue),
title(' List One ')
]
),
window(wlist2, create,
[type(display),
coord(2,20,23,78),
border(yellow),
contents(blue:yellow),
title(' List Two ')
]
).
do('new numbers'):-
list1,
!.
do('add numbers'):-
list2,
!.
do('try prompt'):-
prompt,
!.
do('try dynamic'):-
```

240

<!-- page 251 -->
*Appendices - Full Source Code* *Windows — Windows Demonstration (windemo.pro)*

```prolog
pop,
!.
do('try form'):-
form,
!.
do(exit):-
exit.
do(_):-
dummy.
list1:-
window(wlist1,open),
ctr_set(0,1),
repeat,
ctr_inc(0,N),
window(wlist1, write, 'line number is ':N),
N >= 50,
window(wlist1, writelist,[nl]),
window(wlist1, writelist,
['You can use home, end, pgup, & pgdn',
'to examine the contents',
'use enter to leave the '-wlist1-' window'
]
),
window(x, driver),
window(wlist1, close),
!.
list2:-
window(wlist2, open),
window(wlist2, write, 'adding more numbers'),
ctr_set(2,1),
repeat,
ctr_inc(1,N),
ctr_inc(2,Test),
window(wlist2, write, 'adding number':N),
Test >= 10,
window(x, driver),
!.
exit:-
window(wexit, write, ['Good Bye']),
window(x, driver),
cls,
halt.
dummy:-
repeat,
window(wdummy, read, X),
ctr_inc(3,N),
window(wdummylog, write, [N:X]),
X == return,
window(wdummy, close),
!.
prompt:-
repeat,
window(wprompt, read, ['',X]),
window(wdummylog, write, [X]),
X == '',
window(wprompt, close),
!.
```

<!-- page 252 -->
*Building Expert Systems in Prolog* *Windows — Windows Demonstration (windemo.pro)*

```prolog
pop:-
window([type(prompt),
coord(23,2,23,10),
title(' pop '),
contents(white:blue)
],
read, ['',X]
),
window(wdummylog, write, [X]),
window([type(menu),
coord(20,2,21,5),
contents(white:magenta),
menu([yes,no])
],
read, Y
),
window(wdummylog, write, [Y]),
!.
form:-
window(wform, read, _),
recorded(wform,var(Vname,_,_,Val),_),
window(wdummylog, write, [Vname=Val]),
window(wform2, read, _),
window(wform2, erase),
fail.
form.
```

242

<!-- page 253 -->
*Appendices - Full Source Code*

```prolog
% WINDOWS.PRO - Windowing predicates, written for an old version
% of Arity Prolog.  While not operational at this time, they do
% illustrate the power of Prolog for systems type work.
:- module windows.
:- segment(ijseg2).
:- public window/2, window/3.
:- public showcurse/0, hidecurse/0.
:- default(invisible).
:- extrn curtype/2:asm.    % sets the cursor, can be replaced with:
showcurse:-
curtype(7,8).
hidecurse:-
curtype(39,40).
%***********************************************************
%
% window/3 is the main predicate.  The windowing system is organized
% at the top in an object oriented fashon.  The window/3 arguments are:
%    arg1 - operation (message)
%    arg2 - window (the object)
%    arg3 - parameters (input or output - either a singleton or a list
% The objects can be one of four types of window -
%    display, menu, form, prompt
%
%***********************************************************
:- mode window(+,+).
window(W, Op):-
window(W, Op, []).
:- mode window(+,+,?).
window([H|T], Op, Args):-
window(temp_w, create, [H|T]),
window(temp_w, Op, Args),
window(temp_w, delete),
!.
window(W, Op, Args):-
get_type(W, T),
find_proc(T, Op, Proc),
doproc(Proc, W, Args),
!.
% get_type/2 figures out what type of window we have
:- mode get_type(+,-).
get_type(W, X):-
select_parm(W, [type(X)]),
!.
get_type(W, window).  % W is currently undefined
```

<!-- page 254 -->
*Building Expert Systems in Prolog* *Windows — Windows (windows.pro)*

```prolog
% find_proc/3 finds the appropriate procedure for the message
% and window type
:- mode find_proc(+,+,-).
find_proc(T, Op, Proc):-
find_p(T, Op, Proc),
!.
find_proc(T, Op, Proc):-
error([Op, 'is illegal operation for a window of type', T]).
find_p(T, Op, Proc):-
method(T, Op, Proc),
!.
find_p(T, Op, Proc):-
subclass(Super, T),
!,
find_p(Super, Op, Proc).
% table of objects
:- mode subclass(+,?).
subclass(window, display).
subclass(window, menu).
subclass(window, form).
subclass(window, prompt).
% table of procedures to use for various operations and types
:- mode method(+,+,-).
method(window, open, open_w).
method(window, close, close_w).
method(window, create, create_w).
method(window, change, change_w).
method(window, driver, driver_w).
method(window, display, display_w).
method(window, delete, delete_w).
method(window, erase, erase_w).
method(display, write, write_d).
method(display, writelist, writelist_d).
method(display, writeline, writeline_d).
method(menu, read, read_m).
method(form, read, read_f).
method(form, display, nop).
method(prompt, read, read_p).
% doproc - a faster way to do a call.
:- mode doproc(+,+,+).
doproc(create_w,W,A):-
!,
create_w(W,A).
doproc(open_w,W,A):-
!,
open_w(W,A).
doproc(close_w,W,A):-
!,
close_w(W,A).
doproc(delete_w,W,A):-
```

244

<!-- page 255 -->
*Appendices - Full Source Code* *Windows — Windows (windows.pro)*

```prolog
!,
delete_w(W,A).
doproc(display_w,W,A):-
!,
display_w(W,A).
doproc(erase_w,W,A):-
!,
erase_w(W,A).
doproc(change_w,W,A):-
!,
change_w(W,A).
doproc(write_d,W,A):-
!,
write_d(W,A).
doproc(writelist_d,W,A):-
!,
writelist_d(W,A).
doproc(writeline_d,W,A):-
!,
writeline_d(W,A).
doproc(read_m,W,A):-
!,
read_m(W,A).
doproc(read_f,W,A):-
!,
read_f(W,A).
doproc(read_p,W,A):-
!,
read_p(W,A).
doproc(driver_w,W,A):-
!,
driver_w(W,A).
doproc(nop,_,_):- !.
doproc(X,W,A):-
error(['No window method ',X,' defined.']).
%******************************************************************
%
% methods for the super class "window".  these are used by default
% if they are not redefined for the subclass.
%
%     create_w - create new window from specs
%     open_w  - open a window for use
%     close_w - remove the window contents and viewport
%     change_w - changes a windows definition
%     display_w - display a portion of contents in window
%     driver_w - gives control to user to view other windows
%
%******************************************************************
%------------------------------------------------------------------
%
% create_w/2 records a new window definition
%
%------------------------------------------------------------------
:- mode create_w(+,?).
create_w(W,L):-
make_window(W,L),
!.
%------------------------------------------------------------------
%
% open_w/1 calls make_viewport which opens up a viewport for the window
%
```

<!-- page 256 -->
*Building Expert Systems in Prolog* *Windows — Windows (windows.pro)*

```prolog
%------------------------------------------------------------------
:- mode open_w(+,?).
open_w(W,[]):-
exists_window(W),
make_viewport(W),
!.
%------------------------------------------------------------------
%
% close_w/1 closes a viewport on the active list
%
%------------------------------------------------------------------
:- mode close_w(+,?).
close_w(W,[]):-
del_viewport(W),
!.
%------------------------------------------------------------------
%
% delete_w removes both viewport and dataarea
%
%------------------------------------------------------------------
:- mode delete_w(+,?).
delete_w(W,[]):-
del_viewport(W),
del_dataarea(W),
del_stat(W),
del_image(W),
del_window(W),
!.
%------------------------------------------------------------------
%
% erase_w removes the viewport and dataarea, but preserves
% window definition
%
%------------------------------------------------------------------
:- mode erase_w(+,?).
erase_w(W,_):-
del_viewport(W),
del_dataarea(W),
del_stat(W),
del_image(W),
!.
%------------------------------------------------------------------
%
% change_w/2 changes a windows position on the viewport
%
%------------------------------------------------------------------
:- mode change_w(+,?).
change_w(W,L):-
recorded_w(windef,wd(W,Lold),_),
merge_wl(L,Lold,Lnew),
```

246

<!-- page 257 -->
*Appendices - Full Source Code* *Windows — Windows (windows.pro)*

```prolog
w_clrb(W),
recorded_w(active,AL,_),
remove(W,AL,NL),
redraw(NL,W),
recorded_w(active,AL,DBRef), erase(DBRef),
recorda(active,NL,_),
window(W,create,Lnew),
window(W,open),
!.
merge_wl([],Lnew,Lnew):- !.
merge_wl([Hn|Tn], Lold, Lnew):-
rep_we(Hn, Lold, Temp),
!,
merge_wl(Tn, Temp, Lnew).
rep_we(X,[],[X]):- !.
rep_we(X, [H|T], [X|T]):-
functor(X,F,A),
functor(H,F,A),
!.
rep_we(X,[H|T],[H|T2]):-
!,
rep_we(X,T,T2).
%------------------------------------------------------------------
%
% display_w writes a page of a window from a given starting point
%
%------------------------------------------------------------------
:- mode display_w(+,?).
display_w(W, [_, 0]):- !.
display_w(W, [Line, NN]):-          % add NN lines to the top
NN < 0,
N is -NN,
select_parm(W, [coord(R1, C1, R2, C2)]),
RLL is R1 + N - 1,
(RLL =< R2,
RL = RLL;
RL = R2
),
display_viewport(W, Line, R1, RL, C1),
!.
display_w(W, [Line, NN]):-  % add NN lines to the bottom
NN > 0,                   % note Line is line number at top of window
select_parm(W, [coord(R1, C1, R2, C2)]),
RFF is R2 - NN + 1,
(RFF =< R1,
RF = R1;
RF = RFF
),
Offset is RF - R1,         % if first line to be displayed
Lineoff is Line + Offset,  % is mid viewport somewhere
display_viewport(W, Lineoff, RF, R2, C1),
!.
display_w(W, Line):-
select_parm(W, [coord(R1, C1, R2, C2)]),
display_viewport(W, Line, R1, R2, C1),
!.
%------------------------------------------------------------------
%
```

<!-- page 258 -->
*Building Expert Systems in Prolog* *Windows — Windows (windows.pro)*

```prolog
% driver_w turns control over to the user for manipulating the
% current window.
%
%------------------------------------------------------------------
driver_w(_,_):-
repeat,
recorded_w(active,[W|_],_),
select_parm(W,[coord(R1,C1,_,_)]),
tmove(R1,C1),
keyb(A,S),
w_exec(S,Flag,W),
Flag == end,
!.
:- mode w_exec(+,-,+).
w_exec(71,xxx,W):-         % home
scroll_window(W,top),
!.
w_exec(79,xxx,W):-         % end
scroll_window(W,bottom),
!.
w_exec(81,xxx,W):-         % pgdn
select_parm(W,[height(H)]),
HH is H - 1,
scroll_window(W,HH),
!.
w_exec(73,xxx,W):-         % pgup
select_parm(W,[height(H)]),
HH is - H + 1,
scroll_window(W,HH),
!.
w_exec(72,xxx,W):-         % up arrow
scroll_window(W,-1),
!.
w_exec(80,xxx,W):-         % down arrow
scroll_window(W,1),
!.
w_exec(59,xxx,W):-         % f1 change windows
recorded_w(active,List,_),
last_item(List,NewW),
window(NewW,open),
!.
w_exec(28,end,_):- !.      % enter - leave the driver
w_exec(_,xxx,_):- !.
%******************************************************************
%
% methods for subclass display
%
%     write_d - write to the window
%     writelist_d - write a list of terms to the window
%
%******************************************************************
%------------------------------------------------------------------
%
% write_d
% write to the window.  The term can be a simple term, or a list of terms
% which make up a line.  See w_wlin for other allowed contructs.
%
%------------------------------------------------------------------
:- mode write_d(+,?).
```

248

<!-- page 259 -->
*Appendices - Full Source Code* *Windows — Windows (windows.pro)*

```prolog
write_d(W, Term):-
scroll_window(W, bottom),
select_stat(W,curnum,L1,NL),
select_parm(W, [coord(R1,C1,R2,C2), attr(CC)]),
Row is NL - L1 + 1 + R1,
add_data(W, Term),
write_viewport(W, Term, CC, L1, NL, Row, R2, C1, C2),
!.
%------------------------------------------------------------------
%
% writelist_d
% write multiple lines to the window, using write_d
%
%------------------------------------------------------------------
:- mode writelist_d(+,?).
writelist_d(W, []):-!.
writelist_d(W, [H|T]):-
w_writ(W,H),
!,
writelist_d(W,T).
w_writ(W,nl):-
write_d(W,'').
w_writ(W,H):-
write_d(W,H).
%------------------------------------------------------------------
%
% writeline_d
% write a list of terms on a line, without the list format
%
%------------------------------------------------------------------
:- mode writeline_d(+,?).
writeline_d(W, L):-
make_line(L, $$, S),
write_d(W, S),
!.
make_line([], S, S).
make_line([H|T], Temp, S):-
string_term(HS, H),
concat(Temp, HS, Temp2),
make_line(T, Temp2, S).
%******************************************************************
%
% methods for subclass menu
%
%     read_m - read a term from the menu
%
%******************************************************************
%------------------------------------------------------------------
%
% read_m
% w_menu - returns a menu choice from a menu window, the window may
% be dynamically built, using the first clause
%
```

<!-- page 260 -->
*Building Expert Systems in Prolog* *Windows — Windows (windows.pro)*

```prolog
%------------------------------------------------------------------
:- mode read_m(+,?).
read_m(W,X):-
init_menu_dataarea(W),
window(W,open),
menu_select(W,X),
!.
%  (string_term(X,XX); atom_string(XX,X)), !.
%******************************************************************
%
% methods for subclass form
%
%     read_f - read the fields in the form
%
%******************************************************************
%------------------------------------------------------------------
%
% read_f - updates the contents of the form window
%
%------------------------------------------------------------------
:- mode read_f(+,?).
read_f(W,[]):-
init_form_dataarea(W),
window(W,open),
clear_viewport(W),
display_form(W),
select_parm(W,[coord(_,C1,R2,_)]),
RR is R2 + 1,
tmove(RR,C1),
write(' F9 to enter '),
fill_form(W),
read_form(W),
!.
%******************************************************************
%
% methods for subclass prompt
%
%******************************************************************
%------------------------------------------------------------------
%
% read_p read the prompt
%
%------------------------------------------------------------------
:- mode read_p(+,?).
read_p(W,X):-
var(X),
window(W,open),
fill_prompt(W,Z),
!,
Z = X.
read_p(W,X):-
atomic(X),
window(W,open),
fill_prompt(W,Z),
!,
Z == X.               % ok if X an atom and Z a string
```

250

<!-- page 261 -->
*Appendices - Full Source Code* *Windows — Windows (windows.pro)*

```prolog
read_p(W,[Def,X]):-
write_d(W,Def),
fill_prompt(W,Z),
!,
Z = X.
%******************************************************************
%
%  Basic window data manipulation routines - a window is composed
%  of a viewport and dataarea
%
%******************************************************************
%------------------------------------------------------------------
%
% make a new window
%
%------------------------------------------------------------------
:- mode make_window(+,?).
make_window(W, Def):-
(recorded_w(windef,wd(W,_),DBRef),
erase(DBRef);
true
),
recorda(windef,wd(W,Def),_),
!.
%------------------------------------------------------------------
%
% del_window removes a window definition
%
%------------------------------------------------------------------
:- mode del_window(+).
del_window(W):-
recorded_w(windef,wd(W,_),DBRef),
erase(DBRef),
!.
del_window(_).
%------------------------------------------------------------------
%
% exists window checks for existence of a window definition
%
%------------------------------------------------------------------
:- mode exists_window(+).
exists_window(W):-
recorded_w(windef,wd(W,_),_),
!.
exists_window(W):-
error(['No window definition for ',W]),
fail.
%------------------------------------------------------------------
%
% select_parm extracts various parameters from a window definition.
% The RequestList is a list of structures with keyword functors
% and variable arguments, which are bound by w_attr.  w_attr
% also contains the defaults and computed parameters (ie height)
```

<!-- page 262 -->
*Building Expert Systems in Prolog* *Windows — Windows (windows.pro)*

```prolog
%
%------------------------------------------------------------------
:- mode select_parm(+,+).
select_parm(W,RequestList):-
recorded_w(windef,wd(W,AttrList),_),
fullfill(RequestList, AttrList),
!.
:- mode fullfill(+,+).
fullfill([],_):- !.
fullfill([Req|T], AttrList):-
w_attr(Req, AttrList),
!,
fullfill(T, AttrList).
:- mode w_attr(+,+).
w_attr(height(H), AttrList):-
w_attr(coord(R1,_,R2,_),AttrList),
H is R2 - R1 + 1,
!.
w_attr(width(W), AttrList):-
w_attr(coord(_,C1,_,C2),AttrList),
W is C2 - C1 + 1,
!.
w_attr(attr(A), AttrList):-
w_attr(contents(Color),AttrList),
attr(Color,A),
!.
w_attr(border_attr(A), AttrList):-
w_attr(border(Color),AttrList),
attr(Color,A),
!.
w_attr(A, AttrList):-
member(A, AttrList),
!.
w_attr(coord(1,1,23,78),_).        % default values
w_attr(title(''),_).
w_attr(border(white),_).
w_attr(contents(white),_).
w_attr(type(display),_).
%------------------------------------------------------------------
%
% update_parm provides the facility to update and window parameters.
%
%------------------------------------------------------------------
:- mode update_parm(+,?).
update_parm(W,UpdateList):-
recorded_w(windef,wd(W,AttrList),DBRef), erase(DBRef),
modify(UpdateList, AttrList, NewList),
recorda(windef,wd(W,NewList),_),
!.
modify([],L,L):-!.
modify([Req|T], AttrList, NewList):-
functor(Req,F,A),
mod(F, Req, AttrList, [], NewL),
!,
```

252

<!-- page 263 -->
*Appendices - Full Source Code* *Windows — Windows (windows.pro)*

```prolog
modify(T, NewL, NewList).
mod(_,_,[],L,L).
mod(F,A,[OldA|AL],Temp,NewL):-
functor(OldA,F,_),
append([A|Temp],AL,NewL),
!.
mod(F,A,[OldA|AL],Temp,NewL):-
mod(F,A,AL,[OldA|Temp],NewL).
%------------------------------------------------------------------
%
% select_stat is used to get the status of a window
%
%------------------------------------------------------------------
:- mode select_stat(+,+,?).
select_stat(W,curline,L):-
recorded_w(curline,cl(W,L,_),_),
!.
select_stat(W,numlines,N):-
recorded_w(curline,cl(W,_,N),_).
:- mode select_stat(+,+,?,?).
select_stat(W,curnum,L,N):-
recorded_w(curline,cl(W,L,N),_).
%------------------------------------------------------------------
%
% update_stat is used to change the active status of a window
%
%------------------------------------------------------------------
:- mode update_stat(+,+,?).
update_stat(W,curline,L):-
(recorded_w(curline,cl(W,_,NL),DBRef),
erase(DBRef);
NL = 0
),
!,
recorda(curline,cl(W,L,NL),_).
update_stat(W,numlines,N):-
(recorded_w(curline,cl(W,L,_),DBRef),
erase(DBRef);
L = 1
),
!,
recorda(curline,cl(W,L,N),_).
:- mode update_stat(+,+,?,?).
update_stat(W,curnum,L,N):-
(recorded_w(curline,cl(W,_,_),DBRef),
erase(DBRef);
true
),
!,
recorda(curline,cl(W,L,N),_).
```

<!-- page 264 -->
*Building Expert Systems in Prolog* *Windows — Windows (windows.pro)*

```prolog
%------------------------------------------------------------------
%
% del_stat removes the windows status information
%
%------------------------------------------------------------------
:- mode del_stat(+).
del_stat(W):-
recorded_w(curline,cl(W,_,_),DBRef),
erase(DBRef),
!.
del_stat(_).
%------------------------------------------------------------------
%
% select_content will repeatedly give the next record from
%     a given starting point, and its position
%
%------------------------------------------------------------------
:- mode select_content(+,?,?,?).
select_content(W,Start,Count,X):-
ctr_set(20,0),
recorded_w(W,X,_),
ctr_inc(20,Count),
Count >= Start.
%------------------------------------------------------------------
%
% add to a windows data area
%
%------------------------------------------------------------------
:- mode add_data(+,?).
add_data(W, Term):-
(string(Term),
S = Term;
string_term(S,Term)
),
recordz(W, S, _),
!.
%------------------------------------------------------------------
%
% make_viewport initializes a viewport.  If it is already the head of the
% active list, do nothing.  If it is not on the active list, get it
% and put it on.  Otherwise move it to the head from where it is now.
%
%------------------------------------------------------------------
:- mode make_viewport(+).
make_viewport(W):-                   % If its on the top, clear the decks
recorded_w(active,[W|T],_),
del_image(W),
!.
make_viewport(W):-                   % make sure active and curline exist
w_inact(W),                        %      and go to next clause
w_nocur(W),
fail.
make_viewport(W):-                   % If its on the list somewhere
recorded_w(active,[H|T],_),
```

254

<!-- page 265 -->
*Appendices - Full Source Code* *Windows — Windows (windows.pro)*

```prolog
save_image(H),
split(W,[H|T],L1,L2),
w_chkover(W,L1,_),
append([W|L1], L2, NL),
recorded_w(active,_,DBRef), erase(DBRef),
recorda(active,NL,_),
!.
make_viewport(W):-
recorded_w(active,L,DBRef), erase(DBRef),
recorda(active,[W|L],_),
w_ini(W),
!.
make_viewport(W):-
error(['Initializing viewport',W]).
w_inact(W):-
recorded_w(active,_,_),
!.
w_inact(W):-
recorda(active,[],_).
w_nocur(W):-
select_stat(W, curnum, _, _),
!.
w_nocur(W):-
update_stat(W, curnum, 1, 0).
w_ini(W):-
w_box(W),
clear_viewport(W),
window(W,display,1),             % display from line 1
set_arrows(W),
!.
w_chkover(W, [], no).
w_chkover(W, [H|T], Stat):-
w_nooverlap(W,H),
w_chkover(W,T,Stat).
w_chkover(W,_,yes):-
restore_image(W),
!.
:- mode w_nooverlap(+,+).
w_nooverlap(Wa,Wb):-
select_parm(Wa, [coord(R1a,C1a,R2a,C2a)]),
select_parm(Wb, [coord(R1b,C1b,R2b,C2b)]),
(R1a > R2b + 2;
R2a < R1b - 2;
C1a > C2b + 2;
C2a < C1b - 2
),
!.
%------------------------------------------------------------------
%
% save the screen image
%
%------------------------------------------------------------------
:- mode save_image(+).
```

<!-- page 266 -->
*Building Expert Systems in Prolog* *Windows — Windows (windows.pro)*

```prolog
save_image(W):-
del_image(W),
select_parm(W,[coord(R1,C1,R2,C2)]),
RR1 is R1 - 1, CC1 is C1 - 1,
RR2 is R2 + 1, CC2 is C2 + 1,
region_ca((RR1,CC1),(RR2,CC2),SA),
recorda(image,W-SA,_),
!.
%------------------------------------------------------------------
%
% restore the screen image
%
%------------------------------------------------------------------
:- mode restore_image(+).
restore_image(W):-
select_parm(W,[coord(R1,C1,R2,C2)]),
RR1 is R1 - 1, CC1 is C1 - 1,
RR2 is R2 + 1, CC2 is C2 + 1,
recorded_w(image,W-SA,Ref),
region_ca((RR1,CC1),(RR2,CC2),SA),
!.
%------------------------------------------------------------------
%
% delete an image
%
%------------------------------------------------------------------
:- mode del_image(+).
del_image(W):-
recorded_w(image,W-_,R),
erase(R),
!.
del_image(W).
%------------------------------------------------------------------
%
% del_dataarea removes the contents of the window
%
%------------------------------------------------------------------
:- mode del_dataarea(+).
del_dataarea(W):-
eraseall(W),
update_stat(W,curnum,1,0),
!.
%------------------------------------------------------------------
%
% clear_viewport clears the screen
%
%------------------------------------------------------------------
:- mode clear_viewport(+).
clear_viewport(W):-
select_parm(W,[coord(R1,C1,R2,C2),attr(A)]),
tmove(R2,C1),
wca(1,` ,A),
```

256

<!-- page 267 -->
*Appendices - Full Source Code* *Windows — Windows (windows.pro)*

```prolog
tscroll(0,(R1,C1),(R2,C2)),
!.
clear_viewport(_).
%------------------------------------------------------------------
%
% del_viewport removes a viewport updating active lists and overlays
%
%------------------------------------------------------------------
:- mode del_viewport(+).
del_viewport(W):-
recorded_w(active,AList,_),
member(W,AList),                  %fail and go away if nothing to delete
AList = [H|_],
(W == H; save_image(H)),          % in case closing a window other
w_clrb(W),                        % than the uppermost
remove(W,AList,Newl),
del_image(W),
redraw(Newl,W),
recorded_w(active,AList,DBRef), erase(DBRef),
recorda(active,Newl,_),
!.
del_viewport(_).                 % always succeed
redraw(Newl,W):-                   % from back to front, redraw
reverse(Newl,Backwards),         % affected windows
redr(Backwards,W,[]),
!.
redr([],_,_):- !.
redr([H|T], W, Redrawn):-
w_nooverlap(H,W),
w_chkover(H,Redrawn,Stat),
(Stat == yes,
Red = [H|Redrawn];
Red = Redrawn
),
!,
redr(T,W,Red).
redr([H|T], W, Redrawn):-
restore_image(H),
!,
redr(T, W, [H|Redrawn]).
% remove the window from the viewport
:- mode w_clrb(+).
w_clrb(W):-
select_parm(W, [coord(R1, C1, R2, C2)]),
RR1 is R1 - 1, CC1 is C1 - 1,
RR2 is R2 + 1, CC2 is C2 + 1,
tmove(RR2,CC1),wca(1,` ,7),
tscroll(0, (RR1, CC1), (RR2, CC2)),
!.
w_clrb(W):- !.
%------------------------------------------------------------------
%
% writes a term to the specified line in the viewport
%
%------------------------------------------------------------------
```

<!-- page 268 -->
*Building Expert Systems in Prolog* *Windows — Windows (windows.pro)*

```prolog
:- mode write_viewport(+,+,+,+,+,+,+,+,+).
write_viewport(W, Term, CC, L1, NL, Row, R2, C1, C2):-
(Row =< R2,
R = Row,
L2 is L1,
!;
scroll_viewport(W, 1),
L2 is L1 + 1, R = R2
),
Width is C2 - C1 + 1,
(string(Term),
S = Term;
string_term(S,Term)
),
w_wline(S, R, C1, CC, Width),
NNL is NL + 1,
update_stat(W,curnum,L2,NNL),
!.
:- mode w_wline(+,+,+,+,+).
w_wline(Term, R, C1, CC, Width):-
tmove(R,C1),
wa(Width,CC),
(string_length(Term,L),
L =< Width,
Term = S;
substring(Term,0,Width,S)
),
write(S).
%------------------------------------------------------------------
%
% display_viewport writes lines from R1 to R2 starting at line L
% from the dataarea to the viewport
%
%------------------------------------------------------------------
:- mode display_viewport(+,+,+,+,+).
display_viewport(W,Line,R1,R2,C1):-
key(W,Key),
nth_ref(W,Line,Ref),
select_parm(W,[width(Wid), attr(A)]),
RL is R2 + 1,
w_disp(Ref, Key, R1, RL, C1, A, Wid),
!.
display_viewport(_,_,_,_,_).             % succeed if no key yet
:- mode w_disp(+,+,+,+,+,+,+).
w_disp(Ref, Ref, _, _, _, _, _):- !.
w_disp(_, _, Row, Row, _, _, _):- !.
w_disp(Ref, Sref, Row, RL, C1, CC, Width):-
instance(Ref, Term),
w_wline(Term, Row, C1, CC, Width),
Row2 is Row + 1,
nref(Ref, Nref),
!,
w_disp(Nref, Sref, Row2, RL, C1, CC, Width).
%------------------------------------------------------------------
```

258

<!-- page 269 -->
*Appendices - Full Source Code* *Windows — Windows (windows.pro)*

```prolog
%
% the box, only one choice, double line
%
%------------------------------------------------------------------
:- mode w_box(+).
w_box(W):-
select_parm(W, [coord(R1, C1, R2, C2), title(T), border(C)]),
box(R1, C1, R2, C2, C),
Rt is R1 - 1,
Ct is C1 + 3,
tmove(Rt,Ct),
write(T),
!.
:- mode box(+,+,+,+,+).
box(R1, C1, R2, C2, C):-
R0 is R1 - 1,
C0 is C1 - 1,
R3 is R2 + 1,
C3 is C2 + 1,
Width is C2 - C1 + 1,
Height is R2 - R1 + 1,
attr(C,CC),
left_side(R1, C0, CC, R2),
top(R0, C0, C1, C3, Width, CC),
right_side(R1, C3, CC, R2),
bottom(R3, C0, C1, C3, Width, CC),
!.
:- mode left_side(+,+,+,+).
left_side(R1, C0, CC, R2):-
w_vert(R1, C0, 186, CC, R2).
:- mode top(+,+,+,+,+,+).
top(R0, C0, C1, C3, Width, CC):-
tmove(R0, C0),
wca(1, 201, CC),
tmove(R0, C1),
wca(Width, 205, CC),
tmove(R0, C3),
wca(1, 187, CC).
:- mode right_side(+,+,+,+).
right_side(R1, C3, CC, R2):-
w_vert(R1, C3, 186, CC, R2).
:- mode bottom(+,+,+,+,+,+).
bottom(R3, C0, C1, C3, Width, CC):-
tmove(R3, C0),
wca(1,200,CC),
tmove(R3, C1),
wca(Width, 205, CC),
tmove(R3,C3),
wca(1, 188, CC).
```

<!-- page 270 -->
*Building Expert Systems in Prolog* *Windows — Windows (windows.pro)*

```prolog
:- mode w_vert(+,+,+,+,+).
w_vert(R1, C1, Char, Color, R2):-
ctr_set(0,R1),
repeat,
ctr_inc(0,R),
tmove(R, C1),
wca(1, Char, Color),
R >= R2,
!.
%------------------------------------------------------------------
%
% scroll the viewport
%
%------------------------------------------------------------------
:- mode scroll_viewport(+,?).
scroll_viewport(W, N):-
select_parm(W, [coord(R1, C1, R2, C2)]),
Height is R2 - R1 + 1,
Heightm is -Height,
(N > Heightm,
N < Height,
NN = N;
NN = 0
),
tscroll(NN, (R1,C1), (R2,C2)).
%------------------------------------------------------------------
%
% scroll the window
%
%------------------------------------------------------------------
:- mode scroll_window(+,+).
scroll_window(W, top):-
window(W,open),
select_stat(W,curline,1),         % already at the top
set_arrows(W),
!.
scroll_window(W, top):-
select_stat(W,curline,L),
S is 1 - L,
scroll_window(W,S),
!.
scroll_window(W, bottom):-
window(W,open),
select_parm(W, [coord(R1, C1, R2, C2)]),
Height is R2 - R1 + 1,
select_stat(W, curnum, L, NL),
NL < L + Height,  % already at the bottom
set_arrows(W),
!.
scroll_window(W, bottom):-
select_parm(W, [coord(R1, C1, R2, C2)]),
Height is R2 - R1 + 1,
select_stat(W, curnum, L, NL),
Last is L + Height,
S is NL + 1 - Last,
scroll_window(W, S),
!.
scroll_window(W, N):-
window(W,open),
```

260

<!-- page 271 -->
*Appendices - Full Source Code* *Windows — Windows (windows.pro)*

```prolog
select_stat(W, curnum, Line, NL),
select_parm(W,[height(H)]),
H < NL,                 % if it fits on one frame, no scroll
MaxLine is NL - H + 1,  % biggest line # allowed at first row
Newline is Line + N,
real_nl(in(Line,MaxLine,Newline,N), out(Newl,NN)),
set_arrow(W,MaxLine,Newl),
update_stat(W, curnum, Newl, NL),
scroll_viewport(W, NN),
window(W, display, [Newl, NN]),
!.
scroll_window(_,_).
%------------------------------------------------------------------
%
% set_arrows puts the little arrows at the top and bottom indicating
% that there is more to be seen.
%
%------------------------------------------------------------------
:- mode set_arrows(+).
set_arrows(W):-
select_stat(W, curnum, Line, NL),
select_parm(W, [height(H)]),
Max is NL - H + 1,
set_arrow(W, Max, Line),
!.
set_arrow(W,Max,New):-
select_parm(W, [coord(R1,C1,R2,C2)]),
RR1 is R1 - 1,
RR2 is R2 + 1,
setar(Max,New,up(RR1:C1),down(RR2:C1)),
!.
setar(_, 1, up(R:C), _):-
tmove(R,C),
put(`Í),
fail.
setar(Max, Max, _, down(R:C)):-
tmove(R,C),
put(`Í),
fail.
setar(_, New, up(R:C), _):-
New > 1,
tmove(R,C),
put(`),
fail.
setar(Max, New, _, down(R:C)):-
New < Max,
tmove(R,C),
put(`),
fail.
setar(_,_,_,_).
real_nl(in(Line,MaxLine,Newline,N), out(Newline,N)):-
Newline > 0,
Newline =< MaxLine,
!.
real_nl(in(Line,MaxLine,Newline,N), out(1,NN)):-
Newline =< 0,
Newline =< MaxLine,
NN is 1 - Line,
Line =\= 1,  % fail if already at first line
```

<!-- page 272 -->
*Building Expert Systems in Prolog* *Windows — Windows (windows.pro)*

```prolog
!.
real_nl(in(Line,MaxLine,Newline,N), out(MaxLine,NN)):-
Newline > 0,
Newline > MaxLine,
NN is MaxLine - Line,
Line =\= MaxLine,  % fail if already at last line
!.
%------------------------------------------------------------------
%
% predicates to define and read maps, aka forms.
% they expect an initial definition of the map fields
% in a window spec as follows:
%
%      form([lit(Row:Col,Literal),
%            var(FieldName,Row:Col,Length,InitValue),
%            ...])
%
% This is converted to window records of the form
%
%      recordz(W,lit(..),_). etc
%
% It is sometimes easier for the application to build this directly.
%
%------------------------------------------------------------------
%------------------------------------------------------------------
%
% copy the window definition specs to the dataarea
%
%------------------------------------------------------------------
:- mode init_form_dataarea(+).
init_form_dataarea(F):-
recorded_w(F,_,_),
!.
init_form_dataarea(F):-
select_parm(F,[form(List)]),
init_map(F,List),
!.
:- mode init_map(+,?).
init_map(W,[]):-!.
init_map(W,[H|T]):-
recordz(W,H,_),
!, init_map(W, T).
%------------------------------------------------------------------
%
% put the form data on the viewport
%
%------------------------------------------------------------------
:- mode display_form(+).
display_form(S):-
select_parm(S,[coord(R0,C0,_,_),attr(At)]),
recorded_w(S,Field,_),
write_field(R0:C0,At,Field),
fail.
display_form(S):-true.
write_field(R0:C0, At, lit(R:C,Lit)):-
```

262

<!-- page 273 -->
*Appendices - Full Source Code* *Windows — Windows (windows.pro)*

```prolog
RR is R0 + R, CC is C0 + C,
tmove(RR,CC),
write(Lit),
!.
write_field(R0:C0, At, var(_,R:C,Length,Val)):-
rev_attr(At, Rat),
RR is R0 + R, CC is C0 + C,
tmove(RR,CC),
wa(Length,Rat),
write(Val),
!.
%------------------------------------------------------------------
%
% read the data from the viewport and store in the dataarea
%
%------------------------------------------------------------------
:- mode read_form(+).
read_form(S):-
select_parm(S,[coord(R0,C0,_,_)]),
recorded_w(S,var(Name,R:C,Length,_),Ref),
RR is R0 + R, CC is C0 + C,
C2 is CC + Length - 1,
region_c((RR,CC),(RR,C2),Str),
strcnv(Str,Val),
replace(Ref,var(Name,R:C,Length,Val)),
fail.
read_form(S).
strcnv(S,V):-
strip_leading(S,S1),
strip_trailing(S1,V),
!.
%------------------------------------------------------------------
%
% capture keystrokes and drive form data entry
%
%------------------------------------------------------------------
:- mode fill_form(+).
fill_form(S):-
build_field_list(S),
recorded_w(field_list,S-[R:C:C2|T],_),
tmove(R,C),
set_flag(current_field,R:C:C2),
get_keystrokes(S,[R:C:C2|T]).
build_field_list(S):-
(recorded_w(field_list,S-L,Ref),erase(Ref); true),
recorda(field_list,S-[],_),
bfl(S),
!.
bfl(S):-
select_parm(S,[coord(R0,C0,_,_)]),
recorded_w(S,var(_,R:C,Length,_),_),
RR is R0 + R, CC is C0 + C,
C2 is CC + Length - 1,
add_field(S,RR:CC:C2),
```

<!-- page 274 -->
*Building Expert Systems in Prolog* *Windows — Windows (windows.pro)*

```prolog
fail.
bfl(S):-
recorded_w(field_list,S-L,Ref),  % If there is only one, make
length(L,N), N == 1,             % a dummy second one so next_item
append(L,L,L2),                  % has something to find
erase(Ref),
recorda(field_list,S-L,Ref),
!.
bfl(_).
add_field(S,F):-
recorded_w(field_list,S-L,Ref),
append(L,[F],L2),
erase(Ref),
recorda(field_list,S-L2,_),
!.
get_keystrokes(W,List):-
select_parm(W,[attr(At)]),
rev_attr(At, Rat),
repeat,
get_flag(current_field,F),
keyb(A,S),
put_viewport(A:S,F,List,Rat),
!.  % user ended input
put_viewport(A:67, F, FList, Rat).   % f9
put_viewport(A:77, F, FList, Rat):-  % rt arrow
curse_inc(F, FList),
!,
fail.
put_viewport(A:75, F, FList, Rat):-  % left arrow
curse_dec(F, FList),
!,
fail.
put_viewport(A:72, F, FList, Rat):-  % up arrow
prev_item(F, FList, R:C:C2),
set_flag(current_field, R:C:C2),
tmove(R,C),
!,
fail.
put_viewport(A:80, F, FList, Rat):-  % down arrow
next_item(F, FList, R:C:C2),
set_flag(current_field, R:C:C2),
tmove(R,C),
!,
fail.
put_viewport(A:28, F, FList, Rat):-  % enter
next_item(F, FList, R:C:C2),
set_flag(current_field, R:C:C2),
tmove(R,C),
!,
fail.
put_viewport(A:14, F, FList, Rat):-  % back space
curse_dec(F, FList),
wca(1, ` , Rat),
!,
fail.
put_viewport(A:_,  F, FList, Rat):-  % letter
wca(1, A, Rat),
curse_inc(F, FList),
!,
fail.
```

264

<!-- page 275 -->
*Appendices - Full Source Code* *Windows — Windows (windows.pro)*

```prolog
curse_inc(Rx:Cx:C2x, FList):-
tget(R,C),
C < C2x,
CC is C + 1,
tmove(R,CC),
!.
curse_inc(F, FList):-
next_item(F, FList, R:C:C2),
set_flag(current_field, R:C:C2),
tmove(R,C),
!.
curse_dec(Rx:Cx:C2x, FList):-
tget(R,C),
C > Cx,
CC is C - 1,
tmove(R,CC),
!.
curse_dec(F, FList):-
prev_item(F, FList, R:C:C2),
set_flag(current_field, R:C:C2),
tmove(R,C),
!.
%------------------------------------------------------------------
%
% write the menu dataarea from the window definition
%
%------------------------------------------------------------------
:- mode init_menu_dataarea(+).
init_menu_dataarea(W):-
recorded_w(W,_,_),
!.
init_menu_dataarea(W):-
m_init(W).
m_init(W):-
select_parm(W,[menu(ItemList)]),
m_create(W,ItemList,Nitems,0),
update_stat(W,curnum,1,Nitems),
!.
m_create(_,[],Nitems,Nitems):- !.
m_create(W,[Item|Rest],Nitems,X):-
add_data(W,Item),
XX is X + 1,
!,
m_create(W,Rest,Nitems,XX).
%------------------------------------------------------------------
%
% select an item from the menu
%
%------------------------------------------------------------------
:- mode menu_select(+,?).
menu_select(W,X):-
select_parm(W,[coord(R1,C1,R2,_),
width(L),
attr(A)]),
```

<!-- page 276 -->
*Building Expert Systems in Prolog* *Windows — Windows (windows.pro)*

```prolog
tmove(R1,C1),
revideo(L,A),
repeat,
keyb(_,S),
m_cur(S,Z,w(W,R1,R2,C1,L,A)),  % will fail until Z has a value
!,
Z = X.                           % might fail if X had a value
:- mode m_cur(+,-,+).
m_cur(80,_,w(W,R1,R2,C1,L,A)):-  % down arrow
tget(R,_),
R < R2,
normvideo(L,A),
RR is R + 1,
tmove(RR,C1),
revideo(L,A),
!,
fail.
m_cur(80,_,w(W,R1,R2,C1,L,A)):-  % down arrow at bottom
tget(R,_),
R >= R2,
normvideo(L,A),
scroll_window(W,1),
tmove(R2,C1),
revideo(L,A),
!,
fail.
m_cur(72,_,w(W,R1,R2,C1,L,A)):-  % up arrow
tget(R,_),
R > R1,
normvideo(L,A),
RR is R - 1,
tmove(RR,C1),
revideo(L,A),
!,
fail.
m_cur(72,_,w(W,R1,R2,C1,L,A)):-  % up arrow at top
tget(R,_),
R =< R1,
normvideo(L,A),
scroll_window(W,-1),
tmove(R1,C1),
revideo(L,A),
!,
fail.
m_cur(71,_,w(W,R1,R2,C1,L,A)):-  % home
normvideo(L,A),
scroll_window(W,top),
tmove(R1,C1),
revideo(L,A),
!,
fail.
m_cur(79,_,w(W,R1,R2,C1,L,A)):-  % end
normvideo(L,A),
scroll_window(W,bottom),
tmove(R2,C1),
revideo(L,A),
!,
fail.
m_cur(28,X,w(W,R1,R2,C1,L,A)):-  % enter
tget(R,_),
select_stat(W,curline,Line),
Nth is Line + R - R1,
nth_ref(W, Nth, Ref),
instance(Ref,X),
normvideo(L,A),
```

266

<!-- page 277 -->
*Appendices - Full Source Code* *Windows — Windows (windows.pro)*

```prolog
!.
revideo(L,A):-
rev_attr(A,RevAt),
wa(L,RevAt).
normvideo(L,A):-
wa(L,A).
%------------------------------------------------------------------
%
% read the prompt
%
%------------------------------------------------------------------
:- mode fill_prompt(+,?).
fill_prompt(W,Z):-
select_parm(W,[coord(R1,C1,_,_), width(L), contents(Color)]),
attr(Color,At),
repeat,
C2 is C1 + L - 1,
tmove(R1,C1),
lined(Y,R1:C1:C2,At),
strip_leading(Y,Y1),
strip_trailing(Y1,X),
!,
Z = X.  % might fail if checking X value
% lined - a line editor, returns a string
% :- mode lined(?,+,+).
lined(NewS,R:C1:C2,At):-
L is C2 - C1 + 1,
tmove(R,C1),
wa(L,At),
repeat,
keyb(A,S),
modify(A:S,R:C1:C2,EndFlag,At),
EndFlag == end,
region_c((R,C1),(R,C2),NewS),
!.
%:- mode modify(+,+,?,+).
modify(_:28,R:C1:C2,end,At):- !.        % CR - end edit
modify(_:1,R:C1:C2,x,At):-              % Esc - erase line
tscroll(0,(R,C1),(R,C2)),
tmove(R,C1),
!.
modify(_:77,R:C1:C2,x,At):-             % cursor right
tget(R,C),
(C < C2,
CC is C + 1;
CC = C2
),
tmove(R,CC),
!.
modify(_:75,R:C1:C2,x,At):-             % cursor left
tget(R,C),
(C > C1,
CC is C - 1;
```

<!-- page 278 -->
*Building Expert Systems in Prolog* *Windows — Windows (windows.pro)*

```prolog
CC = C1
),
tmove(R,CC),
!.
modify(_:83,R:C1:C2,x,At):-             % Del - delete character
tget(R,C),
C < C2,
CC is C + 1,
hidecurse,
region_ca((R,CC),(R,C2),S),
list_text([32,At],LastChar),
concat(S,LastChar,St),
region_ca((R,C),(R,C2),St),
tmove(R,C),
showcurse,
!.
modify(_:83,R:C1:C2,x,At):-             % Del - last space
wca(1,` ,At),
!.
modify(_:14,R:C1:C2,x,At):-             % BS - move everything to the left
tget(R,C),
C > C1,
CC is C - 1,
hidecurse,
region_ca((R,C),(R,C2),S),
list_text([32,At],LastChar),
concat(S,LastChar,St),
region_ca((R,CC),(R,C2),St),
tmove(R,CC),
showcurse,
!.
modify(_:14,_,_,_):- !.                 % BS - first space
modify(A:_,R:C1:C2,x,At):-              % any other character, insert
tget(R,C),
C < C2, CC is C + 1,
hidecurse,
C2a is C2 - 1,
region_ca((R,C),(R,C2a),S),
tmove(R,C),
wca(1,A,At),
region_ca((R,CC),(R,C2),S),
tmove(R,CC),
showcurse,
!.
modify(A:_ ,_,_,At):-                    % last space
wca(1,A,At).
%------------------------------------------------------------------
%
% debug dumps all the current window data
%
%------------------------------------------------------------------
debug:-
write('window dump'), nl,
debug_active,
debug_windefs,
!.
debug_active:-
recorded_w(active,L,_),
write(active:L), nl,
!.
debug_active:-
write('no active list'), nl.
```

268

<!-- page 279 -->
*Appendices - Full Source Code* *Windows — Windows (windows.pro)*

```prolog
debug_windefs:-
recorded_w(windef,wd(W,A),_),
write(W:A), nl,
debug_curline(W),
debug_data(W),
fail.
debug_windefs:-
write('no more windefs'), nl.
debug_curline(W):-
recorded_w(curline,cl(W,Line,Num),_),
write(W:curline:Line:Num), nl,
!.
debug_curline(W):-
write('no curline for':W), nl.
debug_data(W):-
recorded_w(W,X,_),
write(W:'first record':X), nl,
!.
debug_data(W):-
write('no data for':W), nl.
%******************************************************************
%
%     Utilities
%
%******************************************************************
% recorded_w_w - a rewrite of recorded_w for a far Prolog routine.
:- mode recorded_w_w(+,?,-).
recorded_w(K,T,R):-
key(K,Kref),
nref(Kref,Nref),
rec_w(Kref,Nref,R,T).
:- mode rec_w(+,+,-,?).
rec_w(K,K,_,_):-
!,
fail.
rec_w(K,R,R,T):-
instance(R,T).
rec_w(K,R,Ro,T):-
nref(R,Rn),
rec_w(K,Rn,Ro,T).
append([], X, X).
append([H|T], L, [H|Newt]):-
append(T, L, Newt).
member(X, [X | Y]):- !.
member(X, [Y | Z]):-
member(X, Z).
split(Item, List, Front, Back):-
append(Front, [Item|Back], List),
!.
```

<!-- page 280 -->
*Building Expert Systems in Prolog* *Windows — Windows (windows.pro)*

```prolog
remove(Item,List,NewList):-
split(Item,List,Front,Back),
append(Front,Back,NewList),
!.
reverse(Forwards, Backwards):-
rev(Forwards, [], Backwards),
!.
rev([], B, B):- !.
rev([H|T], X, B):-
rev(T, [H|X], B).
attr(black,0).
attr(blue,1).
attr(green,2).
attr(cyan,3).
attr(red,4).
attr(magenta,5).
attr(yellow,6).
attr(white,7).
attr(S:Fg:Bg, A):-
attr(S:Fg, Af),
attr(reverse:Bg, Ab),
A is Af \/ Ab,
!.
attr(bright:X,N):-
attr(X,A),
N is A \/ 8,!.
attr(reverse:X,N):-
attr(X,A),
rev_attr(A,N),
!.
attr(Fg:Bg, A):-
attr(Fg, Af),
attr(reverse:Bg, Ab),
A is Af \/ Ab,
!.
rev_attr(At, Rat):-
BG is (At /\ 7) << 4,
FG is (At /\ 112) >> 4,
A is At /\ 136,
Rat is A \/ BG \/ FG.
% strip leading & trailing take the leading and trailing blanks
% off a string.  The final test is due to the unforgiveable nature
% of list_text to return either strings or atoms at its will
%
strip_leading(Si,So):-
string_length(Si,Li),
ctr_set(0,0),
repeat,
ctr_inc(0,Pos),
(Pos >= Li,
atom_string('',So)
;
nth_char(Pos,Si,Char),
Char \== 32,
Lo is Li - Pos,
```

270

<!-- page 281 -->
*Appendices - Full Source Code* *Windows — Windows (windows.pro)*

```prolog
substring(Si,Pos,Lo,So)
),
!.
strip_trailing(Si,So):-
string_length(Si,Li),
Last is Li - 1,
ctr_set(0,Last),
repeat,
ctr_dec(0,Pos),
(Pos < 0, atom_string('',So)
;
nth_char(Pos,Si,Char),
Char \== 32,
Lo is Pos + 1,
substring(Si,0,Lo,So)
),
!.
% flag setting predicates
get_flag(F,Val):-
recorded_w(flag,F:Val,_).
set_flag(F,Val):-
recorded_w(flag,F:_,Ref),
replace(Ref,F:Val),
!.
set_flag(F,Val):-
recorda(flag,F:Val,_).
% wraps circularly around list
next_item(Item, List, NextItem):-
split(Item, List, Front, Back),
(first_item(Back,
NextItem)
;
first_item(Front, NextItem)
),
!.
prev_item(Item, List, PrevItem):-
split(Item, List, Front, Back),
(last_item(Front, PrevItem)
;
last_item(Back, PrevItem)
),
!.
first_item([First|_],First):-
true.
last_item([Last],Last):- !.
last_item([H|T],Last):-
last_item(T,Last).
error(List):-
tget(R,C),
tscroll(0,(24,0),(24,79)),
```

<!-- page 282 -->
*Building Expert Systems in Prolog* *Windows — Windows (windows.pro)*

```prolog
tmove(24,0),
write('*** Window Error *** '),
err(List),
tmove(R,C),
!.
err([]).
err([H|T]):-
write(H),
tab(1),
err(T).
```

272

<!-- page 283 -->
*Appendices - Full Source Code* G Rubik

### Cube Solver (rubik.pro)

```prolog
% RUBIK.PRO
% CUBE SOLVER II
%   A Rubik's Cube Solver
%   written by Dennis Merritt
%   as described in Building Expert Systems in Prolog (Springer-Verlag)
%   available from:
%     Amzi! inc.
%     40 Samuel Prescott Dr.
%     Stow, MA 01775 USA
%     Tel 508/897-7332, FAX 508/897-2784
%     e-mail amzi@world.std.com
%
%  This program may be copied, modified and redistributed although proper
%  acknowledgement is appreciated.
%
%  This implementation was done with Cogent Prolog, also available
%  from Amzi! inc.
%
%  This is the main module which contains the predicates for
%         the main control loop,
%         manual mode,
%         solve mode, and
%         utility functions.
%
% Note - The Cogent/Prolog compiler supports modules.  The export declarations
%        are for predicates defined in the current module which may be used
%        by other modules.  The import declarations are for predicates
%        defined in other modules.
:-export main/0.
:-export append/3.
:-export get_flag/2.
:-export set_flag/2.
:-export error/1.
:-export reverse/2.
:-import add_history/1.     % rubhist
:-import cnd/2.             % rubdata
:-import cube_print/1.      % rubdisp
:-import get_color/1.       % rubedit
:-import pristine/1.        % rubdata
:-import rub_help/0.        % rubhelp
:-import m_disp/1.          % rubdisp
:-import m_choose/2.        % rubdisp
:-import move/3.            % rubmov
:-import orientation/2.     % rubdata
:-import pln/2.             % rubdata
:-import rdfield/2.         % rubdisp
:-import rdchar/2.          % rubdisp
:-import redit/1.           % rubedit
:-import rewrite/2.         % rubedit
:-import rot/3.             % rubmov
:-import seq/2.             % rubdata
:-import side_color/1.      % rubdata
:-import s_r/2.             % rubdata
:-import vw/2.              % rubdata
:-import wrfield/2.         % rubdisp
:-import writec/2.          % rubdisp
```

<!-- page 284 -->
*Building Expert Systems in Prolog* *Rubik — Cube Solver (rubik.pro)*

```prolog
:-import logfile/1.     % dynamic db
:-import impplan/1.        % dynamic db
:-import state/1.          % dynamic db
:-import crit/1.           % dynamic db
:-import ghoul/1.          % dynamic db
:-import sidecolor/1.      % dynamic db
:-import flag/2.        % dynamic db
:-import cand/1.        % dynamic db
:-import candmove/1.      % dynamic db
:-op(500,xfy,:).
main :-  % The start up entry point
banner,
go.
go:-  % The main control loop
repeat,
init_color,
m_disp(main),      % The main menu
m_choose(main,X),  % Select an item
do(X),             % Execute it
X == exit.           % Go back to the repeat or end
% These are the predicates which are called for the various
% main menu choices.  The cut after each ensures they wont be
% backtracked into when the main loop fails.
do(solve):-  % in this module
solve,
!.
do(manual):-  % in this module
manual,
!.
do(help):-  % in rubhelp
rub_help,
!.
do(exit). % built-in predicate to exit
banner:-
nl, nl,
write($Cube Solver II$), nl,
write($An illustrative Prolog program from$), nl,
write($Building Expert Systems in Prolog (Springer-Verlag) by Dennis
Merritt$), nl,
write($implemented in Cogent Prolog$), nl, nl,
write($For more information contact:$), nl,
write($Amzi! inc.$), nl,
write($40 Samuel Prescott Dr.$), nl,
write($Stow, MA 01775 USA$), nl,
write($Tel 508/897-7332, FAX 508/897-2784$), nl,
write($e-mail amzi@world.std.com$), nl, nl.
% These predicates initialize the state to the goal state (ghoul),
% and allow you to enter single moves.  They are intended to demonstrate the
% effects of the various sequences used by the solve routines.
% They are also called by the solve routine if manual scrambling
% is requested
manual:-
pristine(G),          % Start with the goal state
retractif(state(_)),
```

274

<!-- page 285 -->
*Appendices - Full Source Code* *Rubik — Cube Solver (rubik.pro)*

```prolog
assert(state(G)),
cube_print(G),        % Display it
disp_moves,           % List the possible moves
repeat,               % Start repeat-fail loop
rdfield(move,M),      % Get a move
(M == q,              % If '', clear and end
nl,
!
;
state(S),
man_move(M,S,S2),    % Apply move to it
retract(state(_)),
assert(state(S2)),
cube_print(S2),
fail                 % Print it and fail back
).
man_move(M,S,S2):-
movel(M,S,S2),
!.
man_move(M,S,S2):-      % Pop a + in front of an unsigned move
movel(+M,S,S2),
!.
man_move(M,_,_):-
error('Unknown move'-M),
!,
fail.
disp_moves:-            % List the three types of moves
wrfield(moves,''),    % Heading
move(X,_,_),          % Will backtrack through all moves
write(X),tab(1),      % Write move
fail.                 % Go back for the next one
disp_moves:-
nl,
wrfield(rotations,''),  % No more moves, do the same for rots
rot(X,_,_),
write(X),tab(1),
fail.
disp_moves:-            % And again for seqs
nl,
wrfield(sequences,''),
seq(X,_),
write(X),tab(1),
fail.
disp_moves:-            % Got em all, end
nl,
wrfield(end_disp,'').
% This is the main body of the program, which actually solves the cube.
% See rubdoc1 and rubdoc2 for the big picture
solve:-
m_disp(solve),  % solve submenu
m_choose(solve,X),
rdchar(stepmode,SM),
(SM == `y´,  % check for a y (scan code 21)
set_flag(stepmode,on)
;
set_flag(stepmode,off)
),
solve(X).  % call solve w/ arity one with menu choice
solve(X):-
```

<!-- page 286 -->
*Building Expert Systems in Prolog* *Rubik — Cube Solver (rubik.pro)*

```prolog
init_solve(X),  % initialize all the stuff
T1 is cputime,
stages,
T is cputime - T1,
state(S),
cube_print(S),
write($Done  time = $),
write(T), nl, nl.
solve(X):-
error('failing to solve'),
halt.  % something wrong, back to main
init_solve(X):-
wrfield(prob,X),
initialize(X),  % getting closer to the real work
!.
initialize(X):-
pristine(G),
retractall(ghoul(_)),
assert(ghoul(G)),
init_crit(Crit),  % set up the initial criteria (all variables
retractall(crit(_)),
assert(crit(Crit)),
retractall(stage(_)),
assert(stage(1)),  % the first stage will call the others
!,
initial(X).  % get specific start state in the database
initial(random):-  % create a new random cube
random_cube(Cube),
retractall(state(_)),
assert(state(Cube)),
!.
initial(edit):-  % edit your own
redit(Cube),
retractall(state(_)),
assert(state(Cube)),
new_colors(Cube),
!.
initial(manual):-  % scramble your own
manual,
state(Cube),
new_colors(Cube),
!.
stages:-
repeat,
retract(stage(N)),
init_stage(N,Plan),  % Set the stage, get the plan
state(S),
cube_print(S),
build_plan(Plan),
improve(N,Plan),  % Put the pieces in the plan in place
vw(N,V),  % undo the stage view (done by init_stage)
undo_view(V),
N2 is N + 1,  % next stage
assert(stage(N2)),
N2 >= 7.
build_plan([]) :- !.
build_plan([H|T]) :-
assert(impplan(H)),
```

276

<!-- page 287 -->
*Appendices - Full Source Code* *Rubik — Cube Solver (rubik.pro)*

```prolog
build_plan(T).
% init_stage goes to rubdata to get the table entries which define
% the heuristics for the stage
init_stage(N,Plan):-  % return list of target pieces for this stage
wrfield(stage,N),
cnd(N,Cands),  % set up candidate moves used by search
build_cand(Cands),
vw(N,V),  % set up preferred view for stage
set_view(V),
pln(N,Plan),  % get list of target pieces
!.
% improve - works through the list of target pieces for the stage.
%           it first checks to see if its already in place
improve(Stage,[]) :- !.
improve(Stage,[Piece|Rest]) :-
impro(Stage,Piece),
!,
improve(Stage,Rest).
improve(Stage):-
impplan(Piece),
impro(Stage,Piece).
impro(Stage,Piece) :-
add_criteria(Piece,Crit),  % Add new piece to criteria
target_loc(Piece,Pos,Orient),  % Where is it
impr(Orient,Stage,Pos,Piece),
!.
impr(0,_,_,_) :- !.  % In place and oriented
impr(_,Stage,Pos,Piece) :-
imp(Stage,Pos,Piece).
% imp - getting into the real work
imp(Stage,Pos,Piece):-
color_piece(PieceC,Piece),  % translate side notation to
wrfield(target,PieceC),     %   color notation for display
heuristics(Stage,Pos),  % See if special help is needed.
orientation(Piece, View),   % Preferred view for this piece.
set_view(View),
crit(Crit),
state(State),
cntr_set(4,0),  % to limit wild searches
%  gc(7),
rotate(Moves,State,Crit),  % Search for moves which transform
retract(state(_)),
assert(state(Crit)),
wrfield(rot,Moves),
add_history(Moves),
undo_view(View),
!.
heuristics(Stage,Pos):-
(shift_right_1(Stage,Pos)
;
shift_right_2(Stage,Pos)
```

<!-- page 288 -->
*Building Expert Systems in Prolog* *Rubik — Cube Solver (rubik.pro)*

```prolog
),
!.
heuristics(_,_):-
true.
% The shift_right heuristics are used to avoid the situations where
% the piece is in one of the target positions for the stage, but the
% wrong one, or mis-oriented.  By blindly moving it to the right the
% search is reduced since it doesn't have to search to move it both
% out of a critical target position and back into the correct one.
shift_right_1(1,Pos):-
smember('L',Pos),  % Is the target piece already on the left?
s_r(Pos,Moves),    % If so get the canned moves to move it
change(Moves),     % right for easy search.
!.
shift_right_2(Stage,Pos):-
Stage < 4,            % If the target piece is not on the right
notsmember('R',Pos),  % side, get the canned moves to put it
s_r(Pos,Moves),       % there to allow easier search
change(Moves),
!.
% rotate - the real guts of the solution, all the rest of the code provides
%          support for these six lines.
% These lines illustrate the power and obscurity of Prolog.
% Prolog can be very expressive when the main information is carried
% in the predicate.  However, sometimes the work is being done by
% unification, and it is not at all apparent by reading the code.
% Furthermore, since Prolog predicates often work backwards and
% forwards, it is not clear in a given case what is intended to be
% be input, and what is the output, and, as in this case, what might
% be an in-out.
% The input and output states of rotate are:
% Input: Moves - unbound
%        State - bound to the cube structure for the current state
%        Crit  - partially bound cube structure.  the bound portions
%                represent the pieces in place + the current goal piece
% Output: Moves - a list of moves
%         State - same as input
%         Crit  - fully bound to the new state
% rotate does a breadth first search by recursively calling itself
% before it calls get_move which trys new moves.  it does not save the
% search trees as most breadth first algorithms do, but rather recalculates
% the moves since they can be executed so fast.
% get_move fails when called with the partially bound Crit, unless
% it is a move which reaches the desired state.  The failure causes
% backtracking.  However when rotate calls itself, it gives it a
% fully unbound variable NextState.  This call to rotate succeeds and
% keeps adding new moves generated by get_move on backtracking.
% eventually get_move finds a match and rotate succeeds.
rotate([], State, State).  % start with a no move
rotate(Moves, State, Crit):-  % nothing didn't work, get serious
rotate(PriorMoves, State, NextState), % get something to build on
%  cntr_inc(4,N4),
%  check_prog(N4),
```

278

<!-- page 289 -->
*Appendices - Full Source Code* *Rubik — Cube Solver (rubik.pro)*

```prolog
get_move(ThisMove, NextState, Crit),  % generate possible moves
append(PriorMoves, [ThisMove], Moves).  % build up the list
check_prog(N) :-
N < 250,
!.
check_prog(_) :-
error('not converging'),
halt.
% The following predicates all perform various useful services
% for the main predicates above.  Some are declared export as well
% and are used by other modules
% add_criteria puts a new piece on the criteria structure.  it works
% by creating two piece format lists, one of the goal state, and the
% other of the current criteria.  It then walks through the two lists
% simultaneously looking for the target piece in the goal state.
% when it finds it it adds it to the criteria.  Crit is unbound on entry
add_criteria(Piece,Crit):-
crit(OldCrit),
pieces(OldCrit, OldCritP),
ghoul(Ghoul),
pieces(Ghoul, GhoulP),
add_crit(OldCritP, GhoulP, NewCritP, Piece),
pieces(Crit, NewCritP),
retract(crit(_)),
assert(crit(Crit)),
!.
add_crit([V1|V2], [V3|V4], [V3|V2], V5):-
matches(V3, V5),
!.
add_crit([V1|V2], [V3|V4], [V1|V5], V6):-
!,
add_crit(V2, V4, V5, V6).
add_crit(V1, V2, V3, V4):-
error('something wrong with add_crit'),
!.
% The center tiles dont move on the cube.  Sooo if someone enters a cube
% with different color sides then we must find the new center tiles
% and map the new colors to the sides accordingly
new_colors(Cube):-
rewrite(ColorCube,Cube),
get_color(ColorCube),
rewrite(ColorCube,NewCube),
retract(state(_)),
assert(state(NewCube)).
% Set up the initial mapping of sides to colors
init_color:-
side_color(SC),
retractall(sidecolor(_)),
ini_col(SC).
ini_col([]):- !.
ini_col([S-C|T]):-
assert(sidecolor(S-C)),
```

<!-- page 290 -->
*Building Expert Systems in Prolog* *Rubik — Cube Solver (rubik.pro)*

```prolog
ini_col(T).
% translate a piece in piece notation to color notation
color_piece(PieceC,Piece):-
Piece=..[p|Args],
col_p(ArgsC,Args),
PieceC=..[p|ArgsC].
col_p([],[]):- !.
col_p([PC|RestC],[P|Rest]):-
sidecolor(P-PC),
col_p(RestC,Rest).
% execute about 50 or 60 random rotations to the goal cube.  due to the
% random function, the random cubes will be the same from run to
% run.  It always starts from the same seed.
random_cube(Cube):-
ghoul(Start),
rand_cub(Start,Cube,50).
rand_cub(Cube,Cube,0).
rand_cub(Now,Cube,N):-
repeat,
rand_move(M,RN),
movel(M,Now,Next),
NN is N - 1,
!,
rand_cub(Next,Cube,NN).
rand_move(M,RN):-
RN is integer(random*12),
arg(RN,m(+f,+b,+r,+l,+u,+d,-f,-b,-r,-l,-u,-d),M).
% the classic
member(V1, [V1|V2]):- !.
member(V1, [V2|V3]):-
member(V1, V3).
% display a list of terms without the list notation
write_list([]):-
true.
write_list([H|T]):-
write(H),tab(1),
write_list(T).
% target_loc finds the location of a given piece on the cube.  it can
% also be used to find the piece at a given location.  it returns the
% orientation as well, which is 0 if in place, or 1 if in place but
% twisted
target_loc(Piece, Pos, Orient):-
ghoul(Gt),
pieces(Gt, G),
state(St),
pieces(St, S),
find_piece(G, S, Pos, Piece, Orient),
```

280

<!-- page 291 -->
*Appendices - Full Source Code* *Rubik — Cube Solver (rubik.pro)*

```prolog
!.
target_loc(Piece, _,_):-
error('Failing to find piece'-Piece),
fail.
% find_piece does the work for target_loc, walking two lists simultaneously
% looking for either the piece or the position, whichever is bound.
find_piece([Gh|Gt], [Sh|St], Pos, Piece, Orient):-
matches(Pos, Gh),
matches(Piece, Sh),
comp(Gh,Sh,Orient),
!.
find_piece([V1|V2], [V3|V4], V5, V6, Orient):-
!,
find_piece(V2, V4, V5, V6, Orient).
matches(V1, V2):-
comp(V1, V2, V3),
V3 < 2,
!.
% comp returns 0 if direct hit, 1 if in place but twisted, and
% 2 if no match
comp(p(V1), p(V1), 0):- !.
comp(p(V1, V2), p(V1, V2), 0):- !.
comp(p(V1, V2), p(V2, V1), 1):- !.
comp(p(V1, V2, V3), p(V1, V2, V3), 0):- !.
comp(p(V1, V2, V3), p(V1, V3, V2), 1):- !.
comp(p(V1, V2, V3), p(V2, V1, V3), 1):- !.
comp(p(V1, V2, V3), p(V2, V3, V1), 1):- !.
comp(p(V1, V2, V3), p(V3, V1, V2), 1):- !.
comp(p(V1, V2, V3), p(V3, V2, V1), 1):- !.
comp(V1, V2, 2).
% allows easy handling of database entries used as flags
set_flag(Flag,Val):-
retract(flag(Flag,_)),
assert(flag(Flag,Val)),
!.
set_flag(Flag,Val):-
assert(flag(Flag,Val)).
get_flag(Flag,Val):-
flag(Flag,Val).
% get_move is used by rotate to generate moves.  the possible moves
% are stored in the database under the key cand.  backtracking causes
% successive moves to be tried
get_move(+V1, V2, V3):-
cand(V1),
movep(V1, V2, V3).
get_move(-V1, V2, V3):-
cand(V1),
movep(V1, V3, V2).
% build_cand creates the database of possible moves for a given stage.
% this is one of the important heuristics for limiting the search
```

<!-- page 292 -->
*Building Expert Systems in Prolog* *Rubik — Cube Solver (rubik.pro)*

```prolog
build_cand(V1):-
retractall(cand(_)),
retractall(candmove(_)),
build_cands(V1),
!.
build_cands([]):- !.
build_cands([V1|V2]):-
can_seq(V1),
assertz(cand(V1)),
!,
build_cands(V2).
can_seq(M):-         % if the search move is a sequence
seq(M,S),          % precompute it, so it isn't constantly
variable(X),       % redone during search.
move_list(S,X,Y),
assertz(candmove(m(M,X,Y))),
!.
can_seq(_).
% another classic
append([], V1, V1).
append([V1|V2], V3, [V1|V4]):-
append(V2, V3, V4).
% apply a list of moves to a state
move_list([], V1, V1):- !.
move_list([Move|V3], V4, V5):-
movel(Move, V4, V6),
!,
move_list(V3, V6, V5).
% movel is the basic move predicate called from everywhere
movel(+M, V2, V3):-  % distinguish between clockwise
movep(M, V2, V3),
!.
movel(-M, V2, V3):-  % and counter clockwise moves
movep(M, V3, V2),
!.
% find the move, be it a simple move, a rotation, or a sequence.
% if its a sequence break it into its simple componenents
movep(M, X, Y):-
move(M, X, V3),
!,
Y = V3.
movep(M, X, Y):-
rot(M, X, V3),
!,
Y = V3.
movep(M, X, Y):-
candmove(m(M,X,V3)),
!,
Y = V3.
movep(V1, V2, V3):-
seq(V1, V4),
```

282

<!-- page 293 -->
*Appendices - Full Source Code* *Rubik — Cube Solver (rubik.pro)*

```prolog
!,
move_list(V4, V2, V3),
!.
movep([V1|V2], V3, V4):-
move_list([V1|V2], V3, V4),
!.
% same as move_list, only print new state when done
move_listp(V1, V2, V3):-
move_list(V1, V2, V3),
wrfield(rot,V1).
% change is move_list for keeps.
% it takes the old value changes it, updates it,
% and records the history.  it is called by the heuristic routines
change(ML):-
retract(state(Old)),
move_listp(ML,Old,New),
add_history(ML),
assert(state(New)),
!.
% establish a new view.  this means not just rotating the cube, but also
% rotating the criteria and the goal structures.  this is necessary so
% any predicates working with any of the three winds up comparing
% apples and apples.
set_view([]):- !.
set_view(V):-
retract(state(S1)),
move_list(V, S1, S2),
assert(state(S2)),
retract(ghoul(G1)),
move_list(V, G1, G2),
assert(ghoul(G2)),
retract(crit(C1)),
move_list(V, C1, C2),
assert(crit(C2)),
wrfield(rot,V),
add_history(V),
!.
undo_view([]):- !.
undo_view(RV):-
reverse(RV,V),
set_view(V),
!.
% convert a cube structure to a list of pieces and visa versa
pieces(cube(X1, X2, X3, X4, X5, X6,
V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17,
V18, V19, V20, V21, V22, V23, V24, V25, V26, V27,
V28, V29, V30, V31, V32, V33, V34, V35, V36, V37,
V38, V39, V40, V41, V42, V43, V44, V45, V46, V47,
V48, V49, V50, V51, V52, V53, V54
),
[p(X1), p(X2), p(X3), p(X4), p(X5), p(X6),
p(V7, V8, V9), p(V10, V11, V12), p(V13, V14, V15),
p(V16, V17, V18),   p(V19, V20, V21), p(V22, V23, V24),
p(V25, V26, V27), p(V28, V29, V30), p(V31, V32),
```

<!-- page 294 -->
*Building Expert Systems in Prolog* *Rubik — Cube Solver (rubik.pro)*

```prolog
p(V33, V34), p(V35, V36), p(V37, V38), p(V39, V40),
p(V41, V42), p(V43, V44), p(V45, V46), p(V47, V48),
p(V49, V50), p(V51, V52), p(V53, V54)
]
).
% get an unbound cube
variable(cube(X1, X2, X3, X4, X5, X6,
V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17,
V18, V19, V20, V21, V22, V23, V24, V25, V26, V27,
V28, V29, V30, V31, V32, V33, V34, V35, V36, V37,
V38, V39, V40, V41, V42, V43, V44, V45, V46, V47,
V48, V49, V50, V51, V52, V53, V54
)
).
% the initial criteria, unbound except for the six center tiles
init_crit(cube('F', 'R', 'U', 'B', 'L', 'D',
V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17,
V18, V19, V20, V21, V22, V23, V24, V25, V26, V27,
V28, V29, V30, V31, V32, V33, V34, V35, V36, V37,
V38, V39, V40, V41, V42, V43, V44, V45, V46, V47,
V48, V49, V50, V51, V52, V53, V54
)
).
notsmember(X,Y):-
smember(X,Y),
!,
fail.
notsmember(X,Y):-
true.
% like the classic, but works on a structure instead
smember(X,Y):-
Y=..[Fun|Args],
member(X,Args).
% display errors
error(X):-
wrfield(error,X), nl,
get1(_).
% reverse a list of moves, and flip the signs along the way
reverse(L, R) :-
rever(L, [], R).
rever([], Z, Z).
rever([H|T], X, Z) :-
flip_sign(H, FH),
rever(T, [FH|X], Z).
flip_sign(+ X, - X):- !.
flip_sign(- X, + X):- !.
```

284

<!-- page 295 -->
*Appendices - Full Source Code* *Rubik — Cube Solver (rubik.pro)*

```prolog
retractif(X) :-
retract(X),
!.
retractif(_).
```

<!-- page 296 -->
*Building Expert Systems in Prolog*

```prolog
% RUBDISP.PRO - Copyright (C) 1993, Amziod
% This file contains the display predicates.
:-export cube_print/1.
:-export wrfield/2, rdfield/2, rdchar/2.
:-export writec/2.
:-export color/1,color/2,color/3.
:-export m_disp/1,m_erase/1,m_choose/2.
:-import error/1.      % rubik
:-import get_flag/2.   % rubik
:-import sidecolor/1.  % dynamic database
:- op(500,xfy,:).
% cube_print - displays the full color cube. Both variables and
%              blanks appear as spaces.  unification is again used
%              to map the input cube to the individual displays
cube_print(cube(F, R, U, B, L, D,
V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17,
V18, V19, V20, V21, V22, V23, V24, V25, V26, V27,
V28, V29, V30, V31, V32, V33, V34, V35, V36, V37,
V38, V39, V40, V41, V42, V43, V44, V45, V46, V47,
V48, V49, V50, V51, V52, V53, V54
)
) :-
nl,
tab(6),  pc([V28, V45, V22]),
tab(6),  pc([V53, B, V51]),
tab(6),  pc([V25, V43, V19]),
pc([V29, V54, V26, V27, V44, V21, V20, V52, V23]),
pc([V37, L, V35, V36, U, V32, V31, R, V33]),
pc([V17, V50, V14, V15, V40, V9, V8, V48, V11]),
tab(6),  pc([V13, V39, V7]),
tab(6),  pc([V49, F, V47]),
tab(6),  pc([V16, V41, V10]),
tab(6),  pc([V18, V42, V12]),
tab(6),  pc([V38, D, V34]),
tab(6),  pc([V30, V46, V24]),
check_step,
!.
check_step :-
get_flag(stepmode, on),
write($Hit Enter to continue$),
get0(_).
check_step.
pc([]):-
nl.
pc([V1| V2]):-
sidecolor(V1 - C),
write(C),  tab(1),
%  write(V1),  tab(1),
pc(V2).
% wrfield & rdfield - allow input and output to a named field
```

286

<!-- page 297 -->
*Appendices - Full Source Code* *Rubik — Cube Display (rubdisp.pro)*

```prolog
wrfield(F,X):-
field(F,P),
write(P),
write(X),
nl.
rdfield(F,X):-
field(F,P),
write(P),
read(X).
rdchar(F,X):-
field(F,P),
write(P),
get(X).
% field - these are the field definitions for the cube program
field(prob, $Problem: $).
field(stage, $\nStage:   $).
field(target, $Target:  $).
field(rot, $Rotation: $).
field(try, $Trying: $).
field(prompt, $>$).
field(error, $Error: $).
field(done, $Done: $).
field(continue, $Hit Enter to continue.$).
field(stepmode, $Stepmode? (y/n): $).
field(history, $History? (y/n): $).
field(move, $Enter move\n(end with period, ex. u., -l., ct1., -tc3.) : $).
field(moves, $Moves: $).
field(rotations, $Rotations: $).
field(sequences, $Sequences: $).
field(end_disp, $Enter q. to end$).
field(msg20, $ $).
field(msg21, $ $).
m_disp(Menu):-
menu(Menu, Choices),
m_dis(1, Choices),
!.
m_dis(_, []) :-
nl.
m_dis(N, [H|T]) :-
write($[$),  write(N),  write($]$),
write(H),  tab(1),
NN is N + 1,
m_dis(NN, T).
m_choose(Menu,Choice):-
write($Choice: $),
get(Nascii),
N is Nascii - `0,
menu(Menu, Choices),
m_ch(N, Choices, Choice).
m_ch(N, [], _) :-
write($Bad menu choice, try again$),  nl,
fail.
m_ch(1, [X|_], X) :- !.
```

<!-- page 298 -->
*Building Expert Systems in Prolog* *Rubik — Cube Display (rubdisp.pro)*

```prolog
m_ch(N, [H|T], X) :-
NN is N - 1,
m_ch(NN, T, X).
menu(main, [solve, manual, help, exit]).
menu(solve, [random, manual, edit]).
```

288

<!-- page 299 -->
*Appendices - Full Source Code*

```prolog
% RUBEDIT.PRO - Copyright (C) 1994, Amzi! inc.
% This module allows the user to easily enter a scrambled
% cube position.  the cube is displayed in goal form.
% the cursor keys move from tile to tile, and the f1 key
% selects the color for the tile.  repeated hits of f1
% changes the color.  f1 was chosen since that allows a
% machine with a pcmouse to do cube editing with the mouse and
% and the left button (f1) with no special changes.
:-export redit/1.
:-export set_tcolor/1.
:-export get_color/1.
:-export rewrite/2.
:-import cube_print/1.  % rubdisp
:-import error/1.       % rubik
:-import ghoul/1.       % rubdata
:-import wrfield/2.     % rubdisp
:-import sidecolor/1.   % dynamic database
redit(Y):-
ghoul(G),
cube_print(G),
write($Enter single letters separated by spaces in the pattern$),  nl,
write($of the display.  The letters should represent the colors$),  nl,
write($on your cube.  Exact spacing isn't critical.$),  nl,
read_cube(X),     % read it off the screen
trans_cube(X,Y),  % change colors to side notation
cube_print(Y).
redit(_):-
error('failing edit'),
halt.
% read_cube - reads the edited cube directly from the screen, there was
% no need to save information about colors during the cursor movement
% stage ("edi").  it was for this reason that "change_color" writes the
% letter of the color in the tile.
% read_cube looks exactly like print_cube, only in reverse
read_cube(cube(F, R, U, B, L, D,
V7, V8, V9, V10, V11, V12, V13, V14, V15, V16,
V17, V18, V19, V20, V21, V22, V23, V24, V25, V26,
V27, V28, V29, V30, V31, V32, V33, V34, V35, V36,
V37, V38, V39, V40, V41, V42, V43, V44, V45, V46,
V47, V48, V49, V50, V51, V52, V53, V54
)
):-
rc([V28, V45, V22]),
rc([V53, B, V51]),
rc([V25, V43, V19]),
rc([V29, V54, V26, V27, V44, V21, V20, V52, V23]),
rc([V37, L, V35, V36, U, V32, V31, R, V33]),
rc([V17, V50, V14, V15, V40, V9, V8, V48, V11]),
rc([V13, V39, V7]),
rc([V49, F, V47]),
rc([V16, V41, V10]),
rc([V18, V42, V12]),
rc([V38, D, V34]),
rc([V30, V46, V24]),
!.
```

<!-- page 300 -->
*Building Expert Systems in Prolog* *Rubik — Cube Entry (rubedit.pro)*

```prolog
rc([]):- !.
rc([V1| V2]):-
get(X),
name(V1,[X]),
!,
rc(V2).
trans_cube(X,Y):-
get_color(X),  % establish new side colors
rewrite(X,Y).  % translate color notation to side notation
get_color(X):-
X=..[cube,F,R,U,B,L,D|_],  % the sides in color notation
set_tcolor(['F'-F,'R'-R,'U'-U,'B'-B,'L'-L,'D'-D]).
rewrite(C,S):-
var(S),                  % this one if color input and side output
C=..[cube|Clist],
rewrit(Clist,Slist),
S=..[cube|Slist],
!.
rewrite(C,S):-
var(C),               % this one if side input, and color out. It
S=..[cube|Slist],     % is called by the manual routine when building
rewrit(Clist,Slist),  % a cube to solve. Rotate moves might have been used
C=..[cube|Clist],     % which changed the side colors
!.
rewrit([],[]):- !.
rewrit([X|Ctail],[Y|Stail]):-
var(X),
var(Y),
!,
rewrit(Ctail,Stail).
rewrit([Color|Ctail],[Side|Stail]):-
sidecolor(Side-Color),
!,
rewrit(Ctail,Stail).
set_tcolor([]):- !.
set_tcolor([S-C|Tail]):-
retract(sidecolor(S-_)),
assert(sidecolor(S-C)),
!,
set_tcolor(Tail).
```

290

<!-- page 301 -->
*Appendices - Full Source Code*

```prolog
% RUBHIST.PRO - Copyright (C) 1994, Amzi! inc.
%  This module records history information so you can unscramble
%  a real cube by looking at the log file.
:-export add_history/1.
:-import append/3.      % rubik
:-import attr/2.        % rubdisp
:-import clr_bottom/0.  % rubik
:-import error/1.       % rubik
:-import bug/1.         % rubik
:-import get_flag/2.    % rubik
:-import reverse/2.     % rubik
:-import move/3.        % rubmove
:-import rot/3.         % rubmove
:-import seq/2.         % rubdata
:-import wrfield/2.     % rubdisp
% add_history takes a list of moves as input.  As output it sends
% the expanded version of the moves to the logfile.  That is, sequences
% are broken down into primitive moves before being written to the
% window
add_history(V1):-
expand(V1, V2),       % expand the list
de_list(V2,V3),       % remove inbedded lists (flatten the list)
segment_list(V3,V4),  % break into pieces that fit in window
write_hist(V4),
!.
add_history(X):-
error([add_history,X]).
write_hist([]).
write_hist([FirstLine|Rest]) :-
write('  Moves: '),
wr_hist(FirstLine),
nl,
write_hist(Rest).
wr_hist([]).
wr_hist([H|T]) :-
tab(2),
write(H),
wr_hist(T).
% expand pushes its way through a list of moves and sequences, making
% sequences into other move lists. It takes care to preserve the
% meaning of a counterclockwise sequence by reversing the list defining
% the sequence. This reverse also changes the sign of each term along
% the way. The first argument is the imput list, the second is output
expand([], []) :- !.
expand([Term|V3], [Term|V4]):-
moveterm(Term, X),  % strip the sign
(move(X,_,_)
;
rot(X,_,_)  % its a primitive
),
!,
```

<!-- page 302 -->
*Building Expert Systems in Prolog* *Rubik — Move History (rubhist.pro)*

```prolog
expand(V3, V4).
expand([Seq|V3], [Termlist|V5]):-
moveterm(Seq,S),  % we can guess its a sequence
seq(S, SL),
(signterm(Seq,-),
reverse(SL,Sterms)  % flip if necessary
;
Sterms = SL
),
expand(Sterms,Termlist),  % double recursion, on this sequence
!,
expand(V3, V5).           % ...and the rest of the list
expand(X,_):-
error(['expand fails on',X]).
% separate the move and sign of a term, first arg is input, second output
moveterm(+ X, X) :- !.
moveterm(- X, X) :- !.
signterm(+ X, +) :- !.
signterm(- X, -) :- !.
% "expand" left imbedded lists where sequences used to be, flatten them
% out since they arn't necessary
de_list([], []) :- !.
de_list(V1, [V1]):-
(V1 = +X
;
V1 = -X
).
de_list([V1|V2], V3):-
de_list(V1, V4),  % double recursion on the head and tail
de_list(V2, V5),
append(V4, V5, V3).
% having flattened it, segment_list breaks a long list into smaller
% lists that will fit in the display window. This is because the
% window routine is too lazy to deal with lines that are too long
segment_list([A,B,C,D,E|Tin],[[A,B,C,D,E]|Tout]):-
segment_list(Tin,Tout).
segment_list([],[]) :- !.
segment_list(L,[L]) :- !.
```

292

<!-- page 303 -->
*Appendices - Full Source Code*

```prolog
% RUBMOV.PRO - copyright (C) 1994, Amzi! inc.
% this file contains the definitions of all of the
% moves and rotations primitive to Rubik's Cube.
% Both moves and rotations are done using Prologs unification.
% The first argument is the name of the move or rotation, and the
% second and third arguments define transformations of the structure
% which represents the cube.
% By convention the moves are named by a single character which stands
% for the position of the side being turned.  Rotations are used to
% reposition the entire cube (leaving the pieces in the same relative
% positions).  They are named by the side which defines the axis
% of rotation, preceded by the letter r.
% (Why the funny variable names?  This program was originally written
%  in micro-Prolog (one of my favorites) with its parenthetical list
%  notation.  I then acquired Arity Prolog and wrote a translation
%  program converted the micro-Prolog syntax to Edinburgh syntax.
%  It did the dumb thing with variable names, and I've never bothered
%  to fix many of them, such as these.)
% The sides are: u up, d down, l left, r right, f front, b back.
:- export move/3,rot/3.
move(u,
cube(X1, X2, X3, X4, X5, X6, V7, V8, V9, V10, V11, V12,
V13, V14, V15, V16, V17, V18, V19, V20, V21, V22, V23,
V24, V25, V26, V27, V28, V29,
V30, V31, V32, V33, V34,
V35, V36, V37, V38, V39, V40, V41, V42, V43, V44, V45,
V46, V47, V48, V49, V50, V51, V52, V53, V54),
cube(X1, X2, X3, X4, X5, X6, V20, V19, V21, V10, V11,
V12, V8, V7, V9, V16, V17, V18, V26, V25, V27, V22,
V23, V24, V14, V13, V15, V28, V29, V30, V43, V44,
V33, V34, V39, V40, V37, V38, V31, V32, V41, V42,
V35, V36, V45, V46, V47, V48, V49, V50, V51, V52,
V53, V54)
).
move(d,
cube(X1, X2, X3, X4, X5, X6, V7, V8, V9,
V10, V11, V12, V13, V14, V15, V16, V17,
V18, V19, V20, V21, V22, V23, V24, V25, V26, V27, V28, V29,
V30, V31, V32, V33, V34, V35, V36, V37, V38, V39, V40, V41, V42,
V43, V44, V45, V46, V47, V48, V49, V50, V51, V52, V53, V54),
cube(X1, X2, X3, X4, X5, X6, V7, V8, V9,
V17, V16, V18, V13, V14, V15, V29, V28,
V30, V19, V20, V21, V11,
V10, V12, V25, V26, V27, V23, V22, V24, V31, V32,
V41, V42, V35, V36, V45, V46, V39, V40, V37, V38, V43, V44, V33,
V34, V47, V48, V49, V50, V51, V52, V53, V54)
).
move(r,
cube(X1, X2, X3, X4, X5, X6, V7, V8, V9,
V10, V11, V12, V13, V14, V15, V16, V17, V18,
V19, V20, V21, V22, V23, V24, V25, V26, V27, V28, V29, V30, V31,
V32, V33, V34, V35, V36, V37, V38, V39, V40, V41, V42, V43, V44,
V45, V46, V47, V48, V49, V50, V51, V52, V53, V54),
cube(X1, X2, X3, X4, X5, X6, V12, V11, V10, V24,
V23, V22, V13, V14, V15, V16, V17, V18, V9,
V8, V7, V21, V20, V19, V25, V26, V27, V28, V29, V30, V48, V47, V52,
```

<!-- page 304 -->
*Building Expert Systems in Prolog* *Rubik — Moves and Rotations (rubmov.pro)*

```prolog
V51, V35, V36, V37, V38, V39, V40, V41, V42, V43, V44, V45, V46,
V34, V33, V49, V50, V32, V31, V53, V54)
).
move(l,
cube(X1, X2, X3, X4, X5, X6, V7, V8, V9,
V10, V11, V12, V13, V14, V15, V16, V17, V18, V19, V20,
V21, V22, V23, V24, V25, V26, V27, V28, V29,
V30, V31, V32, V33, V34, V35, V36, V37, V38, V39, V40, V41,
V42, V43, V44, V45, V46, V47, V48, V49, V50, V51, V52, V53, V54),
cube(X1, X2, X3, X4, X5, X6, V7, V8, V9,
V10, V11, V12, V27, V26, V25, V15, V14, V13, V19, V20, V21, V22, V23, V24,
V30, V29, V28, V18, V17, V16, V31, V32, V33, V34, V54, V53,
V50, V49, V39, V40, V41, V42, V43, V44, V45, V46, V47, V48,
V36, V35, V51, V52, V38, V37)
).
move(f,
cube(X1, X2, X3, X4, X5, X6, V7, V8, V9,
V10, V11, V12, V13, V14, V15, V16, V17, V18, V19, V20,
V21, V22, V23, V24, V25, V26, V27, V28, V29,
V30, V31, V32, V33, V34, V35, V36, V37, V38, V39, V40, V41,
V42, V43, V44, V45, V46, V47, V48, V49, V50, V51, V52, V53, V54),
cube(X1, X2, X3, X4, X5, X6, V13, V15, V14, V7, V9, V8, V16, V18, V17,
V10, V12, V11, V19, V20, V21, V22, V23, V24, V25, V26, V27, V28, V29,
V30, V31, V32, V33, V34, V35, V36, V37, V38, V49, V50, V47, V48,
V43, V44, V45, V46, V39, V40, V41, V42, V51, V52, V53, V54)
).
move(b,
cube(X1, X2, X3, X4, X5, X6, V7, V8, V9,
V10, V11, V12, V13, V14, V15, V16, V17, V18, V19, V20, V21,
V22, V23, V24, V25, V26, V27, V28, V29,
V30, V31, V32, V33, V34, V35, V36, V37, V38, V39, V40, V41,
V42, V43, V44, V45, V46, V47, V48, V49, V50, V51, V52, V53, V54),
cube(X1, X2, X3, X4, X5, X6, V7, V8, V9,
V10, V11, V12, V13, V14, V15, V16, V17, V18, V22, V24, V23, V28,
V30, V29, V19, V21, V20, V25, V27, V26, V31, V32, V33, V34, V35,
V36, V37, V38, V39, V40, V41, V42, V51, V52, V53, V54, V47,
V48, V49, V50, V45, V46, V43, V44)
).
rot(ru,
cube(X1, X2, X3, X4, X5, X6, V7, V8, V9,
V10, V11, V12, V13, V14, V15, V16, V17, V18, V19, V20, V21,
V22, V23, V24, V25, V26, V27, V28, V29,
V30, V31, V32, V33, V34, V35, V36, V37, V38, V39, V40, V41, V42,
V43, V44, V45, V46, V47, V48, V49, V50, V51, V52, V53, V54),
cube(X2, X4, X3, X5, X1, X6, V20, V19, V21, V23, V22,
V24, V8, V7, V9, V11,
V10, V12, V26, V25, V27, V29, V28,
V30, V14, V13, V15, V17, V16, V18, V43, V44, V45, V46, V39,
V40, V41, V42, V31, V32, V33, V34, V35, V36, V37, V38, V52,
V51, V48, V47, V54, V53, V50, V49)
).
rot(rr,
cube(X1, X2, X3, X4, X5, X6, V7, V8, V9,
V10, V11, V12, V13, V14, V15, V16, V17, V18, V19, V20,
V21, V22, V23, V24, V25, V26, V27, V28, V29,
V30, V31, V32, V33, V34, V35, V36, V37, V38, V39, V40, V41,
V42, V43, V44, V45, V46, V47, V48, V49, V50, V51, V52, V53, V54),
cube(X6, X2, X1, X3, X5, X4, V12, V11,
V10, V24, V23, V22, V18, V17, V16,
V30, V29, V28, V9, V8, V7, V21, V20, V19, V15, V14, V13,
V27, V26, V25, V48, V47, V52, V51, V50, V49, V54, V53, V42,
V41, V46, V45, V40, V39, V44, V43, V34, V33, V38, V37,
V32, V31, V36, V35)
).
rot(rf,
cube(X1, X2, X3, X4, X5, X6, V7, V8, V9,
```

294

<!-- page 305 -->
*Appendices - Full Source Code* *Rubik — Moves and Rotations (rubmov.pro)*

```prolog
V10, V11, V12, V13, V14, V15, V16, V17, V18,
V19, V20, V21, V22, V23, V24, V25, V26, V27, V28, V29,
V30, V31,
V32, V33, V34, V35, V36, V37, V38, V39, V40, V41, V42, V43, V44,
V45, V46, V47, V48, V49, V50, V51, V52, V53, V54),
cube(X1, X3, X5, X4, X6, X2, V13, V15, V14, V7, V9, V8, V16, V18, V17,
V10, V12, V11,
V25, V27, V26, V19, V21, V20, V28,
V30, V29, V22, V24, V23, V36,
V35, V32, V31, V38, V37, V34, V33, V49, V50, V47, V48, V53, V54,
V51, V52, V39, V40, V41, V42, V43, V44, V45, V46)
).
```

<!-- page 306 -->
*Building Expert Systems in Prolog*

```prolog
% RUBHELP.PRO - Copyright (C) 1994, Amzi! inc.
% This is the help you get when you ask for help.
:- export rub_help/0.
rub_help:-
helpscreen(_),
nl,  write($[more - hit any key to continue]$),
get1(_),
fail.
rub_help.
helpscreen(intro):-
write($INTRODUCTION$),  nl,  nl,
write($The cube solver will generate a sequence of moves that will$),  nl,
write($solve any given cube (if solvable).  See rubdoc1.txt for$),  nl,
write($notes on the method.$),  nl,  nl.
helpscreen('menu options'):-
write($MAIN MENU OPTIONS$),  nl,  nl,
write($Solve - solves three types of cubes (from submenu)$),  nl,  nl,
write($      random - generate a random cube to solve$),  nl,
write($      manual - allows you to scramble your own$),  nl,
write($      edit   - allows you to describe a real cube$),  nl,  nl,
write($        with the option (prompts)$),  nl,  nl,
write($      stepmode - stops after each sequence (useful if$),  nl,
write($                 solving a real cube)$),  nl,
write($Manual - allows manipulation of cube (useful to see the$),  nl,
write($         effects of all the legal moves)$),  nl,  nl,
write($Help   - this stuff$),  nl,  nl,
write($Exit   - return to dos$),  nl.
helpscreen(notation):-
write($NOTES ON NOTATION$),  nl,  nl,
write($The cube is unfolded so all six sides are visible.  All moves$),  nl,
write($are labeled by the side they affect.  The letters used are:$),  nl,
nl,
write($                 B - back$),  nl,
write($       L - left  U - up    R - right$),  nl,
write($                 F - front$),  nl,
write($                 D - down$),  nl,  nl,
write($Directions - + clockwise, - counterclockwise$),  nl,  nl,
write($Pieces are referred to by color.  The colors are:$),  nl,  nl,
write($         W - white, G - green, B - blue, Y - yellow,$),  nl,
write($         R - red (PC magenta), O - orange (PC red) $),  nl,  nl,
write($Moves - three types$),  nl,  nl,
write($     Side moves - represented by single side letter, ex +r$),  nl,
write($     Rotations - rotate entire cube, preface side with r$),  nl,
write($                 ex. -ru, +rr (used to exploit symmetry)$),  nl,
write($     Sequences - sequence of moves by name ex. +ct1$),  nl.
helpscreen('solve display'):-
write($SOLVE DISPLAY FIELDS$),  nl,  nl,
write($Stage - the current stage (see rubdoc1.txt)$),  nl,  nl,
write($Target - the piece being solved for$),  nl,  nl,
write($Trying - the n-1 nodes of the breadth first search$),  nl,  nl,
write($Rotation - the chosen sequence of moves for the current goal$),  nl,
nl,
write($Hit any key to end$).
```

296

<!-- page 307 -->
*Appendices - Full Source Code*

```prolog
% RUBDATA.PRO - Copyright (C) 1994, Amzi! inc.
% This file contains all the data needed to drive
% the main cube solving predicates.
:-export seq/2, s_r/2, orientation/2.
:-export cnd/2, pln/2, vw/2.
:-export pristine/1.
:-export side_color/1.
% the sequences of moves used to perform special transformations
% such as twisting the corners without moving anything else
seq(s, [+rr, -r, +l]).
seq(tc1, [-l, +u, +r, -u, +l, +u, -r, -u]).
seq(tc1u2, [+ru, +ru, +tc1, -ru, -ru]).
seq(tc3, [+r, -u, -l, +u, -r, -u, +l, +u]).
seq(ct1, [-r, +d, +r, +f, +d, -f, -u, +f,
-d, -f, -r, -d, +r, +u]).
seq(ct3, [-r, +d, +r, +f, +d, -f, +u, +u,
+f, -d, -f, -r, -d, +r, +u, +u]).
seq(ef1, [-u, +f, -r, +u, -f, -s, +f, -u,
+r, -f, +u, +s]).
seq(ef2, [+l, +f, -u, +f, -r, +u, -f, -s,
+f, -u, +r, -f, +u, +s, -f, -l]).
seq(et1, [+f, +f, +r, +r, +f, +f, +r, +r,
+f, +f, +r, +r]).
seq(h, [+l, +f, +u, -f, -u, -l]).
seq(g, [-r, -f, -u, +f, +u, +r]).
seq(pt, [+ru, +ru]).
seq(mr2a, [+r, +f, -r, -f]).
seq(mr2b, [-r, -u, +r, +u]).
seq(mr3a, [-u, +r, +u]).
seq(mr3b, [+f, -r, -f]).
% cnd defines the moves which will be used in a given stage for search
cnd(1, [r, u, f]).
cnd(2, [r, mr2a, mr2b]).
cnd(3, [r, mr3a, mr3b]).
cnd(4, [r, tc1u2, ct1]).
cnd(5, [u, h, g, ef1, ef2]).
cnd(6, [u, tc1, tc3, ct1, ct3]).
% s_r is used by the shift_right heuristics.  it lists the move sequence
% needed to move a piece which is not on the right, to the right.  the
% first arguement is the position the piece is at
s_r(p('F','L','U'), [-mr2a]).
s_r(p('F','L','D'), [+rr, -mr2a, -rr]).
s_r(p('B','L','U'), [-rr, -mr2a, +rr]).
s_r(p('B','L','D'), [+rr, +rr, -mr2a, -rr, -rr]).
s_r(p('F','U'), [-mr3a]).
s_r(p('F','D'), [+s, -mr3a, -s]).
s_r(p('B','U'), [-s, -mr3a, +s]).
s_r(p('B','D'), [+s, +s, -mr3a, -s, -s]).
s_r(p('L','U'), [+u, +u]).
s_r(p('F','L'), [+f, +f]).
s_r(p('L','D'), [+d, +d]).
s_r(p('B','L'), [+b, +b]).
```

<!-- page 308 -->
*Building Expert Systems in Prolog* *Rubik — Rubik Data (rubdata.pro)*

```prolog
% orientation defines the rotation moves necessary to position the
% cube to take advantage of symmetry for each piece
orientation(p('F','L','U'), []).
orientation(p('F','L','D'), [+rr]).
orientation(p('B','L','U'), [-rr]).
orientation(p('B','L','D'), [+rr, +rr]).
orientation(p('F','U'), []).
orientation(p('F','D'), [+s]).
orientation(p('B','U'), [-s]).
orientation(p('B','D'), [+s, +s]).
orientation(p('L','U'), []).
orientation(p('F','L'), [+rr]).
orientation(p('L','D'), [+rr, +rr]).
orientation(p('B','L'), [-rr]).
orientation(_, []).
% pln lists the target pieces for each stage
pln(1, [p('L','U'),p('F','L'),p('L','D'),p('B','L')]).
pln(2, [p('B','L','D'),p('F','L','D'),p('B','L','U')]).
pln(3, [p('F','U'),p('F','D'),p('B','U'),p('B','D')]).
pln(4, [p('F','L','U')]).
pln(5, [p('R','U'),p('F','R'),p('R','D'),p('B','R')]).
pln(6, [p('F','R','U'),p('B','R','U'),p('B','R','D'),p('F','R','D')]).
% vw defines the preferred orientation for a stage
vw(5, [-rf]).
vw(6, [-rf]).
vw(_, []).
% this is the pristine state
pristine(cube('F','R','U','B','L','D',
'F','R','U','F','R','D','F','L','U','F','L','D','B','R','U','B','R','D',
'B','L','U','B','L','D','R','U','R','D','L',
'U','L','D','F','U','F','D','B','U',
'B','D','F','R','F','L','B','R','B','L')).
% the initial mapping of sides and colors
side_color(['F'-'G', 'R'-'R', 'U'-'W', 'B'-'Y', 'L'-'O', 'D'-'B']).
```

298

*Appendices - Full Source Code*

