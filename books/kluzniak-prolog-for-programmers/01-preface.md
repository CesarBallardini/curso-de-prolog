# Preface

<!-- page 10 -->
g

Prolog is a non-conventional programming language for a wide spectrum of applications, including language processing, data base modelling and implementation, symbolic computing, expert systems, computer-aided design, simulation, software prototyping and planning. A version of Prolog has been chosen as a systems programming language for so-called ¿fth-generation computers; experiments with systems programming and concurrent programming are in progress.

Prolog, devised by Alain Colmerauer, is a logic programming language. Logic programming is a new discipline which lends a unifying view to many domains of computer science. Prolog can be classified as a descriptive programming language, as opposed to prescriptive (or imperative) languages such as Pascal, C and Ada. In-principle, the programmer is only supposed to specify what is to be done by his or her program, without bothering with how this should be achieved. Robert A. Kowalski has coined the “equation”

Algorithm = Logic + Control, which emphasizes the distinction between the what (logic) and the how (control). The programmer need not always specify the control component. In practice, however, Prolog can be treated as a procedural language.

Prolog is not standardized, and it comes in many different Àavours. The most widespread dialect of Prolog is ProIog- I0, originally implemented by David H. D. Warren for DEC-I0 computers. We describe a variant of this dialect, based on an interpreter written in Pascal especially for this book.

The main part of the book is Chapters I-5. Chapters

<!-- page 11 -->
I and are an introduction to Prolog, intended for those who use prescriptive languages in their everyday practice. Both intuitions and the presentation are “practically” biased, but we assume the reader has a certain amount of programming experience and sophistication. Chapter 2 explains Prolog in terms of logic. It requires no deep knowledge of mathematics and is intended as a counterpoint to Chapter I, but can be skipped on a ¿rst reading. Chapter 4 contains some useful programming techniques and hints. Chapter 5 is a reference manual for the version of Prolog described in this book. In addition, Chapter 8 is a discussion of two rather illuminating applications.

For those who wish to gain more insight into the language and its inner workings, Chapter 6 introduces basic principles of Prolog implementation. An implementation of the dialect described in this book is presented in Chapter 7. We used this implementation to test our examples, including the case studies of Chapter 8.

Chapter 9, written by Janusz S. Bien (who also did most of the bibliography), brieÀy outlines the most characteristic features of several other Prolog dialects.

The diskette enclosed with this book contains source text of all the programs listed in Chapter 8 and in the appendices, and of the Toy-Prolog interpreter discussed in Chapter 7. The interpreter is written in TURBO Pascal. You can use the diskette on any IBM PC compatible computer running MS-DOS 2.l0 or 3.l0.

The material in this book, supplemented by some additional reading and a programming assignment, can be used for a two-semester course at the level of third-year computer science majors. Re-implementation of or extensions to the interpreter of Chapter 7 might make interesting assignments for a translator-writing course.

While working on this book, we used the computing facilities of the Institute of Infortnatics, Warsaw University. We would like to thank Pawel Gburzynski and Krzysztof Kimbler, who helped us switch almost painlessly to a diÀ'erent machine when the one we originally used broke down for a protracted period oftime. We thank David I-I. D. Warren for permitting us to include the listings of WARPLAN. We are also grateful to all those who have provided us with logic programming literature for the past I0 years.

