# Issue Table of Contents

<!-- page -1 -->
manipulating a large number of list processing tasks. Gegg-Harrison intends the eventual construction of an Intelligent Teaching System for Prolog. Other work towards this end has been done by Looi (1991) but much more work needs to be done in this area.

In this section, we have concentrated mostly on related work in the area of the application of techniques to program construction. We have noted that others are interested in the issue of teaching techniques to novice Prolog programmers but that there is little evidence of the effectiveness of such schemes (other than anecdotal). Intelligent Teaching Systems for Prolog are still in their infancy.

It would appear that no one has yet applied the notion of techniques to support the debugging of programs. Nor, in relation to this idea, has there been any attempt to provide program visualisation tools that support this notion directly.

9 Conclusion

We have sought to justify the concept of a Prolog programming technique and show how the elaboration of the set of available techniques can be useful to programmers, to teachers of Prolog and in future Intelligent Tutoring Systems. Such techniques have also been found useful in extending the language.

We have also sought to indicate the way in which knowledge about techniques can be used in program construction and program debugging. Further theoretical work is needed to develop the necessary tools for supporting this.

In particular, we believe that a key factor is the development of a techniques editor. In order to develop such a system, we need to develop the work on techniques. This requires the extension of the range of known techniques using knowledge elicitation techniques, the refinement of the definitions of the techniques and their representation. Detailed work has been done on the concept of an editor for developing a class of well-founded recursive programs that can be guaranteed to terminate (Bundy et al., 1991). Further work related to that of Plummer, Kirschenbaum, and Gegg-Harrison has to be done to integrate the work on recursive programs with other techniques (Plummer, 1990; Gegg-Harrison, 1991; Kirschenbaum et al., 1989).

Given such a techniques editor we may then find that it plays a positive rôle in the education of novice Prolog programmers as well as aiding in the development of large scale Prolog programs.

Acknowledgements

We particularly thank the referees for their helpful and informative comments. This work was funded in part through the Alvey-funded workshop on Learning Prolog: tools and related issues at Cosener's House, Abingdon, during February 1987.

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 0 -->
All use subject to http://about.jstor.org/terms References

Breuker, J. A. and Wielings, B. J. (1985). KADS: structured knowledge acquisition for expert sys tems. In J. A. Breuker, Proceedings of the Fifth International Workshop on Expert Systems and their Applications, Avignon. Also: VF Memo 40, Department of Social Science Informatics, University of Amsterdam. Bma, P., Brayshaw, M., Bundy, A., Dodd, T., Elsom-Cook, M. and Fung, P. (1991). An overview of Prolog debugging tools. Instructional Science, this issue. Bundy, A. (1988). A broader interpretation of logic in logic programming. In A. Bundy, Proceedings of the Fifth International Logic Programming Conference/ Fifth Symposium on Logic Programming. Cambridge, MA: MIT Press. Bundy, A., Grosse, G. and Brna, P. (1991). A recursive techniques editor for Prolog. Instructional Science, this issue. Chi, M. T. H., Feltovich, P. J. and Glaser, R. (1981). Categorization and representation of physics problems by experts and novices. Cognitive Science, 5, 121-152. de Jong, T. and Ferguson-Hessler, M. G. M. (1986). Cognitive structures of good and poor novice problem solvers in physics. Journal of Educational Psychology, 78(4), 279-288, Ferguson-Hessler, M. G. M. and de Jong, T. (1987). On the quality of knowledge in the field of electricity and magnetism. American Journal of Physics, 55(6), 492-497. Gegg-Harrison, T. S. (1991). Learning Prolog in a schema-based environment. Instructional Science, this issue. Gilmore, D. J. and Green, T. R. (1988). Programming plans and programming expertise. Quarterly Journal of Experimental Psychology, 40, 423-442. Johnson, W. L. and Soloway, E. (1985). PROUST: knowledge-based program understanding. IEEE Transactions of Software Engineering, SE-11Q), 267-275. Johnson, W. L. (1986). Intention-based debugging of novice programming errors. London: Pitman. Kahney, H. (1982). An in-depth study of the cognitive behaviour of novice programmers. Unpublished Ph.D. thesis, Human Cognition Research Laboratory, The Open University, Milton Keynes, U.K. Kirschenbaum, M., Lakhotia, A. and Sterling, L. (1989). Skeletons and techniques for Prolog progr amming. TR 89-170, Case Western Reserve University. Laird, J. E., Rosenbloom, P. and Newell, A. (1985). Chunking in SOAR: the anatomy of a general learning mechanism. Research Report CMU-CS-85-154, Department of Computer Science, Camegie-Mellon University. Looi, C. K. (1991). Automatic debugging of Prolog programs in a Prolog Intelligent Tutoring System. Instructional Science, this issue. O'Keefe, R. A. (1988). Practical Prolog for real Prolog programmers. A tutorial given at the Fifth International Conference Symposium on Logic Programming, Seattle. O'Keefe, R.A. (1990). The craft of Prolog. Cambridge, MA: MIT Press. Plummer, D. (1990). Cliché programming in Prolog. In D. Plummer, Proceedings of the META-90 Workshop, META-90. Leuven, Belgium. Reiser, B. J., Anderson, J. R. and Farrell, R. G. (1985). Dynamic student modelling in an intelligent tutor for LISP programming. In A. Joshi (Ed.), Proceedings ofIJCAI-85, pp. 8-14. International Joint Conference on Artificial Intelligence, Los Altos, CA: Morgan Kaufman. Rich, C. and Waters, R. C. (1987). The Programmer's Apprentice: a program design scenario. AI Memo 933a, M. I. T. Artificisal Intelligence Laboratory, Cambridge, MA. Spohrer, J. C., Soloway, E. and Pope, E. (1985). A goal-plan analysis of buggy Pascal programs. Human-Computer Interaction, 1, 163-207. Sterling, L. and Lakhotia, A. (1988). Composing Prolog meta-interpreters. In R. A. Kowalski and K. A. Bowen (Eds.), Logic programming: Proceedings of the Fifth International Conference and Symposium, pp. 386-403, Cambridge, MA: MIT Press. Sterling, L. and Shapiro, E. Y. (1986). The art of Prolog. Cambridge, MA: MTT Press. van Someren, M. W. (1990). What's wrong? Understanding beginners' problems with Prolog. Instructional Science, 19(4/5), 257-282. Waters, R. C. (1985). KBEmacs: a step toward the Programmer's Apprentice. Technical Report 753, MIT Artificial Intelligence Laboratory, Cambridge, MA.

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 1 -->
All use subject to http://about.jstor.org/terms Prolog programming techniques Author(s): PAUL BRNA, ALAN BUNDY, TONY DODD, MARC EISENSTADT, CHEE KIT LOOI, HELEN PAIN, DAVE ROBERTSON, BARBARA SMITH and MAARTEN VAN SOMEREN Source: Instructional Science, Vol. 20, No. 2/3, Special Issue: Teaching, Learning and Using Prolog (1991), pp. 111-133 Published by: Springer Stable URL: http://www.jstor.org/stable/23369893 Accessed: 05-08-2016 06:26 UTC

