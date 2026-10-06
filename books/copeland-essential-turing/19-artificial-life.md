# Artificial Life

<!-- page 516 -->
**Jack Copeland**

**1. What is ‘Artificial Life’?**

The highly interdisciplinary Weld of ArtiWcial Life was so named by Christopher Langton, a physicist working at the Los Alamos National Laboratory.1 In 1987 Langton organized at Los Alamos what he described as an ‘interdisciplinary workshop on the synthesis and simulation of living systems’.2 The workshop was a rallying point, bringing together researchers with shared interests and diverse backgrounds.

ArtiWcial Life (‘A-Life’) aims to achieve theoretical understanding of naturally occurring biological life, in particular of the most conspicuous feature of living matter, its ability to self-organize, i.e. to develop form and structure spontaneously. Langton deWnes ArtiWcial Life as ‘the study of man-made systems that exhibit behaviors characteristic of natural living systems’.3 A-Life, he says, ‘complements the traditional biological sciences concerned with the analysis of living organisms by attempting to synthesise life-like behaviors within computers and other artiWcial media’.4

The use of computers to simulate living and life-like systems is central to A-Life. Langton says:

Computers should be thought of as an important laboratory tool for the study of life, substituting for the array of incubators, culture dishes, microscopes, electrophoretic gels, pipettes, centrifuges, and other assorted wet-lab paraphernalia, one simple-to-master piece of experimental equipment.5

Langton even suggests that the ‘ultimate goal of the study of artiWcial life would be to create ‘‘life’’ in some other medium, ideally a virtual medium where the essence of life has been abstracted from the details of its implementation in any particular hardware’.6

1 C. G. Langton, ‘Studying ArtiWcial Life with Cellular Automata’, Physica D, 22 (1986), 120–49.

2 C. G. Langton (ed.), ArtiWcial Life: The Proceedings of an Interdisciplinary Workshop on the Synthesis and Simulation of Living Systems (Redwood City, Calif.: Addison-Wesley, 1989).

3 C. G. Langton, ‘ArtiWcial Life’, in Langton, ArtiWcial Life, 1.

4 Ibid.

5 Ibid. 32.

<!-- page 517 -->
6 Langton, ‘Studying ArtiWcial Life with Cellular Automata’, 147.

**2. Morphogenesis**

Turing was the earliest pioneer of computer-based A-Life: he was the Wrst to use computer simulation to investigate a theory of the development of organization and pattern in living things.7 Early in 1951, the world’s Wrst commercially manufactured general-purpose electronic digital computer, the Manchesterbuilt Ferranti Mark I, was installed in the Computing Machine Laboratory at Manchester University.8 Turing immediately set about using the machine to model biological growth. In February 1951 he wrote to a colleague at the National Physical Laboratory:

Our new machine [the Ferranti Mark I] is to start arriving on Monday. I am hoping as one of the Wrst jobs to do something about ‘chemical embryology’. In particular I think one can account for the appearance of Fibonacci numbers in connection with Wr-cones.9 In a Fibonacci number-series, each number, except for the Wrst two, is the sum of the two previous numbers: for example 1, 3, 4, 7, 11 . . .

In brief, Turing’s ‘chemical embryology’ is the hypothesis that the development of anatomical structure in the animal or plant embryo is a result of the fact that diVusing chemicals reacting with one another can form spatial patterns. This is a thoroughly reductionist view: forms found in living matter are accounted for by the fact that, under appropriate conditions, sheer chemical reaction produces pattern and form.

Turing took his cue from the zoologist D’Arcy Thompson (to whose work Turing refers at the end of Chapter 15). D’Arcy Thompson held that the forms of living things, no less than naturally occurring forms in inorganic matter, are to be explained in terms of ‘the operation of physical forces or mathematical laws’.10 Cell and tissue, shell and bone, leaf and Xower, are so many portions of matter, and it is in obedience to the laws of physics that their particles have been moved, moulded and conformed. . . . The form . . . of any portion of matter, whether it be living or dead, and

7 Another early pioneer of A-Life was the neurophysiologist W. Grey Walter (a founder of the Ratio Club, of which Turing was also a member). His famous ‘tortoises’—built from about 1949 onwards—were mobile, battery-powered devices exhibiting life-like properties. He constructed them in order to show that seemingly complex behaviour can result from simple mechanisms (W. Grey Walter, The Living Brain (London: Gerald Duckworth, 1953), 82–7 and appendix B). Although digital computers were not involved, Grey Walter’s work certainly conforms to Langton’s description given above: ‘ArtiWcial Life . . . attempt[s] to synthesise life-like behaviors within computers and other artiWcial media’ (italics added).

