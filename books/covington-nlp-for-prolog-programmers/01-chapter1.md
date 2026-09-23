# Chapter1

<!-- page 15 -->
<!-- page 16 -->
Natural Language Processing for Prolog Programmers

**Natural Language**

**1.1 WHAT IS NLP?**

Natural language processing (NLP) is the use of computers to understand human (natural) languages such as English, French, or Japanese. By “understand” we do not mean that the computer has humanlike thoughts, feelings, and knowledge. We mean only that the computer can recognize and use information expressed in a human language. Some practical applications for NLP include the following:

e English as a command language—that is, the use of human languages in place of

the artificial languages presently used to give commands to computers.

e Databases and computer help systems that accept questions in English.

e Automatic translation of scientific and technical material and simple business com-

munications from one human language to another.

e Automatic construction of databases from texts of a technical nature, such as equip-

ment trouble reports or medical case reports.

<!-- page 17 -->
All of these applications already exist in prototype form. Some of them are in commercial use—for example, a computer program regularly translates weather reports from English into French in Canada (Thouin 1982).

These applications are successful because they don’t require the computer to know much about the real world. Database programs simply use English to represent information they would otherwise represent in some other form. Translation programs take advantage of the fact that technical texts seldom refer to anything outside a well-defined area of knowledge. It would be much harder to get computers to understand poetry, fiction, or humor, because understanding these kinds of material requires extensive human experience and knowledge of the real world.

Successful NLP, then, depends on putting limits on the need for outside knowledge and human experience. It also depends on two other things.

First, NLP depends on cheap computer power. Here the advent of powerful microcomputers in the 1980s has made a big difference. Previously, NLP was so expensive that people would accept only perfect results, which were never achieved, That situation has changed. Machine translation, for instance, is making a comeback. Imperfect translations may not be worth $1000 a page, but if they can be had for 10 cents a page, people will find plenty of uses for them.

Second, and even more important, NLP depends on exact knowledge of how human languages work—and right now we don’t know enough. Until recently, languages were studied almost exclusively for the purpose of teaching them to other human beings. The principles that underlie al/ human languages were (tightly, for the purpose) ignored. The science of linguistics is only a few decades old, and there is still no consensus about some of the most basic facts. This sometimes comes as a shock to computer programmers who expect complete descriptions of human languages to be available off-the-shelf.

This chapter will survey the scientific study of human language, with an emphasis on basic concepts and terminology that will be used in subsequent chapters. Exercise 1.1.0.1

List several reasons why weather reports are especially easy for computers to process.

Exercise 1.1.0.2

Give an example of an ordinary English sentence whose meaning is quite unclear in isolation,

but perfectly clear when heard in the appropriate context.

Exercise 1.1.0.3

(for discussion)

Under what circumstances would you be willing to use an imperfect, machine-generated

translation of a foreign-language paper or document? Under what circumstances would it

be dangerous to do so?

**1.2 LANGUAGE FROM A SCIENTIFIC VIEWPOINT**

On many points linguists do agree. Here are some of the most important.

<!-- page 18 -->
First, LANGUAGE IS FORM, NOT SUBSTANCE. That is, a language is not a set of utterances or behaviors—it is the underlying system of rules (regularities) that the behaviors follow.

Another way to say this is to distinguish between the speaker’s COMPETENCE (the system) and his or her PERFORMANCE (the observable behavior). This distinction recognizes that accidental mispronunciations, interrupted sentences, and the like, are not really instances of the language that the person is speaking; instead, they are deviations from it.

**Second, language is ARBITRARY. A language is a set of symbols which people agree**

to use in specific ways. There is no deep reason why the word for ‘chair’ should be chair in English, chaise in French, Stuhl in German, and so forth. These words just happen to have these meanings. If you decided you wanted to call a chair a table, this would be “wrong” only in the sense that you would not be cooperating with other speakers of English.

Third, language is DISCRETE (digital), not continuous (analog). That is, languages rely on symbols that are sharply distinct, not positions on a continuum. For example, if you make a sound that is physically between a and e, speakers of English will hear it as either a or e, or else they will ask you which sound you meant. They will take it for granted you meant one sound or the other.

Similarly, if you see a color intermediate between red and orange, you can call it red or you can call it orange, or you can even use both words in some combination, but you cannot normally make up a word whose pronunciation is a physical mixture of the pronunciations red and orange. You have to choose one or the other.

