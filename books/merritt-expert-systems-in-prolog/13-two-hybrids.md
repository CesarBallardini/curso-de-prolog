# Two Hybrids

<!-- page 131 -->
This chapter describes two similar expert systems, which were developed at Cullinet Software, a large software vendor for IBM mainframes, VAXes, and PCs. The systems illustrate some of the difficulties in knowledge base design and show the different features needed in two seemingly very similar systems.

Both expert systems were designed to set parameters for the mainframe database, IDMS/R, at a new user site. The parameters varied from installation to installation, and it was necessary to have an experienced field support person set them at the site. Since field support people are expensive, the expert systems were written to allow the customer to set the parameters, thus freeing the support person for more demanding tasks.

The first, CVGEN, set the system generation (sysgen) parameters for the run time behavior of the system. This included such parameters as storage pool sizes, logging behavior, and restart procedures. These parameters had a serious effect on the performance of the system, and needed to be set correctly based on each site's machine configuration and application mix.

The second, AIJMP, set all of the parameters that ran an automated installation procedure. This included parameters that determined which modules to include and how to build installation libraries. These parameters determined how the software would reside at the customer's site.

The systems were built using a variation of the pure Prolog approach described earlier in the book. The inferencing parts of the system were separated from the knowledge base. It was surprising to find that even with two systems as similar as these — they both set parameters, the shell for one was not completely adequate for the other. 10.1 CVGEN

Various shells available on the PC were examined when CVGEN was built, yet none seemed particularly well suited for this application. The main difficulty centered around the nature of the dialog with the user. To a large degree, the expertise a field support person brought to a site was the ability to ask the right questions to get information from the systems programmers at the site, and the ability to judge whether the answers were realistic.

To capture this expertise, the knowledge base had to be rich in its ability to represent the dialog with the user. In particular:

- The system was designed to be used by systems programmers who were technically sophisticated, but not necessarily familiar with the parameters for IDMS/R. This meant fairly lengthy prompts were needed in the dialog with the user.

- The input data had to be subjected to fairly complex validation criteria, which was often best expressed in additional sets of rules. A large portion of the field person's expertise was knowing what values made sense in a particular situation.

- The output of the system had to be statements, which were syntactically correct for IDMS/R. This meant the rules not only found values for parameters but built the statements as well.

<!-- page 132 -->
*Building Expert Systems in Prolog* The first objective of the system was to gather the data necessary to set the parameters by asking meaningful questions of the systems programmer. This meant providing prompts with a fair amount of text.

The next objective of the system was to validate the user's input data. The answers to the questions needed to be checked for realistic values. For example, when asking for the desired number of simultaneous batch users, the answer had to be checked for reasonableness based on the size of machine.

A similar objective was to provide reasonable default answers for most of the questions. As were the edit checks, the defaults were often based on the particular situation and required calculation using rules.

Given these objectives, the questioning facility needs to have the ability to call rule sets to compute the default before asking a question, and another rule set to validate the user's response. It also needs to be able to store questions that are up to a full paragraph of text.

The knowledge base needs to be designed to make it easy for the experts to view the dialog, and the edit and default rules. The knowledge base also needs some pure factual information.

The actual rules for inferencing were relatively simple. The system had a large number of shallow rules (the inference chains were not very deep), which were best expressed in backward chaining rules. The backward chaining was natural since the experts also tackled the problem by working backward from the goals of setting individual parameter values.

Also, since the system was setting parameters, uncertainty was not an issue. The parameter was either set to a value or it wasn't. For this reason pure Prolog was used for the main rule base.

Pure Prolog had the additional advantage of making it easy for the rules to generate IDMS/R syntax. The arguments to the parameter setting rules were lists of words in the correct syntax, with variables in the positions where the actual value of the parameter was placed. The rules then sought those values and plugged them into the correct syntax. 10.2 The Knowledge Base

The knowledge base is divided into six parts, designed to make it easy for the expert to examine and maintain it. These are:

- main rules for the parameters;

- rules for derived information;

- questions for the user;

- rules for complex validation;

- rules for complex default calculations;

- static information.

### Rule for parameters

