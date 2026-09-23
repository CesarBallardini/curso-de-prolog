# Chapter9

<!-- page 271 -->
**Morphology and the Lexicon**

**9.1 HOW MORPHOLOGY WORKS**

9.1.1 The Nature of Morphology

**We noted in Chapter 1 that morphology consists of two kinds of processes:**

@ INFLECTION, which creates the various forms of each word (singular and plural,

present and past tense, or whatever); and

@ DERIVATION, which creates new words from pre-existing words, often of different

syntactic categories.

Perhaps the biggest difference between morphology and syntax is that, in most languages at least, morphology is finite. You can make a list of all the forms of every word in the language. In some languages this would be grossly wasteful—every Finnish verb, for example, has perhaps 12,000 inflected forms, all predictable by rule—but the point is that it’s possible.!

<!-- page 272 -->
1A few languages do have recursive word-formation processes, but even then the recursion is highly restricted (Anderson 1988b:149). Anyhow, we can force morphology to be finite by handling the recursive processes in the syntax.

What this means is that you don’t have to implement morphology on the compute at all. You can, if you wish, list all the forms of every word in the lexicon. This ha often been done for English.

What’s more, morphology is riddled with iRREGULARITY. There are plenty 6 inflected or derived forms that have to be listed in the lexicon because they are no predictable by rules. No rule will tell you that the plural of English child is children, 0 that the plural of corpus is corpora.

This means that in dealing with morphology on the computer, you have to face practical question: how much of it should you handle by means of rules, and how muc should you simply list in the lexicon?

It’s a matter of trade-offs. Listing every form of every word is obviously inefficient: morphological rules can certainly save space. But an overly elaborate rule system can. be inefficient in the opposite way; it can be faster to work with an incomplete set of | rules, looking up some forms in the lexicon, than to work with a more complex set of rules that captures everything. Unlike the theoretical linguist, the computer implementor is not required to track down every regular pattern and reduce it to a rule.

In languages like English, it is much more important to implement inflection than to implement derivation. The reason is that English inflection is very regular, but most cases of derivation are irregular, at least on the semantic level, and therefore have to be listed in the lexicon anyhow. If you take an English verb that ends in ate and change the ending to ation, you get a noun, but only the lexicon can tell you whether the noun denotes an activity (rotate : rotation), the result of an act (create : creation), or an abstract property (locate : location). The only reason to implement the ate ation rule would be the ability to recognize newly coined words.

But some derivational processes are highly regular. Take almost any English adjective and add ness; you get an abstract noun that denotes the same property as the original adjective. Implementing this morphological rule could eliminate the need for a lot of lexical entries. Some languages have numerous derivational processes that are as regular as this, and it would make no sense not to implement them as rules.

There is as yet no standard approach to computational morphology. In this chapter we will develop a somewhat ad hoc practical implementation of English inflection, adaptable to many but not all other languages. Then we’ll look briefly at more abstract models of morphology and at Koskenniemi’s two-level morphological parsing algorithm.

Exercise 9.1.1.1

English has a suffix er which, when attached to a verb, produces a noun denoting a person

or thing that does whatever the verb describes (teach : teacher, learn : learner, etc.).

Should a parser for English implement a rule that adds er to verbs, or should it simply

list all the er words in the lexicon? Make a recommendation and give reasons for it.

**9.1.2 Morphemes and Allomorphs**

<!-- page 273 -->
Any morphologically complex word can be broken up into several meaningful units called MoRPHS. For example:

dogs

**= dog+s**

dishes

**= dish+es**

undoing

**= un-+do-+**

ing

unrealities

**= un-+real+ity+s**

If two morphs are equivalent, we say they are ALLOMORPHS of the same MORPHEME. For example, the s in dogs and the es in dishes are equivalent to each other; they have exactly the same syntactic and semantic effect. We therefore classify them as allomorphs of the English plural morpheme.

To put this another way: MORPHS are the smallest meaningful segments into which a word is divided; MORPHEMES are morphs that have been identified (treating equivalent morphs alike); and ALLOMORPHS are the various forms of any morpheme.

**An English word consists of zero or more PREFIXES, followed by the RooT and**

then zero or more SUFFIXES:

Prefix

Root

Suffix

Suffix

untouchables

=

un

**+ touch + able**

4+

$5

Some languages also have INFIXES, which are inserted into the root (as in Tagalog s+um-+ulat, a form of the verb sulat ‘write’). Prefixes, suffixes, and infixes together are called AFFIXES.

.

Some languages also use VOWEL CHANGE as a morphological process. English does this in words such as begin : began : begun, mouse : mice, and foot : feet. The Semitic languages (Hebrew, Arabic, and their kin) use vowel change as the basis of their whole morphological system; here are some Hebrew examples:

katav

‘wrote’

_kotev

‘writing’

ahav

‘loved’

—ohev

‘loving’

bakhar

‘chose’

bokher

‘choosing’

amar

‘said’

omer

‘saying’

Here each verb form obviously consists of two parts, but the parts cannot be segmented into morphs in the usual way. One part of each verb form is the root, consisting of two or three consonants (k—t—v, —h—v, b—kh—r, or —m—r); the other part is the set of vowels, —a—a— for past tense or —o—e— for present participle.

Some words in some languages never appear without inflectional affixes. Consider Latin casa ‘house’:

Nominative

cas-a

Accusative

cas-am

Genitive

cas-ae__

(etc.)

<!-- page 274 -->
But cas— by itself is not a word; there is no way to say ‘house’ without marking it as nominative, accusative, genitive, or some other case. Instead, we say that cas— is the STEM of all the forms of the word for ‘house’.

Finally, some inflections and derivations are expressed by nothing at all; when thi happens, we call them ZERO MorPHS. For example, in English the plural of sheep is sheep. On one analysis, the plural should be viewed as sheep+@ where @ is the invisible. plural morph that appears in place of the usual s.

_

Like the phoneme, the morpheme is a descriptive concept from early twentieth-. century descriptive linguistics (Bloomfield 1933). A list of morphemes and allomorphs. is not nowadays considered to be an adequate analysis of the morphology of a language the real question is why the allomorphs are what they are. But segmentation into morphs, and classification of morphs into morphemes, is always a good first step in analyzing an unfamiliar language. Exercise 9.1.2.1

Break each of the following English words into morphs: childish, indescribable, repeating,

blessedness. Give the meaning and/or grammatical function of each morpheme.

Exercise 9.1.2.2

