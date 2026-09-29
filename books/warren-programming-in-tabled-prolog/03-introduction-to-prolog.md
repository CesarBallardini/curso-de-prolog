# Introduction to Prolog

Introduction to Prolog
=====================================================================================================

This chapter introduces the Prolog programming language. Here we will explain a bit of how Prolog works. It is not intended to be a full description of how to become an expert Prolog programmer. For that, after reading this chapter, you should refer to another book, such as *Programming in Prolog* by Clocksin and Mellish, or if you are already very familiar with Prolog, you might look at *The Craft of Prolog* by Richard O'Keefe. While this is an introduction to Prolog, even experts may find something of interest in this chapter, since I explain Prolog in a somewhat unusual way, that may give new insights to old Prolog programmers.

Prolog's name is short for \`\`Programming in Logic'' (or really for Programmation Logique?'') As its name suggests, Prolog is firmly based on logic, and Prolog programs can be understood as statements in a formal logic. I.e., a Prolog program can be thought of as a set of statements in first-order logic, and the meaning of the program is the set of true implications of those logical statements. This is the approach that is usually taken to describe Prolog programming to novices. However, the amazing thing about logic programming to me is not that it is logic, but that it is programming. These Prolog programs are not only statements in a logic but they are also statements in a programming language. This is referred to in the biz by saying that Prolog programs have a procedural interpretation (i.e., as programs) as well as a declarative interpretation (i.e., as statements in a logic.) The introduction to Prolog that I give here will emphasize its procedurality. This may be anathema to some Prolog purists (and it certainly would have been to me a while ago) but I now feel that this is the best way to introduce logic programming to computer scientists who already know about programming. We will build on your understanding of programming, and use that to lead to logic.

------------------------------------------------------------------------

- <a href="#node4.html" id="node3.html_tex2html201">Prolog as a Procedural Programming Language</a>
  - <a href="#node5.html" id="node3.html_tex2html202">Assign-once Variables</a>
  - <a href="#node6.html" id="node3.html_tex2html203">Nondeterminism</a>
    - <a href="#node7.html" id="node3.html_tex2html204">Prolog execution as the execution of multiple machines</a>
  - <a href="#node8.html" id="node3.html_tex2html205">Executing Programs in XSB</a>
  - <a href="#node9.html" id="node3.html_tex2html206">The Scheduling of Machine Execution in Prolog</a>
- <a href="#node10.html" id="node3.html_tex2html207">Grammars in Prolog</a>
- <a href="#node11.html" id="node3.html_tex2html208">Prolog as a Database Query Langauge</a>
- <a href="#node12.html" id="node3.html_tex2html209">Deductive Databases</a>
- <a href="#node13.html" id="node3.html_tex2html210">Summary</a>

------------------------------------------------------------------------

# Prolog as a Procedural Programming Language
Prolog, as a programming language, is a little unusual. It can be understood as a standard procedural language with two unusual properties. It is a procedural language like Pascal or Algol. One programs in a procedural language by writing procedures that carry out particular operations. One specifies what a procedure is to do by using primitive statements and by invoking other procedures. Prolog procedures have only local variables and all the information that a procedure can use or produce must be passed through its arguments.

C can be viewed as a procedural language by thinking of using it without functions; i.e., all functions return void, and information is passed to and from functions through their arguments only.

In Prolog, procedures are called predicates. The two unusual aspects of Prolog are:

1\.
Prolog has assign-once variables, and

2\.
Prolog is nondeterministic.

------------------------------------------------------------------------

- <a href="#node5.html" id="node4.html_tex2html222">Assign-once Variables</a>
- <a href="#node6.html" id="node4.html_tex2html223">Nondeterminism</a>
  - <a href="#node7.html" id="node4.html_tex2html224">Prolog execution as the execution of multiple machines</a>
- <a href="#node8.html" id="node4.html_tex2html225">Executing Programs in XSB</a>
- <a href="#node9.html" id="node4.html_tex2html226">The Scheduling of Machine Execution in Prolog</a>

------------------------------------------------------------------------

## Assign-once Variables
By saying that Prolog has assign-once variables, I mean that any particular variable in a Prolog procedure can only ever get one value assigned to it. A Prolog variable at any point in execution either has a value, which can thereafter never be changed, or it has not yet been given a value. This may seem to be an incredibly strong restriction. In Pascal, for instance, one usually programs by setting a variable's value and then changing it during the execution of the program. For example, to sum up an array of numbers, one sets the accumulator variable to 0 and the loop variable to 1, and then increments the loop variable to step through the array modifying the accumulator at each step. How in the world could this be done with assign-once variables? The secret is that it can be done easily through the use of recursion.

So let's write a simple Prolog program to see how we can do something interesting with only assign-once variables. Let's consider the problem of adding up the numbers in a list. Prolog is a list-processing language, similar to Lisp. Its primary data structure is the tree (called a term), a very common form of which is the list. There are three basic data types in Prolog: 1) integers, 2) floating point numbers, and 3) atoms. The first two should be self-explanatory. Atoms are simply symbols that represent themselves. Prolog terms (trees) are constituted of integers, floats, atoms and other terms.

A list in Prolog is written with square brackets and with its elements separated by commas. For example the following are lists:

```prolog
 \[1,2,3\]  \[aa,bbb,d\]  \[\]  \[\[2,b\],or,not,\[2,b\]\]
```
The first is a list of integers, the second a list of atoms, the third is the empty list consisting of no elements, and the fourth is a list containing four elements, the first and last being themselves lists.

So let's now write a program in a made-up procedural language (that is *not* Prolog, but somewhat similar) and see if we can sum up the elements of an integer list with assign-once variables.

