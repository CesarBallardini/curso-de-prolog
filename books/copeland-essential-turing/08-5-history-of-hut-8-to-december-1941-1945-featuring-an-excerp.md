# 5. History of Hut 8 to December 1941 (1945), featuring an excerpt from Turing’s ‘Treatise on the Enigma’

<!-- page 274 -->
**Patrick Mahon**

**Introduction**

Jack Copeland

Patrick Mahon (A. P. Mahon) was born on 18 April 1921, the son of C. P. Mahon, Chief Cashier of the Bank of England from 1925 to 1930 and Comptroller from 1929 to 1932. From 1934 to 1939 he attended Marlborough College before going up to Clare College, Cambridge, in October 1939 to read Modern Languages. In July 1941, having achieved a First in both German and French in the Modern Languages Part II,1 he joined the Army, serving as a private (acting lancecorporal) in the Essex Regiment for several months before being sent to Bletchley. He joined Hut 8 in October 1941, and was its head from the autumn of 1944 until the end of the war. On his release from Bletchley in early 1946 he decided not to return to Cambridge to obtain his degree but instead joined the John Lewis Partnership group of department stores. John Spedan Lewis, founder of the company, was a friend of Hut 8 veteran Hugh Alexander, who eVected the introduction. At John Lewis, where he spent his entire subsequent career, Mahon rapidly achieved promotion to director level, but his health deteriorated over a long period. He died on 13 April 1972.2

This chapter consists of approximately the first half of Mahon’s ‘The History of Hut Eight, 1939–1945’. Mahon’s typescript is dated June 1945 and was written at Hut 8. It remained secret until 1996, when a copy was released by the US government into the National Archives and Records Administration (NARA) in Washington, DC.3 Subsequently another copy was released by the British

1 With thanks to Elizabeth Stratton (Edgar Bowring Archivist at Clare College) for information.

2 This paragraph by Elizabeth Mahon.

<!-- page 275 -->
3 Document reference RG 457, Historic Cryptographic Collection, Box 1424, NR 4685. government into the Public Record OYce at Kew.4 Mahon’s ‘History’ is published here for the Wrst time.5

**Mahon’s account is Wrst-hand from October 1941. Mahon says, ‘for the early**

**history I am indebted primarily to Turing, the Wrst Head of Hut 8, and most of**

**the early information is based on conversations I have had with him’.**

4 Document reference HW 25/2.

<!-- page 276 -->
5 I have made as few editorial changes as possible. Mahon’s chapter headings have been replaced by section headings. Errors in typing have been corrected and some punctuation marks have been added. Sometimes sentences which Mahon linked by ‘and’, or a punctuation mark, have been separated by a full stop. Mahon preferred the lower-case ‘enigma’, which has been altered to ‘Enigma’ for the sake of consistency with other chapters. In Mahon’s introductory remarks ‘account’ has been substituted for ‘book’ (and the second word of that section has been changed from ‘reading’ to ‘writing’). Occasionally a word or sentence has been omitted (indicated ‘. . .’) and sometimes a word or phrase has been added (indicated ‘[]’). In every case, the omitted material consists of a reference to later parts of the ‘History’ not reproduced here.

The king hath note of all that they intend,

By interception which they dream not of.

King Henry V

**Introduction**

Before writing this history I have not had the unpleasant task of reading voluminous records and scanning innumerable documents.1 We have never been enthusiastic keepers of diaries and log books and have habitually destroyed records when their period of utility was over, and it is the merest chance that has preserved a few documents of interest; hardly any of these are dated. Since March 1943, the Weekly Report to the Director provides a valuable record of our activities, but it is naturally this more recent period which human memory most easily recalls, and it is the lack of documentary evidence about early days which is the most serious. A very large portion of this history is simply an eVort of memory conWrmed by referring to other members of the Section. I joined the Section myself in October 1941 and have fairly clear personal recollections from that time; for the early history I am indebted primarily to Turing, the Wrst Head of Hut 8, and most of the early information is based on conversations I have had with him. I also owe a considerable debt of gratitude to Mr. Birch who lent me the surviving 1939–1940 Naval Section documents which yielded several valuable pieces of information and aVorded an interesting opportunity of seeing Hut 8 as others saw us. Many past members of the Section and many people from elsewhere in B. P.2 have been kind enough to answer questions. . . .

With the exception of Turing, whose position as founder of the Section is a very special one, I have adopted the policy of not mentioning individuals by name. Attributing this or that accomplishment to an individual would be an

All footnotes are editorial; Mahon’s typescript contains none. Some footnotes are indebted to a document entitled ‘A Cryptographic Dictionary’, produced by GC & CS in 1944 (declassified in 1996; NARA document reference: RG 457, Historic Cryptographic Collection, Box 1413, NR 4559). A digital facsimile of ‘A Cryptographic

Dictionary’ is available in The Turing

Archive for

the History of Computing <www.AlanTuring.net/crypt_dic_1944>.

I am grateful to Rolf Noskwith (who worked with Mahon in Hut 8) for providing translations of signals, cribs, and German technical terms.

1 Mahon’s ‘The History of Hut Eight, 1939–1945’ is Crown copyright. This extract is published with the permission of the Public Record OYce and Elizabeth Mahon. The extract from Turing’s ‘Treatise on the Enigma’ is Crown copyright and is published with the permission of the Public Record OYce and the Estate of Alan Turing. A digital facsimile of the complete original typescript of Mahon’s ‘The History of Hut Eight, 1939–1945’ is available in The Turing Archive for the History of Computing <www.AlanTuring.net/ mahon_hut_8>.

<!-- page 277 -->
2 Editor’s note. Bletchley Park. Also B/P. invidious process contrary to the traditional attitude of the Section towards its work and it would inevitably give a misleading impression of the relative contributions of the diVerent members of the Section.

It is impossible to write a truly objective history of a Section which has been one’s principal interest in life for the last 3 1

2 years and so this account is written on a comparatively personal note—mostly in the Wrst person plural with occasionally a purely personal recollection or opinion included: to the best of my ability I have only introduced by ‘we’ opinions with which the Section as a whole would have agreed. We have always prided ourselves on not trying to conceal our failures, and on admitting where we might have done better, and I have attempted to avoid any tendency to ‘whitewash’ our eVorts for the beneWt of posterity.

This history is intended for the layman. Our work has been traditionally incomprehensible—the last distinguished visitor I remember had barely sat down before he announced that he was not a mathematician and did not expect to understand anything. (Anyone wishing to probe the more abstruse mathematical aspect of it should turn to the technical volume which is being compiled in collaboration with Hut 6.) In fact, there is nothing very diYcult to understand in the work we did, although it was confusing at Wrst sight. I have attempted to explain only the basic principles involved in the methods we used. As a result of this I hope that anyone interested in Hut 8 and willing to read the semi-technical passages with some care will get a fairly clear idea of our work and I make no excuse for having deliberately avoided mentioning many of the complications which arose—thus when describing the machine I say that after pressing the keys 26  26  26 times the machine has returned to its starting place, but the mathematician will realize that the introduction of wheels 6, 7, and 8 with 2 turnovers each is liable to split this cycle into several smaller cycles.

The account starts with a description of the machine and the methods of sending messages. [This] is followed by some information as to where the machine was used and the volume of traYc carried. After these tedious but rather necessary pages of background [the account] follows the course of events more or less chronologically, starting some time before the war. Certain subjects—like Banburismus . . . —required whole sections to themselves outside the historical narrative and these are the subjects of a series of digressions. . . .

**The Machine and the Traffic**

<!-- page 278 -->
If the history of Hut 8 is to be understood, it is essential to understand roughly how the [Enigma] machine works and thus obtain some idea of the problem which had to be tackled. Developments which have taken place during the war have complicated the problem but have left the machine fundamentally the same.

The process of cyphering is simple and quick. The message is ‘typed’ on a normal keyboard and as each letter is pressed, another letter is illuminated on a lampboard containing the 26 letters of the alphabet. The series of letters illuminated on the lampboard form the cypher text and the recipient of the cypher message, in possession of an identical machine, types out the cypher text and the decoded message appears on the lampboard.

Wheels The main scrambler unit consists of 3 (later 4) wheels and an Umkehrwalze which I shall refer to henceforth as the ReXector—an admirable American translation. These wheels have on each side 26 contacts which we will for convenience label A to Z. The contacts on the one side are wired in an arbitrary and haphazard fashion to the contacts on the other. Each wheel is, of course, wired diVerently. The reXector has 26 contacts which are wired together arbitrarily in pairs. What happens when one of the letters of the keyboard is pressed may be seen from the following diagram.

Wheel

Wheel

Wheel

A

A

H

M

Reflector

Q

N

S

P

The current in this example enters the right hand wheel at A and leaves it at M, A being wired to M in this wheel: it enters the middle wheel at M and leaves it at Q, and so on until it reaches the reXector, where it turns around and returns through the wheels in a similar fashion, eventually leaving the right hand wheel at position N and lighting the appropriate lamp in the lampboard. Pressing a key may light up any bulb except that which is the same as the key pressed—for a letter to light up itself it would be necessary for the current to return through the wheels by the same route as it entered and, from the nature of the reXector, this is clearly impossible. This inability of the machine to encypher a letter as itself is a vital factor in the breaking of Enigma. It should also be noted at this point that the machine is reciprocal, that is to say that, if at a given position of the machine N lights up A, then A will light up N.

<!-- page 279 -->
Each time a key is pressed the right-hand wheel moves on one so that if, in the position immediately following our example above, the same key is pressed, the current will enter the right-hand wheel at B and not A, and will pursue an entirely diVerent course. Once in every 26 positions, the right hand wheel moves the middle wheel over one so that when the right hand wheel returns to position A, the middle wheel is in a new position. Similarly, the middle wheel turns over the left hand wheel once for every complete revolution it makes. Thus it will be seen that 26  26  26 (about 17,000) letters have to be encyphered before the machine returns to the position at which it started.

For most of the period with which we are concerned, there have been 8 wheels. Wheels 1 to 5 turn over the wheel next to them once per revolution, wheels 6, 7, 8, twice per revolution, this somewhat complicating the cycle of the machine as described in the previous paragraph. The turnovers (by which I mean the position of the wheel at which it turns over its next door neighbour) on wheels 1 to 5 are all in diVerent places; in 6, 7, and 8 they are always at M and Z. As we shall see later, this was an important development.

Ringstellung On each wheel is a tyre, marked with the letters of the alphabet. One of these letters can be seen through a window on top of the machine and the position of the wheel is referred to by the letter shown in the window. The tyre is completely independent of the core of the wheel, which contains the wiring, the relative position being Wxed by the Ringstellung or clip which connects the tyre with the core. Thus even if the starting position of the message is known, it still cannot be decoded unless the clips, which Wx the relative position of tyre and core, are known also.

Stecker The Enigma machine would be a comparatively simple aVair if it were not for the Stecker. This is a substitution process aVecting 20 of the 26 letters before and after the current travels through the wheels. Let us return to our original example and assume for the moment that A is steckered to F and N to T. In our example we pressed key A and entered the right-hand wheel at a position we called A, but if we now press A the current will be sidetracked before entering the wheel, and will in fact enter at F and pursue a quite diVerent course. If, on the other hand, we press F, the current will enter at A and proceed as before, coming out at N. N will not, however, light up on the lampboard, but rather T, because N has been steckered to T. This steckering process aVects 20 letters; the remaining 6 are referred to as self-steckered and, when they are involved, the current proceeds directly to or from the wheels.

<!-- page 280 -->
Set-Up In order to decode a message one has, then, to know wheel order, clips, starting position of message, and Stecker. Any 3 of the 8 wheels may be chosen—336 possibilities. There are 17,000 possible clip combinations and 17,000 possible starting positions—in the 4-wheeled machine half a million. The number of possible Stecker combinations is in the region of half a billion. In fact, the number of ways the machine may be set up is astronomical, and it is out of the question to attempt to get messages out by a process of trial and error. I mention this as it is a hypothetical solution to the problem often put forward by the uninitiated, when in fact all the coolies in China could experiment for months without reading a single message. On most keys the wheel order and clips were changed every two days—this is the so-called ‘innere Einstellung’3 which was supposed to be changed only by oYcers and which was printed on a separate sheet of paper. The Stecker and Grundstellung (of which more later) normally changed every 24 hours. In a 31-day month, the odd day was coped with by having 3 days on 1 wheel order—a triplet. This sometimes came at the end of the month and sometimes in the middle. Triplets happened also in 30-day months, with the result that the last day was a ‘singleton’ with a wheel order of its own. These rules were not obeyed by all keys, but we shall meet the exceptions as we proceed with the historical survey. The later 4-wheeled keys had a choice of 2 reXectors and 2 reXector wheels; these were only changed once a month.

Indicating System The next essential is to understand the indicating system. Various indicating systems were used simultaneously, but if we examine the most complicated fairly carefully the others will be simple to explain.

[The keys] Dolphin, Plaice, Shark, Narwhal, and Sucker all built up their indicators with the help of bigram tables and K book.4

K Book One half of the K book consists of a Spaltenliste5 containing all 17,576 existing trigrams,6 divided into 733 numbered columns of 24 trigrams chosen at random. The second half consists of a Gruppenliste7 where the trigrams are sorted into alphabetical order; after each trigram are 2 numbers, the Wrst giving the number of the column in the Spaltenliste in which the trigram occurs, the second giving the position of the trigram in the column.

By means of a Zuteilungsliste8 the columns of the K book are divided amongst the various keys, the large keys being given several blocks of columns, small keys as few as 10. The K book is a large document which has probably changed only once—the current edition having come into force in 1941—but the Zuteilungsliste was changed fairly frequently.

3 Editor’s note. Innere Einstellung ¼ inner settings.

4 Editor’s note. K book ¼ Kenngruppenbuch or Kennbuch ¼ Identification Group Book. ‘Group’ refers to groups of letters.

5 Editor’s note. Spaltenliste ¼ column list.

