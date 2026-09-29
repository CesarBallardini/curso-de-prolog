# 4 Lists and Complex Structures

<!-- page 58 -->
## 4.1 Lists in Prolog

Lists are an important tool in modern mathematics and symbolic computing. Those of you who are familiar with them will know that lists are an essential structure in the LISP language. Our objective here is to show how lists can be used to enhance the power and scope of Prolog programs.

First then, what is a list? In simple terms it is a sequence of single elements that may (and in practical programming, often do) bear some relation to each other. Here are some examples of lists

(i) a,b,c,d,e

(ii) lion, tiger, puma, lynx

(iii) f,r,3,X,y,z

As you can see, (i) and (ii) are lists which contain members of a particular category - letters of the alphabet and big cats respectively. The third example is a collection of constants, integers and variables. Any syntactically correct Prolog element (constant, variable or structure) may appear in a Prolog list; this includes the case where one list is part of another as we shall see.

## 4.2 The structure of lists

The value of lists in a Prolog program is reduced if we cannot address the individual elements that go to make up the list. For that reason, it is necessary to use the concept of splitting the list intotwo parts, the *head* and the *tail.* The *head* of the list is the first element of the list. The *tail* of the list is the remainder of the list whatever it may contain.

This is how the idea works. The list lion, tiger, lynx, puma is split into head and tail as follows

**head =lion**

tail = tiger, lynx, puma

<!-- page 59 -->
It is worth stating that *the tail of the list* is *itselfa list;* this is important. W. D. Burnham et al., *Prolog Programming and Applications* © W. D. Burnham and A. R. Hall 1985

The list

sid, doris

is split as follows

head = sid

tail = doris

Following on from the previous example, where it was stated that the tail of a list is itself a list, you might ask whether it is also the case when the tail has only a single element. The answer is yes, a single element can still be seen as a list.

The next obvious question, then, is whether it is possible to split a single element list into a head and a tail. Again the answer is yes, but in order to do so we need to introduce another important idea, the *empty list.* If it was necessary to split a single element list (for example,john), into a head and a tail, it could be done as follows

head = john

**tail =the empty list**

Logically the empty list is somewhat akin to the more familiar concepts of zero, the empty set and the void. It is a useful and necessary concept in the use of lists within Prolog programs. From the previous examples you can deduce that a list with no elements presents us with no logical problems and we can just designate it as the empty list.

## 4.3 Special list notation

In order to make practical use of the ability to split lists into head and tail, Prolog provides a special notation with which to define lists in programs. There are two special symbols which are used.

(1) The square open/close brackets These are used to denote the beginning and end of a list respectively. For example

[a, b, c, d)

[lion, tiger, lynx, puma]

[X]

<!-- page 60 -->
The empty list is represented as [] .

(2) The separator symbol This is written as : and is used to allow a list to be represented as a head and a tail. The element to the left of the separator is taken as the head of the list, that to the right as the tail of the list. Thus to represent a list as two variables, the head and the tail, it is possible to write it as

[HiT]

using the separator symbol to define the split representation.

## 4.4 Using lists and list notation

The best way to show how lists and their contents may be accessed in a Prolog program is to simulate an example terminal session. Here we will assume that our knowledge base consists only of a single clause with the predicate letters taking, as the single argument, the list [a, b, c, d] . The assertion would be represented as follows

