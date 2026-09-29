# Preface

<!-- page 9 -->
*Prolog: an introduction to the Ionguage*

Since 1980, world-wide interest in the fields of Artificial Intelligence, Knowledge Processing and Expert Systems has increased. The spread of ideas associated with these subjects has been furthered by the announcement of the Japanese Fifth Generation Computing initiative, the response to that in the United States, the production in the U.K. of the Alvey report on Information Technology and European responses such as the ESPRIT program. The situation now is that most of those people who are seriously involved in computing whether as academics, professional practitioners or students - have some acquaintance with the concepts associated with Expert or Knowledge Based Systems.

In order to use the ideas, it has been necessary to find new ways of communicating our requirements to computer systems. Two languages in particular have emerged as the vehicles for developing and implementing Expert Systems - Prolog and LISP.

Both languages have attracted a dedicated user group because they offer a wider range of expression to the programmer than do other established languages. I.n brief, both languages allow, in their different ways, for the symbolic representation of some parts of human knowledge and reasoning.

Although they have some common characteristics, Prolog and LISP have different histories and, at the time of writing, there is a notable contrast in the way in which the languages have been implemented. LISP is the older language by more than a decade and the original development is credited to John McCarthy. LISP has been available as ausable language since the early sixties. Being essentially a simple and 'open' language, the strength of LISP is that its structure has allowed the development of beautifully engineered programming environments, examples of these being ZETALISP from MIT and INTERLISP-D from Xerox PARCo Running on dedicated machines with micro-coding capability (for example, Symbolics, Xerox 1108, LMllambda) these environments undoubtedly represent the most sophisticated programming tools available to us.

<!-- page 10 -->
Prolog has a somewhat different history, having originated in Europe on the basis ofwork done by Alain Colmerauer and team at the University of Marseilles. Since the mid seventies much of the definitive development work on Prolog has been carried out in the U.K.

Up until a couple of years ago, LISP was regarded as the American Artificial Intelligence language and Prolog that of Europe. That situation is now changing and Prolog is gaining acceptance in the U.S.A. at the same time that powerful LISP environments are becoming extensively used in Europe.

Although there are as yet no specialised Prolog implementations that match the sophistication of the best LISP environments, it is only a matter of time before they are produced. Japan has selected Prolog as the base language for the Fifth Generation Programme and have stated that a primary objective is the development of a dedicated Prolog machine. A team at Berkeley University is currently working on the development of a similar system and there is work in that direction being carried out at Imperial College, London.

There are now a number of implementations of Prolog; some are excellent, others weak to the point of being little more than refined toys. The number of different 'dialects' means that there may be cases where examples used in this book will need to be restated to suit a different Prolog environment. The examples and test programs were constructed on the following systems, with minor changes in syntax.

The DEC-lO system running University of Edinburgh Prolog (Warren, Pereira, Byrd). The SUN-2 system running Quintus Prolog (Artificial Intelligence Ltd). The IBM PC system running Prolog-! (Expert Systems Ltd).

*About the book*

Our intention has been to produce a reference book which will allow students of the Prolog language to reach a good standard of proficiency in a fairly short period of time. As with all programming languages, there is a point at which the programmer must take over control of the learning process and build upon a basis ofunderstanding in order to obtain the results he or she wants from the language. This is particularly true of Prolog because there are few constraints upon the power of expression that the language offers. It is possible to teach someone the syntax of the language but it is not entirely possible to teach people to use it productively - that comes with experience and motivation.

Although there is a considerable amount of theory and academic knowledge which is appropriate to the advanced study of Prolog, we have made a conscious decision to exclude most ofit from this book. Much ofit is treated in*Programming* *in Prolog* (Clocksin and Mellish; Springer-Verlag), and the reader is recommended to pass on to thattext after assimilating this one.

<!-- page 11 -->
Throughout the book, we have concentrated on obtaining practical results from the use ofProlog - thus the examples used tend to illustrate how a particular process can be implemented in Prolog and the reader is then (we hope) able to adapt the technique to his or her own requirements. By the time you have fmished reading the book we very much hope that you will share our opinion that Prolog is a fascinating and delightful language to use, concealing great depth and power behind its apparent simplicity.
