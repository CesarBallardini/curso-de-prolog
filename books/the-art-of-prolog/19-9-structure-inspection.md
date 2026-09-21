# 9 Structure Inspection

<!-- page 204 -->
Standard Prolog has several predicates related to the structure of terms. These predicates are used to recognize the different types of terms, to decompose terms into their functor and arguments, and to create new terms. This chapter discusses the use of predicates related to term structure.

9.1 Type Predicates Type predicates are unary relations that distinguish between the different types of terms. System predicates exist that test whether a given term is a structure or a constant, and further, whether a constant is an atom, an integer or floating-point. Figure 9.1 gives the four basic type predicates in Standard Prolog, together with their intended meanings.

Each of the basic predicates in Figure 9.1 can be regarded as an infinite table of facts. The predicate `integer/i` would consist of a table of integers:

```prolog
integer(0).
                 integer(i).
                                 integer(-1).
```

The predicate `atom/i` would consist of a table of atoms in the program:

```prolog
atoin(foo).
               atom (bar).
                            .
```

The predicate `compound/i` would consist of a table of the function symbols in the program with variable arguments, etc.

```prolog
compound(father(X,Y)).
                             compound(son(X,Y)).
```

<!-- page 205 -->
```prolog
integer(X) - X is an integer.
atom(X) - X is an atom.
real(X) - X is a floating-point number.
compound(X) - X is a compound term.
```

Figure 9.1

Basic system type predicates

Other type predicates can be built from the basic type predicates. For example, that a number is either an integer or floating-point can be represented by two clauses:

```prolog
number(X) - integer(X).
number(X) - real(X).
```

Standard Prolog includes a predicate `number/i` effectively defined in this way. It also includes a predicate `atomic (X),` which is true if X is an atom or a number. In this book, we prefer to call the predicate `con-` `stant/i.` To run under Standard Prolog, the following clause may be necessary:

```prolog
constant(X) - atomic(X).
```

To illustrate the use of type predicates, the query `integer (3)?` would succeed, but the query `atom(3)?` would fail. One might expect that a call to a type predicate with a variable argument, such as `integer (X) ?,` would generate different integers on backtracking. This is not practical for implementation, however, and we would prefer that such a call report an error condition. In fact, Standard Prolog specifies that the call

```prolog
integer (X)? should fail.
```

The only terms not covered by the predicates in Figure 9.1 are variables. Prolog does provide system predicates relating to variables. The use of such predicates, however, is conceptually very different from the use of structure inspection predicates described in this chapter. Metalogical predicates (theìr technical name) are the subject of Chapter 10.

We give an example of the use of a type predicate as part of a program for flattening a list of lists. The relation `flatten(Xs,Ys)` is true if Ys is the list of elements occurring in the list of lists `Xs.` The elements of Xs can themselves be lists or elements, so elements can be arbitrarily deeply nested. An example of a goal in the meaning of `flatten is f`lat-

```prolog
ten([[a]
         , [b, [c,d]] ,e] , [a,b,c,d,e]).
```

<!-- page 206 -->
flatten(Xs,Ys)

Ys is a list of the elements of Xs.

```prolog
flatten([XIXs] ,Ys)
    flatten(X,Ysl), flatten(Xs,Ys2), append(Ysl,Ys2,Ys).
flatten(X,[X])
    constant(X), X[ 1.
flatten([ ],[ 1).
```

Program 9.la

Flattening a list with double recursion

The simplest program for flattening uses double recursion. To flatten an arbitrary list [XIXs], where X can itself be a list, flatten the head of the list X, flatten the tail of the list Xs, and concatenate the results:

```prolog
flatten([XIXs] ,Ys)
    flatten(X,Ysl), flatten(Xs,Ys2), append(Ysl,Ys2,Ys).
```

What are the base cases? The empty list is flattened to itself: A type predicate is necessary for the remaining case. The result of flattening a constant is a list containing the constant:

```prolog
flatten(X, [X]) - constant(X), Xl E
                                      ]
```

The condition `constant (X)` is necessary to prevent the rule being used when X is a list. The complete program for `f latten` is given as Program 9.la.

Program 9.la, although very clear declaratively, is not the most efficient way of flattening a list. In the worst case, which is a left-linear tree, the program would require a number of reductions whose order is quadratic in the number of elements in the flattened list.

A program for `flatten` that constructs the flattened list top-down is a little more involved than the doubly recursive version. lt uses an auxiliary predicate `flatten(Xs,Stack,Ys),` where Ys is a flattened list containing the elements in Xs and a stack `Stack` to keep track of what needs to be flattened. The stack is represented as a list.