letters ([a, b, c, dD.

Now we will perform some simple operations on the list.

*User*

letters (X).

letters ([HIT]).

letters ([X, YITD.

letters ([HU ).

letters ([_, [HIT] D.

**... (session ends)**

*Prolog* ?- X=[a,b,c,d] ?- H=a T= [b,c,d] ?- X=a Y=b T= [c,d] ?- H=a ?- H=b T= [c,d]

## 4.5 Exercise 9

A knowledge base contains these clauses

<!-- page 61 -->
fish ([shark, pike, salmon, cod]). birds ([hawk, dove, sparrow, canary]). and the following questions are asked by the user

(i) fish ([H:T]).

(ii) birds (UT]).

(iii) birds ([HI, H2:T]).

(iv) birds (Birds).

(v) fish ([shark, X, salmon, Y].

(vi) birds (X, Y, Z).

What answers will the system return?

## 4.6 Incorporating more complex data structures in lists

Those of you familiar with LISP will have noticed that the head-tail notation is very closely allied to the LISP intrinsics CAR and CDR. (Do not worry if you do not know LISP, the point is incidental.) It is important that you understand how to access and manipulate the contents of lists and you should be sure that you can complete and understand exercise 9 before you proceed with this section.

Up to now we have used as examples lists which have *atoms* as their members. However, it is equally possible to construct lists which have more complex structures as members. For example

employee_record (smith, [john, [sales, manager], london, [january, 1982]]).

employee_record (brown, [jim, [prod, manager], luton, [june, 1983]]).

Thus the predicate employee_record (used here to hold a small personnel database) takes two arguments, the first the name of the employee, the second the list containing details about the employee. Here is an example terminal session to illustrate how the information contained in the list could be accessed.

*User*

employee_record (Name, Details).

*Prolog* ?- Name =smith Details = [john, [sales, manager], london, [january, 1982] ] ?-

**employee_record (brown, L, Title,**

Base,-l).

**... (session ends)**

Title = [prod, manager] Base = luton

<!-- page 62 -->
Note that the format of the first question assigns the value of the complete details list to the second argument. However, the second question demonstrates the flexibility of the list structure for storing data, in that although the list represents only one argument to the employee_record predicate, the structure of that argument can itself be analysed by Prolog as shown in the example. This is an invaluable technique that can be used to great effect in the writing of complex programs.

## 4.7 Manipulating the contents of lists

The basis for success with these techniques is an understanding of the structure of lists (that is, the head - tail concept), and the application of recursion.

First, consider the question of whether or not a single element is an entry in a given list. To begin with we know that an element which represents the head of a list must be an entry in that list and we can use that property to write a boundary condition as follows

```prolog
entry (E, L) :- L = [EU.
```

which states that "E is an entry in a list L, if L is made up of a head E and any tail" (hence the blank variable).

Now that you have thoroughly understood the list structure and the way in which Prolog works, you can probably see a more elegant way of writing the first clause of the procedure, that is

entry (E, [EU).

From now on we shall adopt this more compact format for these types of clauses.

So far we have dealt with the simple case where the head of a list is an entry in it. Now we need a second (recurSive) clause which will allow all other entries to be identified. To construct that rule we use the property that any entry in the tail of a list must also be an entry in the list itself

```prolog
entry (E, UTD :- entry (E, T).
```

"E is an entry in a list if the list comprises any head and a tail T, which con· tains E".

Taking the pair of clauses defining the procedure

entry (E, [ELD.

```prolog
entry (E, [_IT)) :- entry (E, T).
```

we will trace the resolution of the question

```prolog
?- entry (E, [a, b, c]).
```

<!-- page 63 -->
(i) The first solution is found by matching on the first clause, where the variable E is instantiated to the head of the list [a, b, c] , that is, a. (li) Ifwe ask for another solution by entering the; prompt it is clear that the first clause cannot directly provide it because E=a has already been returned. The search process therefore continues with the second clause wherein T is instantiated to [b, c] . It is important to understand that the recursive structure of the second clause now 'forces' a return to the first clause. However, after the second clause has been invoked the second argument to the first clause has changed. The list on which the fust clause now has to operate has been changed from [a, b, c] to [b, c] and the head of the list now takes the value b, thereby allowing a second solution, b, to be generated. The third and last solution is generated in a similar manner to produce the answer E =c. Notice that the second clause can never directly provide a solution; its function is to remove successive heads from the front of the list before forcing a return to the first clause, which can then provide successive solutions.

4. 7.1 *Using entry to define other useful rules*

We are now going to use the rules for entry to define the idea of membership of a particular category. Consider the small knowledge base

employees (manager, [brown,jones, smith]).

employeeds (clerical, [whyte, payne, clare]).

employees (manual, [hempstead, burnham, hall]).

In order to establish an individual as, for example, a manager we can see that it is first necessary to establish the category manager, and second to search the list of managers. This is one method of achieving this

```prolog
manager (M) :- employees (manager, L),
             entry (M, L).
```

(entry is defined as shown previously).

Furthermore, we can see that an employee is a wider category, that is, an employee is an entry in anyone of the three lists we have specified. We can defme an employee as follows

```prolog
employee (E) :- employees C, L),
             entry (E, L).
```

*4.7.2 Joining two lists together*

<!-- page 64 -->
Suppose we want to join (or concatenate) two lists. For example we may wish to take the two lists [a, b, c] and [d, e, f] and join them to form the list [a, b, c, d, e, f]. Here is one method of achieving this

concatenate ([] , X, X).

```prolog
concatenate ([H X] , Y, [H Z]) :- concatenate (X, Y, Z).
```

Thus the question

```prolog
?- concatenate ([a, b, c], [d, e, f], L).
```

will elicit the response

L= [a,b,c,d,e,f]

The procedure works by recursively removing the head of the first list [a, b, c]. So the first time the procedure is called the element a is removed from the list, the second time b is removed and so on. This recursive calling continues because of the rule definition and is terminated when a match takes place with the first clause in the rule, that is concatenate ([], X, X). When this match takes place we have proved that the last head to be removed from the first list becomes the head of the result. As the recursive loop is exited the successive heads of the first list are added to the resultant list L.

*4.7.3 Determining the nth term of a list*

Here we wish to find out which element in a list is in the nth pOSition. For example we may wish to access the third element. This can be done by removing N elements of a list recursively. The variable R keeps track of how many elements have been removed. When R = 1, then X is assigned to the Nth element.

nth (X, I, [XL]).

```prolog
nth (X, N, UL]) :- R is N-I,
                nth (X, R, L).
```

There are many more of these kinds of rules that can be applied to lists. Here are some for you to try.

## 4.8 Exercise 10

(i) Define the last entry in a list. (ii) Remove an element of a list from that list leaving a new list (for example,

<!-- page 65 -->
remove (a, [b, a, c], L) gives L = [b, c].

## 4.9 Solutions to exercises

*Exercise 9*

**(i) H =shark**

**T =[pike, salmon, cod]**

**(ii) T =[dove, sparrow, canary]**

(iii) HI = hawk

**H2 =dove**

T = [sparrow, canary] (iv) Birds =[hawk, dove, sparrow, canary]

**(v) X =pike**

y= cod (vi) This is an incorrect question format.

*Exercise 10*

(i) last (X, [X]).

last (X, LlL] :-last (X, L). (ii) remove (X, [XIT] , L) :- remove (X, T, L), !.

remove (X, [XIT] , T).

```prolog
remove (X, [H:TJ, [HIL]) :- remove (X, T, L).
```

*Suggested project*

Use the features of lists and the procedures for manipulating their contents to set up and maintain a small database about something of interest to you.