8 A digital facsimile of Turing’s Programmers’ Handbook for Manchester Electronic Computer (University of Manchester Computing Machine Laboratory, 1950) is in The Turing Archive for the History of Computing <www.AlanTuring.net/programmers_handbook>.

9 Letter from Turing to Michael Woodger, undated, received 12 Feb. 1951 (in the Woodger Papers, National Museum of Science and Industry, Kensington, London; a digital facsimile is in the Turing Archive for the History of Computing <www.AlanTuring.net/turing_woodger_feb51>).

<!-- page 518 -->
10 W. D’Arcy Thompson, On Growth and Form (2nd edn. Cambridge: Cambridge University Press, 1942), 3. the changes of form which are apparent in its . . . growth, may in all cases alike be described as due to the action of force.11

Concerning the puzzling fact that the scales of a Wr-cone, or the Xorets of a sunXower, are grouped together in numbers that form a Fibonacci series, D’Arcy Thompson boldly declared: while the Fibonacci series stares us in the face in the Wr-cone, it does so for mathematical reasons; and its supposed usefulness, and the hypothesis of its introduction into plantstructure through natural selection, are matters which deserve no place in the plain study of botanical phenomena.12

Turing summarized his own theory as the suggestion that ‘certain well-known physical laws are suYcient to account for many of the facts’ of morphogenesis (p. 519). (‘Morphogenesis’ means ‘generation of form’.) Turing described an idealized chemical mechanism, now called the reaction-diVusion model. He showed that this mechanism could lead to a number of simple but life-like patterns and forms. The reaction-diVusion model is the topic of Chapter 15, ‘The Chemical Basis of Morphogenesis’. ‘The Chemical Basis of Morphogenesis’ has been widely cited in the biological literature and today reaction-diVusion remains a possible, although still unconWrmed, explanation of aspects of the generation of biological pattern and form.

The geneticist C. H. Waddington commented in a letter to Turing in 1952 that the most clear-cut application of Turing’s theory appeared to be ‘in the arising of spots, streaks, and Xecks of various kinds in apparently uniform areas such as the wings of butterXies, the shells of molluscs, the skin of tigers, leopards, etc’.13 Modern computer simulations of Turing’s reaction-diVusion mechanism have indeed produced leopard-like spots, cheetah-like spots, and giraVe-like stripes, as well as textures reminiscent of reptile skin, corals, and the surfaces of some fungi.14 Turing himself, however, envisaged diverse applications of his theory (as he indicated in the letter to biologist J. Z. Young quoted below), including leaf arrangements and the appearance of Fibonacci sequences, and phenomena such as gastrulation. (Gastrulation is a process of rearrangement of cells in the spherical embryo, involving the folding inwards of part of the surface, producing a depression akin to the dent formed by poking a balloon with a Wnger.) Furthermore, Turing described his research into

11 Ibid. 10, 16.

12 Ibid. 933.

13 Letter from Waddington to Turing (11 Sept. 1952). The letter is among the Turing Papers in the Modern Archive Centre, King’s College, Cambridge (catalogue reference D 5).

<!-- page 519 -->
14 J. D. Murray, ‘A Pre-pattern Formation Mechanism for Animal Coat Markings’, Journal of Theoretical Biology, 88 (1981), 161–99; G. Turk, ‘Generating Textures on Arbitrary Surfaces Using Reaction-DiVusion’, Computer Graphics, 25 (1991), 289–98; A. Witkin and M. Kass, ‘Reaction-DiVusion Textures’, Computer Graphics, 25 (1991), 299–308. morphogenesis as ‘not altogether unconnected’ to his work on neural networks (see Chapter 10).

Turing simulated the reaction-diVusion mechanism using the Ferranti computer. A mathematician using paper and pencil to analyse the behaviour of a reaction-diVusion system risks becoming overwhelmed by formidable mathematical complexity, and must make (what Turing calls) ‘simplifying assumptions’. Turing explains that use of the computer enables such assumptions to be dispensed with to some extent. This freedom enables Turing to employ nonlinear diVerential equations to describe the chemical interactions hypothesized by his theory.15 Non-linear diVerential equations are mathematically intractable. Turing used the computer to explore in detail particular cases of interactions governed by equations of this type. He may well have been the Wrst researcher to engage in the computer-assisted exploration of non-linear systems.16 (It was not until Benoit Mandelbrot’s discovery of the ‘Mandelbrot set’ in 1979 that the computer-assisted investigation of non-linear systems gained widespead attention.17)