Your use of the JSTOR archive indicates your acceptance of the Terms & Conditions of Use, available at http://about.jstor.org/terms

JSTOR is a not-for-profit service that helps scholars, researchers, and students discover, use, and build upon a wide range of content in a trusted digital archive. We use information technology and tools to increase productivity and facilitate new forms of scholarship. For more information about JSTOR, please contact support@jstor.org.

Springer is collaborating with JSTOR to digitize, preserve and extend access to Instructional Science

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 2 -->
All use subject to http://about.jstor.org/terms Instructional Science 20: 111-133 (1991) © Kluwer Academic Publishers, Dordrecht - Printed in the Netherlands

**Prolog programming techniques**

**PAUL BRNA1, ALAN BUNDY1, TONY DODD2, MARC**

**EISENSTADT3, CHEE KIT LOOI4, HELEN PAIN1, DAVE**

**ROBERTSON1, BARBARA SMITH5 & MAARTEN VAN SOMEREN6**

Department of Artificial Intelligence, University of Edinburgh, 80 South Bridge, Edinburgh, EH1 IHN, UK. ^Expert Systems International Ltd., 9 West Way, Oxford, 0X2 OJB, UX. ^Human Cognition Research Laboratory, The Open University, Milton Keynes, MK7 6AA, U.K. 4 Information Technology Institute, 71 Science Park Drive, Singapore 0511 School of Computer Studies, University of Leeds, Leeds, LS2 9JT, UK. ^Department of Social Science Informatics, University of Amsterdam, Roetersstraat 15, 1018 WB Amsterdam, The Netherlands.

Abstract. In this paper we introduce the concept of a Prolog programming technique. This concept is then distinguished both from that of an algorithm and that of a programming cliché. We give exam ples and show how a knowledge of them can be useful in both programming environments and in teaching programming skills. The extraction of the various techniques is outlined. Finally, we discuss the problem of representing techniques where we conclude that the most promising approach is the development of a suitable meta-language.

1 Introduction

Until recently, there has been little more than a feeling that there are common pat terns of code used by Prolog programmers in a fairly systematic way. There has been widespread uncertainty as to what these common patterns are and whether they are any real use.

In this paper we outline the reasons - both theoretical and empirical - why we believe that such techniques exist and how we have limited the notion of tech nique in order that we can distinguish between the algorithm that some Prolog code implements and the choices made by the programmer in terms of Prolog data structures and Prolog control.

We outline our work on describing and formalising Prolog programming tech niques. We motivate the discussion in terms of illustrative examples and, later, we provide more formal descriptions as part of our discussion of the issues that underlie the problem of how to represent techniques.

We have described the progress that we (and others) have made in this area both in terms of software engineering and in terms of education. We have also described the potential utility of such techniques for both experts and novices and for both program construction and program debugging.

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 3 -->
All use subject to http://about.jstor.org/terms

Having provided the motivation and the framework within which we are work ing, we mention here the work of Bundy et al. who illustrate aspects of our approach in the design and construction of an editor (Bundy et al., 1991, this issue). This editor makes use of the notion of techniques to constrain the progr ammer to build a restricted range of programs with some desirable properties (such as termination). This system, partially implemented, demonstrates the utility of the techniques-based approach particularly for software production. Gegg-Harrison, also in this issue (Gegg-Harrison, 1991), describes an approach to the education of novice Prolog programmers founded on the related notion of basic Prolog schemata. We have provided an outline of the educational potential of this approach.

These systems demonstrate the education and software engineering potential of the techniques-based approach. We note, however, that despite the potential for the use of Prolog programming techniques in program debugging and program visualisation there has been very little work in this area. In this paper, we limit ourselves to outlining this potential.

**2 What is a technique?**

One way in which experienced Prolog programmers differ from novices is that they have picked up a wide variety of coding techniques from their previous programming experience and are able to bring this to bear on new problems. By Prolog programming technique we understand, for instance, the use of cut to implement the conditional structure "if test then case 1 else case 2", i.e.,

```prolog
cond:- test, !, case 1.
cond:- case 2.
```

Another technique is the use of accumulator pairs to build recursive data struc tures. e.g., the use of an accumulator argument (Acc in the second clause of rev/3) and result argument (Res in the second clause of rev/3) in:

rev(List,ReversedList):

```prolog
         rev(List,[] .ReversedList).
rev( [], Acc, Acc).
rev([HIT], Acc, Res):
         rev(T, [HIAcc], Res).
```

to build the output list and the use of the result argument Res to return it as out put. (We thank Richard O'Keefe for his emphasis on accumulator pairs. Also, we note that accumulator pairs can be used for reasons outwith the building of recur sive data structures: see O'Keefe, 1990).

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 4 -->
All use subject to http://about.jstor.org/terms

We contrast such techniques with both the notion of algorithm and that of programming clichés (see the work on the Programmer's Apprentice in Waters, 1985). An algorithm is a language independent procedure which meets some specification, e.g., sorts the elements of a list. In contrast, our techniques are language dependent (i.e., Prolog), but specification independent, e.g., the same technique might be used in sorting a list or in finding the maximum of two numbers. Furthermore, a technique might apply to only part of a complete proc edure, and many techniques may be combined together in a procedure.

The notion of cliché is less restrictive than either an algorithm or technique. It seems to include both algorithms for specific tasks, e.g., sorting a list, and language independent techniques. There is no attempt to be parsimonious: in the Programmer's Apprentice users can build a large and redundant library of clichés embodying complete or fragmentary algorithms and generalised to the extent they specify. In contrast, we intend our techniques to be a parsimonious set and to be maximally generalised. We want a small set of techniques from which Prolog programs can be generated by combination and specialisation. We might expect to discover of the order of 100 commonly occurring techniques. This parsimony solves some problems of retrieval caused by the large number of clichés.

In subsequent sections we explore the questions of:

- what is the set of techniques?

- what can techniques be used for?

- how can we use principled methods to uncover them?

- how can they be represented?

3 Some examples of techniques

We have identified a wide range of constructs that feature one or more techniques. Here, we provide a selection of those techniques that we have identi fied. We have sought to name these to suggest the programmer's intentions (see Section 5 for empirical work on extracting programmer's intentions/program understanding).

