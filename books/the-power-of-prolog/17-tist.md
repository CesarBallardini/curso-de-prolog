# Thinking in States

## Motivation

If you are used to imperative programming languages and then learn a functional or logic programming language, you may first work successfully through a few easy exercises and then suddenly find yourself unable to solve apparently simple tasks in the declarative language. You may for example find yourself asking: "How do I even increase the value of a variable?", or "How do I even remove an element from a list?", or more generally "How do I even apply a simple transformation to this data structure?" etc. Invariably, the solution to such problems is to think in terms of *relations* between different entities. Examples of such entities are variables, lists, trees, *states* etc. For example, in an imperative language, changing the *state* of a variable is easy:

```prolog
i = i + 1;

```

After such a statement is executed, the *state* of `i` has *changed*. The old state of `i` is no longer accessible. Note that declaratively, the equation makes no sense: There is no number `i` that equals `i+1`. In Prolog, the above snippet could become:

```prolog
I #= I0 + 1

```

This means that `I` and `I0` are in a certain relation. In this case, `(#=)/2` denotes the *equivalence relation* of [integer expressions](/prolog/clpfd). Importantly, such a relation can be used in *all directions*. The way corresponding to the imperative way shown above would be to have `I0` instantiated to a concrete integer, and let `I` denote the next integer. Due to the generality of Prolog, the *same* snippet can also be used if `I` is instantiated and `I0` is not known, and even if *both* of them are still variables. The mental leap you have to perform to benefit from this generality is to think in terms of *two* variables instead of one. This is necessary because the same variable cannot reflect two different states, old *and* new, at the same time. As another example, when you find yourself asking "How do I even remove an element *E* from a list?", think declaratively and describe a *relation* between two lists: One list may contain the element *E*, and the second list contains all elements of the first list which are not equal to *E*. Actually, as you already see, we are describing a relation between *three* entities in this case: Two lists, and an element. You can express this relation in Prolog by stating the conditions that make the relation *hold*:

```prolog
list1_element_list2([], _, []).
list1_element_list2([E|Ls1], E, Ls2) :-
        list1_element_list2(Ls1, E, Ls2).
list1_element_list2([L|Ls1], E, [L|Ls2]) :-
        dif(L, E),
        list1_element_list2(Ls1, E, Ls2).

```