Fourth, all human languages use DUALITY OF PATTERNING, in which words are strings of sounds, and utterances are strings of words. The words have meaning; the sounds, by themselves, do not. A complex word such as dogcatcher can be divided into meaningful units such as dog, catch, and er, but each of these is a string of smaller units that have no meaning.

Fifth, ALL LANGUAGES ARE ABOUT EQUALLY COMPLICATED, except for size of vocabulary. Primitive cultures do not have simpler languages, nor are ancient languages simpler than modern ones.

Languages change constantly, but each change is a trade-off. Simplifying the sound system may complicate the system of verb forms, or vice versa. Often, a language evolves in a particular direction for thousands of years; for example, the languages descended from Latin have gradually lost the noun-case system. But other languages, such as Finnish, are evolving in the opposite direction; the noun cases of Finnish are getting more complex. There are no simple ways to predict what the languages of the future will be like.

**Sixth, EVERYONE SPEAKS HIS OR HER OWN LANGUAGE. My English is not entirely**

the same as your English, though it is probably very close. Because of the way language is learned, slight differences between individuals, and large differences between societal groups, are inevitable.

<!-- page 19 -->
This point is worth emphasizing, because some people think that only the most prestigious, educated dialect of a language is “real” and that people who speak other dialects simply can’t talk (or even think) very well. The truth is that every variety of a language has definite rules of grammar, but the rules vary from dialect to dialect. Exercise 1.2.0.1

Does tone of voice in English follow the principle of discreteness? Explain and cite evidence

for your conclusion.

Exercise 1.2.0.2

Suppose someone claims that there is no duality of patterning in the Chinese language

because the written symbols stand for whole words. How would you answer this claim?

Exercise 1.2.0.3

The sounds of w and wh have become the same in English as spoken in England and most

of the United States; they remain distinct in Scotland and the Deep South.

On the whole, does this change simplify the language or complicate it? In what ways

does it make English easier to speak or understand? In what ways does it make it harder?

Point out a pair of words that have become harder to distinguish as a result of this sound

```prolog
change.
```

**1.3 LANGUAGE AND THE BRAIN**

Speaking languages is a distinctively human activity. So is playing checkers. Why, then, is there a science of linguistics but not a science of checkerology?

The answer is that there is good evidence that the human brain is specially structured for language, but not for checkers. When people play checkers they are merely using mental abilities that they also use for many other purposes, but this is not the case with language.

The evidence comes from two main sources. The first is the study of brain injuries. There are specific areas of the brain’ which, when injured, impair a person’s use of language in specific ways. Damage to one area affects the ability to construct sentences; damage to another area affects word recognition; and so forth. To a surprising extent, corresponding parts of the brain have corresponding functions in all individuals. By contrast, there is of course no specific area of the brain devoted to checker-playing, and brain injuries that stop a person from playing checkers while leaving the rest of his or her mental abilities intact are rare or nonexistent.

The second kind of evidence comes from language acquisition. All children learn the language of the people around them, whether or not anyone makes any effort to teach them how to talk. This learning takes place in definite stages and is quite independent of the general intelligence of the child; even mentally retarded children learn exactly the language to which they are exposed, though they learn it more slowly. It appears, then, that acquiring a native language is like learning to walk—it is a matter of activating structures in the brain that are pre-programmed for the purpose, rather than learning information from scratch. Cook (1988, ch. 3) discusses this issue in detail. Exercise 1.3.0.1

(for discussion)

All known languages have duality of patterning (defined in Section 1.2). Does this fact

<!-- page 20 -->
constitute evidence that the brain is pre-programmed for language? Why or why not? 1.4 LEVELS OF LINGUISTIC ANALYSIS

The structure of any human language divides up naturally into five levels: PHONOLOGY (sound), MORPHOLOGY (word formation), SYNTAX (sentence structure), SEMANTICS (meaning), and PRAGMATICS (use of language in context). The levels do, of course, interact to some extent. This section will survey the five levels and define many commonly used terms.

1.4.1 Phonology

Phonology is the study of how sounds are used in language. Every language has an “alphabet” of sounds that it distinguishes; these are called its PHONEMES, and each phoneme has one or more physical realizations called ALLOPHONES.' Consider for example the f sounds in the words top and stop. They are physically different; one of them is accompanied by a puff of air and the other isn’t. (Pronounce both words with your hand in front