The rules for each parameter are stored in the knowledge base with the parameter name as the functor. Thus each parameter is represented by a predicate. The argument to the predicate is a list with the actual IDMS/R syntax used to set the parameter. Variables in the

122

<!-- page 133 -->
*Chapter 10 - Two Hybrids* list are set by the body of the predicate. A separate predicate, parm, is used to hold the predicate names that represent parameters.

Most knowledge bases are designed with askable information listed separately from the rules, as in the earlier examples in the book. In this case however, the experts wanted the relationship between user dialog and rules to be more explicit. Therefor the ask predicate is embedded in the body of a rule whenever it is appropriate.

In the following example, the parameter is ina, which when set will result in a text string of the form INACTIVE INTERVAL IS X, where X is some time value. Some of the subgoals, which are derived from other rules, are online_components and small_shop, whereas int_time_out_problems is obtained from the user.

```prolog
parm(ina).
ina( ['INACTIVE INTERVAL IS', 60]):-
online_components,
small_shop.
ina( ['INACTIVE INTERVAL IS', 60]):-
online_components,
heavily_loaded.
ina( ['INACTIVE INTERVAL IS', 60]):-
ask(initial_install, no),
online_components,
ask(int_time_out_problems, yes).
ina( ['INACTIVE INTERVAL IS', 30]):-
online_components.
```

Some parameters also have subparameters that must be set. The structure of the knowledge base reflects this situation:

```prolog
parm(sys).
sys( ['SYSCTL IS', 'NO']):-
never.
sys( ['SYSCTL IS', 'SYSCTL']):-
os_class(os).
subprm(sys, dbn, [' DBNAME IS', 'NULL']):-
ask(initial_install, no),
ask(multiple_dictionaries, yes),
ask(db_name, null).
subprm(sys, dbn, [' DBNAME IS', V1]):-
ask(initial_install, no),
ask(multiple_dictionaries, yes),
ask(db_name, V1),
V1 \== null.
```

### Rules for derived information

The next part of the knowledge base contains the level of rules below the parameter/subparameter level. These rules represent derived information. They read as standard Prolog. Here are a few examples:

```prolog
heavily_loaded:-
ask(heavy_cpu_utilization, yes),
!.
heavily_loaded:-
ask(heavy_channel_utilization, yes),
!.
```

<!-- page 134 -->
*Building Expert Systems in Prolog*

```prolog
mvs_xa:-
ask(operating_system, mvs),
ask(xa_installed, yes),
!.
online_components:-
dc_ucf,
!.
online_components:-
ask(cv_online_components, yes),
!.
```

### Questions for the user

The next portion of the knowledge base describes the user interaction. Standard Prolog rules do not cover this case, so special structures are used to hold the information. Operator definitions are used to make it easy to work with the structure.

The first two examples show some of the default and edit rules, which are simple enough to keep directly in the question definition.

```prolog
quest abend_storage_size
default 200
edit between( 0, 32767)
prompt
['Enter the amount of storage, in fullwords, available',
'to the system for processing abends in the event',
'of a task control element (TCE) stack overflow.',
'Note that this resource is single threaded.'].
quest abru_value
default no
edit member( [yes, no])
prompt
['Do you want the system to write a snap dump to the',
'log file when an external run unit terminates',
'abnormally?'].
```

The next two rules require more complex edit and default rule sets to be called. The square brackets in the default field indicate there is a rule set to be consulted. In these examples, ed_batch_user will be called to check the answer to allowed_batch_users, and def_storage_cushion is used to calculate a default value for storage_cushion_size.

```prolog
quest allowed_batch_users
default 0
edit ed_batch_user
prompt
['How many concurrent batch jobs may access',
'the CV at one time?'].
quest storage_cushion_size
default [def_storage_cushion]
edit between( 0, 16384)
prompt
['How many bytes of storage cushion would',
'you like? When available storage is less than the',
'cushion no new tasks are started. A recommended',
'value has been calculated for you.'].
```

### Default rules

The next two sections contain the rules that are used for edit and default calculations. For example, the following rules are used to calculate a default value for the storage cushion

124

<!-- page 135 -->
*Chapter 10 - Two Hybrids* parameter. Notice that it in turn asks other questions and refers to the settings of another parameter, in this case the storage pool (stopoo).

