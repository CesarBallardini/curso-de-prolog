# D Code to Support DCGs

<!-- page 303 -->
Code to Support DCGs

```prolog
The Prolog standard does not specify that a Prolog implementation should provide
translation from DCG rules into Prolog, though in practice many implementations
do. The following Prolog program may be useful for people wishing to use DCGs
if their implementations do not support this. Apart from the predicates phrase/2,
phrase/3 and (updateable) 'C'/3, it provides a predicate g/1 to consult a file contain-
ing grammar rules (and possibly ordinary Prolog as well).
The g/1 predicate works by reading in the file and writing it out to a file dcg.tmp with
any grammar rules translated into ordinary Prolog. Then that file is consulted nor-
mally. Obviously a user should not be using a file dcg.tmp for something else. Any
directives in the original file are simply copied to dcg.tmp so that they are obeyed
when this is consulted. Since they are not obeyed on the first reading of the file, any
operator declarations necessary for reading the file have to be made before g is called.
The code assumes that —> is already declared as an operator, as if by:
    ?- op(1200,xfx,-->).
and that the Prolog reader reads a term of the form {...} as '{}'(...) (where the argu-
ment can use operators like ,/2 and ;/2 without having to enclose the terms in extra
parentheses). Both of these should be the case in an implementation conforming to
the standard. The comments at the start of the code suggest how one might be able
to fix things in an implementation that was non-standard in this respect.
```

<!-- page 304 -->
**D.l DCG Support Code**

```prolog
% DCG code for Programming in Standard Prolog
```

%

```prolog
% The following is part of Standard Prolog, but some Prolog
% systems may need it:
```

%

```prolog
?- op(1200,xfx,-->).
```

%

```prolog
% {...} is dealt with specially in the syntax of Standard Prolog,
% but in case it is not recognised, the following could be a way
% of having { and } be standard operators. However, any conjunctions
% and disjunctions inside {...} will have to be inside extra
% parentheses with spaces around the { and }, e.g. { (a(X), b(Y)) } .
%
?- op(901,fx/{').
?- op(900,xf,'}').
% g(File)
%
% Consult a file File that may contain grammar rules. The
% predicate creates a new file dcg.tmp with the translated
% version of the original file and then consults that.
% The file can contain ordinary Prolog clauses as well, but
% any necessary operator declarations must be made before g is called
% (it does not obey any directives when the file is first read).
9(File) :-
  open(File,read,In),
  setjnput(ln),
  open('dcg.tmp', write,Out),
  set_output(0ut),
  repeat,
    read(Term),
    output_with_translation(Term),
    Term = end_of_file,
    i
    .,
  close(Out),
  close(In),
  consult('dcg.tmp').
```

<!-- page 305 -->
Appendix D Code to Support DCGs

```prolog
  % output_with_translation(Term)
  %
  % Outputs Term (in such a way that it can be read in as a clause)
  % after translating it (if it happens to be a grammar rule)
  output_with_translation(end_of_file):-!.
  output_with_translation((X~>Y)) :- !,
    translate((X—>Y),Z),
    write_canonical(Z), write('.'), nl.
  output_with_translation(X) :-
    write_canonical(X), write(7), nl.
% translate(+In,-Out)
%
% Translate a grammar rule
%
translate(((LHSJnl,LHS_in2) ~ > RHSJn), (LHS_out:- RHS_out)) :- !,
  nonvar(LHSJnl),
  islist(LHS_in2),
  tag(LHS_inl,SO,Sn,LHS_out),
  make_connects(LHS_in2,Sn,Sl,Conn),
  dcg_rhs(RHS_in,SO,Sl,RHS_l),
  dcg_and(Conn,RHS_l,RHS_2),
  flatten2(RHS_2,RHS_out).
translate((LHS_in - > RHSJn), (LHS_out:- RHS_out)) :-
  nonvar(LHSJn),
  tag(LHSJn,SO,Sn,LHS_out),
  dcg_rhs(RHSJn,SO,Sn,RHS_l),
  flatten2(RHS_l,RHS_out).
% dcg_rhs(+RHS,SO,SI,-Translation)
%
% Translate the RHS of a grammar rule into a
% conjunction of Prolog goals. SO and S i are
% variables to be used for the input and output
% list arguments of the whole conjunction (these
% are the variables used for the input and output
% list arguments for the head of the clause)
dcg_rhs(X, SO, S, phrase(X,SO,S)) :- var(X), !.
```