Turing’s work on morphogenesis was in every respect ahead of its time. He died while in the midst of this groundbreaking work, leaving a large pile of handwritten notes and various programmes.18 This material is still not fully understood.

The computer programme shown in Figure 1, which is in Turing’s own hand, formed part of his study of the development of the Wr-cone. He also investigated the development of the sunXower. The photograph and diagram shown in Figure 2 are from his notes.19

**3. The Reaction-Diffusion Model**

In reaction-diVusion, two or more chemicals diVuse through the embryo reacting with each other. Turing showed that under certain conditions a stable pattern of chemical concentrations will be reached. For example, in the case of an artiWcially simple embryo consisting of nothing but a ring of twenty cells, reactiondiVusion will produce a stable, regular pattern of concentration and rarefaction around the circumference of the ring. The points of highest concentration

15 See p. 561 of Chapter 15; also section 2 of Turing’s ‘Morphogen Theory of Phyllotaxis’, in Morphogenesis: Collected Works of A. M. Turing, ed. P. T. Saunders (Amsterdam: North-Holland, 1992).

16 Unless perhaps the computer-assisted modelling of non-linear systems was Wrst undertaken a little earlier, in secret, by members of the Los Alamos group in connection with nuclear explosions.

17 B. B. Mandelbrot, The Fractal Geometry of Nature (New York: Freeman, 1977; revised and expanded 1982, 1983). For a popular exposition see J. Gleick, Chaos: Making a New Science (London: Cardinal, 1988).

18 Some—but by no means all—of this material appears in Morphogenesis, ed. Saunders.

<!-- page 520 -->
19 The notes and programme sheets are among the Turing Papers in the Modern Archive Centre, King’s College, Cambridge (catalogue references C 25, C 27). Figure 1.

<!-- page 521 -->
occur equidistantly from one another. Turing picturesquely describes this pattern as a stationary ‘chemical wave’. His suggestion is that at the points of high concentration around the ring, the chemical acts as a trigger to stimulate growth. For example, a ring of cells might sprout leaves at these points, or tentacles, producing a structure reminiscent of Hydra (‘something like a sea-anenome but liv[ing] in fresh water and hav[ing] from about Wve to ten tentacles’ (p. 556)). Regular but non-stationary patterns of concentration—travelling waves—are also possible. Turing suggested that the movements of the tail of a spermatozoon may provide an example of these travelling waves.

It might be wondered how genes Wt into this picture. Given our current knowledge of the role played by genes in the determination of anatomical structure, is Turing’s theory archaic? Not at all. On Turing’s account, reactiondiVusion is the mechanism by which genes determine the anatomical structure of the resulting organism. The function of genes, he suggested, is catalytic. The genes are presumed to catalyse the production of appropriate chemicals, so setting reaction-diVusion in train.

Turing calls the chemicals that diVuse and react ‘morphogens’, suggesting hormones as an example. However, his aim is not to give a taxonomy of morphogens or to describe speciWc morphogens, but rather to demonstrate in the abstract that, given certain realistic assumptions about unspeciWed morphogens, reaction-diVusion will produce pattern. These assumptions include the rates at which the morphogens diVuse between the cells, the rates at which the various chemical reactions between the morphogens take place, and the ways in which these rates change (due, for example, to increases in temperature in the tissue, or increases in concentration of morphogens that act as catalysts). The initial concentrations of the morphogens must be speciWed, and the number, dimensions, and positions of the cells making up the mass of tissue through which the morphogens diVuse. This mass—the embryo—is assumed to be initially homogeneous. (Other features of the situation, such as the motions and elasticities of the cells, are ignored in order to simplify the model.)

Turing represents the reactions between morphogens purely schematically, making no assumptions concerning the actual chemical compositions of the substances involved. For example, two reactions might be speciWed like this: morphogens X and Y react to produce Z; Z and morphogen A react to produce

Figure 2. Turing’s numbering of the individual florets of a sunflower.

<!-- page 522 -->
20 Editor’s note. A blastula is a hollow sphere of cells, one cell in thickness. 2Y. The Wrst reaction therefore depletes the supply of morphogen Y, while the second tends to build up the concentration of Y.