Identify the morphological process involved in each of the following examples:

- English black : blackness

- Greek phild ‘I love’ : philoumen ‘we love’

Greek philoumen ‘we love’ : ephiloumen ‘we loved’

Navaho dibddah : disbddh (two forms of the verb ‘start off for war’)

. English begin : began

**An wn**

. English run (present tense) : run (past participle)

**9.2 ENGLISH INFLECTION**

9.2.1 The System

Later in this chapter we will implement a morphological parser for English inflection. First, let’s review how English inflection works.

Verbs.

Each English verb has only a few forms. Four of them are unproblematic:

The PLAIN FORM, with no ending, as in Fido will bark;

The s FoRM, used in the third person singular, as in Fido barks;

The ING ForM, used both as an adjective (a barking dog) and as a noun (his loud

barking); and

The ED FoRM, used in the past tense (Fido barked).

<!-- page 275 -->
But English also has plenty of IRREGULAR VERBS (“strong verbs”) with two peculiarities:

**e The past tense does not end in ed; instead it is formed by vowel change (sing : sang,**

**eat : ate).**

**e There is usually a fifth verb form, which we will call the the EN FoRM, used after**

**has and other auxiliary verbs:**

**Fido has eaten.**

**(not ate)**

**Regular verbs don’t have a special form for this situation; they use the ed form (Fido**

**has barked).**

**Immediately we find ourselves in an analytical dilemma. Should we say that regular**

**verbs have no en form, or should we say that their en form is the same as their ed form?**

**The question is basically whether to complicate the syntax or the morphology. If**

**we say that regular verbs have no en form, then the syntactic component is going to**

**have to know whether each verb is regular, so that it can specify an en form in Fido**

**has eaten but an ed form in Fido has barked. If we say that regular verbs do have en**

**forms which are identical in form with their ed forms, the syntax becomes simpler but**

**the morphology has to deal with the fact that every verb that ends in ed is ambiguous:**

**barked = both bark+ed and bark-+-en.**

**We will take the second option, but with no great confidence that it is the best**

**analysis of modern English. Table 9.1 shows the forms of a number of regular and**

**irregular verbs, classified the way our morphological parser will analyze them.**

**TABLE 9.1 FORMS OF ENGLISH VERBS.**

Form

Examples

Example of use

plain

bark

eat

run

**Fido wants to bark**

/ eat / run.

s form

barks

eats

runs

Fido barks / eats / runs.

ing form

barking

eating ~—s running __ Fido is barking / eating / running.

ed form

barked

ate

ran

Fido barked / ate / ran.

en form

barked

eaten

run

Fido has barked / eaten / run.

**Adjectives and adverbs.**

**English adjectives, and some kinds of adverbs, take**

the inflectional suffixes er and est to form, respectively, the comparative and the superlative. These are used only on one- or occasionally two-syllable words (bigger, happier, but not *beautifuler).

**Just to keep down the total number of rules, we will not implement inflection of**

**adjectives or adverbs. Rules to handle it are easy to add.**

**Nouns. Most English nouns form the plural from the singular by adding s or**

**es. Some nouns are irregular (child : children, ox : oxen) and some (denoting edible**

**animals) have the plural the same as the singular (deer, sheep). Nouns borrowed from**

**other languages sometimes use the plural morphology of the original language (bac-**

**terium : bacteria, seraph : seraphim, chateau : chateaux).**

**For our purposes it will be sufficient to treat everything except the s/es suffix as**

**irregular, listing all irregular plurals in the lexicon. A more ambitious morphological**

**parser might recognize some of the foreign patterns, such as um : a.**

<!-- page 276 -->
**Chap,**

9

Possessive’s as clitic, not suffix.

There is abundant evidence that the possessive ending 5 is not an inflectional suffix for nouns, but rather a CLITIC, i.€., a syntactically separate word that is always pronounced as part of the previous word.

If ‘s were a noun inflection, it would never appear on anything other than a noun But in English it is at least marginally possible to say

the boy who came early’s lunch

and early is definitely not a noun (it is an adverb). This example may not be fully grammatical, but the point is that if s were a noun inflection, attaching % to an adverb would be flatly impossible, not just slightly deviant.

Further, if 5 were a noun inflection denoting possessive case, it would always attach to the noun that denotes the possessor. But in the phrase

