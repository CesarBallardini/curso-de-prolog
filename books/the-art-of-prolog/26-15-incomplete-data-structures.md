# 15 Incomplete Data Structures

<!-- page 324 -->
The programs presented so far have been discussed in terms of relations between complete data structures. Powerful programming techniques emerge from extending the discussion to incomplete data structures, as demonstrated in this chapter.

The first section discusses difference-lists, an alternative data structure to lists for representing a sequence of elements. They can be used to simplify and increase the efficiency of list-processing programs. In some respects, difference-lists generalize the concept of accumulators. Data structures built from the difference of incomplete structures other than lists are discussed in the second section. The third section shows how tables and dictionaries, represented as incomplete structures, can be built incrementally during a computation. The final section discusses queues, an application of difference-lists.

15.1 Difference-Lists Consider the sequence of elements 1,2,3. It can be represented as the difference between pairs of lists. It is the difference between the lists [1,2,3,4,5] and [4,51, the difference between the lists [1,2,3,8] and [8], and the difference between [1,2,3] and [J. Each of these cases is an instance of the difference between two incomplete lists [1,2,3 Xs] and Xs.

<!-- page 325 -->
We denote the difference between two lists as a structure As\Bs, which is called a difference-list. As is the head of the difference-list and Bs the tail. In this example [1,2,3Xs]\Xs is the most general difference-list representing the sequence 1,2,3, where [1,2,3Xs] is the head of the differencelist and Xs the tail.

Logical expressions are unified, not evaluated. Consequently the binary functor used to denote difference-lists can be arbitrary. Of course, the user must be consistent in using the same functor in any one program. Another common choice of functor besides \ is -. The functor for difference-lists can also be omitted entirely, the head and the tail of the difference-list becoming separate arguments in a predicate. While this last choice has advantages from a perspective of efficiency, we use the functor \ throughout for clarity.

Lists and difference-lists are closely related. Both are used to represent sequences of elements. Any list L can be trivially represented as a difference-list L\[ J. The empty list is represented by any difference-list whose head and tail are identical, the most general form being As\As.

Difference-lists are an established logic programming technique. The use of difference-lists rather than lists can lead to more concise and efficient programs. The improvement occurs because of the combining property of difference-lists. Two incomplete difference-lists can be concatenated to give a third difference-list in constant time. In contrast, lists are concatenated using the standard `append` program in time linear in the length of the first list.

Consider Figure 15.1. The difference-list Xs\Zs is the result of appending the difference-list Ys\Zs to the difference-list Xs\Ys. This can be expressed as a single fact. Program 15.1 defines a predicate `append_` `dl(As,Bs,Cs),` which is true if the difference-list Cs is the result of appending the difference-list `Bs` to the difference-list `As.` We use the suffix `_dl` to denote a variant of a predicate that uses difference-lists.

A necessary and sufficient condition characterizing when two difference-lists `As\Bs` and Xs\Ys can be concatenated using Program 15.1 is that `Bs` be unifiable with Xs. In that case, the two difference-lists are compatible. If the tail of a difference-list is uninstantiated, it is compatible with any difference-list. Furthermore, in such a case Program 15.1 would concatenate it in constant time. For example, the result of the query

```prolog
append_dl([a,b,cIXs]\Xs, [1,2]\[ J ,Ys)? is (Xs=[1,2] ,Ys=[a,b,c,
1,2]\[ ]).
```

<!-- page 326 -->
Difference-lists are the logic prograniming counterpart of Lisp's rplacd, which is also used to concatenate lists in constant time and save consing

Xs

Xs\Ys

Ys

Ys\Zs

Zs

Xs\Zs Figure 15.1

Concatenating difference-lists

append_dI(As,Bs,Cs)

The difference-list Cs is the result of appending Bs to As,

where As and Bs are compatible difference-lists. append_dl(Xs\Ys, Ys\Zs, Xs\Zs). Program 15.1

Concatenating difference-lists

(allocating new list-cells). There is a difference between the two: the former are free of side effects and can be discussed in terms of the abstract computation model, whereas rplaccl is a destructive operation, which can be described only by reference to the machine representation of Sexpressions.

A good example of a program that can be improved by using difference-lists is Program 9.la for flattening a list. It uses double recursion to flatten separately the head and tail of a list of lists, then concatenates the results. We adapt that program to compute the relation `f latten_` `dl(Xs,Ys),` where `Ys is` a difference-list representing the elements that appear in a list of lists Xs in correct order. The direct translation of Program 9.la to use difference-lists follows:

```prolog
flatten_dl([XIXs] ,Ys\Zs) -
    f latten_dl(X,As\Bs), f latten_dl(Xs,Cs\Ds),
    append_dl (As\Bs , Cs\Ds
                            , Ys\Zs).
flatten_dl(X, [XIXs]\Xs) -
    conistant(X), X[ J.
flatten_dl([ ] ,Xs\Xs).
```

<!-- page 327 -->
flatten (Xs,Ys)

Ys is a flattened list containing the elements in Xs.

```prolog
flatten(Xs,Ys) - flatten_dl(Xs,Ys\[ 1).
flatten_dl([XIXs] ,Ys\Zs) -
    flatten_dl(X,Ys\Ysl), flatten_dl(Xs,Ysl\Zs)
flatten_dl(X, [XIXs]\Xs) -
    constant(X), XL[ ].
flatten_diCE J ,Xs\Xs)
```

Program 15.2

Flattening a list of lists using difference-lists

The doubly recursive clause can be simplified by unfolding the `append_` `dl` goal with respect to its definition in Program 15.1. Unfolding is discussed in more detail in Chapter 18 on program transformation. The result is

```prolog
flatten_dl([XIXs] ,As\Ds) -
     flatten_dl(X,As\Bs), flatten_dl(Xs,Bs\Ds).
```

The program for flatten_cl! can be used to implement `flatten` by expressing the connection between the desired flattened list and the difference-list computed by `f latt en_dl` as follows:

```prolog
flatten(Xs,Ys) - flatten_dl(Xs,Ys\[ 1).
```

Collecting the program and renaming variables yields Program 15.2.

Declaratively Program 15.2 is straightforward. The explicit call to `ap-` `pend` is made unnecessary by flattening the original list of lists into a difference-list rather than a list. The resultant program is more efficient, because the size of its proof tree is linear in the number of elements in the list of lists rather than quadratic.

The operational behavior of programs using difference-lists, such as Program 15.2, is harder to understand. The flattened list seems to be built by magic.

Let us investigate the program in action. Figure 15.2 is a trace of the

```prolog
query flatten([[a]
```

`, [b, [c]]] ,Xs)?` with respect to Program 15.2.

<!-- page 328 -->
The trace shows that the output, Xs, is built top-down (in the terminology of Section 7.5). The tail of the difference-list acts like a pointer to the end of the incomplete structure. The pomter gets set by unification. By using these "pointers" no intermediate structures are built, in contrast to Program 9.la.

```prolog
flatten([[a] , [b,[c]]] ,Xs)
    flatten_dl([[a] , [b, [cl]] ,Xs\[ 1)
        flatten_dl([a] ,Xs\Xsl)
           flatten_dl(a,Xs\Xs2)
                                                   Xs
                                                        [aIXs2]
               constant (a)
               a
                    []
           flatten_dl([],Xs2\Xsl)
                                                   Xs2 = Xsl
        flatten_dl([[b,[c]]],Xsl\[ 1)
           flatten_dl([b, [cl] ,Xsl\Xs3)
               flatten_dl(b,Xsl\Xs4)
                                                   Xsl = [bIXs4]
                   constant (b)
                   b
                       []
               flatten_dl([[c]] ,Xs4\Xs3)
                   flatten_dl([c] ,Xs4\Xs5)
                       flatten_dl(c,Xs4\Xs6)
                                                   Xs4
                                                         [cIXs6]
                          constant (c)
                          c
                               []
                       flatten_dl([ ],Xs6\Xs5)
                                                   Xs6
                                                         Xs5
                   flatten_dl([
                               1 ,Xs5\Xs3)
                                                   Xs5
                                                         Xs3
               flatten_dl([
                           1 ,Xs3\[ 1)
                                                   Xs3
                                                         [
                                                          I
           Output: Xs = [a,b,c]
```

Figure 15.2

Tracing a computation using difference-lists

The discrepancy between clear declarative understanding and difficult procedural understanding stems from the power of the logical variable. We can specify logical relations implicitly and leave their enforcement to Prolog. Here the concatenation of the difference-lists has been expressed implicitly, and it is mysterious when it happens in the program.

Building structures with difference-lists is closely related to building structures with accumulators. Loosely, difference-lists build structures top-down, while accumulators build structures bottom-up. Exercise 9.1(i) asked for a doubly recursive version of `flatten` that avoided the call to `append` by using accumulators. A solution is the following program:

```prolog
flatten(Xs,Ys) - flatten(Xs,[ ],Ys).
flatten([XIXsJ,Zs,Ys) -
    flatten(Xs,Zs,Ysl), flatten(X,Ysl,Ys).
flatten(X,Xs, [XIXs]) -
    constant(X), X[ ].
flatten([
           I ,Xs,Xs).
```

<!-- page 329 -->
reverse(Xs,Ys) -

Ys is the reversal of the list Xs.

```prolog
reverse(Xs,Ys) - reverse_dl(Xs,Ys\[ 1).
reverse_dl([XIXs] ,Ys\Zs) -
    reverse_dl (Xs,Ys\ [XIZs]).
reverse_dl(
           E ] ,Xs\Xs).
```

Program 15.3

Reverse with difference-lists

The similarity of this program to Program 15.2 is striking. There are only two differences between the programs. The first difference is syntactic. The difference-list is represented as two arguments, but in reverse order, the tail preceding the head. The second difference is the goal order in the recursive clause of `flatten.` The net effect is that the flattened list is built bottom-up from its tail rather than top-down from its head.

We give another example of the similarity between difference-lists and accumulators. Program 15.3 is a translation of naive `reverse` (Program 3.16a) where lists have been replaced by difference-lists, and the `append` operation has been unfolded away.

When are difference-lists the appropriate data structure for Prolog programs? Programs with explicit calls to `append` can usually gain in efficiency by using difference-lists rather than lists. A typical example is a doubly recursive program where the final result is obtained by appending the outputs of the two recursive calls. More generally, a program that independently builds different sections of a list to be later combined is a good candidate for using difference-lists.

The logic program for `quicksort,` Program 3.22, is an example of a doubly recursive program where the final result, a sorted list, is obtained from concatenating two sorted sublists. It can be made more efficient by using difference-lists. All the `append` operations involved in combining partial results can be performed implicitly, as shown in Program 15.4.

<!-- page 330 -->
The call of `quicksort_di` by `quicksort` is an initializing call, as for `flatten` in Program 15.2. The recursive clause is the quicksort algorithm interpreted for difference-lists where the final result is pieced together implicitly rather than explicitly. The base clause of `quicksort_di` states that the result of sorting an empty list is the empty difference-list. Note the use of unification to place the partitioning element X after the smaller quicksort (List,SortedList) -

SortedList is an ordered permutation of List.

```prolog
quicksort(Xs,Ys)
                   quicksortd1(Xs,Ys\[ 1).
quicksort_dl([XIXs] ,Ys\Zs) -
    partition(Xs,X,Littles,Bigs)
    quicksort_dl(Littles , Ys\ [X lYsi])
    quicksort_dl(fligs,Ysl\Zs)
quicksort_dl([ ] ,Xs\Xs)
partition(Xs,X,Ls,Bs)
                       See Program 3.22.
```

Program 15.4

Quicksort using difference-lists

elements Ys and before the bigger elements Ysi in the call `quicksort_`

```prolog
dl(Littles,Ys\[XYs1]).
```

Program 15.4 is derived from Program 3.22 in exactly the same way as Program 15.2 is derived from Program 9.la. Lists are replaced by difference-lists and the `append_dl` goal unfolded away. The initial call of `quicksort_dl` by `quicksort` expresses the relation between the desired sorted list and the computed sorted difference-list.

An outstanding example of using difference-lists to advantage is a solution to a simplified version of Dijkstra's Dutch flag problem. The problem reads: "Given a list of elements colored red, white, or blue, reorder the list so that all the red elements appear first, then all the white elements, followed by the blue elements. This reordering should preserve the original relative order of elements of the same color." For example, the list `[red(1),white(2),blue(3),red(4),white(5)]` should be reordered to

```prolog
[red(1) ,red(4) ,white(2) ,white(5) ,blue(3)].
```

Program 15.5 is a simple-minded solution to the problem that collects the elements in three separate lists, then concatenates the lists. The basic relation is `dut ch (Xs ,Ys),` where Xs is the original list of colored elements and Ys is the reordered list separated into colors.

The heart of the program is the procedure `distribute,` which constructs three lists, one for each color. The lists are built top-down. The two calls to `append` can be removed by having `distribute` build three distinct difference-lists instead of three lists. Program 15.6 is an appropriately modified version of the program.

<!-- page 331 -->
The implicit concatenation of the difference-lists is done in the initializing call to `distribute_dls` by `dutch.` The complete list is finally dutch (Xs,RedsWhitesBlues) -

Reds WhitesBlues is a list of elements of Xs ordered

by color: red, then white, then blue.

```prolog
dutch(Xs ,RedsWhitesBlues) -
    distribute(Xs,Reds,Whites,Blues),
    append(Whites,Blues ,WhitesBlues),
    append (Reds, WhitesBlues , RedsWhitesBlues).
```

distribute(Xs,Reds, Whites,Blues) -

Reds, Whites, and Blues are the lists of the red, white,

and blue elements in Xs, respectively.

```prolog
distribute([red(X)IXs] ,[red(X) Reds] ,Whites,Blues) -
    distribute(Xs,Reds,Whites,Blues).
distribute([white(X)IXs] ,Reds,[white(X)IWhites] Blues) -
    distribute(Xs,Reds,Whites,Blues).
distribute([blue(X)IXs] ,Reds,Whites, [blue(X)jBlues]) -
    distribute(Xs,Reds,Whites,Blues).
distribute([ l,E],
                  E ] [1).
append(Xs,Ys,Zs) - See Program 3.15.
```

Program 15.5 A solution to the Dutch flag problem

"assembled" from its parts with the satisfaction of the base clause of

```prolog
distribute_dis.
```

The Dutch flag example demonstrates a program that builds parts of the solution independently and pieces them together at the end. It is a more complex use of difference-lists than the earlier examples.

Although it makes the program easier to read, the use of an explicit constructor such as \ for difference-lists incurs noticeable overhead in time and space. Using two separate arguments to represent the difference-list is more efficient. When important, this efficiency can be gained by straightforward manual or automatic transformation. Exercises for Section lSd

Rewrite Program 15.2 so that the final list of elements is in the

reverse order to how they appear in the list of lists.

```prolog
Rewrite Programs 3.27 for preorder(Tree,List), inorder(Tree,
```

<!-- page 332 -->
`List)` and `postorder(Tree,List),` which collect the elements ocdutch (Xs,RedsWhitesBlues)

Reds WhitesBlues is a list of elements of Xs ordered

by color: red, then white, then blue.

```prolog
dutch(Xs ,RedsWhitesBlues) -
    distribute_dis (Xs , RedswhitesBlues\Whitesßlues,
        WhitesBlues\Blues,Blues\[ 1).
```

distribute_dis (Xs,Reds, Whites,Blues)

Reds, Whites, and Blues are the difference-lists of the

red, white, and blue elements in Xs, respectively.

```prolog
distribute_dls( [red(X)
                     I Xs]
        [red(X) IReds]\Redsl,Whìtes,Blues)
    distribute_dls(Xs,Reds\Redsl,Whites,Blues).
distrïbute_dls([white(X) IXs]
        Reds, [whïte(X)Iwhites]\Whitesl,Blues)
    distribute_dls(Xs,Reds,Whites\Whitesl Blues)
distribute_dls( [blue (X)
                      I Xs]
        Reds,Whites, [blue(X) IBlues]\Bluesl) -
    distribute_d1s(Xs,Reds,.ihites ,Blues\Bluesl)
distrïbute_dls([ ],Reds\Reds,Whites\Whites,Blues\Blues).
```

Program 15.6

Dutch flag with difference-lists

currmg in a binary tree, to use difference-lists and avoid an explicit

call to append. (iii)

Rewrite Program 12.3 for solving the Towers of Hanoi so that the

list of moves is created as a difference-list rather than a list.

i 5.2 Difference-Structures The concept underlying difference-lists is the use of the difference between incomplete data structures to represent partial results of a computation. This can be applied to recursive data types other than lists. This section looks at a specific example, sum expressions.

<!-- page 333 -->
Consider the task of normalizing sum expressions. Figure 15.3 contains two sums (u + b) + `(C +` ci) and (ci + (b + (c + cl))). Standard Prolog syntax brackets the term a + b + c as ((a + b) + c). We describe a procedure converting a sum into a normalized one that is bracketed to the right. For example, the expression on the left in Figure 15.3 would be 292 Chapter 15/\

+

+

**/\**

**/\**

**a b cd**

Figure 15.3

Unriormalized and normalized sums

normalize(Sum,NormalizedSum) -

NormalizedSum is the result of normalizing the sum expression Sum.

```prolog
normalize(Exp,Norm)
                     normalize_ds(Exp,Norm++O).
normalize_ds (A+B , Norm++Space) -
    normalize_ds (A, Norm++Normß), normalize_ds (B, NormB++Space).
normalize_ds(A, (A+Space)++Space)
    constant (A)
```

Program 15.7 Normalizing plus expressions

converted to the one on the right. Such a procedure is useful for doing algebraic simplification, facilitating writing programs to test whether two expressions are equivalent.

We introduce a difference-sum as a variant of a difference-list. A difference-sum is represented as a structure El ++ F2, where El and F2 are incomplete normalized sums. lt is assumed that ++ is defined as a binary infix operator. It is convenient to use O to indicate an empty sum.

Program 15.7 is a program for normalizing sums. The relation scheme is `normalize (Exp Norm),` where `Norm` is an expression equivalent to `Exp` that is bracketed to the right and preserves the order of the constants appearing in `Exp.`

<!-- page 334 -->
This program is similar in structure to Program 15.2 for flattening lists using difference-lists. There is an initialization stage, where the difference-structure is set up, typically calling a predicate with the same name but different arity or different argument pattern. The base case passes out the tail of the incomplete structure, and the goals in the body of the recursive clause pass the tail of the first incomplete structure to be the head of the second.

The program builds the normalized sum top-down. By analogy with the programs usmg difference-lists, the program can be easily modified to build the structure bottom-up, which is Exercise (ii) at the end of this section.

The declarative reading of these programs is straightforward. Operationally the programs can be understood in terms of building a structure incrementally, where the "hole" for further results is referred to explicitly. This is entirely analogous to difference-lists. Exercises for Section 15.2

(i)

Define the predicate `normalized_sum(Expressiori),` which is true

if `Expression` is a normalized sum. (ii)

Rewrite Program 15.7 so that

The normalized sum is built bottom-up;

The order of the elements is reversed. (iii)

Enhance Program 15.7 so that numbers appearing in the addends

are added together and returned as the first component of the nor-

malized sum, For example, (3 + X) + 2 + (y + 4) should be normal-

ized to 9 + (X + y). (iv)

Write a program to normalize products using difference-products,

defined analogously to difference-sums.

<!-- page 335 -->
15.3 Dictionaries A different use of incomplete data structures enables the implementation of dictionaries. Consider the task of creating, using, and maintaining a set of values indexed under keys. There are two main operations we would like to perform: looking up a value stored under a certain key, and entering a new key and its associated value. These operations must ensure consistency - for example, the same key should not appear twice lookup (Key,Dictionary, Value) -

Dictionary contams Value mdexed under Key.

Dictionary is represented as an incomplete

list of pairs of the form (Key,Value).

```prolog
lookup(Key, [(Key,Value) IDict] ,Value).
lookup(Key, [(Keyl,Valuel)IDict] ,Value) -
    Key
          Keyl, lookup(Key,Dict,Value).
```

Program 15.8

Dictionary lookup from a list of tuples

with two different values. It is possible to perform both operations, looking up values of keys, and entering new keys, with a single simple procedure by exploiting incomplete data structures.

Consider a linear sequence of key-value pairs. Let us see the advantages of using an incomplete data structure for its representation. Program 15.8 defines the relation `lookup(Key,Dictionary,Value)` which is true if the entry under `Key` in the dictionary `Dictionary` has value `Value.` The dictionary is represented as an incomplete list of pairs of the form

```prolog
(Key,Value).
```

Let us consider an example where the dictionary is used to remember phone extensions keyed under the names of people. Suppose that `Dict is` initially instantiated to

```prolog
[(arnold, 8881) , (barry,4513) , (cathy, 5950)
```

`Xs].` The query `lookup(arnold,Dict,N)?` has as answer `N=8881` and is used for finding Arnold's phone number. The query `lookup(barry,` `Dict,4513)?` succeeds, checking that Barry's phone number is 4513.

The entry of new keys and values is demonstrated by the query `lookup(david,Dict,1199)?.` Syntactically this appears to check David's phone number. Its effect is different. The query succeeds, instantiating

```prolog
Dict to
         [(arnold,8881),(barry,4513),(cathy,5950),(david,1199)
```

Xsl]. Thus `lookup` has entered a new value.

What happens if we check Cathy's number with the query `lookup` `(cathy,Dict,5951)?,` where the number is incorrect? Rather than entering a second entry for Cathy, the query fails because of the test `Key`

```prolog
Keyl.
```

<!-- page 336 -->
The `lookup` procedure given in Program 15.8 completes Program 14.15, the simplified ELIZA. Note that when the program begins, the dictionary is empty, indicated by its being a variable. The dictionary is built up lookup (Key,Dictionary, Value) -

Dictionary contains Value indexed under Key.

Dictionary is represented as an ordered binary tree.

```prolog
lookup(Key,dict(Key,X,Left,Right),Value)
    !, X
          Value.
lookup(Key,dict(Keyl,X,Left,Right),Value) -
    Key < Keyl, lookup(Key,Left,Value).
lookup(Key,dict(Keyl,X,Left,Right),Value)
    Key > Keyl, lookup(Key,Right,Value).
```

Program 1.9 Dictionary lookup in a binary tree

during the matching against the stimulus half of a stimulus-response pair. The constructed dictionary is used to produce the correct response. Note that entries are placed in the dictionary without their values being krown: a striking example of the power of logical variables. Once an integer is detected, it is put in the dictionary, and its value is determined later.

Searching linear lists is not very efficient for a large number of keyvalue pairs. Ordered binary trees allow more efficient retrieval of information than linear lists. The insight that an incomplete structure can be used to allow entry of new keys as well as to look up values carries over to binary trees.

The binary trees of Section 3.4 are modified to be a four-place structure

```prolog
dict(Key,Value,Left,Right), where Left and Right are, respectively,
```

the left and right subdictionaries, and `Key` and `Value` are as before. The functor `dict` is used to suggest a dictionary.

Looking up in the dictionary tree has a very elegant definition, similar in spirit to Program 15.8. It performs recursion on binary trees rather than on lists, and relies on unification to instantiate variables to dictionary structures. Program 15.9 gives the procedure `lookup(Key,Dictio-` `nary,Value),` which as before both looks up the value corresponding to a given key and enters new values.

<!-- page 337 -->
At each stage, the key is compared with the key of the current node. If it is less, the left branch is recursively checked; if it is greater, the right branch is taken. If the key is non-numeric, the predicates < and > must be generalized. The cut is necessary in Program 15.9, in contrast to freeze(A,B) -

Freeze term A into B.

```prolog
freeze(A,B) -
    copy_term(A,B), numbervars(B4O,N).
```

me!t_new(A,B) -

Melt the frozen term A into B.

```prolog
melt_new(A,B) -
    melt(A,B,Dictionary),
melt('$VAR' (N) ,X,Dictionary)
    lookup(N,Dictionary,X).
melt(X,X,Dictionary)
    constant (X)
melt (X, Y ,Dictionary)
    compound(X),
    f unctor (X , F , N)
    f unctor (Y ,F , N)
    melt(N,X,Y,Dictionary).
melt(N,X,Y,Dictionary) -
    N > O,
    arg(N,X,ArgX),
    melt(ArgX,ArgY,Dictionary),
    arg(N,Y,ArgY),
    Nl is N-1,
    melt (Nl ,X,Y,Dictionary).
melt (O,X,Y,Dictionary).
numbervars(Term,Nl ,N2)
                      '- See Program 10.8.
lookup(Key,Dictionary,Value)
                              See Program 15.9.
```

Program 13.10 Meltmg a term

Program 15.8, because of the nonlogical nature of comparison operators, which will give errors if keys are not instantiated.

Given a number of pairs of keys and values, the dictionary they determine is not unique. The shape of the dictionary depends on the order in which queries are posed to the dictionary.

<!-- page 338 -->
The dictionary can be used to melt a term that has been frozen using Program 10.8 for numbervars. The code is given as Program 15.10. Each melted variable is entered into the dictionary, so that the correct shared variables will be assigned. 15.4 Queues An interesting application of difference-lists is to implement queues. A queue is a first-in, first-out store of information. The head of the difference-list represents the beginning of the queue, the tail represents the end of the queue, and the members of the difference-list are the elements in the queue. A queue is empty if the difference-list is empty, that is, if its head and tail are identical.

Maintaining a queue is different from maintaining a dictionary. We consider the relation queue(s), where a queue processes a stream of commands, represented as a list S. There are two basic operations on a queueenqueuing an element and dequeuing an elementrepresented, respectively, by the structures enqueue (X) and dequeue (X), where X is the element concerned.

Program 15.11 implements the operations abstractly. The predicate queue(s) calls queue(S,Q), where Q is initialized to an empty queue. queue/2 is an interpreter for the stream of enqueue and dequeue commands, responding to each command and updating the state of the queue accordingly. Enqueuing an element exploits the incompleteness of the tail of the queue, instantiating it to a new element and a new tail, which is passed as the updated tail of the queue. Clearly, the calls to enqueue and dequeue can be unfolded, resulting in a more concise and efficient, but perhaps less readable, program.

queue(S)

S is a sequence of enqueue and dequeue operations,

represented as a list of terms enqueue(X) and dequeue(X).

```prolog
queue(s)
           queue(S,Q\Q).
queue([enqueue(X) XsJ ,Q)
    eriqueue(X,Q,Q1), queue(Xs,Q1).
queue([dequeue(X)IXs] ,q)
    dequeue(X,Q,Q1), queue(Xs,Q1).
queue([ ],Q).
enqueue(X,Qh\[XIQt] ,Qh\Qt).
dequeue(X, [XIQh]\Qt,Qh\Qt).
```

Program 1S.11

<!-- page 339 -->
A queue process flatten(Xs,Ys) -

Ys is a flattened list containing the elements in Xs.

```prolog
flatten(Xs,Ys) - flatten_q(Xs,Qs\Qs,Ys).
flatten_q([XIXs) ,Ps\[XslQs] ,Ys) -
    flatten_q(X,Ps\Qs,Ys).
flatten_q(X, [QIPs]\Qs, [XIYs]) -
    constant(X), X[ I,
                       flatten_q(Q,Ps\Qs,Ys).
flatten_q([ ],Q,Ys) -
    non_empty(Q), dequeue(X,Q,Q1), flatten_q(X,Q1,Ys).
flatten_q([ ],[ I\[ ],[ 1).
non_empty([ ]\[ 1) - !,
                       fail.
non_empty (Q)
dequeue(X, [XIQh]\Qt,Qh\Qt).
```

Program 15.12

Flattening a list using a queue

The program terminates when the stream of commands is exhausted. It can be extended to insist that the queue be empty at the end of the commands by changing the base fact to

```prolog
queue([ I,Q)
                 empty(Q).
```

A queue is empty if both its head and tail can be instantiated to the empty list, expressed by the fact `empty ( [`

`]` \ E ]). Logically, the clause `empty (Xs\Xs)` would also be sufficient; however, because of the lack of the occurs check in Prolog, discussed in Chapter 4, it may succeed erroneously on a nonempty queue, creating a cyclic data structure.