Uniform diVusion and uniform reaction in a uniform mass of tissue can produce only uniformity, not diVerentiation and pattern. Some sort of symmetry-breaker must be thrown into the mix. As Turing put it (p. 525): There appears superWcially to be a diYculty confronting this theory of morphogenesis, or, indeed, almost any other theory of it. An embryo in its spherical blastula20 stage has spherical symmetry, or if there are any deviations from perfect symmetry, they cannot be regarded as of any particular importance, for the deviations vary greatly from embryo to embryo within a species, though the organisms developed from them are barely distinguishable. One may take it therefore that there is perfect spherical symmetry. But a system which has spherical symmetry, and whose state is changing because of chemical reactions and diVusion, will remain spherically symmetrical forever. . . . It certainly cannot result in an organism such as a horse, which is not spherically symmetrical.

Turing suggested various possible symmetry-breakers, including small disturbances caused by the presence of anatomical structures neighbouring the embryo, and purely statistical Xuctuations at the molecular level. An example of the latter is statistical Xuctuation in the number of molecules of a given morphogen passing through the wall of a cell, so producing small Xuctuations in the concentration of that morphogen within the cell. Turing’s point is that in certain circumstances, small Xuctuations such as this can bring about large eVects, just as a small nudge that under normal circumstances would have no eVect on a person’s balance could be enough to topple someone balancing on one foot.

Turing demonstrated that under appropriate conditions small departures from uniformity can indeed lead to the formation of chemical waves.

**4. Genetic Algorithms**

An important concept both in ArtiWcial Life and in ArtiWcial Intelligence is that of a genetic algorithm (GA). GAs employ methods analogous to the processes of natural evolution in order to produce successive generations of software entities that are increasingly Wt for their intended purpose. Turing anticipated the concept of a genetic algorithm in a brief passage of his ‘Intelligent Machinery’, where he described what he called a ‘genetical or evolutionary search’ (Chapter 10, p. 431; see also Chapter 11, p. 463, and the introduction to Chapter 16, p. 565). The actual term ‘genetic algorithm’ was introduced circa 1975 by John Holland and his research group at the University of Michigan.21 Holland’s work is responsible for the current intense interest in GAs. (Holland, a student of Arthur Burks, was inXuenced by von Neumann’s ideas—see below.)

<!-- page 523 -->
21 J. H. Holland, Adaptation in Natural and ArtiWcial Systems (Cambridge, Mass.: MIT Press, 1992), p. x.

Turing described an early example of a GA in connection with his chess-player in Chapter 16.

One of the Wrst GAs to be implemented (in the 1950s) formed part of the learning mechanism of Samuel’s checkers or draughts programme mentioned above in ‘ArtiWcial Intelligence’.22 Samuel’s programme used heuristics to rank moves and board positions (the programme ‘looked ahead’ as many as ten turns of play). To speed up learning, Samuel would set up two copies of the programme, Alpha and Beta, on the same computer and leave them to play game after game with each other. The learning procedure consisted in the computer making small numerical changes to Alpha’s ranking procedure, leaving Beta’s unchanged, and then comparing Alpha’s and Beta’s performance over a few games. If Alpha played worse than Beta, these changes to the ranking procedure were discarded, but if Alpha played better than Beta then Beta’s ranking procedure was replaced with Alpha’s. As in biological evolution, the Wtter survived. Over many such cycles of mutation and selection, the programme’s quality of play increased markedly.

The use of GAs is burgeoning, in AI and elsewhere. In one application a GAbased system and a witness to a crime cooperate to generate on-screen faces that become closer and closer to the recollected face of the criminal.23 In A-Life, researchers study GAs as a means of studying the process of evolution itself.

**5. John von Neumann and A-Life**

John von Neumann was another important early pioneer of ArtiWcial Life. In his 1948 Hixon Symposium, entitled ‘The General and Logical Theory of Automata’, he said:

Natural organisms are, as a rule, much more complicated and subtle, and therefore much less well understood in detail, than are artiWcial automata. Nevertheless . . . a good deal of our experiences and diYculties with our artiWcial automata can be to some extent projected on our interpretations of natural organisms.24

Arthur Burks (who edited and completed von Neumann’s posthumously published volume Theory of Self-Reproducing Automata, listed in the section of Further Reading) wrote this concerning von Neumann’s research on the problem of self-reproduction:

22 A. L. Samuel, ‘Some Studies in Machine Learning Using the Game of Checkers’, IBM Journal of Research and Development, 3 (1959), 211–29; reprinted in E. A. Feigenbaum and J. Feldman (eds.), Computers and Thought (New York: McGraw-Hill, 1963).