6 Editor’s note. A trigram is any trio of letters, e.g. ABC, XYZ.

7 Editor’s note. Gruppenliste ¼ group list.

<!-- page 281 -->
8 Editor’s note. Zuteilungsliste ¼ assignation list. Bigram Tables A set of bigram tables consisted of 9 tables, each giving a series of equivalents for the 676 existing bigrams. These tables were reciprocal, i.e. if AN¼OD then OD¼AN, a useful property as we shall see later. Which bigram table was in force on any given day was determined by means of a calendar which was issued with the tables. New sets of bigram tables were introduced in June 1941, November 1941, March 1943, July 1944.

Now that we are familiar with all the necessary documents—key sheets, K book, bigram tables, etc.—it will be proWtable to follow in detail the steps taken by a German operator wishing to send a message.

He is on board a U-boat and has Shark keys and, after consulting his Zuteilungsliste, goes to columns 272–81, which have been allotted to Shark. Here he selects the trigram HNH to serve as his Schluesselkenngruppe.9 He then selects from anywhere in the book another trigram (PGB) and writes them down like this:

. H N H

P G B . He then Wlls in the 2 blanks with dummy letters of his own choice:

Q H N H

P G B L

Taking the bigram table which is in force at the time, [he] substitutes for each vertical pair of letters QP, HG, etc.:

I D Y B

N S O I

The indicator groups of his message will then be IDYB NSOI.

The trigram which he chose at random (Verfahrenkenngruppe10) now provides him with the starting position of his message. To obtain this he sets up the Grundstellung in the window of his machine and taps out PGB. The three encyphered letters which result are the set-up for his message.

The Wrst step in decyphering the message is, of course, to decypher the indicator groups by means of the bigram tables. At this stage the Schluesselkenngruppe can be looked up in the K book, and it can then be established by each station whether the message is on a key which it possesses. The Grundstellung is then set up, the trigram tapped out, and the message decoded.

Some form of Grundstellung procedure was common to all keys, but there were a number of keys not using bigram tables and K book. In the Mediterranean

9 Editor’s note. Schluesselkenngruppe ¼ key identification group.

<!-- page 282 -->
10 Editor’s note. Verfahrenkenngruppe ¼ procedure identification group. area Kenngruppenverfahren Sued11 was used and discrimination between keys was dependent on the Wrst letters of the Wrst and second groups—the resulting bigram indicating the key. In this case, the operator chose any trigram he wished and encyphered it twice at the Grundstellung and the resulting 6 letters formed the last three letters of the Wrst 2 groups. . . . Of the other keys, Bonito and Bounce relied for recognition on the fact that in external appearance their traYc was unlike any other and so used no discriminating procedure, simply sending as indicators a trigram encyphered at the Grundstellung and Wlling the groups up with dummy letters as required.

This machine was in general use by the German Navy in all parts of the world; it was used alike for communication between ship and shore and shore and shore and by all vessels from mine sweepers and MTBs up to U-boats and major units.

Traffic The history of Hut 8 is conditioned very largely by the rapid growth of the German Naval communications system and the resulting increases of traYc and increasing number of keys. . . . It is not necessary to go into details here, but a few Wgures will illustrate very clearly that the gradual contraction of German occupied territory in no way signiWed a decrease of traYc and a simpliWcation of the problem. Our traYc Wgures do not go back to 1940 but the following are the daily averages of messages for March 1941–5:

1941

465

1942

458

1943

981

1944

1,560

1945

1,790 The largest number of messages ever registered in Hut 8 on one day was on March 13, 1945, when 2,133 were registered.

As a general rule German Naval traYc was sent out in 4 letter groups with the indicator groups at the beginning and repeated at the end. Both from the German and our own point of view this made Naval traYc easily recognizable, and gave a check on the correct interception of the indicator groups. Messages were normally broadcast on Wxed frequencies which changed comparatively rarely, so that it was possible for the cryptographer without W/T12 knowledge to keep the diVerent frequencies and the areas to which they belonged in his head. The principal exception to this was the U-boats, which used a complicated W/T programme, but from our point of view identiWcation of services was made easy by the use of an independent set of serial numbers for each service. We

11 Editor’s note. Kenngruppenverfahren Sued ¼ identification group procedure South.

<!-- page 283 -->
12 Editor’s note. W/T ¼ wireless telegraphy. R/T or radio-telephony involves the transmission of speech, W/T the transmission of e.g. Morse code or Baudot-Murray (teleprinter) code. should have had some diYculty also with the Mediterranean area if the intercept stations had not given a group letter to each W/T service and appended it to the frequency when teleprinting the traYc.

Except for a short period in the early days of Bonito, Wxed call signs were always used, though it was unfortunately by no means always possible to tell fromwhom a messageoriginated.‘Addressee’callsigns—averygreathelptothecryptographer— were little used except in the Mediterraneanwhere, if we were fortunate, it might be possible to tell both the originator and the destination of a message. Like the Mediterranean keys, Bonito gave a lot away by its call signs, but other keys stuck to the old procedure. The only exception of any note to this rule was the emergency W/T links which replaced teleprinter communications if the latter broke down.

From early days Scarborough was our chief intercept station and was responsible for picking up most of the traYc. Other stations were brought in if interception at Scarborough was unsatisfactory, as was often the case in the Mediterranean and North Norwegian areas. For a considerable time North Norwegian traYc was being sent back from Murmansk, while the W/T station at Alexandria played an important part in covering many Mediterranean frequencies. The principal disadvantage of traYc from distant intercept stations was the length of time it took to reach us. TraYc came from Alexandria by cable and an average delay of 6 hours between time of interception and time of receipt at B/P was considered good.

Unlike Hut 6 we never controlled the disposition of the various receiving sets at our disposal but made our requests, which were considerable, through Naval Section. As I do not ever recollect an urgent request having been refused, this system worked very satisfactorily from our point of view.

The reason for our numerous demands for double, treble, and even quadruple banking13 of certain frequencies was that, for cryptographic reasons which I will explain later, it was absolutely essential to have a 100% accurate text of any message that might be used for crib purposes. In our experience it was most unwise to believe in the accuracy of single text, even if it was transmitted with Q.S.A. 5,14 and so we asked automatically for double banking on frequencies likely to be used for cribbing. Especially on the Mediterranean keys and Bonito, interception was extremely unreliable and quadruple banking on crib frequencies was often necessary. On Bonito the assistance of R.S.S.,15 who did not normally work on Naval traYc, was enlisted, and for some Bounce traYc originating from weak transmitters in Northern Italy, we relied on R.A.F. stations in Italy.

13 Editor’s note. Where two independent operators are assigned to monitor the same radio frequency, the frequency is described as ‘double-banked’.

14 Editor’s note. In International Q-Code (radio operators’ code) the strength of the received signal is represented on a scale of 1 to 5. ‘Q.S.A. 5’ means ‘signal strength excellent’. (I am grateful to Stephen Blunt for this information.)

<!-- page 284 -->
15 Editor’s note. Radio Security Service: a branch of the SIS (Secret Intelligence Service) which intercepted Enigma and other enciphered traYc.

Requests for double banking for cryptographic reasons became extremely numerous by the end of the war. In 1941, with only one key, special cover on a small group of frequencies was suYcient, but by late 1944 we were normally breaking some 9 or 10 keys, for each of which special cover on some frequencies was required. On the whole the policy was to ask for double banking if it was at all likely that it might be useful and accept the fact that a certain amount of unnecessary work was being done by intercept stations. There were at any rate suYcient hazards involved in breaking keys and it was felt that it would be foolhardy policy to take risks in the matter of interception when these could be obviated by double banking.

Most traYc arrived from the intercept stations by teleprinter, being duplicated by carbon. Retransmissions, dupes as we called them, were also teleprinted in full after 1942; before this, German preamble and diVering groups only of dupes had been teleprinted, but we found that we were unable to rely on the intercept stations to notice all diVerences.

Shortage of teleprinters was a perennial problem, as the traYc constantly increased while those responsible for teleprinters persisted in believing that it would decrease. The eVect of this shortage was that traYc got delayed at Scarborough for considerable lengths of time before teleprinting and was not in fact cleared until there was a lull in the traYc. It was usually true that there were suYcient teleprinters to cope over a period of 24 hours with the traYc sent in that period, but they were quite insuYcient for the rush hours on the evening and early night shift. In the spring of 1944 the teleprinter situation was reviewed and considerably improved, in anticipation of the Second Front and possible heavy increases of traYc. Experiments were carried out with a priority teleprinting system for certain frequencies but the list tended to be so large (having to cover cryptographic and intelligence needs) and so Xuid that it aVorded no more than a theoretical solution to the problem. It was our experience that it was possible to ‘rush’ very small groups of traYc at very high speed—some very remarkable results were achieved with the frequency which carried Flying Bomb information—but that rushing a large quantity was comparatively ineVective.

<!-- page 285 -->
As a result of the increased number of teleprinters, the average time elapsing between interception and teleprinting was reduced to about 30 minutes, which was thought to be satisfactory. For the opening of the Second Front a small W/T station was opened at B/P, most appropriately in the old Hut 8. This covered certain frequencies of special operational urgency or crib importance and produced very satisfactory results. A new record was established when a signal reached Admiralty in translation 12 minutes after being intercepted here. As the excitement over the success of the Second Front died down and the sense of urgency disappeared, the time lag became somewhat worse, but the situation remained under control, with one or two brief exceptions, even during the Wnal peak period in March 1945.

As was to be expected, stations other than Scarborough which had less interest in Naval traYc and less facilities for teleprinting were appreciably slower in passing us the traYc; a time check late in 1944 revealed an average delay of 103 minutes at Flowerdown. It should perhaps also be gratefully recorded that Scarborough’s standard of teleprinting, accuracy, and neatness remained right through the war a model which other stations were far from rivalling.

In early days traYc was teleprinted to the Main Building whence it was carried every half hour, later every ¼ hour, to the old Hut 8 Registration Room. This was inevitably a slow process, but it mattered comparatively little as in those days keys were not often being read currently. The move into Block D (February 1943) and the introduction of conveyor belts greatly improved the situation and traYc now came to the teleprinter room a few yards away whence it was conveyed to the Registration Room by belt.

Once a message had arrived in Hut 8, a considerable number of things had to be done before it could arrive decoded in Naval Section. The Registration Room had to sort the traYc—partly by frequency and partly with the help of the K book—into the various keys and, if the key in question was current, the message was then handed to the Decoding Room. For a long time decoded traYc was carried to Naval Section, a considerable walk either from the old or the new Hut 8; this wasteful method of conveyance was only superseded when the pneumatic tube system was introduced some time after we arrived in Block D.

These tubes were violently opposed on various grounds at Wrst but, when the permanent two-way tube system had been introduced, they carried a terriWc load and much toing and froing between Naval Section and ourselves was cut out. There were undoubted disadvantages in having to screw the messages up to put them into the containers but there can be no doubt that they saved us both time and trouble and that messages reached Naval Section much more quickly than before. A conveyor belt would certainly have been more satisfactory but, given the distance separating us from Naval Section (A15), was presumably out of the question.

<!-- page 286 -->
The time taken for decodeable traYc to pass through the Section varied appreciably with the degree of excitement caused by the war news. In early Second Front days some messages were arriving in Naval Section 20 minutes after being intercepted, but speeds of this sort could not be kept up indeWnitely. The introduction of time stamping with the help of Stromberg time-clocks enabled us to make a regular check of the time it took for traYc to pass through the Hut and we were normally able to keep the average in the region of half an hour. This reXects, I think, great credit on all concerned as the work was tiring and, especially in the Decoding Room, noisy, and at peak periods everyone had to work very fast indeed. In the week ending March 16th 1945, the record total of 19,902 messages were decoded, a remarkable feat for an average of perhaps 10 typists per shift.

This introduction has, I hope, supplied the necessary background on how the machine works and on how the traYc was received and dealt with. We can now turn to a more interesting subject and examine the history of the breaking of Enigma from the earliest days.

**Early work on Enigma**

Nearly all the early work on German Naval Enigma was done by Polish cryptographers, who handed over the details of their very considerable achievements just before the outbreak of war. Most of the information I have collected about prewar days comes from them through Turing, who joined G.C.C.S. in 1939 and began to interest himself in Naval cyphers, which so far had received scant attention.

The Heimsoeth & Rinke16 machine which was in use throughout the war and which I described [earlier] was not the Wrst machine to be used by the German Navy. In the 1920s, the so-called O Bar machine had been in use. This had 3 wheels and no Stecker, and the curious characteristic of 29 keys—the modiWed vowels O, U, and A being included. Of these 29 symbols, X always encyphered as X without the current entering the machine, and the remaining 28 letters were encyphered in the normal way. The tyres of the wheels necessarily had 28 letters printed on them and it was decided that the letter which had been omitted was the modiWed O: hence the name of the machine, which was broken by the Poles and the traYc read.

The O Bar machine went out of force for Xeet units in 1931, when the present machine was introduced, and gradually disappeared altogether. The new machine had originally been sold commercially by the Swedes: as sold by them it had no Stecker and it was they who recommended the boxing indicator system17 which enabled so many Navy cyphers to be read.

When the German Navy Wrst started to use the machine there were only 3 wheels in existence instead of the later 8 and only 6 Stecker were used. The

16 Editor’s note. The Heimsoeth & Rinke company manufactured Enigma machines following Scherbius’ death. See F. L. Bauer, Decrypted Secrets: Methods and Maxims of Cryptology (2nd edn. Berlin: Springer- Verlag, 2000), 107.

