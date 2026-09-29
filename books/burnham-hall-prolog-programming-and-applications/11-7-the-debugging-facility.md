# 7 The Debugging Facility

<!-- page 96 -->
These predicates are provided in order to enable the user to watch the flow of the program, and hence remove any bugs that may be present. In order to understand the discussion of the debugging predicates later in the chapter you will find it helpful to be familiar with the "box model" for control flow in a Prolog program, which is outlined below.

## 7.1 The box model

To explain the box model for control flow we first have to assume that every Prolog procedure is contained inside an imaginary box. An example is given below for the procedure apple and concatenate.

```prolog
apple (X) :- object (X, round),
          colour (X, green).
cone (A, [] ,A).
cone (A, [HIT], D) :- cone ([HIA], T, D).
```

We now assume that the box is closed and that we may enter or leave the box only under certain conditions. So under what circumstances will we want to enter the box? Well, we will want to enter the box when we are trying to satisfy goals that involve the clauses contained in the box. That is when we invoke or call the procedure. A CALL label is therefore placed as an entrance to the box as shown below with the procedure cone.

CALL __

cone (A, [], A).

cone (A, [HIT], D) :-eone (HIA] , T, D).

This type of entry would take place when a call is made as an attempt to satisfy part of a rule or as a direct request from the user's terminal. For example

```prolog
?-cone ([a, b, e], [d, e, f], V).
```

<!-- page 97 -->
Once we have entered the procedure box we have to try and satisfy the W. D. Burnham et al., *Prolog Programming and Applications* © W. D. Burnham and A. R. Hall 1985 procedure before we can attempt to get out of the box. As we know, when we try to satisfy the procedure we will either succeed and we will exit the procedure, or it will fail. To summarise, we leave the EXIT port of the box if the procedure call was successful and we leave the FAIL port if the attempt to satisfy the procedure was unsuccessful, as shown below.

**CALL -* I**

".meed",,"

**I**

FAIL +-

L.*_______ ---.l* -* EXIT

We must now cover the possibility that Prolog has previously satisfied the procedure but is forced to reconsider it by the failure of a subsequent goal. This option is provided by including a REDO port on the model as shown.

**CALL -* I**

**I +- REDO**

"procedure"

FAIL +-

-* EXIT

~----------------~

We have now defined the basic box model, used to represent the control of the Prolog program.

To provide compatibility with the DEC-IO debugger we must also provide an invocation number and a number which represents the depth of invocation. The invocation number appears in parentheses on the debugging messages, and is a number assigned to a box when it is entered by the CALL port. The first box to be entered will be assigned an invocation number of I, the second 2 and so on. Note that these boxes could be the same box called as part of a recursive procedure. Two examples are given below; the first shows how the box model works with a recursive procedure, the second shows how it works when backtracking takes place.

The depth of invocation number may be thought of as giving the number of rules that have to be satisfied, in order to prove the initial enquiry from the top level of the Prolog system. That is, it gives the number of ancestors of that particular goal. Referring to the examples, notice how the cone predicate has to prove 4 rules in order to satisfy the initial enquiry, whereas the apple predicate only needs to prove I rule.

*Examples*

The knowledge base is as follows

cone (A, [] , A).

```prolog
cone (A, [HIT], D) :- cone ([HIA], T, D).
fruit (victoria_plum).
fruit (granny_smith).
shape (victoria_plum, round).
shape (granny_smith, round).
```

<!-- page 98 -->
colour (victoria_plum, purple). colour (granny_smith, green), apple (X) :-fruit (X), shape (X, round), colour (X, green).

The following are the output from the debugger in response to the questions shown

?-conc ([a, b, c, d], [e, f, g, h], P).

**(1) t' Call: cone ([a, b, c, d], [e, f, g, h], _75)**

(2) 1 Call: cone ([e, a, b, c, d], [f, g, h], _75)

(3) 2 Call: cone ([f, e, a, b, c, d], [g, h] ,_75)

(4) 3 Call: cone ([g, f, e, a, b, c, d], [h] ,_75)

(5) 4 Call: cone ([h. g. f. e. a. b, c, d], [] ,_75)

(5) 4 Call: cone ([h, g, f, e, a, b, c, d], [] , [h, g, f, e, a, b, c, d])

(4) 3 Exit: cone ([g, f, e, a, b, c, d], [h], [h, g, f, e, a, b, c, d])

(3) 2 Exit: cone ([f, e, a, b, c, d], [g, h], [h, g, f, e, a, b, c, d])

(2) 1 Exit: cone ([e, a, b, c, d], [f, g, h], [h, g, f, e, a, b, c, d])

**(1) t' Exit: conc ([a, b, c, d], [e, f, g, h], [h, g, f, e, a, b, c, d])**

p = [h, g, f, e, a, b, c, d]

**(1) t' Call: apple L24)**

(2) 1 Call: fruit L24)

(2) 1 Exit: fruit (victoria_plum)

(3) 1 Call : shape (victoria_plum, round)

(3) 1 Exit: shape (victoria_plum, round)

(4) 1 Call: colour (victoria_plum, green)

(4) 1 Fail: colour (victoria_plum, green)

(3) 1 Redo: shape (victoria_plum, round)

(3) 1 Fail: shape (victoria_plum, round)

(2) 1 Redo: fruit (victoria_plum)

(2) 1 Exit: fruit (granny_smith)

(5) 1 Call: shape (granny_smith, round)

(5) 1 Exit: shape (granny_smith, round)

(6) 1 Exit: shape (granny_smith, round)

(6) 1 Call: colour (granny_smith, green)

(6) 1 Exit: colour (granny_smith, green)

**(1) t' Exit : apple (granny_smith)**