[wp the dictator of Ruritania | ’s crimes the crimes are definitely those of the dictator, not of the country. Thus it is evident that what we have is not a “possessive case” of Ruritania, but rather a separate word, spelled ’s, which comes at the end of a complete noun phrase, and makes the whole noun phrase possessive.

The tokenizers in Appendix B already split off » and treat it as a separate word. We will ignore it in the morphological analysis to be done in this chapter. Exercise 9.2.1.1

Identify all the inflectional (but not derivational) morphology in the following sentences.

Distinguish ed forms from en forms of verbs even when they look alike.

Two elephants, surrounded by deer, marched into the garden.

Having bellowed loudly, the larger one knelt and its rider dismounted.

Then the tallest of the deer ran toward the chateaux.

**9.2.2 Morphographemics (Spelling Rules)**

English has a number of rules that change the spellings of various morphemes depending on the context. These are called MORPHOGRAPHEMIC RULES. The main ones that we have to deal with are as follows:

**1. Fina E DELETION: Silent final e disappears before any suffix that begins with a**

**vowel, as in rake+-ing = raking, rake+ed = raked. (We will assume that any final**

e that is preceded by a consonant is silent. Exceptions are rare enough to be listed

individually in the lexicon.)

2. Y-TO-I RULE: Final y changes to i before any suffix that does not begin with i:

**carry+ed = carried, but carry+ing = carrying. This occurs only when the final y**

**is not preceded by a vowel (delayt+ed = delayed, not *delaied).**

<!-- page 277 -->
3. S-TO-ES RULE: The suffix s, on both nouns and verbs, appears as es after s, z,

x, sh, ch, and after y which has changed to i. Thus

S

**grass+s =**

**= grasses, disht+s**

**=**

**dishes, carry+s**

= carries.

4. FINAL CONSONANT DOUBLING: Generally, a single final consonant doubles before any suffix that begins with a vowel; thus grab+ed = grabbed, grab+ing = grabbing, big+er = bigger. There are exceptions (offering, chamfering) but they are infrequent enough to list in the lexicon.

Notice that these rules do not all operate in the same direction. Specifically,

e Rules 1, 2, and 4 operate RIGHT-TO-LEFT: the form of the second morph (the suffix) influences the form of the first morph. e Rule 3 operates LEFT-TO-RIGHT: the form of the first morph influences the second.

All of these rules could be refined somewhat, but this is enough to get us started. English is unusual in having this much right-to-left influence; some languages, such as Latin, are easily analyzed without postulating any right-to-left morphographemic rules at all. Of course the most unusual thing about English here is that the spelling follows different rules than the pronunciation. In most languages we would have few or no MORPHOGRAPHEMIC (spelling) rules; instead we would have MORPHOPHONEMIC (pronunciation) rules which are reflected directly in the spelling.

Exercise 9.2.2.1 Indicate which morphographemic rules, if any, are involved in forming each of the following words:

amazing

matching

portrayed

whizzing

churches

merrier

bacteria

Which words involve more than one rule?

**9.3 IMPLEMENTING ENGLISH INFLECTION**

**9.3.1 Lexical Lookup**

<!-- page 278 -->
For morphological analysis, we want to look at the individual characters of each word. This means that we will represent words, not as atoms, but as CHARLIsTs (lists of onecharacter atoms, [[1,i,k,e], [t,h,i,s]]). We could have used strings (lists of ASCII codes), but then our code would be hard to read. (Quick, does [_,115] mate "es"? A tokenizer that produces charlists is given in Appendix B. ISO Standarc Prolog will encourage the use of charlists.

The next question is how to store the lexicon. Recall that Prolog has a very efficient. indexing (hashing) scheme for finding the first argument of any predicate. Accordingly we could convert every word to an atom when we want to look it up, and store the lexicon like this:

lex(dog, ...information about ‘dog’...

) . lex(cat, ...information about ‘cat’...

) .

The indexing scheme would find dog, cat, etc., very quickly.

But there’s a good reason not to do this. Imagine what happens when we find the word babies. First we have to look up babies in the lexicon to see if it’s an irregular form. Then we have to try various morphological rules; maybe it’s the plural of babie...no, there’s no such word. .. not the plural of babi either... so finally we look for baby and find it.

**Now recall how the Prolog symbol table works. Whenever an atom is created, it’s**

stored in the symbol table. But most Prologs do not GARBAGE-COLLECT the symbol table; that is, they don’t remove atoms that no longer exist in the program. In the process of looking up babies in the manner just described, the program would use not one, but four atoms (babies, babie, babi, and baby). If you do a lot of morphological analysis this way in a highly inflected language, you’ll eventually fill up the symbol table with useless material.

Fortunately, there’s an alternative: a structure called a LETTER TREE, CHARACTER TREE, or trie [short for retrieval; see de la Briandais (1959), Fredkin (1960), Knuth (1973:481-505)]. Figure 9.1 shows how it works. The idea is to look at each word letter by letter, and choose the appropriate branch of the tree each time. Eventually, if the word is in the tree, you get to the place where its lexical entry is stored.

Exercise 9.3.1.1

Draw, in the style of Figure 9.1, a letter tree for the words:

aardvark abacus

baker bark

bee

beef book 9.3.2 Letter Trees in Prolog

**Figure 9.2 shows the same letter tree represented in Prolog. We store the tree as the**

argument of a Prolog fact so that we can retrieve it easily.

The exact form of the tree bears explaining. Crucially, to progress from one letter to the next, we move into the list (i.e., into lists within lists). To search among alternative

<!-- page 279 -->
2Some Prologs let you write the ~a, ~b, etc., or 0’a, O’b, etc., for the numeric ASCII codes of a, b, etc. This solves the readability problem but isn’t portable.

**b-a-r—k**

bark

**r—r—-y**

carry

**c=a(**

cat

**Sol**

**€-g-o-r—y**

category

**d-e-l—a-y**

delay

**e-l—p**

help

h

hop

**o-p mo!”**

e

hope

**a-r—r—**

**y ———————quarry**

**q-url—z**

quiz

Figure 9.1 Letter tree for the words bark,

carry, cat, category, delay, help, hop, hope,

o-t—e

quote

quarry, quiz, and quote.

**ltree([{ [b, fa, [r, [k, bark]]]],**

[c, fa, [x,

(x,

ly, carry]]],

[t, cat,

le, [g,

fo,

[r,

ly, category]]]]]]]],

**[d, fe, fl, fa, ly, delay]]]]],**

th, fe, [1, [p, help]]],

[o,

[p, hop,

le, hope}]]],

(gq,

fu,

fa,

[x,

[xr,

ly, quarry]]]],

**fi, [z, quiz]],**

[o,

[t, [e, quote]]]]]

Figure 9.2 Letter tree from Figure 9.1, in Prolog.

**letters we move along the list (from one element to another). If cat were the only word**

**in the tree, it would be represented as [[c, [a, [t,cat]]]] so that each letter could**

**be reached by moving deeper into each succeeding element. Here the atom cat is the**

lexical entry; in real life this could be a much larger data structure containing many kinds of information about the word.

**All this needs to be defined more formally. We’ll define a TREE to be a list of**

<!-- page 280 -->
BRANCHES. Each branch is the portion of the tree that is relevant if a particular letter has been found in a particular position:

**e A branch is a list.**

e The first element of the list is a letter.

e Each succeeding element is either another branch, or the lexical entry for a word

e The elements are in a specific order: the lexical entry (if any) comes first, an

branches are in alphabetical order by their first letters.

So a branch representing cat, category, and cook would look like this:

[c, [a, [t, cat,

le, [g, lo, [r, ly, category]]]]]]]1,

[o, [o, [k, cook] ]]]

All this is probably easier to see than to describe. Note in particular that if you take the first element off a branch, you get a tree. That is, trees contain branches which contain trees which contain branches, and so on recursively.

The procedure to find a word in a tree is simple. In principle, all we need is:?

oe

find_word(+Word,+Tree,-LexEntry) -- First version oe

Finds Word in Tree retrieving LexEntry.

find_word([H|T],Tree,LexEntry) :-

member ([H|Branches],Tree),

```prolog
find_word(T,Branches,LexEntry).
```

find_word([],Tree,LexEntry) :-

member (LexEntry,Tree),

—

\+ (LexEntry = [_l_]).

That is: To find a word, find (in the current tree) the branch whose first element matches the word’s first letter. Then continue the search using the tail of that branch instead of the original tree, and looking at the next letter of the word. When you run out of letters, look for a non-list (i.e., a lexical entry) in whatever tree you’ve gotten to.