<!-- page 287 -->
17 Editor’s note. The ‘boxing’ or ‘throw-on’ indicator system was an earlier and much less secure method. K book and bigram tables were not used. Mahon explains the system later in his ‘History’ (on p. 56, which is not printed here): ‘By this system a trigram of the operator’s own choosing was encyphered twice at the Grundstellung and the resulting 6 letters became letters 2, 3, 4, 6, 7, 8, of the indicator groups.’ Letters 1 and 5 were either dummies or, in Mediterranean traYc, identified which particular key was being used in accordance with Kenngruppenverfahren Sued. (See p. 273 and also H. Alexander, ‘Cryptographic History of Work on the German Naval Enigma’ (n.d. (c.1945), Public Record OYce (document reference HW 25/1), 8–9; a digital facsimile of Alexander’s typescript is available in The Turing Archive for the History of Computing <www.AlanTuring.net/alexander_naval_enigma>). reXector in force was reXector A and boxing or throw-on indicators were used. . . .

Having obtained photographs of the keys for 3 months, during which period the wheel order obligingly remained unchanged, the Poles broke the wiring of wheels 1, 2, and 3 by a ‘Saga’, a long and complicated hand process which I shall not attempt to explain. Having obtained all the details of the machine, they were able to read the traYc more or less currently with the help of the indicating system and catalogues of ‘box shapes’.18 These catalogues listed positions of the machine

which

would

satisfy

certain

conditions

which

were

implied by the indicator groups, and from them the machine set-up for the day could be worked out.

On May 1st 1937 a new indicating system was introduced. The Wrst 2 groups of the message were repeated at the end, thus showing clearly that they formed the indicator, but it was immediately apparent that throwing-on had been given up. This was a sad blow, but the Poles succeeded in breaking May 8th and they discovered the Grundstellung with the help of messages to and from a torpedo boat with call-sign ‘AFA¨’, which had not got the instructions for the new indicating system. On breaking May 8th, the Poles discovered that it had the same wheel order as April 30th, and the intervening days were soon broken. AFA¨’s lack of instructions and the continuation of the wheel order are typical examples of good fortune such as we have often experienced, and also of the German failure to appreciate that for a cypher innovation to be successful it must be absolutely complete.

May 8th and the preceding days could not, of course, be broken with the catalogue of box shapes, as the indicating system had changed, and for them the Poles devised a new method which is of considerable interest. Their account of this system, written in stilted German, still exists and makes amusing reading for anyone who has dealt with machines. The process was fundamentally a form of cribbing, the earliest known form. On the basis of external evidence, one message was assumed to be a continuation (a fort) of another—apparently identiWcation was easy and forts numerous in those days. The second message was then assume to start fort followed by the time of origin of the Wrst message, repeated twice between Ys. German security must have been non-existent in those days, as these cribs appear to have been good and the Poles quote an example which, by its pronounceability, gave its name to the method of attack they had evolved—fortyweepyyweepy ¼ continuation of message 2330,

<!-- page 288 -->
18 Editor’s note. Alexander (ibid. 17–18) gives the following explanation. With the boxing indicator system, ‘the letters of the encyphered indicators can be associated together so as to produce various patterns—known as ‘‘box shapes’’—independent of the stecker and determined only by the wheel order and Grundstellung at which the indicators are encyphered. With only 6 possible wheel orders catalogues could be made of all possible box shapes with the machine positions at which they occurred and thus the daily key could be worked out.’ numerals at this time being read oV the top row of the keyboard and inserted between Ys.19 I will not attempt to explain the details of the method: it involved a series of assumptions to the eVect that certain pairs of letters were both selfsteckered. If the assumption was correct, the method worked. At this time, it will be remembered, 14 of the 26 letters were still unsteckered so that the assumption was not a very rash one and also the number of wheel orders was very small.

Even when they had found the Grundstellung with the help of the AFA¨ messages, the Poles still could not read the traYc as they did not know how the indicating system worked. They set to work, therefore, to break individual messages on cribs—largely of the forty weepy type—not a very diYcult process when Stecker and wheels are known. By this method they broke out about 15 messages a day and came to the conclusion that the indicating system involved a bigram substitution, but they got little further than this.

All witnesses agree that Naval Enigma was generally considered in 1939 to be unbreakable; indeed pessimism about cryptographic prospects in all Welds appears to have been fairly prevalent. This attitude is constantly referred to in such letters of the period as still survive; Mr. Birch records that he was told when war broke out that ‘all German codes were unbreakable. I was told it wasn’t worth while putting pundits onto them’ (letter to Commander Travis, August 1940) and, writing to Commander Denniston in December of the same year, he expresses the view that ‘Defeatism at the beginning of the war, to my mind, played a large part in delaying the breaking of codes.’20 When Turing joined the organization in 1939 no work was being done on Naval Enigma and he himself became interested in it ‘because no one else was doing anything about it and I could have it to myself’. Machine cryptographers were on the whole working on the Army and Air Force cyphers with which considerable success had been obtained.

Turing started work where the Poles had given up; he set out to discover from the traYc of May 1937 how the new indicating system worked. ‘Prof’s Book’, the write-up he made in 1940 of the work he had done and of the theory of Banburismus, describes the successful conclusion of this work.

**Excerpt from Turing’s Treatise on the Enigma**

[T]he Poles found the keys for the 8th of May 1937, and as they found that the wheel order and the turnovers were the same as for the end of April they rightly assumed that the wheel order and Ringstellung had remained the same during the end of April and the beginning of May. This made it easier for them to Wnd the keys for other days at the beginning of May and they actually found the

19 Editor’s note. The top line of the German keyboard is qwertzuio. Q was used for 1, W for 2, E for three, and so on. The time of origin of the original message, 23.30, becomes weep, 0 being represented by P, the first key of the bottom line of the keyboard. (See ibid. 18.)

<!-- page 289 -->
20 Editor’s note. Edward Travis was Denniston’s deputy. Stecker for the 2nd, 3rd, 4th, 5th, and 8th, and read about 100 messages. The indicators and window positions of four (selected) messages for the 5th were

Indicator

Window start

K

F

J

X

E W T W

P

C

V

S

Y

L

G

E W U

F

B

Z

V

J

M H O

U

V

Q G

M

E

M

J

M F

E

F

E

V

C

M

Y

K

The repetition of the EW combined with the repetition of V suggests that the Wfth and sixth letters describe the third letter of the window position, and similarly one is led to believe that the Wrst two letters of the indicator represent the Wrst letter of the window position, and that the third and fourth represent the second. Presumably this eVect is somehow produced by means of a table of bigramme equivalents of letters, but it cannot be done simply by replacing the letters of the window position with one of their bigramme equivalents, and then putting in a dummy bigramme, for in this case the window position corresponding to JMFE FEVC would have to be say MYY instead of MYK. Probably some encipherment is involved somewhere. The two most natural alternatives are i) The letters of the window position are replaced by some bigramme equivalents and then the whole enciphered at some ‘Grundstellung’, or ii) The window position is enciphered at the Grundstellung, and the resulting letters replaced by bigramme equivalents. The second of these alternatives was made far more probable by the following indicators occurring on the 2nd May

E X D P

I V

J

O

V C

P

X X E X

J X

J

Y

V U

E

R C X X

J L W A

N U M With this second alternative we can deduce from the Wrst two indicators that the bigrammes EX and XX have the same value, and this is conWrmed from the second and third, where XX and EX occur in the second position instead of the Wrst.

<!-- page 290 -->
It so happened that the change of indicating system had not been very well made, and a certain torpedo boat, with the call sign AFA¨, had not been provided with the bigramme tables. This boat sent a message in another cipher explaining this on the 1st May, and it was arranged that traYc with AFA¨ was to take [place] according to the old system until May 4, when the bigramme tables would be supplied. SuYcient traYc passed on May 2, 3 to and from AFA¨ for the Grundstellung used to be found, the Stecker having already been found from the fortyweepy messages. It was natural to assume that the Grundstellung used by AFA¨ was the Grundstellung to be used with the correct method of indication, and as soon as we noticed the two indicators mentioned above we tried this out and found it to be the case.

There actually turned out to be some more complications. There were two Grundstellungen at least instead of one. One of them was called the Allgemeine and the other the OYziere Grundstellung. This made it extremely diYcult to Wnd either Grundstellung. The Poles pointed out another possibility, viz that the trigrammes were still probably not chosen at random. They suggested that probably the window positions enciphered at the Grundstellung, rather than the window positions themselves, were taken oV the restricted list.

In Nov. 1939 a prisoner told us that the German Navy had now given up writing numbers with Y. . . YY. . . Y and that the digits of the numbers were spelt out in full. When we heard this we examined the messages toward the end of 1937 which were expected to be continuations and wrote the expected beginnings under them. The proportion of ‘crashes’ i.e. of letters apparently left unaltered by encipherment, then shews how nearly correct our guesses were. Assuming that the change mentioned by the prisoner had already taken place we found that about 70% of these cribs must have been right.

[End of Excerpt]

[Turing’s] theory was further conWrmed when the Grundstellung which AFA¨ had been using was discovered to encypher these trigrams in such a way that the Vs and Us all came out as the same letter. Turing had in fact solved the essential part of the indicator problem and that same night he conceived the idea of Banburismus ‘though I was not sure that it would work in practice, and was not in fact sure until some days had actually broken’.

As Banburismus was the fundamental process which Hut 8 performed for the next 2 or 3 years, it is essential to understand roughly the principle on which it works.

**Banburismus**

Banburismus is not possible unless you have the bigram tables.

<!-- page 291 -->
The idea behind Banburismus is based on the fact that if two rows of letters of the alphabet, selected at random, are placed on top of each other, the repeat rate between them will be 1 in 26, while if two stretches of German Naval plain language are compared in the same way the repeat rate will be 1 in 17. Cypher texts of Enigma signals are in eVect a selection of random letters and if compared in this way the repeat rate will be 1 in 26 but if, by any chance, both cypher texts were encyphered at the same position of the machine and [are] then written level under each other, the repeat rate will be 1 in 17—because, wherever there was a plain language repeat, there will be a cypher repeat also. Two messages thus aligned are said to be set in depth: their correct relative position has been found. If by any chance the two messages have identical content for 4 or 6 or 8 or more letters then the cypher texts will be the same for the number of letters concerned—such a coincidence between cypher texts is known as a ‘Wt’. Banburismus aims Wrst of all at setting messages in depth with the help of Wts and of a repeat rate much higher than the random expectation.

Long before the day is broken, a certain amount can be done to the indicators of the messages. The bigram substitution can be performed and the trigrams obtained: these trigrams, when encyphered or ‘transposed’ at the Grundstellung, will give us the starting positions of the messages. Once the day has been broken, the Grundstellung alphabets, i.e. the eVect of encyphering each of the 26 letters of the alphabet at positions one, two, and three of the trigrams, can be produced. The alphabets will look something like this:

A B C D E F G H I

J K L M N O P Q R

S T U V W X Y Z

1.

T V X M U I W N F L P

J

D H Y K Z S

R A E B G C O Q 2.

E Y K W A Q X R T U C N S

L V Z F H M I

J O D G B P 3.

J G D C

F E

B

P Z A V Q W O N H L T U R S K M Y X

I The aim of Banburismus is to obtain, with the help of the trigrams and Wts between messages, alphabets 2 and 3, the middle and right hand wheel alphabets.

The chance a priori of 2 messages with completely diVerent trigrams ZLE and OUX being correctly set in depth is 1 in 17,000, but if the trigrams are NPE and NLO, the factor against them being in depth is only 1 in 676 as, although we do not know the transposed value of the trigrams, N will in each case transpose to the same letter, and therefore both messages were encyphered with the left hand wheel in the same position. These messages are said to be ‘at 676’. Messages with such trigrams as PDP and PDB are said to be ‘at 26’: they are known to have had starting positions close together on the machine. On our alphabets:

PDP ¼ KWH

PDB ¼ KWG therefore PDB started one place earlier than PDP. This is expressed as B þ 1 ¼ P: in the right hand wheel alphabet, P will be seen one place ahead of B.

The Wrst stage in attacking a day by Banburismus is to discover the Wts. This was done largely by Freeborn who sorted all messages against all other messages and listed Wts of 4 letters or more.21 At the same time messages were punched by hand onto Banburies, long strips of paper with alphabets printed vertically, so that any 2 messages could be compared together and the number of repeats be recorded by counting the number of holes showing through both Banburies.22 A scoring

21 Editor’s note. Freeborn’s department, known as the ‘Freebornery’, used Hollerith equipment to sort and analyse cipher material. ‘Freeborn’ was commonly used as an adjective, e.g. attached to ‘catalogue’. ‘Freeborn, a[dj]: Performed, produced, or obtained by means of the (Hollerith) electrical calculating, sorting, collating, reproducing, and tabulating machines in Mr. Freeborn’s department’ (Cryptographic Dictionary, 39).

<!-- page 292 -->
22 Editor’s note. The name arose because the printed strips of paper were produced in the nearby town of Banbury. system by ‘decibans’ recorded the value of Wts.23 All messages at 26 were compared with 25 positions to the right and left of the level position and the scores recorded.

The completion of a Banburismus can best be explained bya simple example, the type of Banburismus that would take the expert 10 minutes rather than many hours or even days of work. This is our list of Wts. Note 3.7 ¼ 3 alphabets þ 7 letters.

ODDS

B B C

þ

.2

¼

B B E

hexagram

certain

E N F

þ

3.7

¼

E P Q

pentagram

17:1 on

R WC

þ

.13

¼

R W L

tetragram

4:1 on

P N X

þ

.5

¼

P I C

enneagram

certain

QQ G

þ

2.7

¼

Q D U

pentagram

evens

I U S

þ

3.3

¼

I U Y

hexagram

20:1 on

Z D R

þ

5.5

¼

Z I X

hexagram

15:1 on

S W I

þ

4.3

¼

S U D

tetragram

4:1 on

P P D

þ

.16

¼

P P U

tetragram

2:1 against

The Wts of better than even chance concern the letters of the right hand wheel.

C—E

F—Q

C—L

X—C

S—Y

R—X One chain X R C L E can be expressed in this form:

R . . . . X . . . . C . E . . . . . . . . . . L We know that those letters must appear in those relative positions in the right hand wheel alphabet. We now ‘scritch’ the 26 possible positions (R under A, then under B etc.) and cross out those which imply contradictions: the Wrst position, with the reciprocals (R ¼ A, etc) written in and ringed, looks like this.24