Some further work has been done by us to organise these techniques into a hierarchical structure. Here, we do not describe the limited progress in this area. We would argue that the structuring of techniques depends, to an extent, on the purpose for which it is intended. The software engineer may well produce a different structuring from that produced by a Prolog educator. If we focus on the instructional issues, we require that any analysis of techniques be integrated into a general task analysis for a substantial part of the Prolog language and various related issues (e.g., debugging, style, knowledge representation and so on). This interesting task is not, however, within the scope of this paper.

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 5 -->
All use subject to http://about.jstor.org/terms The list of techniques that we have identified includes (amongst others): generate-and-test catchall-fail constructing-datastructures-in-the-clause-head catchall-true constructing-datastructures-in-the-clause-body commit-to-case if-then-else always-succeed failure-driven loop succeed-at-most-once check-terms-would-unify test-existence cut-fail find-all-solutions Each of these techniques can be given a precise meaning at the code level. We seek here to motivate the notion of technique in an informal manner before turning, in Section 7, to provide a more formal approach. There is also the need to organise the techniques into some kind of hierarchy and to decide on whether to include more esoteric techniques that might be of less use to the beginner; for example, the enhancement of Prolog meta-interpreters (see Sterling and Lakhotia, 1988). For example, the technique of generate-and-test is suggested by the highly inefficient code fragment below where generate!1, on backtracking, returns a new integer each time (i.e., 1,2,3...):

three_digit_prime(Integer):

```prolog
         generate(Integer),
         test(Integer).
test(Integer):
         Integer >99,
         prime(Integer).
```

We describe the use of accumulator pairs for constructing-datastructures-in-the clause-body in Section 7. Code illustrating constructing-datastructures-in-the clause-head follows:

```prolog
:- mode double(+,-).
double«],[]).
double([Hl I T], [H2 I Ans]):
         H2 is 2* HI,
         double(T, Ans).
```

The pattern in the second argument of the heads of the clauses is used to build the output list recursively. Note that the mode of a predicate indicates the rôle of the various arguments: A + indicates an input argument (instantiated or at least partially so), - indicates an output argument which is therefore a variable and ? indicates an argument which might be either an input or an output argument.

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 6 -->
All use subject to http://about.jstor.org/terms

failure_driven_loop:

```prolog
                   % Non-deterministic literal
         fact(X),
         write(X),nl,
                   % Side effecting literal
         fail.
                   % Failing literal
failure_driven_loop
fact(l).
fact(23).
```

Figure 1. A failure driven loop

One of the standard techniques for producing a form of bounded quantification is that of the 'failure-driven loop' illustrated in Figure 1. For this technique, there needs to be:

- a non-deterministic literal which will eventually fail

- a side effecting literal

- a failing literal Prolog programmers are familiar with the intuitive idea of techniques. Textbooks such as The art of Prolog (Sterling and Shapiro, 1986) refer to this intuition. Figure 2 gives the definition of two familiar predicates which have a great deal in common.

mode length(+,-).

```prolog
length(List, Length)
         length(List, 0, Length).
length([], Length, Length).
length(L I Tail], SoFar, Length)
         Count is SoFar+1,
         length(Tail, Count, Length).
  mode rev(+,-).
rev(List, Reversed)
         reverse(List, [], Reversed).
reverse([], Reversed, Reversed).
reverse([Head I Tail], Sofar, Reversed)
         reverse(Tail, [Head I Sofar], Reversed).
```

Figure 2. Definitions of length/2 and rev/2

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 7 -->
All use subject to http://about.jstor.org/terms

Note that the common idea is that of using an accumulator pair. We produce a schema, in Figure 7, for the technique for which length/3 and reverse/3 are an instantiation.

In each case, the predicate with arity 2 makes use of a predicate with arity 3. In both cases, the recursion is over a list. The recursion argument is the first argument, the accumulator argument is the second argument and the result argument is third. The accumulator for one is an integer while, for the other, it is a list. The base constructor for integers is 0, while for lists, is [].

**4 What use are they?**

In this section, we discuss a number of issues relating to the utility of Prolog programming techniques. These issues include: the rôle of techniques in progr amming; in teaching programming; in intelligent systems to teach programming; in debugging programs; in support for program construction; and in language design. We finish this section with a brief discussion about the problems and benefits that can be expected for novice programmers.

4.1 Use in programming

Programming techniques provide ready made solutions for subtasks of progr amming. They provide generalised pieces of Prolog code or abstract descriptions (e.g., a side effect on the database) that can be used to implement part of a speci fication. In top-down program development, programming techniques make the last steps easier before completing the final code. In bottom-up programming, techniques present useful ways to construct parts of a program.

To be useful, the (usually procedural) meaning of a technique should be well defined, to enable the programmer to select a technique that is appropriate for the problem. For example, to implement an iterative design (an operation is to be performed on a set of data objects until some criterion is met), there are several possibilities. The iteration can be achieved using recursion or backtracking. A recursive solution is often the more attractive since it can be more efficient in terms of structure building. Within recursion, there are several possibilities, depe nding on the nature of the datastructure (e.g., linear/hierarchical) and the opera tion (e.g., aggregation/mapping/selection). A collection of well defined control structures would allow the programmer to select a structure for the program and would relieve him/her from the burden of designing one.

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 8 -->
All use subject to http://about.jstor.org/terms 4.2 Use for teaching

A set of such techniques would have uses in teaching Prolog, in that the process of acquiring techniques by experience, word-of-mouth, generalising from textbook examples and so on, could be by-passed.

A techniques compendium should be introduced only when learners have assimilated the basics of Prolog and are beginning to write their own programs. It might in fact be more suitable for newcomers to Prolog from another language than for complete novices for whom Prolog is their first programming language.

For teaching purposes, the description of a technique should be simplified as far as possible. A possible description outline would be:

- the code structure and/or an illustrative example;

- an account of what the technique does, both at a surface level (what output you

get for a given input), and at a deeper level (what happens during execution);

- an indication of how the technique could be generalised. This description format contrasts with that required for other purposes in that here the technique definition given in the description of the code structure must be simple enough for an inexperienced programmer to understand and use. The full generality of the technique is shown only in the final item, whereas for the pur poses described below, the technique definition must itself be as general as possible.

For example, the technique mentioned earlier of using accumulator pairs to build recursive data structures might be best described for teaching in terms of lists, with an indication under the last item of generalisations to other types of data structure, multiple recursion, and so on.

A techniques compendium should help inexperienced programmers to write Prolog programs more quickly and possibly with fewer errors. They should be encouraged to trace the execution of programs written using the techniques to make sure that the trace corresponds to the execution of the technique as described, rather than simply applying the technique uncritically. This will help them to learn the techniques and become familiar with them; the use of techniques can then be viewed as a structured way of gaining experience rather than the present haphazard process.

For newcomers to Prolog from other languages, the techniques compendium might have an additional advantage in helping them to write programs in a style appropriate to Prolog. The encouragement to look for situations in which techniques can be applied might for instance prevent them from designing a Pascal-like algorithm and attempting to code it directly into Prolog (van Someren, 1990).

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 9 -->
All use subject to http://about.jstor.org/terms 4.3 The use of techniques in intelligent teaching systems