```prolog
sum(List,Sum) :-
    if List = \[\]
      then Sum := 0
      else Head := head(List)
           Tail := tail(List)
           sum(Tail,TailSum)
           Sum := TailSum + Head
```
The first line (preceding the `:-`) declares the name of the procedure and its formal parameters. The remaining lines (following the `:-`) make up the body of the procedure definition. We have assumed the existence of two functions, head and tail, to extract the first element of a list, and the remainder of the list after the head is removed, respectively. Sum is a recursive procedure. It takes a list of numbers as its first argument and returns the sum of the numbers in its second. It first checks to see if the list is empty. If so, it sets the sum to 0 and returns directly. If not, it saves the first element of the list in a local variable, `Head`, and then calls `sum` recursively on the tail of the list, getting the sum of the rest of the list in the local variable `TailSum`. It then adds `Head` to `TailSum` to get the value for `Sum`, which it sets and returns. Notice that no single variable gets two different values. The variable `Sum` is not set and then changed; each recursive invocation has a different `Sum` variable and each gets set only once, to its appropriate partial sum. Note also that the loop variable in the iterative version of summing an array is here replaced by the variables containing each sublist. So here too there is no need to have multiply assigned variables. Instead of one variable getting many values, we can instead uses many variables, each getting one value. (Let me point out for those of you who may be worried about efficiency that this is a conceptual point; it may well be that the underlying implementation of such a program would actually use just one location for all the `Sum` variables.)

So we see that we are able get by in this case with assign-once variables. It turns out that this idea of using recursion and the multiple variables at the different recursion levels is very general. This is not just a trick that works in this case only, but is an example of a very general technique.

Now having assign-once variables gives rise to a very interesting phenomenon: assignment can be symmetrical in Prolog. That is, Prolog doesn't have to treat the left and the right sides of an assignment differently, as must be done in normal procedural languages such as Pascal or C. As a matter of fact, Prolog doesn't have to treat tests and assignments differently either. I.e., Prolog doesn't need two operators, say == for testing and = for assignment as C does; it needs only one.

Let's first consider assignment. Consider the following assignments:

```prolog
 X := 5
 Y := X
```
We'll assume that neither `X` nor `Y` have been assigned a value before this sequence is executed. So `X` gets the value 5 by the first statement, and then `Y` is assigned the value of `X`, so `Y` gets the value 5 as well. Now consider the following statements:

```prolog
 X := 5
 X := Y
```
The first statement again assigns 5 to `X`. Now consider the second. `X` has the value 5 and `Y` has no value. Since Prolog is an assign-once language, `X` can get only one value and it already has it, so we know we can't change it. But `Y` doesn't yet have a value. So the only reasonable thing to do is to set `Y` to be 5, i.e., to `X`'s value. Note that this sequence of assignments has the same net effect that the previous sequence had.

This suggests how we can treat both sides of an assignment in the same way. If one of the variables has a value and the other doesn't, then assign the value that the one has to the other. If neither variable has a value yet, then make it so that whenever one of them gets a value, the other gets that same value. If they both have a value, then if it's the same value, then the assignment is a no-op. If the two values are different, then there is a problem since neither can get a new value. In this case we say the computation fails. (We will talk more about failure later.)

Notice that this definition of \`\`assignment'' means that any ordering of the same (or symmetric) assignments gives the same result. For example, consider the different ordering of our assignments above:

```prolog
 X := Y
 X := 5
```
Again assuming that `X` and `Y` start with no values, the first statement causes Prolog to bind `X` and `Y` together, so that whenever one of them gets a value, the other will also get that same value. Then the second statement causes `X` to get the value 5, and so `Y` gets that value, too. So after these two assignments are executed, both `X` and `Y` have the value 5, exactly as they do after the previous two versions of these assignments. This is also a very general phenonemon: with this meaning of assignment, any ordering of any set of assignments gives the same result.

So let's rewrite our sum program with these ideas in mind. We will use = for our symmetric assignment statement. (From now on, all our programs will be syntactically correct Prolog, and XSB, programs, so you can type them into XSB and try them out. \[sidebar\] to explain how to create files, consult them, and run defined predicates).

```prolog
sum(List,Sum) :-
    List = \[\]
     -\>   Sum = 0
     ;    List = \[Head\|Tail\],
          sum(Tail,TailSum),
          Sum is TailSum + Head.
```
I've changed the syntax for if-then-else to Prolog's syntax, using `->` and `;`. Here we've said that `Sum = 0`; using the properties of symmetric assignment, we could just as well have said that `0 = Sum`. Consider the symmetric assignment: `List = [Head|Tail]`. The structure on the right is how one constructs a list from a head element and a tail list. (In Lisp it is known as `cons`.) So our symmetric assignment here is even more powerful. We know that the variable `List` has a list as its value. So this assignment assigns both variables `Head` and `Tail` so that they get the values of the first element of `List` and the tail of `List`, respectively. We can see that symmetric assignment is here extended to matching. We match the value in the variable `List`, which is a list, to the structure `[Head|Tail]`. `Head` and `Tail` are the only variables without values, so the symmetric assignment will fill them in with the appropriate values to make the `List` and the `[Head|Tail]` structure the same. This matching process, which we have been referring to as \`\`symmetric assignment'', is called *unification*.

Notice that we've used the same operation of unification, `List = []`, in the test of the if-then-else. Here we see a use of failure. Recall that we said that if a symmetric assignment cannot be made because the two sides have values that are different, then the assignment (or unification) fails. The if-then-else construct does the unification and if it succeeds, then it executes the then statement (which follows the `->`); if it fails, it executes the else statement (which follows the `;`.) So even the boolean test of an if-then-else can use our universal unification operation.

Notice, however, that we have not used unification for the last statement that adds Head to the partial sum. This is because here we don't want to match the two sides, since Prolog considers the right side to be a tree (with + at the root and with two leaves of TailSum and Head.) So here we must use an operation that explicitly asks for the tree on the right to be evaluated as a numeric expression. In Prolog that operation is named `is`.

As another example, consider the append procedure:

```prolog
append(L1,L2,L3) :-
    L1 = \[\]
     -\>  L3 = L2
     ;   L1 = \[X\|L1t\],
         append(L1t,L2,L3t),
         L3 = \[X\|L3t\].