In fact, however, member/2 fails to exploit the fact that the branches are in alphabetical order. If the program finds a branch whose first letter is alphabetically after the letter it’s looking for, it should give up—that word definitely isn’t there, or the program would have found it already.

The built-in predicate @< will compare two atoms for alphabetical order. Accordingly, here’s a more efficient version of find_word, replacing member with find_branch:

ae

find_word(+Word,+Tree, -LexEntry) oe

Finds Word in Tree retrieving LexEntry.

<!-- page 281 -->
Here member/2 is as defined in Appendix A. find_word([H|T],Tree,LexEntry) :-

```prolog
find_branch(H, Tree, SubTree),
find_word(T, SubTree,LexEntry).
```

find_word([], [LexEntry|_] ,LexEntry) :-

\+ (LexEntry = [_|_]).

find_branch(+Letter,+Tree, -LexEntry) oe oe oe

Given a letter and a tree, returns the

appropriate (unique) subtree.

Deterministic.

find_branch (Letter, [[Letter|LexEntry] |_] ,LexEntry) :- !.

% Found it; there is only one.

find_branch(Letter, [[L|_]!_],_)

```prolog
:- Letter @< L,
                 !, fail.
```

% Went past where it should be; don’t search any further.

find_branch (Letter, [_|Rest] ,LexEntry) :-

find_branch (Letter,Rest, LexEntry) .

% Haven’t found it yet, so advance to next branch.

Notice that this version of find_word also exploits the fact that the lexical entry, if any, comes right at the beginning of the subtree.

Exercise 9.3.2.1

Get find_word working. Then take your letter tree from the previous exercise, express

it in Prolog, and show that find_word searches it correctly.

Exercise 9.3.2.2

Implement a predicate mparse/2 that takes a word (expressed as a charlist) and gives its

morphological analysis. Start as follows:

```prolog
mIparse(Word,Result) :-
  itree(Tree),
  find_word(...)...
```

You will use mparse extensively in what follows.

Exercise 9.3.2.3

Modify £ind_word so that a word can have more than one lexical entry, like this:

(r, fa, [k, [e, noun (rake) , verb (rake) J]d]

Assume that all the lexical entries are at the beginning of the list, immediately after the last

<!-- page 282 -->
letter of the word, before any other branches. 9.3.3 How to Remove a Suffix

By adding one more clause to find_word we can start parsing suffixes. Recall that — find_word works through each word one letter at a time. When trying to parse [d,e,1,a,y,e,d], for example, it will eventually be looking at [e,d]. At this. point it should recognize the suffix ed, then try to parse [] (ie., find a word that ends at. the point in the letter tree that it’s presently looking at) in order to find the root. Here’s . the clause that does this:

% Additional rule for suffix

find_word (Ending, Tree,Result+Suffix) :-

suffix (Ending, Suffix),

```prolog
find_word([],Tree,Result).
```

Of course now we need a table of suffixes, like this:

oe

```prolog
suffix(?Chars, ?Morpheme)
```

oe oe

Chars is a suffix, Morpheme is the representation

of it (identifying the morpheme)

.

suffix([s],s). suffix([e,d],ed) suffix([e,d], en).

```prolog
% Ambiguous verb suffix
```

suffix ( li, n,g],ing).

Recall that ed marks both the ed form and the en form of regular verbs; that’s why it’s in the table twice. If the suffixes were more numerous, it would pay to put them in a letter tree too.

Exercise 9.3.3.1

Get this extension to

find_word working. Show that your program will successfully

analyze barks, barked, hops, carrying, delayed, and cats.

Exercise 9.3.3.2

Add the adjective suffixes er and est to suffix/2 and add the roots odd and sweet to

the letter tree. Show that your program will correctly analyze sweeter, sweetest, odder, and

```prolog
oddest.
```

**9.3.4 Morphographemic Templates and Rules**

**Now for morphographemics. The morphographemic rules that we formulated in Section**

<!-- page 283 -->
9.2.2 work forward; that is, they start with the root and the suffix, and derive the actual correctly spelled form. What we want to do now is work backward, taking the observed form and picking it apart into root and suffix. This isn’t especially easy, for several reasons. For one, English morphographemics has a lot of right-to-left influence; the root itself changes form depending on what suffix follows it. Second, there are plenty of words in which more than one rule applies; quizzes, for example, undergoes both consonant doubling and the s-to-es change. Fortunately, in English the total number of inflectional suffixes and the total number of morphographemic rules is small. We can make a chart (Table 9.2) showing the effects of all the rules with each suffix on roots of various forms.

**TABLE 9.2 SOME ENGLISH**

**INFLECTIONAL ENDINGS,**

**SHOWING THE EFFECT OF ALL**

**MORPHOGRAPHEMIC RULES.**

Ending

Analysis

Example

s

**=**

$§

barks ses

**=**

sts

glasses zes

**= zs**

klutzes xes

**= xs**

foxes shes

**=**

sh+s

dishes ches

**=**

ch+ts

churches Cies

**=**

Cy+s

hobbies ed

**=**

ed

barked ed

**=**

et+ed

raked Cied

**=**

Cyted

worried ing

**=**

ing

barking ing

**=**

e-+ing

raking VCCed

**=**

**VC+ed**

grabbed VCCing

VC+ing — grabbing Vzzes

**=**

Vzt+s

quizzes

**Note: Throughout, V denotes any vowel,**

**and C denotes any consonant.**

**This suggests a shortcut: simply use the endings in Table 9.2 as templates, match**

**them to a word, and thereby extract the root and suffix. Fortunately, we don’t need quite**

**as many templates as are shown in the table, because many suffixes act alike. Doubling**

**occurs before any suffix that begins with a vowel, and y changes to i before any suffix**

**that doesn’t begin with i.**

**What we need is a predicate called split_suffix that extracts a suffix from**

**the ending of a word, or fails if there is no suffix. Figure 9.3 shows its clauses.**

**To distinguish consonants from vowels, sp1it_suf**

**fix relies on this predicate:**

oe vowel (?Char) oe Char is a vowel.

**vowel(a).**

**vowel(e).**

**vowel(i).**

```prolog
vowel(o).
            vowel(u).
                        vowel (y).
```

**The code for suf£ix/1 remains as before, but we need to get rid of the clause**

**of £ind_word that recognizes a suffix directly, and replace it with a clause that calls**

<!-- page 284 -->
split_suffix:

find_word(Chars,Tree, Root+Suffix) :-

```prolog
split_suffix(Chars, Stem, Suffix),
find_word (Stem, Tree, Root).
```

Exercise 9.3.4.1

Get all this new code working and show that it correctly parses carries, carried, carrying,

categories, hopping, hoping, quizzes, and quoting as well as all of the words correctly parsed

by the previous version.

Exercise 9.3.4.2

Using the code in this section, how many analyses of hoping do you get? Why?

Exercise 9.3.4.3

Add the adjectives big and large to the letter tree, and add the adjective suffixes er and est

to suffix/2 if you have not already done so. Then show that your program correctly

parses big, bigger, biggest, large, larger, and largest.

9.3.5 Controlling Overgeneration

So far our implementation still overgenerates—that is, it parses plenty of forms that don’t really exist. (The term “overgenerate” is used both for generators and for recognizers.) — Specifically:

e It lets you put any suffix on any word. In correct English, nouns don’t take ing or

ed, and irregular forms such as went don’t take any suffixes at all.

e It doesn’t recognize that certain morphographemic changes are obligatory. This

leads to misinterpretations. For example, our implementation doesn’t know that

hoping is not a form of hop (that is, it doesn’t know that the doubling in hopping

is obligatory).

**We can fix the first problem by enriching the lexical entry of each word, so that each**

lexical entry looks like this:

word (Morpheme, Category, Inf1)

**Here Morpheme identifies the word; Category is noun or verb (etc.); and Inf**

1 is 1 if the word takes inflectional endings and 0 if it does not. This enables us to check that ed and ing appear only on verbs, not on nouns. It also lets us ensure that irregular forms such as went don’t take any affixes at all. Figure 9.4 shows the letter tree with lexical entries in this form and with a few irregular forms added.

**We also need to modify the last clause of split_suffix—the one that adds a**

<!-- page 285 -->
suffix with no morphographemic changes—so that it won’t apply if doubling should have % split_suffix(+Characters,-Root,-Suffix) %

Splits a word into root and suffix. %

Fails if there is no suffix.

% Suffixes with doubled consonants in root split_suffix([V,z,z,e,s],[V,z],s).

```prolog
% "quizzes", "whizzes"
```

split_suffix([V,s,s,e,s],[V,s],s).

```prolog
% "gasses" (verb)
```

split_suffix([V,C,C,V2|Rest],[V,C],Suffix) :-

```prolog
vowel(V), \+ vowel(C), vowel(V2), suffix([V2|Rest],Suffix).
```

% y changing to i and -s changing to -es simultaneously split_suffix([C,i,e,s],[(C,y],s) :- \+ vowel(C).

% y changes to i after consonant, before suffix beg. w vowel split_suffix([C,i,X|Rest],[C,y],Suffix) :-

\+ vowel(C), \+ (X = i), vowel (X), suffix([X|Rest],Suffix).

% -es = -s after s (etc.) split_suffix([s,h,e,s],[s,h],s). split_suffix([c,h,e,s],[c,h],s). split_suffix([s,e,s],[s],s).. split_suffix([z,e,s],[z],s). split_suffix([x,e,s],[x],s).

% Final e drops out before a suffix beg. with a vowel split_suffix([C,V|Rest],(C,e],Suffix) :-

\+ vowel(C), vowel(V), suffix([V/Rest],Suffix).

% Ending of word exactly matches suffix. split_suffix(Ending,[],Suffix) :- suffix(Ending,Suffix).

Figure 9.3 Implementation of templates to recognize suffixes and undo mor-

```prolog
phographemics.
```

applied. (Actually, it shouldn’t apply if any other rule should have applied, but filtering out just the cases where doubling should apply is sufficient for our present purposes.)

Figure 9.5 shows split_suffix, suffix, and find_word in final form. (The predicates find_branch and vowel are not shown because they haven’t changed.) Notice that we allow the suffix s to attach to any syntactic category. Strictly speaking, that’s not correct, since it attaches only to nouns and verbs. But if we were to list it twice—as a suffix for nouns, and as a suffix for verbs—a lot of needless backtracking would take place. As it is, the slight remaining overgeneration is not troublesome.

Exercise 9.3.5.1

Get these predicates working and show that they still parse all the words that were correctly

parsed by previous versions; also show that they no longer accept hoped as a form of hop,

<!-- page 286 -->
or quizes as a form of quiz. ltree([ [b,

[a,

[r,

[k, word(bark,verb,1)]]]],

{[c,

[a,

{xr,

[xr,

ly, word(carry,verb,1)]]],

[t, word(cat,noun,1),

le,

[g,

fo,

Ir,

ly, word(category,noun,1)]]]]]]]],-

fd, [e,

[1,

[a,

ly, word(delay,verb,1)]]]]],

{g,

[o, word(go,verb,0),

[n,

[e, word(go+en,verb,0)]]]],

th, fe, [l, [p, word(help,verb,1)]]],

[o,

[p, word(hop,verb,1),

fe, word(hope,verb,1)]]]],

[q, [u,

fa,

[r,

[r,

ly, word(quarry,verb,1)]]]],

[i,

[zZ, word(quiz,verb,1)]],

[o,

[t,

[e, word(quote,verb,1)]]]]],

{w,

fe,

[n,

[t, word(go+ed,verb,0)]]]]

Figure 9.4 Revised letter tree with more information in the lexical entries.

Exercise 9.3.5.2

Modify split_suffix further so that carryed and hopeing will not be accepted.

**9.4 ABSTRACT MORPHOLOGY**

**9.4.1 Underlying Forms**

The frustrating thing about our morphological parser so far is that we weren’t able to implement the morphographemic rules directly; instead we had to figure out their effects, define templates, and combine some of the templates into rules of a new kind. In so doing, we find that the program no longer expresses how the rules really work.

Traditionally, morphophonemics (or morphographemics, in the written language) is the relationship between UNDERLYING and SURFACE forms. Underlying forms are listed in the lexicon; surface forms are what actually occur. The morphophonemic rules map one onto the other. An example:

Underlying form

quiz+s

**4**

s—>es after z

quizt+es

**a**

z doubles before suffix beginning with vowel

Surface form

quizzes

<!-- page 287 -->
This analysis has three levels; besides the underlying and surface forms, there’s a level in between, needed because the doubling rule can’t be triggered until the vowel e has been inserted. % split_suffix(+Characters,-Root,-Suffix,-Category) %