A B C D E

F G H

I

J

K

L M N O P Q R

S

T U V W X Y

Z R

.

.

.

.

.

.

.

.

.

.

.

.

.

.

.

.

.

K

M X

C X

E

A

L

F Here there is the contradiction that L appears under X, but X which is on our chain also is under F, giving two values for one letter. Similar reasons reject most other positions. Those left in are:

23 Editor’s note. ‘Ban: Fundamental scoring unit for the odds on, or probability factor of, one of a series of hypotheses which, in order that multiplication may be replaced by addition, are expressed in logarithms. One ban thus represents an odds of 10 to 1 in favour, and as this is too large a unit for most practical purposes decibans and centibans are normally employed instead’ (Cryptographic Dictionary, 4).

<!-- page 293 -->
24 Editor’s note. ‘Scritch: To test (a hypothesis or possible solution) by examining its implications in conjunction with each of a set of (usually 26) further assumptions in turn, eliminating those cases which yield contradictions and scoring the others’ (Cryptographic Dictionary, 72).

A B C D E

F G H I

J K L M N O P Q R

S T U V W X Y Z

1. L

N R

P

X

A

C

E

D

I

2.

S

U L

R

F

X

I

C

E

N

3.

T

V

L

R

G

X

J

C

E

O

4.

U

W

L

R H

X

K

C

E

P

5.

E Z

B

M L

R

P

X

U

C

6.

D C

F

E

Q

L

T

R

Y X

7. X

F

H C

E

S

V L

R

A

8.

X G

I

C

E

T

W

L

R

B

9.

I

X K

C

E V

Y

L

D R Of these, 2 contradicts the S þ 3 ¼ Y Wt, 1 and 9 contradict the good tetra I þ 3 ¼ D: they are, therefore, unlikely to be right. 6, however, is extremely interesting.

We scritched L R X C E and got the position:

A B C D E F G H I J K L M N O P Q R S T U V W X Y Z

D C F E

Q

L T

R

Y X In this alphabet F þ 7 ¼ Q and we have a good Wt at this distance which was not used in our scritching. We have in fact ‘picked up’ this extra Wt and thereby obtained a considerable factor in favour of this alphabet. We now Wt in S in such a position that S þ 3 ¼ Y in accordance with our hexagram:

8

8

7

7

6

2

4

6

1

3

5

A B C D E F G H I J K L M N O P Q R S T U V W X Y Z

D C F

E

Q

L T U R S

Y X This makes S equal U and we notice at once that we pick up the tetragram D þ 16 ¼ U, not a very good tetra but valuable as a further contribution.

We now have to see for which wheels this alphabet is valid. The turnovers on the wheels are in the positions marked on the alphabet above. From the Wt RWC þ 13 ¼ RWL we know there is no turnover between C and L; if there were a turnover, the position of the middle wheel would have changed, but both trigrams have W in the middle. This Wt knocks out wheels 4, 6, 7, and 8. BBC þ 2 ¼ BBE knocks out wheel 2. Further, we have the Wt PNX þ 5 ¼ PIC: as the two trigrams have diVerent letters in the middle, there must be a turnover between X and C. The wheel must therefore be 5, 6, 7, or 8; 6, 7, and 8 are already denied by C þ 13 ¼ L, so the wheel is 5.

<!-- page 294 -->
The next stage is to count up the score for the alphabet, assuming it to be correct. For instance, if there are two messages BDL and BDS, the score for BDL þ 4 ¼ BDS will be recorded and should be better than random if the alphabet is right. The Wnal score should be a handsome plus total. An attempt, usually not diYcult, is then made to complete the alphabet with the help of any further Wts or good scores which may exist. It will be noticed that the Wt QQG þ 2.7 ¼ QDU is contradicted: it had, however, only an even chance of being right and we do not let this worry us unduly.

A similar process Wnds the alphabet for the middle wheel and suYcient material is then available to break the day on the bombe. The number of wheel orders which have to be run will probably have been reduced from 276 to something between 3 and 90.

This example shows clearly the fallacy of the system of having all the wheels turning over in diVerent places. It was this characteristic alone which made it possible to distinguish the wheels by Banburismus and reduce the number of wheel orders to be tried. Wheels 6, 7, and 8 were indistinguishable from one another and a great nuisance to the Banburist.

Like depth cribbing, which was closely allied to it and which will be described in due course, Banburismus was a delightful intellectual game. It was eventually killed in 1943 by the rapidly increasing number of bombes, which made it unnecessary to spend much time and labour in reducing the number of wheel orders to be run: it was simpler and quicker to run all wheel orders.

**January 1940 to July 1941**

Turing’s solution of the indicating system came at the end of 1939 but it was well over a year before Banburismus was established as a practical proposition and used as a successful method of attack. The reason for this was primarily a lack of bigram tables.

The next interesting development was the interrogation of Funkmaat25 Meyer, who revealed valuable information about Short Signals and also the fact that the German Navy now spelt out numerals in full instead of using the top row of the keyboard. This encouraged Turing to look again at the forty weepy cribs which in 1937 had begun inexplicably to crash, and he came to the conclusion that the cribs remained fundamentally correct provided that the numerals were spelt out.

In early 1940, now joined by Twinn and 2 girls, he started an attack on November 1938 by the forty weepy method and the new-style crib. The reasons for choosing a period so long ago were various but were primarily based on the knowledge that modern keys were more complicated and would require more work. Two new wheels (4 and 5) had been introduced in December 1938, and from the beginning of the war they were unable to trace the forty weepy messages owing to call-signs being no longer used.

<!-- page 295 -->
25 Editor’s note. Funkmaat ¼ radio operator.

After about a fortnight’s work they broke November 28th, and 4 further days were broken on the same wheel order. Only the Spanish Waters came out; the rest of the traYc was on a diVerent key. There were still only 6 Stecker and there was a powerful and extremely helpful rule by which a letter was never steckered 2 days running: if continuity was preserved, 12 self-stecker were known in advance. No Grundstellungs and no bigrams were broken, messages being broken individually or on the EINS catalogue which was invented at this time and was to play an important part in the exploitation of Enigma.

eins was the commonest tetragram in German Naval traYc: something in the region of 90% of the genuine messages contained at least one eins. An eins catalogue consisted of the results of encyphering eins at all the 17,000 positions of the machine on the keys of the day in question. These 17,000 tetragrams were then compared with the messages of the day for repeats. When a repeat was found, it meant that [at] a certain position of the machine the messages could be made to say eins, and further letters were then decoded to see if the answer was a genuine one. If it was, the starting position of the message was known and it could be decoded. In fact about one answer in 4 was right, so that messages were broken fairly rapidly. In later days, the whole process of preparation and comparison was done rapidly and eYciently by Hollerith machinery, but at Wrst slow and laborious hand methods were used.

The plan was to read as many messages as possible, to gain some knowledge of cribs, and then to make rapid progress with the help of the Stecker rule. ‘There seemed’, says Turing in his book, ‘to be some doubt as to the feasibility of this plan’, and in fact it proved over-optimistic. Work was Wzzling out when Norway was invaded and the cryptographic forces of Hut 8 were transferred en bloc to assist with Army and Air Force cyphers.

By the time work on Naval could be started again, the ‘Narvik Pinch’ of April 19th had taken place. This pinch revealed the precise form of the indicating system, supplied the Stecker and Grundstellung for April 23rd and 24th (though the scrap of paper on which they were written was for some time ignored) and the operators’ log, which gave long letter for letter cribs for the 25th and 26th. Wheels 6 and 7 had been introduced by this time and were already in our possession.

<!-- page 296 -->
In all 6 days were broken, April 22nd to 27th. The 23rd and 24th presented no diYculty and the days paired with them, the 22nd and 25th, were also broken (by this time the wheel order was only lasting 2 days and there were ten Stecker). The 26th gave much more trouble, being on a new wheel order with unknown Stecker. At Wrst a hand method, the Stecker Knock Out, was unsuccessfully tried and then the Bombe, which had arrived in April and which will be discussed later, was put onto the problem. After about a fortnight of failure, due largely to running unsuitable menus, the day was broken on a freak menu, to be known later as a Wylie menu and tried unsuccessfully on Shark of February 28th 1943. The paired day, the 27th, was also broken.

All hands now turned to einsing out messages and building up the bigram tables. Provided that the Grundstellung was known, the starting position of the message when broken by einsing could be transposed and the trigram discovered. This then gave a value for 3 bigrams. A message with 2 of the 3 operative bigrams known could be ‘twiddled’ out: the 2 known bigrams Wxed the positions of 2 of the wheels, and only 26 positions for the remaining wheel had to be tried.26 This was quickly done and a further bigram was added to the store. April 27th was on the same bigram table as the 24th and this table came near enough to completion to make Banburismus feasible on another day using the same table. May 8th was identiWed as using this table and a Banburismus was started, but no results were obtained for many months. Turing wrongly deduced that June was using diVerent bigram tables.

The next 6 months produced depressingly few results. Such Banburismus as was triedwasunsuccessful,andtherewaslittlebombetimeforrunning cribs.Suchcribs as there were were supplied by Naval Section and failed to come out; ‘Hinsley’s certain cribs’ became a standing joke. After consulting many people I have come to the conclusion that it is impossible to get an impartial and moderately accurate picture of cribbing attempts at this period: Hut 8 and Naval Section each remain convinced that cribbing failures were due to the other section’s shortcomings.

1940 was clearly a very trying period for those outside Hut 8 whose hopes had been raised by the April Pinch and the results obtained from it. On August 21st Mr. Birch wrote to Commander Travis:

I’m worried about Naval Enigma. I’ve been worried for a long time, but haven’t liked to say as much . . . Turing and Twinn are like people waiting for a miracle, without believing in miracles . . .

I’m not concerned with the cryptographic problem of Enigma. Pinches are beyond my control, but the cribs are ours. We supply them, we know the degree of reliability, the alternative letterings, etc. and I am conWdent if they were tried out systematically, they would work.

Turing and Twinn are brilliant, but like many brilliant people, they are not practical. They are untidy, they lose things, they can’t copy out right, and they dither between theory and cribbing. Nor have they the determination of practical men . . .

Of the cribs we supply, some are tried out partially, some not at all, and one, at least, was copied out wrong before being put on the machine . . .

Sometimes we produce a crib of 90% certainty. Turing and Twinn insist on adding another word of less than 50% probability, because that reduces the number of answers and makes the result quicker. Quicker, my foot! It hasn’t produced any result at all so far. The ‘slower’ method might have won the war by now.

Presumably the number of answers possible on a given crib is mathematically ascertainable. Suppose the one we back 90% has 100,000 possible answers: is that a superhuman labour? . . .

<!-- page 297 -->
26 Editor’s note. ‘Twiddle: To turn round the wheels of an Enigma machine in hand-testing’ (Cryptographic Dictionary, 90).

When a crib, with or without unauthorised and very doubtful additions, has been tried once unsuccessfully we are not usually consulted as to what should be tried next, but, generally speaking, instead of exhausting the possibilities of the best crib, a new one is pottered with under similar handicaps. No crib has been tried systematically and failed; and a few have been tried partially and the partial trial has been unsuccessful . . .

Turing has stated categorically that with 10 machines [bombes] he could be sure of breaking Enigma and keeping it broken. Well can’t we have 10 machines? . . .

At one end, we’re responsible for cribs; at the other end we’re responsible to Admiralty. We know the cribs and the odds on them and we believe in them and it’s horrible to have no hold, no say, no nothing, on the use that is made of them or the way they are worked . . .

This letter has great value as a reXection of the relationship of Hut 8 with the outside world and of the cryptographic organization for breaking Enigma; the fact that the letter misinterprets the true position tends to show Mr. Birch at a disadvantage, but it would be most unfair to look at it in this light, as anyone must know who has read the early Naval Section documents and has seen the eVorts which Mr. Birch extended to further any work which might in any way assist Hut 8.

First of all the letter demonstrates clearly Turing’s almost total inability to make himself understood. Nearly all Mr. Birch’s suggestions, as is immediately obvious to anyone with actual experience of Hut 8 work, are impossible and are simply the result of not understanding the problem—his 100,000 answers (had the bombe been able to run the job, which it couldn’t have done) would have taken 5 men about 8 months to test. Such problems as this and the disadvantages of the other suggestions should clearly have been explained but Turing was a lamentable explainer and, as Mr. Birch rightly says, not a good practical man: it was for these reasons that he left Hut 8 when the research work was done and the back of the problem broken. The lack of satisfactory liaison was a great disadvantage in early days, but was fortunately most completely overcome later; in a letter to myself of May 16th, 1945, Mr. Birch speaks truly of ‘two independent entities so closely, continuously, and cordially united as our two Sections’.

The second point of interest in the letter is the assumption that cribbing and all to do with it was the business of Naval Section and something quite separate from the mathematical work, classed as cryptography and belonging to Hut 8. This concept prevailed until 1941 when Hut 8 set up a Crib Room of its own. No one now would maintain that it would be feasible to separate cribbing from cryptography in this way: to be a good cribster it was essential to understand fully the working of the machine and the problems of Banburismus, bombe management, etc. On the other hand, it remained highly valuable to us that Naval Section were always crib conscious and would send over suggestions for us to explore.

<!-- page 298 -->
The view frequently expressed by Hut 8 was that a successful pinch of a month’s keys with all appurtenances (such as bigram tables) oVered the best chance of our being able to get into a position where regular breaking would be possible, as in the course of that month crib records and modern statistics could be built up. Naval Section papers of the barren days of the autumn of 1940 discuss various plans for obtaining keys in this way.

On September 7th Mr. Birch distributed the following document to his subsections, requesting their comments:

When talking to Lt. Cd. Fleming the other day, Mr. Knox put forward the following suggestion: The Enigma Key for one day might be obtained by asking for it in a bogus signal. Lt. Cdr. Fleming suggested that the possibilities should be examined and something got ready and kept ready for use in emergency. Four groups of questions need answering:

1. In the light of our knowledge of German codes and cyphers, W/T routine, and coding