- of your mouth to see which is which.) Yet in English these two sounds are allophones of the same phoneme, because the language does not distinguish them. Other languages, such as Hindi, make a distinction between these two sounds.

From the NLP point of view, the main challenge in phonology is that sound waves are continuous but phonemes are discrete. In order to understand speech, a computer must segment the continuous stream of speech into discrete sounds, then classify each sound as a particular phoneme. This is a complicated problem in pattern recognition.

One difficulty is that consecutive sounds overlap. In the word man, the a and the n are almost completely simultaneous. (A pure a followed by a pure n would sound unnatural.) In the word bit, the b and the t are almost completely silent; they are recognized by their effect on the i between them. The influence of adjacent sounds on each other is called COARTICULATION.

Another difficulty is that speech varies from one person to another and even from occasion to occasion with the same speaker. Some New Yorkers pronounce pat exactly the way some Texans pronounce pet. This is one of the reasons speech-recognition systems have to be “trained” for the speech of a particular person.

SPEECH SYNTHESIS, the creation of speech by computer, is considerably easier than speech recognition. A synthesizer’s most important task is to simulate coarticulation. This is usually done by providing several allophones for each phoneme, each to be used when a different kind of phoneme is adjacent. Recognizable speech has been generated by this method since the 1960s.

The hardest part of speech synthesis is INTONATION (tone of voice). The buzzing, robotlike sound of cheap synthesizers is due to the fact that they have no intonation; the voice always stays at the same pitch. More sophisticated synthesizers try to model realistic intonation. The best synthesized English that I have heard sounded quite lifelike;

<!-- page 21 -->
Halle (1959) showed that classical phonemic theory misses some generalizations, and more modern theories of phonology do not refer to phonemes as such. But the classical phoneme remains a useful working approximation, particularly for speech synthesis. it sounded like a person who had a cold (because the nasal sounds were not quite perfect) and a slight Swedish accent (because the intonation was not quite right, either). Algorithms are being developed that calculate intonation from sentence structure.

