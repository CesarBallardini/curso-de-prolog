# Global Variables in Prolog

It is not the *skilful* poet that bemoans the rigid rules of the sonnet.

When you start learning Prolog, the language will initially seem very limited to you. Where are all the features you know from other programming languages? In particular, where are the **global variables** that you can use in other languages to pass information around? In Prolog, we pass information around in predicate *arguments*. We are *not* using global variables. Why is this? Think about it: Suppose there were a global state that is modified by a predicate. This would have consequences that clash fundamentally with how we expect relations to behave. For example, when programming in terms of relations, we expect:

- to be able to use them *in reverse* too
- to be able to reason about them *in isolation* from each other, allowing [declarative testing](12-testing.md)
- that repeated use of the same relation has exactly the same meaning
- that all changes are *undone* on backtracking
- thread-safety for *parallel* evaluation
- etc.

Therefore, we *avoid* the use of global state in Prolog. Instead, we describe *relations* between states of interests. When you are stuck, consider adding an argument to your predicate that lets you express the state of interest. See [***Thinking in States***](/tist/) for examples. That being said, there *are* of course ways to modify the global state of your programs. However, using them should be the **exception**, not the norm. For example, you can modify the global database by dynamically asserting clauses with `assertz/1`. The global database is very good for *reading* information, but quite bad for often *modifying* the data. This is because the global database performs *indexing* over its entries, and you pay the price for indexing every time you assert new clauses. In addition, you cannot use this kind of modifications in other directions. On backtracking, the data will still be there, and running the same code twice may also add the data redundantly. Using *predicate arguments* to pass around information therefore more naturally leads to Prolog programs that are [pure](11-purity.md) *and* efficient. [**Semicontext notation**](14-dcg.md#semicontext) lets you pass around information without the need to introduce many additional predicate arguments.