Splits a word into root and suffix. %

Fails if there is no suffix. %

Instantiates Category to the syntactic category %

to which this suffix attaches.

% Suffixes with doubled consonants in root split_suffix([(V,z,z,e,s],[V,z],s,_).

```prolog
% "quizzes", "whizzes"
```

split_suffix([V,s,s,e,s],[V,s],S,_).

```prolog
% "gasses" (verb)
```

split_suffix([V,C,C,V2|Rest],[V,C],Suffix,Cat) :-

```prolog
vowel(V), \+ vowel(C), vowel(V2), suffix([V2|Rest],Suffix,Cat).
```

% y changing to i and -s changing to -es simultaneously split_suffix((C,i,e,s],[C,y],s,_) :- \+ vowel(C).

% y changes to i after consonant, before suffix beg. w vowel split_suffix([(C,i,Xl!Rest],(C,y],Suffix,Cat) :-

\+ vowel(C), \+ (X = i), vowel (X), suffix([X|Rest],Suffix,Cat).

% -es = -s after s (etc.) split_suffix([s,h,e,s],[s,h],s,_). split_suffix({c,h,e,s],[{c,h],s,_). split_suffix([s,e,s],[s],s,_). split_suffix([z,e,s],(z],s,_). ’ split_suffix([x,e,s],(x],s,_).

% Final e drops out before a suffix beg. with a vowel split_suffix([C,V|Rest],[C,e],Suffix,Cat) :-

\+ vowel(C), vowel(V), suffix([V|Rest],Suffix,Cat).

% Ending of word exactly matches suffix. % (Does not apply if Doubling was required to apply. %

This eliminates spurious ambiguities such as hoped=hop+ed.) split_suffix([A,B,C]Rest], [A,B],Suffix,Cat) :-

```prolog
suffix([C|Rest],Suffix,Cat),
\+ (vowel(A), \+ vowel(B), vowel(C)).
                                          % Doubling
```

% suffix(?Chars, ?Morpheme, ?Category) %

If Chars is a suffix, Morpheme is the description of it, %

and Category is the syntactic category it attaches to.

suffix([s],s,_).

% let it attach to any category suffix([e,d],ed,verb). suffix([e,d],en,verb).

```prolog
% ambiguous suffix
```

suffix([i,n,g],ing,verb).

Figure 9.5 Morphological parsing predicates in final form (find_branch and vowel

<!-- page 288 -->
are unchanged). (Continues on page 274.) % find_word(+Word,+Tree, -LexEntry) %

Finds Word in Tree retrieving LexEntry % where LexEntry = word(Form,Category,Inflectable).

find_word([], [LexEntry|_]},LexEntry) :-

\+ (LexEntry = [_|_]).

find_word([HIT],Tree,LexEntry) :-

find_branch (H, Tree, SubTree),

```prolog
find_word(T,SubTree, LexEntry) .
```

find_word (Chars, Tree, word(Form+Suffix,Cat,0)) :-

% use split_suffix, but only with inflectable roots

```prolog
split_suffix(Chars,Stem,Suffix,Cat),
find_word(Stem,Tree,word(Form,Cat,1)).
                          Figure 9.5 cont.
```

Multilevel morphophonemics goes back at least to Bloomfield (1939). Here’s a Finnish example (from Anderson 1988a) that needs four levels:

Underlying form

karahka+i+ta

**4**

a-—o before i

karahko+i+ta

**4**

t disappears between vowels

karahko+i+-a

\|

**ij between vowels**

Surface form

karahkoja

**Why so many levels? Because, to a considerable extent, morphophonemic rules reflect**

context-dependent sound changes that have actually occurred in the history of the language. At one time, karahkoja probably was pronounced as karahkaita or something close. Again, here’s a simple example from Classical Greek:

Underlying form phile+ete

4

ee>ei

Surface form

phileite

<!-- page 289 -->
The rule that changes ee to ei is needed in Classical Greek to explain why a large number of suffixes have the forms that they do. But if we look at the Greek of Homer, a few hundred years earlier, we find that the word corresponding to classical phileite is actually written phileete. The change of e+e to ei was a historical event, not just an analytic abstraction. Not all morphophonemic rules reflect historic changes like this, but sound change is at least part of the reason why morphophonemic rules exist. Sec. 9.4

Abstract Morphology

275

Exercise 9.4.1.1

Show, step by step, how morphographemic rules generate the English words hopping, hop-

ing, quizzing, and carried from their underlying forms.

Exercise 9.4.1.2

Hebrew has a rule that nt is always realized on the surface as tt. Accordingly, give both the

underlying and the surface forms for the missing verb in this table:

shamar

‘hekept?

:

shamarti

‘I kept’

pa‘al

‘he did’

:

pa‘alti

‘T did’

nathan

‘he gave’:

?

‘I gave’

**9.4.2 Morphology as Parsing**

It would seem that the obvious way to do morphological parsing is to run all these rules backward, level by level. That, however, is difficult because so many of the rules introduce ambiguity by deleting letters or making different forms look alike. Consider the English rule that drops final e. It’s easy to work forward using this rule and convert rake-+ing to raking. But when it’s working backward, how can the parser recognize the final e’s that aren’t there?

Without guidance about where a silent final e can occur—guidance that cannot come from within the e-deleting rule itself—the parser can waste a lot of time hypothesizing deleted e’s where none are called for.

The same goes for deleted ?’s in Finnish, or ei reflecting underlying ee in Greek, and so on. Generally, the underlying form contains more information than the surface form, and the parser cannot reconstruct the missing information out of thin air.

Crucially, morphological analysis is quite different from syntactic parsing. The syntactic parser’s job is mainly to group and classify the elements of its input. The morphological analyzer, on the other hand, often has to deal with elements that aren’t there, or appear in quite different forms than are listed in the lexicon. Exercise 9.4.2.1

Of the four English morphographemic rules that we’ve been studying, which ones introduce

ambiguity (i.e., create a surface form that could have had more than one different underlying

form)? Give examples.

Exercise 9.4.2.2 (Small project)

Write a Prolog predicate apply_morphographemics/2 that will apply the morphogra-

phemic rules, working forward, given a charlist that represents the underlying form. For

example:

```prolog
?- apply_morphographemics ( [c,a,r,r,y,+,e,d],What).
What = [c,a,r,r,i,e,d]
```

Assume that + will mark all morpheme boundaries in the input string.

**ad**

<!-- page 290 -->
**9.4.3 Two-Level Morphology**

What we need is a morphological analyzer that is guided by the lexicon—one that. determines as early as possible what word it’s looking at, and chooses morphological

_ tules taking this knowledge into account. For example, we don’t want it to hypothesize a

| deleted final e unless the input so far is consistent with a real word that actually has one.:

**What we face, in fact, is a problem of string comparison. We want to step through**

the surface form, letter by letter, and simultaneously step through the underlying form. making sure that the two forms correspond in the way that the rules require, like this:

**un rake ed**

|

|

**|**

|

|

(every correspondence sanctioned by rules) un

**rak 0**

**ed**

**ot**

**ont**

Here 0 denotes a null (absent) character in the surface form, and + marks morpheme boundaries. We’ll have to restrict the rules so that only these two levels (underlying and surface) are needed, and not any intervening ones.

.

The underlying forms are stored in a letter tree, and the system will have to backtrack whenever the wrong underlying form has been chosen. This is unavoidable. Until it reads the final 1, the system has no way to know that spiel is not a form of spy. But choice of lexical item and choice of prefix or suffix will be the only sources of backtracking; the system will never waste time hypothesizing morphological changes that are not actually appropriate in the (apparent) context.

This is the essence of the TWO-LEVEL MORPHOLOGY developed by Koskenniemi (1983) and implemented by Karttunen (1983) in the computer program KIMMO. Koskenniemi’s original insights were that:

e No more than two levels are needed, because successive rules that require inter-

mediate levels can be combined;

e Most rules are independent of each other and can operate in parallel, simultane-

ously;

e Each rule can be implemented efficiently as a DETERMINISTIC FINITE-STATE TRANS-

DUCER (to be explained shortly). The results have been fruitful: KIMMO and its derivatives have been used to implement successful morphological parsers for English (Karttunen and Wittenburg 1983, Pulman et al. 1988, Ritchie et al. 1992), Japanese (Alam 1983), French (Lun 1983), Finnish (the language on which Koskenniemi originally worked), German (Trost 1991), and other languages. That’s a wide variety.

Exercise 9.4.3.1

How many levels are used in our original system (split_suffix and its kin)? Is ita

one-level system, a two-level system, or what? Explain why.

4An IBM PC implementation of KIMMO was released in 1990 by the Summer Institute of Linguistics, 7500 West Camp Wisdom Road, Dallas, Texas 75236.

<!-- page 291 -->
‘ 9.4.4 Rules and Transducers

**Here is our final-e-deletion rule expressed in KIMMO’s framework:**

**eO0 => C:C _ +:0 V:V**

**where C is any consonant and V is any vowel.**

Here the notation ‘x:y’ means ‘underlying x corresponding to surface y.’ So the rule as a whole says: e:0 (that is, underlying e corresponding to surface null) occurs if and only if preceded by C:C (that is, a consonant) and followed by +:0 (morpheme boundary corresponding to surface null) and then V:V (a vowel).

Figure 9.6 shows this same rule expressed as a DETERMINISTIC FINITE-STATE TRANS- DUCER, i.€., a State-transition network that steps through the two strings, accepting or rejecting them, and never backtracks. The transducer can be described by either a diagram or a table, and both are shown.”

C:C

other

any me IN

**QO**

**©**

other

State | C:C

V:V_

e:0

+:0

other | Can stop?

1

2

1

yes

2

2

3

1

yes

3

4

no

4

5

no

5

1

yes

Figure 9.6 Finite-state transducer for final e deletion, shown as a diagram and as a

```prolog
table.
```

This transducer has five states. It starts in state 1 and must finish in state 1, 2, or 5, denoted by double circles. The states are linked by arcs, and the transducer goes from one state to another by accepting the pair of underlying and surface characters indicated

<!-- page 292 -->
On transition networks see also the end of Chapter 3. on the arc. An arc labeled ‘other’ can only be taken if none of the other arcs leading oy of the same node is applicable.

The idea is to run the transducer like a machine, feeding it letters (or rathe underlying-surface letter pairs), and check that it ends up in state 1, 2, or 5 at th end of the word. If it finishes in some other state, or if it BLOCKS (gets into a state fro which there is no arc corresponding to the next character), then the proposed underlyin and surface strings can’t go together; the parser must back up and try a different lexical: item if one is available.

Suppose, for example, we feed it the strings:

**rak ted**

**o-—**

oO |

**||**

|

|

| rak Oed

Here’s what happens:

—Start in state 1.

—Accept r:r (a consonant); go to state 2.

—Accept a:a (which matches only the ‘other’ arc); go back to state 1.

—Accept k:k (a consonant); go to state 2.

—Accept e:0 and go to state 3.

—Accept +:0 and go to state 4.

—Accept e:e (a vowel) and go to state 5.

—Accept d:d and go to state 1.

—Encounter end of word. Stopping in state 1 is permissible, so the word is accepted.

Notice that if the underlying or the surface form is unknown, either one can be obtained from the other by simply running the transducer. That is, the transducer serves both to parse and to generate forms.

In KIMMO, the transducers for all the rules run simultaneously, in parallel, and a pair of strings is accepted only if none of the transducers reject it. Further, KIMMO has an automatic compiler to translate rules into transducers.

Exercise 9.4.4.1

What does this transducer do when given each of the following inputs?

**nw**

**Oo**

— oO

K

i)