Technologically, computer speech is quite separate from the rest of natural language processing, and this book will not treat it further. [For the basics see Denes and Pinson (1963), which is much more relevant than the date suggests; then, for in-depth technical coverage, see O'Shaughnessy (1987).] Computer speech relies heavily on waveform analysis and pattern recognition, while computational morphology, syntax, semantics, and pragmatics rely on symbolic programming and automated reasoning. Exercise 1.4.1.1

People whose native language is Spanish often have trouble distinguishing the sounds of b

and v in English. What does this tell you about the phonemes of Spanish?

Exercise 1.4.1.2

Would a speech synthesizer designed for English be able to speak French or Chinese?

Explain.

**1.4.2 Morphology**

Morphology is word formation. Every language has two kinds of word formation proc- @sses: INFLECTION, which provides the various forms of any single word (such as singular man and plural men, present runs and past ran), and DERIVATION, which creates new words from old ones. For example, the creation of dogcatcher from dog, catch, and —er is a derivational process.

Unfortunately, the distinction between inflection and derivation is often unclear; we don’t know precisely what we mean by “different words” versus “different forms of the same word.”

One guideline is that only derivation, not inflection, can introduce an unpredictable change of meaning. That is, derivation produces words which are listed separately in a speaker’s mental dictionary (LEXICON) and can thus have meanings that are not predictable from their parts.

Consider dogcatcher. You may know what dog and catch mean, but this does not tell you that a dogcatcher is a public official rather than, say, a machine or a trained tiger. The word dogcatcher means more than just “something that catches dogs.” Thus we know that it is created derivationally.

Another guideline is that derived forms are often missing—that is, you have to learn whether or not a derived form actually exists—while inflected forms are almost never missing (nonexistent). Every English verb has a past tense; that’s inflection. Some adjectives form nouns ending with ity (such as divine : divinity); others don’t, and there’s no way to predict in advance whether any particular adjective will take ity; that’s derivation.

<!-- page 22 -->
But the catch is that derivation can be almost as regular as inflection. The English suffix ness behaves very regularly, forming nouns from practically all adjectives, such as goodness, badness, blueness, etc., from good, bad, and blue. There is nothing unpredictable about the words thus created. Still, we call this process derivational because it creates words of one category (nouns) from words of another category (verbs).

Inflection in English is much simpler than derivation. An English verb typically has only a few forms (such as catch, catches, caught, catching), and a noun has only two forms (dog, dogs). Most of these are formed by very regular rules, but a few are irregular (we say caught rather than catched).

Contrast this with Latin, where every verb has over 100 forms, such as capio ‘I catch’, capis ‘you catch’, cepi ‘I have caught’, cepisset ‘he might have caught’. Latin also inflects nouns to indicate their position in the sentence; ‘dog’ is canis if it is the subject but canem if it is the direct object. Russian, Japanese, Finnish, and many other languages have inflectional systems that are equally complex.

The simplicity of English inflection has led NLP researchers to neglect morphology. If other languages are to be processed effectively, adequate computational models of morphology will have to be developed. We will return to this topic in Chapter 9.

Exercise 1.4.2.1

Say whether each of the following word formations is inflectional or derivational, and give

the reason for your conclusion.

(a) observed from observe

(b) observation from observe

(c) dogs from dog

(d) high school from high and school

Exercise 1.4.2.2

(for discussion)

Briefly describe the morphology of a foreign language you have studied, and compare it to

English.

1.4.3 Syntax

Syntax, or sentence construction, is the lowest level at which human language is constantly creative. People seldom create new speech sounds or new words. But everyone who speaks a language is constantly inventing new sentences that he or she has never heard before.

**This creativity means that syntax is quite unlike phonology or morphology. A**

good way to describe the sounds or word-formation processes of a language is to simply make a list of them. But there is no way to make a list of the sentence structures of a language—there are too many. In fact, if there is no limit on sentence length, the number of sentence structures is demonstrably infinite.

<!-- page 23 -->
Noam Chomsky (1957) was the first to make this point. He introduced GENERATIVE GRAMMAR, which describes sentences by giving rules to construct them rather than by listing the sentences or their structures directly. For example, the rules sentence —>

**noun phrase + verb phrase**

noun phrase —>

**determiner + noun**

verb phrase

-—>

**verb + noun phrase**

determiner

-—>

the determiner —>

a noun —>

dog noun

-—>

cat verb

-—>

chased verb —>

saw generate a number of sentences, among them this one:

sentence ae

noun phrase

verb phrase

**ae**

determiner noun

verb

noun phrase

**UO**

determiner

noun

|

| the dog

saw

the

cat

<!-- page 24 -->
Rules of this type have become standard not only in linguistics, but also in computer science and especially in compiler development. Crucially, a finite set of rules can describe an infinite number of sentences. We will return to this point in Chapters 3 and 4. Recognition of sentence structure by computer is called PARSING. To parse a sentence the computer must match it up with the rules that generate it. This can be done either TOP-DOWN or BOTTOM-UP. A top-down parser starts by looking for a sentence, then looks at the rules to see what a sentence can consist of. A bottom-up parser starts by looking at the string of words, then looks at the rules to see how the words can be grouped together. The best parsers use a combination of the two approaches (see Chapter 6). Parsing of English has been studied extensively, and some NLP researchers consider it practically a solved problem. The issue today is what is the best way of parsing English, not whether there is a way. Parsing of other languages has not been investigated as thoroughly; most present-day parsing techniques rely on fixed word order and do not work well for languages in which word ordet is highly variable, such as Latin, Russian, or Finnish. Exercise 1.4.3.1 Use the rules above to generate two more sentences, and draw tree diagrams of their structures. 1.4.4 Semantics

Semantics, or meaning, is the level at which language makes contact with the real world. As a field of study, semantics has only recently started to mature. For a long time it was unclear how to describe the meanings of natural-language utterances. Suitable tools have now been provided by mathematical logic and set theory, and since 1970 the study of semantics has made great strides.

The distinction between SENSE (meaning) and REFERENCE is basic. In the sentence

The president said he hated broccoli.

the word president MEANS ‘chief executive of the United States’ but REFERS to George Bush. Clearly, president could refer to someone else—whoever happened to be president at the time. The sense’ of a word determines what it can refer to; anything that we call president has to be a chief executive, unless we change the meaning of the word.

There are many different kinds of reference. In a sentence like The lion is the king of beasts, the word lion refers to a species, not an individual lion. Reference was studied extensively by medieval logicians (who called it suppositio), and their classifications are still sometimes used.

,

Multiple kinds of reference are particularly a problem with plurals. If I say the students are wearing sweaters I mean that each student individually is wearing a sweater, but if I say the students are numerous J do not mean that each student is numerous—I mean that the set of students is large.

Many words are AMBIGUOUS, 1.e., they have more than one meaning. Consider pen in the sentence There is ink in the pen versus There are pigs in the pen. Or think of how many things pipe can mean—anything from a flute to a piece of plumbing. Some of the meanings of pipe are connected in understandable ways, and some are not. The point is that they are distinct, and in a particular context, the hearer must pick out the right sense for the word, a process called WORD-SENSE DISAMBIGUATION. Human beings are very good at this, but good computer techniques have not yet been developed.

Sentences can be ambiguous, too, either because words within them are ambiguous, or because the sentence has more than one possible structure. A famous example is I saw the boy with the telescope, in which with the telescope modifies either the boy or saw—it says either which boy I saw, or how I saw him.

SEMANTIC COMPOSITION is the combining of meanings of words to form the meanings of phrases and sentences. Clearly the meaning of John loves Mary is a combination, somehow, of the meanings of John, loves, and Mary. Just as clearly, however, the meanings are not just piled together in a structureless way; if they were, John loves Mary would mean the same thing as Mary loves John, and it doesn’t.

One way to account for semantic composition is to represent meanings as logical formulas. Some examples:

loves (john, mary)

‘John loves Mary’

**(Vx)crow (x) — black(x)**

<!-- page 25 -->
‘All crows are black’ LAMBDA NOTATION, which we will meet in Chapter 2, provides a way to encode formulas with information missing, thus:

(Ax)loves(x,mary)

‘loves Mary’

(Ay)(Ax)loves(x,

y)

‘loves’

This gives us representations for the meanings of words and phrases as well as whole sentences. We will explore this more fully in Chapter 7.

Ipioms are phrases whose meaning is not predictable from the meanings of the parts. A classic example is kick the bucket, which means ‘die’. The meanings of idioms are said to be NONCOMPOSITIONAL; idioms have to be listed in the lexicon. Exercise 1.4.4.1

Each of the following sentences is ambiguous. Identify two distinct meanings for each

sentence, and say whether the ambiguity is caused by ambiguous words, ambiguous structure,

or both.

1. Students may come into the room.

2. I need to ask for books in Spanish.

3. Flying planes can be dangerous.

4. I detest visiting relatives.

1.4.5 Pragmatics

Pragmatics is the use of language in context. The boundary between semantics and pragmatics is uncertain, and different. authors use the terms somewhat differently. In general, pragmatics includes aspects of communication that go beyond the literal truth conditions of each sentence.

Suppose, for example, that while lecturing, I look at a student sitting next to the open door of the classroom and ask, Can you close the door? If she just answers Yes she’s missed the point. My question was implicitly a request. Without knowing the pragmatics of English a person (or a computer) would fail to realize this. Whereas syntax and semantics study sentences, pragmatics studies SPEECH ACTS and the situations in which language is used.

An important concept in pragmatics is IMPLICATURE. The implicature of a sentence comprises information that is not part of its meaning, but would nonetheless be inferred by a reasonable hearer. In the example just mentioned, Can you open the door? is, by implicature, a polite request, not just a question; if it were only a question there would be little reason for asking it.

Or suppose that I say:

I have two children,

**If I have only one child, or none, this is false. If I have three children, my statement**

<!-- page 26 -->
is true but (in most contexts) MISLEADING, because it leads a reasonable hearer to infer that I have only two. False meanings make a sentence false; false implicatures merely make it misleading.

Unlike the meaning of a sentence, the implicature can be cancelled. Consider the dialogue:

If you have at least two children you’re exempt from military service.

On what ground do you claim exemption?

I have two children.

This is both true and appropriate, in context, when spoken by a father of three.

Implicature was first studied by Grice (1975), who identified a number of MAXIMS (principles) which people follow when making statements, such as “Be relevant” and “Make the strongest statement that is true” (avoid misleading understatements; don’t say the temperature is “above freezing” if it is in fact 90°).

Another concern of pragmatics is PRESUPPOSITION. The presuppositions of a statement are the things that must be true in order for the statement to be either true or false.” For example, both The present king of France is bald and The present king of France is not bald presuppose that there is indeed a king of France. If there is no such king, these sentences are neither true nor false.

Like implicatures, presuppositions can be CANCELLED. The basic meaning of a sentence, however, cannot be cancelled. I can say The present king of France is not bald because there is no king of France, explicitly doing away with the presupposition that such a king exists. Similarly, I can say I have two children; in fact I have three, cancelling the implicature that I have only two. But if I try to cancel the basic meaning of a sentence, I contradict myself. English does not allow people to say I have two children; in fact I have only one.

Pragmatics also includes the study of DiscouRSE (the way sentences connect together to convey information). Discourse structure is especially important when computers generate natural language text. A human being might say, “The employee with the highest salary is Joe Smith, the CEO.” A computer retrieving the same information from a database might construct a boring, wordy monologue such as, “The maximum salary is the salary of Smith. The first name of Smith is Joe. The title of Smith is CEO.” Obviously this is not satisfactory. An important but largely unexplored question is how to make computers organize discourse the same way people do.

Exercise 1.4.5.1

Distinguish between the basic meaning and the implicature of each of the following utter-

ances. Show how each implicature can be cancelled.

1. Parent to child: It’s bedtime.

<!-- page 27 -->
>This is one of several rival definitions; the exact nature of presupposition is still an open question.

2. Some of the students passed the course.

3. It’s hot today—the temperature is over 90°.

**1.5 WHY USE PROLOG?**

Of all the programming languages available today, Prolog may be the most suitable for natural language processing. Here are some reasons.

e Large, complex data structures are easy to build and modify. This makes it easy

to represent syntactic and semantic structures, lexical entries, and the like.

e The program can examine and modify itself. This allows use of very abstract

programming methods.

e Prolog is designed for knowledge representation and is built around a subset of

first-order logic; extensions to this logic are relatively easy to implement.

e A search algorithm, depth-first search, is built into Prolog and is easily used in

all kinds of parsers. In fact Prolog also has a built-in, ready-to-use parser (see

Chapter 3).

e Unification (pattern matching) is built into Prolog and can be used to build data

structures step-by-step in such a way that the order of the steps does not matter.

Lisp shares only the first two of these advantages. Conventional languages such as Pascal and C lack all of them. Of course natural language processing can be done in any programming language, but some languages are much easier to use than others.

1.6 FURTHER READING

Readers who have not studied linguistics would do well to read Fromkin and Rodman (1988) or Akmajian, Demers, Farmer, and Harnish (1990) for general background. Two comprehensive handbooks are The Cambridge Encyclopedia of Language (Crystal 1987) for nonspecialists, and Linguistics: The Cambridge Survey (Newmeyer 1988) for in-depth coverage.

Newmeyer (1983, 1986) surveys modern linguistic theory. The first of these is an especially good explanation of the goals of theoretical linguistics (and, implicitly, why theoretical linguists do not produce the ready-to-use descriptions that NLP implementors want). The second traces the development of syntactic theory since 1957. For extensive (but far from complete) accounts of the syntax of English see Radford (1988) and Gazdar et al. (1985). On lexical semantics see Palmer (1981); on semantics and logic, Bach (1989); and on pragmatics, Levinson (1983).

<!-- page 28 -->
The best survey of natural language processing is Allen (1987), which uses Lisp for examples of implementation. Moyne (1985) is also useful. Smith (1991) gives an especially wide-ranging survey of computers and natural language, including not only NLP, but also text statistics, speech synthesis, and related fields. Winograd (1983) gives an accessible but thorough survey of syntax from a computational point of view; the second volume, to deal with semantics, has not yet been published. Obermeier (1989) surveys commercial applications of NLP.

**The leading NLP journal is Computational Linguistics; relevant papers also appear**

in Literary and Linguistic Computing and especially in the proceedings of the many Association for Computational Linguistics (ACL) and international COLING conferences. Articles about practical natural-language user interfaces for software often appear in the International Journal of Man-Machine Studies. Grosz et al. (1986) reprint a number of classic NLP papers, and there are many relevant articles in the Encyclopedia of Artificial Intelligence (Shapiro 1987). Gazdar et al. (1987) give a bibliography of more than 1700 NLP books and papers.

,

**On NLP in Prolog see Pereira and Shieber (1987); Gazdar and Mellish (1989, also**

available in Lisp and Pop-11 editions); and Gal et al. (1991).

'