We demonstrate the use of queues in Program 15.12 for flattening a list. Although the example is somewhat contrived, it shows how queues can be used. The program does not preserve the order of the elements in the original list.

The basic relation is `flatten_q(Ls,Q,Xs),` where `Ls` is the list of lists to be flattened, Q is the queue of lists waiting to be flattened, and Xs is the list of elements in `Ls.` The initial call of `f latten_q/3` by `f latten/2` initializes an empty queue. The basic operation is enqueuing the tail of the list and recursively flattening the head of the list:

```prolog
flatten_q(EXIXs],Q,Ys)enqueue(Xs,Q,Q1), flatten._q(X,Q1,Ys).
```

<!-- page 340 -->
The explicit call to `enqueue` can be omitted and incorporated via unification as follows:

```prolog
flatten_q([XIXs] ,Qh\[XsIQt] ,Ys) - flatten_q(X,Qh\Qt,Ys).
```

If the element being flattened is a constant, it is added to the output structure being built top-down, and an element is dequeued (by unifying with the head of the difference-list) to be flattened in the recursive call:

```prolog
flatten_q(X, [QIQh]\Qt, [XIYs]) -
    constant(X), X[ ]
                         ,
                           flatten_q(Q,Qh\Qt,Ys).
```

When the empty list is being flattened, either the top element is dequeued

