# Writing Prolog Programs

The best general advice on *writing* Prolog code was given by Richard O'Keefe in his book *The Craft of Prolog*:

> **Elegance is not optional.**

Take this advice to heart! If your Prolog code seems somewhat inelegant, *pause* and think about how it can be made more elegant. This page explains a few additional guidelines for writing Prolog code.

*Video*: [Writing Prolog Code](https://www.metalevel.at/prolog/videos/writing)

## How to begin

Consider a relation like `list_list_together/3` that is mentioned in [Reading Prolog Programs](05-reading.md). How do we come up with such a definition in the first place? When *writing* a Prolog predicate, think about *the conditions that ought to make it true*. For example, in the case of `list_list_together/3`, we can proceed as follows: First, we want to describe a relation that holds for [*lists*](04-data.md#list). We know from their inductive definition that we need to consider at least two possible cases:

1.  the *atom* `[]`
2.  compound terms of the form `[L|Ls]`

These two cases form the skeleton of our prospective definition:

```prolog
list_list_together([], Bs, Cs) :-
        ...
list_list_together([L|Ls], Bs, Cs) :-
        ...

```

These two clauses form logical *alternatives* that describe the different *cases* that can arise. Then, we ask: *When*, i.e., under what *conditions* do these cases *hold*? If you think about it, you will come to the conclusion that the first clause holds *if* `Bs = Cs`, so we can write it as:

```prolog
list_list_together([], Bs, Cs) :-
        Bs = Cs.

```

Such unifications can always be pulled into the clause head, so we can write it as:

```prolog
list_list_together([], Bs, Bs).

```

We apply the same reasoning to the second clause: *When* does it hold that `Cs` is the concatenation of `[L|Ls]` and `Bs`? A bit of reflection tells us: This holds *if* `Cs` is of the form `[L|Rest]` *and* `Rest` is the concatenation of `Ls` and `Bs`. We use the [built-in](03-concepts.md#builtin) predicate `(',')/2` to express this *conjunction* of conditions. To describe that `Rest` is the concatenation of `Ls` and `Bs`, we use `list_list_together(Ls, Bs, Rest)`, since this is precisely the relation that ought to *hold* in this case. The whole clause therefore becomes:

```prolog
list_list_together([L|Ls], Bs, Cs) :-
        Cs = [L|Rest],
        list_list_together(Ls, Bs, Rest).

```

This is an example of a predicate whose definition refers to itself. Such predicates are called *recursive*. Note how recursive definitions naturally arise from considering the conditions that make such predicates true. Again, we can simply pull the unification into the clause head:

```prolog
list_list_together([L|Ls], Bs, [L|Rest]) :-
        list_list_together(Ls, Bs, Rest).

```

Finding better variable names is left as an exercise. When beginners write their first Prolog programs, a common mistake is to ask the *wrong* question: "What should Prolog *do* in this case?". This question is misguided: Especially as a beginner, you will not be able to grasp the actual control flow for the different modes of invocation. In addition, this question typically limits you to only one possible usage mode of your predicate, and one specific execution strategy. Therefore, do not fall into this trap! Instead, think about the conditions that *make the relation hold*, and provide a clear declarative description of these conditions. If you manage to state these conditions correctly, you often naturally obtain very general predicates that can be used in several directions. Thus, when writing Prolog code, better ask: *What are the cases and conditions that make this predicate true*? You may now think: That's all OK, and may work for such simple relations. But what if I want to actually "do" something, such as incrementing a counter, removing an element etc.? The answer is still the same: Think in terms of *relations* between the entities you are describing. To express a *modification* of something, you should define a relation between different *states* of something, and state the conditions that make this relation *hold*. See [*Thinking in States*](/tist/) for more information.

## Naming predicates

A good *predicate name* makes clear what the predicate arguments *mean*.

*Video*: [Naming Prolog Predicates](https://www.metalevel.at/prolog/videos/naming_predicates)

Ideally, a predicate can be used in *all* directions. This means that *any* argument may be a variable, partially instantiated, or fully instantiated. This generality should be *expressed* in the predicate name, typically by choosing *nouns* to describe the arguments. Examples of **good** predicate names are:

- `list_length/2`, relating a list to its length
- `integer_successor/2`, relating an integer to its successor
- `student_course_grade/3`, relating students to courses and grades.

In these cases, the predicate names are so clear that the descriptions seem almost superfluous. Note also that `using_underscores_makes_also_longer_names_easy_to_read`, whereas for example `mixingTheCasesAsInJavaMakesThatALotHarderInGeneral`. For these reasons, examples of **bad** names are:

- `length/2`: Which argument is the length, the first or the second one?
- `nextInteger/2`: Not as readable as for example `next_integer/2`, and not as meaningful as `integer_successor/2`.
- `fetch_grades/3`: Does not make sense for example if grades are already *instantiated*.

## Naming variables

A Prolog **variable** starts with an uppercase letter *or* with an underscore. The latter rule is useful to know if you are teaching Prolog in Japan, for example. In contrast to the convention for *predicate* names, `MixedCases` are sometimes used when naming Prolog *variables*. However, the mixing is in almost all cases limited to at most *two* uppercase words that are adjoined. Some Prolog predicates describe a sequence of [*state transitions*](/tist/) to express state changes in a pure way. In such cases, the following convention can be very useful: The initial state is denoted as `State0`, the next state is `State1`, etc. This enumeration continues until the final state, which we call `State`. In total, the sequence is therefore:

```prolog
State0 → State1 → State2 → ... → State

```

Of course, the prefix `State` can denote any other entity that is being described. For example, if multiple elements are inserted into an [association list](04-data.md#assoc), we may have the sequence:

```prolog
Assoc0 → Assoc1 → Assoc2 → ... → Assoc

```

When writing [higher-order predicates](10-metapredicates.md), it is good practice to denote with `C_`*`N`* a partial goal `C` that is called with *N* additional arguments. For example, the first argument of `maplist/2` could be called `Pred_1`, because it is invoked with *one* additional argument.

## Indenting Prolog code

Prolog is a very simple language: Only a few language constructs exist, and several ways for indenting them are common. However, no matter which convention you choose, one invariant that should always be adhered to is to *never place `(;)/2` at the end of a line*. This is because `;` looks very similar to `,` (comma). Since `(',')/2` almost always occurs at the end of a line, it is good practice to place `;` either at the *beginning* of a line or *between* the two goals of a disjunction to more clearly distinguish it from a conjunction.

## Comments

You can use *comments* in your code to explain important principles and design goals of your programs. Prolog supports two kinds of *comments*:

- *single line comment*, starting with `%` and including everything up to (and including) the next *newline* character

- *bracketed comment*, which has the form

  ```prolog
  /* comment text */

  ```

  A bracketed comment may also include newline characters between the delimiters.

By convention, supported *modes* of predicates are sometimes indicated in comments. Such comments consist of the predicate head, and indicate the supported modes for each argument using a dedicated prefix for each argument. For example, such a comment may read:

```prolog
list_list_together(?As, ?Bs, ?Cs)

```

where "`?`" means that the respective argument may be a variable, only partially instantiated *or* fully instantiated when the predicate is invoked. Other common prefices are "`+`" and "`-`", denoting intended *input* and *output* arguments, respectively. Such mode annotations may be augmented with the *determinism* specifiers `semidet`, `det`, `multi` and `nondet`, indicating whether the predicate succeeds, respectively, at most once, exactly once, at least once, or arbitrarily often.

## Further reading

Covington et al., [*Coding Guidelines for Prolog*](https://arxiv.org/pdf/0911.2899.pdf), contains some interesting observations for programming in Prolog.