[and] cyphering instructions, what signals could be made for the purpose,

(1) in what code,

(2) on what frequency,

(3) at what hour(s),

(4) from what geographical position accessible to us?

2. Of the various alternative possibilities, in what circumstances would which be most

likely to fox the enemy?

This scheme found little favour and was soon rejected as impracticable but a week later Mr. Birch produced his own plan in a letter to D.N.I.:27

Operation Ruthless:

I suggest we obtain the loot by the following means

1. Obtain from Air Ministry an air-worthy German bomber (they have some).

2. Pick a tough crew of Wve, including a pilot, W/T operator and word-perfect German

speaker. Dress them in German Air Force uniform, add blood and bandages to suit.

3. Crash plane in Channel after making S.O.S. to rescue service in P/L.28

4. Once aboard rescue boat, shoot German crew, dump overboard, bring rescue boat to

English port. In order to increase the chances of capturing an R. or M. with its richer booty, the crash might be staged in mid-Channel. The Germans would presumably employ one of this type for the longer and more hazardous journey.

This somewhat ungentlemanly scheme was never put into practice although detailed plans for it were made and it is discussed several times in Naval Section papers. In fact, the only valuable acquisition during this period was the Wnding of wheel 8 in August 1940, the last new wheel to be introduced during the war.

27 Editor’s note. Director of Naval Intelligence.

<!-- page 299 -->
28 Editor’s note. Plain language.

The next event in the cryptographic world was the breaking in November of May 8th, known to history as Foss’s day. Foss had joined temporarily to assist in exploiting the Banburismus idea, and after a labour of many months broke the Wrst day on Banburismus. The moral eVect of this triumph was considerable and about a fortnight later another Banburismus, April 14th, was broken at what was considered lightning speed. June 26th was also broken (June having by now been established to be on the same bigram tables) and contained the information that new bigram tables would come into force on July 1st, so Banburismus after that date was out of the question.

A second sensational event was the breaking of April 28th on a crib, the Wrst all wheel order crib success.29 Hut 8 at this time contained no linguists and no cribster by profession and the crib was produced as a result of the labour of two mathematicians, who take great delight in recalling that the correct form of the crib had been rejected by the rival Naval Section cribster.

This last break was obtained in February 1941 and was followed shortly afterwards by the Wrst Lofoten pinch which is one of the landmarks in the history of the Section. This pinch gave us the complete keys for February—but no bigram tables or K book.

The immediate problem was to build up the bigram tables by einsing and twiddling, the methods for which had now been much improved. With a whole month’s traYc to deal with, there was a vast amount of work to be done and the staV position was acute. Rapid expansion and training of new people had to take place and greatly slowed up the work, but by late in March the bigram tables were more or less complete.

Much of the theory of the Banburismus scoring system had been worked out at the end of 1940 and now statistics were brought up to date and satisfactory charts produced. Much work was done on the identiWcation and utilization of dummy messages which at this time formed about half the traYc. It was most important to know and allow for the chance of a message being dummy. The end of a dummy message consisted of a string of consonants and yielded a totally diVerent repeat rate. If dummy was not allowed for, Banburismus could become diYcult and even insoluble.

In March also shift work was started and Hut 8 was manned 24 hours a day for the rest of the war. In April, teleprinting of traYc from Scarborough was begun and the Registration Room was started, all traYc being registered currently. Banburismus was started on some March days and there was a rather depressing period of inexplicable failure before the Wrst break and then the system began to get under way. Sooner or later a large part of April and May were broken. There can be no doubt that at this stage the battle was won and the problem was simply one of perfecting methods, of gaining experience, and of obtaining and above all

<!-- page 300 -->
29 Editor’s note. See p. 253 for an explanation of ‘all wheel order crib’. of training staV. These last stages were made much simpler by the pinch of June and July keys.

These last two pinches were a great stroke of good fortune, for the bigram tables changed on June 15th and had once again to be reconstructed. The methods of reconstruction were, however, by now eYcient and between June 15th and the end of July this task was easily accomplished. Had we not had the keys, all days subsequent to June would have had to be broken on all wheel order cribs and the messages subsequently broken by einsing. With the lack of bombes and comparatively crude knowledge of cribs which existed at that stage, this would have been a slow process, and the beginning of what I have called the operational period of Hut 8 would have been delayed by perhaps 2 or 3 months.

**Bombes**

Throughout these early [sections] I have avoided as far as possible all mention of bombes. Bombes are a complicated subject and their workings are to a large extent incomprehensible to the layman, but without them Hut 8 and Hut 630 could not have existed and it is essential to attempt to describe brieXy the part they played.

The bombe was so called because of the ticking noise it made, supposedly similar to that made by an infernal machine regulated by a clock.31 From one side, a bombe appears to consist of 9 rows of revolving drums; from the other, of coils of coloured wire, reminiscent of a Fairisle sweater.

Put brieXy, the function of a bombe was to take one wheel order at a time and discover which of the 17,000 possible positions of the machine combined with which of the half billion possible Stecker combinations would satisfy the conditions of the problem presented to it. This problem was called a menu and was in fact a crib in diagram form. If the crib and cypher text were

E

T

R

B H

U

S

E

D

F

S

H

J

U

Q

A

P

L

V

V

V

J

V

O

N

D

E

R

G

R

O

E

B

E

N

J32 the bombe would be asked to Wnd a position on the machine where V would encypher as E, followed at the next position by V encyphering as T, etc. To perform this function for one wheel order the bombe would take about 20 minutes. The wheel order would then be changed and the process repeated.

The bombe was a highly complicated electrical apparatus, involving some 10 miles of wire and about 1 million soldered connections. Its intricate and delicate apparatus had to be kept in perfect condition or the right answer was likely to be

30 Editor’s note. Hut 6 dealt with German Army and Air Force Enigma.

31 Editor’s note. This belief seems to have been widespread at Bletchley Park. See pp. 235–7, for remarks concerning the possible origin of the Polish term ‘bomba’, from which the British term ‘bombe’ was derived.

<!-- page 301 -->
32 Editor’s note. from von der groeben (probably a U-boat commander). ‘VVV’ was standard radio spelling for ‘from’ (von). missed. An embryonic bombe was evolved by the Poles and could be used on the comparatively simple pre-war Enigma problems. The invention of the bombe as we have known it was largely the work of Turing, Welchman, and, on the technical side, Keen.

Unfortunately, the bombe was an expensive apparatus and it was far from certain that it would work or, even if the bombe itself worked, that it would enable us to break Enigma. Its original production, and above all the acceptance of a scheme for large scale production, was the subject of long and bitter battles. Hut 8, and, of course, Hut 6, owe very much to Commander Travis, and to a lesser extent to Mr. Birch, for the energy and courage with which they sponsored its production.

The Wrst bombe arrived in April 1940. In August, the Wrst bombe to incorporate the vital development of the diagonal board arrived.

On the 21st of December, 1940, Mr. Birch wrote:

The chances of reading current Enigma depend ultimately on the number of bombes available. The pundits promise that given 35 bombes they guarantee to break Enigma continuously at an average delay of 48 hours.

At present they get the part time use of one machine. The reason that they don’t get more is that there are only two bombes available and that, owing to increased complications of Air Enigma, Hut 6 requires the use of both machines. It is true that more bombes are on their way, up to a limit of 12, but the situation may well be as bad when they have all arrived, owing to the introduction to Air Enigma of further complications and owing to the further success with other Enigma colours, Air or Army.33

The long and the short of it is Navy is not getting fair does. Nor is it likely to.

It has been argued that a large number of bombes would cost a lot of money, a lot of skilled labour to make and a lot of labour to run, as well as more electric power than is at present available here. Well, the issue is a simple one. Tot up the diYculties and balance them against the value to the Nation of being able to read current Enigma.

By August 1941, when Hut 8 really started work on an operational basis, 6 bombes were available. By this time it appears that they were considered to have proved their worth and production went ahead steadily. Some idea of the increasing bombe capacity may be obtained from the following Wgures of the number of jobs run in each year:

1940

273

1941

1,344

1942

4,655

1943

9,193

1944

15,303

The running and maintenance of the machinery was in no respect the responsibility of Huts 6 and 8 but was under the control of Squadron Leader Jones, who

<!-- page 302 -->
33 Editor’s note. See p. 227 for an explanation of ‘Enigma colours’. had working for him a team of technical experts from the R.A.F. and large numbers of Wrens (about 2,000 in all) to operate the machines. The bombe organisation started in one Hut at B.P. and Wnished at four Out Stations organized and fed with menus from a central Station at B.P. The Wnal organisation was complex and highly eYcient, and we owe much to Squadron Leader Jones and his Section. At all times they gave every possible assistance with our problem and no labour was too much to ask of them: certainly no one in Hut 8 worked for lengths of time comparable to those worked frequently by the Bombe Hut mechanics.

The fact that the German Army, Navy, and Air Force used the same cypher machine had the fortunate result that the bombes could be used by both Hut 6 and ourselves and it was a universally accepted principle that they were to be used in the most proWtable way possible, irrespective of the Service or Section concerned. As Hut 6 had more keys to run than ourselves, the bombes were normally left in their hands and we applied for them as required. The relative priority of Hut 6 and Hut 8 keys in their claim for bombe time was decided at a weekly meeting between Hut 6, Hut 8, Naval Section, and Hut 3; in very early days Commander Travis decided what use should be made of the few bombes then available.

To have suYcient material to break a day on the bombe a crib of 30 letters or more was normally needed; when cribs are referred to, the phrase should be taken to mean a guess at the plain text for not less than 30 letters.

The bombe was rather like the traditional German soldier, highly eYcient but totally unintelligent; it could spot the perfectly correct answer but would ignore an immensely promising position involving one contradiction. The eVect of this was that if one letter of the cypher text had been incorrectly intercepted, the menu would fail although both the crib and the text were elsewhere absolutely correct. This was the [reason for] the extensive double-banking programme, which has already been described.

Cribs were sent to the Bombe Hut in the form of menus with directions as to the wheel orders on which they were to be run. No more was heard of them until the possible positions, known as ‘stops’, started to come from the bombes as they worked through wheel orders. The strength of menus was calculated with a view to the bombe giving one stop on each wheel order, thus supplying a check that the machine was working correctly. The identiWcation of the right stop, the stop giving the correct Stecker, and the rejection of the wrong ones was done in Hut 8.

<!-- page 303 -->
In order to get the maximum use from the bombes they had, of course, to be kept fed with menus for 24 hours a day, and the art of bombe management required a certain amount of skill and experience. The plugging up of a new menu was a comparatively complicated and lengthy process, so that it was desirable to give a bombe as long a run on a menu as possible: on the other hand an urgent job would justify plugging up a large number of bombes for only a few runs, because of the importance of saving time. EYcient bombe management was largely a matter of striking the happy medium between speed and economy, of making sure that, with a limited amount of bombe time, everything of importance got run and that, as far as possible, the urgent jobs were run Wrst. Bombe management was interesting because the situation a few hours ahead was to a large extent incalculable: allowance had to be made on the one hand for jobs which one expected to have to run in 12 hours time (and which when the time came did not always materialise) and for the fact that sometimes 2 or 3 jobs would come out in quick succession on one of the Wrst wheel orders to be run, thus releasing large numbers of bombes: because of this possibility it was necessary to keep a reserve of fairly unimportant jobs to Wll the gaps.

Pressure on the bombes varied greatly with the immediate cryptographic situation and the period of the month, it being generally true to say that towards the end of the month the number of wheel orders was restricted by wheel order rules.34 It was, however, extremely rare for us to be unable to keep all the machinery busy even in latter days when there were very large numbers of bombes both here and in America.

**Cribbing**

The Beginning of the Crib Room Autumn of 1941 found us at last approaching a position where there was some hope of breaking Naval Enigma with regularity. For the Wrst time we had read, in June and July, a fairly long series of days and the traYc was heavy enough—in the region of 400 [messages] a day—to make Banburismus practicable.

Hut 8 immediately began to increase in numbers so as to be able to staV 3 shifts for an attack on current traYc. Before the end of the year our senior staV numbered 16. Rather curiously, this was the highest total it ever reached. As methods improved, and as we ourselves became quicker and more skilled, we found ever increasing diYculty in keeping busy and by the end of 1942 our numbers were already on the decline. Although the number of keys to be broken and the volume of traYc rose steadily, we reduced ourselves by March 1944 to a staV of 4, with which we were able to keep the situation under control for the rest of the war.

Autumn of 1941 saw the birth of the Crib Room as an independent body from the Banburists, an important date as the Cribsters were to outlive the Banburists

<!-- page 304 -->
34 Editor’s note. Alexander, ‘Cryptographic History of Work on the German Naval Enigma’, 6: ‘There were a number of ways in which the German key maker quite unnecessarily restricted his choice of wheel orders e.g. the W.O. always contained a [wheel] 6, 7 or 8 in it. Restrictions of this kind were known as Wheel Order Rules and could on occasions narrow the choice from 336 to as little as 10 or 20 which was of enormous value to us.’ by 18 months and cribbing was to become the only means of breaking after the introduction of the 4-wheeled machine.35

It is interesting to note here that by this time cribbing was accepted as a natural part of Hut 8 work—we have seen that earlier it was considered separate from ‘cryptography’ and the function of Naval Section. No one now would dispute that the only possible arrangement was to have the cribbing done by people who understood the whole problem of breaking Enigma, though the more ‘crib conscious’ people there were in Naval Section and the more suggestions they sent over the better. . . .

Earlier in the year, as we have seen, days had been broken on cribs obtained from the operator’s log of the Lofoten pinch, but little had been done in the way of analysing the traYc for routine messages. Cribbing is essentially merely a matter of guessing what a message says and then presenting the result to the bombe in the form of a menu on which the bombe has to Wnd the correct answer. Any fool, as has recently been shown, can Wnd an occasional right crib, though some skill and judgment is required to avoid wasting time on wrong ones, or rather to waste as little time as possible.