```prolog
flatten_q([ ],Q,Ys)
    non_empty(Q), dequeue(X,Q,Q1), flattenq(X,Q1,Ys).
```

or the queue is empty, and the computation terminates:

```prolog
flatten_q([ ],[ ]\[ ],[ ]).
```

A previous version of Program 15.12 incorrectly expressed the case when the list was empty, and the top element was dequeued as

```prolog
flatten_q([ ],[QIQh]\Qt,Ys) - flatten_q(Q,Qh\Qt,Ys).
```

This led to a nonterminating computation, since an empty queue `Qs\Qs` unified with [QIQh] \Qt and so the base case was never reached.

Let us reconsider Program 15.11 operationally. Under the expected use of a queue, `enqueue(X)` messages are sent with `X` determined and `de-` `queue (X)` with X undetermined. As long as more elements are enqueued than dequeued, the queue behaves as expected, with the difference between the head of the queue and the tail of the queue being the elements in the queue. However, if the number of dequeue messages received exceeds that of enqueue messages, an interesting thing happens - the content of the queue becomes negative. The head runs ahead of the tail, resulting in a queue containing a negative sequence of undetermined elements, one for each excessive dequeue message.

<!-- page 341 -->
It is interesting to observe that this behavior is consistent with the associativity of appending of difference-lists. If a queue `qs\[X1,X2,X3Qs]` that contains minus three undetermined elements has the queue `[a, b,` `c,d,ejXs]\Xs` that contains five elements appended to it, then the result will be the queue

`[d, e Xs] \Xs` with two elements, where the "negative" elements X1,X2,X3 are unified with `a,b,c.`

15.5 Background Difference-lists have been in the logic programming folklore since its inception. The fifst description of them in the literature is given by Clark and Tarniund (1977).

The automatic transformation of simple programs without differencelists to programs with difference-lists, for example, `reverse` and `f lat-` `ten,` can be found in Bloch (1984).

Section 15.1 implicitly contains an algorithm for converting from a program with explicit calls to `append` to an equivalent, more efficient program that uses difference-lists to concatenate the elements and which is much more efficient. Care is needed in application of the algorithm. There are excellent discussions of a correct algorithm and the dangers of using difference-lists without the occurs check in Sondergaard (1990) and Marriott and Søndergaard (1993).

There is an interesting discussion of the Dutch flag problem in O'Keefe (1990).

Automatic removal of a functor denoting difference-lists is described in Gallagher and Bruynooghe (1990).

Maintaining dictionaries and queues can be given a theoretical basis as a perpetual process, as described by Warren (1982) and Lloyd (1987).

Queues are particularly important in concurrent logic programming languages, since their input need not be a list of requests but a stream, which is generated incrementally by the processes requesting the services of the queue.
