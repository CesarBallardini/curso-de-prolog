# 1 Basic Constructs

<!-- page 52 -->
The basic constructs of logic programming, terms and statements, are inherited from logic. There are three basic statements: facts, rules, and queries. There is a single data structure: the logical term.

**Li Facts**

The simplest kind of statement is called a fact. Facts are a means of stating that a relation holds between objects. An example is father(abrahani,isaac). This fact says that Abraham is the father of Isaac, or that the relation f ather holds between the individuals named abraham and isaac. Another name for a relation is a predicate. Names of individuals are known as atoms. Similarly, plus(2,3,5) expresses the relation that 2 plus 3 is 5. The familiar plus relation can be realized via a set of facts that defines the addition table. An initial segment of the table is plus(O,O,O).

```prolog
plus(O,1,1).
                  plus(O,2,2).
                                   plus(O,3,3).
```

plus(1,O,1).

```prolog
plus(1,1,2).
                  plus(1,2,3).
                                   plus(1,3,4).
```

A sufficiently large segment of this table, which happens to be also a legal logic program, will be assumed as the definition of the plus relation throughout this chapter.

<!-- page 53 -->
The syntactic conventions used throughout the book are introduced as needed. The first is the case convention. It is significant that the names

```prolog
father(terach,abraham).
                             male(terach).
father (terach,nachor).
                             male (abraham).
father (terach,haran).
                             male (nachor).
f ather(abraham,isaac).
                             male (haran).
father (haran,lot).
                             male(isaac).
father (haran,milcah).
                             male (lot).
father(haran,yiscah).
                             female(sarah).
mother(sarah,isaac).
                             female (milcah).
                             female(yiscah).
```

Program 1.1 A biblical family database

of both predicates and atoms in facts begin with a lowercase letter rather than an uppercase letter.

A finite set of facts constitutes a program. This is the simplest form of logic program. A set of facts is also a description of a situation. This insight is the basis of database programming, to be discussed in the next chapter. An example database of family relationships from the Bible is given as Program 1.1. The predicates `father, mother, male,` and `female` express the obvious relationships.

1.2 Queries The second form of statement in a logic program is a query. Queries are a means of retrieving information from a logic program. A query asks whether a certain relation holds between objects. For example, the query `father (abraham, isaac)?` asks whether the `father` relationship holds between `abraham` and `isaac.` Given the facts of Program 1.1, the answer to this query is yes.

Syntactically, queries and facts look the same, but they can be distinguished by the context. When there is a possibility of confusion, a term!nating period will indicate a fact, while a terminating question mark will indicate a query. We call the entity without the period or question mark a goal. A fact P. states that the goal P is true. A query P? asks whether the goal P is true. A simple query consists of a single goal.

<!-- page 54 -->
Answering a query with respect to a program is determining whether the query is a logical consequence of the program. We define logical consequence incrementally through this chapter. Logical consequences are obtained by applying deduction rules. The simplest rule of deduction is identity: from P deduce P. A query is a logical consequence of an identical fact.

Operationally, answermg simple queries using a program containing facts like Program 1.1 is straightforward. Search for a fact in the program that implies the query. If a fact identical to the query is found, the answer is yes.

The answer no is given if a fact identical to the query is not found, because the fact is not a logical consequence of the program. This answer does not reflect on the truth of the query; it merely says that we failed to prove the query from the program. Both the queries `f emale(abrahazn)?` and plus(1 ,1,2)? will be answered no with respect to Program 1.1.

1.3 The Logical Variable, Substitutions, and Instances A logical variable stands for an unspecified individual and is used accordingly. Consider its use in queries. Suppose we want to know of whom `abraham` is the father. One way is to ask a series of queries,

```prolog
father(abraham,lot)?,
                          father(abraham,milcah)?, ...,
                                                            father
(abraham,isaac)?,. .
```

`.` until an answer yes is given. A variable allows a better way of expressing the query as `f ather(abraham,X)?,` to which the answer is `X=isaac.` Used in this way, variables are a means of summarizing many queries. A query containing a variable asks whether there is a value for the variable that makes the query a logical consequence of the program, as explained later.

Variables in logic programs behave differently from variables in conventional programming languages. They stand for an unspecified but single entity rather than for a store location in memory.