```prolog
def_storage_cushion(CUS):-
ask(initial_install, yes),
stopoo([_, SP]),
PSP is SP / 10,
min(PSP, 100, CUS),
!.
def_storage_cushion(V1):-
ask(total_buffer_pools, V2),
stopoo([_, V3]),
ask(maximum_tasks, V4),
V1 is (V2 + V3 + 3) / (3 * V4),
!.
```

### Rules for edits

Here are the rules that are used to edit the response to the number of batch users. The user's response is passed as the argument, and rules succeed or fail in standard Prolog fashion depending on the user's response.

```prolog
ed_batch_user(V1):-
V1 =< 2,
!.
ed_batch_user(V1):-
machine_size(large),
V1 =< 10,
!.
ed_batch_user(V1):-
machine_size(medium),
V1 =< 5,
!.
ed_batch_user(V1):-
machine_size(small),
V1 =< 3,
!.
```

### Static information

The final section contains factual information. For example, here is a table of the MIPS ratings for various machines, and the rules used to broadly classify machines into sizes.

```prolog
mac_mips('4381-1', 1.7).
mac_mips('4381-2', 2.3).
mac_mips('3083EX', 3.7).
mac_mips('3083BX', 6.0).
mac_mips('3081GX', 12.2).
mac_mips('3081KX', 15.5).
mac_mips('3084QX', 28.5).
mips_size(M, tiny):-
M < 0.5,
!.
mips_size(M, small):-
M >= 0.5,
M < 1.5,
!.
mips_size(M, medium):-
M >= 1.5,
M < 10,
!.
```

<!-- page 136 -->
*Building Expert Systems in Prolog*

```prolog
mips_size(M, large):-
M >= 10.
```

The knowledge base is designed to reduce the semantic gap between it and the way in which the experts view the knowledge. The main parameter setting rules are organized by parameter and subparameter as the expert expects. The secondary rules for deriving information and the queries to the user are kept in separate sections.

The dialog with the user is defined by data structures, which act as specialized frames with slots for default routines and edit routines. Their definition is relatively simple since the frames are not general purpose, but designed specifically to represent knowledge as the expert describes it.

The standard Prolog rule format is used to define the edit and default rules. In the knowledge base the rules are simple, so Prolog's native syntax is not unreasonable to use. It would of course be possible to utilize a different syntax, but the Prolog syntax captures the semantics of these rules exactly. The experts working with the knowledge base are technically oriented and easily understand the Prolog syntax. Finally, supporting data used by the system is stored directly in the knowledge base.

It is up to the inference engine to make sense of this knowledge base. 10.3 Inference Engine

The inference is organized around the specialized knowledge base. The highest level predicates are set up to look for values for all of the parameters. The basic predicate set_parms accomplishes this. It uses the parm predicate to get parameter names and then uses the univ (=..) built-in function to build a call to a parameter setting predicate.

```prolog
set_parms:-
parm(Parm),
set_parm(Parm),
fail.
set_parms:-
write('no more parms'), nl.
set_parm(Parm):-
get_parm(Parm, Syntax),
write(Parm), write(': '),
print_line(Syntax), nl,
subs(Parm).
get_parm(Parm, Syntax):-
PS =.. [Parm, Syntax],
call(PS),
!.
subs(Parm):-
subprm(Parm, Sub, Syntax),
write(Parm), write('/'), write(Sub), write(':'),
print_line(Syntax), nl,
subs(Sub),
fail.
subs(Parm):-
true.
```

The next portion of the inference engine deals with the questions to the user. The following operator definitions are used to define the data structure for questions.

```prolog
:-op(250, fx, quest).
:-op(240, yfx, default).
:-op(240, yfx, edit).
```

126

<!-- page 137 -->
*Chapter 10 - Two Hybrids*

```prolog
:-op(240, yfx, prompt).
```

The basic ask predicate follows the patterns used earlier, but is more complex due to the fact that it handles both attribute-value pairs and object-attribute-value triples. The implementation of triples is relatively straight-forward and not worth repeating. The interesting portions of ask have to do with handling defaults and edits.

The following code is used by the ask predicate to perform edits on a user response. It is called after the user enters a value. If the edit fails, the user is presented with an explanation for why the edit failed, and is reprompted for the answer.