**vy**

wv

oO;

<!-- page 293 -->
oO

**ab**

a

**|**

|

**ab**

a

a-—-a

o-—o

**rh**

— Fh

**Q —Q**

Exercise 9.4.4.2

Our y-to-i rule says that underlying y must be realized as surface i when preceded by a

consonant and followed by a morpheme boundary and then a vowel other than i.

(a) Express this rule in KIMMO’s notation.

(b) Convert this rule into a finite-state transducer and draw a diagram of it.

9.4.5 Finite-State Transducers in Prolog

Space and time preclude giving a full implementation of two-level morphology here, but we can at least implement a bit of it. [For a full KIMMO system in Prolog see Boisen 1988}.

Figure 9.7 shows our finite-state transducer (from Figure 9.6) implemented in Prolog. It’s surprisingly simple, consisting mostly of a table of how to get from one state to another. Notice that when there are multiple clauses starting in the same state (corresponding to multiple arcs), each of them except the last contains a cut. This allows the last clause—the ‘other’ arc—to be taken only if none of the preceding ones match the input.

Note added 2013: As the cuts in Fig. 9.7 suggest, this implementation ignores some subtleties. Instead of cuts, a more

sophisticated system would use a Sth argument to distinguish ‘others’ arcs, which apply to input that does not match the