Programming techniques might play an important rôle in an intelligent teaching system for Prolog. The student would be asked to perform tasks which either require or motivate the use of one or more techniques. The teaching system then seeks to tutor the student in when to apply a particular technique, how this is achieved in terms of the code, and what the consequences are.

A novice often constructs his/her program by applying a small number of programming techniques. The program analyser in the teaching system needs some way of recognising and analysing these programming techniques to explore the intent behind the program code.

To do this an automated teaching system requires some internal representation of techniques. A Prolog teaching system would find bugs in a student's program and attempt to relate the bugs to the incorrect conception or usage of a programm ing technique. Thus one dimension of the student model might be based on the student's understanding of the correct and appropriate use of programming techniques.

A program analyser intended for use as a component of a Prolog Intelligent Teaching System has been constructed. This program analyser, called APROPOS2, is described in this issue (Looi, 1991). The results of evaluating the performance of this program suggest that the approach taken by APROPOS2 in recognising Prolog programming techniques is viable.

4.4 Use in debugging tools

Here we consider briefly how we can extend the common static analysis of Prolog programs to include a check for correctly implemented techniques. We assume here that, in general, the programmer annotates the program with an assertion that a given predicate features certain specified techniques. This static checker is a technique recogniser which can detect discrepancies between the stated declarations about the intended techniques and the code itself.

failure_driven_loop: -

repeat,

```prolog
         read(X),
         write(X),nl,
         fail.
failure_driven_loop.
```

Figure 3. A non-terminating failure driven loop

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 10 -->
All use subject to http://about.jstor.org/terms

At the minimum, such a static program analyser can detect malformed techniques and query them. For example, it should detect a failure driven loop from which escape is impossible - see Figure 1 for an illustrative (if somewhat trivial) example of a failure driven loop and Figure 3 for an example of one that never terminates.

The scope of this approach will be restricted by the fact that some errors make the technique unrecognizable, e.g., dropping an argument may make a recursion undetectable. Possible solutions are:

- including a library of buggy techniques in the checker

- allowing the user to declare that a predicate uses a technique. More ambitiously, a dynamic debugger may use the presence of a technique, however detected, to cut down on information displayed, shrinking the call of a programming technique to a single leaf of the search tree. Brna et al. (1991) also consider the place of techniques within current Prolog debugging systems.

4.5 Use in program construction

If designers of logic programs (and students of logic programming) could work directly with higher-level techniques rather than with low-level programs, the entire design/edil/run/debug cycle could be significantly enhanced. For example, a designer could specify that something should be implemented as 'list construc tion in the head' rather than having to hand-code a clause which looks like the following:

**P(—[X I Xs]):-....P(...Xs)... (1)**

The abstracted representation of a technique (in schema form) represented by (1) raises several interesting questions about how techniques might be specified. For example, how do we specify which elements we really care about, and which ones we don't care about (as illustrated by the ellipsis dots above)? We discuss such representation issues in Section 7. The process of designing a 'techniques editor' forces us to come to grips with the pragmatics of technique-driven pro gram construction, and enables us to speculate about precisely how techniques might form part of a programming 'arsenal' (we refer to Gegg-Harrison, 1991, and Bundy et al., 1991, both this issue) for systems that embody some of the principles that underly the notion of a techniques editor).

**The concept of a techniques editor (henceforth TE) is related to the**

Programmer's Apprentice under development at MIT (Rich and Waters, 1978). The first fully working piece of software to emerge from the Programmer's Apprentice is called KBEmacs (Knowledge Based Emacs). A sample KBEmacs interaction, shown in Figure 4, highlights one type of interaction which might be possible in a TE.

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 11 -->
All use subject to http://about.jstor.org/terms

Programmer: Define a function DELETE which takes one parameter

**Apprentice: (defun delete (X)....)**

Programmer: Implement it as a trailing pointer list enumeration