<!-- page 207 -->
The call of `flatten/3` by `f latten/2` initializes the stack to the empty list. We discuss the cases covered by `f latten/3.` The general case is flattening a list [XXs], where X is itself a list. ¡ri this case Xs is pushed onto the stack, and X is recursively flattened. The predicate `list(X) is` used to recognize a list. It is defined by the fact `list ( [XIXs]):` flatten(Xs,Ys) -

Ys is a list of the elements of Xs.

```prolog
flatten(Xs,Ys) - flatten(Xs,[ ],Ys).
flatten([XIXs] ,S,Ys) -
    list (X), flatten(X, [XsIS] ,Ys)
flatten([XIXs],S,[XIYs]) -
    constant(X), X
                   E I ,
                       flatten(Xs,S,Ys).
flatten([ ],[XIS],Ys) -
    flatten(X,S,Ys).
```

`flatten([` 1,1 ],E I).

```prolog
list([XIXs]).
```

Program 9.lb

Flattening a list using a stack

```prolog
flatten([XIXs] ,S,Ys) - list(X), flatten(X, [XsIS] ,Ys).
```

When the head of the list is a constant other then the empty list, it is added to the output, and the tail of the list is flattened recursively:

```prolog
flatten([XIXs],S,[XIYs]) -
     constant(X),X[ 1,
                          flatten(Xs,S,Ys).
```

When the end of the list is reached, there are two possibilities, depending on the state of the stack. If the stack is nonempty, the top element is popped, and the flattening continues:

```prolog
flatten([ ],[XIS],Ys) - flatten(X,S,Ys).
```

If the stack is empty, the computation terminates:

```prolog
flatten([ ],[ ],[ 1).
```

The complete program is given as Program 9.lb.

A general technique of using a stack is demonstrated in Program 9.lb. The stack is managed by unification. Items are pushed onto the stack by recursive calls to a consed list. Items are popped by unifying with the head of the list and recursive calls to the tail. Another application of stacks appears in Programs 17.3 and 17.4 simulating pushdown automata.

Note that the stack parameter is an example of an accumulator.

<!-- page 208 -->
The reader can verify that the revised program requires a number of reductions linear in the size of the flattened list. 9.1.1

Exercise for Section 9.1

(i)

Rewrite Program 9.la for `f latten(Xs,Ys)` to use an accumulator

instead of the call to `append,` keeping it doubly recursive.

9.2 Accessing Compound Terms Recognizing a term as compound is one aspect of structure inspection. Another aspect is providing access to the furictor name, arity, and arguments of a compound term. One system predicate for delving into compound terms is `functor (Term, F, Arity).` This predicate is true if `Term is` a term whose principal functor has name `F` and arity `Arity.` For example,

```prolog
functor(father(haran,lot),father,2)? succeeds.
```

The functor predicate can be defined, analogously to the type predicates, by a table of facts of the form `functor(f(Xl,...,XN),f,N)` for each functor `f` of arity N, for example, `functor(father(X,Y) father,`

```prolog
2), functor(son(X,Y) ,son,2).....Standard Prolog considers constants
```

to be functors of arity O, with the appropriate extension to the functor table.

Calls to `functor` can fail for various reasons. A goal such as `f unc-` `tor(father(X,Y) ,son,2)` does not unify with an appropriate fact in the table. Also, there are type restrictions on the arguments of `f uric-` `tor` goals. For example, the third argument of `functor,` the arity of the term, cannot be an atom or a compound term. If these restrictions are violated, the goal fails. A distinction can be made between calls that fail and calls that should give an error because there are infinitely many so-

```prolog
lutions, such as functor(X,Y,2)?.
```

The predicate `functor` is commonly used in two ways, term decomposition and creation. The first use finds the functor name and arity of a given term. For example, the query `functor(father(haran,lot) ,X,Y)?` has the solution `{X=father,Y"2}.` The second use builds a term with a particular functor name and arity. A sample query is `functor (T ,father,`

```prolog
2)? with solution T=father(X,Y).
```

The companion system predicate to

```prolog
functor is arg(N,Term,Arg),
```

<!-- page 209 -->
which accesses the arguments of a term rather than the functor name. subterm (Sub, Term)

Sub is a subterm of the ground term Term.

```prolog
subterm(Term,Term).
subterm(Sub,Term) -
    compound(Term), functor(Term,F,N), subterm(N,Sub,Term).
subterm(N ,Sub,Term) -
    N > 1, Nl is N-1, subterm(N1,Sub,Term).
subterm(N,Sub,Term) -
    arg(N,Term,Arg), subterm(Sub,Arg).
```