```
This is a procedure that takes two lists and concatenates them together, returning the resulting list in its third argument. This definition says that if the first list is empty, then the result of concatenating `L1` and `L2` is just `L2`. Otherwise, we let `X` be the head of the first list and `L1t` be its tail. Then we concatenate `L1`t and `L2`, using append recursively, to get `L3t`. Finally we add `X` to the beginning of `L3t` to construct the final result, `L3`.

Consider the following version of append:

```prolog
append(L1,L2,L3) :-
    L1 = \[X\|L1t\]
     -\>  L3 = \[X\|L3t\],
         append(L1t,L2,L3t)
     ;   L3 = L2
```
This one looks rather strange, but it also works. We've used the boolean test unification also to deconstruct the list. (This is probably a poor idea in real Prolog programming.) The other perhaps stranger (but less bad) difference is that we've moved the construction of the output list `L3` to before the recursive call to `append`. You might wonder how we can construct a list before we have its components. But with unification, that works just fine. The intuition is that if a variable can get only one value, it doesn't really matter when it gets it. So it is often the case that unifications can be moved earlier. What happens here is that the list cell is constructed before the call to `append`, and then the recursive call to `append` will fill in the tail of that cell with the appropriate value.

We've looked at assign-once variables and seen how they lead to symmetric assignment, which leads to unification. Next let's consider the other unusal property of Prolog programs, the fact that they can be nondeterministic.

------------------------------------------------------------------------

## Nondeterminism
Pascal is a deterministic programming language (as are C and Algol); at any point in the execution of a Pascal program there is exactly one next step. Prolog, however, is nondeterministic. There are points in the execution of a Prolog program when there are multiple legal next steps. The way this is specified in Prolog is to give multiple definitions of the same procedure. For example, we could write a procedure to find both square roots of a positive real number by:

```prolog
a_sqrt(X,Y) :-
    X \> 0,
    Y is sqrt(X).
a_sqrt(X,Y) :-
    X \> 0,
    Y is -sqrt(X).
```
`A_sqrt` takes a number and returns its square root. Here we want it to return both square roots, one positive and one negative. We can do that by giving two definitions of a procedure `a_sqrt`. A Pascal compiler would complain that the procedure is multiply defined, but Prolog accepts such multiple procedure definitions happily. The first definition checks that the input argument is greater than 0, and if so uses a Prolog primitive builtin to calculate the positive square root. The second definition does the same, but returns the negation of the positive square root. In Prolog terminology, each definition is called a \`\`clause'', so `a_sqrt` is defined by two clauses.

------------------------------------------------------------------------

- <a href="#node7.html" id="node6.html_tex2html249">Prolog execution as the execution of multiple machines</a>

------------------------------------------------------------------------

### Prolog execution as the execution of multiple machines
The way to understand how Prolog handles multiple procedure definitions is first to think of how a deterministic procedural machine executes a procedural program. It maintains a state (usually a stack of activation records) and executes instructions which update that state, calling subprocedures, performing the indicated operations, and returning from subprocedures. To introduce nondeterminism into this picture, we consider what happens when a machine encounters a procedure that has multiple definitions. At this point it duplicates itself, creating a copy for each definition, and each copy continues by executing the definition it is assigned to. Recall that an execution may fail when it does a unification that discloses an inconsistency. When this happens, we can think of the machine as simply disappearing. So we can think of a Prolog execution as a set of executing deterministic machines; whenever any one of them encounters a procedure call of a multiply defined procedure, it forks into multiple machines; whenever a machine fails, it disappears out of existence. The answer to a Prolog program is the set of answers returned by all the individual machines that make it to the final instruction of the program, i.e., that return successfully from the initial procedure call.

So if we invoke the `a_sqrt` procedure defined above with the following procedure call statement:

```prolog
:- a_sqrt(13,Y).
```
we will get two answers:

```prolog
X = 3.6055;
X = -3.6055;
```
Let's revisit the append program we wrote above. Instead of using an if-then-else construct there, we can now use nondeterminism. Consider:

```prolog
append(L1,L2,L3) :-
    L1 = \[\],
    L3 = L2.
append(L1,L2,L3) :-
    L1 = \[X\|L1t\],
    append(L1t,L2,L3t),
    L3 = \[X\|L3t\].
```
Notice that for whatever the list that is assigned to the variable `L1`, exactly one of the two procedure definitions will fail, and the other will succeed. The first will succeed only if `L1` is the empty list, and the second will succeed only if `L1` is a nonempty list. This program is essentially equivalent to the one above with the if-then-else.

Actually we can now improve this new append program. Consider how a normal procedural programming language passes parameters to procedures. One way is to do it by assignment: local variables are allocated for each formal parameter and the actual parameters are assigned to local variables on invocation. So assignment is used for passing parameters. Prolog can pass parameters this way as well, but instead of using assignment, it uses its symmetric assignment operation, unification (or matching.) So rather than doing a unification in the body of a procedure definition, we can simply put the values to be unified in the place of the formal parameters. So, for example, in the first procedure definition for `append`, rather than assigning the actual parameter to a local variable `L1` and then checking it against the empty list, we can directly check the first argument against the empty list as follows:

```prolog
append(\[\],L2,L3) :-
    L3 = L2.
```
This looks very odd for a conventional procedural language, having a constant in the place of a formal parameter, but with Prolog's symmetric assignment, it works fine. It simply unifies the empty list with the first actual parameter at the time of invocation.

As a matter of fact, whenever we have an explicit unification of a variable with another term, we can replace all occurrences of the variable with the term and eliminate the explicit unification. So we can replace L3 by `L2` in the above clause and we get simply:

```prolog
append(\[\],L2,L2).
```
(When a definition has no body operations, we don't even write the :-.) This procedure definition has no operations in its body. In a traditional procedural language, it would be a no-op, but in Prolog it actually does some work through the unification of its arguments when it is invoked.

The same idea for eliminating explicit unifications can be used on the second clause for `append`, and we obtain the usual Prolog definition of `append`:

```prolog
append(\[\],L2,L2).
append(\[X\|L1t\],L2,\[X\|L3t\]) :-
    append(L1t,L2,L3t).
