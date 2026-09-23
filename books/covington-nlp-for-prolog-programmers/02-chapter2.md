# Chapter2

<!-- page 29 -->
**Templates and Keywords**

2.1 TEMPLATE MATCHING

2.1.1 ELIZA

In 1950, Alan Turing proposed that a machine should be considered intelligent if a human being, communicating with it by teletype, could not distinguish it from another human being. In 1966, Joseph Weizenbaum published a computer program called ELIZA that seemed to pass Turing’s test (admittedly with a different kind of conversation than Turing envisioned) but obviously did not contain humanlike intelligence.

ELIZA carried on a dialogue with its user, in English, in the manner of a psychological counselor. Figure 2.1 shows a typical dialogue (from Weizenbaum 1966). ELIZA was So convincing that people willingly told it their troubles and asked Weizenbaum to g0 away so they could converse in private. Psychiatrists even thought it was a practical way of administering therapy. Weizenbaum was alarmed at this; far from a triumph of artificial intelligence, he considered ELIZA to be evidence of how easy it is to deceive people with computers.

<!-- page 30 -->
After all, ELIZA did not “understand” much of its input, if “understanding” means responding to the information content. ELIZA merely recognized certain patterns of words and gave appropriate “canned” responses. For example, if the user typed You are X, ELIZA could respond What makes you think I am X, where X is any adjective. Any Sec. 2.1

Template Matching

15

Men are all alike. IN WHAT WAY They’re always bugging us about something or other. CAN YOU THINK OF A SPECIFIC EXAMPLE Well, my boyfriend made me come here. YOUR BOYFRIEND MADE YOU COME HERE He says I’m depressed much of the time. I AM SORRY TO HEAR YOU ARE DEPRESSED It’s true. I am unhappy. DO YOU THINK COMING HERE WILL HELP YOU NOT TO BE UNHAPPY I need some help, that much seems certain. WHAT WOULD IT MEAN TO YOU IF YOU GOT SOME HELP Perhaps I could learn to get along with my mother. TELL ME MORE ABOUT YOUR FAMILY My mother takes care of me. WHO ELSE IN YOUR FAMILY TAKES CARE OF YOU My father. YOUR FATHER You are like my father in some ways. WHAT RESEMBLANCE DO YOU SER

. You are not very aggressive but

I think you don’t want me to

notice that. WHAT MAKES YOU THINK I AM NOT VERY AGGRESSIVE You don’t argue with me. WHY DO YOU THINK I DON’T ARGUE WITH You You are afraid of me. DOES IT PLEASE YOU TO BELIEVE I AM AFRAID OF YOU My father is afraid of everybody. WHAT ELSE COMES TO MIND WHEN YOU THINK OF YOUR FATHER Bullies. DOES THAT HAVE ANYTHING TO DO WITH THE FACT THAT YOUR

BOYFRIEND MADE YOU COME HERE

Figure 2.1 A sample session with ELIZA. The machine’s responses are in upper case. sentence containing words like mother would get a reply such as Tell me more about your family. And a sentence containing nothing that ELIZA recognized would evoke a response such as Tell me more or Go on. Exercise 2.1.1.1

If your computer has the Gnu Emacs editor, you can play with a somewhat updated version

<!-- page 31 -->
of ELIZA. Simply get into Emacs and type: Esc x doctor Return. 2.1.2 Other Template Systems ELIZA was an example of a TEMPLATE SYSTEM or PATTERN-MATCHING SYSTEM, a technology that is still useful today. (A TEMPLATE is a pattern such as J am X.) What ELIZA proved is that templates are powerful enough for quite realistic natural-language dialogue.

Several other classic AI programs used templates. One of these was SIR (Semantic Information Retrieval) by Bertram Raphael (1968). SIR could do enough logical reasoning to answer questions such as, “Every person has two hands. Every hand has two fingers. Joe is a person. How many fingers does Joe have?”

Another was Bobrow’s STUDENT, which could solve high-school-level mathematical problems stated in English. A noteworthy feature of STUDENT is that it used recursive templates. For example, the template if X then Y allowed whole sentences in place of X and Y and would apply whole-sentence templates to them. Bobrow (1968) describes the original system and Norvig (1991) reimplements it in Common Lisp.

SIR, STUDENT, and their kin were developed mainly to study the information content of natural language, not to model the syntax. Nobody claims that templates are a realistic model of the way the human mind processes language. They are, however, a quick way to extract useful information from natural-language input, adequate for many practical user-interface applications. One modern example is HAL, the Englishlanguage command interface for the Lotus 1-2-3 spreadsheet program. Though its internal workings have not been made public, HAL shows the rigidity of syntax that is typical of a template system (see Petzold 1987).

.

**2.2 DOS COMMANDS IN ENGLISH**

2.2.1 Recipe for a Template System