X = granny_smith

## 7.2 The debugging predicates

<!-- page 99 -->
Although the debugging predicates referred to here are written according to the DEC-lO implementation of Prolog, you should find that with reference to this section and the appropriate User Manual, you will be able to successfully use the debugging facilities on many Prolog interpreters.

In the above two examples you have seen the format of the debugging messages you will receive. In this section we will discuss how to use the standard features of the debugger to assist you in removing bugs from your program.

To switch on the debugging facility the system predicate debug is used. To switch the debugger off the predicate nodebug is used. You should bear in mind for later in this section that nodebug also removes any "spy points" you set in your program. Spy points are a debugging aid that we will discuss shortly. Another predicate you will find useful during extensive debugging sessions is the system predicate debugging which will return information about the current state of the debugging facility. For example

yes

```prolog
?- debugging.
```

Action on unknown procedures: fail

Debug mode is switched on.

Spy-points set on:

shape/2

Leashing set to half (call, redo).

Again do not worry about leashing, we will be talking about it soon.

*7.2.1 Tracing*

Let us suppose that you have written your program, and then you find that it does not work (a common problem!), and you wish to use the debugger to assist in finding the problems. One of the options open to you would be to produce a complete listing of the program flow through all of the procedure boxes called. You can do this using the system predicate trace. If the debugger is not already switched on, using debug causes the debugger to be activated, and ensures that the next time a procedure box is entered a prompt will be received. At this point a number of control options are available, which will vary according to the system you are using. These may include 'creeping', 'leaping' or 'skipping' through the program.

*7.2.2 Creeping*

<!-- page 100 -->
In this mode the interpreter single steps through the program, stopping at the next leashed port (we will talk about leashing shortly) to print out a debugging message and prompt the user. This control is performed using a carriage return command. *7.2.3 Leaping*

In this mode the interpreter continues its execution of the program, until a spy point is reached or the program ends. This control is performed using a line feed command.

*7.2.4 Skipping*

This control is valid only at CALL and REDO ports. It causes theinterpreter to perform the execution of the procedure within the box being entered, without producing any debugging messages or user prompts. The user is prompted again when theprocedure is exited or failed. The control is performed using the escape command. When a trace is performed the debugger will output to indicate that a skip was performed when the user was given a chance to interact at one of the ports of a given procedure box. For example, the message could be of the form

**> (13) 1 Exit: colour (granny_smith, green).**

*7.2.5 Disabling the trace facility*

To disable the trace facility the predicate notrace is used. Notice that the predicate trace can be used part way through a program, by interrupting the program (using "C). However if information about the program flow before trace is called is required, the debug mode must have been on from the start of the program execution or the information will be lost.

*7.2.6 Leashing*

<!-- page 101 -->
Now that you are able to set up exhaustive tracing using the trace predicate, you will probably want to alter the ports at which you are prompted for action. As we have mentioned before, this is done by leashing the ports you wish to be prompted at. The predicate leash (X) is used to alter the degree of leashing on all procedure boxes. The variable X may be an integer in the range 0 to 15 or a description of the leashing (for example full, half etc.). The integers and corresponding description, if any, are given below along with their effect on the leashing of the procedure boxes. PROMPTON DESCRIPTION X CALL EXIT

REDO

FAIL off 0 no no

no

no 1 no no

no

yes 2 no no

yes

no 3 no no

yes

yes 4 no yes

no

no 5 no yes

no

yes 6 no yes

yes

no 7 no yes

yes

yes loose 8 yes no

no

no 9 yes no

no

yes half 10 yes no

yes

no tight 11 yes no

yes

yes 12 yes yes

no

no 13 yes yes

no

yes 14 yes yes

yes

no full 15 yes yes

yes

yes

Thus if we wish to obtain a prompt on only the CALL port of a procedure box we could use either

leash (loose). or leash (8).

The default setting for leash is usually half, that is prompts on CALL and REDO.

*7.2.7 Spy points*

Clearly using the trace facility will be very useful if small sections of your program are to be debugged, or you have only a small program. However, for large programs this method of debugging would be extremely time consuming and complicated. A higher level of debugging is available which allows you to look at the control flow through certain procedures. This is done by setting 'spy points' on the procedures you are interested in. Placing a spy point on a procedure causes a debugging message and a prompt to appear when control passes into a procedure box with a spy point placed on it. The spy points are placed using the system predicate spy (X), where X is the procedure of interest. The variable X may be of the form

**<atom>**

**or**

**<atom>I<arity>**

<!-- page 102 -->
where the arity is the number of arguments the particular predicate has. For example, suppose that we had the following program in the knowledge base

sharp (X) :-knife (X).

sharp:-citrus_fruit.

Then the declarations spy (sharp/I)., spy (sharp/"). and spy (sharp). would have the following effects

spy (sharp/I). spy (sharp/'). spy (sharp).

would placea spy point on sharp (X)

would place a spy pOint on sharp

would place a spy point on both sharp and sharp (X)

Thus specifying the predicate without an arity places spy points on all procedures of that name, regardless of the arity.

To remove spy points from particular procedures the predicate nospy (X) can be used. For example

nospy (sharp/I).

However if you wish to remove all spy points an easier method is to use the predicate nodebug. Placing spy points on a procedure causes the prompt to appear on the output when tracing the program flow to indicate that a spy point is placed on that particular procedure. For example

**** (3) I Call : shape (victoria_plum, round) ?**

If the procedure has a spy point placed on it and if a skip had been performed on the previous occasion when control was exercised at the port of that procedure box, the trace message would be preceded by the symbols *>. An example is shown below

***> (3) I Fail : shape (victoria_plum, round).**