23 D. E. Goldberg, ‘Genetic and Evolutionary Algorithms Come of Age’, Communications of the Association for Computing Machinery, 37 (1994), 113–19.

<!-- page 524 -->
24 J. von Neumann, ‘The General and Logical Theory of Automata’, in vol. v of von Neumann’s Collected Works, ed. A. H. Taub (Oxford: Pergamon Press, 1963), 288–9. Von Neumann had the familiar natural phenomenon of self-reproduction in mind . . . but he was not trying to simulate the self-reproduction of a natural system at the levels of genetics and biochemistry. He wished to abstract from the natural self-reproduction problem its logical form.25 This passage is quoted approvingly by Langton, who italicizes the Wnal sentence and comments: This approach is the Wrst to capture the essence of ArtiWcial Life. To understand the Weld of ArtiWcial Life, one need only replace references to ‘self-reproduction’ in the above with references to any other biological phenomenon.26

Von Neumann was thinking about issues relevant to A-Life at least as early as

1946. In a letter to the cyberneticist Norbert Wiener (dated 29 November 1946), von Neumann wrote: ‘I did think a good deal about self-reproductive mechanisms. I can formulate the problem rigorously, in about the style in which Turing did it for his mechanisms.’27 There is no doubt that von Neumann’s theorizing about self-reproduction was strongly inXuenced by Turing’s discovery of the universal computing machine (or ‘universal automaton’, as von Neumann called it). Von Neumann’s colleague Herman Goldstine wrote:

von Neumann had a profound concern for automata. In particular, he always had a deep interest in Turing’s work. . . . Turing proved a most remarkable and unexpected result. . . . In essence what he showed is that any particular automaton can be described by a Wnite set of instructions, and that when this is fed to his universal automaton it in turn imitates the special one. . . . Von Neumann was enormously intrigued with these ideas, and he started in 1947 working on . . . how complex a device or construct needed to be in order to be selfreproductive.28

In his Hixon Symposium, von Neumann said:

For the question which concerns me here, that of ‘self-reproduction’ of automata, Turing’s procedure is too narrow in one respect only. His automata are purely computing machines. Their output is a piece of tape with zeros and ones on it. What is needed . . . is an automaton whose output is other automata. There is, however, no diYculty in principle in dealing with this broader concept and in deriving from it the equivalent of Turing’s result. . . . The problem of self-reproduction can . . . be stated like this: Can one build an aggregate out of . . . elements in such a manner that if it is put into a reservoir, in which there Xoat all these elements in large numbers, it will then begin to construct other aggregates, each of which will at the end turn out to be another automaton exactly like the

25 A. W. Burks (ed.), Essays on Cellular Automata (Urbana: University of Illinois Press, 1970), p. xv.

26 C. G. Langton, ‘ArtiWcial Life’, in M. A. Boden (ed.), The Philosophy of ArtiWcial Life (Oxford: Oxford University Press, 1996), 47.

27 Letter from von Neumann to Wiener, 29 Nov. 1946 (in the von Neumann Archive at the Library of Congress, Washington, DC).

<!-- page 525 -->
28 H. H. Goldstine, The Computer from Pascal to von Neumann (Princeton: Princeton University Press, 1972), 271, 274–5. original one? This is feasible, and the principle on which it can be based is closely related to Turing’s [universal automaton] outlined earlier.29

In lectures von Neumann described a ‘universal constructor’ (remarking, ‘You see, I’m coming quite close to Turing’s trick with universal automata’).30 Just as complete descriptions of Turing machines can be fed into the universal automaton in the form of programmes, complete descriptions of automata can be inserted into the universal constructor. The universal constructor Xoats in a medium—or sea—in which also Xoat, in practically unlimited supply, the components from which the universal constructor is made. Given a complete description of an automaton, the universal constructor will assemble that automaton.

If what is inserted into the universal constructor is a description I of the universal constructor itself, the constructor assembles a duplicate of itself—selfreproduction. Since the duplicate is to be an exact copy, it must contain the description I. This is done by a copying mechanism in the universal constructor and the copy of I is inserted into the oVspring.31 Thus the oVspring, too, is capable of self-reproduction. Von Neumann likened the description I to the gene, saying that the copying mechanism ‘performs the fundamental act of reproduction, the duplication of the genetic material, which is clearly the fundamental operation in the multiplication of living cells’.32 Allowing the copying mechanism to make occasional random errors aVords the possibility of random mutation in the genes of the oVspring, thus opening the door to Darwinian evolution.33