<!-- page 55 -->
Having introduced variables, we can define a term, the single data structure ¡ii logic programs. The definition is inductive. Constants and variables are terms. Also compound terms, or structures, are terms. A compound term comprises a functor (called the principal functor of the term) and a sequence of one or more arguments, which are terms. A functor is characterized by its name, which is an atom, and its arity, or number of arguments. Syntactically, compound terms have the form f(t1,t2,. . .,t), where the functor has name f and is of arity n, and the t are the arguments. Examples of compound terms include

```prolog
s(0), hot(milk), name(john,doe), list(a,list(b,nil)), foo(X), and
tree(tree(nil,3,nil) ,5,R).
```

Queries, goals, and more generally terms where variables do not occur are called ground. Where variables do occur, they are called nonground. For example, `f oo (a, b)` is ground, whereas `bar (X)` is nonground. Definition A substitution is a finite set (possibly empty) of pairs of the form X = t, where X is a variable and t is a term, and X

X1 for every i

j, and X does not occur in t1, for any i and j.

**.**

An example of a substitution consisting of a single pair is `{X=isaac}.` Substitutions can be applied to terms. The result of applying a substitution G to a term A, denoted by AO, is the term obtained by replacing every occurrence of X by t in A, for every pair X = t in O.

The result of applying `{X=isaac}` to the term `f ather(abraham,X)` is

```prolog
the term father(abrahani,isaac).
```

Definition A is an instance of B if there is a substitution O such that A = BO.

**.**

The goal `f ather(abraham,isaac)` is an instance of `father (abraham,` `X)` by this definition. Similarly, `mother(sarah, isaac)` is an instance of `mother(X,Y)` under the substitution `{X=sarah,Y=isaac}.`

1.4 Existential Queries Logically speaking, variables in queries are existentially quantified, which means, intuitively, that the query `father (abraham, X)?` reads: "Does there exist an X such that `abraham` is the father of X?" More generally, a query p(T1,T2,. . .,T)?, which contains the variables X1,X2,. . .,Xk reads: "Are there X1,X2,. . .,Xk such that p(T1,T2,. . .,T)?" For convenience, existential quantification is usually omitted.

The next deduction rule we introduce is generalization. An existential query P is a logical consequence of an instance of it, PO, for any substitution 6. The fact `f ather(abraham, isaac)` implies that there exists an X

```prolog
such that f ather(abraham,X) is true, namely, X=isaac.
```

<!-- page 56 -->
Operationally, to answer a nonground query using a program of facts, search for a fact that is an instance of the query. If found, the answer, or solution, is that instance. A solution is represented in this chapter by the substitution that, if applied to the query, results in the solution. The answer is no if there is no suitable fact in the program.

In general, an existential query may have several solutions. Program 1.1 shows that Haran is the father of three children. Thus the query `father (haran,X)?` has the solutions `(X=lot}, {X=milcah}, {X=yiscah}.` Another query with multiple solutions is plus (X, Y, 4)? for finding numbers that add up to 4. Solutions are, for example, {X=O, Y=4} and {X=1, Y=3}. Note that the different variables X and Y correspond to (possibly) different objects.

An interesting variant of the last query is plus(X,X,4)?, which insists that the two numbers that add up to 4 be the same. It has a unique answer {X=2}.

**LS Universal Facts**

Variables are also useful in facts. Suppose that all the biblical characters like pomegranates. Instead of including in the program an appropriate fact for every individual,

```prolog
likes(abraham,pomegranates).
likes(sarah,pomegranates).
```

a fact `likes (X,pomegranates)` can say it all. Used in this way, variables are a means of summarizing many facts. The fact `tirnes(O,X,O)` summarizes all the facts stating that o times some number is O.