Cribs may be divided into 3 basic groups:

1. Depth cribs

2. Straight cribs

3. Re-encodements

As the history of the Hut is from this point to a large extent the history of cribbing, we must digress considerably at this point and study the 3 basic groups with some care. This process will take us far beyond August 1941. . . .

Depth Cribbing The concept of depth is very simple to understand.36 If two operators choose the same trigram they will, after transposing it at the Grundstellung, get the same starting position for their messages. Now suppose that one encyphers

35 Editor’s note. Concerning the four-wheeled machine, Mahon says later in his ‘History’ (on p. 55, which is not printed here): ‘January 1942 passed peacefully enough but on February 1st Shark [the U-boat key] changed over to the 4-wheeled machine and was not broken again, with one exception, until December. This was a depressing period for us as clearly we had lost the most valuable part of the traYc and no form of cryptographic attack was available to us.’ Further information concerning the four-wheeled machine is given in the introduction to Chapter 8, pp. 343–5.

<!-- page 305 -->
36 Editor’s note. ‘Depth-cribbing ¼ Fun and Games: The interesting process of simultaneously fitting two cribs (especially for the beginnings) to two messages on the same setting’ (Cryptographic Dictionary, 27, 40). Alexander expands (‘Cryptographic History of Work on the German Naval Enigma’, 11): ‘when the relative positions of a number of messages have been discovered it is frequently possible by examining them in conjunction with each other to work out the contents of some or all of the messages. This process is known as depth cribbing and cribs produced in this way give cross checks from one message to the other of such a kind that one can be virtually certain of their correctness.’

W E T T E R F U E R D I E N A C H T37 and the other

M I T M M M D R E I S I E B E N E I N S38 It is clear that their cypher texts must have the 3rd, 9th, 12th, and 13th letters in common, as both hit the same letter at the same position of the machine. Let us write them under each other with the encyphered text:

M

B H N W S

S

A W M N T C K N N P

Z

W E

T

T

E

R

F

U E

R D

I

E N A C H T

D

C N N

J

T

R Q N W S

T

T C X R

D

S

M

I

T M M M D R

E

I

S

I

E

B

E

C

N E

I

L

N

S

Here we get the repeats—‘clicks’39 we called them—as expected and also ‘reciprocals’ where the cypher text in one message equals the clear text in the other. Now let us assume that we are cribsters possessing only the cypher text but suspecting that the top message is a weather message which says ‘Wetter fuer die Nacht und Morgen’40—quite a likely state of aVairs as, from time of origin, frequency, call signs, and length, we consider that this message is a plausible candidate for a weather message which occurs every day.

M

B H N W S

S

A W M N T C K N N P

Z

W E

T

T

E

R

F

U E

R D

I

E N A C H T

C N N

J

T

R Q N W S

T

T C X R

D

S

T

M

E

I

E

C

N

Here we see the state of our knowledge about the lower message after assuming we know the clear text of the upper message. It may well be that, from our knowledge of the traYc on this frequency and of the minesweepers known to be operating, we can guess the text of the lower message. We have now done a depth crib, and one that is certainly right. For each ‘click’successfully cribbed we receive a factor of 17 (the language repeat rate) and for each reciprocal one of 26, so we have in our favour a factor of 174  262—an astronomical number in 8 Wgures, which completely lulls any lingering doubts we may have had about the a priori improbability of a given message starting Mit MMM 371 . . . In fact, no experienced cribster would have troubled to do the calculation, but I include it as an example of a method which may very usefully be applied when assessing a crib.

37 Editor’s note. weather for the night.

38 Editor’s note. with m 371. ‘M’ refers to a class of vessel, minesweeper.

39 Editor’s note. ‘Click: A repeat or repetition of one or more cipher units usually in two or more messages, especially a repeat which, by its position in the messages or from the fact that it is one of a significant series, suggests that the messages are in depth’ (Cryptographic Dictionary, 16).

<!-- page 306 -->
40 Editor’s note. weather for the night and morning.

Such a depth crib as that illustrated was rare in the early days of cribbing, largely because we had not on the whole accumulated enough general knowledge or enough experience to have guessed correctly the beginning of the second message. Muchoftheearlydepthwas‘dummy’depth.WehavealreadynoticedthatthetraYc contained very large quantities of dummies ending in a series of consonants. These began with a few dummy words and then said such things as

HATKEINENSINNVONVONMNOOOBOULOGNE41

FUELLFUNKVVVHANSJOTAAERGER42 (HJA¨, the call sign of Brest.)

The large number of messages saying VONVON naturally led to hexagram repeats being discovered by Freeborn when he analysed the traYc. One would be presented with something of this sort: two messages, trigrams HBN and HDS, have a hexa repeat if HDS is written out 17 places in front of HBN. The overlapping part of the texts look like this:

DS H

HWV E L CNUTNU F K J

M JWR J HQO F EWZ E ZNHD L S K E K I CMT B P

D I ENT ZUR T

F

A EU S CHUNGVONVONHAN S J OT AA E RG E R

A HBN

D S NACMOUWMR L AH WHVUXHQZ F EWZ E Z XQDZ

Z

R E CNX S B

E

F UE L L F UNKVONVON F UNK

J

S T

T

E L L EO S LO

This was the simplest form of dummy depth and, as will be realized, the solution of it was extremely easy, and could in fact be found byconsultation of a chart listing all known dummy expressions one under the other: all that was necessary was to Wnd two phrases having 2 letters in common the appropriate distance in front of the ‘vonvon’. To use this chart was thought by some cribsters to be unsporting and unaesthetic, but it was none the less a very useful document. The value of having cribbed the above messages was not, of course, only that we now possessed a crib which would break the day but also that the hexagram had been proved beyond doubt to be a correct Wt—a valuable contribution to the Banburismus.

By the early months of 1942, depth cribbing had become a fairly highly developed art. The amount of dummy traYc was steadily decreasing and much of the cribbing had to be between genuine messages; this, of course, was much more varied, much wider in its scope, and required a far greater knowledge of what messages were likely to say. This knowledge was obtained by extensive reading of traYc and by the keeping of such useful records as lists of ships likely to be addressed on the various frequencies.

The various applications of depth cribbing were also developed and the amount of assistance cribsters were able to give to Banburists steadily increased.

41 Editor’s note. has no meaning from mno boulogne. ‘MNO’ stands for Marine Nachrichten OYzier ¼ Naval Communications OYcer. ‘OOO’ was standard radio spelling for ‘O’.

<!-- page 307 -->
42 Editor’s note. filler radio from hj A¨. I will give one example of the growth of a ‘monster depth’ such as warmed the cockles of a cribster’s heart.

We start by noting that there are 2 messages about which we think we know something and which have trigrams HEX and HEN, that is to say that they started within 26 places of each other on the machine and it is therefore possible that we may be able to set them in depth.

HEX we think says one of 2 things:

VORHERSAGEBEREICHDREITEILEINS43 or

WETTERBEREICHDREITEILEINS44

HEN we think says

ZUSTANDOSTWAERTIGERKANALXX45

We now proceed to examine all the possible relative positions for conWrmations or contradictions.

Position HEX ¼ HEN þ 1 looks like this:

WE T T E R B E R E I CHD

Stagger HEN 1 to left.

VORHE R S AG E B E R E

HEX

BHNWS UHDWMTNCN . . .

H

F DQR L

ZU S T A

B

T

EN

TU L EWGDQ P

NDO S TWA E R

Now in this position there are clicks between the 7th letter of HEX and the 8th of HEN and the 10th of HEX and 11th of HEN, but in neither case have the cribs for HEX letters in common with the crib for HEN, so the position is impossible. Continuing we get to the position HEX ¼ HEN þ 4, which is obviously correct, having 4 conWrmations and no contradictions.

N

H

BHNWS

VORHE

S

EX

UHDWMTNC

KHP Z F HY F RU E K L I G

R S AG E B E R E

I CHDR E I T E I L E I N

H

F DQR L

ZU S T A

B

T I G E R K ANA L X X

EN

TU L EWGDQ P

OXNZ RN S I OZHXHR RN I NK

NDO S TWA E R

N

We now take message HEK about which we know nothing except that it probably comes from Boulogne and may be a dummy. Here again we examine position by position to see what consequences are implied.

Position HEK þ 1 ¼ HEN looks like this:

43 Editor’s note. forecast area 3 part 1.

44 Editor’s note. weather area 3 part 1.

<!-- page 308 -->
45 Editor’s note. situation eastern channel. (The weather situation.)

HEX

BHNWS

HDWMTNCN

H P Z F HY F RU E K L I G

K

VORH E

U

R S AG E B E R E

CHDR E I T E I L E I N S

I

HEN

F DQR L TU L

WGDQ P

OXNZ RNC I OZHXHR RN I NK

B

ZU S T A

N

NDO

E

S TWA E R

I G E R K ANA L X X

T

A V A J VQ S K TW

G P S

QT R E BHU S E CD. . .

I

R

UW

CN

HEK

(Two places

to right)

Both UW and CN are more or less impossible bigrams, so we reject the position. Position HEK þ 3 ¼ HEN, however, looks like this:

HEX

BHNWS

HDWMTNCN

H P Z F HY F RU E K L I G

K

VORH E

U

R S AG E B E R E

CHDR E I T E I L E I N S

I

HEN

F DQR L TU L

WGDQ P

OXNZ RNC I OZHXHR RN I NK

B

ZU S T A

N

NDO

E

S TWA E

R

I G E R K ANA L X X

T

A V A J VQ S K T

W

G P S

QT R E

BHU S E C

HEK

QA I P

I

R

L

U

N

H

N

N

O

D L S S J I E

E Which we guess correctly as OHNESINNVVVMNOOOBOULOGNE46, the Wrst N being just a stray letter in the dummy words. We are now well under way, and have supplied the Banburists with 2 certain distances: with the distances obtained from the Freeborn catalogue in addition they will probably soon produce the correct alphabets.

The next move is to examine a tetragram Wt between HIP and HEX—not a very good tetragram, estimated to have about 1 chance in 3 of being right. With HEX, HEN, and HEK cribbed we can easily prove or disprove this tetra, and great is our delight on Wnding that it is the cypher text of the word drei47; this almost certainly a correct Wt and the matter is proved beyond doubt when we crib the whole beginning of the message. With the amount of crib we now possess, attaching HIJ is not very diYcult and we have a solid piece of depth on Wve messages.

U

R S AG E B E R E

CHDR E I T E

I

HEX

BHNWS

HDWMTNCN

H P Z F HY F R

K

VORH E

E

S TWA E R

I G E R K ANA L X X

T

HEN

F DQR L TU L

WGDQ P

OXNZ RNC I OZHX

B

ZU S T A

U

NDO

A V

A J VQ

S K T

W

G P

BHU S E CD L S S J

I

QT R E

E S I

NVVVMNOOOBO

N

R

HEK

O

S

N

O

S

H

N

D

ME I N S N

UN E I N S DR E I X

E

HI P

S OOO

WO

QC

J

N E

B I

B

O

WLMY Z T A B

I B I X K

L B NK P C Z F HYH

U

VONV

K I VU

U

X48

NMM

46 Editor’s note. without meaning from mno boulogne.

47 Editor’s note. Drei ¼ three.

<!-- page 309 -->
48 Editor’s note. bee bso from m 1913. I am grateful to Frode Weierud and Ralph Erskine for the following information: ‘BSO’ stands for Befehlshaber der Seestreitkraefte Ostsee ¼ Commanding OYcer Naval Forces Baltic Sea (see M. van der Meulen, ‘Werftschluessel: A German Navy Hand Cipher System –

O

UME

CH

NA

T

R E I X V I E R X B

S E T Z E NX X49

E

H I J

HWHV

R

L A

OW

WM

M

N J X V P NQ P J M MF D Y I Y A Z

Y

I N S D

Z

At this stage it is certain that the Banburists will get the alphabet, but we can still assist by conWrming and by Wnding new distances on the middle wheel. If we have two messages HOD and HIJ and know that on the right hand wheel D þ 1 ¼ J, we can say that HOD starts in one of 50 positions in a known relationship to HIJ—1 alphabet plus 1 letter, or 2 plus 1 letter, etc. Inasmuch as HOD is long enough, we can try these possibilities also. Although the whole message cannot be cribbed, the position illustrated where I ¼ O þ 3 on the middle wheel is clearly right, all the consequences are good letters, and at one place much of EINSNULYYEINSNUL50 is thrown up. HOS can then be attached.

N

H

BHNWS

VORHE

I CHDR E I T E

EX

UHDWMTNC

KHP Z F HY F R

R S AG E B E R E

TU L EWGDQ P

OXNZ RNC I OZHX

H

F DQR L

ZU S T A

B

T I G E R K ANA L X X

EN

U

NDO S TWA E R

A V

A J VQ

S K T

W

G P

BHU S E CD L S S J

I

QT R E

E S I

NVVVMNOOOBO

N

R

HEK

O

S

N

O

S

H

N

D

ME I N S N

UN E I N S DR E I X

E

H I P

S OOO

WO

QC

J

N E

B I

B

O

WLMY Z T A B

I B I X K

L B NK P C Z F HYH

U

VONV

K I VU

U

X

NMM

O

UME

CH

NA

T

R E I X V I E R X B

S E T Z E NX X

E

H I J

HWHV

R

L A

OW

WM

M

N J X V P NQ P J M MF D Y I Y A Z

Y

I N S D

Z

CMKG

J

HB

K C

ZW

F

KO J X S H I NUN

Y U P V A K J CM J W

T

Z

R E

N

E

N

I N S NU L Y

E I N S NU L

Y

HOD

N

UHR

L N

NU

U

NAU S G E L AU F

N51

E

HOS

B E V L

W

E C

G I

L P

C

TMZ E BMC I L Z

B

N

ROY A

L

It would be pointless to pursue this depth further. More might well be added and, once started, the messages might be read for some distance. The delight of depth lay in its great variety—no two depths were ever quite the same—and it were a blase´ cryptographer indeed who experienced no thrill at discovering a right position and correctly guessing large chunks of message about the contents of which he at Wrst knew nothing. Needless to say things rarely went as smoothly as in our example, and it was possible to work for a very long time without even getting a piece of depth started.

Part I’, Cryptologia, 19 (1995), 349–64). ‘Bee’ translates ‘Bine’, a code word for the urgency indicator ‘SSD’: ‘Sehr, Sehr Dringend’ (Very, Very Urgent). The German Navy used three alternative code words for SSD: ‘Bine’, short for ‘Biene’ (bee), ‘Wespe’ (wasp), and ‘Mucke’ or ‘Muke’, short for ‘Muecke’ (midge).