The third argument to edit is the edit criterion. It could be a simple edit such as member or less_than, or one of the more complex edit rules. The built-in univ (=..) is used to construct the goal that is called for the edit process. The actual code is slightly more complex due to additional arguments holding trace information for explanations.

```prolog
edit(X, X, none):- !.  % passes, no edit criteria.
edit(X, X, Ed) :-
Ed =.. [Pred | Args],
Edx =.. [Pred, X | Args],
call(Edx),
!.
edit(X, X, not(Ed)):-
Ed =.. [Pred | Args],
Edx =.. [Pred, X | Args],
notcall(Edx),
!.
```

The default is handled in a similar fashion. It is calculated before the prompt to the user, and is displayed in the answer window. Just hitting enter allows the user to take the default rather than entering a new value.

```prolog
default([], []):- !.
default(D, D):-
atomic(D),
!.
default([D], X):-
P =.. [D, X],
call(P).
```

**10.4 Explanations**

Explanations become a bit more difficult with the ask predicate. The how questions are handled pretty much as in the *Clam* and *Native* systems described earlier in the book. Since why traces require overhead during the inference process, and performance is a key issue for a system with a long dialog such as this one, the why trace implementation is different from that in *Native*. The basic strategy is to use pure Prolog as indicated for most of the inferencing, but to redo the inference using a Prolog in Prolog inference engine to answer why questions.

In order to do this the system must in fact restart the inference, but since the parameters are all basically independent, the why trace need only restart from the last call to set a parameter. For this reason, the set_parm predicate writes a record to the database indicating which parameter is currently being set.

Once the why trace gets into ask, the Prolog in Prolog must stop. In fact, the question might have arisen from setting a parameter, calculating a default value or specifying an edit criteria. Again, for these cases a flag is kept in the database so that trace knows the current situation.

<!-- page 138 -->
*Building Expert Systems in Prolog* The why trace then starts at the beginning, traces pure Prolog inferencing until it encounters ask. The why explanation then notes that it is in ask, and finds out from the database if ask has gone into either default or edit. If so it proceeds to trace the default or edit code. The final explanation to the user has the Prolog traces interspersed with the various junctions caused by edit and default in ask.

This system is a perfect example of one in which the explanations are of more use in diagnosing the system than in shedding light on an answer for the user. Many of the rules are based solely on empirical evidence, and reflect no understanding of underlying principles. For this reason a separate explanation facility was added to the knowledge base that would explain in English the rationale behind the setting of a particular parameter.

For example, the setting of the maxeru parameter is relatively complex. The rule, while correct in figuring a value for the parameter, does not give much insight into it. The separate exp predicate in the knowledge base is displayed in addition to the rule if the user asks how a value of maxeru was derived.

```prolog
parm(maxeru).
maxeru( ['MAXIMUM ERUS IS', MAXERU]):-
maxeru_potential(PMERU),
max_eru_tas(F),
MAXERUF is PMERU * F,
MAXERU is integer(MAXERUF),
explain(maxerutas01).
exp(maxerutas01,
['MAXERUS and MAXTASKS are set together. They are both ',
'potentially set to values which are dictated by the size ',
'of the terminal network. The total tasks for both is then ',
'compared to the maximum realistic number for the ',
'machine size. If the total tasks is too high, both ',
'MAXERUS and MAXTASKS are scaled down ',
'accordingly.']).
```

**10.5 Environment**

CVGEN is also designed to handle many of the details necessary in a commercially deployed system. These details include the ability to change an answer to a question, save a consultation session and restore it, build and save test runs of the system, and the ability to list and examine the cache and the knowledge base from within a consultation. The system also includes a tutorial, which teaches how to use the system.

Most of these features are straight-forward to implement, however changing a response is a bit tricky. When the user changes an answer to a question, it is almost impossible to predict what effects that will have on the results. Whole new chains of inferencing might be triggered. The safest way to incorporate the change is to rerun the inference. By saving the user's responses to questions, the system avoids asking any questions previously asked. New questions might be asked due to the new sequence of rules fired after the change.

