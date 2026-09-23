# 9. Prolog Dialects

<!-- page 257 -->
## 9.1 Prolog I

The idea of logic programming emerged in Marseilles in the ¿rst half of 1972 while Robert Kowalski was visiting the arti¿cial intelligence team founded by Alain Colmerauer at the University of Marseilles. Colmerauer with his team prepared the design speci¿cation of the programming language Prolog (Colmerauer et al. 1972). The language resembled a theorem prover rather closely, but it already possessed the essential properties of contemporary Prolog, and even some features reintroduced quite recently, e.g. delaying calls till appropriate instantiation of their arguments. Almost at the same time Kowalski advocated predicate calculus as a formalism for expressing algorithms without commitment to a speci¿c strategy of their execution; the short note (1972) was later expanded to a larger paper (1974). Hence the two pioneers of logic programming took from the outset different approaches to the problem of changing the idea into reality. Although developed in close interaction, these different attitudes still manifest themselves in logic programming research.

The language described in Colmerauer et al. (1972) was implemented in Algol W on IBM 360/67 by Philippe Roussel and used at once in several applications (Colmerauer et al. 1973, Pasero I973, Kanoui I973, Joubert I974; Bergman and Kanoui I973, 1975. Battani and Méloni 1975. Guizol 1975). It was quickly replaced by an improved version. coded partly in Fortran by Battani and Méloni (I973) and partly in Prolog by Colmerauer and Roussel. This was the ¿rst version of Prolog used outside Marseilles. Although not christened so by its authors, it deserves the name of Prolog I. especially as its commonly used name “Marseille Prolog" has become ambiguous.

<!-- page 258 -->
' This chapter was contributed by Janusz S. Bien, Institute of Informatics, Warsaw University, Warsaw. Poland.

The original reference to Prolog I is Roussel (1975); some historical infonnation can be found in Battani and Méloni (1973) and l(Iu2niak (1984). The syntax of the language is illustrated below by the sample clauses:

+APPEND( NIL, -I-X, -I-X ).

+APPEND( -1-X.-1-Y, -I-Z, -1-X.-1-V ) —APPEND( -1-Y, -1-Z, -1-V ). This should be preceded by the decimation of the in¿x dot:

—AJOP(

1, "X'( X‘X )“ )! And a sample directive (SORT means write):

—APPEND( A.B.NIL, C.NIL, -I-X ) —SORT( -I-X ) —LIGNE! Positive literals (see Chapter 2) are preceded with + , negative with —; the notation allows representation of non-Hom clauses. This was a natural requirement, because the early versions of Prolog were intended to implement a general theorem-proving method known as linear resolution with selection function (Kowalski and Kuehner 1971). Program clauses were distinguished from directives by a different tenninator. The syntax survived its original motivation and is still used in some versions of the language (Kluiniak and Szpakowicz 1983).

## 9.2 Prolog II

After Prolog I was released, Colmerauer’s team experimented with various mutations of the language; some of them have been described in Guizol and Méloni (I976), Colmerauer er al. (1979) and Kanoui and Van Caneghem (1980). Finally it was announced that the goal of creating “the ultimate Prolog” was achieved (Colmerauer et al. 1981). The new language was called Prolog II by its authors (Colmerauer

1982, Van Caneghem I982, Kanoui I982).

<!-- page 259 -->
The most important innovation of Prolog II is the treatment of cyclic data structures (see Section 1.2.3). They are simply valid representations of in¿nite trees, which can be manipulated in a similar way to other terms (Colmerauer 1979, 1982). However, the same in¿nite tree can be represented by different data stnrctures; to let them be matched correctly it appeared necessary to treat functors in the sameway as arguments (Filgueiras I982). As a result, a functor can be a variable or a compound term. In Prolog II, the standard form of terms is considered just a shorthand notation for a more general form called tuple. For example, ff(x) stands for <ff, x>, while <x, y> and <<ff(x)>, y> are also legal terms (singleletter names denote variables, ff is a constant). Instead of unifying two tuples, Prolog II constructs a system of equations. For example, matching <x> with <ff(x)> corresponds to solving in x the equation

**x=ff(x).**

The solution of this equation is the in¿nite tree ff(ff(ff(...))), which is represented by an appropriate cyclic data structure.

The behavior of Prolog programs is described as incremental solving of the system of equations introduced by program clauses, which can also be seen as rewriting rules. The execution of a call is viewed as the operation of erasing it by applying the rules and solving the appropriate equations. This viewpoint manifests itself in the syntax of clauses by an arrow leading from the head to the (possibly empty) body, e.g.

0000001 nil. x. X )—>;

0000001 X-Y. z. x.v )—> 0000001 Y. z. v ) ; This approach makes it possible to describe the principles of Prolog II in a compact and self-contained way, relieved from the references to theoremproving techniques and relying only on the most fundamental and intuitive notions of logic (Colmerauer I983).

Prolog II offers a simple yet powerful coroutining mechanism (see Chapter 2). A call may require its parameter to be instantiated. Given a variable, it waits for it to become bound. This is achieved by the b_uilt-in procedure geler (“freeze”), whose ¿rst argument is a “trigger” (usually a variable to be bound) and the second a call (to be delayed). If the “trigger” is already bound, geler simply executes the call.