This relation has one argument for each of these entities, and we can read each clause [declaratively](05-reading.md#declarative). For example, the first clause means: The relation *holds* **if** the first and third argument are the empty list. The second clause means: **If** the relation holds for `Ls1`, `E` and `Ls2`, **then** the relation holds for `[E|Ls1]`, `E` and `Ls2`. The third clause is read analogously, with the added constraint that it only holds **if** `L` and `E` are *different* terms. The predicate is usable in all directions: It can answer much more general questions than just "What does a list look like if we remove all occurrences of the element *E*?". You can also use it to answer for example: "Which element, if any, *has been* removed in a given example?", or to answer the most general query: "For which 3 entities does this relation even hold?". This generality is the reason why an imperative name like "remove/3" would not be a good fit in this case. Prolog provides several language constructs to make predicates general, efficient *and* concise. For example, using the meta-predicate `tfilter/3` from [`library(reif)`](10-metapredicates.md#if_3), we can write `list1_element_list2/3` equivalently as:

```prolog
list1_element_list2(Ls1, E, Ls2) :-
        tfilter(dif(E), Ls1, Ls2).

```

This version is *deterministic* if all arguments are sufficiently instantiated. For example:

```prolog
?- list1_element_list2("abc", b, Ls).
   Ls = "ac".

```

As yet another example, when you find yourself asking: "How do I even apply a transformation to a tree?", again think declaratively and describe a *relation* between two trees: one tree *before* the transformation and one tree *after* the transformation. Notice that *functions* are a special kind of relations, so most of the things below hold for functional as well as logic programming languages. Logic programming languages typically allow for more general solutions with less effort, since predicates can often be used in several directions. In this text, we will see several examples of relations between *states*: states in puzzles, states in programs, states in compilers etc., so that you see how various tasks can be expressed in declarative languages. The core idea is the same in all these examples: We think in terms of *relations between states*. This is in contrast to imperative languages, where we often think in terms of destructive *modifications* to a state.

## Global states

If you are used to thinking in terms of imperative programming languages, you will try to find ways to manipulate *global states* also in declarative languages. For example, you may try to query and change [*global variables*](16-global.md) in Prolog. Prolog *does* support changing the global state by various means. For example, we can destructively change the global database in several ways. However, if a Prolog program changes a global state by setting a global variable or modifying the global database, important properties we expect from logic programs may *break*. Such programs may no longer be usable in all directions, may yield different results for identical queries, and can typically no longer be tested and used in isolation from other program fragments that prepare or clean up these global states. For these reasons, this is *not* the kind of state we discuss in this text. To fully benefit from the advantages of [**pure**](11-purity.md) Prolog programs, you should always aim to find *declarative* ways to express changes in states. The declarative way to reason about changes is to describe the *relations* between states that are induced by such changes.

## States in puzzles

The choice of state representation can significantly influence how elegantly you can describe a task. Consider a simple puzzle to see this:

Given **water jugs** A, B and C of respective capacities 8, 5 and 3 and respective fill states *full*, *empty* and *empty*, measure exactly 4 units into both A and B.

Clearly, an important *state* in this puzzle is the amount of water in each jug. Using Haskell, let us represent this state as a triple (A,B,C):

```prolog
type State = (Int,Int,Int)

```

Now, we are to find a sequence of transfers leading from state (8,0,0) to state (4,4,0). We start with a function that, given a state, yields a list of all proper successor states:

```prolog
successors :: State -> [State]
successors (a,b,c) =
    let ab = min a (5 - b)
        ac = min a (3 - c)
        ba = min b (8 - a)
        bc = min b (3 - c)
        ca = min c (8 - a)
        cb = min c (5 - b)
        ss = [(ab,a-ab,b+ab,c), (ac,a-ac,b,c+ac), (ba,a+ba,b-ba,c),
              (bc,a,b-bc,c+bc), (ca,a+ca,b,c-ca), (cb,a,b+cb,c-cb)]
    in
      [(a',b',c') | (transfer,a',b',c')  0]

```

We can test this function interactively:

```prolog
Main> successors (8,0,0)
[(3,5,0),(5,0,3)]

```

Let us now determine whether we can, starting from the initial state, actually reach the target state. We try breadth-first search, a complete and space-inefficient search strategy:

```prolog
search :: [State] -> Bool
search (s:ss)
    | s == (4,4,0) = True
    | otherwise = search $ ss ++ successors s

```

In each iteration, we consider the first state in the given list of states. If it's the target state, we're done. Otherwise, its successors are appended to the remaining states (to be considered later), and the search continues. We can now query

```prolog
search [(8,0,0)]
True

```

and know that the puzzle actually has a solution. To find a sequence of actions leading to the target state, we reconsider the *state representation*. Instead of merely keeping track of the amount of water in the jugs, we also store how we obtained each configuration. We represent this new state as a pair (J,P): J is the jug configuration (A,B,C) like before, and P is a "path" that leads from the starting state to configuration J. A path is a list of `FromTo Jug1 Jug2` moves, meaning that we poured water from `Jug1` into `Jug2`. For each successor state, we record how its configuration was reached by appending the corresponding path element to (a copy of) its predecessor's path. The new program ([jugs.hs](jugs.hs)) is:

```prolog
data Jug = A | B | C deriving Show

data Move = FromTo Jug Jug deriving Show
type Path = [Move]

type State = ((Int,Int,Int), Path)

start :: State
start = ((8,0,0), [])

successors :: State -> [State]

successors ((a,b,c),path) =
    let ab = min a (5 - b)
        ac = min a (3 - c)
        ba = min b (8 - a)
        bc = min b (3 - c)
        ca = min c (8 - a)
        cb = min c (5 - b)
        ss = [(ab, a-ab, b+ab,    c, path ++ [FromTo A B]),
              (ac, a-ac,    b, c+ac, path ++ [FromTo A C]),
              (ba, a+ba, b-ba,    c, path ++ [FromTo B A]),
              (bc,    a, b-bc, c+bc, path ++ [FromTo B C]),
              (ca, a+ca,    b, c-ca, path ++ [FromTo C A]),
              (cb,    a, b+cb, c-cb, path ++ [FromTo C B])]
    in
      [((a',b',c'), path') | (amount,a',b',c',path')  0]

search :: [State] -> Path

search (s:ss)
    | fst s == (4,4,0) = snd s
    | otherwise = search $ ss ++ successors s

```

A path is now readily found:

```prolog
search [start]
[FromTo A B,FromTo B C,FromTo C A,FromTo B C,FromTo A B,FromTo B C,FromTo C A]

```

There are various ways to make this more efficient. We could, for example, *prepend* the new path elements and reverse the path once at the end of the search. More importantly, we can also make it more elegant: Clearly, the code above contains some redundancy, which we can avoid with a different state representation. The following Prolog version illustrates this:

```prolog
jug_capacity(a, 8).
jug_capacity(b, 5).
jug_capacity(c, 3).

moves(Jugs) -->
        { member(jug(a,4), Jugs),
          member(jug(b,4), Jugs) }.
moves(Jugs0) --> [from_to(From,To)],
        { select(jug(From,FromFill0), Jugs0, Jugs1),
          FromFill0 #> 0,
          select(jug(To,ToFill0), Jugs1, Jugs),
          jug_capacity(To, ToCapacity),
          ToFill0 #< ToCapacity,
          Move #= min(FromFill0, ToCapacity-ToFill0),
          FromFill #= FromFill0 - Move,
          ToFill #= ToFill0 + Move },
        moves([jug(From,FromFill),jug(To,ToFill)|Jugs]).

```

With this state representation, moves can be described uniformly and need not be enumerated explicitly. We use *iterative deepening* to find a shortest solution:

```prolog
?- length(Ms, _), phrase(moves([jug(a,8),jug(b,0),jug(c,0)]), Ms).
Ms = [from_to(a,b),from_to(b,c),from_to(c,a),from_to(b,c),from_to(a,b),from_to(b,c),from_to(c,a)] .

```

**Exercise**: Use this state representation in the Haskell version. In a similar manner, you can solve other puzzles involving search like "wolf and goat", 8-puzzles, [**Escape from Zurg**](/zurg/) and "missionary and cannibal".

## States in programs

Let us now build an **interpreter** for a simple programming language over integers in Prolog. Using Prolog terms, we represent programs as abstract syntax trees (ASTs) like:

```prolog
function(Name, Parameter, Body)
call(Name, Expression)
return(Expression)
assign(Variable, Expression)
if(Condition, Then, Else)
while(Condition, Body)
sequence(First, Second)

```

To symbolically distinguish variables from numerals in arithmetic expressions, we use the unary functors "v" and "n", respectively. Look up the definition of **is_program/2** in the source code ([interp.pl](interp.pl)) for a complete declarative specification of the chosen representation. Also included, you find a parser to automatically generate this term representation from more readable syntax. For instance, the following program (recursively) computing and printing the fourth Catalan number

```prolog
catalan (n) {
        if (n == 0) {
                return 1;
        } else {
                c = catalan(n-1);
                r = 2*(2*n + 1)*c / (n + 2);
                return r;
        }
}

print catalan(4);

```

is converted to a syntax tree like this:

```prolog
?- string_ast("catalan (n) { if (n == 0) { return 1; } else { c = catalan(n-1);
          r = 2*(2*n + 1)*c / (n + 2); return r; } } print catalan(4);", AST).

AST = sequence(function(catalan, n,
                         if(bin(=, v(n), n(0)),
                            return(n(1)),
                            sequence(assign(c, call(catalan, bin(-, v(n), n(1)))),
                                     sequence(assign(r, bin(/,
                                                            bin(*,
                                                                bin(*,
                                                                    n(2),
                                                                    bin(+,
                                                                        bin(*,
                                                                            n(2),
                                                                            v(n)),
                                                                        n(1))),
                                                                v(c)),
                                                            bin(+, v(n), n(2)))),
                                              return(v(r)))))),
               print(call(catalan, n(4))))

```

To interpret such programs, we have to keep track of the *state* of computation. It consists of:

- the binding environment for variables
- all encountered function definitions.

These two, collectively referred to as *the environment*, are represented as a pair of association lists, associating variable names with values, and function heads with function bodies. This makes defining and referring to functions as well as accessing variables O(log(N)) operations in the number of encountered functions and variables, respectively. Clearly, the predicates responsible for interpreting syntax trees define relations between such environments and thus between *states*. This is how we interpret imperative programs in a purely declarative way. To *evaluate* expressions with respect to the current environment, we use the predicate **eval/3**:

```prolog
eval(bin(Op,A,B), Env, Value) :-
        eval(A, Env, VA),
        eval(B, Env, VB),
        eval_(Op, VA, VB, Value).
eval(v(V), Env, Value) :-
        env_get_var(Env, V, Value).
eval(n(N), _, N).
eval(call(Name, Arg), Env0, Value) :-
        eval(Arg, Env0, ArgVal),
        env_func_body(Env0, Name, ArgName, Body),
        env_clear_variables(Env0, Env1),
        env_put_var(ArgName, ArgVal, Env1, Env2),
        interpret(Body, Env2, Value).


eval_(+, A, B, V) :- V #= A + B.
eval_(-, A, B, V) :- V #= A - B.
eval_(*, A, B, V) :- V #= A * B.
eval_(/, A, B, V) :- V #= A // B.
eval_(=, A, B, V) :- goal_truth(A #= B, V).
eval_(>, A, B, V) :- goal_truth(A #> B, V).
eval_( V = 1 ; V = 0).

```

The predicates accessing the environment (**env_get_var/3** etc.) are straight-forward, and you can look up their definitions in the source code. Finally, the predicate **interpret/3** specifies how, if at all, each construct of our language changes the environment:

```prolog
interpret(print(P), Env, Env) :-
        eval(P, Env, Value),
        format("~w\n", [Value]).
interpret(sequence(A,B), Env0, Env) :-
        interpret(A, Env0, Env1),
        (   A = return(_) ->
            Env = Env1
        ;   interpret(B, Env1, Env)
        ).
interpret(call(Name, Arg), Env0, Env0) :-
        eval(Arg, Env0, ArgVal),
        env_func_body(Env0, Name, ArgName, Body),
        env_clear_variables(Env0, Env1),
        env_put_var(ArgName, ArgVal, Env1, Env2),
        interpret(Body, Env2, _).
interpret(function(Name,Arg,Body), Env0, Env) :-
        env_put_func(Name, Arg, Body, Env0, Env).
interpret(if(Cond,Then,Else), Env0, Env) :-
        eval(Cond, Env0, Value),
        (   Value #\= 0 ->
            interpret(Then, Env0, Env)
        ;   interpret(Else, Env0, Env)
        ).
interpret(assign(Var, Expr), Env0, Env) :-
        eval(Expr, Env0, Value),
        env_put_var(Var, Value, Env0, Env).
interpret(while(Cond, Body), Env0, Env) :-
        eval(Cond, Env0, Value),
        (   Value #\= 0 ->
            interpret(Body, Env0, Env1),
            interpret(while(Cond, Body), Env1, Env)
        ;   Env = Env0
        ).
interpret(return(Expr), Env0, Value) :-
        eval(Expr, Env0, Value).
interpret(nop, Env, Env).

```

Two things deserve special attention: For one, the `print` statement produces a *side-effect*: It is meant to show output on the terminal, and this cannot be expressed by transforming the binding environment. The interpreter is thus not purely logical. To fix this, we could incorporate a suitable representation of the state of the "world" into our environment and adjust it appropriately whenever a `print` statement is encountered. Second, `return` statements are special in that their resulting environment consists of a single value. The **eval/3** predicate makes use of this when evaluating function calls. To interpret a program, we start with a fresh environment and discard the resulting environment:

```prolog
run(AST) :-
        env_new(Env),
        interpret(AST, Env, _).

```

We can run our simple example program like this:

```prolog
?- string_ast("catalan (n) { if (n == 0) { return 1; } else { c = catalan(n-1);
          r = 2*(2*n + 1)*c / (n + 2); return r; } } print catalan(4);", AST), run(AST).

42

```

## States in compilers

To get rid of the interpreter's overhead incurred by looking up variables and function definitions in the environment, we now **compile** programs to *virtual machine code* in which variables and functions are addressed by offsets into specific regions of the virtual machine's "memory". Using a programming language permitting efficient array indexing, you can thus interpret variable access and function calls in O(1). Our virtual machine (VM) shall be stack-based and have the following instructions:

[TABLE]

*Variables* are now actually integers, denoting an offset into the stack frame of the function being executed. 0 (zero) corresponds to a function's sole argument and is copied on the stack when encountering a `call` instruction. Also, `call` saves the current frame pointer and program counter on the stack. A function can allocate additional space for local variables by means of the `alloc` instruction. The return instruction (`ret`) removes all stack elements allocated by the current function, restores the frame pointer and program counter, and pushes the function's return value on the stack. The following example program and corresponding VM code illustrate most of the instructions:

[TABLE]

Generating such VM code from an abstract syntax tree is straight-forward. In essence, we will write a predicate **compilation/3** with clauses roughly of the form

```prolog
compilation(functor(Arg1,Arg2,...,ArgN), State0, State) :-
        compilation(Arg1, State0, State1),
        compilation(Arg2, State1, State2),
           :
           :
        compilation(Argn, State_(N-1), State_N),
        vminstr(instruction_depending_on_functor, State_N, State).

```

Notice the naming convention `S0`, `S1`, `S2`, ..., `S` for successive states. As we will see in the following, only a few predicates need to access and modify the state in this case. We will therefore use Prolog [**semicontext notation**](14-dcg.md#semicontext) to implicitly thread the state through, yielding the more readable nonterminal **compilation//1**:

```prolog
compilation(functor(Arg1,Arg2,...,ArgN)) -->
        compilation(Arg1),
        compilation(Arg2),
           :
           :
        compilation(Argn),
        vminstr(instruction_depending_on_functor).

```

When compiling to VM code, we keep track of the *state* of the compilation process:

- VM instructions emitted so far
- offsets of encountered function definitions
- offsets of variables encountered in the current function
- offset of next instruction ("program counter").

We store all this in a quadruple `s(Is, Fs, Vs, PC)`. The entry point for compilation is **ast_vminstrs/2**, which relates an abstract syntax tree to a list of virtual machine instructions. It starts with a fresh state, transforms it via **compilation//1** and then extracts the accumulated instructions, also translating names to offsets in function calls:

```prolog
ast_vminstrs(AST, VMs) :-
        initial_state(S0),
        phrase(compilation(AST), [S0], [S]),
        state_vminstrs(S, VMs).

initial_state(s([],[],[],0)).

state_vminstrs(s(Is0,Fs,_,_), Is) :-
        reverse([halt|Is0], Is1),
        maplist(resolve_calls(Fs), Is1, Is).

resolve_calls(Fs, I0, I) :-
        (   I0 = call(Name) ->
            memberchk(Name-Adr, Fs),
            I = call(Adr)
        ;   I = I0
        ).

```

To portably (i.e., without relying on a particular expansion method for DCGs) access and modify the state that is implicitly threaded through in DCG notation, we use the following two nonterminals:

```prolog
state(S), [S] --> [S].

state(S0, S), [S] --> [S0].

```

Thus, `state(S)` can be read as "the current state is `S`", and `state(S0, S)` can be read as "the current state is `S0`, and henceforth it is `S`". Here are auxiliary predicates to access and transform parts of the state:

```prolog
current_pc(PC) --> state(s(_,_,_,PC)).

vminstr(I) -->
        state(s(Is,Fs,Vs,PC0), s([I|Is],Fs,Vs,PC)),
        { I =.. Ls,
          length(Ls, L),   % length of instruction including arguments
          PC #= PC0 + L }.

start_function(Name, Arg) -->
        state(s(Is,Fs,_,PC), s(Is,[Name-PC|Fs],[Arg-0],PC)).

num_variables(Num) -->
        state(s(_,_,Vs,_)),
        { length(Vs, Num0),
          Num #= Num0 - 1 }.      % don't count parameter

variable_offset(Name, Offset) -->
        state(s(Is,Fs,Vs0,PC), s(Is,Fs,Vs,PC)),
        { (   memberchk(Name-Offset, Vs0) ->
              Vs = Vs0
          ;   Vs0 = [_-Curr|_],
              Offset #= Curr + 1,
              Vs = [Name-Offset|Vs0]
          ) }.

```

For example, **start_function//2** records the offset (= current program counter) of the function to be defined and starts a new list of encountered variables, originally consisting only of the function's argument, whose offset in the stack frame is 0. Further variables are assigned ascending offsets as they are encountered. This is handled by **variable_offset//2**, which either determines a variable's offset from the list of encountered variables or, if it is new, registers it with a new offset computed by adding one to the offset of the variable registered previously. We can now define **compilation//1**:

```prolog
compilation(nop) --> [].
compilation(print(P)) -->
        compilation(P),
        vminstr(print).
compilation(sequence(A,B)) -->
        compilation(A),
        compilation(B).
compilation(call(Name,Arg)) -->
        compilation(Arg),
        vminstr(call(Name)).
compilation(function(Name,Arg,Body)) -->
        vminstr(jmp(Skip)),
        start_function(Name, Arg),
        vminstr(alloc(NumVars)),
        compilation(Body),
        num_variables(NumVars),
        current_pc(Skip).
compilation(if(Cond,Then,Else)) -->
        { Cond = bin(Op,A,B) },
        compilation(A),
        compilation(B),
        condition(Op, Adr1),
        compilation(Then),
        vminstr(jmp(Adr2)),
        current_pc(Adr1),
        compilation(Else),
        current_pc(Adr2).
compilation(assign(Var,Expr)) -->
        variable_offset(Var, Offset),
        compilation(Expr),
        vminstr(pop(Offset)).
compilation(while(Cond,Body)) -->
        current_pc(Head),
        { Cond = bin(Op,A,B) },
        compilation(A),
        compilation(B),
        condition(Op, Break),
        compilation(Body),
        vminstr(jmp(Head)),
        current_pc(Break).
compilation(return(Expr)) -->
        compilation(Expr),
        vminstr(ret).
compilation(bin(Op,A,B)) -->
        compilation(A),
        compilation(B),
        { op_vminstr(Op, VI) },
        vminstr(VI).
compilation(n(N)) -->
        vminstr(pushc(N)).
compilation(v(V)) -->
        variable_offset(V, Offset),
        vminstr(pushv(Offset)).


op_vminstr(+, add).
op_vminstr(-, sub).
op_vminstr(*, mul).
op_vminstr(/, div).

condition(=, Adr) --> vminstr(jne(Adr)).
condition( vminstr(jge(Adr)).
condition(>, Adr) --> vminstr(jle(Adr)).

```

Notice how we benefit from logical variables in several cases: For example, when `alloc` is emitted, we do not yet know how much space must be allocated. Nevertheless, we add the instruction to the sequence of virtual machine instructions, and instantiate its argument later. By introducing a `call_n` instruction that discards the `n` most recently allocated local variables before calling a given function, we could add *tail call optimisation* and, more generally, *stack trimming* to the VM: If a variable isn't needed after a function call, its stack space can be reclaimed before the call. To keep the generated VM code compact and easily accessible in other programming languages, we relate the mnemonic virtual machine instructions to lists of integers:

```prolog
vminstrs_ints([])     --> [].
vminstrs_ints([I|Is]) -->
        vminstr_ints(I),
        vminstrs_ints(Is).

vminstr_ints(halt)      --> [0].
vminstr_ints(alloc(A))  --> [1,A].
vminstr_ints(pushc(C))  --> [2,C].
vminstr_ints(pushv(V))  --> [3,V].
vminstr_ints(pop(V))    --> [4,V].
vminstr_ints(add)       --> [5].
vminstr_ints(sub)       --> [6].
vminstr_ints(mul)       --> [7].
vminstr_ints(div)       --> [8].
vminstr_ints(jmp(Adr))  --> [9,Adr].
vminstr_ints(jne(Adr))  --> [10,Adr].
vminstr_ints(jge(Adr))  --> [11,Adr].
vminstr_ints(jle(Adr))  --> [12,Adr].
vminstr_ints(call(Adr)) --> [13,Adr].
vminstr_ints(print)     --> [14].
vminstr_ints(ret)       --> [15].

```

## States in virtual machines

Let us now implement the VM we devised. Its *state* is determined by:

- values on the stack
- list of instructions to execute
- pc: program counter (offset into list of instructions)
- fp: frame pointer (offset into stack).

Using Haskell, we can use a quadruple to represent this state:

```prolog
type State = ([Int], [Int], Int, Int)

```

The function `step`, given the integer code of a VM instruction and the VM's current state, computes and returns the VM's new state:

```prolog
step :: Int -> State -> State
step instr (stack,instrs,pc,fp) =
    case instr of
      1 -> ((replicate next 0) ++ stack, instrs, pc2, fp + next)
      2 -> (next:stack, instrs, pc2, fp+1)
      3 -> ((stack!!(fp - next)):stack, instrs, pc2, fp + 1)
      4 -> (tail $ set_nth stack (fp - next) first, instrs, pc2, fp1)
      5 -> ((second+first):drop2, instrs, pc1, fp1)
      6 -> ((second-first):drop2, instrs, pc1, fp1)
      7 -> ((second*first):drop2, instrs, pc1, fp1)
      8 -> ((div second first):drop2, instrs, pc1, fp1)
      9 -> (stack, instrs, next, fp)
      10 -> if second /= first then (drop2, instrs, next, fp2)
            else (drop2, instrs, pc2, fp2)
      11 -> if second >= first then (drop2, instrs, next, fp2)
            else (drop2, instrs, pc2, fp2)
      12 -> if second  ([first,fp,pc2] ++ tail stack, instrs, next, 0)
      15 -> let fp' = stack !! (fp + 1)
                pc' = stack !! (fp + 2)
            in
              (first : drop (fp+3) stack, instrs, pc', fp')
    where next = instrs !! (pc+1)
          first = head stack
          second = stack !! 1
          drop2 = drop 2 stack
          fp1 = fp - 1
          fp2 = fp - 2
          pc1 = pc + 1
          pc2 = pc + 2


set_nth :: [a] -> Int -> a -> [a]
set_nth (x:xs) n a
    | n == 0 = a:xs
    | otherwise = x:(set_nth xs (n - 1) a)

```

We execute a list of integer codes by continually transforming the state until a `halt` instruction is reached:

```prolog
exec :: State -> IO ()
exec s0@(stack,instrs,pc,fp) =
    let instr = instrs !! pc
    in
      case instr of
        0 -> return ()
        14 -> do putStr $ (show $ head stack) ++ "\n"
                 exec (tail stack, instrs, pc + 1, fp - 1)
        otherwise -> exec $ step instr s0


main :: IO ()
main =
    do prog <- getLine
       let ints = read prog::[Int]
           s0 = ([],ints,0,0)
       exec s0

```

This code is available as [vm.hs](vm.hs). Since we used lists to represent the stack and set of instructions, indexing is inefficient. To remedy this, we could use an array at least for the set of instructions. The stack, however, needs to grow and shrink. We could artificially fix its size, or resize on demand, and still use a Haskell array. Instead, let us formulate the program in a language with efficient array operations at its core: [J](http://www.jsoftware.com), a successor of APL. In the J version ([vm.ijs](vm.ijs)), we represent the VM's state using an array of four boxed vectors. Using the power conjunction `^:`, we produce the limit of repeated applications of `step`:

```prolog
st =. 3 : '> 0 { y'
is =. 3 : '> 1 { y'
pc =. 3 : '> 2 { y'
fp =. 3 : '> 3 { y'

next =. (>:&pc { is)

print =. 3 : 'y (1!:2) 2'

adv =. 3 : '(2 }.st y); (is y); (2+pc y); ((fp y) - 2)'
jmp =. 3 : '(2 }.st y); (is y); (next y); ((fp y) - 2)'

i1  =: 3 : '(((next y) # 0),st y); (is; 2&+&pc; next+fp) y'
i2  =: 3 : '((next,st); is ; 2&+&pc; >:&fp) y'
i3  =: 3 : '((((fp-next) { st),st); is; 2&+&pc; >:&fp) y'
i4  =: 3 : '(}.({.st y) ((fp-next)y) } st y); (is; 2&+&pc; :&pc; :&pc; :& pc; :&pc; :/1 0 {st y)) y'
i12 =: 3 : '(adv ` jmp @. (:&pc); (:&fp { st) y
   pc1 =. (2&+&fp { st) y
   (({. st y),(3+fp y)}. st y) ; (is y); pc1 ; fp1
)

step =: 3 : 0
   instr =. (pc { is) y
   (]`i1`i2`i3`i4`i5`i6`i7`i8`i9`i10`i11`i12`i13`i14`i15  @. instr) y
)

state0 =:  ($0); instrs; 0; 0

step ^: _ state0

```

## Source files

The source files are:

- [jugs.hs](jugs.hs): Water jugs puzzle in Haskell.
- [jugs2.hs](jugs2.hs): Water jugs puzzle in Haskell, different state representation.
- [jugs.pl](jugs.pl): Water jugs puzzle in Prolog.
- [interp.pl](interp.pl): Interpreter and compiler for a simple programming language, written in Prolog.
- [vm.hs](vm.hs): Interpreter for the abstract machine code generated by the compiler, written in Haskell.
- [vm.ijs](vm.ijs): Interpreter for the abstract machine code, written in J.

A transcript showing how to invoke these programs: [log.txt](log.txt) You can use [Scryer Prolog](https://codeberg.org/mthom/scryer-prolog) to try the Prolog code.