```
------------------------------------------------------------------------

## Executing Programs in XSB
Now, we can load this definition into XSB and then call it in various ways to experiment with how it works. So we put this definition into a file called, say, appendfile.P. (The \`.P' suffix indicates to XSB that this is a file containing source code.) We run XSB and then compile the file and load it into XSB by:

```prolog
 % xsb
 XSB Version 1.4.1 (94/11/21)
 \[sequential, single word, optimal mode\]
 \| ?- \[appendfile\].
 \[Compiling ./appendfile\]
 \[appendfile compiled, cpu time used: 0.901 seconds\]
 \[appendfile loaded\]
```
```prolog
 yes
 \| ?-
```
The XSB system top-level prompt is \``| ?-` ', which is printed when XSB is waiting for the user to enter something. Here we've entered the filename in a list. This requests the system to compile and load the indicated file, which the system then does. The compilation creates an object file, in this case named appendfile.O. Then the XSB loader is called to load that file into XSB's space. (If the last-change date of the object file is more recent than the last-change date of the source file, then the compiler is not called, but the object file is loaded.) So now we have the append program in XSB memory and we can ask XSB to execute it. We do this by entering a call at the top-level prompt, as follows:

```prolog
 \| ?- append(\[a,b,c\],\[d,e\],X).
```
```prolog
 X = \[a,b,c,d,e\]
```
XSB calls the append procedure and executes it, passing the two lists in and when append returns, X has been assigned the answer, which XSB prints. It's possible that there is more than one answer (as would be the case with `a_sqrt` above), so XSB waits to let the user ask for another answer, if desired. To request another answer, the user enters a \`;', to which XSB responds with the next answer, if any. Here the result is as follows:

```prolog
 \| ?- append(\[a,b,c\],\[d,e\],X).
```
```prolog
 X = \[a,b,c,d,e\];
```
```prolog
 no
 \| ?-
```
XSB has responded with \`no' and then returned with the top level prompt. This is because, in this case, there is just one answer so asking for another results in the response of \`no'.

We could, of course, ask for different invocations of append, giving it different lists, but we can also give different forms of invocations. The unification of Prolog allows us to call some procedures in perhaps a surprising variety of different ways.

For example, we can enter the following query (i.e., procedure invocation) and will get the indicated result from XSB:

```prolog
 \| ?- append(\[a,b,c\],\[d,e\],\[a,b,c,d,e\]).
```
```prolog
 yes
 \| ?-
```
Here we've given the answer. XSB simply verifies that the answer is correct, and indicates it is by responding \`yes'. In this execution, unifications that set variable values in the previous execution simply verify that the variables already have the correct values. If the values don't check out, as they won't in this following case:

```prolog
 \| ?- append(\[a,b,c\],\[d,e\],\[a,b,c,d\]).
```
```prolog
 no
 \| ?-
```
XSB gives a response of \`no' indicating that the first two arguments do *not* concatenate to form the third.

Actually, Prolog can respond to even stranger invocations of our append procedure. Consider the following invocation:

```prolog
 \| ?- append(X,Y,\[a,b,c\]).
```
Here we are asking for what two values will concatenate together to form the list \[a,b,c\]. The tokens beginning with capital letters, `X` and `Y`, are variables, and we are asking the system to fill them in with correct values. (A variable starts with an upper-case letter, and an atom starts with a lower-case letter. We've been using this convention all along, and it is important to know.)

Prolog can answer this query reasonably. There are four possible pairs of lists that do concatenate together to produce `[a,b,c]`, and Prolog will produce them:

```prolog
 \| ?- append(X,Y,\[a,b,c\]).
```
```prolog
 X = \[\]
 Y = \[a,b,c\];
```
```prolog
 X = \[a\]
 Y = \[b,c\];
```
```prolog
 X = \[a,b\]
 Y = \[c\];
```
```prolog
 X = \[a,b,c\]
 Y = \[\];
```
```prolog
 no
 \| ?-
```
Here XSB produced the first answer and then waited for my response. I responded with a `;`, and it responded by producing the next answer. We continued until all the answers were produced. Since Prolog is nondeterministic, queries that have multiple correct answers are reasonable to ask. In this case Prolog answers the query correctly and reasonably.

Let's consider another simple (and well known) Prolog program known as `member`. `Member` is a binary predicate, i.e., it is a procedure with two arguments. It is given an element and a list, and it checks to see whether the element is a member of the list:

```prolog
 member(X,\[X\|L\]).
 member(X,\[Y\|L\]) :-
     member(X,L).
```
The first clause says that `X` is a member of a list whose head is `X`, an unexceptional statement. The second clause `X` is a member of a list if `X` is a member of the tail of the list.

Example executions of `member` are:

\| ?- member(2,\[1,2,3\]).\

yes\
\| ?- member(2,\[1,3,4\]).\

no\
\| ?- member(X,\[1,2,3\]).\

X = 1;\

X = 2;\

X = 3;\

no\
\| ?-\

Notice that we can use `member` to generate all the elements of a list.

(Aside: If you tried to compile this `member` program exactly as it is written here, you noticed that the XSB compiler issued some warning messages. The first message says that the variable `L` in the first clause appears only once in that clause. Such a variable is called an *anonymous variable*. An anonymous variable is just a placeholder, since the value that it might get is never used anywhere else, because the variable appears nowhere else. In such cases you are encouraged to use a slightly different notation: instead of starting anonymous variables with upper-case letters, start them with underscores (\_), or simply use an underscore alone. Each occurrence of the underscore symbol is a distinct (unnamed) variable. The compiler will not complain if you begin the name of an anonymous variable with an underscore. I strongly suggest following this convention; it will save untold grief that you'll otherwise suffer when you mistype variable names. So an equivalent, but syntactically improved, version of `member` is:

```prolog
 member(X,\[X\|\_L\]).
 member(X,\[\_Y\|L\]) :-
     member(X,L).