Another coroutining primitive is drf, which succeeds if its parameters are not “perfectly” equal (see the built-in procedure = =, Section 5.6). If during the execution of dif(“down the tenns’ structure") a variable is encountered, dif waits until it becomes bound and only then resumes the comparison.

The coroutining mechanism will be illustrated by two examples adapted from Colmerauer et al. (I983). The ¿rst example is a procedure that takes two trees represented as deeply nested dotted list structures. It succeeds when both structures can be Àattened to the same linear list. A built-in procedure ident is used to check whether the argument is a constant.

```prolog
sameleaves( a, b ) —> leaves( a, u ) leaves( b, u ) Iist( u );
leaves( a, u )—> geler( u, leavesl( a, u ) );
```

<!-- page 260 -->
```prolog
leavesl( a, a.nil ) —> ident( a );
leavesl( a.l, a.u )—> ident( a) leaves( I, u );
leavesl( ( a.b ).l. u )—> leavesl( a.b.l, u );
Iist( nil )—>;
Iist( a.u )—> Iist( u );
```

The second example is a procedure that generates a list of digits 1, 2, 3 such that all three elements are different.

```prolog
perm( x.y.z.nil )—> alldifferent( x.y.z.nil )
                  alldigits( x.y.z.nil );
alldigits( nil ) —>;
alldigits( x.l )—> digit( x ) alldigits( I );
digit( I ) —>; digit( 2 )—>; digit( 3 )—>;
alldifferent( nil ) —>;
alldifferent( x.l )—> outside( x, I ) alldifferent( I );
outside( x, nil );
outside( x, y.l )—> dif( x. y ) outside( x, I );
```

Prolog II supports a kind of modularisation implemented by so-called “worlds”, each with a unique name. Worlds are organised into a tree structure. The root is the world “origine”, which has two subworlds “ordinaire” and “?????”. Subworlds of “ordinaire” (which is the default) can be created by the user who can walk up and down the tree, and also create and discard worlds. “?????” contains the Prolog II supervisor and cannot be used as the current world. Every procedure name is associated with the world in which it was ¿rst mentioned (“declared”). It is accessible in this world and its descendants but not in its siblings. Moreover, a name N and the same name N declared in a superworld later on refer to different procedures.

Clauses are available for all manipulations (including initial de¿nition) only in the world where the procedure name has been declared and in its direct subworlds. For example, standard procedure names are introduced in “origine”—with clauses de¿ned in “?????”—and used in “ordinaire”. So. the user cannot change a standard procedure de¿nition. Clause indexing is provided. or rather tuple indexing. The leftmost name in the tuple is used as a key.

The purpose of Toy‘s tag, tagexit etc. (see Section 5.12) is served in Prolog ll by a pair of built-in procedures bloc. ¿n-bloc. In the call bloc-(l,

<!-- page 261 -->
t), t is the call to be executed in the block. When. during the execution of t, a call of the form ¿n-bloc-(ll) is encountered, the most recent call on bloc(l, t) with l uni¿able with ll is sought. If none is found. an error condition is raised, else this call on bloc succeeds deterministically. This feature is used for error handling and for exiting loops.

**We have presented here only some of the Prolog ll features, and the**

interested reader is referred to Colmerauer er al. (1983). It is interesting that the pilot implementation of Prolog ll which is described here was done on an Apple ll microcomputer using software paging on Àoppy disks.

## 9.3 Micro-Prolog and MPROLOG

micro-Prolog is the dialect used by l(owalski‘s team at Imperial College of Science and Technology in London. micro-Prolog was developed and implemented by McCabe (I981); his main goal was to install Prolog on a cheap 8-bit microcomputer. micro-Prolog uses lists to represent terms. calls and clauses. e.g.

**((APP00d()xx))**

**((APP00d(X|X)Y(X|Z))(APP00¢1XYZ))**

The list notation has several advantages: predicates and functors need not have a ¿xed number of arguments (i.e. the whole argument list can be bound to a single variable); their names can be arbitrary list structures (for technical reasons this is not allowed for predicates). micro-Prolog also supports a simple form of modularity: modules are created dynamically and the accessibility of names is detennined by export/import lists.

A typical user is not expected to interact directly with micro-Prolog, because a special front-end called Simple is provided to conceal the lowlevel language features. Here is the append example in the Simple syntax:

**A000nd(()xx)**

Append((x|X)Y(x|Z))ifAppend(XYZ) Simple was used as a computer language for children; other interesting applications are expert systems. The language is subject to various experiments and extensions. such as an explanation facility or an original form of input/output operations called query-the-user (Sergot I982); Simple and other extensions are all written in micro-Prolog. Both micro-Prolog and some of its applications are extensively documented in Ennals (I983) and Clark and McCabe (I984).

<!-- page 262 -->
MPROLOG was developed at the Institute for Co-ordination of Computer Techniques. in Budapest (Bendl et al. 1980, SzKl 1982), using the programming language CDL2 (Koster 1974). MPROLOG is an upwardcompatible extension of Prolog-10, intended for creating production software for mainframe computers. The crucial extension consists in introducing a form of modularity, based on the ideas of Szeredi (1982) and similar in spirit to that found in many other languages. The modules are syntactic units and contain explicit export/import lists detennining the visibility (i.e. the accessibility) of names; a visible name can serve as a functor or as a predicate name. When a program is entered, only the main module is loaded and executed; other modules must be loaded explicitly by calling appropriate built-in procedures.

MPROLOG is a large system which includes several components. The pretranslator produces an intemal form of a program module; the consolidator links the modules into a program; the interpreter executes it. The program development support system (PDSS) provides a dedicated editor and debugging aids. A compiler and an optimizer are under development. The language offers a multitude of built-in procedures (probably more than any other Prolog system) and interfaces to user-supplied procedures written in CDL2 and Fortran.