In this section we will develop a template system that lets the user type commands to MS-DOS (PC-DOS) in English. The same could be done just as easily for UNIX or another operating system. See Lane (1987) for a different DOS-in-English system written in Turbo Prolog.

Like most template systems, ours will translate English into a formal language, in this case DOS command language. The formal language has two important characteristics:

e [tis much less expressive than English; many English words and expressions simply

cannot be translated into it.

e The human user knows about these restrictions on expressive power and can restrict

the English input accordingly. For example, people know that when talking to DOS,

it makes sense to say Show me the BAT files on drive D but not Look on my works,

ye mighty, and despair.

<!-- page 32 -->
This means that the template system can get away with covering only a tiny part of the English language. Sec. 2.2

**DOS Commands in English**

17

The first step in designing a template system is to write down a lot of sample input sentences with the desired translations, then try to find patterns in them. For example:

What files are on drive B?

=> dir b:

Delete all my files.

=> erase *.x*

Run the word processor.

=> wp

Figure 2.2 shows a larger set.

**At this stage you may well decide that DOS command language isn’t powerful**

enough. For example, the user can’t say Erase all files older than 1/29/90 because there is no DOS command corresponding to it; the erase command does not check the date of a file. This is a separate issue from natural language processing; we’ll leave it behind, but you have been warned. The success of any natural-language-driven software depends on whether the software can do what the user wants, not just whether it understands English.

The next step is to write a set of rules to do the translation. These will be of two types:

e SIMPLIFICATION RULES discard unnecessary words and make equivalent words look

alike. For example, display might get rewritten as show, and the might get dropped

```prolog
altogether.
```

e TRANSLATION RULES actually map a template into the formal language, such as

**(show, files,on,disk,X] > [’dir’,x,':°].**

What is on disk A?

=>

dir as:

What is on the disk in drive A?

=>

dira:

What files are on disk A?

=>

diras:

What files are there on the disk in drive

A?

=>

dir a:

(Likewise for any drive.)

Are there any EXE files on disk A?

=>

dir a:*.exe

Are there any EXE files on the disk in drive A?

=>

dir a:*.exe

What EXE files are there on disk A?

=>

dir a:*.exe

**What EXE files are there on the disk in driveA? > dir a:*.exe**

(Likewise for BAT files, COM

files, etc.)

Copy everything from disk

A to disk B.

=>

copy a:*.* b:

Copy everything from (the disk in)

drive A to (the disk in) drive B.

=>

copy a:*.* b:

Copy (all) files from ...(etc.)

=>

copy a:*.* b;:

Copy all BAT files from ...(etc.)

=>

copy a:*.bat b:

<!-- page 33 -->
Figure 2.2. Some English sentences and their translations into DOS command language. Simplification rules ( denotes the empty string):

the

=>

&G is

=>

@ are

=>

@ there

=>

@ any

=> disk in drive

**= drive**

disk in

=>

drive disk

=>

drive what files

=>

files what

=>

files file

=>

files everything

=>

all files every

=>

all

Translation rules:

Files on drive X?

=>

dir X: X files on drive Y?

=>

dir Y:*.xX Copy all files from drive X to drive Y.

=>

copy X:*.* Y: Copy all X files from drive Y to driveZ.

=>

copy Y:*.X Z:

Figure 2.3. Examples of simplification and translation rules.

The purpose of the simplification rules is to reduce the number of translation rules. There’s a trade-off; if you put in too many simplification rules, you may lose distinctions that you later on want to preserve. It’s common for some of the simplification rules to get dropped as the system becomes more complete. Figure 2.3 shows simplification and translation rules to handle the sentences in Figure 2.2. Note that every sentence goes through all the simplification rules that match any part of it, and then through one translation rule (the one that matches the whole sentence). What about sentences that the system can’t recognize? Some of these will be typing errors and the like. Others will be reasonable sentences that you didn’t provide for. The appropriate thing to do is store them on a file so that you can come back and modify the system later to handle them.

Exercise 2.2.1.1

<!-- page 34 -->
In addition to the examples in Figure 2.2, write down at least 20 more English sentences and their translations into MS-DOS command language (or the command language of your computer). Sec. 2.2

**DOS Commands in English**

19

Exercise 2.2.1.2

Write a set of simplification and translation rules (in any notation you care to use) to handle

those sentences. Notice that if you do this intelligently, your rules will also handle many

sentences that you didn’t originally think of. 2.2.2 Implementing Simplification Rules Simplification rules use templates for parts of sentences. For example, the word everything gets simplified to all files wherever it occurs, and the phrase what files is simplified to files.

What we need is a way to match simplification rules to the input list. The match can occur anywhere in the list. Accordingly, the program works through the list, word by word, comparing it to all the templates at every point:

[copy, files, from, disk, in, drive,a,to, drive,b]

(No match)

[files, from, disk, in, drive,a,to,drive,b]

(No match)

[from, disk, in, drive,a,to,drive,b]

(No match)

[disk,in,drive,a,to,drive,b]

(Matches ‘disk in’) The next question is how to store the templates. Here open lists come in handy. It’s much easier to match [disk, in, drive,a,to,drive,b] with (disk, in|X] than with [disk,in]. The latter would require a special procedure to compare elements one by one; the former can be done by ordinary Prolog unification. Here, then, are a set of simplification rules expressed as open lists:

% sxr(T1L,T2) 6

Simplification rules.

sr([the|X],X). sr(f{is|X],X). sr([are|X],X). sxr([there|X],X). sr(fany|X],X). sx([disk,in,drive|X], [drive|X]). sr({disk,in|!X], [drive|X]). sr([disk|X], [drive|X]). sr([what, files|X],[files|x]). sr({what

|X], [files|x]). sr([file|X], [files|x]). sr(f{everything|X],[all,files|x]). sr(flevery|X],[all|X]).