The facts which are stored are not necessarily the same as the user's response. In particular, the user response of "take the default" is different from the actual answer, which is the default value itself. For this reason, both the facts and the user responses to questions are cached. Thus, when the user asks to change a response, the response can be edited and the inference rerun without reprompting for all of the answers.

This list of responses can also be used for building test cases, which are rerun as the knowledge base is modified.

128

<!-- page 139 -->
*Chapter 10 - Two Hybrids* 10.6 AIJMP

The AIJMP system seemed on the surface to be identical to the CVGEN system. Both set parameters. It was initially assumed that the shell used for CVGEN could be applied to AIJMP as well. While this was in general true, there were still key areas that needed to be changed.

The differences have much to do with the nature of the user interaction. The CVGEN system fits very nicely into the classic expert system dialog as first defined in the MYCIN system. The system tries to reach goals and asks questions as it goes. However, for AIJMP there is often the need for large amounts of tabular data on various pieces of hardware and software. For these cases a question and answer format becomes very tedious for the user; a form-based front end to gather information is much more appropriate.

AIJMP uses forms to capture some data, and dialogs to ask for other data as needed. This led to the need to expand the basic inferencing to handle these cases.

Another difficulty became evident in the nature of the expertise. Much of what was needed was purely algorithmic expertise. For example, part of the system uses formulas to compute library sizes based on different storage media. Many of the parameters required both rules of thumb and algorithmic calculations.

The best solution to the problem, for the knowledge engineer, was to build into the inference engine the various predicates which performed calculations. This way they could be referred to easily from within the rules.

Some of the declarative knowledge required for AIJMP could not be easily represented in rules. For example, many products depend on the existence of co-requisite products. When the user enters a list of products to be installed, it must be checked to make sure all product dependencies are satisfied. The clearest way to represent this knowledge was with specialized data structures. Operators are used to make the structures easy to work with.

```prolog
product 'ads batch 10.1'
psw [adsb]
coreqs ['idms db', 'i data dict'].
product 'ads batch 10.2'
psw [adsb]
coreqs ['idms db', 'i data dict'].
product 'ads online'
psw [adso, nlin]
coreqs ['idms db', 'idms cv', 'i data dict',
'idms dc' / 'idms ucf'].
product auditor
psw [audi, culp]
coreqs [].
product autofile
psw [auto]
coreqs [].
```

The inference engine was enhanced to use this structure for co-requisite checking. The design goal is to make the knowledge base look as familiar as possible to the experts. With Prolog, it is not difficult to define specialized structures that minimize semantic gap and to modify the inference engine to use them.

One simple example of how the custom approach makes life easier for the expert and knowledge engineer is in the syntax for default specifications in the questions for the user. The manual on setting these parameters used the "@" symbol to indicate that a parameter had as its default the value of another parameter. This was a shorthand syntax well understood by the experts. In many cases the same value (for example a volume id on a

<!-- page 140 -->
*Building Expert Systems in Prolog* disk) would be used for many parameters by default. Only a slight modification to the code allowed the knowledge to be expressed using this familiar syntax:

```prolog
quest loadunit
default @ diskunit
edit none
prompt
['What is the unit for the load library?'].
```

One of the major bottlenecks in expert system development is knowledge engineering. By customizing the knowledge base so it more closely matches the expert's view of the knowledge domain, the task becomes that much simpler. A simple change such as this one makes it easier for the expert and the knowledge base to interact. 10.7 Summary

These two systems show how some of the techniques in this book can be used to build real systems. The examples also show some of the difficulties with shells, and the advantages of customized systems in reducing semantic gap.

## Exercises

10.1 Incorporate data structures for user queries with edits and defaults for the *Clam*

```prolog
shell.
```

10.2 The CVGEN user query behavior can be built into *Foops* when a value is sought

from the frame instances. If there is no other way to get the value, the user should

be queried. Additional facets can be used for prompt, default, and edit criteria,

which the inference engine uses just like in CVGEN. 10.3 Add features of CVGEN to the shells that are needed for real world applications.

These include the ability to save user responses, allow editting of responses, saving

a consultation, and rerunning a consultation. The last feature is essential for testing

and debugging systems. Old test runs can be saved and rerun as the knowledge base

changes. Hopefully the changes will not adversely affect the old runs.

130

*Chapter 10 - Two Hybrids*