**Apprentice: (defun delete (X)**

(cond ((null X) nil)

...<etc>

Figure 4. A sample interaction with the Programmer's Apprentice

The programmer types highly stylised English sentences into a text window (or selects key words and phrases from a menu), and the apprentice builds segments of code in another window. In the sample interaction in Figure 4, key words or phrases are shown italicised.

The main point of interest in this example is the key phrase 'trailing pointer list enumeration', which is one technique in the LISP programmer's arsenal. There are several important issues which would need to be addressed in the design of a TE. Several of these are outlined below:

- which techniques: what are the techniques, and which ones should be included

in the TE?

- access: should the techniques be accessed by menu, by key phrase, by icon, by

example, etc.

- grouping: should techniques be hierarchically clustered, so that some special

ised techniques co-occur within a larger cluster?

- methods of manipulation: should the designer/user interact with the TE via

abstractions, which involves using phrases such as 'double the number of

arguments', or with concrete 'direct manipulation interfaces', which involves

pointing directly to a 'typical argument' such as [al [b, c]] and moving it

around (or pulling it apart) on the screen to indicate the desired effect?

4.6 Use in language design

In a sense, formal definitions of techniques are a way of expanding the language. Some of them have already become a part of Prolog: for example, the technique of using "! , fail" to fail all clauses for a predicate has been concealed in not/1, as has that of collecting successive instantiations in the database in setof/3.

**The advantage of concealing procedural techniques in a declarative**

construction is obvious. Bundy (1988) provides some theoretical justification for particular examples.

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 12 -->
All use subject to http://about.jstor.org/terms 4.7 Use in learning to program

Novices, whether familiar or unfamiliar with other programming languages, have difficulty in making Prolog "do something". They find it extremely hard, for example, to understand how the declarative reading of append/3 (see below) achieves the intended, or indeed any, result.

```prolog
append([],L,L).
append([H I L1],L2,[H IL3]):
         append(Ll,L2,L3).
```

Part of this problem can be attributed to the problem that novices have in integrating their declarative understanding of a program with their procedural understanding. Another problem lies in the relative opacity of Prolog code in terms of the clues given by the syntax as to how the execution of Prolog is determined. A further problem lies in the difficulty novices have with writing recursive programs in any language (see Kahney, 1982).

Experts, on the other hand, are capable of choosing the most convenient way of viewing a Prolog program. They may choose between a variety of different semantics for Prolog according to their needs (not just the simple declarative and procedural descriptions found in introductory texts). They may also switch between levels of description - moving from a description of the code to discuss program behaviour in terms of Prolog implementational details (such as whether or not the particular dialect of Prolog uses structure sharing or structure copying). They may move from a theoretical analysis of the underlying computational complexity to a discussion as to how they can gain extra coding efficiency by switching arguments around (appealing, for instance, to some low level abstract machine). They can choose between different methods for coding a solution and justify their choice. They can recognise common structures in their code and see how to make use of these in a variety of ways.

The basic issue, however, is not to describe the ways in which the novice falls short of expert knowledge and behaviour, the problem is to change the novice. If some notion of technique is part of the equipment of the expert then we might hope that by teaching techniques explicitly we might be giving the novice a better chance of emulating the expert. We can see this process as forming more reliable, explicit programming plans.

Related work includes that by Soloway and his colleagues at Yale who made use of the notion of programming plans in their attempt to gain leverage on the problem of recognising and describing how novice Pascal programmers produce semantic errors in their code (Johnson and Soloway, 1985; Johnson, 1986; Spohrer et al., 1985). We regard Prolog programming techniques as related closely to that of the programming plans of Soloway et ai, but not identical. We do not believe that novices are necessarily aware of correct or buggy techniques

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 13 -->
All use subject to http://about.jstor.org/terms but we do believe that experts explicitly possess some notion of technique which they manipulate to their ends. Although Prolog does not possess the syntactic constructs that make it easy to detect the (correct or buggy) application of (correct or buggy) techniques we are persuaded that it offers an interesting domain within which to explore the notion of programming plans (Gilmore and Green, 1988).

A number of questions can be raised in relation to whether to include the teach ing of Prolog programming techniques as part of a Prolog course. These include:

- an extra burden: if students have trouble learning Prolog then will they not find

the additional burden of learning Prolog programming techniques to be

excessive?

- making the connection: if students already have problems making the connect

ion between the declarative reading and the procedural reading of their pro

grams then exactly how will Prolog programming techniques help them with

this problem?

- where do techniques fit? If we are going to introduce techniques into the teach

ing of Prolog in a more thorough way then where does this fit into the basic

curriculum for teaching Prolog?

- how abstract? Top level experts may make use of a very abstract representation

for techniques. For example, they may appeal to abstract mathematical theory

and may make use of complex and highly abstract operations to manipulate

techniques in suitable ways. Do we go for highly abstract descriptions of

techniques? Novices learn to code simple programming problems. In doing so, they may pick up either good or sub-optimal practice, although what is good practice can quite reasonably be regarded as dependent on the stage at which the student is at. If we see this procedure as a process of learning to chunk as, for example, found in Laird's notion of chunking (Laird et al., 1985) then the student is learning both a syntactic pattern observed in the code, the salient features in the context in which the chunk is found useful, and the general effect of using the chunk. Although we see the use of explicitly taught techniques as having something of a normative rôle in helping to avoid basic errors, we also appreciate the problem of trying to teach techniques as a separate activity from experience in coding.

This suggests that normal methods of teaching need to be supplemented with the help of some software tool. If, however, the tool enforces a normative view of techniques then we are almost back where we started. This picture invokes shades of Anderson's approach to tutoring LISP (Reiser et al., 1985). We believe that the greater need is to help the student: recognise successful and unsuccessful patterns; generalise and specialise patterns; and learn both when and when not to use them. If we do not adopt this approach then we run the risk that we do not help the student make the right connections between the structure of code chunks

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 14 -->
All use subject to http://about.jstor.org/terms (embodying Prolog techniques) and the function of the chunk. Students might well retain a kind of "magic" view of adapting code structure to attain their ends without a clear understanding of how these ends are really achieved (as per Kahney, 1982).

Given that we believe that the extra time needed to learn and practice techniques is worthwhile then we have to decide on both the techniques on which to focus and the instructional sequence which we would like to follow. This sequence has to be determined in part by the student's own experience with programming and Prolog (and any relevant disciplines such as mathematics).

Once we have chosen the techniques of interest, we have to choose example problems which can be used as the basis for extracting the description of the technique. We see this as educationally more desirable than the introduction of the technique followed by exemplars. The determination of the sequence is by no means trivial - even if there are only 40 or so fundamental techniques - as we have to allow for the composition of two or more techniques and various legitimate generalisations and specialisations. Our choices may tend towards:

• Specialised versions of techniques over more general versions

• Simplified methods of technique composition over more sophisticated methods

• Reducing the importance of efficiency issues in the first instance

• Making use of procedural versions of techniques over declarative versions

(where relevant). We prefer to make use of procedural intuitions in the learning path. Although top flight experts emphasise that it is possible to gain great computational and conceptual efficiency from adopting a declarative description of techniques (where possible), we would be surprised if novices found this to be an easy step.

Some preliminary attempt has been made to introduce the formal descriptions of techniques into Prolog courses at the Department of Artificial Intelligence, Edinburgh University. At this stage we have identified a number of issues.

We have found that students who were given the chance to practice the appli cation of techniques in small classes responded with interest. Typically, at the start of such a class they would have heard techniques described but not practised them. Again, typically, they would have great difficulty applying their knowledge to solve simple programming tasks.

In the first stages of writing simple programs students find it difficult to choose the appropriate technique. Students exposed to teaching about techniques also show signs that their buggy solutions to programming tasks can be interpreted in terms of the faulty composition of explicitly taught techniques.

Although these observations are informal, they are suggestive of the diffi culties to be found in incorporating techniques into a Prolog programming course without some form of software support.

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 15 -->
All use subject to http://about.jstor.org/terms

A prototype techniques editor has been built by Robertson at the Department of Artificial Intelligence, University of Edinburgh. This system is based on ideas from Kirschenbaum et al. (1989), see Section 8. Currently, this system provides a testbed for the exploration of the basic issues in helping novice programmers learn through and about techniques.

The prototype allows the student to introduce techniques one after the other. The student is provided with assistance in making various choices - which pred icate to define, which control structure to use, which modifications to use. If a dead end is reached or the student decides that he/she has made a mistake ihen the system can back up in a fairly simple manner to allow other paths to be explored.

The prototype has given us the foundation to develop a system which meets some of the educational requirements outlined above. At the moment, however, the approach to teaching Prolog via techniques is a simple one.

As part of our further work in this area, we seek to adapt this prototype further in order to produce a system that can be used productively to help novices learn Prolog. We then intend to map out the educational costs and benefits associated with the use of the techniques-based approach.

5 How do we find techniques?

Identifying Prolog programming techniques is a knowledge acquisition problem, similar to that for expert systems. Therefore, we make use of the same methods to obtain them (Breuker and Wielinga, 1985). Some programming techniques are described explicitly in textbooks on Prolog - such as Sterling and Shapiro, 1986. However, most techniques have never been formulated in textbooks, but are passed on from expert to student in apprentice situations. Other techniques are not even explicitly known to the expert, but can be qualified as implicit ("tacit") knowledge. These can to some extent be inferred from experts' behaviour and their products. We have made use of several sources for discovering the techniques which we have identified so far:

• Textbooks

• Interviews with experts (to collect explicitly known techniques)

• Analysis of expert's behaviour. The task at which the expert is observed can be

**designing or debugging a program. This observation can be simple**

observation, but it also possible to let an expert think aloud when s/he solves

programming problems and search the protocol for techniques. Other possibili

ties are to ask an expert afterwards how s/he has solved the problem. A different approach is to use special tasks that aim to show memory structures. This approach attempts to exploit the idea that programming techniques correspond to "chunks" of information in memory. If an expert uses the concept

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 16 -->
All use subject to http://about.jstor.org/terms "double recursion on the head and tail of a list", s/he could use it to remember partial programs, to reproduce them from memory, to describe them or to see meaningful similarities between programs. Examples of such tasks (adapted from psychological research) to study expertise in a variety of domains, are:

• Reconstructing a program from memory

• Copying a program by hand

• Summarising or describing a program

• Sorting a collection of programs (i.e., constructing a classification). A different way to analyse experts' behaviour is to analyse a collection of programs that were written by one or more experts, in order to identify structural patterns in the programs.

6 Illustrations of technique extraction methods

We now describe three methods we have used to extract information about tech niques taken from the set of methods outlined in Section 5. The work described here provided useful information that helped in the construction and formalisation of the various techniques identified.

We are aware, however, that much more work is needed in this area to identify, for example, the motivations that guide the development of code written by top level experts. Perhaps the most interesting and explicit exposition of tackling real programming problems by an expert has been provided by O'Keefe (see O'Keefe, 1988; O'Keefe, 1990). Another problem is the analysis of the path by which expertise is gained. Such longitudinal studies are difficult but useful.

6.1 Interviewing experts

One method we used to extract explicit Prolog expertise is the technique of mutual interviewing in the form of a brainstorming session with several Prolog experts.

This technique was applied in a small study at a workshop on Prolog at Cosener's House, Abingdon in February 1987. About ten Prolog experts (includ ing the authors of this paper) were present. The session yielded a collection of between 40 and 50 promising candidates for later analysis. Afterwards, we began to provide formal definitions of the techniques collected there. This resulted in the collection which is discussed in Section 3.

We add the caveat that the notion of expertise is not a simple one. There are several different dimensions along which a programmer might be judged to be an expert. For example, if we are interested in the teaching context then, realistically, teachers/lecturers have to communicate such expertise that they possess. In this

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 17 -->
All use subject to http://about.jstor.org/terms context, a further issue is the usability of an expert's knowledge: a novice may find little utility in an explanation as to why altering the order of arguments used by a procedure affects the efficiency of the code in a particular implementation of Prolog.

6.2 Interpreting programs

In another small study held at the same workshop on Prolog, we applied a semi structured interviewing technique to determine how good experienced Prolog programmers were at understanding Prolog code. The subjects were asked by Brna to explain what a given Prolog program actually does. The program, reproduced in Figure 5, is a genuine (and useful) Prolog program, with mnemonic predicate and argument names removed (the mode declaration was given as mode a(+, +, +, -)). It should be noted that the predicate a/4 is known as select/4 in Prolog code libraries. Its mode is usually given as mode select(?,?,?,?). We find, in the subject's report, that the procedural view implied by the mode declaration given helps to guide the search for an interpretation. A retrospective report was provided by the subject: "At first glance the program appears to be doing something to lists which have similar elements. For example, clause 1 could be used to identify that two lists (arguments 2 and 4) had identical tails. In fact, it could also tell you what their heads were, if arguments 1 and 3 were used as output variables. With all arguments as input, the program does something like this: if two lists (arguments 2 and 4) have identical tails, then succeed; otherwise, if the two lists (arguments 2 and 4) have identical heads, do whatever you were doing recursively on their tails. [Some examples were tried at this point.] I need to know what the mode declarations are. [I was told that declaration is: mode a(+, +, +, -)]• Aha ... argument 2 is being reconstructed in argument 4 when X (argument 1) is not the head of the list [clause 2] and X is just being replaced by Y when X does appear as the head of the list [clause 1], So the program substitutes X by Y at the first place it occurs in the list. Let's try it out. [More examples tried out here.] It will replace other occurrences of X on backtracking, but only one for each attempt."

```prolog
a(X, [XIT], Y, [YIT]).
a(X, [HIX1], Y, [HIY1]):
         a(X, XI, Y, Yl).
```

Figure 5. The program used for the sample protocol

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 18 -->
All use subject to http://about.jstor.org/terms There are several points to note about this account. Without the mode declarations, the subject does not get further than re-describing program elements, without being able to relate them. For example, a statement as "if the two lists (arguments 2 and 4) have identical tails, then succeed" is simply a partial transla tion of the first clause into English. Once the mode declarations were provided by the experimenter, the behaviour became clear within less than thirty seconds.

There is some shallow evidence that the mode declarations combined with patterns in the argument were recognised by the subject as the product of a technique, e.g., in the phrase "argument 2 is reconstructed in argument 4", which suggest recognition of the combination of two techniques (both destruction and construction in the head).

6.3 Sorting problems

Asking experts to sort problems into similar classes was used by Chi, Feltovich and Glaser (Chi et al., 1981) to compare experts' and novices' perception of prob lems (in this case from physics). Novices used primarily superficial similarity (e.g., the same objects appear in both problems, both involve a falling object) and experts used underlying physics principles that would be the basis of the solution. The experts classification was therefore more useful for solving the problems, because it turned out that experts can identify the principle to be used for the solu tion from the problem description (cf. deJong and Ferguson-Hessler, 1986; Ferguson-Hessler and deJong, 1987). The principles from physics correspond to programming techniques in the sense that they provide the basic structure of the solution around which the complete solution is built.

We replicated the experiment by Chi et al. with Prolog programming exercises (see van Someren, 1991, this issue, for some more details) and asked the experts (who in our case had limited experience, ranging from six months to two years) to explain the criteria that they used to put several problems together in one class. Many problems in our set involved list manipulation, which explains some of the categories. The criteria that were mentioned by the experts were:

• Backtracking (i.e., generate solutions by backtracking over a generator)

• Non-recursive (no recursion needed)

• Recursive, with as special cases:

- Double recursive

- Consider the whole list (as opposed to a program that may consider only part

of a list, e.g., member). These criteria can be contrasted with the criteria mentioned by at least two (out of six) novices: operations on numbers, counting, comparing, other operations (than the previous, grouped together) and creating a sublist.

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 19 -->
All use subject to http://about.jstor.org/terms

This experiment produced techniques that are similar to those of the brain sto rming session (Section 6.1). The selection of problems that is used for the sorting task is obviously important here. In our problem set, list manipulation problems were over-represented.

7 How should techniques be represented?

In order to use techniques in the ways outlined in Section 4 we need to represent them. Different uses call for different kinds of representation. For instance, explicit teaching of techniques can make use of an informal representation based on examples and English text, but a techniques-based editor calls for a more formal representation. The strongest demands for formality are made by auto matic technique recognisers which require a precise and exhaustive definition to enable them to recognise all correct variations of the techniques, but reject incorrect deviations. For instance, a technique-based editor can display the arguments of a procedure in an arbitrary order, but a techniques recogniser must be prepared to recognise the order chosen by the programmer.

Three modes of representation suggest themselves: prototypes, schemata and meta-language. A prototype is a Prolog program embodying the technique and, to avoid confusion, embodying as few other techniques as possible. This might be used in teaching accompanied by some English words to indicate the critical features and parts which can be generalised. For instance, to illustrate the use of accumulator pairs in construction of datastructures in the clause body one might use the procedure double!3 found in Figure 6. (We note that double!3 would be really useful only where we do not care about preserving the order of the doubled list elements. The result we get from applying double/3 is a list of doubled ele ments in the reverse order. This problem can make the use of accumulator pairs inappropriate.)

mode double(+, -).

mode double(+, +, -).

double(List,DoubledList): -

```prolog
         double(List,[] .DoubledList).
double([], Acc, Acc).
double([HHTl], Acc, Res):
         H2 is 2*H1,
         double(Tl, [H2IAcc], Res).
```

Figure 6. A prototype

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 20 -->
All use subject to http://about.jstor.org/terms

Noting that Acc in the second argument position in the second clause for double/3 is the accumulator and Res, the third argument position in the same clause, the result; that these have the same value in the base case in order that the accumulated datastructure should be passed back; and that the structure is built in the accumulator argument in the recursive call of double/3. This technique can be used for a wide variety of procedures with different recursive datastructures; addi tional recursive, accumulator and result arguments; and additional literals in the body, both recursive and non-recursive.

A schema is a generalised prototype: particular predicates, functions, variables, etc. are replaced with meta-variables and the potential of additional arguments, literals, etc. is indicated by ellipsis. For instance, a schema for the use of accumulator pairs in construction of datastructures in the clause body might be as shown in Figure 7.

Note that the technique here has been generalised in a number of ways - in particular, the datastructure over which recursion takes place has been generalised. Below, V is the base constructor for the datastructure (instead of '0'), and 'ïj' and '#2' are constructor functions - we have used only list constructor functions in the examples presented up to this point. (Note, however, that this schema could be generalised further. For example, the base case might not need to use the base constructor.)

Such a schema might be used in teaching to present the general idea of the technique to the student. It might also be used in a technique-based editor, being presented to the user for instantiation and modification. It is less useful for a technique recogniser. A pattern matcher might be used to match the schema to a particular program. However, a heavy burden is placed on this pattern matcher. It must be able to cope with different argument orders, extra arguments, extra literals, missing literals, etc. For this task a meta-language might be more suitable.

mode CDCB(...+,...+,

**mode MapH(...+,...)•**

CDCB(...1>, ...Accb, ...Accb).

CDCB(...t1(Hl,Tl), ...Accs, ...Res):

MapH(...Hl, ...H2,...)

CDCB(...T1, ...l2(H2,Accs),...Res).

Figure 7. A schema

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 21 -->
All use subject to http://about.jstor.org/terms

A meta-language is a language for describing the critical features of the technique. English was used for this task above in conjunction with the prototype. But English is too vague and ambiguous for the technique recogniser; for this a formal meta-language is required, e.g., one based on mathematical logic. However, a list in English of the key properties of the technique is a useful starting point for forming the logical meta-language. For instance, the key proper ties of the use of accumulator pairs for construction of datastructures in the clause body (CDCB) seem to be:

(a) There should be a recursive definition of the procedure, CDCB, with some

step and base clauses.

(b) CDCB should have some recursive, accumulator and result arguments. The

first two have mode + and the latter has mode

(c) The recursive argument contains a constructor function in the step head with

0 or more constructor parameters and 1 or more recursion variable

arguments. (Note that for [HIT] then the H is a constructor parameter and the

T is a recursion variable argument.) For each recursion variable argument, T,

there is an occurrence of CDCB in the step body with recursive argument, T.

(d) The accumulator argument should be a variable, Accs, in the step head and a

constructor function containing Accs in at least one of the recursive calls in

the step body. In the base clauses it should be Accb or some constructor

functions applied to Accb. The above suggests that the logical meta-language needs some standard pred icates/functions for identifying occurrences of subexpressions in expressions, e.g., expjitfExp,Posn) is the subexpression at position, Posn, in expression, Exp. For instance:

exp_at(double(Tl,[H2IAcc],Res),[2,l])=H2. where [2,1] indicates that we look at the 2nd argument of the principal functor and the 1st argument of this term. In addition we need some special predicates/ functions for identifying step/base clauses, recursive/accumulator/result arguments, and constructor parameter/recursion variable arguments e.g.,

arg_type(2, double)=accumulator. Inference in this meta-language could be used to derive properties of a program and check whether it fitted a technique definition. This inference would depend on rules like those found in Figure 8. Working out the details of this meta language is a major undertaking to be addressed in future work.

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 22 -->
All use subject to http://about.jstor.org/terms

mode (ArgJProc) = + &

step_head (Proc, SH) &

rec_call (Proc, RC) &

variable (exp_at (SH, [Arg])) &

constructor (exp_at (RC,[Arg]))

-> arg-type (Arg,Proc)=accumulator

Figure 8. Inference in the meta-language

8 Related work

Bundy describes an approach to the use of a techniques editor to build primitive recursive programs that are guaranteed to terminate and be well defined (Bundy et al., 1991). This system is aimed at providing a software engineering tool rather than an environment within which novices can learn Prolog. In general, most of the work done in this area is targeted at the production of software engineering tools which have interesting implications for the education of novice Prolog programmers. The general notion of a techniques editor has an application to most, if not all, programming languages.

Plummer, for example, has adopted a related cliché-based tool which is intended for use by experienced Prolog programmers (Plummer, 1990). His approach requires that clichés are defined in a way equivalent to a second order predicate logic form. The programmer has to specify how to instantiate the cliché. Kirschenbaum et al. are also exploring the notion of using techniques for program development (Kirschenbaum et al., 1989). They make claims that their approach can be applied to introductory courses and that this has been successful, although they do not appear to have produced a software tool yet. Their approach to pro gram development requires that a program 'skeleton' is selected which has the precise flow of control desired to solve the current programming task. The progr ammer then enhances the basic skeleton without altering the flow of control. The permitted enhancements are the application of the various techniques. If more than one technique is to be applied then the result of each application is produced and these results merged together.

From the educational approach, there must be some doubts about this approach of enforcing a split between control flow and 'enhancements' (techniques). The problem of choosing the correct control flow seems to have been sidestepped. This, however, is a major problem for all systems which seek to help students learn programming.

Perhaps the only current work other than our own that is aimed at the novice programmer is that of Gegg-Harrison who has designed a schema-based editor for list-processing tasks (Gegg-Harrison, 1991, this issue.) His system is a relative of the techniques-based editor which makes use of fourteen basic schemata for

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 23 -->
All use subject to http://about.jstor.org/terms manipulating a large number of list processing tasks. Gegg-Harrison intends the eventual construction of an Intelligent Teaching System for Prolog. Other work towards this end has been done by Looi (1991) but much more work needs to be done in this area.

In this section, we have concentrated mostly on related work in the area of the application of techniques to program construction. We have noted that others are interested in the issue of teaching techniques to novice Prolog programmers but that there is little evidence of the effectiveness of such schemes (other than anecdotal). Intelligent Teaching Systems for Prolog are still in their infancy.

It would appear that no one has yet applied the notion of techniques to support the debugging of programs. Nor, in relation to this idea, has there been any attempt to provide program visualisation tools that support this notion directly.

9 Conclusion

We have sought to justify the concept of a Prolog programming technique and show how the elaboration of the set of available techniques can be useful to programmers, to teachers of Prolog and in future Intelligent Tutoring Systems. Such techniques have also been found useful in extending the language.

We have also sought to indicate the way in which knowledge about techniques can be used in program construction and program debugging. Further theoretical work is needed to develop the necessary tools for supporting this.

In particular, we believe that a key factor is the development of a techniques editor. In order to develop such a system, we need to develop the work on techniques. This requires the extension of the range of known techniques using knowledge elicitation techniques, the refinement of the definitions of the techniques and their representation. Detailed work has been done on the concept of an editor for developing a class of well-founded recursive programs that can be guaranteed to terminate (Bundy et al., 1991). Further work related to that of Plummer, Kirschenbaum, and Gegg-Harrison has to be done to integrate the work on recursive programs with other techniques (Plummer, 1990; Gegg-Harrison, 1991; Kirschenbaum et al., 1989).

Given such a techniques editor we may then find that it plays a positive rôle in the education of novice Prolog programmers as well as aiding in the development of large scale Prolog programs.

Acknowledgements

We particularly thank the referees for their helpful and informative comments. This work was funded in part through the Alvey-funded workshop on Learning Prolog: tools and related issues at Cosener's House, Abingdon, during February 1987.

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

<!-- page 24 -->
All use subject to http://about.jstor.org/terms References

Breuker, J. A. and Wielings, B. J. (1985). KADS: structured knowledge acquisition for expert sys tems. In J. A. Breuker, Proceedings of the Fifth International Workshop on Expert Systems and their Applications, Avignon. Also: VF Memo 40, Department of Social Science Informatics, University of Amsterdam. Bma, P., Brayshaw, M., Bundy, A., Dodd, T., Elsom-Cook, M. and Fung, P. (1991). An overview of Prolog debugging tools. Instructional Science, this issue. Bundy, A. (1988). A broader interpretation of logic in logic programming. In A. Bundy, Proceedings of the Fifth International Logic Programming Conference/ Fifth Symposium on Logic Programming. Cambridge, MA: MIT Press. Bundy, A., Grosse, G. and Brna, P. (1991). A recursive techniques editor for Prolog. Instructional Science, this issue. Chi, M. T. H., Feltovich, P. J. and Glaser, R. (1981). Categorization and representation of physics problems by experts and novices. Cognitive Science, 5, 121-152. de Jong, T. and Ferguson-Hessler, M. G. M. (1986). Cognitive structures of good and poor novice problem solvers in physics. Journal of Educational Psychology, 78(4), 279-288, Ferguson-Hessler, M. G. M. and de Jong, T. (1987). On the quality of knowledge in the field of electricity and magnetism. American Journal of Physics, 55(6), 492-497. Gegg-Harrison, T. S. (1991). Learning Prolog in a schema-based environment. Instructional Science, this issue. Gilmore, D. J. and Green, T. R. (1988). Programming plans and programming expertise. Quarterly Journal of Experimental Psychology, 40, 423-442. Johnson, W. L. and Soloway, E. (1985). PROUST: knowledge-based program understanding. IEEE Transactions of Software Engineering, SE-11Q), 267-275. Johnson, W. L. (1986). Intention-based debugging of novice programming errors. London: Pitman. Kahney, H. (1982). An in-depth study of the cognitive behaviour of novice programmers. Unpublished Ph.D. thesis, Human Cognition Research Laboratory, The Open University, Milton Keynes, U.K. Kirschenbaum, M., Lakhotia, A. and Sterling, L. (1989). Skeletons and techniques for Prolog progr amming. TR 89-170, Case Western Reserve University. Laird, J. E., Rosenbloom, P. and Newell, A. (1985). Chunking in SOAR: the anatomy of a general learning mechanism. Research Report CMU-CS-85-154, Department of Computer Science, Camegie-Mellon University. Looi, C. K. (1991). Automatic debugging of Prolog programs in a Prolog Intelligent Tutoring System. Instructional Science, this issue. O'Keefe, R. A. (1988). Practical Prolog for real Prolog programmers. A tutorial given at the Fifth International Conference Symposium on Logic Programming, Seattle. O'Keefe, R.A. (1990). The craft of Prolog. Cambridge, MA: MIT Press. Plummer, D. (1990). Cliché programming in Prolog. In D. Plummer, Proceedings of the META-90 Workshop, META-90. Leuven, Belgium. Reiser, B. J., Anderson, J. R. and Farrell, R. G. (1985). Dynamic student modelling in an intelligent tutor for LISP programming. In A. Joshi (Ed.), Proceedings ofIJCAI-85, pp. 8-14. International Joint Conference on Artificial Intelligence, Los Altos, CA: Morgan Kaufman. Rich, C. and Waters, R. C. (1987). The Programmer's Apprentice: a program design scenario. AI Memo 933a, M. I. T. Artificisal Intelligence Laboratory, Cambridge, MA. Spohrer, J. C., Soloway, E. and Pope, E. (1985). A goal-plan analysis of buggy Pascal programs. Human-Computer Interaction, 1, 163-207. Sterling, L. and Lakhotia, A. (1988). Composing Prolog meta-interpreters. In R. A. Kowalski and K. A. Bowen (Eds.), Logic programming: Proceedings of the Fifth International Conference and Symposium, pp. 386-403, Cambridge, MA: MIT Press. Sterling, L. and Shapiro, E. Y. (1986). The art of Prolog. Cambridge, MA: MTT Press. van Someren, M. W. (1990). What's wrong? Understanding beginners' problems with Prolog. Instructional Science, 19(4/5), 257-282. Waters, R. C. (1985). KBEmacs: a step toward the Programmer's Apprentice. Technical Report 753, MIT Artificial Intelligence Laboratory, Cambridge, MA.

This content downloaded from 141.218.1.105 on Fri, 05 Aug 2016 06:26:02 UTC

All use subject to http://about.jstor.org/terms