rules, from situations in which a rule is violated. See Ritchie et al. 1992:21-26.

This transducer succeeds if given an acceptable pair of input strings, and fails if given an unacceptable pair, like this:

?- transduce(1,State, [r,a,k,e,+,e,da],[(r,a,k,0,0,e,da]). State=1

yes

?- transduce(1,State, [r,a,k,e,+,e,d],[r,a,k,e,0,e,da]). no

**What’s more, in fine KIMMO tradition, it can find either one of the strings given the**

other one:

?- transduce(1,State, [r,a,k,e,+,e,d],What). State=1 What=[r,a,k,0,0,e,a]

?- transduce(1,State,What, [r,a,k,0,0,e,d]). State=1 What=([r,a,k,e,+,e,4]

Notice that deterministic finite-state transducers run fast and never backtrack. Exercise 9.4.5.1

Get the transducer working as shown, modify it to output information about each state

transition that it performs, and use it to check your work from the first exercise of the

<!-- page 294 -->
previous section. % state(+Old,-New, ?Undl1, ?Surf) %

Allows moving from state Old to state New ®

by accepting Undl and Surf characters.

state(1,2,C,C) :- \+ vowel(C), !. state(1,1,X,X). state(2,3,e,0)

```prolog
:-
  !.
```

state(2,2,C,C) :- \+ vowel(C), !. state(2,1,X,X). state(3,4,+,0). state(4,5,V,V) :- vowel(V). state(5,1,X,X).

final_state(?N) ae ae

N is a state in which the transducer can stop.

final_state(1). final_state(2). final_state(5).

vowel (V) de oe

V is a vowel.

vowel(a).

```prolog
vowel(e).
            vowel(i).
                        vowel(o).
                                   vowel(u).
                                               vowel (y).
```

2 % transduce(Start, Finish, Und1lString, SurfString)

transduce (Start, Finish, [U]UndlString], [S| SurfString})

state(Start,Next,U,S),

transduce (Next, Finish, UndlString, SurfString) .

transduce(Start,Start,[],[]) :-

final_state(Start).

Figure 9.7

Finite-state transducer from Figure 9.6, in Prolog.

Exercise 9.4.5.2

Add a clause to transduce that allows it to “accept” a null without actually accepting

any characters. This will allow us to write [r,a,k,e,d] instead of [r,a,k,0,0,e,4]

(very important for practical parsing). Verify that this works and use it to find the underlying

string corresponding to raked. How many alternative answers do you get? Is this correct

behavior? Explain why or why not.

Exercise 9.4.5.3

In a previous exercise you expressed the y-to-i rule as a finite-state transducer. Now imple-

<!-- page 295 -->
ment it in a program similar to that in Figure 9.7, and show that it correctly parses carrying. Exercise 9.4.5.4 (small project)

Now that you have two transducers, make them apply in parallel to the same input. That

is, as you step through the strings, feed each pair of characters to both transducers. Verify

that the resulting program accepts raked and carried and rejects rakeed and carryed.

Exercise 9.4.5.5

(project)

Implement all four English morphographemic rules as transducers; also implement true

lexical search (that is, instead of being given an underlying form as input, the program

should search the character tree or the set of suffixes as appropriate). The result should be

a very satisfactory parser for English inflection.

9.4.6 Critique of Two-Level Morphology

All in all, KIMMO looks very promising. How satisfied should we be with it?

The big question is whether two levels are really enough. Of course it’s possible to make do with two levels—or even with no levels at all, by listing everything in the lexicon. But are two levels enough to capture the way a morphological system really works?

Perhaps so. Some analyses don’t really need as many levels as they seem to. Recall that our three-level analysis quizt+s —> quiztes — quizzes was motivated by the fact that doubling can’t be triggered until the vowel is put in. We were assuming that each rule could only look at the level immediately above it. By letting every rule look at both the underlying and surface forms, KIMMO avoids this problem; the doubling can be triggered by the following vowel that is, in some sense, “already there” in the surface though not the underlying form.

On the other hand, there are undeniably a lot of clear, insightful analyses that can only be stated by using more than two levels. Anderson (1988a) points out that KIMMO’s Finnish lexicon does in fact treat some forms as irregular that could have been predicted by multilevel rules. So it would be premature to conclude that two levels are entirely adequate for describing the structure of a morphological system.

Another strike against KIMMO is that finite-state transducers are not the guarantee of simplicity that they seem to be. Barton, Berwick, and Ristad (1987) have proved that KIMMO’s formalism is powerful enough to encode NP-complete problems, i.e., problems that require gigantic amounts of computer time. This is not a fatal objection, because no cases of apparent NP-completeness have shown up in real morphological systems. Apparently, and not surprisingly, human language is constrained in ways that KIMMO does not yet recognize.

<!-- page 296 -->
Still less serious are the objections that KIMMO does not yet have some needed mechanisms. So far KIMMO has no good way to deal with discontinuous morphemes (such as Hebrew vowel patterns), nor with syntactic conditioning of morphophonemics [as when the French suffix e causes consonant doubling on adjectives but not on verbs, (Ritchie et al. 1992:185)]. Nor can it refer to phonological features (such as the feature [+labial] that distinguishes p, b, and m from all the other consonants); instead it has to use explicit lists or sets of phonemes (or letters). If KIMMO’s basic approach Proves” adequate, additional mechanisms to do these jobs can easily be added.

**9.5 FURTHER READING**

Sproat (1992) is a fine introduction to morphology in general and computational morphology in particular. To get more acquainted with morphological phenomena, read the opening chapters of Spencer (1991), or the whole of Matthews (1991), and/or the’ appropriate parts of a descriptive linguistics text (even Bloomfield 1933); then, to learn about computer implementations, proceed to Wallace (1988) (available from UCLA), and Ritchie, Black, Russell, and Pulman (1992).

Morphology is an oddly placed branch of linguistics. In traditional generative grammar, morphology is not a separate level; morphophonemics is subsumed into phonology. The classic work in this genre is Chomsky and Halle (1968), which is now widely considered to be too abstract, and certainly does not lend itself to computer implementation. For reviews of present-day phonological and morphological theory, and references to further reading, see the articles in Newmeyer (1988, vol. 1) as well as the later chapters of Spencer (1991).
