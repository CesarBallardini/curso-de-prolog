# Preface

<!-- page 3 -->
When I compare the books on expert systems in my library with the production expert systems I know of, I note that there are few good books on building expert systems in Prolog. Of course, the set of actual production systems is a little small for a valid statistical sample, at least at the time and place of this writing – here in Germany, and in the first days of 1989. But there are at least some systems I have seen running in real life commercial and industrial environments, and not only at trade shows.

I can observe the most impressive one in my immediate neighborhood. It is installed in the Telephone Shop of the German Federal PTT near the Munich National Theater, and helps configure telephone systems and small PBXs for mostly private customers. It has a neat, graphical interface, and constructs and prices an individual telephone installation interactively before the very eyes of the customer.

The hidden features of the system are even more impressive. It is part of an expert system network with a distributed knowledge base that will grow to about 150 installations in every Telephone Shop throughout Germany. Each of them can be updated individually overnight via Teletex to present special offers or to adapt the selection process to the hardware supplies currently available at the local warehouses.

Another of these industrial systems supervises and controls in "soft" real time the excavators currently used in Tokyo for subway construction. It was developed on a Unix workstation and downloaded to a single board computer using a real time operating system. The production computer runs exactly the same Prolog implementation that was used for programming, too.

And there are two or three other systems that are perhaps not as showy, but do useful work for real applications, such as oil drilling in the North Sea, or estimating the risks of life insurance for one of the largest insurance companies in the world. What all these systems have in common is their implementation language: Prolog, and they run on "real life" computers like Unix workstations or minis like VAXs. Certainly this is one reason for the preference of Prolog in commercial applications.

But there is one other, probably even more important advantage: Prolog is a programmer's and software engineer's dream. It is compact, highly readable, and arguably the "most structured" language of them all. Not only has it done away with virtually all control flow statements, but even explicit variable assignment too!

These virtues are certainly reason enough to base not only systems but textbooks on this language. Dennis Merritt has done this in an admirable manner. He explains the basic principles, as well as the specialized knowledge representation and processing techniques that are indispensable for the implementation of industrial software such as those mentioned above. This is important because the foremost reason for the relative neglect of Prolog in expert system literature is probably the prejudice that "it can be used only for backward chaining rules." Nothing is farther from the truth. Its relational data base model and its underlying unification mechanism adapt easily and naturally to virtually any programming paradigm one cares to use. Merritt shows how this works using a copious variety of examples. His book will certainly be of particular value for the professional developer of industrial knowledge-based applications, as well as for the student or programmer interested in learning about or building expert systems. I am, therefore, happy to have served as his editor.

Peter H. Schnupp Munich, January 1989

*Building Expert Systems in Prolog*