Variables in facts are implicitly universally quantified, which means, intuitively, that the fact `likes(X,pomegranates)` states that for all X, X likes `pomegranates.` In general, a fact p(T1,. . .,T) reads that for all X1,. . `.,Xk,` where the X1 are variables occurring in the fact, p(T1,. . is true. Logically, from a universally quantified fact one can deduce any instance of it. For example, from `likes(X,poniegranates),` deduce

```prolog
likes (abraham, pomegranates).
```

<!-- page 57 -->
This is the third deduction rule, called instantiation. From a universally quantified statement P, deduce an instance of it, PO, for any substitution 0.

As for queries, two unspecified objects, denoted by variables, can be constrained to be the same by using the same variable name. The fact plus (0, X, X) expresses that O is a left identity for addition. It reads that for all values of X, O plus X is X. A similar use occurs when translating the English statement "Everybody likes himself" to `likes (X, X).`

Answering a ground query with a universally quantified fact is straightforward. Search for a fact for which the query is an instance. For example, the answer to plus(0,2,2)? is yes, based on the fact plus(0,X,X). Answering a nonground query using a nonground fact involves a new definition: a common instance of two terms. Definition C is a common instance of A and B if it is an instance of A and an instance of B, in other words, if there are substitutions 0 and 02 such that C=A01 is syntactically identical to BO2.

For example, the goals `plus(0,3,Y)` and plus(0,X,X) have a common instance `plus (0,3,3).` When the substitution

`{Y=3}` is applied to `plus (0,3, Y)` and the substitution `{X=3}` is applied to `plus (0, X, X),` both

```prolog
yield plus(0,3,3).
```

In general, to answer a query using a fact, search for a common instance of the query and fact. The answer is the common instance, if one exists. Otherwise the answer is no.

Answering an existential query with a universal fact using a common instance involves two logical deductions. The instance is deduced from the fact by the rule of instantiation, and the query is deduced from the instance by the rule of generalization.

<!-- page 58 -->
1.6 Conjunctive Queries and Shared Variables An important extension to the queries discussed so far is conjunctive queries. Conjunctive queries are a conjunction of goals posed as a query, for example, `f ather(terach,X) ,father(X,Y)?` or in general, Q,. . Simple queries are a special case of conjunctive queries when there is a single goal. Logically, it asks whether a conjunction is deducible from the program. We use '," throughout to denote logical and. Do not confuse the comma that separates the arguments in a goal with commas used to separate goals, denoting conjunction.

In the simplest conjunctive queries all the goals are ground, for example, `f ather(abraham,isaac) ,male(lot)?.` The answer to this query using Program 1.1 is clearly yes because both goals in the query are facts in the program. In general, the query Q,. .,Q,?, where each Q is a ground goal, is answered yes with respect to a program P if each Q is implied by P. Hence ground conjunctive queries are not very interesting.

Conjunctive queries are interesting when there are one or more shared variables, variables that occur in two different goals of the query. An example is the query `f ather(haran,X) ,male(X)?.` The scope of a variable in a conjunctive query, as in a simple query, is the whole conjunction. Thus the query p(X),q(X)? reads: "Is there an X such that both p(X) and

Shared variables are used as a means of constraining a simple query by restricting the range of a variable. We have already seen an example with the query plus (X , X, 4)?, where the solution of numbers adding up to 4 was restricted to the numbers being the same. Consider the query

`f ather(harari,X) ,male(X)?.` Here solutions to the query

```prolog
f a-
```

`ther(haran,X)?` are restricted to children that are male. Program 1.1 shows there is only one solution, `{X1ot}.` Alternatively, this query can be viewed as restricting solutions to the query `male (X)?` to individuals who have Haran for a father.

A slightly different use of a shared variable can be seen in the query `father (terach,X) ,father(X,Y)?.` On the one hand, it restricts the sons of `terach` to those who are themselves fathers. On the other hand, it considers individuals Y, whose fathers are sons of `terach.` There are several

```prolog
solutions, for example, (Xabrahain, Y=isaac J and {X=haran, Y=lot J.
```

A conjunctive query is a logical consequence of a program P if all the goals in the conjunction are consequences of P, where shared variables are instantiated to the same values in different goals. A sufficient condition is that there be a ground instance of the query that is a consequence of P. This instance then deduces the conjuncts in the query via generalization.

<!-- page 59 -->
The restriction to ground instances is unnecessary and will be lifted in Chapter 4 when we discuss the computation model of logic programs. We employ this restriction in the meantime to simplify the discussion in the coming sections.

Operationally, to solve the conjunctive query A1,A2 ,...,A? using a program P, find a substitution O such that A10 and.. . and AO are ground instances of facts in P. The same substitution applied to all the goals ensures that instances of variables are common throughout the query. For example, consider the query f ather(haran,X) ,male(X)? with respect to Program 1.1. Applying the substitution {X=lot} to the query gives the ground instance father (haran,lot) ,male (lot)?, which is a consequence of the program.

1.7 Rules Interesting conjunctive queries are defining relationships in their own right. The query father (haran,X) ,male(X)? is asking for a son of Haran. The query father(terach,X) ,father(X,Y)? is asking about grandchildren of Terach. This brings us to the third and most important statement in logic programming, a rule, which enables us to define new relationships in terms of existing relationships.

Rules are statements of the form: A - B1,B2,. . where n

O. The goal A is the head of the rule, and the conjunction of goals B1,. . .,B is the body of the rule. Rules, facts, and queries are also called Horn clauses, or clauses for short. Note that a fact is just a special case of a rule when n = O. Facts are also called unit clauses. We also have a special name for clauses with one goal in the body, namely, when n = 1. Such a clause is called an iterative clause. As for facts, variables appearing in rules are universally quantified, and their scope is the whole rule.

A rule expressing the son relationship is

```prolog
son(X,Y) - father(Y,X), male(X).
```

Similarly one can define a rule for the daughter relationship:

```prolog
daughter(X,Y) - father(Y,X), female(X).
```

<!-- page 60 -->
A rule for the `grandfather` relationship is

```prolog
grandfather(X,Y)
                      father(X,Z), father(Z,Y).
```

Rules can be viewed in two ways. First, they are a means of expressing new or complex queries in terms of simple queries. A query `son(X,haran)?` to the program that contains the preceding rule for son is translated to the query `f ather(haran,X) ,male(X)?` according to the rule, and solved as before. A new query about the son relationship has been built from simple queries involving `father` and `male` relationships. Interpreting rules in this way is their procedural reading. The procedural reading for the `grandfather` rule is: "To answer a query is X the grandfather of Y?, answer the conjunctive query Is X the father of Z and Z the father of Y?."

The second view of rules comes from interpreting the rule as a logical axiom. The backward arrow is used to denote logical implication. The son rule reads: "X is a son of Y if Y is the father of X and X is male." In this view, rules are a means of defining new or complex relationships using other, simpler relationships. The predicate son has been defined in terms of the predicates `father` and `male.` The associated reading of the rule is known as the declarative reading. The declarative reading of the `grandfather` rule is: "For all X, Y, and Z, X is the grandfather of Y if X is the father of Z and Z is the father of Y."

Although formally all variables in a clause are universally quantified, we will sometimes refer to variables that occur `in` the body of the clause, but not in its head, as if they are existentially quantified inside the body. For example, the `grandfather` rule can be read: "For all X and Y, X is the grandfather of Y if there exists a Z such that X is the father of Z and Z is the father of Y." The formal justification of this verbal transformation will not be given, and we treat it just as a convenience. Whenever it is a source of confusion, the reader can resort back to the formal reading of a clause, in which all variables are universally quantified from the outside.

To incorporate rules into our framework of logical deduction, we need the law of modus ponens. Modus ponens states that from B and A

<!-- page 61 -->
B we can deduce A, Definition The law of universal modus ponens says that from the rule R = (A - B1,B2,. . and the facts B. B.

**B.**

A' can be deduced if A' - B'1,B,. . is an instance of R.

Universal modus ponens includes identity and instantiation as special cases.

We are now in a position to give a complete definition of the concept of a logic program and of its associated concept of logical consequence. Definition A logic program is a finite set of rules. Definition An existentially quantified goal G is a logical consequence of a program P if there is a clause in P with a ground instance A - B1,. . . ,B, n

O such that B1.....B are logical consequences of P, and A is an instance of G. .

Note that the goal G is a logical consequence of a program P if and only if G can be deduced from P by a finite number of applications of the rule of universal modus pollens.

Consider the query son (S, haran)? with respect to Program 1.1 augmented by the rule for son. The substitution {X=lot , Y=haran} applied to the rule gives the instance son(lot,haran) f ather(haran,lot), male(lot). Both the goals in the body of this rule are facts in Program 1.1. Thus universal modus ponens implies the query with answer {S=lot}.

<!-- page 62 -->
Operationally, answering queries reflects the definition of logical consequence. Guess a ground instance of a goal, and a ground instance of a rule, and recursively answer the conjunctive query corresponding to the body of that rule. To solve a goal A with program P, choose a rule A1 B1,B2,. . .,B in P, and guess substitution O such that A = A10, and BO is ground for i

í

n. Then recursively solve each BLO. This procedure can involve arbitrarily long chains of reasoning. lt is difficult in general to guess the correct ground instance and to choose the right rule. We show in Chapter 4 how the guessing of an instance can be removed.

The rule given for `son` is correct but is an incomplete specification of the relationship. For example, we cannot conclude that Isaac is the son of Sarah. What is missing is that a child can be the son of a mother as well as the son of a father. A new rule expressing this relationship can be added, namely,

```prolog
son(X,Y) - niother(Y,X), male(X).
```

To define the relationship `grandparent` correctly would take four rules to include both cases of `father` and `mother:`

```prolog
grandparent (X, Y)
                                              Y).
                                    father(Z,
grandparent (X ,Y)
                                    mother (Z
                                              Y).
grandparent (X, Y)
                                              Y).
                                    father(Z,
grandparent (X ,Y)
                                    mother (Z
                                              Y).
                   - father(X,Z)
                   - father(X,Z)
                   - mother(X,Z)
                   - mother(X,Z)
```

There is a better, more compact, way of expressing these rules. We need to define the auxiliary relationship `parent` as being a father or a mother. Part of the art of logic programming is deciding on what intermediate predicates to define to achieve a complete, elegant axiomatization of a relationship. The rules defining `parent` are straightforward, capturing the definition of a parent being a father or a mother. Logic programs can incorporate alternative definitions, or more technically disjunction, by having alternative rules, as for `parent:`

```prolog
parent(X,Y) - f ather(X,Y).
parent(X,Y)
                mother(X,Y).
```

Rules for `son` and `grandparent` are now, respectively,

```prolog
son(X,Y) - parent(Y,X), male(X).
grandparent(X,Y) - parent(X,Z), parent(Z,Y).
```

<!-- page 63 -->
A collection of rules with the same predicate in the head, such as the pair of parent rules, is called a procedure. We shall see later that under the operational interpretation of these rules by Prolog, such a collection of rules is indeed the analogue of procedures or subroutines in conventional programming languages, 1.8 A Simple Abstract Interpreter An operational procedure for answering queries has been informally described and progressively developed in the previous sections. In this section, the details are fleshed out into an abstract interpreter for logic programs. In keeping with the restriction of universal modus ponens to ground goals, the interpreter only answers ground queries.

The abstract interpreter performs yes/no computations. It takes as input a program and a goal, and answers yes if the goal is a logical consequence of the program and no otherwise. The interpreter is given in Figure 1.1. Note that the interpreter may fail to terminate if the goal is not deducible from the program, in which case no answer is given.

The current, usually conjunctive, goal at any stage of the computation is called the resolvent. A trace of the interpreter is the sequence of resolvents produced during the computation. Figure 1.2 is a trace of answering the query son(1ot,harn)? with respect to Program 1.2, a subset of the facts of Program 1.1 together with rules defining son and daughter. For clarity, Figure 1.2 also explicitly states the choice of goal and clause made at each iteration of the abstract interpreter.

Each iteration of the while loop of the abstract interpreter corresponds to a single application of modus ponens. This is called a reduction.

A ground goal G and a program P Input:

yes if G is a logical consequence of P, Output:

no otherwise

Initialize the resolvent to G. Algorithm

while the resolvent is not empty do

choose a goal A from the resolvent

choose a ground instance of a clause A' B1.....B,, from P

such that A and A' are identical

(if no such goal and clause exist, exit the while loop)

replace A by B1.....B,, in the resolvent

<!-- page 64 -->
If the resolvent is empty, then output yes, else output no. Figure 1.1 An abstract interpreter to answer ground queries with respect to logic programs

```prolog
Input:
          sori(lot,haran)? and Program L2
          Resolvent is son(lot ,haran)
```

Resolvent is not empty

```prolog
choose son(lot,haran)
```

(the only choice)

```prolog
choose son(lot,haran)
                      father(haran,lot), male(lot)
```

new resolvent is `father(haran,lot), male(lot)`

Resolvent is not empty

```prolog
choose father (hamo ,lot)
choose father (haran,lot).
```

new resolvent is `inale(lot)`

Resolvent is not empty

```prolog
choose male(lot)
choose male(lot)
```

new resolvent is empty Output:

yes Figure 1.2

Tracing the interpreter

```prolog
father(abraham,isaac)
                            male(isaac)
father(haran,lot).
                            male(lot).
father (haran,mïlcah).
                            female (milcah).
father(haran,yiscah)
                            female(yiscah).
son(X,Y) - father(Y,X), male(X).
daughter(X,Y)
                father(Y,X), female(X).
```

Program 1.2

Biblical family relationships

Definition A reduction of a goal G by a program P is the replacement of G by the body of an instance of a clause in P, whose head is identical to the chosen goal.

<!-- page 65 -->
A reduction is the basic computational step in logic programming. The goal replaced in a reduction is reduced, and the new goals are derived. In this chapter, we restrict ourselves to ground reductions, where the goal and the instance of the clause are ground. Later, in Chapter 4, we consider more general reductions where unification is used to choose the instance of the clause and make the goal to be reduced and the head of the clause identical.

The trace in Figure 1.2 contains three reductions. The first reduces the goal `son(lot,haran)` and produces two derived goals, `f ather(haran,` `lot)` and `male (lot).` The second reduction is of `father (har,lot)` and produces no derived goals. The third reduction also produces no derived goals in reducing `male (lot).`

There are two unspecified choices in the interpreter in Figure 1.1. The first is the goal to reduce from the resolvent. The second choice is the clause (and an appropriate ground instance) to reduce the goal. These two choices have very different natures.

The selection of the goal to be reduced is arbitrary. In any given resolvent, all the goals must be reduced. It can be shown that the order of reductions is immaterial for answering the query.

In contrast, the choice of the clause and a suitable instance is critical. In general, there are several choices of a clause, and infinitely many ground instances. The choice is made nondeterministically. The concept of nondeterministic choice is used in the definition of many computation models, e.g., finite automata and Turing machines, and has proven to be a powerful theoretic concept. A nondeterrninistic choice is an unspecified choice from a number of alternatives, which is supposed to be made in a "clairvoyant" way. If only some of the alternatives lead to a successful computation, then one of them is chosen. Formally, the concept is defined as follows. A computation that contains nondeterministic choices succeeds if there is a sequence of choices that leads to success. Of course, no real machine can directly implement this definition. However, it can be approximated in a useful way, as done in Prolog. This is explained in Chapter 6.

The interpreter given in Figure 1.1 can be extended to answer nonground existential queries by an initial additional step. Guess a ground instance of the query. This is identical to the step in the interpreter of guessing ground instances of the rules. It is difficult in general to guess the correct ground instance, since that means knowing the result of the computation before performing it.

<!-- page 66 -->
A new concept is needed to lift the restriction to ground instances and remove the burden of guessing them. In Chapter 4, we show how the guess of ground instances can be eliminated, and we introduce the computational model of logic programs more fully. Until then it is assumed that the correct choices can be made. Figure 1.3 A simple proof tree

A trace of a query implicitly contains a proof that the query follows from the program. A more convenient representation of the proof is with a proof tree. A proof tree consists of nodes and edges that represent the goals reduced during the computation. The root of the proof tree for a simple query is the query itself. The nodes of the tree are goals that are reduced during the computation. There is a directed edge from a node to each node corresponding to a derived goal of the reduced goal. The proof tree for a conjunctive query is just the collection of proof trees for the individual goals in the conjunction. Figure 1.3 gives a proof tree for the program trace in Figure 1.2.

An important measure provided by proof trees is the number of nodes in the tree. lt indicates how many reduction steps are performed in a computation. This measure is used as a basis of comparison between different programs in Chapter 3.

1.9 The Meaning of a Logic Program How can we know if a logic program says what we wanted it to say? If it is correct, or incorrect? In order to answer such questions, we have to define what is the meaning of a logic program. Once defined, we can examine if the program means what we have intended it to mean. Definition The meaning of a logic program P, M(P), is the set of ground goals deducible from P.

u

<!-- page 67 -->
From this definition it follows that the meaning of a logic program composed just of ground facts, such as Program 1.1, is the program itself. In other words, for simple programs, the program "means just what it says." Consider Program 1.1 augmented with the two rules defining the `parent` relationship. What is its meaning? It contains, in addition to the facts about fathers and mothers, mentioned explicitly in the program, all goals of the form `parent(X,Y)` for every pair X and Y such that `father (X, Y)` or `mother (X, Y)` is in the program. This example shows that the meaning of a program contains explicitly whatever the program states implicitly.

Assuming that we define the intended meaning of a program also to be a set of ground goals, we can ask what is the relation between the actual and the intended meanings of a program. We can check whether everything the program says is correct, or whether the program says everything we wanted it to say.

Informally, we say that a program is correct with respect to some intended meaning M if the meaning of P, M(P), is a subset of M. That is, a correct program does not say things that were not intended. A program is complete with respect to M if M is a subset of M(P). That is, a complete program says everything that is intended. It follows that a program P is correct and complete with respect to an intended meaning M if M = M(P).

Throughout the book, when meaningful predicate and constant names are used, the intended meaning of the program is assumed to be the one intuitively implied by the choice of names.

For example, the program for the `son` relationship containing only the first axiom that uses `father is` incomplete with respect to the intuitively understood intended meaning of `son,` since it cannot deduce `son(isaac,sarah).` If we add to Program 1.1 the rule

```prolog
son(X,Y) - rnother(X,Y), male(Y).
```

it would make the program incorrect with respect to the intended meanmg, since it deduces `son(sarah,isaac).`

The notions of correctness and completeness of a logic program are studied further in Chapter 5.

<!-- page 68 -->
Although the notion of truth is not defined fully here, we will say that a ground goal is true with respect to an intended meaning if it is a member of it, and false otherwise. We will say it is simply true if it is a member of the intended meaning implied by the names of the predicate and constant symbols appearing in the program. 1.10 Summary We conclude this section with a summary of the constructs and concepts introduced, filling in the remaining necessary definitions.

The basic structure in logic programs is a term. A term is a constant, a variable, or a compound term. Constants denote particular individuals such as integers and atoms, while variables denote a single but unspecified individual. The symbol for an atom can be any sequence of characters, which is quoted if there is possibility of confusion with other symbols (such as variables or integers). Symbols for variables are distinguished by beginning with ari uppercase letter.

A compound term comprises a functor (called the principal functor of the term) and a sequence of one or more terms called arguments. A functor is characterized by its name, which is an atom, and its arity or number of arguments. Constants are considered functors of arity O. Syntactically, compound terms have the form f(t1,t2.....t) where the functor has name f and is of arity n, and the t are the arguments. A functor f of arity n is denoted f/n. Functors with the same name but different arities are distinct. Terms are ground if they contain no variables; otherwise they are nonground. Goals are atoms or compound terms, and are generally nonground.

A substitution is a finite set (possibly empty) of pairs of the form X = t, where X is a variable and t is a term, with no variable on the left-hand side of a pair appearing on the right-hand side of another pair, and no two pairs having the same variable as left-hand side. For any substitution O

{X1 = ti,X2

t2,... ,X

= t} and term s, the term sO denotes the result of simultaneously replacing in s each occurrence of the variable X by t, i

j <n; the term sO is called an instance of s. More will be said on this restriction on substitutions in the background to Chapter 4.

A logic program is a finite set of clauses. A clause or rule is a universally quantified logical sentence of the form A - B1,B2,. . .,Bk.

k

<!-- page 69 -->
O, where A and the B are goals. Such a sentence is read declaratively: "A is implied by the conjunction of the B1," and is interpreted procedurally "To answer query A, answer the conjunctive query B1,B2,. . .,Bk." A is called the clause's head and the conjunction of the B the clause's body. If k = O, the clause is known as a fact or unit clause and written A., meaning A is true under the declarative reading, and goal A is satisfied under the procedural interpretation. If k = 1, the clause is known as an iterative clause.

A query is a conjunction of the form A1,...,A?

n>O, where the A are goals. Variables in a query are understood to be existentially quantified.

A computation of a logic program P finds an instance of a given query logically deducible from P. A goal G is deducible from a program P if there is an instance A of G where A B1,.. .,B, n

O, is a ground instance of a clause in P, and the B are deducible from P. Deduction of a goal from an identical fact is a special case.

The meaning of a program P is inductively defined using logical deduction. The set of ground instances of facts in P are in the meaning A ground goal G is in the meaning if there is a ground instance G B1,.

. of a rule in P such that B1,. . .,B are in the meaning. The meaning consists of the ground instances that are deducible from the program.

An intended meaning M of a program is also a set of ground unit goals. A program P is correct with respect to an intended meaning M if M(P) is a subset of M. It is complete with respect to M if M is a subset of M(P). Clearly, it is correct and complete with respect to its intended meaning, which is the desired situation, if M = M(P).

A ground goal is true with respect to an intended meaning if it is a member of it, and false otherwise.

Logical deduction is defined syntactically here, and hence also the meaning of logic programs. In Chapter 5, alternative ways of describing the meaning of logic programs are presented, and their equivalence with the current definition is discussed.