```
End of aside.)

As a final example of a simple Prolog list-processing predicate, consider the procedure `reverse`, which is given a list and returns a list that contains the elements of the input list, but in the reverse order.

```prolog
 reverse(\[\],\[\]).
 reverse(\[X\|L\],R) :-
     reverse(L,RL),
     append(RL,\[X\],R).
```
The first clause says that if the input list is empty, then the resulting list is also the empty list. The second clause says that if the input list has head `X` and tail `L`, then first reverse the tail `L` of the input list obtaining `RL`, and then add `X` to the end of `RL`. The predicate `append` is used to add this element to the end of the reversed sublist. Notice that we must use `[X]` as the second argument of append, not just `X`, because `append` requires a list there, not an element.

An example of executing `reverse` is:

\| ?- reverse(\[1,2,3\],R).\

R = \[3,2,1\];\

no\
\| ?-\

exactly as expected. You might reasonably think that we should also be able to ask the following query:

\| ?- reverse(X,\[1,2,3\]).\

X = \[3,2,1\];\

And it looks as though everything works fine. However, what has really happened is that after the system produced the expected answer, I asked it for another answer. It should have simply said \`\`no'', but instead it went into an infinite loop and didn't respond at all. To understand why Prolog behaves like this, we have to understand more clearly exactly how it goes about evaluating queries.

\[add an example to introduce ; and disjunction.\]

------------------------------------------------------------------------

## The Scheduling of Machine Execution in Prolog
Recall that above we described a conceptual model of how Prolog executes nondeterministic programs by talking of a growing and shrinking set of deterministic procedural machines. In order to completely understand how Prolog executes these nondeterministic programs, we must look more carefully at how this growing and shrinking set of machines is actually executed. Clearly Prolog is not executed by actually have a set of hardware machines that grows and shrinks. (While it would be nice, the physics of such machines has not yet been worked out.) Instead these multiple machines must somehow be simulated, or emulated, by a single hardware machine having just one processor.

The Prolog engine keeps track of the states of these multiple machines and uses them to simulate the machine executions. Let's first consider the way Prolog keeps track of the state of a single machine. We can model execution of a single machine by \`\`expanding'' procedures. When a procedure is called, the actual parameters are matched with the formal parameters. All variables that get values in the matching process, occurrences in the body of the procedure being called and variables in the calling procedure, are replaced by those values. And the procedure call is replaced by the body of the procedure. The explanation is complex but the idea is simple: procedure calls are replaced by procedure bodies, with the variables appropriately set. For example.....

Now that we have seen how a single machine executes, the real question is in what order does it emulate the multiple machines. Clearly when a query first starts, there is just one machine to execute it. What happens when that machine encounters a procedure defined by multiple clauses? At that point there are several machines to be executed. In what order does Prolog execute them? I.e., how are they scheduled?

===================

The formal counterpart of Prolog execution is the SLD search tree. Each node in the search tree corresponds to a state of one of the machines. Each path through the search tree corresponds to the execution sequence of one of the machines. A branching node in the tree corresponds to a choice point, when a machine is duplicated to create instances of itself that will explore the various alternatives.

Let's look at a simple example to see how this works for the append program when it is called with a final list and it is asked to find all pairs of lists that concatenate to form the given list.

Consider the query:

```prolog
 \| ?- append(X,Y,\[a,b\]).
```
First we have to determine a way to represent the states of the individual procedural machines. The state of execution of a procedural program is normally kept by a current instruction pointer and a stack of activation records associated with active procedures, which indicate values of local variables and also where to return when the procedure exits. For our Prolog programs we will use a very abstract representation that will enable us to understand the machine's operations without getting lost in encoding details. We will keep an instance of the variables of the original query and the sequence of procedure calls that remain to be done to complete the machine's computation. So the state of the initial machine is:

```prolog
 answer(X,Y) :- append(X,Y,\[a,b\]).