That is: [the|X] simplifies to X; [disk, in|X] simplifies to [drive|X]; and so on.

<!-- page 35 -->
The order of the simplification rules matters because more than one rule can match the same input. For example, disk in drive A matches both

disk in drive = drive

and

disk = drive.

If both rules match, the first one should take precedence; thus it must be tried first. Otherwise the result might be drive in drive A.

After one simplification rule works on the string, the result gets fed into the simplification rules again. This makes it possible, for example, to simplify all files to every file and then change every file to everything. You can even get loops; a loop will happen if there is a rule that changes every to all and also a rule that changes all to every. The complete simplification routine looks like this:

,

% simplify (+List,-Result) %

Applies simplification rules to List giving Result.

simplify (List,Result) :-

A simp. rule matches

oe

```prolog
sr(List,NewList),
! 7
simplify (NewList,Result).
```

so apply it and then

try to further simplify

the result

No simp. rule matches simplify ([(W|Words], [W|NewWords]) :-

dP dP de

oe

simplify (Words,NewWords) .

so advance to next word

oe

ae simplify([],([]).

No more words

Exercise 2.2.2.1

Using simplify/2 given above, implement all the simplification rules that you developed

in Exercise 2.2.1.2.

2.2.3 Implementing Translation Rules

Translation rules are relatively simple because each of them is supposed to match the whole list of words:

6 tr(?Input, ?Result) %

Translation rules.

tr([quit], [quit]). tr({files,on,drive,X,'?’],[’dir ’,X,’:']). tr([X,files,on,drive,Y,’?’],[’dir ',Y,‘’:*.'’,X]). tr([copy,all,

files, from, drive,X,to,drive,Y,’.’],

<!-- page 36 -->
(‘copy ',X,':*.* 7,Y,%:']). The output of a translation rule is a list of atoms which, when converted back into character strings and concatenated, will give the appropriate DOS command. (The first of these rules handles the “quit” command that the user will use to exit from the program.)

The procedure that applies the translation rules will simply find a rule that applies to the input, then execute a cut, or complain if no rule is applicable:

oe

translate (-Input,+Result)

Applies a translation rule, or complains oe oe

if no translation rule matches the input.

translate (Input,Result) :-

```prolog
tr(Input,Result),
|
```

translate(_,[]) :-

write(’I do not understand.’),

```prolog
nl.
```

Exercise 2.2.3.1

Implement all the translation rules that you developed in Exercise 2.2.1.2. Make sure these

fit together properly with the simplification rules that you have just implemented.

**2.2.4 The Rest of the System**

Once the translation rules have produced a command, the next step is to pass the command to the operating system. How this is done depends on the exact version of Prolog.

**The first step in ALS Prolog (which is typical) is to concatenate the atoms into a**

character string, so that for example [‘dir ’,’a:‘] becomes "dir a:". This is simple; just expand each atom into a list of characters, and append the lists:

oe

make_string(+ListOfAtoms, -String) oe oe

Concatenates a list of atoms giving a string.

Example: [’a‘’,’b’,’c’] gives "abc".

make_string([HIT],Result) :-

name (H,Hstring),

```prolog
make_string(T,Tstring),
append (Hstring,Tstring,Result).
```

make_string({],[]).

oe

append (?List1, ?List2,?List3) ae

Appending Listl to List2 gives List3.

<!-- page 37 -->
append([H|T],L,[H|Rest]) :- append(T,L,Rest). append([],L,L). The complete procedure to pass a command to DOS is:

pass_to_os (+Command)

Accepts a command as a list of atoms, concatenates

the atoms, and passes the command to the operating system. de oP ae

pass_to_os([quit]) :- !.

pass_to_os([]) :- !.

pass_to_os(Command) :-

```prolog
make_string(Command,S),system(S).
```

Notice that pass_to_os ignores [quit] (the quit command) and [] (the output of an unrecognized command).!

Finally, we’re ready to define the main procedure of the template system. Its purpose is to accept sentences from the user and run them through simplify, translate, and pass_to_os in succession. The main loop uses repeat so that execution will continue even if the processing of any particular command fails. Here, then, is the main procedure:

process_commands

Repeatedly accepts commands in English,

simplifies and translates them,

and passes them to the operating system. oP de oP oP

process_commands a

repeat,

```prolog
write(’Command: '),
read_atomics (Words),
                          % defined in Appendix B
simplify (Words, SimplifiedWords),
translate (SimplifiedWords, Command) ,
pass_to_os (Command) ,
Command == [quit],
```

The template system is now complete.

'The equivalent of make_string(Command,S), system(S) in some other Prologs is:

Arity Prolog:

concat (Command,S), shell(S) LPA (MS-DOS):

```prolog
make_string(Command,S), name(C,S), dos(C)
```

ESL Prolog-2:

```prolog
make_string(Command,S), list(S,C), command(C,32000,display)
```

Quintus (UNIX):

```prolog
make_string(Command,S), name(C,S), unix(system(C)
                                         )
```

Quintus (VMS):

```prolog
make_string(Command,S), name(C,S), vms(dcl(C))
```

<!-- page 38 -->
Consult your manual for further guidance. Exercise 2.2.4.1

Find out how your Prolog passes commands to the operating system, and get pass_to_os working. Verify that

?- pass_to_os([dir]).

(or the equivalent) works correctly.

Exercise 2.2.4.2

**Modify pass_to_os so that it displays the command on the screen before passing it to**

the operating system.

Exercise 2.2.4.3

Using your answers to several previous exercises, build a working, though small, template system that translates English sentences into DOS commands.

Exercise 2.2.4.4

Modify your DOS-in-English system so that if the user types an unrecognized sentence, this sentence is recorded in a file for you to see. (This will enable you to improve the system later, to accommodate more of the sentences that users actually type.)

[Hint: Consult your Prolog manual to find out how to open a file in append mode (i.e., open an already existing file so that you can write at the end).]

Exercise 2.2.4.5

(project)

Expand your DOS-in-English system so that it becomes a practical (if still modest) piece of software. Modify it in any ways you can think of that will make it more useful. This is a very open-ended project; depending on how much work you choose to do, it could be anything from a weekend assignment to a Ph.D. thesis.

Exercise 2.2.4.6

(project)

ELIZA in Prolog. Implement a version of ELIZA. To do this, you will have to implement:

e A simplifier that can translate you to me and me to you without getting into a loop;

**e A matching algorithm more powerful than ordinary Prolog unification, so that a**

variable can match more than one word in a list (for example, [X, says, that, Y]

should match my mother says that airplanes are dangerous);

e A strategy for identifying the most important word in a sentence (for example, com-

puter is more important than mother, which is more important than why), so that

if more than one template matches the input, the template that recognizes the most

important word can be chosen;

**e A way to give different responses to the same question at different times.**

<!-- page 39 -->
Weizenbaum (1966) gives a complete, though disorganized, set of simplification and translation rules for ELIZA; Norvig (1991) describes how to implement ELIZA in Lisp. Exercise 2.2.4.7 (project)

English grammar and style checking. Some commonly misused words and phrases can be

recognized by a template system. Examples:

e comprised of (standard English is composed of);

@ inasmuch as, in point of fact, in the area of (these are grammatical but should usually

be replaced by clearer, more direct wordings such as because, in fact, or in);

e very (much overused; should often be deleted);

e¢ does not only (a common mistake in the English of people whose native language is

German or Scandinavian).

Write a program that will read English documents (business letters, computer documentation,

etc.), and point out words and phrases such as these.

,

**2.3 KEYWORD ANALYSIS**

**2.3.1 A Time-Honored Approach**

An alternative to template matching is KEYWORD ANALYSIS. Instead of matching the whole sentence to a template, a keyword system looks for specific words in the sentence and responds to each word in a specific way.

One of the first keyword systems was that of Blum (1966). Inspired by ELIZA, Blum wrote a program to accept sentences such as

Copy I file from U1 to U2, binary, 556 bpi.

and convert them into commands for a program that managed magnetic tapes.

Though he took ELIZA as his model, Blum ended up using quite different techniques. He distinguished three kinds of keywords: requests (list, copy, backspace, etc.), “qualifiers” that further described the request, such as binary or blocked, and “quantifiers” (numbers) such as 5 files or 556 bpi (= bits per inch). His program simply collected all the requests, qualifiers, and quantifiers in the input and put them together into a properly formed command, paying very little attention to the word order and completely ignoring unrecognized words.

Keyword analysis has been reinvented several times, with slight variations, and keyword systems have had a long and successful history. Unlike template systems, they are not thrown off by slight variations of wording; unrecognized words are simply skipped. Keyword systems are useful in any situation where the input is known to contain certain kinds of information, and other information, if any, can be ignored.

<!-- page 40 -->
Two prominent keyword systems today are AICorp’s Intellect and Symantec’s Q&A; Obermeier (1989) lists many others. Both Q&A and Intellect are database query systems and both work very much like the system to be developed later in this chapter. Wallace (1984) describes a much more elaborate keyword system written in Prolog. 2.3.2 Database Querying

In this section we will develop a keyword-analysis program to process database queries that are expressed in English. Before doing this, however, we must say a few things about databases.

**Tables and tuples. A RELATIONAL DATABASE consists of one or more TABLES**

such as the following:

| ID number | Name

Birth date | Title

|

Salary |

1001

Doe, John P.

1947/01/30 | President

100000

1002

Smith, Mary J. | 1960/09/05 |} Programmer

30000

1003

Zimmer, Fred

1957/03/12 | Sales rep

45000

The database is a collection of Rows or RECORDS (lines), each divided into ATTRIBUTES (FIELDS). Each attribute has a name. One specific field—in this case, the ID number—is the KEY or IDENTIFIER; it is unique to each record and can be used to identify the record.

Formally, each record is a TUPLE (an ordered set of a specific number of items), a table is a set of tuples, and each table expresses a RELATION between the values in its tuples. A true relational database can consist of many tables; a FLAT-FILE DATABASE, which is less powerful, consists of one table only. For more on database theory, see Date (1990).

Queries.

The main function of a database is to answer QUERIES (requests for information). Database manipulation has a semantics all its own; regardless of the language used, the meanings of most queries will have the form

Do action A to all records that pass test T.

For example, if the query is

Show me all programmers with salaries over 25000.

then the action is display and the tests are Title = programmer, Salary > 25000.

Most large databases use STRUCTURED QUERY LANGUAGE (SQL) (pronounced “sequel”). In SQL the query just mentioned would be expressed as:

SELECT NAME, SALARY FROM TABLE1

WHERE SALARY > 25000

AND TITLE =

’ PROGRAMMER’

<!-- page 41 -->
In this chapter, however, we will use a database consisting of Prolog facts and construct queries in Prolog. The techniques are very much the same, and we avoid having to learn another language. Several Prolog implementations include the ability to access SQL databases through Prolog queries.

**2.3.3 A Database in Prolog**

In order to experiment with natural-language access to databases, we need a database. We will construct a simple database in Prolog, but it will be designed to act like a single table rather than to use Prolog in the most effective way. In this respect the Prolog system will act as if it were accessing a large database implemented in some other language.

First, the records themselves:

employee(1001,’Doe, John P.’,[1947,01,30],’President’,100000). employee (1002,’Smith, Mary J.’,[1960,09,05],’Programmer’,30000). employee (1003,’Zimmer, Fred’, [1957,3,12],’Sales rep’,45000).

Next, predicates to retrieve the values of the individual attributes, given the key:

full_name(ID,N) :- employee(ID,N,_,_,_). birth_date(ID,B) :- employee(ID,_,B,_,_). title(ID,T) :- employee(ID,_,_,T,_). salary(ID,S) :- employee(ID,_,_,_,S).

Finally, predicates to do other things to the records—in this case, merely display them and remove them:

display_record(ID) :-

employee (ID,N,B,T,S),

```prolog
write([ID,N,B,T,S]),
nl.
```

remove_record(ID) :-

retract (employee(ID,_,_,_,_)).

A fully functional database would also have a way to UPDATE (change) the attributes in each record.

Exercise 2.3.3.1

Make up a tiny relational (not flat-file) database and implement it in Prolog clauses. Include

at least two tables and give an example of a query that does something useful by accessing

both tables. Indicate which attribute is the key in each table.

Exercise 2.3.3.2

What is the relationship between first-argument indexing (see Appendix A) and the concept

<!-- page 42 -->
of a key in a database? 2.3.4 Building a Keyword System

Keyword systems work well for database querying because each important concept associated with the database has a distinctive name. A keyword system responds only to the words that identify fields, values, comparisons, and the like, and ignores all the other words,

Like a template system, the keyword system can have simplify andtranslate stages. However, the simplify stage is relatively unimportant and is often unnecessary. Its only function is to make synonymous words look alike. There is no need for simplify to drop unnecessary words such as the, because translate will drop all the words it does not recognize.

The translate stage does most of the work. The output of translate will be a Prolog query that picks out the appropriate records and performs some action on them. We want to act on all the records that pass the test, so we will attempt as many alternative solutions to the query as possible.

The main procedure will therefore look something like this:

ae

process_queries oe oe

Accepts database queries from the keyboard and

executes all solutions to each query.

process_queries :-

repeat,

```prolog
write(‘Query: ‘),
read_atomics (Words),
```

6 some systems would have a ‘simplify’ stage here,

translate (Words,_,Query),

write(Query), nl,

```prolog
                               % for testing
do_all_solutions (Query),
Words == [quit],
```

%® do_all_solutions (+Query) %

Makes execution backtrack through all solutions to Query.

do_all_solutions (Query) :-

call (Query),

```prolog
fail.
```

do_all_solutions(_).

The anonymous variable in the arguments of translate will be explained later.

Exercise 2.3.4.1

In process_queries, what should translate do with the quit command? (Don’t

<!-- page 43 -->
Just say “it should ignore it”; be more specific.) Exercise 2.3.4.2

When process_queries terminates, does it succeed or fail?

2.3.5 Constructing a Query

From the keyword system’s point of view, there are only five kinds of words:

@ ACTIONS such as display, erase, select, etc. (we may want to supply display as the

default action for queries that do not name an action);

e TESTS such as programmer, president, male, female, etc., each of which requires a

specific value in a specific attribute;

.

@ COMPARISONS such as greater, over, under, etc., each of which takes two arguments;

@ ARGUMENTS of the comparisons, such as salary (which retrieves the value of a

field) and 25000 (which is a constant); and

@ NOISE WORDS, i.e., unrecognized words which can be skipped.

The string of words must be translated into a Prolog query. This is done by working through it, word by word, and adding something to the query for each meaningful word. Assuming the input list is [show, programmer, salary,over, 25000], the process should go roughly as follows:

Word

Query

show

..., Gisplay_record(X)

programmer

title(X,programmer), ... display_record

(xX)

**salary**

over 25000

title(X,programmer), salary (X,Y), Z=25000,

Y>Z, display_record

(xX) Notice that the action goes at the end of the query because we don’t want it to be executed until all the tests have been fulfilled. All the other tests, however, come at the beginning, roughly in the order in which the human user gave them. Further, the comparison salary over 25000 translates into three queries (or in any case two), not just one.

Moreover, the variable xX, identifying the record to be retrieved, is shared by all the goals in the query. Otherwise there would be nothing to make them all apply to the same record.

We will put the query together by joining the goals with commas. Recall that if x, y, and z are Prolog queries, then so is (x,y,z). The comma is an infix Operator and is right associative so that (x,y,z) = (x, (y,Z)). Prolog executes a query of the form (a,b) by executing a and then b.

<!-- page 44 -->
Knowing this, we can write rules to translate words into queries. Specifically, we can define a predicate with a clause for each word that will translate that word and then call the predicate recursively to translate the rest of the list, thus: translate([show|Words] ,X, (Queries, display_record(X))) :-

| oF

translate (Words,X,Queries).

translate([programmer|Words],X, (title(X,programmer),Queries)) :-

i oF

translate (Words,X,Queries).

The first of these puts an action at the end of the compound query; the second puts an ordinary test at the beginning. Together these two rules translate

[show,programmer,...]

into

((title(X,programmer),...),display_record(X)

where ... stands for the rest of the list and its translation, respectively.

Any word for which there is no specific translation should be skipped. Together with the cuts in the previous clauses, the following clause takes care of this:

translate([_|Words],X,Query) :- translate(Words,X,Query) .

Finally, what happens at the end of the list? It would be handy if Prolog had a “null” or “empty” query that could serve as the translation of an empty list. Sure enough, there is such a thing—the built-in predicate true, which does nothing, but always succeeds. Thus we can write

translate([],_,true).

and then translate will render [show, programmer] (with no subsequent words) as:

((title(X,programmer) , true) ,display_record(X))

It takes less time to execute the redundant true in the query than to perform extra checks and avoid putting it there.

Exercise 2.3.5.1

Get translate working in the form shown. Add at least three more words to its vocab-

ulary and demonstrate that it works correctly.

Exercise 2.3.5.2

<!-- page 45 -->
Will our keyword system need a special routine to discard punctuation marks? Exercise 2.3.5.3

Modify translate so that it prints a warning when a word more than five letters long is

ignored. (A more sophisticated system might have a list of hundreds of words that it can

safely ignore, and print a warning whenever it ignores a word that is not on this list.)

**2.3.6 Lambda Abstraction**

The alert reader will have noticed two things. First, we haven’t tackled comparisons and their arguments yet. Second, the above clauses for translate contain a mysterious variable X whose only purpose is to get unified with all the variables in the query, so that they all become the same variable. As you might guess, the task of keeping the variables straight gets complicated when we start dealing with arguments of comparisons.

Accordingly, we’re going to pull out one of our most powerful tools: LAMBDA ABSTRACTION.

Lambda abstraction (or LAMBDA CALCULUS) may be the most useful technical tool in all of semantics. It was introduced by the logician Alonzo Church (1941) as a way to turn formulas into properties.

In formal logic, mortal(Socrates) means Socrates is mortal, and mortal (Plato) means Plato is mortal. So how do you say simply mortal? According to Church, the property of being mortal is expressed by the formula

(Ax)mortal (x) where A is the Greek letter lambda, and (Ax) means that x in the formula is to be supplied as an argument.

Here’s a more familiar example. In ordinary mathematics we “define” a function f by writing a formula such as

**Let f(x) = 4x +2.**

But this is really a definition, not of f, but of f(x); the reader is left to assume that the definitions of f(y), f(z), and f(a +b +c) are analogous, with yorzora+b+c substituted for x. If, instead, we say

**Let f = (Ax)4x +2.**

lambda abstraction makes it explicit that x is not part of the definition, but merely a stand-in for a value to be supplied from elsewhere.

The programming language Lisp uses lambda expressions regularly; in fact it is built around them. A function definition such as

(DEFUN F(X) (+ (* 4 X) 2))

was written, in the earliest dialect of Lisp, as:

(DEFINE F

(LAMBDA (X)

<!-- page 46 -->
(+ (* 4 X) 2))) That is, the definition of F is a lambda expression that says, “Give me a value—I’Il call it X—and I’ll multiply it by 4, add 2, and give you the result.” Then F is the name of this function, and the lambda expression describes the function.

Exercise 2.3.6.1

Assuming that studies(plato, philosophy) means ‘Plato studies philosophy’, use lambda ab-

straction to write expressions that mean:

1. ‘studies philosophy’

2. ‘Plato studies’

3. ‘studies’

Exercise 2.3.6.2

What is the result of supplying the argument 200 to the expression (Aqg)q* — g + 35?

Distinguish supplying the argument from evaluating the expression.

2.3.7 Lambdas in Prolog

Now back to the main story. Because Prolog is built around predicates rather than functions, the need for lambda expressions does not arise immediately, and there is no standard notation for them. Nonetheless, they are easy to construct and use. While we’re at it, we’re going to extend lambda abstraction beyond its original use, and use lambdas to indicate any part of a formula that is supplied from outside, whether or not our intent is to define a function or a property.

To see the need, recall that we defined programmer as title (X,programmer), and show as display_record (X). In order to translate a query such as show all programmers, we need to put the definitions of show and programmer together in such a way that the X’s in them are the same variable. But this isn’t easy. The structures title(X,programmer) and display_record(X) have different principal functors; they don’t unify with each other, and there is no easy way to get the X’s in them unified together.

At this point we have two options. We could use ‘=. .’ to decompose terms into lists and then search for the variables in the lists. Or—more simply—we could keep another copy of the variable in an easily accessible place outside the term.

That’s where lambda expressions come in. A lambda expression is merely a twoargument term whose arguments are a variable and a term in which that variable can occur. For example:

lambda (X,title(X,programmer) ) lambda (X,display_record(X) )

<!-- page 47 -->
Notice that Lambda doesn’t mean anything in Prolog; it’s just an arbitrary functor that I picked. It’s also rather long. To be more concise, let’s use the character ~ as an infix operator to hold lambda expressions together. Then we can write X * title(X,programmer) X * display_record

(xX)

and say that the first of these defines programmer and the second defines show. In ordinary lambda notation they would be (Ax)title(x, programmer) and (Ax)display (x), respectively.

**Notice that we don’t need an op declaration because ~ is already an infix operator.**

**In arithmetic expressions, it denotes exponentiation; in arguments to setof and bagof,**

it indicates that certain variables are to take on all possible values. Neither of these uses conflicts with the way we are using it here.

**Further, “ is right-associative so that X*Y*£(X,Y) is legal and means X* (Y***

**£(X,Y)).? That’s exactly how lambda notation deals with multiple arguments: “Give**

**me the first argument—I’ll call it X—and I'll give you a lambda expression that only**

wants one more argument.” Exercise 2.3.7.1

In Prolog, what is the result of unifying [X* green (X) , Y*frog(¥) ] with ([A*B,A*C]?

Exercise 2.3.7.2

Define a predicate suppl y_argument that will take a lambda expression and an argument,

and supply that argument to that lambda expression, like this:

```prolog
?- supply_argument (X*green(X),kermit, Result) .
Result = green(kermit)
```

Hint: The correct answer is very short.

Exercise 2.3.7.3

What is the result of supplying the argument felix to the lambda expression Y*X*

chases (X,Y)?

**2.3.8 The Complete System**

**Armed with lambda notation, we can store the definitions of words separately from the**

**translate predicate itself. That’s important because now translate needs only**

five clauses—for actions, tests, comparisons, skipped words, and the empty list—rather than a clause for each word. The clauses for translate are now:

% translate (+Words,-Variable, -Query) %

Translates Words (a list of atoms) into Query %

(a compound Prolog query to access the database). %

Variable serves to identify the records being retrieved.

<!-- page 48 -->
2In Arity Prolog version 4, you cannot write a functor adjacent to a left parenthesis unless that parenthesis introduces its argument list. So instead of ~( you must write ~ ( within formulas. translate([W|Words],X, (Queries,Q)) :-

```prolog
action(W,X*Q),
| 7
translate (Words,X,Queries).
```

translate([W|Words],X, (Q,Queries)) :-

test (W,X*Q),

| 4

translate (Words,X,Queries).

translate([Argl1,W,Arg2|Words],X, (Q1,02,03,Queries)) :-

comparison (W,Y~Z7Q3),

!

argument (Arg1,X*Y*Q1),

argument (Arg2,X*2Z*Q2),

translate (Words,X,Queries).

f°) translate([_|lWords],X,Query) :-

% skip unrecognized word

translate (Words,X,Query).

translate([],_,true).

The definitions of words look like this:

action (show, X*display_record(X)). action(display,X*display_record(X)). action(delete,

X* remove_record(X)).

test (programmer, X*title(X,'Programmer’)). test (salesrep,X*title(X,

‘Sales rep’)).

comparison(over,Y*~Z*

(Y>Z)). comparison(under,Y~Z*

(Y<Z)).

argument (salary, X*Y*salary(X,Y)). argument (birthdate, X°Y“birth_date(X,Y)). argument (N,_“Y*(Y=N)) :- number(N).

The last clause lets us use any number as an argument without looking anything up in the database.? That is, it provides for numeric constants. Like salary and birth_date, a number has two arguments, one for the person and one for the value, but the first argument is ignored.

Exercise 2.3.8.1

What is the crucial difference between the first two clauses of translate? That is, what

is the difference between the way it treats actions and the way it treats tests?

<!-- page 49 -->
3In ESL Prolog-2, use numeric(N) instead of number (N).

Chap. 2

Exercise 2.3.8.2 Put all these bits and pieces together and build a working natural language database query system. Add at least five words to its vocabulary in addition to the words defined in the code shown above.

Exercise 2.3.8.3 (large project) Using techniques from this and the previous chapter, plus anything else that occurs to you, build a natural language query system for a real database.

One possibility is to answer queries about users of a UNIX system. A suitable twotable database is easy to obtain. The file

/etc /passwd contains the user name and real name of every user (along with a lot of other information that is not useful). The command last -200 >myfile will write, on myfile, a database about the 200 most recent interactive sessions, showing who logged in when and for how- long. By combining these databases you can answer such questions as, “How many times did Jane Smith log in this week?”

To use these files, you will need to write a procedure that reads them line by line using an appropriate tokenizer (see Appendix B), builds a Prolog fact from each line, and asserts that fact into the knowledge base. The database will then consist of Prolog facts and can be queried using the methods developed in this chapter.

**2.4 TOWARD MORE NATURAL INPUT**

2.4.1 Ellipsis

Often the queries or commands typed by the user are incomplete, the assumption being that part of the query will be the same as the previous one. For example:

user:

What programmers have salaries over 25000? computer:

(prints a list or table) user:

Over 30000? computer:

(prints another list or table) Here Over 30000? is an example of ELLIPSIS (omission of repeated words). Ellipsis is fairly easy to handle in keyword systems. If the new query is incomplete (lacking an action, for instance), retain all parts of the previous query that are not explicitly replaced in the new one. Exercise 2.4.1.1 Modify your keyword system so that if the user does not supply an action, the same action will be used as in the previous query.

2.4.2 Anaphora

<!-- page 50 -->
ANAPHORA is the use of special words (ANAPHORS) to stand for individuals, events, or other things already referred to. Anaphoric pronouns such as he, she, it, and (the) ones refer to people or things; the anaphoric verb does/did refers to actions or states. Adverbs such as then and there can provide anaphoric reference to times and places.*

Anaphora is obviously useful in query systems. Users would like to be able to say things like:

**Give me a list of sales representatives in Georgia. List the ones in Florida. Now**

list the programmers there.

To handle anaphora, the system must remember important characteristics of earlier queries and must be able to figure out what the anaphors refer to. Usually, an anaphor refers to the most recently mentioned thing that it can refer to; she would refer to the most recently mentioned woman, for instance. In keyword systems, this is usually sufficient. A full account of anaphora will require a much more powerful theory of semantics and pragmatics (see Chapters 8 and 9).

Two other points need to be made. First, noun phrases marked with the are much like anaphors. If you say the boat you mean either a previously mentioned boat, or a boat that can be uniquely identified from the context.

Second, anaphors usually stand for referents (things referred to), not words or phrases. Occasionally this distinction is important. For example,

If any customer has overpaid, display his balance.

is obviously not the same as:

If any customer has overpaid, display any customer's balance.

Again, consider a discourse such as:

Display the first record.

**Now display the next record.**

**Now delete it.**

The last sentence does not mean ‘delete the next record’; it means ‘delete the record that

999 I just now referred to as “next”.

Exercise 2.4.2.1

Modify your keyword system to properly handle the anaphoric phrases which of them and

which ones (each referring to whatever records were retrieved by the previous query). The

user should be able to say such things as Show me all the programmers and then Which of

them have salary over 25000? or the like.

“Some linguists reserve the term ANAPHORA for pronoun reference only.