In his letter to Wiener (29 November 1946), von Neumann voiced some concerns that might equally well be raised concerning the focus of modern research in A-Life and ArtiWcial Intelligence. Von Neumann pointed out that when automata theorists choose the human nervous system as their model, they are unrealistically selecting ‘the most complicated object under the sun— literally’. Moreover, he said, there is little advantage in choosing instead simpler organisms with fewer neurons, for example, the ant: any nervous system exhibits ‘exceptional complexity’. Von Neumann suggested that automata theorists ‘turn to simpler systems’, and he recommended attention to ‘organisms of the virus or bacteriophage type’. These, he pointed out, are ‘self-reproductive and . . . are able to orient themselves in an unorganized milieu, to move towards food, to appropriate it and to use it’. He estimated that a typical bacteriophage might consist of 6 million atoms grouped into a few hundred thousand ‘mechanical elements’, saying that this represents ‘a degree of complexity which is not

29 von Neumann, ‘The General and Logical Theory of Automata’, 315.

30 J. von Neumann, Theory of Self-Reproducing Automata, ed. and completed by A. W. Burks (Urbana: University of Illinois Press, 1966), 83.

31 von Neumann ‘The General and Logical Theory of Automata’, 316–17.

32 Ibid., 317.

<!-- page 526 -->
33 Ibid. 317–18. necessarily beyond human endurance’. By following this path, he said, the ‘decisive break’ might be achieved.

**6. Letter from Turing to Young**

Shortly before the Ferranti computer arrived in 1951, Turing wrote about his work on morphogenesis in a letter to the biologist J. Z. Young. The letter connects Turing’s work on morphogenesis with his interest in neural networks (Chapter 10), and moreover to some extent explains why he did not follow up his earlier suggestion (Chapter 10, p. 428) and use the Ferranti computer to simulate his ‘unorganised machines’.

I am afraid I am very far from the stage where I feel inclined to start asking any anatomical questions [about the brain]. According to my notions of how to set about it that will not occur until quite a late stage when I have a fairly deWnite theory about how things are done.

At present I am not working on the problem at all, but on my mathematical theory of embryology. . . This is yielding to treatment, and it will so far as I can see, give satisfactory explanations of

i) Gastrulation.

ii) Polyogonally symmetrical structures, e.g., starWsh, Xowers.

iii) Leaf arrangement, in particular the way the Fibonacci series (0, 1, 1, 2, 3, 5, 8,

13, . . . ) comes to be involved.

iv) Colour patterns on animals, e.g., stripes, spots and dappling.

v) Patterns on nearly spherical structures such as some Radiolaria, but this is more

diYcult and doubtful.

I am really doing this now because it is yielding more easily to treatment. I think it is not altogether unconnected with the other problem. The brain structure has to be one which can be achieved by the genetical embryological mechanism, and I hope that this theory that I am now working on may make clearer what restrictions this really implies. What you tell me about growth of neurons under stimulation is very interesting in this connection. It suggests means by which the neurons might be made to grow so as to form a particular circuit, rather than to reach a particular place.34

**Further reading**

Boden, M. A., Mind as Machine: A History of Cognitive Science (Oxford: Oxford University

Press, 2005). —— (ed.), The Philosophy of ArtiWcial Life (Oxford: Oxford University Press, 1996).

<!-- page 527 -->
34 Letter from Turing to Young, 8 Feb. 1951 (a copy of the letter is in the Modern Archive Centre, King’s College, Cambridge (catalogue reference K 78)). Holland, J. H., ‘Genetic Algorithms’, ScientiWc American, 267 (July 1992), 44–50. Swinton, J., ‘Watching the Daisies Grow: Turing and Fibonacci Phyllotaxis’, in C. Teuscher

(ed.), Alan Turing: Life and Legacy of a Great Thinker (Berlin: Springer-Verlag, 2004). Turing, A. M., Morphogenesis: Collected Works of A. M. Turing, ed. P. T. Saunders

(Amsterdam: North-Holland, 1992). Turk, G., ‘Generating Textures on Arbitrary Surfaces Using Reaction-DiVusion’, Computer

Graphics, 25 (1991), 289–98. von Neumann, J., Theory of Self-Reproducing Automata, ed. and completed by A. W. Burks

(Urbana: University of Illinois Press, 1966).