```
We use the `:-` to separate the query variables, which are grouped by `answer`, from the sequence of procedure calls that remain to be done. Initially the only thing to be done is the initial procedure call. We move a machine to its next state by taking the first procedure call after the `:-` in the machine state, matching it against the head of the chosen clause that defines the procedure, and replacing that call by the body of the clause, with the variables appropriately updated. Thus one step of computation replaces a procedure call by the sequence of procedure calls that make of the body of its definition, with the variables appropriately updated according to the parameter passing method.

So let's now consider the execution of the above query. The execution will be a tree of machine states, with the above machine state at the root. This tree is shown in Figure [2.1](#node9.html_appendsld).\



**Figure 2.1:** SLD tree for the query: append(X,Y,\[a,b\]). {width="50%"}

Prolog explores this tree in a top-down left-to-right order. The left-to-right order of children of a node corresponds to the order in which clauses for the called procedure appear in the text of the program. This is implemented in the Prolog engine by maintaining a stack of alternatives; whenever new alternative computation states are generated, it pushes them onto the stack, and whenever it needs another alternative, it takes the top one from the stack. So the Prolog engine begins by taking the first (and only) state off the stack and matching the first procedure, `append(X,Y,[a,b])`, with the heads of the appropriate procedure definitions (i.e., clauses). For each one that matches, it pushes a new state on the stack, replacing the procedure call by the body of the procedure, updating the variables accordingly. Now this first procedure call matches both clauses, so we generate two new states as children of the root state:

answer(\[\],\[a,b\]) :- .\
answer(\[a\|L1ta\],L2a) :- append(L1ta,L2a,\[b\]).\

The second state comes from the second clause, and the procedure call is replaced by the single procedure call in the body of the second clause defining `append`. The first state comes from the first clause, which has no procedure call in its body, so this state has no procedure call to do, and thus is a successful *final state* of the Prolog program. The arguments of the answer template contain the values of the variables of the original query, and so constitute the final answer of this machine. Here they are `[]` and `[a,b]`, which do indeed concatenate to generate `[a,b]`, as expected. Prolog will print this answer out, remove this state from the stack and continue expanding the next state on the top of the stack, here the second child of the root node.

Now consider that state:

answer(\[a\|L1ta\],L2a) :- append(L1ta,L2a,\[b\]).\

It was generated by matching the original procedure call with the second clause for `append`. In a procedural language, whenever a procedure is called, the procedure gets a *new* set of local variables, and in Prolog it is the same. I've indicated that here by giving the variables in the clause new names, by adding \`a' to the end of their original names. Each time I take a clause, I'll have to rename the variables to new ones, so we don't have unintended collisions, and I'll do this by adding a new letter suffix.

Again Prolog expands this state by replacing the first procedure call by the bodies of matching clauses. Again both clauses for `append` match this one so we get two new states on the stack:

answer(\[a\],\[b\]) :- .\
answer(\[a,b\|L1tb\],L2b) :- append(L1tb,L2b,\[\]).\

The top one is again an answer, since it has no procedures left to call, and its values for the result variables are: `[a]` and `[b]`, which again do concatenate to form the desired `[a,b]`.

After the answer is printed and the state removed from the stack, the next state:

answer(\[a,b\|L1tb\],L2b) :- append(L1tb,L2b,\[\]).\

is expanded. Now this procedure call matches only the first of the `append` clauses; the second fails to match because the third argument in the call is `[]` but in the procedure head is `[X|L3t]`. So the new stack is just:

answer(\[a,b\],\[\]) :- .\

The top state is an answer, which gets popped and displayed, and then the stack is empty, indicating that Prolog has completely finished traversing the SLD tree and thus with evaluating the query. It has simulated all the deterministic procedural machines to completion.

Stepping back a bit and thinking about the SLD tree, we can quite easily describe the tree by giving an operation that can be applied to a subtree to extend it. Then we can define the SLD tree as the result of applying this operation to an initial (trivial) tree, and all resulting trees until no operation is applicable. This operation is called Program Clause Resolution.

**Definition 2.1.1  ** **(Program Clause Resolution)** Given a tree with a node labeled\
 , and a rule in the program of the form  , and given that *H* and *B*<sub>1</sub> match with matching variable assignment , then add a new node as a child of this one and label it with  , if it does not already have a child so labeled. Note that the matching variable assignment is applied to all the goals in the new label.

Notice that the entire tree of Figure [2.1](#node9.html_appendsld) is developed by applying this rule to the trivial tree consisting of the single node `answer(X,Y) :- append(X,Y,[a,b])`. So we can think of Prolog as applying this Program Clause Resolution rule over and over again (in a top-down backtracking manner) to the initial query to trace out the SLD tree.

The example we have used here has a relatively simple execution and Prolog executions can get considerably more complex, but all the basics have been illustrated.

------------------------------------------------------------------------

# Grammars in Prolog
Next we turn to more complex examples of Prolog programming. Prolog was originally invented as a programming language in which to write natural language applications, and thus Prolog is a very elegant language for expressing grammars. Prolog even has a builtin syntax especially created for writing grammars. It is often said that with Prolog one gets a builtin parser for free. In this section we will see why this claim is made (and sometimes contested).

Consider the following simple context-free grammar for a small fragment of English.

>  \
>  \
>  \
>  \
>  \
>  \
>  \
>  \
>  \
>  \
>  \
>  \
>  \

In this grammar we can derive such simple sentences as:

> a man loves the woman\
> every woman walks\
> a woman likes the park\

We can write a simple Prolog program to recognize this language, by writing a recursive descent parser. We first must decide how to handle the input string. We will use a list in Prolog. For each nonterminal we will construct a Prolog procedure to recognize strings generated by that nonterminal. Each procedure will have two arguments. The first will be an input parameter consisting of the list representing the input string. The second will be an output argument, and will be set by the procedure to the remainder of the input string after an initial segment matched by the nonterminal has been removed. An example will help clarify how this works. The procedure for `np` would, for example, take as its first argument a list `[a,woman,loves,a,man]` and would return in its second argument the list `[loves,a,man]`. The segment removed by the procedure, `[a,woman]`, is an NP. The Prolog program is:

```prolog
s(S0,S) :- np(S0,S1), vp(S1,S).
np(S0,S) :- det(S0,S1), n(S1,S).
vp(S0,S) :- tv(S0,S1), np(S1,S).
vp(S0,S) :- v(S0,S).
det(S0,S) :- S0=\[the\|S\].
det(S0,S) :- S0=\[a\|S\].
det(S0,S) :- S0=\[every\|S\].
n(S0,S) :- S0=\[man\|S\].
n(S0,S) :- S0=\[woman\|S\].
n(S0,S) :- S0=\[park\|S\].
tv(S0,S) :- S0=\[loves\|S\].
tv(S0,S) :- S0=\[likes\|S\].
v(S0,S) :- S0=\[walks\|S\].
```
The first clause defines procedure `s`, for recognizing sentences. An input list `S0` is passed into procedure `s`, and it must set `S` to be the remainder of the list `S` after a sentence has been removed from the beginning. To do that, it uses two subprocedures: it first calls `np` to remove an NP, and then it calls `vp` to remove a VP from that. Since the grammar says that an S is an NP followed by a VP, this will do the right thing. The other rules are exactly analogous.

Having put this program in a file called `grammar.P`, we can load and execute it on our example sentences as follows:

% xsb\
XSB Version 1.4.1 (94/11/21)\
\[sequential, single word, optimal mode\]\
\| ?- \[grammar\].\
\[Compiling ./grammar\]\
\[grammar compiled, cpu time used: 1.14 seconds\]\
\[grammar loaded\]\

yes\
\| ?- s(\[a,man,loves,the,woman\],\[\]).\

yes\
\| ?- s(\[every,woman,walks\],\[\]).\

yes\
\| ?- s(\[a,woman,likes,the,park\],\[\]).\

yes\
\| ?- s(\[a,woman,likes,the,prak\],\[\]).\

no\
\| ?-\

When the string is in the language of the grammar, the program will execute successfully through to the end, and the system produces \`yes'. If the string is not in the language, as in the final example where \`park' was misspelled, the system answers \`no'. We called the `s` procedure with the input string as first argument and we gave it the empty list as second argument, because we want it to match the entire input string, wiht nothing left over after seeing an `s`.

The grammar above is called a *Definite Clause Grammar* (DCG) and Prolog supports a special rule syntax for writing DCGs. The syntax is simpler, much closer to the syntax one uses in writing context-free grammar rules. When using the DCG syntax, the programmer doesn't have to write all the string variables threaded through the nonterminal procedure calls; the compiler will do it. Here following is the same Prolog program as above, but witten as a DCG:

```prolog
s --\> np, vp.
np --\> det, n.
vp --\> tv, np.
vp --\> v.
det --\> \[the\].
det --\> \[a\].
det --\> \[every\].
n --\> \[man\].
n --\> \[woman\].
n --\> \[park\].
tv --\> \[loves\].
tv --\> \[likes\].
v --\> \[walks\].
```
Notice that these \`\`procedure definitions'' use the symbol `-->` instead of `:-` to separate the procedure head from the procedure body. The Prolog compiler converts such rules to (almost) exactly the program above, by adding the extra arguments to the predicate symbols and treating the lists as terminals. The \`\`almost'' is because it really translates, for example, a single word list `[loves]` above to the procedure call `'C'(S0,loves,S)`, and includes the definition of this new predicate as:

```prolog
'C'(\[Word\|String\],Word,String).
```
This gives exactly the same effect as the Prolog program for the grammar given above.

Consider another example grammar, this one for simple arithmetic expressions over integers with operators `+` and `*`:

expr --\> term, addterm.\
addterm --\> \[\].\
addterm --\> \[+\], expr.\
term --\> factor, multfactor.\
multfactor --\> \[\].\
multfactor --\> \[\*\], term.\
factor --\> \[I\], {integer(I)}.\
factor --\> \['('\], expr, \[')'\].\

There are several things to note about this DCG. Notice that the list entries, representing terminals, need not appear alone on right-hand-sides of DCG rules, but may accompany nonterminals. Also notice the first rule for `factor`; it has a variable (`I`) in a list, which will cause it to be matched with, and thus set to, the next input symbol. The following procedure call is enclosed in braces. This means that it matches no input symbols and so its translation to Prolog does NOT result in the string variables being added. It remains just a call to the Prolog procedure with one argument: `integer(I)`. The `integer` procedure is a Prolog builtin which tests whether its argument is an integer. Note also that we must quote the parentheses in the final rule. Otherwise, Prolog's reader would not be able to parse them correctly as atoms.

Consider some example executions of this grammar:

% xsb\
XSB Version 1.4.1 (94/11/21)\
\[sequential, single word, optimal mode\]\
\| ?- \[grammar\].\
\[Compiling ./grammar\]\
\[grammar compiled, cpu time used: 1.309 seconds\]\
\[grammar loaded\]\

yes\
\| ?- expr(\[4,\*,5,+,1\],\[\]).\

yes\
\| ?- expr(\[1,+,3,\*,'(',2,+,4,')'\],\[\]).\

yes\
\| ?- expr(\[4,5,\*\],\[\]).\

no\
\| ?-\

This grammar is not the most obvious one to write down for this expression language. It is specially constructed to avoid being left recursive. We mentioned above that we were writing a recursive descent parser for the grammar, and that is what one gets for a DCG from Prolog's execution strategy. Prolog execution of the underlying deterministic machines and its use of a stack to schedule them naturally yields a recursive descent parser. And it is well known that a recursive descent parser cannot handle left-recursive grammars; it will go into an infinite loop on them. So in Prolog we must avoid left-recursive grammars.

Also a recursive descent parser can be quite inefficient on some grammars, because it may re-parse the same substring many times. In fact, there are grammars for which recursive descent parsers take time exponential in the length of the input string. When using DCGs in Prolog, the programmer must be aware of these limitations and program around them. It is for this reason that some people respond to the claim that \`\`You get a parser for free with Prolog'' with \`\`Maybe, but it's not a parser I want to use.''

(Another example for adding arguments and using word/3 instead of strings?).

------------------------------------------------------------------------

# Prolog as a Database Query Langauge
Prolog is an elegant language for database queries. In fact if one constrains Prolog programs to use only atoms, integers and reals (no lists or complex terms) and disallows recursive definitions, one gets a database language that is equivalent to a powerful subset of SQL. In this section we will see how this is so.

A relation in relational database theory is a set of tuples. A common example of a database relation is the `employee` relation, which contains a tuple for each employee in a company. Each tuple might contain fields for: employee number, last name, first name, street address, city, state, zipcode, department number, hire date, and salary. It could, of course, contain many more. We can represent a set of tuples in Prolog as a highly nondeterministic procedure, the procedure returning every one of the tuples in the relation.

employee(193,'Jones','John','173 Elm St.','Hoboken','NJ',\
```prolog
                                      12345,1,'25 Jun 93',25500).