<!-- page 306 -->
```prolog
dcg_rhs((RHS_inl,RHSJn2),S0,Sn,RHS_out):- !,
   dcg_rhs(RHS_inl,SO,Sl,RHS_outl),
   dcg_rhs(RHS_in2,Sl,Sn,RHS_out2),
   dcg_and(RHS_outl,RHS_out2,RHS_out).
dcg_rhs((RHS_inl;RHS_in2),S0,Sn,(RHS_outl;RHS_out2)):- !,
   dcg_or(RHS_inl,SO,Sn,RHS_outl),
   dcg_or(RHS_in2,S0,Sn,RHS_out2).
dcg_rhs({RHS_in},SO,SO,RHS_in) :- !.
dcg_rhs(!,S0,S0,!) :- !.
dcg_rhs(RHS_in,SO,Sn,C) :-
                            % terminal(s)
   islist(RHSJn), !,
   make_connects(RHS_in,SO,Sn,C).
dcg_rhs(RHS_in,SO,Sn,RHS_out):-
                              7o single non-terminal
   tag(RHS_in,SO,Sn,RHS_out).
%
% Auxiliary predicates
%
% dcg_or(+RHS,SO,SI,-Translation)
%
% As dcg_rhs, except for goals that will be part of a
% disjunction. dcg_rhs can instantiate the first list
% argument (SO) (by making it the same as the second
% or a list with some terminals in it), but that can't
% be done here (it will mess
% up the other disjuncts). Instead, if that happens, an
% explicit = goal is included in the output.
dcg_or(In,S0,Sn,0ut) :-
  dcg_rhs(In,Sl,Sn,0utl), % using new first list argument S I
   ( var(Sl),
    \+ S i == Sn, !,
                   % if Si has not been set
    S0=S1,
                  %
    0ut=0utl;
                  % return what was computed (SI)
    0ut=(S0=Sl,0utl)). % otherwise link SO,SI with an = goal
% Create a conjunction, flattening if possible
dcg_and(true,In,In) :- !.
dcg_and(In,true,In) :- !.
```

<!-- page 307 -->
Appendix D Code to Support DCGs

```prolog
dcg_and(Inl,In2,(Inl,In2)).
% tag(+In,S0,Sl,-0ut)
%
% In is a term representing a DCG non-terminal. Out
% is the result of adding SO and S I as extra arguments
tag(In,S0,Sn,0ut) :-
  In=..[Predicate|Arguments],
  dcg_append(Arguments,[SO,Sn],New_arguments),
  Out=..[Predicate|New_arguments].
% flatten 2 (+Seq,-FSeq)
%
% Given a sequence of terms connected by','/2
% (possibly with embedded sequences), produces a
% "flattened" form
flatten2(In,In) :- var(In), !.
flatten2((Inl,In2),0utl) :- !,
  flattenl(lnl,0utl,0ut2),
  flatten2(In2,0ut2).
flatten2(In,In).
flattenl(Inl,(Inl,In2),In2) :-
  var(Inl), !.
flattenl((Inl,In2),0utl,In3):- !,
  flattenl(Inl,0utl,0ut2),
  flattenl(In2,0ut2,In3).
flattenl(Inl,(Inl,In2),In2).
islist([]).
```

islist(LU).

```prolog
dcg_append([],X,X).
dcg_append([X|L],Ll,[X|L2]):- dcg_append(L,Ll,L2).
% make_connects(+Terminals,SO,Sl,-Goals)
%
% Create the X' goals for a list of terminals. SO and SI
% are to be instantiated to the input and output list
```

<!-- page 308 -->
```prolog
% arguments.
make_connects([First|Rest],SO,Sn,Conns) :-
  nonvar(Rest), !,
  make_connects(Rest,SI,Sn,Cs),
  dcg_and('C'(SO,First,SI),Cs,Conns).
make_connects([],S,S,true).
% Predicates that can be called/redefined by the user
phrase(T, S):- phrase(T, S, []).
phrase(T, SO, S ) t a g ( T , SO, S, G), call(G).
'C'([W|Ws],W,Ws).
```