Program 9.2 Fmdmg subterms of a term

The goal `arg` (N `,Term, Arg)` is true if `Arg` is the Nth argument of `Term.` For

```prolog
example, arg(1,father(haran,lot) ,haran) is true.
```

Like `functor/3, arg/3` is commonly used in two ways. The term decomposition use finds a particular argument of a compound term. A query exemplifying this use is `arg(2,father(haran,lot) ,X)?` with solution `X=lot.` The term creation use instantiates a variable argument of a term. For example, the query `arg(1,father(X,lot) ,haran)?` succeeds, instantiating X to `haran.`

The predicate `arg is` also defined as if there is an infinite table of facts. A fragment of the table is

```prolog
arg(i,father(X,Y) ,X).
                           arg(2,father(X,Y) ,Y).
arg(i,son(X,Y) ,X).
```

Calls to `arg` fail if the goal does not unify with the appropriate fact in the

```prolog
table, for example, arg(1,father(haran,lot) abraham). They also fail
```

if the type restrictions are violated, for example, if the first argument is an atom. An error is reported with a goal such as `arg (1 , X, Y).`

Let us consider an example of using `functor` and `arg` to inspect terms. Program 9.2 axiomatizes a relation `subterm(T1 T2),` which is true if Ti is a subterm of `T2.` For reasons that will become apparent later, we restrict Ti and `T2` to be ground.

<!-- page 210 -->
The first clause of Program 9.2 defining `subterm/2` states that any term is a subterm of itself. The second clause states that `Sub` is a subterm of a compound term `Term` if it is a subterm of one of the arguments. The number of arguments, i.e., the arity of the principal functor of the term, is found and used as a ioop counter by the auxiliary subterm/3, which iteratively tests all the arguments.

The first clause of subterm/3 decrements the counter and recursively calls subterm. The second clause covers the case when Sub is a subterm of the Nth argument of the term.

The subteim procedure can be used in two ways: to test whether the first argument is indeed a subterm of the second; and to generate subterms of a given term. Note that the clause order determines the order in which subterms are generated. The order in Program 9.2 gives subterms of the first argument before subterms of the second argument, and so on. Swapping the order of the clauses changes the order of solutions.

Consider the query subterm (a, f (X , Y))?, where the second argument is not ground. Eventually the subgoal subterrn(a,X) is reached. This succeeds by the first subterm rule, instantiating X to a. The subgoal also matches the second subterm rule, invoking the goal compound(X), which generates an error. This is undesirable behavior.

We defer the issues arising when performing structure inspection on nonground terms to Chapter 10, where meta-logical predicates with suitable expressive power are introduced. For the rest of this chapter, all programs are assumed to take only ground arguments unless otherwise stated.

Program 9.2 is typical code for programs that perform structure inspection. We look at another example, substituting for a subterm in a term.

The relation scheme for a general program for substituting subterms is substitute (Old,New,OldTerm,Newlerm), where NewTerm is the result of replacing all occurrences of Old in OldTeim by New. Program 9.3 implementing the relation generalizes substituting for elements in a list, posed as Exercise 3.3(i) and the logic program (Program 3.26) substituting for elements in binary trees.

<!-- page 211 -->
Program 9.3 is a little more complicated than Program 9.2 for subterm but conforms to the same basic pattern. The clauses for substitute/4 cover three different cases. The last, handling compound terms, calls an auxiliary predicate substitute/5, which iteratively substitutes in the subterms. The arity of the principal functor of the term is used as the initial value of a loop counter that is successively decremented to control the iteration. We present a particular example to illustrate substitute( Old,New,OldTerm,NewTerrn) -

NewTenn is the result of replacing all occurrences of Oid

in OldTerm by New.

```prolog
substitute(Old,New, Dld,New).
substitute(Old,New,Term,Term) -
    constant(Term), Term
                          Old.
substitute(Old,New,Term,Termi) -
    compound(Term),
    f unctor (Term , F , N)
    functor(Terml ,F,N),
    substitute(N,Old,New,Term,Terml).
substitute(N,Old,New,Term,Terml) -
    N > O,
    arg (N , Term , Arg)
    substitute(Old,New ,Arg,Argl),
    arg(N,Terml ,Argl),
    Nl is N-i,
    substitute(Ni3Old,New,Term,Termi).
substitute(O,Old,New,Term,Termi).
```

Program 9.3 A program for substituting in a term

the interesting points lurking in the code. A trace of the query `substi-` `tute (cat ,dog, owns(j arie ,cat) , X)?` is given in Figure 9.2.

The query fails to unify with the fact in Program 9.3. The second rule is also not applicable because `owns(jane,cat)` is not a constant.

The third `substitute` rule is applicable to the query. The second call of `functor` is interesting. `Name` and `Arity` have been instantiated to `owns` and 2, respectively, in the previous call of `furictor,` so this call builds a term that serves as the answer template to be filled in as the computation progresses. This explicit term building has been achieved by implicit unification in previous Prolog programs. The call to `substitute/5` successively instantiates the arguments of `Termi.` In our example, the second argument of owns (Xi,X2) is instantiated to dog, and then Xl is mstantiated to `jane.`

The two calls to `arg` serve different tasks in `substitute/5.` The first call selects an argument, while the second call of `arg` instantiates an argument.

<!-- page 212 -->
Substitution in a term is typically done by destructive assignment in conventional languages. Destructive assignment is not possible directly

```prolog
                                                     Xowns (j ane,
substitute(cat,dog,owns(jane,cat) ,X)
                                                           cat)
    constant(owns(jane,cat))
                                  f
substitute (cat ,dog, owns(jane, cat) ,X)
                                                     F=owns , N2
    coinpound(owns(jane ,cat))
    functor(owns(jane,cat) ,F,N)
    functor(X owns, 2)
                                                     Xowns(X1 ,X2)
    substitute(2,cat,dog,owns(jane,cat),owns(X1,X2))
        2>0
        arg(2,owns(jane,cat) Arg)
        substitute(cat ,dog, cat ,Argl)
                                                     Argcat
                                                     Argl=dog
                                                     X2dog
                                                     N1=l
                                                 ,dog))
        arg (2 , owns (Xl, X2) , dog)
        Nl is 2-1
        substitute(1,cat,dog,owns(jarie,cat), owns(X1
                                                     Arg2j ane
           1>0
           arg(l,owns(jane,cat) ,Arg2)
                                                     Arg3=j ane
           substitute(cat ,dog,jane,Arg3)
                                                     Xljane
               constant (j ane)
               jane
                      cat
           arg(1,owns(X1,dog) jane)
           N2 is 1-1
                                                     N2=0
                                                 (jane,dog))
           substitute(0,cat,dog,owns(jane,cat),owns
               0>0
                                 f
           substitute(0,cat,dog,owns(jane,cat) ,owns
                                                 (jane,dog))
               true
                   Output: (Xowns (j ane ,dog))
```

gure 9.2

Tracing the `substitute` predicate

in Prolog. Program 9.3 typifies how Prolog handles changing data structures. The new term is recursively built as the old term is being traversed, by logically relating the corresponding subterms of the terms.

Note that the order of the second `arg` goal and the recursive call to `substitute/5` can be swapped. The modified clause for `substitute/5` is logically equivalent to the previous one and gives the same result in the context of Program 9.3. Procedurally, however, they are radically different.

Another system predicate for structure inspection is a binary operator

called, for historical reasons, `univ.` The goal `Term =.. List` succeeds if `List` is a list whose head is the functor name of the term `Term` and whose tail is the list of arguments of `Term.` For example, the query `(f`a-

```prolog
ther(haran,lot) =.
                    .
                      [f ather,haran,lot])? succeeds.
```

<!-- page 213 -->
subterm(Sub,Term) -

Sub is a subterm of the ground term Term.

```prolog
subterm(Term,Term).
subterm(Sub,Term) -
    compound(Term), Term =..
                            [FIArgs], subterm_list(Sub,Args).
subterm_list (Sub, [Arg
                    I Args])
    subterm (Sub Arg).
subterm_list (Sub, [Arg
                    I Args]) -
    subterm_list (Sub Args).
```

Program 9.4

Subterm defined using `univ`

Like `functor` and `arg, Univ` has two uses. Either it builds a term given a list, for example, `(X =.`

```prolog
.
  [f ather,haran,lot])? with solution
```

`X=father(haran,lot),` or it builds a list given a term, for example, `(f a-`

```prolog
ther(haran, lot) =.. Xs)? with solution Xs= [f ather,haran, lot].
```

In general, programs written using `functor` and `arg` can also be written with `Univ.` Program 9.4 is an alternative definition of `subterin,` equivalent to Program 9.2. As in Program 9.2, an auxiliary predicate investigates the arguments; here it is `subterm_list. Univ` is used to access the list of arguments, `Args,` of which subterms are recursively found by `subterm_`

```prolog
list.
```

Programs using `univ` to inspect structures are usually simpler. However, programs written with `functor` and `arg` are in general more efficient than those using `univ,` since they avoid building intermediate structures.

A neat use of `univ` is formulating the chain rule for symbolic differentiation. The chain rule states that d/dx{f(g(x)} = d/dg(x){f(g(x)J x d/dx{g(x)}. In Section 3.5, we noted that this rule could not be expressed as a single clause of a logic program as part of Program 3.30. A Prolog rule encapsulating the chain rule is

```prolog
derivative (F_G_X,X ,DF*DG) -
    F_G_X =.. [F,G_X],
    derivative(F_G_X,G_X,DF),
    derivative(G_X,X,DG).
```

<!-- page 214 -->
The function `F_G_X` is split up by `univ` into its function `F` and argument `G_X,` checking that `F` is a function of arity i at the same time. The deriva- Term =.. List -

List is a list containing the ftmctor of Term followed

by the arguments of Term.

```prolog
Term
      ..
         [FIArgsI
    functor(Term,F,N), args(O,N,Term,Args).
args(I,N,Term,[krglArgs])
    I < N, Il is 1+1, arg(I1,Term,Arg), args(I1,N,Term,Args).
args(N,N,Term,[ J).
```

Program 9.Sa

Constructing a list corresponding to a term

tive of F with respect to its argument is recursively calculated, as is the derivative of G_X. These are combined to give the solution.

`Univ` can be defined m terms of `functor` and `arg. Two` different definitions are necessary, however, to cover both building lists from terms and building terms from lists. One definition does not suffice, because of errors caused by uninstantiated variables. Other system predicates are similarly precluded from flexible use.

Program 9.5a behaves correctly for building a list from a term. The functor F is found by the call to `functor,` and the arguments are recursively found by the predicate `args.` The first argument of `args` is a counter that counts up, so that the arguments will appear in order in the final list. If Program 9.5a is called with `Term` uninstantiated, an error will be generated because of an incorrect call of `furictor.`

Program 9.5b behaves correctly for constructing a term from a list. The length of the list is used to determine the number of arguments The term template is built by the call to `functor,` and a different variant of `args` is used to fill in the arguments. Program 9.5b results in an error if used to build a list, because of the goal `length(Args ,N)` being called with uninstantiated arguments. 9.2.1

Exercises for Section 9.2

Define a predicate `occurrences (Sub,Term,N),` true if `N` is the num-

ber of occurrences of subterm Sub in `Term,` Assume that `Term` is

```prolog
ground.
Define a predicate position(Subterm,Term,Position), where Po-
```

`sition` is a list of argument positions identifying `Subterm` within

<!-- page 215 -->
`Term.` For example, the position of X in `2'sin(X) is [2,1],` since Term =..List -

The functor of Term is the first element of the list List,

and its arguments are the rest of List's elements.

```prolog
Term =..
         EFIArgs] -
    length(Args,N), Î unctor(Term,F,N), args(Args,Term,i).
args([ArglArgs] ,Term,N) -
    arg(N,Term,Arg), Nl is N+1, args(Args,Terin,Nl).
args([ ],Term,N).
```

`length(Xs,N) -` See Program 8.11. Program 9.Sb

Constructing a term corresponding to a list

`sin(X)` is the second argument of the binary operator "", and X

is the first argument of `sin(X).` (Hint: Add an extra argument for

Program 9.2 for `subterni,` and build the position list top-down.)

Rewrite Program 9.5a so that it counts down. (Hint: Use an accumu-

lator.)

Define `functor` and `arg` in terms of `univ.` How can the programs be

used?

(y)

Rewrite Program 9.3 for `substitute` so that it uses `univ.`

9.3 Background Prolog does not distinguish between object-level and meta-level type predicates. We have taken a different approach, by defining the type test predicates to work only on instantiated terms and by treating the metalogical test predicates (e.g., `var/i,` discussed in Section 10.1) separately. The predicates for accessing and constructing terms, `functor, arg,` and

originate from the Edinburgh family The origin of =.. is in the old Prolog-10 syntax for lists, which used the operator ,. . instead of the current

in lists, e.g., [a,b,c,. `.Xs]` instead of `[a,b,cXs].` The

. . on the right-hand side suggested or reminded that the right-hand side of the equality is a list.

Several of the examples in this section were adapted from O'Keefe (1983).

Exercises 9.2(1) and 9.2(u) are used in the equation solver in Chapter 23.
