# Engineering Aspects

## Prolog Development Environment

There are several good *development environments* with special support for Prolog coding. For example, see [PceProlog](/pceprolog/) to configure **GNU Emacs** for Prolog. The `comp.lang.prolog` [FAQ](/prolog/faq/) contain pointers to several additional environments. Prolog systems ship with different features that make *compiling* and *consulting* your code easier. For example, in SWI-Prolog, you can invoke the built-in predicate `make/0` to reconsult all source files. This feature works to various degrees, depending on other features you are using. Using [ediprolog](/ediprolog/), you can stay in the Emacs buffer, and interact with Prolog directly in the buffer. I recommend you use the system that works best for you, i.e., I recommend you use Emacs for Prolog development. Make sure to configure your keyboard so that you can use `Caps Lock` as an additional `Ctrl` key! In my experience, Emacs is most usable with a *Dvorak* keyboard layout.

*Video*: [Prolog development with GNU Emacs](https://www.metalevel.at/prolog/videos/emacs)

## Module Systems

For programming *in the large*, and even for programming *in the medium*, and *even* for several other kinds of programming, you will want to make use of your Prolog's *module system* to separate logical units of code. Different Prolog implementations support different *kinds* of module systems. Notably, there are *functor-based* module systems and *predicate-based* module systems, with different consequences and trade-offs. It is very hard to *design* a module system and think all consequences through. Usually, conflicting requirements are imposed on a module system: On the one hand, you want to use modules to *separate concerns*, and on the other hand, you want to support *code introspection* and other features that run counter to true separation. Therefore, typical module systems are ultimately inconsistent, yet useful for structuring your source files and avoiding name conflicts. *Using* a particular module system is usually very straight-forward. Essentially, you typically place a `module/2` (or similar) directive in your source file, such as:

```prolog
:- module(my_nice_module, [first_exported_predicate/2,
                           second_exported_predicate/1,
                           third_exported_predicate/4,
                           ...
                          ]).
    
```

where the various *exported* predicates are listed by their predicate *indicators* (name and arity). In Prolog files that *use* a module, you place a corresponding `use_module/1` (or similar) directive, such as:

```prolog
:- use_module(my_nice_module).
    
```

A major advantage is that the *internal* predicates of `my_nice_module` cannot cause conflicts with internal predicates of other programs and modules.

## Timing and Profiling

Different Prolog systems provide different ways to *time* and *profile* your predicates. For example, in Scryer Prolog, you can use the predicate `time/1` from [`library(time)`](https://codeberg.org/mthom/scryer-prolog/raw/master/src/lib/time.pl) to measure the run time of any goal. For example:

```prolog
?- time((X in 0..1_000,indomain(X),false)).
   % CPU time: 0.029s, 262_448 inferences
   false.
    
```

SWI-Prolog ships with a very nice *profiler* which you can invoke via `profile/1`. Simply supply the goal you want to profile as an argument. Other systems such as SICStus Prolog also ship with a built-in [profiler](https://sicstus.sics.se/sicstus/docs/4.3.2/html/sicstus/Execution-Profiling.html). Most Prolog systems provide the predicate `statistics/2` which you can use to take your own measurements. For example, we can define the *relation* between a goal and the CPU time it takes until it succeeds:

```prolog
goal_time(Goal, T) :-
        statistics(runtime, [T0|_]),
        Goal,
        statistics(runtime, [T1|_]),
        T #= T1 - T0.
    
```

We can now obtain the CPU time (in milliseconds) of any goal `Goal` via the query:

```prolog
?- goal_time(Goal, Time).
    
```

I highly recommend such tools to measure the performance of your predicates.

## Exceptions and Errors

Prolog supports raising and handling *exceptions*. As the name implies, this mechanism is useful to handle *exceptional* situations. Some of these situations are already prescribed in the ISO standard. The most important ones are:

- **type error**: This exception is raised when a particular *type* of term is expected, but a different kind of term is present. The ISO standard explicitly defines sets of terms (such as *integer*, *list* etc.) for which a type error may be raised.
- **domain error**: This is very similar to a type error: A different *kind* of term than is present is expected. The difference to a type error is that the kind of term that is expected is *not* among the predefined types that are defined in the standard.
- **instantiation error**: This exception is raised when a predicate argument is insufficiently *instantiated*, i.e., a *variable* occurs where a more specific term is expected.

There is a very important semantic difference between these exceptions: Declaratively, a *type* or *domain* error can be replaced by silent *failure*, because no further constraint you add to the (monotonic) program can turn such a situation into success. On the other hand, an *instantiation* error *must not* be replaced by silent failure, because there *could* still be solutions in such cases, and adding further constraints may reveal them. Here are two examples that illustrate these cases:

```prolog
?- X #= a.
   error(domain_error(clpz_expression,a),unknown(a)-1).

?- X in Y.
   error(instantiation_error,instantiation_error(unknown(_143),1)).
    
```

It is easy to see that adding further constraints can make the *second* query succeed:

```prolog
?- Y = 0..5, X in Y.
   Y = 0..5, clpz:(X in 0..5).
    
```

However, no additional goal can ever make `X #= a` succeed, and therefore this *domain error* could also be replaced by failure. In exceptional situations, exceptions are typically more useful than silent failure, because they let you reason about the *cause* of the problem. You can use the standard predicate `throw/1` to *raise* an exception, and the standard predicate `catch/3` to handle exceptions.

## Unit Tests

*Unit tests* are an extremely important tool to detect regressions in your code. Prolog is eminently well-suited to formulate and run unit tests. Using declarative descriptions and Prolog's built-in backtracking mechanism, you can quickly formulate tests that cover a vast range of possible tests. Essentially, state what *ought* to hold, and then simply *run* these queries to test whether it *does* hold. The best way to write unit tests in Prolog is to use **quads**: *queries using answer descriptions*. Quads are verbatim copies of toplevel annotations, possibly extended with annotations. See for instance [`library(quads)`](https://github.com/trealla-prolog/trealla/blob/main/library/quads.pl) in Trealla Prolog. There is also a unit testing framework called [PlUnit](http://www.swi-prolog.org/pldoc/doc_for?object=section(%27packages/plunit.html%27)) that is available for SWI-Prolog *and* for SICStus Prolog.