49 Editor’s note. night to 13.4. occupy.

50 Editor’s note. ten ten.

<!-- page 310 -->
51 Editor’s note. 00 hours left royan.

There were other applications of depth cribbing of which only one need be mentioned here—the slide. The slide is similar to the process by which we started our last example, but in this case we only have a crib for one message—a fairly long and probably a right crib. If SWI is our cribbed message, we examine the consequences of trying SWL for 25 places to either side of it and, although we cannot attempt to crib [the] result, we look to see whether the letters thrown up are good or bad. For this a simple scoring system was used, E being worth something in the region of 57 and Q about 100. On a really long crib the right position usually showed up clearly and a large number of distances were established by this method.

Depth cribbing died with Banburismus in autumn 1943.

Straight Cribs I should perhaps have dealt with straight cribs before depth. The theory of straight cribs is simple: it is merely a matter of guessing the contents of a message without the assistance of depth and without the contents having already been passed in another cypher which has been broken.

Finding straight cribs was largely a matter of analysing the traYc. At Wrst, with the traYc fairly small, this was comparatively easy and an organisation was created for writing down any message which looked as if it might occur regularly. Having found a message of a routine type, details about it were recorded. SigniWcant facts were normally frequency and frequencies on which it was retransmitted, call-signs, German time of origin, and length. When a few examples had been written down, it became possible to assess:

(a) whether, given an unbroken day’s traYc, it would be possible to identify

this particular message;

(b) whether, once identiWed, it had few enough forms to be used as a crib.

These two factors—identiWcation and forms—were the essential factors in all cribbing. In our experience identiWcation, though often tricky, could usually be cleared up by careful examination of the evidence and there have been comparatively few cribs that have been unusable because they had been unWndable. In very diYcult cases we tried to enlist the assistance of R. F. P.52 but, though help was most readily given, the experiments were never very successful. The German Security Service appears to have considered that retransmitting of messages of one area in another area was dangerous and did something towards stopping curious linkages by recyphering messages and adding dummy at the end before retransmission. This sort of thing was a nuisance to us, but never became suYciently widespread to cause serious diYculty.

<!-- page 311 -->
52 Editor’s note. ‘Radio Finger Print: Enlarged or elongated film-record of morse transmission by means of which the type of transmitter used and the peculiarities of the individual sets of any type can be distinguished, serving to identify stations’ (Cryptographic Dictionary, 63).

The ideal crib is not shorter than 35 letters and uses the identical wording every day. Such cribs never existed, though occasionally we possessed for a time what seemed to be the crib to end all cribbing. For some 3 months in the summer of 1942, Boulogne sent a weather message which began zustandostwaertigerkanal53 and, if I remember rightly, it only failed twice during that period. On the whole, a crib that had more than 2 or 3 basic forms was little use except for getting out paired days on known wheel orders or for depth cribbing: most cribs produced ‘horrors’ from time to time which we classed as ‘other forms’ and made no attempt to allow for them as a possible form of a crib, but when assessing a crib it was of course necessary to take into consideration the frequency with which ‘other forms’ were tending to appear.

The crashing54 property of the machine was an essential element of all cribbing and most especially of straight cribbing. When writing a wrong crib under a portion of cypher text, each letter of crib had 1 chance in 25 of being the same as the letter of cypher text above it and of thus proving by a ‘crash’ that the crib was wrong. If therefore a crib had 2 good forms, each about 30 letters long, there was an odds on chance that the wrong form would crash out; in this case the remaining form is, of course, left with a heavily odds on—instead of an approximately evens—chance of coming out. If the good forms crashed out and only some rather poor form went in, it proved to be bad policy to believe the poor form to be correct, although on the basis of mathematical calculation it might appear to have a reasonably good chance. It was the ability to assess this type of problem which distinguished the good cribster. It was impossible to become a good cribster until one had got beyond the stage of believing all one’s own cribs were right—a very common form of optimism which died hard.

The pleasure of straight cribbing lay in the fact that no crib ever lasted for very long; it was always necessary to be looking for new cribs and to preserve an open mind as to which cribs oVered the best chance of breaking a day. A crib which lasted for 2 months was a rarity; most cribs gradually deteriorated and never recovered until eventually we only recorded them every 2 or 3 days. To give up recording cribs because they were bad was a fool’s policy; it unquestionably paid to keep a record of anything that might one day assist in breaking. Time and again, when a good crib died, we were thrown back onto a reserve at which we would have turned up our noses a week before, only to Wnd that the reserve was quite good enough to enable us to break regularly.

The perennial mortality of cribs was undoubtedly to a considerable extent the result of the work of the German Security Service to whose work as crib hunters we must in all fairness pay tribute. The information recently received that they kept an

53 Editor’s note. situation eastern channel. (Weather situation.)

<!-- page 312 -->
54 Editor’s note. ‘Crash: The occurrence of a plain letter opposite the same letter in the cipher text in one of the positions or versions in which a crib is tried, normally involving rejection of that position or version’ (Cryptographic Dictionary, 22). expert permanently at work analysing the weaknesses of the machine does on the other hand little credit to their technical ability. The crib chasers gave us a fairly bad time, especially in the areas nearer home where the cyphers were better organised. By March 1945 Dolphin—a large key of some 400 messages a day—had been rendered almost cribless and we might have failed to read some of the last days had we not captured the Hackle keys which kept us supplied with re-encodements.

Cribs in the early days were largely weather messages. A very large amount of weather was sent in Enigma and it was obvious that it was regarded as of Wrst importance. In 1941 weather cribs from the Channel ports were our principal stand-by and wewa55 boulogne and wewa cherbourg were trusty friends. One day during the late autumn, the security oYcers pounced on this habit of announcing internally from whom the weather originated, but Wrst class cribs of a rather shorter variety continued to come regularly at the beginnings and ends of messages. Rather curiously, this habit of signing weather messages at the end never caught on elsewhere and after the death of the Channel weather cribs in spring 1942 we never again had cribs at the ends of messages. This was, on the whole, convenient as a message always Wnished with a complete 4 letter group (irrespective of the number of letters in the plain text, dummy letters being added at the end), so that an end crib could be written in 4 diVerent places, and one had to be fortunate with the crashing out for a single really good shot to be available.

The reprimand to the Channel weather stations for insecurity in April 1942 is something of a landmark as the Channel cribs never recovered, except for the remarkable run of zustandostwaertigerkanal during the summer of the same year. Henceforth they omitted such lengthy statements as wetterzustandeinsachtnulnuluhr56 and satisWed themselves with a terse nantesbisbiarritz57 buried somewhere in the middle of the message. This habit of burying sign-oVs was an almost completely eVective anti-crib measure and became more and more widespread as time went on.

Weather cribs in Norway and the Baltic were useful for a long time, and in the Mediterranean for even longer, but there can be little doubt that the security services were weather conscious and one after another cribs of this type disappeared. They were replaced by other cribs of a type which generally required more Wnding—some were situation reports of a fairly obviously routine nature, others were much more elusive. For instance, when looking through a day’s traYc one was not likely to be struck immediately by a message from Alderney to Seekommandant58 Kanalinseln which said feuer brannten wie befohlen59 but it was in fact a daily conWrmation that various lights had been shown as ordered and was a very excellent crib.

55 Editor’s note. ‘wewa’ abbreviates ‘Wetter Warte’: weather station.

56 Editor’s note. weather situation 1800 hours.

57 Editor’s note. nantes to biarritz.

58 Editor’s note. Naval Commander.

<!-- page 313 -->
59 Editor’s note. beacons lit as ordered.

To spot cribs of this type it was necessary to read through large quantities of traYc, covering perhaps a week or two, and to have a good short-term memory which would react to seeing two similar messages. Work of this type was naturally more diYcult and, as the years went by, the Wnding of possible cribs (as distinct from their exploitation) began to require more and more high-grade labour. For a long time, junior members of the Crib Room were relied upon for discovering new cribs by reading traYc in Naval Section but, as cribs became scarcer, it became obvious that this system was inadequate, and we started having traYc redecoded on the carbon copies of messages so that they were available for scrutiny by senior cribsters. The desirability of this system was further stressed by the increasing numbers of re-encodements which had to be recognized and preserved, so that by 1945 nearly all the traYc was being decoded twice. In some respects this was an extravagant system, as it required a large decoding staV, but it meant that Naval Section received their decodes more quickly, as all available typists set to work Wrst of all on their copies and subsequently typed those for the Crib Room. The alternative scheme would have been to have an increased number of high-grade cribsters so that someone was always available to examine decodes before they went to Naval Section.

The crib chosen as an example in the paragraph before last is interesting also for being a crib for a complete message. Cribs on the whole were only ‘beginners’, but we had much success with very short messages for in these we got additional conWrmation that our crib was right, in that it Wnished up exactly in the last group of the message. An interesting example of this type was a little harbour report from the Mediterranean. It said: hansmaxvvvlechxxaaayydddfehlanzeige.60 This was a 13 group message. If the message was 14 groups, vvv had been changed to vonvon, one of the normal alternatives for which the cribster had to allow—others were funf or fuenf, siben or sieben, vir or vier, etc.61 Most of these little messages that could be cribbed in toto were situation reports which said, in some form or other, ‘Nothing to report’; some of them were security conscious and Wlled up the message with dummy words, which had the eVect of degrading them to the level of a normal crib.

. . . One further crib must be mentioned here for fear it be forgotten altogether as, though often useful, it was never one of the cribs which formed our daily bread and butter. This was the popti crib, so christened by the decoders who were amused by the curious selection of letters it contained. We have seen that the German Navy had ceased in general using QWERTZUIOP numerals, but these numerals continued to be used for certain types of Wgure—weather and notably for certain observations aVecting gunnery. As a result we received messages of this sort:

60 Editor’s note. hm from lech a-d error message.

<!-- page 314 -->
61 Editor’s note. Alternative spellings of the German words for five, seven, and four. NUEMBERG VVV WEWA SWINEMUENDE LUFTBALTA 05 UHR62:

P P

Q

I

P

P

W

Y

Q

U

E

P

T

O

Y P T

W

Q

T

P

R

Y

Q

E

Z

O

T

I

Y Q P

W

P

Q

P

E

Y

Q

E

T

W

T

Z

Y Q T

Q

O

Q

P

E

Y

Q

E

R

E

T

T

Y W P

Q

U

O

P

W

Y

Q

E

E

R

T

E

Y W T

Q

U

Z

P

W

Y

Q

E

W

O

T

W

Y E P

Q

U

Z

P

W

Y

Q

E

W

R

- Q

Y E T

Q

I

Z

P

W

Y

Q

E

Q

O

T

P

Y R P

Q

U

Z

P

W

Y

Q

E

Q

I

T

P

Y R T

Q

U

E

P

W

Y

Q

E

Q

U

T

P

Y T P

Q

Z

O

P

W

Y

Q

E

Q

Z

T

P

Y Z P

Q

Z

Q

P

Q

Y

Q

E

Q

E

T

P

Y U P

P

I

U

P

Q

Y

Q

E

Q

- T

P

Y I P

M

T

W

P

W

Y

Q

E

Q

P

T

P

Y ERDBALTA 05 UHR63:

P P

Q

I

P

P

W

Y

Q

E

U

P

T

O

Y Q P

Q

I

P

P

W

Y

Q

E

Z

I

T

I

Y Q T

Q

O

I

P

E

Y

Q

E

Z

E

T

I

Y W P

W

Q

T

P

R

Y

Q

E

T

O

T

U

Y W T

O

I

E

P

E

Y

Q

E

R

O

T

T

Y E P

Q

Z

U

P

E

Y

Q

E

R

Q

T

R

Y R P

Q

U

P

P

W

Y

Q

E

Q

O

T

W

Y T P

Q

U

E

P

W

Y

Q

E

Q

I

T

Q

Y Z P

Q

E

W

P

Q

Y

Q

E

Q

T

T

P

Y U P

P

W

T

P

R

Y

Q

E

Q

W

T

P

Y I P

P

E

I

Q

E

Y

Q

E

P

I

T

E

The letters enclosed in the boxes are constant. The bigrams in columns 1 and 2 are the station indices and the 13 letters which follow are the observations from each station: the Ys are commas and the second half of the observation always has a one as its Wrst digit—hence the Q. The stations were always listed in the same order and so we had right through a long message a series of known letters in Wxed relative positions. The crib would look something like this: PP?????YQ?????YPT?????YQ etc. These cribs were good and were successfully used, but unfortunately usually lived for a short time only. The example given, for instance, was dependent on the Nuemberg being out exercising. Occasionally, similar messages occurred with the numerals written out in full, but were less useful in most cases owing to the varying lengths of numerals.

62 Editor’s note. nuremberg from weather station swinemuenda air [balta]

<!-- page 315 -->
05 hours. ‘Balta’ is clearly a meteorological term but the meaning is obscure. 63 Editor’s note. ground [balta] 05 hours.

In the spring of 1942 the Wrst shift system for a crib was discovered. This was a very important discovery which aVected straight cribbing for the rest of the war. The reason for failing to make this discovery earlier was doubtless the same [as the] reason for our failing to notice in early days cribs of a type which were in regular use later; the obvious cribs were very good and we simply did not look very hard for the less obvious, a reprehensible but very understandable state of mind into which we seem frequently to have lapsed. The fact was that, when a key was breaking regularly and satisfactorily, there was very little incentive to do energetic research work.