```
employee(181,'Doe','Betty','11 Spring St.','Paterson','NJ',\
```prolog
                                      12354,3,'12 May 91',28500).
```
employee(198,'Smith','Al','2 Ace Ave.','Paterson','NJ',\
```prolog
                                      12354,3,'12 Sep 93',27000).
```
(and more...)\

And we might have a department relation which contains for each department, a tuple that gives its number, name, and employee number of its manager.

department(1,'Grocery',181).\
department(3,'Deli',193).\
department(5,'Produce',199).\
...\

Given these basic relations (also called extensional relations), we can define other relations using Prolog procedure definitions to give us answers to questions we might have about the data. For example, we can define a new relation containing the names of all employees making more than \$28,000:

well_paid_emp(First,Last) :-\
```prolog
employee(\_Num,Last,First,\_Addr,\_City,\_St,\_Zip,\_Dept,\_Date,Sal),
Sal \> 28000.
```
As another example, we could ask for the name of the manager of the Deli department:

deli_manager(First,Last) :- \
```prolog
department(\_Deptno,'Deli',MgrID),
employee(MgrID,Last,First,\_Addr,\_City,\_St,\_Zip,\_Dept,\_Date,\_Sal).
```
Here we first call the department relation to find the employee number of the manager of the Deli department; then we call the employee relation to find the first and last names of the employee with that number.

(Should we introduce negation here? Without recursion, it is pretty easy. Would have to talk about safety.)

------------------------------------------------------------------------

# Deductive Databases
By staying with the simple data types, but adding recursion to this database language, one gets a language called (positive?) Datalog, which is the language underlying deductive databases. Deductive databases are an extension of relational databases which support more complex data modeling. In this section we will see how simple examples of deductive databases can be represented in Prolog, and we will see more of the limitations of Prolog.

A standard example in Prolog is a geneology database. An extensional relation stores the `parent` relation: `parent(X,Y)` succeeds with `X` and `Y` if `X` has parent `Y`. (Maybe do an example consisting of some English monarchs?) Given this `parent` relation, we can define the ancestor relation as follows:

```prolog
ancestor(X,Y) :- parent(X,Y).
ancestor(X,Y) :- parent(X,Z), ancestor(Z,Y).
```
This says that X has ancestor Y if X has parent Y; and X has ancestor Y if there is a Z such that X has parent Z and Z has ancestor Y. Given a definition for the parent relation as follows:

parent(elizabeth_II, charles\_??).\
etc.\

we can query about ancestors, such as:

:- ancestor(elizabeth_II,X).\

and find all of Queen Elizabeth's ancestors.

This works very nicely in Prolog, since the parent graph is (essentially) a tree. However, if we try the same definition of transitive closure for a graph that is not acyclic like a tree, we can be in trouble. Say we have a relation `owes(X,Y)` which indicates that `X` owes money to `Y`, and we want to define a predicate `avoids(X,Y)`, meaning that `X` tries to avoid running into `Y`. The definition is that people avoid someone to whom they owe money, and they avoid anyone that someone to whom they owe money avoids:

avoids(X,Y) :- owes(X,Y).\
avoids(X,Y) :- owes(X,Z), avoids(Z,Y).\

This definition has the same form as the ancestor definition. The problem here is that the `owes` relation may be cyclic. It is possible for Andy to owe money to Bill, Bill to own money to Carl and Carl to owe money to Bill:

owes(andy,bill).\
owes(bill,carl).\
owes(carl,bill).\

and if we ask who Andy avoids:

\| ?- avoids(andy,X).\

we get:

\| ?- avoids(andy,X).\

X = bill;\

X = carl;\

X = bill;\

X = carl;\

X = bill;\

X = carl;\

X = bill;\
....\

an infinite loop.

If we would like to use Prolog as an engine for deductive databases, this shows up a serious problem: that a user can write a simple specification (using only atoms and variablse) and yet Prolog won't give an answer, but will wander off to (or toward) infinity. One couldn't afford to give such a system to a naive database user. There it is important that any query come back with some answer. Think of an SQL system that sometimes went into an infinite loop. It wouldn't be much used, and certainly not by naive users.

This problem of infinite looping is a well-known problem in Prolog and Prolog programmers learn to program around it. The usual fix is to add an extra argument to the `avoids/2` predicate that keeps the list of people encountered in the process of finding the avoidees. Then if one of them is encountered again, the search is made to fail at that point, since it is known that all avoidees from that one have already been found. I.e.,

avoids(X,Y,L) :- owes(X,Y), \\ member(Y,L).\
avoids(X,Y,L) :- owes(X,Z), \\ member(Z,L), avoids(Z,Y,\[Z\|L\]).\

Here we've used the Prolog predicate `member/2`, and the Prolog builtin, `\+`, which implements *not*. `\+ member(Y,L)` succeeds just in case `member(Y,L)` fails, and fails if it succeeds. Now with this program and the corresponding query, we get:

\| ?- avoids(andy,X,\[\]).\

X = bill;\

X = carl;\

no\
\| ?-\

This fix works to avoid the infinite loop, but it sometimes has some undesirable properties. There are graphs for which the computation will be exponential in the number of arcs. Consider the case in which Andy owes money to Bill and Bob, and Bill and Bob owe money to Carl; Carl owes money to Dan and Dave, and Dan and Dave owe money to Evan; Evan owes money to Fred and Frank, and Fred and Frank owe money to George; and so on. The graph of the owes relation can be pictured as in Figure [2.2](#node12.html_expgraph).\



**Figure 2.2:** Graph on which Prolog is exponential {width="50%"}

On this graph, this query will be exponential. This graph is acyclic, so the original, simpler Prolog program for transitive closure would terminate. But it (and the `member`-enhanced version, too) would recompute the same answers again and again. It would in effect turn this (essentially) linear list into a tree.

------------------------------------------------------------------------

# Summary
So we have seen that Prolog is an interesting language that combines logic and computation. Some programs are very simple and elegant and execute very reasonably, such as the `append` program or the `member` program. Other programs, such as those derived from context-free grammars, are very simple and elegant, but sometimes have undesirable computational properties. For example, some context-free grammars have recognition times that are exponential in the length of the input string. This is clearly undesirable, since we know that there are recognition algorithms that work for all context-free grammars in at worst cubic time. And even worse, for some grammars, such as left-recursive grammars, Prolog will go into an infinite loop, not returning an answer at all. We also saw the same problem with the Datalog language. Perfectly good specifications might end up with (very) bad computational behavior. In the next chapter we will see how Prolog might be modified to deal with some of these problems.

------------------------------------------------------------------------