The incentive which led to the discovery of the shift system was a deterioration of the Channel weather cribs, soon to be Wnally killed. The position was that they were developing too many diVerent forms and it was at this stage that it was noticed that certain forms occurred at regular intervals. The discovery was made on Cherbourg weather and was rapidly exploited elsewhere. This system involved 4 operators and I very much regret that all records of this original shift system have long since been destroyed. The interesting thing is that all later shift systems, some of which have been proved beyond a shadow of doubt, have worked on a 3-day cycle and have involved 3 operators. It would be interesting to re-examine the original shifts in the light of this evidence to see if our conclusions were only in part correct. The most common form of 3 day cycle, and the only one to be proved in detail, divides the day into 3 shifts (approx. 0–9, 9–16, 16–24) and works as follows: /BAC/ACB/CBA/BAC/ACB/ etc. As an example of the uses of these shifts we may take the twice daily weather report sent out to Arctic U-boats. This message stated the day and the month for which it was a forecast and the month appeared as a jumble of names and numbers—in fact, 2 forms of the crib had to be run each time, one with April and one with vier. On being divided into shifts on the above principle, however, it was discovered that one man said April consistently and the other two vier so that on any day we knew which would occur. Also one man was security conscious and was responsible for nearly all the ‘horrors’ and it was best to leave the crib severely alone when he was on duty.

<!-- page 316 -->
The practical use of crib records, that is to say, the identiWcation of cribs and the decisions as to what was and was not worth running, always remained a job for high-grade labour, rather surprisingly, as in theory it is simple enough. An attempt to ‘mechanize’ cribbing with the help of mathematical formulae was a lamentable failure and disappeared amidst howls of derision, though in justice to the inventor of the system it must be said that this was not really due to the essential faultiness of the system as he proposed to use it, but rather the fact that it was misapplied by the inexpert and ignored by the expert, who felt rightly that it was no real assistance. Mathematical computation of the probability of cribs was a system which could not be ignored, but results needed to be modiWed and analysed by the judgement of experience. Nothing really could replace the knowledge which was gained by experience. A cribster had to come to realize that a crib was not right because he had thought of it himself, that he should not be discouraged because a series of apparently good cribs had failed and start making wild assumptions about new wheels and new keys. He had constantly to decide between two or more cribs as to which was the best and in doing so had to rely as much on a very wide experience as on written records. He had to know which risks could be wisely, which unwisely, taken and had constantly to make decisions on the policy to adopt in breaking a key: would it be better to run 1 crib with a 60% chance of coming out and, if this failed, change to another message, or start on a programme of a 3 form crib on one message which would Wnish by giving a 95% chance of success? Problems like this would, of course, have been easy had it not been necessary to consider such other factors as the bombe time available, the intelligence and cryptographic advantages of a quick break, the probable pressure on bombes in 12 hours time, and so on. On the face of it, straight cribbing appears to be impossibly tedious when compared with depth but, though depth had its great moments which straight cribbing could not touch, the problem did not become less interesting when Banburismus had died. With perhaps 6 to 10 keys to break regularly, the cribster was a busy man faced with an interesting problem in tackling which he had to consider not only the total number of keys eventually broken but also economy of bombe time and the demands of Intelligence.

Re-encodements Re-encodements are repetitions in a cypher of messages which have already been transmitted on other cyphers, or indeed in plain language. The great advantage of re-encodements over straight cribs is the factor they receive in favour of their being right, owing to the length of crib which has been written in without its crashing against the cypher text. We have already seen that for each letter of a wrong crib there is a 1 in 25 chance of a crash, so that a 50 letter crib which does not crash gets a factor of 7 in its favour, a 100 letter crib a factor of 50, a 200 letter crib a factor of 2,500, a 300 letter crib a factor of 40,000—in fact there is really no chance of a long re-encodement being wrong. We have met re-encodements in a variety of fairly distinct forms which I will deal with separately.

Re-encodements from hand cyphers The two main sources of re-encodements from hand cyphers were Werftschluessel64 and R.H.V.65 Werftschluessel was used by small ships in the German Home Waters area, mostly in the Baltic: it was read continuously from early 1941 to February 1945, when it was abandoned as being of little further value. R.H.V., the

64 Editor’s note. Dockyard Key.

<!-- page 317 -->
65 Editor’s note. RHV ¼ Reservehandverfahren: Reserve Hand Cipher, used should an Enigma machine break down (see F. H. Hinsley and A. Stripp (eds.), Codebreakers: The Inside Story of Bletchley Park (Oxford: Oxford University Press, 1993), 238–9). reserve hand cypher of the German Navy, was being used, apart from its function as an emergency cypher, by a number of small ships in the Norwegian area when it was Wrst captured in December 1941. Presumably owing to the completion of the distribution of the [Enigma] machine, its use gradually declined and there has been little traYc since the end of 1943.

Re-encodements from these cyphers were of the type one would expect— messages of signiWcance to great and small alike: weather messages, gale warnings, aircraft reports, mine warnings, wreck warnings, etc. Given the R.H.V. or Werft version of the signal, it was not normally diYcult to Wnd its Enigma pair. Habits about relative time of origin varied somewhat from area to area but were fairly consistent in any one area, while length, and the frequencies the Enigma version was likely to be passed on, were normally fairly accurately predictable.

The most famous of all these re-encodements was Bereich 766, which broke Dolphin consistently from late 1942 to late 1943. This was a twice daily reencodement of weather from Trondhjem, and it was normally possible to produce a right crib from it. The contents were rarely hatted67 and the only hazard was an addition at the end of the Dolphin message giving the information that a certain R.H.V. message need not be decoded as it had identical content. Another famous weather crib was Bereich 5, which broke most of the Wrst 6 months of Plaice but which subsequently became security conscious and hatted, the Werft version to such an extent that we could do nothing with it. By early 1945 it was so bad that we did not feel justiWed in asking that Werft should continue to be broken to assist us with Plaice. It was generally true of all re-encodements that, if much hatting took place, we could make little use of them.

The other most proliWc source of re-encodements of this type was the mine laying, especially in the Baltic. Mine warnings and ‘all clears’ were sent out in Werft and then repeated for the Baltic U-boats. So good were these cribs that, if we were under pressure to obtain an early break, mines were laid deliberately with a view to producing cribs and most proWtable results were obtained. We even put up suggestions as to the best places to lay mines: obviously weg funf (or fuenf) ziffer (or ziffx or ziff) sieben (or siben) was a rotten place but kriegsansteuerungstonne swinemuende68 was likely to go unaltered into the Enigma version. The golden age of these cribs was the Wrst half of

66 Editor’s note. Area 7.

67 Editor’s note. ‘Hat book: A code-book characterized by the fact that when the plain-language terms are arranged in alphabetical order the code groups are not in numerical (or alphabetical) order. . . Hatted: Arranged in other than numerical (or alphabetical) order.’ (Cryptographic Dictionary, 43.)

<!-- page 318 -->
68 Editor’s note. wartime marker buoy swinemuende. (I am grateful to Ralph Erskine and Frode Weierud for assistance with the translation of this crib.)

1942. By 1943 they were already falling oV and eventually, by using dummy words and inversions, they ceased to be of any interest to us.

Re-encodements from Army and Air cyphers There was surprisingly little re-encodement between our traYc and that of Hut 6. The only re-encodements to have occurred consistently over a long period were Mediterranean reconnaissance reports. These were usually easy to tie up and fairly diYcult and amusing to attack; they had their heyday in early 1944 when Porpoise ceased to be breakable on its indicating system. These diVered from all other re-encodements in that they presented a problem of ‘translation’: the German Air Force used very diVerent cypher conventions from the Navy, so each message had to be turned into Naval language before it could be used. With a little practice this game could be played very successfully.

Re-encodements between Naval machine cyphers Apart from those already mentioned, all re-encodements have been between keys we ourselves have broken. Hence they only began fairly late in our history as the number of our keys increased. The most famous series of these re-encodements were those originating in Shark and being repeated in Dolphin (later Narwhal) for the Arctic U-boats, Plaice for the Baltic U-boats, [and] Turtle for the Mediterranean U-boats. These re-encodements were messages of general interest to all U-boats—corrections to existing documents, descriptions of new Allied weapons, signiWcant experiences of other boats, etc.—and they would start their career by being sent on all existing Shark services, with often a note at the end ordering repetitions on other keys. Re-encodements of this type were usually dead easy and, as they were usually long, one knew deWnitely when one had a right crib. A considerable timelag before re-encoding—on Narwhal sometimes 3 or 4 days—often made identiWcation diYcult, but had compensating advantages. Shark of the 2nd of a month might break Narwhal of the 4th and Narwhal of the 4th might also contain a re-encodement of a Shark message of the 3rd. The 3rd Shark would break and its paired day69 the 4th would follow, providing perhaps a store of messages likely to appear in Narwhal of the 5th or 6th. Re-encodements were fairly frequent, an overall average of perhaps 1 or 2 a day, and, with several keys involved, it was often possible to break all keys concerned for considerable periods on re-encodements without having to use a single straight crib—a very economical process.

Another remarkable series of re-encodements linked Dolphin and Sucker from November 1944 until the end of the war. In this case it was a weather message from the Hook of Holland which was repeated in almost identical form in the 2

<!-- page 319 -->
69 Editor’s note. See p. 259 for an explanation of ‘paired day’. cyphers. This crib was responsible for our consistently good results in Dolphin during the last months of the war.

Another weather re-encodement of considerable interest was that of bereichdora70—an area in the Skagerrak and West Baltic of interest to Plaice and Dolphin. This message originated from Swinemunde on Plaice and was repeated on Dolphin by one of a variety of stations, in accordance with a complicated programme. The repeating station was responsible for hatting the original and for sending it out on the Dolphin frequencies; normally the repeating station encyphered it twice with the text in a diVerent order and sent it out as 2 independent messages. Security precautions were in fact extremely strictly enforced. However, the original Plaice message always set out its observations in the same order—wind—cloud—visibility—sea—and it was possible to take the Dolphin message and reshuZe it into its original order. bereichdora remained far too tricky to be a high-grade crib, but it was used regularly and quite successfully when nothing better was available: there were several periods when it was in fact our only crib into Plaice. The Wnal reWnement of discovering the principle on which the Plaice was hatted and using it for breaking Dolphin remained beyond our powers.

The remaining and most curious type of re-encodement was between one day’s traYc and another on the same cypher. These re-encodements were found largely in the Baltic where a series of belehrungsfunksprueche71 were sent to the training U-boats and were repeated frequently for some weeks. There was no law as to when these might be retransmitted but, presumably because their content was [of] didactic value and the decyphering of them good practice, they occurred at one period fairly frequently, and could often be identiWed by their exceptional length. Dolphin also produced one crib of this type, perhaps the longest lived of all our cribs and one which would have broken Dolphin daily, had it been possible to intercept the message satisfactorily. It was a statement of areas oV North Norway in which anti-submarine activities were to be allowed during the next 24 hours and, while the areas did indeed sometimes change, much more often they remained the same and the message of the day before supplied the crib for the message of the new day.

Commander Denniston wrote: ‘The German Signal Service will do its best to prevent compromise of Enigma by inferior low-grade72 cyphers . . . the Germans do not intend their cyphers to be read.’ The German Signals Service failed, however, lamentably in its functions (though Werft and R.H.V. are not, of

70 Editor’s note. Area D.

71 Editor’s note. Training radio messages.

<!-- page 320 -->
72 Editor’s note. ‘Low-grade (of a code or cipher system): Not expected to resist attempts to break it for long, esp. if used to any great extent’ (Cryptographic Dictionary, 52). course, low-grade cyphers), and its cyphers were most extensively read. In later years, we should never have been able to continue regular breaking on a large number of keys if it had not been for the steady Xow of re-encodements, and their complete failure to master the re-encodement problem was without doubt one of the biggest blunders the German Security Service made.

**The Beginning of the Operational Period**

During the Autumn of 1941, the outlook became steadily brighter. In August there were 6 bombes in action and we had the bigram tables without which Banburismus was impossible.

The results speak for themselves. All August was broken except 1–4, 24–25, all September, and all October except 3–4 and 12–13. From October 14th, 1941, Dolphin was broken consistently until March 7th, 1945.

During these months, methods of Banburismus and cribbing improved considerably. The situation gradually developed that stability which can only arise from a long period of regular breaking.

Early in October, on the 3rd, 4th, or 5th, we were mystiWed by the failure of the U-boat traYc to decode when Dolphin for the day had been broken. The situation was saved by a Werft crib, one of Werft’s earliest triumphs, and it transpired that the key was the same as for the rest of the traYc except for the Grundstellung, which was entirely diVerent. This was a further development of the innovation of April when the U-boats started to use a Grundstellung which was the reverse of that used by surface craft. This new development made very little diVerence except that it delayed slightly the reading of the U-boat traYc.

November 29th brought the Wrst real crisis in the form of a change of bigram tables and K book. 6 months earlier this would have beaten us, but we now knew enough about cribs to be able to break the traYc without Banburismus if suYcient bombes were available, and there were now 12 bombes in action. Rather curiously, we thought it worth while to indulge in the luxury of a Freeborn catalogue of Wts in the hope of being able to do a piece of depth— dummy depth—a remarkable reXection on our comparative ignorance of straight cribs and of their value. The policy was, however, to some extent justiWed, as on November 30th we got a right dummy depth crib and Commander Travis, then the arbiter of bombe policy, decreed that we might have all 12 bombes to run it.

<!-- page 321 -->
This crib and many others duly came out in the course of December, and the process of einsing, twiddling, and bigram table building, described in an earlier [section], proceeded merrily enough and considerably more smoothly than before. By the end of December, the tables were near enough to completion to begin to think of restarting Banburismus and Turing was just starting to reconstruct the K book—almost the last theoretical problem he tackled in the Section, although he remained with us for some time to come. On December 30th a pinch of keys, bigram tables, and K book made further work unnecessary and we were able to restart Banburismus at once.
