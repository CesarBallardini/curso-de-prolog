# Appendices

<!-- page 263 -->
Appendix A.l Appendix A.2 Appendix A.3 Appendix A.4 Itemel File ...................................................... .. “Bootstrapper“ ................................................ .. User Interface and Utilitim ................................. .. Three Useful Programs A Simple Editor

<!-- page 264 -->
............................................. .. A Primitive Tracing Tool .................................... .. A Program Structure Analyser with Analyser Analysed APPENDIX A.l Kernel Flle

1 2 3 % KEFINEL llle % standard atoms ';'/2

','/2

‘call’/1

‘tag’/1 ‘U’/0

'.'/2

'error'l1

'user'I0

% atoms ldentilylng system routlnes (keep ‘tall’ ¿rst and ’tn.re' last) 'lal|'/0 ‘tag’/1

‘call’/1

‘I70 'tagcut'l1

'Iaglall'/1

tagexlt’/1

‘ancestor’/1 ‘halt’/1

'status'l0 ‘display’/1

‘rch'I0

'lastch'/1

'sk'pbl'I0

'wch'/1 'echo'/0

'noecho'l0 ‘see’/1

'seelng'/1

'seen'I0

‘tell’/1

‘telling’/1

'Iold'I0 'orclchr'/2

'sum'l3

'prod'l4

‘less’/2

'@<'/2 'smalletter'/1

'blgIeIter'l1

'letter'l1

'dIgll'l1

'alphanum'l1 ‘bracket’/1

'solochar'/1

‘symch’/1 'eqvar'/2

‘var’/1 ‘atom’/1

‘Integer’/1

‘nonvarint’/1 'lunctor'I3

‘arg'I3

‘pname’/2

‘pnamei’/2 '$proc’l1

'$proclknlt'l0

’$proclnlt’l0 ‘clause’/5

’retract'l3

‘abolish’/2

'assert'l3

'redellne'l0 'predellned'l2

‘protect’l0 'nonexlstent'I0

'nononexlstent'/0 'debug’l0

‘nodebug’/0 'tn.re'I0

% kemel lbrary error(:0) : nl . display(‘-1-r-+ System call error: ') . dlsplay(:0) . nl . lall . U :ordchr(10, :0) . assert(lseoh(:0). U, 0) .

**assert(nl, wch(:0).U, 0) . U I**

'-'(:0, :0) :U ','(:0, :1) :call(:0) . calI(:1) . U ';'(:0, _) :call(:0) . U ';'(_, :0) : call(:0) . U not(:0) :call(:0) . '1' . lall . U not(_) :U check(:0) : not(not(:0)) . U ‘side_ettects‘(:0) : not(not(:0)) . U

or1ce(:0) :call(:0) . '1' . U

'@-<'(:0, :1) : '@<'(:1, :0) . '1‘ . lall . U ‘@-<'(_, _) :U '@>'(:0, :1) : '@<'(:1, :0) . U '@>-'(:0, :1) : '@-<'(:1, :0) . U

<!-- page 265 -->
% - - - - - - baslc lnp1.rl procedures - - - - - rdchsk(:0) : rch . skbbl . lastchm) . U r1:lch(:0) : rch . laslch(:1) . sch(:1, :0) . U % convert nonprhtable characters to blanks sch(:0, :0) : '@<'(' ', :0) . '1' . U sch(:0, ' ') : U 3100:)-ro>r.nt:> 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 4-4 45 46 47 48 49 50 51 52 53 APPENDIX A.l (Continued)

54

repeat : U 55

repeat : repeat . U 56

merr|ber(:0, :0.:1) : U 57

merr|ber(:0, _.:1) : merrber(:0, :1) . U 58 59

proo(:0) : '$proclnIt' . ‘$pr’(:0) . U 60

'$pr‘(:0) : '$procii'nit’ . ‘I’ . tall . U 61

'$pr‘(:0) : '$proc'(:0) . U 62

'$pr‘(:0) : ’$pr‘(:0) . U 63 64

```prolog
%
```

b a g o I (preserves order of solutions) 65

```prolog
bagot(:0, :1, _) : asserta('BAG'('BAG')) . call(:1) .
```

66

asserta('BAG'(1))) . tall . U 67

```prolog
%% 0 Item, 1 Condition.
```

68

bago1(_, _, :0) : 'BAG'(:1) . ‘I’ . lntobagtzt, U, :0) . U 69

```prolog
%% 0 Bag, 1 Item,
```

70

imobag('BAG', :0, :0) : ‘I’ . retract('BAG‘, 1, 1) . U 71

```prolog
%% 0 Flnal_bag,
```

72

intobag(:0, :1, :2) : retract('BAG‘, 1, 1) . 'BAG'(:3) . ‘I’ . 73

|ntobag(:3, :0.:1, :2) . |] 74

```prolog
%% 0 Item, 1 Thls_bag, 2 FInaI_bag, 3 Next_ltem,
```

75 76

% end oi Àle - toyprolog will now read Irom the terminal 77

**:dlsplay('Keme| Àle Ioaded.') .nl . see(user) . U I**

<!-- page 266 -->
APPENDIX A.2 “Bootstnpper”

1 2

```prolog
% % % translator ot Prolog-10(mlnl) Into ‘kemel-prolog" % % %
transIate(:0, :1) : see(:0) . telI(:1) . program . seen . told .
seeluser) . te|l(ueer) . display(transIated(:0)) . nl . U
    %% 0 trom_llle, 1 to_Àle
% - - - - - - - - - - - - - - - - -
% maln loop
program : rch . skpb(:0) . tag(trar|sl(:0)) . lsendsym(:0) . ‘I’ . U
PY°lJ|‘¿"'l I P"°tI'al'" - I]
lransl('@') : ‘I’ . rch . U
transl(’%') : oomment(’%‘, :0, U) . ’I’ . puttrm) . U
 transI(:0) :oIauee(:0, :1, U, :2) . putlr(:1) . putvamames(:2, 0).U
     %% 0 stench, 1 tennrepr, 2 sym_tab
 Isendsyrn(’@') : U
                    % otherwise tall, Ie loop
 % - - - - - - - - - - - - - - - - -
```

% error handing: skip to the nearest dot

```prolog
err(:0, :1) : display(“ error tn‘) . dlsplay(:0) .
display(‘: unexpected "') . dIspIay(:1) . lastch(:2) .
display(“ . text skbped: ') . sItb(:2) . nt . taglall(transl(_)).U
    °/0% 0 proo_name, 1 bad_item, 2 Àrst_sklpped_char
sl<Ip('.') :wch(’.') . U
sl-tb(:0) :wch(:0) . rch . laslch(:1) . skb(:1) . U
% - - - - ~ - - - - - - - - - - - -
```

% a oomment extends till end_oI_lhe

oomment(:0, 11:1,

:1) : IseoIn(:0) . U

```prolog
    %% 0 eoln, 1 rest_ot_termrepr
oomment(:0,
          :0.:1,
               :2) : rch . lastoh(:3) . oomment(:3, :1, 2) . U
    %% 0 char, 1 termrepr, 2 rest_oI_termrepr, 3 nextchar
% - - - - - - - - - ~ - - - - - - -
% read a goal
olause(':’, ’:'.:0, :1, :2) : ‘I’ . ctaIl(':', :0, ’ ‘.’@‘.:1, :2) . U
    %% 0 termrepr, 1 rest_ot_termrepr, 2 sym_tab
```

% read an asserllon/n.|le

olause(:0, :1, :2, :3) :lten'n(:0, :4, :1,

’ ’.':'.:5,

:3) .

‘I’ . ctall(:4, 5, :2, :3) . U

```prolog
    %% 0 ltem1_Àrstch, 1 tem1repr, 2 rest_ot_tennrepr,
    %% 3 sym_tab, 4 otal|_Àrstoh, 5 mlddletennrepr
oIause(:0, _, _, _) : err(clause, :0) . |]
% - - - - - - - - - - - - - - - - -
% clause tall
ctall('.', ’ '.’[’.']‘.:0, :0, _) : ‘I’ . [1
    %% 0 rest_ol_termrepr
```

% rlghthaml slde ol a non-unit clause. or a goal

% eoln and blari-ts Inserted to make the output look tidy

ctall(':', :4.’

‘.20, :1, :2) : rdch(‘-') . ‘I’ . Iseoln(:4) .

rdchsl<(:3) . ctallauxm, :0, :1, :2) . U

```prolog
    %% 0 termrepr, 1 rest_ot_terrrrepr, 2 sym_tab,3 calls_tIrstch,
    %% 4 eoln
ctall(:0. _, _, _) : err(ctall, 1)) . U
```

% get the righthand slde ol a clause (errbedded oomments not displaced)

ctaIlaux('%‘, :0, :1, :2) :oomment(’%’, :0, ‘

'.:5) . ‘I’ .

rdchsklÀ) . ctallauxlÀ, :5, :1, -2) . [1 U'l-II-(D 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52

```prolog
%% 0 lerrnrepr, 1 rest_ot_termrepr, 2 sym_tab, 3 rest_lirstch,
```

<!-- page 267 -->
APPENDIX A.2 (Continued)

53

°/6% 5 mlddletermrepr 54

ctal|aux(:0, :1, :2, :3) :fterm(:0, :4, :1,

:3) . 55

Iterl'ns(:4, :5, :2, :3) . U 56

```prolog
%% 0 tterm_Ilrstoh, 1 termrepr, 2 rest_ol_termrepr,
```

57

```prolog
%% 3 sym_tab, 4 item\s_Ilrstoh, 5 rriddleterrrtepr
```

56

```prolog
% a IIst oI functor-temte (Ie calls)
```

59

items(‘), ‘ '.'[‘.']'.:0, :0, _) : ‘I’ . U 60

```prolog
%% 0 rest_oI_termrepr
```

61

```prolog
% eoInandbIarits-dotalI/2/
```

62

Iterms(‘,‘, :4.’

’.:0, :1, :2) : ‘I’ . Ise-oln(:4) . 63

rdchslt(i3) . ctaIIaux(3, :0, :1, :2) . U 64

```prolog
%% 0 termrepr, 1 rest_oI_termrepr, 2 sym_tab,3 ctaIl_lIrstoh,
```

65

‘I/0°/o 4 BOII1 66

Item's(:0, _, _, _) : err(ftemB, :0) . U 67

```prolog
% - - - - - - - - - - - - - - - - -
```

66

```prolog
%atunctor-term
```

69

Iterrn(:0, :1, “".:2, :3, :4): 70

Iderlt(:0, :5, :2, "“.:6) . ‘I’ . args(:5, :1, :6, :3, :4) . U 71

```prolog
%% 0 Id_Ilrstch, 1 lerrrinator, 2 terrnrepr,3 rest_oI_terrnrepr,
```

72

```prolog
%% 4 sym_lab, 5 Id_lermInator, 6 mlddleterrrtepr
```

73

```prolog
% Identlltersz words, I, quoted names, synbols
```

74

Ident(:0, :1, 11:2, :3) : 75

wordstart(:0) . rdch(:4) . abhanurns(:4, :1, :2, :3) . U 76

```prolog
%% 0 Id_llrstoh, 1 terrrlnator, 2tem1repr,
```

77

```prolog
%% 3 rest_ot_termrepr, 4 nextch
```

76

Ident('I', 1), 'I'.:1, :1) : rch . skpb(:0) . U 79

```prolog
%% 0 terrnlnator, 1 terrrrepr
```

60

ident("”, .1), :1, :2) : rdohtÀ) .qIderl(3, :0, :1, :2) . U 61

°/6% 0 lem1lnator, 1 temrepr, 2 rest_oI_terrnrepr, 3 nextoh 82

iderrt(:0, :1, :0.:2, :3): 83

syrnch(:0) . rdoh(:4) . sy|'riJol(:4, :1, :2, 3) . U 64

```prolog
%% 0 syrnb_Iirstoh, 1 lerrnlnator, 2 tennrepr,
```

65

```prolog
%% 3 resl_oI_termrepr, 4 nextch
```

66

```prolog
% quoted Identi¿ers
```

87

qldent("", :0, :1, :2) : 68

rdch(:3) . qtdentalllÀ, :0, :1, :2) . ‘I’ . U 69

```prolog
%% 0 termlnator, 1 termrepr, 2 rest_ot_termropr, 3 nextoh
```

90

qIdent(:0, :1, :0.:2, :3) : rdch(:4) .qIdent(:4, :1, :2, :3) . U 91 '

```prolog
%% 0 char, 1 lerrnlnator, 2 termrepr,
```

92

```prolog
%% 3 rest_oI_termrepr, 4 nextch
```

93

qIderlaIl(”", :0,

:2) : 94

rdch(:3) . qIdent(:3, :0, :1, :2) . |] 95

```prolog
%% 0 terrnlnator, 1 termrepr, 2 rest_oI_termrepr, 3 nextoh
```

96

qiderlail(_, :0, :1, :1) :skpb(:0) . U 97

```prolog
%% 0 terrnlnator, 1 rest_ot_lerrnrepr
```

96

% words and symbols

3bI‘I3l‘l.IlTB(IO, :1, :0.:2, :3): 99 100

alphanum(:0) . ‘I’ . rdch(:4) . abhanurns(:4, :1, :2, :3) . U 101

°/6% 0 an_alphanum, 1 terminator, 2 lennrepr, 102

°/6% 3 rest_oI_termrepr, 4 nextch 103

aIphanums(_, :0, :1, :1) :skpb(:0). U 104

```prolog
%% 0 terrrlnator, 1 rest_ot_lerrnrepr
                    2.59
```

<!-- page 268 -->
APPENDIX A.2 (Continued)

symboI(:0, :1, :0.:2,

:3)

syrnch(:0) . ‘I’ . rdch(:4) . symboI(:4, :1, :2, :3) . U

```prolog
        %% 0 a_synt>oIchar, 1 terrnlnator, 2 termrepr,
        %% 3 rest_oi_tennrepr, 4 nextch
syrnboI(_, :0, :1, :1) :skpb(:0). U
        %% 0 terrrlnator, 1 rest_ot_termrepr
```

% get argumert list: nothlng or a sequence oi temts in brackets

args(‘(‘, :0, ‘(‘.:1,

:2,

:3)

‘I’ . rdchsk(:4) .terms(:4, :1, :2, :3) . rdchslt(:0) . U

```prolog
        %% 0 nextch, 1 tem1repr, 2 rest_oI_terrnrepr,
        %% 3 sym_tab, 4 ten'ns_Iirstch
args(:0, :0, :1, :1, _) : U
        °/6% 0 nextoh. 1 rest_oI_tennrepr
```

% get a sequence oi temts

```prolog
tem1s(:0, :1, :2, 3) :terrn(:0, :4, :1, :5, inargs, :3) .
    termstaII(:4, ‘.5, :2, :3) . U
        %% 0 terrn_IIrstch, 1 temtrepr, 2 rest_ot_termrepr, 3 sym_tab
        °/6% 4 teminator. 5 mlddletermrepr
terrnstaiI(’)‘, ‘)‘.:0, :0, _) : ‘I’ . U
        %% 0 rest_ot_termrepr
                 . 2)
tem1staII(‘,’,
            ’.:0,:1
    ‘I’ . rdchsk(:3) .tem':s(:3, :0, :1, :2) . U
        %% 0 middletermrepr, 1 rest_oI_tem\repr, 2 sym_tab, 3 nextch
tem1staII(:0. _, _, _) : errltennstail, :0) . U
% - - -
```

% get a term (context used to Iorce brackets around Ilsts within lists)

**terrn(:0, :1, :2, :3, :4, 5) : t(:0, :1, 2, :3, :4, :5) . ‘I’ . U**

°/6% 0 tlrstch, 1 terminator, 2 termrepr,

```prolog
        %% 3 rest_oI_termrepr, 4 context. 5 sym_tab
          _, _, _) : err(term, :0) . U
terrn(:0, _, _
            '4) :varIable(:0, :1,
           nargs, :4) : Iist(:0, :1,
```

105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137

-"'§.NI“

:3, Iniist, :4) : Iist(:0, :1 -NPPP? “£5

-5.|"5§'-5:’-'5'ST

**06**

:4).U

tor negative numbers

```prolog
% a dirty pa
ti’-‘, :0, :1, :2, _, :3) :
    rdch(:4) . numberorItem1(:4, :0, :1, :
        %% 0 terrrlnator, 1 termrepr,
                             "N3..0:8i 9.1:: 6"rmrepr,
        %% 3 sym_tab, 4 nextch
        :3, _, _) : number(:0, :1, :2, :3) .U
          _, :4) : Iterm(:0, :1, :2, :3, :4) . U
a9<‘=-T-.‘=':~~99I'.1'_: ¿¿ 9
nurnberorItem1(:0, :1,
    digit(:0) . ‘I’ . nurrbe
                          :3) . U
                          r, 2 termrepr, 3 rest_ot_lermrepr
        %'yo 0 TIBXICII
numberortterm(:0, :1,
                 €;_&$355 @i§L
    symboI(:0, :5, :2, ““.:6) . args(:5, :1, :6, :3, :4) . U
        %% 0 nextoh, 1 terminator, 2 termrepr, 3 rest_oI_terrnrepr
        %% 4 sym_tab, 5 syrnboI_termInator, 6 middleterrnrepr
                  ‘I. ar;tart(:0) . aIphanums(:0, :1, :5,U).
t(:0, :1
t(:0, :1
t(:0, :1
```

136 139 140 141 142 143 144 145 146 147 146 149 150 151 152 153 154 155 156

```prolog
%~-
% get a variable
variabIe(:0, :1, :
             :
                :
                  :v
    tindv(:5,
          PP
              ‘a.u$.6- .i
```

<!-- page 269 -->
APPENDIX A.2 (Conrinned)

157

```prolog
%% 0 Iirstoh, 1 terminator, 2 lennrepr,
```

156

°/0% 3 rest_oi_tem\repr, 4 sym_tab, 5 name 159

Iindv(‘_‘.U, ‘_‘.:0, :0, _) : U

% no search: an anonymous variable 160

```prolog
%% 0 rest_oI_terrnrepr
```

161

Ilndv(:0, ':’.:1, :2, :3) : look(:0, 0, :4,

:3) . setn(:4, :1, :2).U 162

°/0% 0 name, 1 termrepr, 2 rest_oI_tem1repr, 3 sym_tab, 4 num 163

% look counts Irom 0 and Ilnds the position oi a name In the syn1tab 164

IooI<(:0, :1, :1, :0.:2) : U 165

```prolog
%% 0 name, 1 num, 2 syrntabtail
```

166

looi<(:0, '2, :1, _.."3) :sum(:2, 1, :4) . looi<(:0, :4, :1, :3) . U 167

```prolog
%% 0 name, 1 num, 2 ourrnum, 3 symtabtail, 4 GUl’I’t‘lUmpl.|$1
```

166

% set a number: no more than two digits (should be enough) 169

setn(:0, :1.:2,

:2) : ‘lee-s’(1), 10) . 170

ordohr(:3, '0') . surn(:3, :0, :4) .ordchr(:4, :1) . U 171

```prolog
%% 0 num, 1 char, 2 rest_oi_termrepr, 3 k, 4 kpiusnum
```

172

```prolog
setn(:0, :1, :2) : ’iess'(:0, 100) . prod(10, :3, :4, :0) .
```

173

setn(:3, :1, :5) . setn(:4, ".5, :2) . [1 174

°/6% 0 num, 1 termrepr, 2 rest_oi_termrepr, 175

```prolog
%% 3 nurnby10, 4 nummod10, 5 mlddletermrepr
```

176

setn(:0, _, _) : err(setn, .13) . U 177

```prolog
% - - - - - - - - - - - - - - - - -
```

176

```prolog
% get a list In square brackets
```

179

Iist(‘[’, :0, :1, :2, ii) : rdchsk(:4) . endIist(:4, :1, :2, :3) . 160

rdchsk(:0) . U 161

```prolog
%% 0 terrrlnator, 1 termrepr, 2 rest_oi_termrepr,
```

162

```prolog
%% 3 sym_lab, 4 nextch
```

163

endIIst('1‘, ‘[’.'1'.1J, :0, _) : U 164

```prolog
%% 0 rest_oI_terrnrepr
```

165

endIist(:0, :1, '2, :3) : 166

term(:0, :4, :1, ‘.’.:5, lnlist, :3) . ItaiI(:4, :5, :2, :3) . U 167

```prolog
%% 0 lirstoh, 1 lennrepr, 2 rest_ot_tem\repr,
```

166

```prolog
%% 3 sym_tab, 4 nextch, 5 middlelermrepr
```

169

ItaII(']', '['.'1'.:0, :0, _) :’I‘ . [1 190

```prolog
%% 0 rest_oi_termrepr
```

191

Itali(‘|‘, :0, :1, :2) :’I‘ . rdchsl-r(:3) . variable(:3.']'.1J,:1,:2).[1 192

°/0% 0 termrepr, 1 rest_oi_termrepr, 2 sym_tab, 3 nextch 193

italIi'.'. :0, :1, :2) : ‘I’ . rdchsiqÀ) . 194

terrn(:3, :4, :0, ‘.’.:5, iniist,

:2) . ltaIi(:4, :5, :1, :2) . U 195

```prolog
%% 0 termrepr, 1 rest_oi_termrepr, 2 sym_tab,
```

196

```prolog
%% 3 tem1_iirstoh, 4 nettch, 5 middleterrnrepr
```

197

ItaiI(:0, _, _, _) : err(Itail, :0) . U 196

```prolog
% - - - - - - - - - - - - - - - - -
```

199

% numbers: only natural ones 200

nurrber(:0, :1, :2, :3) :digIt(:0) . digIts(:0, :1, :2, 3) . U 201

```prolog
%% 0 Àrstch, 1 non_digit, 2 tennrepr, 3 rest_oi_termrepr
```

202

```prolog
dlgIts(:0, :1, :0.:2, .13) : dIgit(:0) .
```

203

‘I’ . rdch(:4) . dlgits(:4, :1, :2, :3) . U 204

```prolog
%% 0 iirstch, 1 non_digit, 2 lennrepr, 3 resl_ot_terrnrepr.
°/070 4 DBXICII
```

206

dIgits(_, :0, :1, :1) :skpb(:0) . U 207

```prolog
%% 0 non_digit, 1 rest_oi_termrepr
```

20s

```prolog
% - - - - - - - - - - - - - - - - -
```

<!-- page 270 -->
APPENDIX A.2 (Conlinned)

209

```prolog
% auxiliary tests
```

210

vvordstart(:0) :smaIIetter(:0) . U 211

varstart(:0) : blgietter(:0) . U 212

varstart(‘_’) : U 213

```prolog
% - - - - - - - - - - - - - - - - -
```

214

skpb(:0) : skbbl . Iastch(:0) . U 215

```prolog
% - - - - - - - - - - - - - - - - -
```

216

°/oOUIDI.i1lI'IOIl’8I'IS|81bI1 217

puttr(U) : ‘I’ . U 216

puttr(:0.:1) :vvch(:0) . puttr(:1) . U 219

putvamames(:0, _) :var(:0) . ‘I’ . nl . U 220

°/0°/o 0 sym_tab_end 221

putvamal'ne=s(:0.:1, :2) : nextIine(:2) .wch(‘ ‘) . dlspiay(:2) . 222

puttr(‘ ‘.:0) .woh(‘,‘) . surn(:2, 1, :3) . putvamames(:1, :3) . U 223

```prolog
%% 0 ourrname, 1 sym_tab_taiI, 2 currnum, 3 nextnum
```

224

nextllne(:0) : prod(6, _, 0, :0) . ‘I’ . ni . display(’

```prolog
%%') . U
```

225

```prolog
%% 0 a_rnultIpie_ot_Ilne_sIze
```

226

nextI|ne(_) : U 227

°/0°/o%IhO B|À°/o%% 226

**:dlspIay("'BO0TSTRAPPEFI" Ioaded.') . nI . see(user) . U I**

<!-- page 271 -->
APPENDIX A.3 Um Interface and Utilities

Interpreter oi Toy-Prolog - the Prolog part.

) COPYRIGHT 1963 - Fellrs Khznlak. Stanislaw Szpakowicz

institute oi lniomtatlce, Warsaw University

I I 0 0 I I O I Q I I I I O 0 I I 0 I I I I I I 0 0 I 0 Q I I n O O Q I Q Q Q Q I I I I I 0 0 0 I 0 I 0 0 I I I O O O O I I on

I Q O O Q Q I 0 O 0 I I I I 0 I I I I I I I I 0 n I Q I I O 0 I 0 O I 0 O I I I I I 0 I I 0 0 0 Q I O O O O I n n I O 0 O 0 II

interactive driver - top level

§§Ea?69E8?a9%9$

O O I I I I I O I I I I I I O I I O O O I I O I O

O O I I O O I I I I O I I O O O O I I I I I I O I I O I O Q I O I I I O I II

I I I I I I I 0 I I I I I I I I O I O O I O I I I I I I I I 0 I 0 I I 0 I I I I 0 O O I Q I

Q I I n I O I I I 0 I I I I I 0 II

```prolog
:- nl, dispiay('Toy-Prolog Ilstenlng:'), nl, tag(Ioop).
```

:- hait('Toy-Prolog, end oi sesslon.‘).

```prolog
loop :- repeat.
  dlsplay(’?- '), read(Term, Sym_tab), exeo(Tem1, Sym_tab), Iall
S1013
    2- I3QI&|l(I0Op).
exec(‘err', _) :- I.
```

%this oovers variables, too

```prolog
exec(:-(Goals), _)
              :-
                I, once(GoaIs).
exec(N,_)
        :- Integer(N),
                   I, num_clar.se.
exec(GoaIs. Sym_tab) :-
    call(Goals), nurrbervars(Goals, O,_),
    printvars(Sym_tab), enoudt,
                          I.
exeo(_, _)
        :- dlsplay(no), nl.
                          %l1caII(Goals) tails
enough :- rch, skipbl, lastch(Ch), rch, not(-(Ch, ‘:'l).
prIntvars(Sym_tab)
               :- var(Sym_tab), dlspIay(yes), nl,
                                        I.
prlntvars(Sym_tab)
               :- prvars(Sym_tab).
prvars(Sym_tab)
             :- var(Sym_tab),
                          I.
prvars([var(NarneStrlng, Instance) | Sym_tab_tail]) :-
    writetext(NameStn'ng), display(‘ - '),
    slde_eiIects(outt(Instance, ld(_, _), q)),
```

% this is equivalent to writeq(lrstance) but we avoid

% suporlluous calls on nunbervars - cl WRITE

nl, prvars(Sym_tab_taiI).

```prolog
num_clause :- dispIay(‘+++ A nurrber can“t be a cIause.'), nl.
```

% read a program upto end. (the only way to de¿ne user procedures)

% oonsultlreoonsult must be Issued Irom the terrnlnal, and it retums

```prolog
% there ( oonsult(user) is correct, too 1
oonsult(FIle)
          :- seelng(0IdF), reacbrog(Flie), see(OldF).
reconsul(FIle) :-
  redeline, seelng(OidF), reaq:>rog(Flie), see(OidF), redefine.
readprog(user) :- I, getprog.
readprog(FlIe) :-
              see(FIle), echo, getprog, noecho, seen.
```

% the actual lob is done by this procedure

```prolog
getprog :- repeat, read(T). asslrnIIate(‘l'), -(T.end), I.
```

jacoda-udum-bun:- 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50

```prolog
asstmIlate(‘e r r’)
             :- l.
```

<!-- page 272 -->
% a variable is erroneous. too APPENDIX A.3 (Continued)

```prolog
assimilate( -->(Leit, Right) )
                     :-
    I, tag(transI_ruIe(LeIt, Right, Clause)), assertz(Clause).
asslmiIate( :-(Goal))
                :- I, once(GoaI).
asslmilate(end)
            :-
              I.
assimilate(N)
          :- integer(N), I, num_clause.
```

% otherwise - store the clause

```prolog
assimiIate(Clause) :- assertz(Clause).
```

51 52 53 54 55 56 57 58 59 60

reading a term

$a\°$

```prolog
read(1')
      :- read(T, Sym_tab).
read(T, Sym_tab)
              :-
    gettr(T_Intemal, Sym_tab),
                        I, maketerrn(T_lntemal,1').
```

% ii gettr iails, then...

```prolog
read('err’,_)
           :-
```

nl, dispIay(‘+-I-+ Bad term on input. Text skipped: '), skip, nl.

% skip to the nearest lull stop not In quotes or in oomment

skip

```prolog
    :- lastch(Ch), wch(Ch), sklp(Ch).
skip(.)
       :- rch, lastch(Ch), e_skb(Ch),
                              I.
sklp(‘%') :- skip_commerl,
                     I, rch, skb.
skip(Q)
       :- isquote(Q), skip_s(0),
                           I, rch. skip.
skip(_)
       :- rch, skip.
% stop on a ‘layout’ character
e_skip(Ch) :- @-<(Ch, ‘ '1.
e_skIp(Ch) :- wch(Ch), rch, skip.
skip_commerlt :- repeat. rch, lastch(Ch), wch(Ch), lseoln(Ch),
                                               I.
isquote("").
             lsquote("").
‘/0
     HSIIIHQ
skip_s(Q)
        :- repeat, rch, lastch(Ch), wch(Ch), -(Ch, Q),
                                            I.
```

B'883$$2889 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99

```prolog
% IIIIIIIIIIZZIIIHIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
%
           p a r s e r
°/o IIIIIIIIIIIZIZIIIIIIIZIIZIIIIIIIIIIIIIIIIIIIIIIIIIIIZIIIIIIIIIIIIII
```

% This is an operator precedence parser Ior Prolog-10. g e t t r

% constructs the intemal representation oi a term. Next, m a k e-

% t e r m constructs the temt proper - see r e a d. Here is an In-

% Iorrnal description oi the underlying operator precedence grammar

% (each “rule“ corresponds to one clause oi r e d u c e). Sides are

% separated by --> and multiple righthand sides by OR.

```prolog
%
     t --> variable
                  OFI
                      integer
                            OR
                                string
```

100

°/o

I II)

IdBl'III1I8l’ 101

°/o

I II)

Id6l'III1IOI' ( I ) 102

I

```prolog
%
       --> U
             OFI
                 {}
```

<!-- page 273 -->
**APPENDIX A.3 (cÀliillltd)**

%

**t-->(t)**

**OFI [t]**

**OFI {t}**

%

t --> [ I I t ] %

**t --> t postiix_Iunctor**

0/0

I II) I Il'lIIX_IU|'BIOI'I %

**t --> preiix_Iunctort**

% Sequerces oi temts separated by commas - in rules 3, 5. 6 - will be % recognised as comma-temts (commas are iniix functors, covered by % rule 6). There are Àve types oi operators, vns(_), ld(_). % I1(_, _, _), br(_, _), bar: see the scanner. The temtinal symbol dot % never gets onto the stack. The temtinal symbol bottom is never re- % tumed by the scanner; it is only used to initiate and terminate the % main loop (p a r s e). The only nontemtinal syrnboi is t(_). % There are live types oi intemal represeriations (Args denotes the % represerlatlon oi argumerls - usually a comrna-term): %

```prolog
tr(Name, Args)
            - tor iunctor-terms.
```

%

```prolog
argO(X)
           - ior X a variable, atom, number, or stn'ng,
```

%

```prolog
bar(X, Y)
           - tor a list with Irom X and tail Y,
```

%

```prolog
tr1(Name, X)
            - Iorpreiix and post¿x Iunclors.
```

%

tr2(Name, X, Y) - Ior lniix functors. % A Name in tr mey be a bracket type. See r e d u c e (clauses 5, 6) % and makete rm iordetails.

% - - - get the intemal representation oi a term gettr(X, Sym_tab) :-

```prolog
gettoken(T, Sym_tab). PÀrse([bottom], T, X, Sym_tab).
```

% p a r s e takes 4 parameters: the current stack, the current token % Irom input, the variable used to bring the intemal representation %tothe suriace, andthe symboltabie (usedby getto ke n) parse([t(X), bottom], dot, X, _) :-

I. parse(Stack, Irput, X, Sym_tab) :-

```prolog
topterminaI(Stack, Top, Pos),
establish_precedence(Top, Irput, Pos, Rel, FITop, Filnput),
exch_top(Top, FITop, Stack, FIStack).
step(FIel, Fiinput, FIStack, NewStack, Newlnput, Sym_tab).
parse(NewStack, Newlrput, X, Sym_tab).
```

% the topmost terrninai will be covered by at most one nonterrninai % (the third parameter gives Top‘s position: 1 on the top, 2 covered) tootemtlnaltilu. Top I _l. Ton. 2)

1- ItopterminaI([Top | _], Top, 1).

% change the topmost terminal (applies only to mixed iunctors) exch_top(Top. Top, Stack, Stack) :-

I. exch_top(_, FITop. [t()()_ _|S]. [t(X), FITop |S1)

```prolog
:-
  I.
```

**exch_top(_, FITop, L I S1, [FITop | S1).**

% - - - periorrn one step: shift (stack the current token) or reduce step(lseq, Fiirput. Stadt, [Rlrput I Stack], Newlnput, Sym_tab) :-

I, gettoken(Newlnput, Sym_tab). step(gt, Filnput, Stack, NewStad<, Fiinput, _) :-

```prolog
reduce(Stack, NewStack),
                    I.
```

<!-- page 274 -->
APPENDIX A.3 (Coniinned)

155

% iail ii reduction Irrpossibie (parse and gettr will Iail, too - 156

```prolog
%
```

this iallure will be intercepted by gettr‘e caller) 157 156

% reduce top segment oi the stack according to the underlying grammar 159

```prolog
reduce([vns(X)
            | S],
                  [t(arg0(X))
                          1 S1).
```

160

redvceil Idtll

**I SI. ltlaro¿illl**

I SD- 161

**redvsÀllbrir. ‘0'l- lIX).brtl. '0'). ldlll I $1.**

162

**(t(tr(l. Xll**

**I Sil-**

163 redusÀilbrir. TYP9). br(l.TvPBl I $1. 164

IIIHYOOITYPBII

I $1)

1-

"OIHTYPB. ‘(I'll- 165

```prolog
%'U’ or ‘{}‘, see p, 2nd clause
```

**166 wdvcelibrtr. Tyne). IIXI. bI'(|-TYPBI**

**I Si.**

167

**ltltr(TrP@.Xll I SD-**

16B

**reduceilbrir. 1]‘). IIYI. bar. IIXI. br(l.’[i'l**

I $1. 169

[t(bar(X,Y))

| S1). 170

```prolog
reduce([I1(l,Type,_), t(X)
                    1 S],
```

171

[t(tr1(I, X1)

| S1)

```prolog
:-
```

172

```prolog
isrrpost1(Type).
```

173

```prolog
reduce([t(Y), I1(I, Type,_), t(X)
                        | S],
```

174

[t(tr2(l, X,Y))

| S1)

```prolog
:-
```

175

```prolog
isminI(Type).
```

176

```prolog
reduce([t(X), il(l,Type,_)
                    | S],
```

177

[t(tr1(I, X))

| S1)

```prolog
:-
```

176

Isl1'preI(Type). 179

```prolog
% otherwlseIalI(cI step)
```

160 161

%- - -auxiliary tests ior the parser 162

```prolog
ispreI(iy).
         lspreI(Ix).
```

163

```prolog
ispostI(yI).
         ISDO-SI'I(X1).
```

184 185 186 187

```prolog
isrnpreI(['i'Un])
           :- Isprei(TUn).
```

188

Ismprei(L, TUn])

```prolog
:- IspreI(TUn).
```

169

```prolog
isminI([‘i'Bln]) :- mer1'ber('i'Bln,[rriy,ybr,:rix]).
```

190

```prolog
isminI(L, _1).
```

191 192

```prolog
ismposti(1'TUn1)
            :- lspostl(TUn).
```

193

```prolog
ismpost1(L, TUn]) :- Ispost1(TUn).
```

194 195

% - - - establish precedence relation between the topmost 196

% temtinal on the stack and the cunent lrput terrnlnal 197

```prolog
estabiish_precedence(Top, Input, Pos, Rel, RTop, Rlrput)
                                          :-
    p(Top,I
            t,Pos,Rei0),
```

196

npu

Iinalize(Rel0. Top, Input, Rel, RTop, Rlnput),

I. 199 200 201

Iinalize(lseq, Top, Input, Iseq, Top, Input). 202

```prolog
linalize(gt, Top, input, gt, Top, Input).
```

203

Iinalize(lseq(RTop, Rlrput), _, _, Iseq, RTop, Rlnput). 204

```prolog
linalIze(gt(RTop, Rlnput). _, _, gt, RTop, Rlnput).
```

205 206 p(id(_), mu, '0'), 1, iseq).

**ms**

<!-- page 275 -->
APPENDIX A.3 (Continued)

207

```prolog
p(br(I, Type), br(r, Type), _, lseq).
```

206

```prolog
p(br(I, U), bar, 2, iseq).
```

209

```prolog
p(bar, br(r, U), 2, lseq).
```

210 211

```prolog
p(Top,lrput,1,gt)
               :-
```

212

```prolog
vns_Id_br(Top, r), br_bar(lnput, r).
```

21a

**P(T°P.I1(N.TlIPB3. Pl. 1. at(T=>r>. "IN. FITYP°$- Pill**

=- 214

```prolog
vns_ld_br(Top, r), restrIct(Types, [fx. IY]. RTypes).
```

215

```prolog
p(Top,lnput,1,lseq) :-
```

216

```prolog
br_bar(Top, I), vns_id_br(lmut, I).
```

**217 ntTen.ÀIN.Tvr>e=.Pl.Pos.lseqlT0p.ÀtN.HTvrm.Plll**

=- 216

```prolog
br_bar('l'op, I), pre_lnpost(Pos, Types, RTypes).
```

219

```prolog
p(I1(N, Types, P), Input, Pos, gt(ll(N, RTypes, P), Imut)) :-
```

22O

```prolog
br_bar(Input, r), post_lrpre(Pos, Types, RTypes).
```

221

**PIIIIN. TYP68. P). Input. 1. |99q(II(N.FITYP03.P). Irwin I-**

222

```prolog
vns_id_br(lnput, I),
               restrict(Types,[x'i,yI].RTypes).
```

223 224

%Iunctors with equal priorities 225

```prolog
p(I1(NTop, TeTop, P),I1(Nlrp,TsIrrp, P), Pos, Rel) :-
```

226

```prolog
ree_confi(TsTop, Tslrp, Pos, RTsTop, RTsIrp, ReI0),
```

227

I, do_rel(RelO, Ii(NTop, RTsTop, P), Ii(Nlnp, RTslnp, P), Rel). 226

```prolog
% different priorities
```

229

**r>lÀtNTer>. TsTop. PTor>l. ÀtNInr>. TellP- Plwl. Poe.**

230

```prolog
gt(Ii(NTop, RTsTop, PTop), i1(Nlrp, RTslnp, P|rrp)))
                                      :-
```

231

```prolog
slronger(PTop, PIFP).
                 I,
```

232

```prolog
restrlct(Tslrp, (ix. Ivl. FITeIrp),
```

233

pO6I_lt‘|prg(PO6. TeTop, RTsTop). 234

p(li(NTop, TsTop, PTop), li(NInp, Tslrp, PIIIJ). Pos, 235

```prolog
iseq(l1(NTop, RTsTop, PTop), l1(NIrp, RTelrp, Plrp)))
                                       :-
```

236

```prolog
stronger(Plnp,PTop),
                 I.
restrict(TsTop, (xi, yl], RTeTop),
pre_lrpost(Pos, Tslnp, RTslnp).
```

237 238 239 240 241

```prolog
p(_, dot, _, gt).
p(bottom, _, _, Iseq).
```

242

```prolog
% otherwise fail (p a r e e fails, too)
```

243 244

```prolog
vrls_Id_br(vns(_), _).
```

245

```prolog
vns_id_br(id(_), _).
vns_id_br(br(LeitRIght, _), LeitRIght).
br_bar(br(LeitRIght, _), LeItFIIghl).
br_bar(ba, _).
```

246 247 246 249 250 251

```prolog
stronger(Prior1, Prlor2) :- less(Prlor1, Prlor2).
```

252 253

```prolog
pre_lnpost(1, Types, RTypes)
                      :-
```

% the Iunctor trust be prefix 254

```prolog
reslrlct(Types, (xi, yi1, A),
```

**gig**

**restricts. lriv. vir. ml. FlTvr>e=l-**

```prolog
pre_irpost(2, Types, RTypes) :-
```

% the functor must not be prefix :2;

<!-- page 276 -->
F6811‘?!-'I(TV1568. III. Ill]. FIT!!!)FBI- APPENDIX A.3 (Continued)

259

```prolog
post_inpre(1, Types, RTypes) :-
```

% the functor must be postiix 260

```prolog
restricl(Types, (ix, fy], A),
```

261

```prolog
restrict(A, [xfy, yix, xix], RTypes).
```

262

```prolog
post_Inpre(2, Types, RTypes) :-
```

% the functor rnust not bepostiix 263

```prolog
restrict(Types, [xI, yl], RTypes).
```

264 265

% leave only those types that do not belong to RSet, 266

% tail ii this would leave no types at all (RSet 267

% contains only binary types, or only unary types) 266

```prolog
restrict([T1, RSet, (T1)
                :-
                  I, not(merrber(T, RSet)).
```

269

```prolog
restrict([TBin, TUn], RSet, [TBin])
                         :- mel'r|ber(TUn, RSet),
                                           I.
```

270

```prolog
restrict([TBin, TUn], RSet, [TUn])
                         :- men'ber(TBin, RSet),
                                           I.
```

271

```prolog
restrlct(Types, _, Types).
```

272 273

% compute relation for two functors with equal priorities; four cases: 274

```prolog
%
    both nom1aI, Top rnlxed, Input mixed, both rnlxed
```

275

```prolog
res_confl([Ti'op1, [Tlnp], Pos, [Tl'op], [Tim], ReI0) :-
```

276

I, I1_p(TTop,TInp, Pos, Rei0). 277

```prolog
res_coniI(1Ti'opBIn,‘I"I'opUn],[Tlnp], Pos, RTsTop,1TIrrp], ReI0) :-
```

276

I, I1_p(‘iTopBIn, Tirp, Pos, RelB), 279

```prolog
f1_p(TTopUn, Tlrp, Pos, RelU),
```

260

```prolog
match_reIs(RelB, ReIU, ReI0,‘iTopBin, 'iTopUn, RTsTop).
```

261

```prolog
res_confi([TI'op], 1TlnpBin, TInpUn], Pos, [TI'op], RTelrp, Rei0) :-
```

262

I, I1_p(‘iTop, TlnpBin, Pos, RelB), 263

I1_p(TTop, TlnpUn, Pos, ReIU), 264

```prolog
match_reIs(RelB, RelU, Rel0, TIrpBin, TIrpUn, RTsInp).
```

265

res_conil(1Ti'opBin,Tl'opUn],1'l'InpBin, TlnpUn], Pos, RTsTop, RTsinp 266

Rel0)

```prolog
:- I1_p(1‘l'opBin, TlnpBin, Pos, ReIBB),
```

267

I1_p(‘iTopBIn,TIrpUn, Pos, RelBU), 266

```prolog
l1_p(‘iTopUn,TlnpBin, Pos, ReIUB),
```

269

I1_p(‘iTopUn, TinpUn, Pos, RelUU), 290

res_mixed(RelBB, RelBU, RelUB, ReIUU, Rel0, 291

TTopBin, ‘lTopUn, TlnpBin, TInpUn, RTsTop, RTslnp),

I. 292 293

```prolog
do_rel(lseq, TopF, InpF, Iseq(TopF, InpF)).
```

294

```prolog
do_rel(gt, TopF, InpF, gt(TopF, InpF)).
```

295

```prolog
% fail II ReI0 - err
```

296 297

```prolog
match_reIs(Rel, Rel, Rel, TBin, TUn, [TBin, TUn]) :- I. % err Included
```

296

```prolog
match_reis(en, Rel, Rel,_,TUn,[TUn1)
                             :-
                               I.
```

299

```prolog
match_reis(Rei, err, Rel, TBin, _, [TBln])
                              :-
                                I.
```

300

```prolog
match_reIs(_. _, en, TBin, TUn, [TBin, TUn]).
```

301 302

res_mlxed(Rel0, Rel0. Rel0, Rel0, FleI0, 303

TTopBin, ‘iTopUn, TlnpBIn, TIrpUn, 304

['l'l'opBin, TTopUn], [TInpBin, TlnpUn]). 305

res_mixed(err, err, RelUB, ReIUU, Rel0. 306

```prolog
_, ‘iTopUn, TInpBIn,TInpUn,1'lTopUn], RTsInp) :-
```

307

```prolog
match_reis(ReIUB, ReIUU, Rel0, TInpBIn, TlrrpUn, RTsInp).
```

306

res_mixed(ReIBB, RelBU, err, err, Rel0, 309

```prolog
TTopBin, _, TlnpBin, TlnpUn, [Ti'opBin], RTslnp) :-
```

310

<!-- page 277 -->
match reis(ReiBB, ReIBU, Rel0, TInpBIn, TlnpUn, RTslnp). APPENDIX A.3 (Continued)

311

res_mixed(en, RelBU, err, ReIUU, Rel0, 312

TTopBin, TTopUn, _, TInpUn, RTsTop, |TlnpUn1)

```prolog
:-
```

313

```prolog
match_rels(ReiBU, ReIUU, Rel0, TTopBin, TTopUn, RTsTop)
```

314

res_mixed(ReIBB, err, ReiUB, err, Rel0, 315

```prolog
‘iTopBln,TTopUn,TlnpBln,_,RTsTop,['i'InpBin]) :-
```

316

```prolog
match_reis(RelBB, ReIUB, Rel0, TTopBin, TTopUn, RTsTop)
```

317

```prolog
res_mlxed(_, _, _, _, err, _, _, _. _, _, _).
```

316 319

% establish precedence relation for two (basic) types 320

```prolog
l1_p(‘i'i'op,TInp, Pos,lseq) :-
```

321

```prolog
merrber(Ti'op, [xiy, iy]),
                     % right_associative
```

322

```prolog
il_p_aux1(Pos, Tlnp),
                !.
```

323

I1_p(1‘l'op,Tlrp,Pos.gt)

```prolog
:-
```

324

```prolog
merrber(Tlnp, [yfx, yI1),
                     % Ielt_associative
```

325

I1_p_aux2(Pos, ‘iTop),

I. 326

```prolog
i1_p(_,_,_, en).
```

327 326

```prolog
i1_p_aux1(1, Tlrp)
              :- lspreI(TInp).
```

3323

```prolog
l1_p_aux1(2,Tlrp)
              :- merrber(Tlrp, [xiy, xi, xix]).
```

331

I1_p_aux2(1, ‘lTop)

```prolog
:- Ispos'li('lTop).
```

332

I1_p_aux2(2, ‘iTop)

```prolog
:- mernber(‘iTop,[yix,fx, x1x1).
```

333 334

°/o IIIIIIIIIIZIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII 335

```prolog
%
     intemal representation --->tem1
```

336

```prolog
% IIIIIIII!IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIZIZIIIIIIIZIIIIIIIIZ
```

337

```prolog
maketerm(arg0(X), X) :- I.
                       %variabIe, atom, nurnber,strlng
```

336

```prolog
maketenn(tr(‘()‘, RawTerm), T) :-
```

339

I, maketenn(RawTerm, T). 340

```prolog
maketem1(bar(RawLIst, RawTaII),T)
                           :-
```

341

I, maketen'n(RawTail, Tail), 342

```prolog
makeIist(RawUst, Tail, T).
```

343

```prolog
maketerm(tr('U’, RawLIst), T)
                      :-
```

344

I, makelIst(RawList, 'U‘,1'). 345

```prolog
maketenn(tr(‘()‘, RawArg), ‘{}‘(Arg)) :-
```

346

I, maketenn(RawArg, Arg). 347

```prolog
maketerrn(tr(Name, RawArgs), T) :-
```

346

I, makeIlst(RawArgs, ‘U’, Args), 349

-..(T, (Name | Args]). 350

```prolog
maketerm(tr2(Name, RawArg1, RawArg2), T) :-
```

351

I, maketem1(RawArg1,Arg1), maketerm(RawArp2.Arg2), 352

-..(T, (Name, Argt, Arg2]). 353

```prolog
maketerm(tr1(Name, RawArg), T) :-
```

354

```prolog
maketerm(RawArg.Arg), -..(T,[Name,Arg]).
```

355 356

% comma-term to dot-list-with-Tai 357

```prolog
makeIist(tr2('.'. RawArg, RawArgs), Tall, [Arg | Args]) :-
```

356

I, maketenn(RawArg, Arg). makeIist(RawArgs,TaII, Args). 359

```prolog
makellst(RawArg, Tail, [Atq | Tall1)
                          :-
                            rn-aketenn(RawArp, Atq).
```

<!-- page 278 -->
360 APPENDIX A.3 (Continued)

361

```prolog
%IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
```

362

```prolog
%
          e c a n n e r
```

363

```prolog
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
```

364

% this scanner retums six kinds ol tokens: 365

```prolog
%
     vns(_)
                   variables, nurrbers, strings
```

366

```prolog
%
     ld(Name)
                    atons
```

367

```prolog
%
     iI(Name, Types, Prior) ‘fix’ Iunctors
```

366

```prolog
%
     br(Which, Type)
                     brackets (lelt/right. ‘ll’/‘I1’/1}‘)
```

369

```prolog
%
     bar
                   | (in lists)
```

370

```prolog
%
     dot
                   . followed by a layout character
```

371 372

% - - - read a token and construct its intemal form 373

```prolog
%the lrx:tt.ttissupposedtobeposItioned
```

374

% over the first character oi a token (or preceding ‘white space‘) 375

```prolog
gettoken(Token, Sym_tab) :-
```

376

skipbl, Iastch(Startch), absotbtoken(Startch, Rawtoken), I. 377

maketoken(RawIoken, Token, Sym_tab), I. 376 379

% - - - read in a suitable sequence oi characters 360

% a word, le a regular alphanumeric identifier 361

```prolog
absotbtoken(Ch, ld([Ch | WordtaIl1)) :-
```

362

won:Istatt(Ch), getword(WorclaII). 383

‘yo 8 VHTIQDIB 364

```prolog
absorbtoken(Ch, var([Ch | Tall1)) :-
```

365

```prolog
vatstatt(Ch), getword(Tai).
```

366

% a solo character is a comma, a semicolon or an exclamation mark 367

```prolog
absorbtoken(Ch, ld([Ch])) :- solochar(Ch), rch.
```

**366 %abracket,le()[]{}**

369

```prolog
absor1:ttoken(Ch, br(Wh, Type)) :-
```

390

bracket(Ch), bracket(Ch, Wh, Type), rch. 391

```prolog
absorbtoken(‘|‘, bar) :- rch.
```

392

```prolog
% a string In quotes or In double quotes
```

393

```prolog
absotbtoken(““, qId(Qname)) :-
```

394

```prolog
rdch(Nextch), getstrlng("", Nextch, Qname).
```

395

```prolog
absorbtoken("", str(Strlng)) :-
```

396

```prolog
rdch(Nextch), getstrIng("‘, Nextch, String).
```

397

```prolog
% a positive nunber
```

396

```prolog
absorbtoken(Ch, nt.tm([Ch | Digits])) :-
```

399

```prolog
dlglt(Ch), getdlgls(DIgIts).
```

400

% a negative nurrber or a dash (possbly starting a syrrbol, see below) 401

```prolog
absotbtoken(-, Rawtoken) :- rdch(Ch), nt.tm_or_sym(Ch, Rawtoken).
```

402

```prolog
absotbtoken(., Rawtoken) :- rdch(Ch), dot_or_eym(Ch, Rawtoken).
```

**403 %asymboI,buIitoi.:-<->+/'?&$@l’_"**

404

```prolog
absorbtoken(Ch, ld([Ch | Syn-bs])) :- symch(Ch), getsym(Symbs).
```

405

% an embedded comment 406

```prolog
absotbtoken(’%’, Rawtoken) :-
```

407

skbcommert, lastch(Ch), absotbtoken(Ch, Rawtoken). 406

```prolog
% this shouldn't happen:
```

409

```prolog
absorbtoken(Ch, _) :- dlspIay(errInscan(Ch)), nl, fail.
```

410 41 1

```prolog
num_or_sym(Ch, num([-, Ch | Dlgits])) :-
```

412

```prolog
dlglt(Ch), getdlgls(Dlgits).
```

<!-- page 279 -->
APPENDIX A.3 (Continued)

413

```prolog
num_or_sym(Ch, id([-, Ch 1 Syn'l:s])) :- symch(Ch), getsym(Syn'bs)
num_or_sym(_, id([-1)).
```

416

% layout characters precede ’ ‘ in ASCII 417

```prolog
dot_or_sytn(Ch, dot) :- @-<(Ch, ‘ ').
                            ‘I6 no advance
```

416

```prolog
dot_or_eym(Ch, id([., Ch | Symbs])) :- symch(Ch), getsyrn(Syrrbs).
```

**£3**

```prolog
dot_or_sym(_, Id([.1)).
```

421

```prolog
skbcommert :- Iastch(Ch). BeoIn(Ch). skipbl. I.
```

422

```prolog
skipcommert :- rch, skipcomrnerl.
```

423 424

```prolog
% - - - auxiliary Input procedtxes
```

425

% read an abhanumerlc identi¿er 426

```prolog
getword([Ch | Word1) :-
```

427

```prolog
rdch(Ch), aIphartum(Ch), I, getwordtword).
```

428

```prolog
getword(U).
```

429 430

% read a sequence ol digits 431

```prolog
getdIgls([Ch | Digltsl) :-
    rdch(Ch), dlglt(Ch), I, getdlgls(DlgIis).
getdIgIs(U).
% read a symbol
ttsislrrttili?-I1 I Svmbsll =-
```

432 433 434 435 436 437

```prolog
rdch(Ch), sytnch(Ch), I, getsym(Syn'l:s).
```

**¿g**

c@tBvmiI]l-

440

% read a quoted id orstrlng (Dellrn B either ’ or '1 441

```prolog
getstrlng(Deilm, Dellrn, Str) :-
```

442

I, rdch(Nextch), twodeIIms(DeIIm, Nextch, Str). 443

```prolog
getstrlng(DelIm, Ch, [Ch | Strl) :-
```

444

```prolog
rdch(Nextch). 99Istrlng(DeIlm, Nextch, Str).
```

445

```prolog
twodellms(DeIIm, Delim, [Delim 1 Str]) :-
```

446

I, rdch(Nextch), getstrlng(Dellm, Nextch, Str). 447

```prolog
twodelims(_, _, U).
               %cIose the list
```

446 449

```prolog
% - - - auxiliary tests
```

450

```prolog
wordstart(Ch) :- smalIetter(Ch).
```

451

```prolog
varstart(Ch) :- blgletter(Ch).
```

452

```prolog
vars1art(‘_’).
```

45s

```prolog
btacket(‘(’, t, '()').
                breoket(')‘, r, '()').
```

454

```prolog
bracket('[’, t, 11').
                bracket(1’, r, 1]).
```

4552

```prolog
bracket(‘(’, I, '{)').
                 bracket(‘)‘, r, '{)').
```

457

% - - - translonn a raw token Irtto its final form 456

```prolog
maketoken(var(Namestrlng), vns(Ptr), Sym_tab) :-
```

459

```prolog
makeptr(Namestring, Ptr, Sym_tab).
```

460

```prolog
maketoken(k:I(Namestring), Token, _) :-
```

461

```prolog
pname(Name, Namestrlng), make_iI_or_k:i(Name, Token).
```

462

```prolog
maketoken(qld(NanlestrlÀe). id(Name), _) :-
```

463

```prolog
pname(Name, Namestrlng).
```

464

```prolog
maketoken(rum([- 1 DigIts]), vns(N). _) :-
                           2'7]
```

<!-- page 280 -->
APPENDIX A.3 (Continued)

465

```prolog
pnamei(N1, Digits), sum(N, N1, 0).
```

466

```prolog
maketoken(mm(Digits), vns(N), _) :- pnameI(N, Digits).
```

467

```prolog
maketoken(str(Chars), vns(Chats), _).
```

466

```prolog
maketoken(Token, Token, _).
```

% br(_,_) and bar and dot 469 470

% variables are kept In a syrnboi table (an open IBI) 471

```prolog
makeptr([’_’], _, _).
```

%no search - an anonymous variable 472

```prolog
makeptr(Nmstr, Ptr, Sym_tab) :- iook_var(var(Nmstr, Ptr), Sym_tab)
```

473 474

```prolog
% look-up
```

475

```prolog
look_var(ltem, [Item | Sym_tab]).
```

476

```prolog
look_var(ltem, L I Sym_tab]) :- look_var(ltem, Sym_tab).
```

477 476

```prolog
make_I1_or_ld(Name, Ii(Name, Types, Prlor)) :-
```

479

‘FF‘(Name, Types, Prior),

I. 460

make_I1_or_k:I(Name, Id(Name)). 461 462

°/o IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIZIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII 463

```prolog
%
```

grammar rule preprocessor 464

```prolog
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
```

465

```prolog
transI_t'ule(Lelt. Right, Clause) :-
```

466

```prolog
two_ok(Leit, Right),
```

467

```prolog
lsolate_Ihs_t(Left, Nont, Lhs_t),
```

466

```prolog
oonnect(Lhs_t, Ot.ttpar, Finaivar),
```

469

```prolog
expand(Nont, Inltvar, Outpar, Head),
```

490

```prolog
makebody(RIght, Inltvar, Finalvar, Body, AIt_Àag).
```

491

```prolog
do_clause(Body, Head, Clause).
```

492 493

```prolog
do_cIause(true, Head, Head) :-
                        I.
```

494

```prolog
do_clause(Body, Head, :-(Head, Body)).
```

495 496

% Lhs_t is a list (possibly enpty) oi leithand side tem'tinaB 497

```prolog
isoIate_Ihs_t(‘,‘(Nont, Lhs_t), Nont, Lhs_t)
                              :-
```

496

‘;‘(nonvarint(Nont), ruienor(varint)), 499

‘;‘(isclosedlist(Lhs_t), ruIerror(ter)),

I. 500

```prolog
isoIate_lhs_t(Nont, Noni, U).
```

501 502

```prolog
%fail II notaclosed list
```

503

IscIosedilst(L)

```prolog
:- check(BcII(L)).
```

504

```prolog
lscII(L)
      :- var(L),
             I, lail.
```

505

```prolog
lscIl(U).
```

506

Iscli(L | L1)

```prolog
:- BclI(L).
```

507 506

% connect terminals to the nearest nontem'tInal’s input parameter 509

```prolog
% (actually, ‘open’ a closed list)
```

510

```prolog
connect(U, Nextvar, Nextvar) :-
                        I.
```

511

```prolog
connect(lTsym | Tsyms]. ['l'sym | Outpar], Nextvar)
                                     :-
```

512

```prolog
oonnect(Tsyt'ns, Outpar, Nextvar).
```

% In altematives. each righthand slde B preceded by a dummy 513 514

% - - - translate the righthand slde (loop over altematives) 515 516

% nontenninal, as defined by

‘ch.tmmy' --> U.

<!-- page 281 -->
(sirtce temtinals APPENDIX A.3 (Continued)

517

% are appended to lrput parameters, the lrput parameter of a common 516

% leithand side must be a variable) 519

makebody(‘;‘(Alt, Alts), Inltvar, Finalvar. 520

‘;‘(‘,‘(‘ dummy’(InItvar, Nextvar), AIt_b), AIt_bs), _)

```prolog
:-
```

521

I, two_ok(AIt, Alts), 522

```prolog
makerigix(AIt, Nextvar, Finalvar, AIt_b),
```

523

```prolog
makebody(Aits, Inltvar, Finalvar, Alt_bs, alt).
```

524

```prolog
makebody(Right, Inltvar, Finalvar, Body, AIt_fIag) :-
```

525

```prolog
var(Alt_Ilag),
          I,
```

% only one altemative 526

```prolog
makerigix(Right, Inltvar, Finalvar, Body).
```

527

makebody(Right, lnitvar, Finalvar, 526

```prolog
‘,‘(‘dummy‘(Initvar, Nextvar), Body), alt) :-
```

529

```prolog
makerlgix(Right, Nextvar, Finalvar, Body).
```

530 531

% - - - trarslate one altemative 532

```prolog
makerigix(‘,‘(ltem, Items), Thispar, Finalvar, T_item_items) :-
```

533

I, two_ok(ltem, items). 534

```prolog
transI_ltem(item, Thispar, Nextvar, T_item),
```

535

makerlgix(ltems, Nextvar, Finalvar, T_itemsl. 536

```prolog
conbIne(T_ltem, T_itenB, T_item_ltems).
```

537

makerlgl'I(ltem, Thlspar, Finalvar, T_item)

```prolog
:-
```

536

```prolog
transl_Iiem(ltem, Thispar, Finalvar, T_item).
```

539 540 541

```prolog
conbIne(true, T_ltems, T_item)
                        :-
                          I.
cornbIne(T_ltem, true, T_item) :-
                         I.
```

542

cot'nbine(T_item, T_IIenB, ‘,‘(T_ltem, T_ltems)). 543 544 %---translate one item (sure tobeafunclor-temt) 545

```prolog
transl_ltem(Ten'ninals, 'I'hlspar, Nextvar, true)
                                 :-
```

546

Bciosediist(Tenninals), 547

I, connect(TennlnaIs, 'I'hBpar, Nextvar). 546

% conditions (the out and others) 549

```prolog
transI_item(I, ThBpar, Thlspar, I)
                        :-
                          I.
```

550

```prolog
transI_ltem(‘{}‘(Corxl), 'i'hispar, Thlspar, call(Corxl))
                                      :- I.
```

551

°/abadlist of tem1inaB (missed the ¿rst clause) 552

```prolog
transl_item(L|_1, _, _,_)
                   :- t'ulerror(ter).
```

553

```prolog
%a nested altemative
```

554

```prolog
transl_ltem(‘:‘(X, Y), ThBpar, Nextvar, Trarsl) :-
```

555

I, makebody(’:‘(X,Y)_ThBpar,Nextvar,Transl,_). 556

```prolog
%finaliy,aregularnontem1lrtal
```

557

```prolog
Il'3i‘L5|_II6l'l1(NOI'II, Thispar, Nextvar, Transl) :-
```

556

```prolog
expand(Nont, Thlspar, Nextvar, Trartsl).
```

559 560

% add input parameter and output parameter 561

```prolog
expand(Nont, In_par, Out_par, Call) :-
```

562

-..(Nont, [Fun | Args]), ¿g

-..(CalI, [Fun, In_par, Out_par | Args]).

565

```prolog
% - - - error handling
```

566

```prolog
two_ok(X,Y) :- nonvarht(X), nonvarht(Y),
                                 I.
```

:3;

two_oI<(_, _)

```prolog
:- mlerror(varint).
```

<!-- page 282 -->
APPENDIX A.3 (Continued)

see

```prolog
ruterrorwtsssaoel :-
```

570

nl, dBpIay(‘+++ Error In this rule: '), mes(Messa09). nl, 571

```prolog
tagiaIl(trarBI_rule(_, _, _)).
```

572

% diagnostim are only very brief (and not too informative ...) 573

```prolog
mes(varlnt) :- display(’variable or Integer ltem.’).
```

574

```prolog
mes(ter)
         :- dIsplay('terrnlnaIs not on a closed iBt.’).
```

575 576

```prolog
% - - - Initiate grammar processing
```

577

```prolog
phrase(Nortt, TennlnaB) :-
```

576

```prolog
nonvarht(Nont),
             I,
```

579

```prolog
expand(Nont, TermlnaB, U, Init_caII),
```

560

```prolog
calI(InII_caIl).
```

561

```prolog
phrase(N,T)
          :- error(phrase(N,T)).
```

562 563

‘ch.tmmy‘(X, X). 564 $5

```prolog
% IIOIIOI-IIIOIOIOOIQOIIIIOIQOIIIOOI
```

586

```prolog
        % IIOIIOIIIIIOIIIIIIIIOOIOIOOIOIOIOIO
        %
              I I b r a r y
        % IOIIIOIIOIOOIOIIIIIOIIIOIOOIIIOIO
        % IIOOIIOIQOIIIOIIIQOIOI-QOIOOOI-QOIOO
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
%
        -.. (readas“unIv')
  I u I u u I u I I u I I I I I u u O O O u O I O u u I O u u O u u u u u I I u I I u I u u I u u I I I I I u u I I u u I u u u nu
  I u I I u u I u I u u I u u u I I u u I u I O u I O u O u I Q u Q u O O u I u I u u I u u u u u I u I u I u u I u I u I u u I II
```

567 566 569 590 591 592

```prolog
%
```

593

-..(X,Y)

```prolog
:- var(X), var(Y), I, error(-..(X,Y)).
```

594

```prolog
-..(Num,[Num1) :- Integer(Num),
                         I.
```

595

-..(Tenn, [Fun1Args1)

```prolog
:-
```

596

```prolog
setarlty(Tenn, Args, N),
```

597

```prolog
iunctor(Tenn, Fun, N),
```

% this works both ways 596

```prolog
not(integer(Fun)),
                    %we don't wanteg 17(X)
```

599

```prolog
setargs(Tenn, Args. 0, N).
```

%this works both ways,too 600

```prolog
setarity(Term, Args, N)
                  :- var(Tenn),
                            I, length(Args, N).
    %notlcethatbadArgsgiveanerrorIn length
setarity(_,_,_).
              %AritywIIIbesetby functor in-..
```

601 602 603 604 605

% both numeric parameters are given, 606

% the loop stops when the third reaches the fourth 607

```prolog
%(worIt.sbothwaysbecause a rg does)
```

606

```prolog
setargs(_, U, N, N) :-
                 I.
```

609

```prolog
setargs(Ten'n, [Arg 1 Args1, K, N)
                        :-
```

610

```prolog
sum(l<, 1, K1), arg(I(1, Tert'n, Arg),
```

611

```prolog
setargs(Tenn, Args, K1, N).
```

612 613

% find the length of a closed list; error ll not closed 614

```prolog
length(LBt, N)
           :- length(LBt, 0. N).
```

615 616

% this is a tall-recursive lomtulatlon oi length 617

```prolog
length(L,_, _) :- var(L), t, error(length(L, _)).
```

616

```prolog
Iength(U, N, N) :-
              I.
```

619

Iength(L|Llst],l(,N)

```prolog
:-
```

620

<!-- page 283 -->
I, sum(K,1,l<1), length(LIst,l<1,N). APPENDIX A.3 (Continued)

621

Iength(Blzarre,_,_)

```prolog
:- error(Ierqth(Bizane,_)).
```

622 623

%blnd every variable to adBtlnct 'V’(N) 624

```prolog
nunbervats('V‘(N), N, NextN)
                      :- I, sum(N,1,NextN).
```

625

```prolog
nunbervats(‘V'(_), N, N) :-
                     I.
```

626

```prolog
nun'betvars(X, N, N) :- lnteger(X), I.
```

627

```prolog
nun'bervats(X, N, NextN) :- nurnbervars(X, 1, N, NextN)
```

626 629

```prolog
nurrbervars(X, K, N, NextN) :-
```

630

```prolog
arg(K, X, A), I, nurrbervars(A, N, MIdN),
```

631

```prolog
sum(K,1,K1), nut'nbetvars(X,K1,MIdN,NextN).
```

632

```prolog
nurrbervars(_, _, N, N).
```

633 634

```prolog
% ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
```

635

```prolog
%
     predeiIned'ilx" iunctorsand op
```

636

```prolog
% ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
```

637

% (ordered according to probable frequency) 636

‘FF‘(‘,’,[xiy], 1000). 639

```prolog
‘FF’(:- , 1xix, ix], 1200).
```

640

'FF'(';',[xl‘y], 1100). 641

‘FF’(not, [fy],

900). 642

’FF'(- ,[xix1, 700). 643

‘FF‘(B,[xix1, 700). 644

‘FF‘(->,[xix],1200). 645

’FF'(+ ,1yIx,ix], 500).

’FF'(- ,1yix,ix], 500). 646

‘FF'(’ ,[yix], 400).

'FF’(l ,[yix1, 400). 647

'FF‘(mod.[xix], 300). 646

‘FF’(< ,[xix], 700).

‘FF’(-< , [xfx], 700). 649

```prolog
‘FF’(:- ,[x1x], 700).
                     ‘FF’(:- ,[x1x], 700).
```

650

'FF’(-:-,[xfx], 700).

‘FF'(--,[x1x], 700). 651

‘FF’(@<,[xix], 700).

‘FF‘(@-<, [xix], 700). 652

‘FF‘(@> , [xix], 700).

'FF'(@>-, [xix], 700). 653

‘FF'(-.., [xix], 700). 654

‘FF'(--,[xix], 700).

'FF'(--, [xix], 700). 655 656

% thB Inplemerlatlon of op takes care oi redeflnlions 657

% and oi mixed Iunclots 656

```prolog
op(Prlor, Type, Name) :-
```

559

8I0"\(N&t'ne). pname(Name, String), noq(String), 660

```prolog
% noq - see WRITE
```

661

Integer(Prior), less(0, Prior), less(Prlor, 1201), 662

```prolog
set_klnd(Type, Kirxi),
                I,
```

663

```prolog
do_op(Prior, Type, Name, Kind).
```

% Ii not all parameters are OK -

```prolog
op(P, T, N)
         :- error(op( P, T, N )1.
```

664 665 666 667 668

% set Kind to bin or un

```prolog
set_klnd(Type, bin) :- blnary(Type, _),
                             I.
```

669

```prolog
set_klnd(Type, un) :- unary(Type, _, _),
                              I.
```

670 671

% test lor binary and instantiate Assoc 672

binarylxiy, a(r)).

```prolog
% right associative
             2'75
```

<!-- page 284 -->
APPENDIX A.3 (Continued)

```prolog
unary(xI, post, na(I)).
                    % left non-associative
```

673

```prolog
binary(yfx, a(I)).
              % lelt associative
```

674

binarylxix, na(_)).

```prolog
%
   non-associative
```

675

% test for unary, instantiate Kind and Assoc 676

```prolog
unary(fy, pre, a(r)).
                   % right associative
```

677

```prolog
unary(fx, pre,na(r)).
                    %rlght non-associative
```

676

unarytyf. post, a(l)).

```prolog
% left associative
```

679 680 681

```prolog
do_op(P, T, N, Kind)
                :-
```

662

‘FF‘(N, Oidtypes, Oidprior),

I, 663

```prolog
addii(Oidtypes, Oldprior, P, T, N, Kind).
```

664

```prolog
do_op(P, T, N, _)
              :- assertz(‘FF'(N, [T1, P1).
```

665 666

% add or redeline a functor 667

% for rnlxed functors, keep the binary type before the unary 666 669

% the same priority: redefine or make mixed 690

```prolog
addlf([Oidtype], P, P, T, N, Kind) :-
```

691

I, set_kind(0ldtype, Oldkind), 692

```prolog
addff1(0Iclkind, Kind, Oidtype, T, N, P).
```

693

```prolog
addlf([OIdtype1, 0ldtype2], P, P, T, N, Kind)
                                 :-
    I, addii2(Kind, Oldtypel, OIdtype2, T, P, N).
```

694 695

% otherwise the priorities were diiierent: redefine 696

addi’l(_, _, P, T, N, _) ;- redel1(N,1T1, P). 697

% make a mixed iunctor or change type

```prolog
addlf1(un, bln, Oidtype, T, N, P)
                        :-
                           rnk mixed(N, [T, Oldtype], P).
```

696 699

```prolog
addii1(bin. un, Oidtype, T, N, P)
                        :-
                           mk_mixed(N, [Oidtype, T1, P).
```

700 701

```prolog
addil1(KInd, Kind, _, T, N, P)
                      1- redef1(N,1T1, P).
```

702 703

```prolog
retract(‘FF‘(N, _, _)),
                I, assertz(‘FF'(N, Types. P1).
```

% adjust a mixed functor by changing one ol its types 704

```prolog
addlf2(bin, _, OIdtype2, T, P, N)
                        2- t'r|k_mIxed(N, [T, Oldtype2], P)
```

705

```prolog
addii2(un, Oldlypet, _, T, P, N)
                        :- rnk_mIxed(N, [Oldlype1, T], P).
```

706 707

```prolog
mk_rnixed(N, Types, P)
                  :-
```

708 709 710

% redeline and issue a waming 711

```prolog
redeI1(N, T, P) :-
```

712

nl, dispIay(1unctor"), display(N), 713

display(‘ redefined’), nl, 714

```prolog
retract(‘FF‘(N, _, _)),
                I,
                  assetta(‘FF‘(N, T, P)).
```

715 716

```prolog
% remove adeclaratlon
```

717

```prolog
delop(Name)
          :- atom(Name), retract(‘FF‘(Name,_, _)),
                                         I.
```

716

```prolog
delop(Name) :- enor(delop(Name)).
```

719 720 721

```prolog
%IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIZIIIIIIIIIIIIIIIIII
```

722

```prolog
%
```

evaluate an arithmetic expression 723

‘YoIIIIIIIIIIIIIIIIIIIIIIIIZIIIIIIIIIIIIIIIIIIIIIIII1211211II§IIIIII 724

```prolog
is(N,N)
       :- integer(N),
                 I.
```

<!-- page 285 -->
APPENDIX A.3 (Continued)

725

```prolog
is(Val, +(A, B))
            :-
```

726

I, Is(Av, A), Is(Bv, B), surn(Av, Bv, Val). 727

```prolog
is(Val, -(A, B))
           :-
```

72B

I, is(Av, A), i5(Bv, B), surn(Bv, Val, Av). 729

```prolog
is(VaI, '(A, B))
           :-
```

730

I, Is(Av, A), i5(Bv, B), prod(Av, Bv, O, Val). 731

Is(VaI,l(A, B))

```prolog
           :-
    I, Is(Av, A), Is(Bv, B), prod(Bv, Val, _, Av).
is(Val, rnod(A, B )
              :-
```

732 733

) 734

I, Is(Av, A), ls(Bv, B), prod(Bv,_, Val, Av). 735

```prolog
is(VaI, +(A))
          :-
            I, Is(Val, A).
```

736

```prolog
is(Val, -(A))
         :-
           I, Is(Av, A), sum(Val, Av, O).
```

737

Is(N, [N])

```prolog
:- InIeger(N).
```

738

```prolog
%otherwise I all
```

739 740

```prolog
% - - - - - - EVALUATE AN ARITHMETIC RELATION - - - -
-:-(X,
        I‘
              X), Is(XV,
```

742

<(X,Y)

```prolog
:-
  Is(XV, X), Is(YV,Y), Iess(XV,YV).
```

743

-<(X, Y)

```prolog
:-
   Is(XV,X), is(YV,Y), noI(Iess(YV,XV)).
```

744

>(X,Y)

```prolog
:-
   Is(XV, X), is(YV,Y), Iess(YV, XV).
```

745

>-(X,Y)

```prolog
:-
  is(XV,X), i5(YV,Y), not(I0ss(XV,YV)).
```

746

--(X, Y)

2- not(-:-(X, 747 748

```prolog
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
```

749

```prolog
%
       perlect equaity oItem1s
```

750

```prolog
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
```

751

**--(T1, T2)**

```prolog
         :-
           var(T1), var(T2),
                         I, eqvar(T1, T2).
II(T1,
         I‘
           dm(-I?(T1,
```

753 754

III(T'|,T2)

2- l'lOI(III?(T1,T2)). 755 756

II?(T1,T2)

I- 757

**Ir|toger(T1), Intoger(T2), I, -(T1, T2).**

756

```prolog
--?(T1,T2) :-
```

759

```prolog
nonvarint(T1), nor|varhl(T2),
```

760

Iunctor(T1, Fun, Arity), Iunclor(T2, Fun, Arity), 761

```prolog
equaIargs(T1, T2, 1).
```

762 763

```prolog
equaIargs(T1, T2, Argnumber)
                       :-
```

764

```prolog
arg(Argnurrber, T1, Arg1), arg(Argnurnber, T2, Arg2)
```

765

% arg IaIIs given too largo a number 766

I,

II(A.I'g1, N52).

Q-||'|xA|'gl'I.l|'|'&l', 1, NBXI|'I.||'|'bB'l')| 767

```prolog
equaIargs(T1, T2, Nextnumber).
```

723

```prolog
equalargs(_, _, _).
```

770

```prolog
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
```

771

```prolog
%
   assert, asserla, assortz, retract, clause
```

772

```prolog
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
```

773

```prolog
%- - -addaclause(usIng buiit-In assert(_, _, _))
```

774

```prolog
asserl(CI)
        :- assona(Cl).
```

775

```prolog
assena(CI) :-
```

776

```prolog
nonvarht(CI), c:onverl(Cl, Head, Body),
                             I.
```

<!-- page 286 -->
APPENDIX A.3 (Continued)

777

```prolog
sssert(Head, Body, 0).
```

776

```prolog
asse|1a(Cl) :-
           error(asse|1a(Cl)).
```

779 760

```prolog
assertz(C|)
         :-
```

761

```prolog
nonvarint(Cl), convert(C|,Head,BOdy).
                             I,
```

762

```prolog
sssert(Head, Body, 32767).
                       %Ie 2 to 15th mlnus1
```

763

```prolog
assertz(Cl)
         :- error(assertz(CI)).
```

764 765

```prolog
% convert the extemal1ormoIaBodylnto adotted llst
```

766

```prolog
convert(:-(Head, B), Head, Body)
                         :- conv_body(B,Body).
```

767

```prolog
convert(Unl_cI, UnIt_cl, |]).
```

766 769

% this procedure works both ways 790

```prolog
conv_body(B, [caI|(B)])
                 :- var(B),
                         I.
```

791

cor|v_body(trus, []). 792

```prolog
conv_body(B, Body)
                :- conv_b(B, Body).
```

793 794

```prolog
conv_b(B, [Body1)
              :- var(B),
                      I, conv_calI(B, Body).
```

795

```prolog
conv_b(','(C, B), [Call | Bodyl)
                      :-
```

796

I, conv_cal|(C, Call), conv_b(B, Body). 797

```prolog
conv_b(CaII, [CaIl]).
                % not avarisble
```

796 799

% Interpreter can process varlable calls only within c a I I 600

conv_cal|(C, call(C))

```prolog
:- var(C),
        I.
```

601

```prolog
conv_caII(C, C).
```

602 603

```prolog
% - - - remove a clause (thls procedure Is backtrackable)
```

604

```prolog
retract(C|)
        :-
```

605

nonvar'nt(Cl), convert(C|, Head, Body),

I, 606

```prolog
    lunctor(Head, Fun, Arity), rsmcls(Fun, Arity, 1, Head, Body)
retract(CI)
        :- error(retract(CI)).
```

B07 B08 B09 810

```prolog
% ultimate Iallure It N too big (retractl3 tails)
remcks(Fun, Arlty, N, Head, Body) :-
```

611

```prolog
clause(Fun, Arlty, N, N_head, N_body),
```

612

```prolog
remcIs(Fun, Arity, N, N_head. Head, N_body, Body).
```

613

```prolog
remcks(Fun, Arity, N, Head, Head, Body. Body) :-
    retract(Fun, Anty, N).
% user's backtracking resumes r e t r a ct here
rerncls(Fun, Arlty, N, N_head, Head, N_body, Body) :-
    checl-t(-(N_hsad, Head)). check(-(N_body, Body)),
```

614 615 616 617

% (after removing the Nth clause the next becomes Nth) 616 619 620

I, remcls(Fun, Arlty, N, Head, Body).

```prolog
remcIs(Fun, Arlty, N, _, Head, _, Body)
                             :-
    surn(N, 1, N1), remcIs(Fun, Arity, N1, Head, Body).
```

621 622 623 624

% - - - generate nondeterrnlnlsttcally all clauses whose head 625

```prolog
%
```

**andbodymatchthe parametersot clause**

626

```prolog
c|ause(Head, Body) :-
```

627

nonvarIr|t(Head),

I, Iunctor(Head. Fun, Arity), 626

```prolog
gencIs(Fun, Arity, 1, Head. Body).
```

<!-- page 287 -->
APPENDIX AJ (Con¿ned)

629

```prolog
clause(Head, Body) :- error(clause(Head, Body)).
```

630

```prolog
% generate; ultlmate laibre It N too blg (clausel5 talks)
gencls(Fun, Arity, N, Head. Body)
                         :-
    clause(Fun, Arlty, N, N_head, N_body),
    gencls(Fun. Arlty, N, N_head, Head, N_body, Body).
```

B31 B32 833 B34 835 836 837 B3-B B39 B40

% tall It N_head does not match Head.

```prolog
%
```

or ll N_body converted does not match Body

```prolog
gencls(_, _, _, N_head, N_head, N_body, Body)
                                   :-
    conv_body(Body, N_body).
% user's bacldracklng resumes c I a u s e here
```

641

```prolog
gencls(Fun, Arlty, N, _, Head, _, Body)
                             :-
    surn(N, 1, N1), gencls(Fun, Anty, N1, Head, Body).
```

B42 B43 644

```prolog
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::
```

845

°/e

Iistlng 646

```prolog
%
```

B47 646 B49

I I Q Q Q Q I Q I n I I I G 0 Q Q 0 Q I I O 0 0 I I I I 0 I I O I I I Q I 0 I 0 I O O I I 0 I I I I 0 I I OI

I n a I Q G Q u I Q 0 O I O O I I I I I I I O O O I I I I I I I I I I I I 0 I I I I I I I I I I I I I I I II

% list procedures detemtlned by the parameter ( Ilstlng(_) )

```prolog
%
```

or all user's pnooechtres ( Ilstlng )

```prolog
listlng :-
```

650

proc(Head), llstproc(Head), nl, tall. 651

Ilstlng.

% catch the llnal tall Irom p r o c 652 653

IIstlng(Fun)

```prolog
:- atom(Fun),
           I, lIstbyname(Fun).
```

854

```prolog
llstIng(I(Fun, ArIty))
               :-
```

sss

atom(Fun), Integsr(ArIy), -<(o, Aritv). |, 656

```prolog
lunctor(Head, Fun, Arlty), lIstproc(Head).
```

657

```prolog
IIstIng(L) :-
```

656

```prolog
lsclosedIlst(L), llstseveral(L),
                      I.
```

659

```prolog
lIstlng(X) :- srror(listIng(X)).
```

660

% lsclosedlst - cl grammar rule preprocessor 661

IisIssveraI([]).

```prolog
llstseveralq Item | ltems]) :-
    llstlng(ltem), llstsevsral(ltems).
```

662 663 664 665 666

% all procedures wlththlsname 667

```prolog
llstbynarne(Fun) :-
```

666

```prolog
proc(Head). Iunctor(Hsad, Fun, _),
```

669

llstproc(Hea:l), nl, tall. 670

```prolog
llstbyname(_).
               %succeed
```

671 672

```prolog
% one procedure
```

673

```prolog
listproc(Head) :-
```

674

```prolog
dause(Head, Body),
```

675

wrlteclause(Head. Body). wch(.), nl, tall. 676

```prolog
listproc(_).
              %succeed
```

677 676

```prolog
wrIteclause(Head, Body) :-
```

679

```prolog
not(var(Body)), -(Body,true),
                       I, wrlteq(Head).
```

660

```prolog
writecIause(Head. Body) :-
                     wrlteq(:-(Heal, Body)).
```

<!-- page 288 -->
APPENDIX AJ (Continued)

°/o IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIZZIIIIIZIIZIZIIIIIIIIIIII

```prolog
%
         w r I t e
°/e IIIZIIIIIIIIZIIIIIIIIIIIIIZIZIIZIIIIIZiIIIIiIZIII1211112I
write(Tem1)
         :- side_eI1ects(outterm(Tem1, noq)).
```

% syrrbols and solochars (not colnclding with 'llx" functors)

```prolog
writeq(Term)
          :- sIde_el1ects(outterm(Term, q)).
```

661 662 663 664 665 666 667

```prolog
% writeq encloses In quotes all Identiliers except words,
```

666 669 690 691

```prolog
writetext([Ch | Chsl)
                :-
                  l, wch(Ch), wrltetext(Chs).
```

s92

```prolog
writetext([]).
```

693 694

```prolog
outtem1(T, Q)
           :- nurrbervars(T, 1, _), outt(T, Id(_,_), Q).
```

695 696

% the real iob ls done here 697

```prolog
outt('V'(N), _, _)
            :- lntsger(N),
                       I, wch('X'). dispIay(N).
```

696

% C A U T I 0 N : cult Is unable to write 'V'(Integer) 699

```prolog
outt(Tem1, _, _)
            :- lnteger(Tem1), display(Tem\), I.
```

900

% the second parameter specltles a context lor 'llx' functors: 901

% the nearest extemal functor and Tem1's position 902

% (to the left or to the right ol the extemal functor) 903

```prolog
outt(Term, Context, Q)
                 :-
```

904

-..(Tem1, [Name | Argsl), 905

```prolog
outlun(Name, Args, Context, Q).
```

906 907

```prolog
% - - - output a lunctor-terrn
```

906

```prolog
%
   - asa"lix"tenn
```

909

```prolog
out1un(Name, Args, Context, Q)
                        :-
```

910

kslix(Name, Args,This_l1, Kind), l, 911

```prolog
outI1(Kind,Thls_I1, [Name | Args], Context, Q).
```

912

```prolog
%
   - asalist
```

913

```prolog
out1un(., [Larg, Rarg], _. Q)
                     :-
```

914

I, outlist([Larg|Flarg],Q). 915

```prolog
%
   - asanormaltunctor-tenn
```

916

```prolog
out1un(Name, Args, _, Q)
                   :-
```

917

```prolog
outname(Name, Q). outargs(Args, Q).
```

916 919

```prolog
% isllx constructs a palr l1(Prlor, Assoclatlvlty) , and
```

920

% ‘In’ or ‘pro’ or 'post' (tails ll not a "¿x" Iunctor) 921

```prolog
isIix(Narns, L, _], À(PrIor, Assoc), In)
                            :-
```

922

‘FF‘(Name, Types, Prior), rnl<_bIn(Types, Assoc). 923

```prolog
istix(Name, L], À(Prior, Assoc), Kind) :-
```

924

‘FF‘(Name, Types, Prior), rnl-t_un('l'ypes,Kind,Assoc). 925 926

```prolog
% Bintype (it any) ls belore Untype (it any)
```

927

```prolog
mk_bin([Bintype I _], Assoc) :- blnary(Birlype, Assoc).
```

926

```prolog
ml-t_un([Untype], Kind, Assoc) :- unary(Ur1ype,Klnd,Assoc).
```

929

```prolog
mk_un(L,Untype],KInd,Assoc)
                         :- unary(Untype,KInd,Assoc)
```

930

```prolog
% tests - see o p
```

931 932

```prolog
% - - - output a "lix' tem1 (thls outÀ has 5 parameters)
```

<!-- page 289 -->
APPENDIX A.3 (Colltilled)

933

```prolog
out1I(Klnd, This_I1, NameArgs, Context, O) :-
```

934

agree(ThIs_tI, Context), I, 935

```prolog
outI1(l-(Ind, Thls_t1, NameArgs, Q).
```

936

```prolog
outÀ(Klnd, Thls_t1, NameArgs, _, Q) :-
    wch('('), out11(KInd, Thls_t1, NameArgs, Q), wch(')').
```

937 938 939 940

% agree helps avoid (some) unnecessary brackets around the tem-I

```prolog
agree(_, Id(Ext_lI, _))
                :- var(Ext_I1).
```

941

```prolog
agree(t1(Prior1, _), ld(t1(Prior2, _), _))
                           :-
```

942

```prolog
stronger(Prior1, Prlor2).
```

% cl the parser 943

```prolog
agres(t1(PrIor, a(Dir)),1d(11(PrIor, a(Dir)), DIr)).
```

944 945

% output the functor and the arguments (this outlt has 4 parameters) 946

```prolog
out11(in, This_l1, [Name, Larg, Rarg], Q) :-
```

947

```prolog
outt(Larg, Id(This_I1, I), Q),
```

946

```prolog
outln(Name, ' '). outt(FIarg, Id(This_I1, r), Q).
```

949

```prolog
outl1(pre,Thls_t1, [Name, Arg], Q) :-
```

950 951

```prolog
    outIn(Name, ' '). outt(Arg, ld(ThIs_I1, n, Q).
outl1(post, TI1Is_t1,[Nams.N9]. Q) :-
```

**ssz**

```prolog
outt(Arg,Id(ThIs_I1, I), 0). outIn(Name, ' ').
```

953 954

```prolog
%outputIunctor's name encIosedInEncl
```

955

```prolog
outtn(Name, Encl) :- wch(EncI), dIsplay(Name), wch(EncI).
```

956 957

```prolog
% - - - print a name (In quotes, ll necessary)
```

956

```prolog
outname(Name, noq)
                :-
                  I, display(Name).
```

959

```prolog
outname(Name, q) :-
```

960

'FF'(Name,_,_),

I, out1n(Name, 961

```prolog
outname(Name, q)
               :-
```

962

```prolog
pname(Name, Namestrlng).
```

963

```prolog
check(noq(NamestrIng)),
                   I, display(Name).
```

964

```prolog
outname(Name,q) :- outln(Name,"").
```

965 966

```prolog
noq([Ch |StrIng1) :- wordstart(Ch), lsword(StrIng).
```

967

```prolog
noq([Cl'l])
        :- solochar(Ch).
```

969

00qI['I'- ‘I'D- 969

```prolog
noq([Ch |String1)
             :- symch(Ch), Issym(String).
```

970 971

```prolog
iavord(|]).
```

972

```prolog
isword([Ch | Strlng])
               :- abhanum(Ch), Isword(Strlng).
```

973

```prolog
issyn1([]).
```

974

```prolog
lssym([Ch | Strlngl)
               :- symch(Ch), lssym(Strlng).
```

975 976

% - - - output a list ol argumerls (cl outtun) 977

_)

I"

I- 976

```prolog
outargs(Args, Q)
             :-
```

979

```prolog
lake(Context), wch('('), outargs(Args, Context, Q), wch(')').
```

960 961

```prolog
outargs([Last]. Context. Q)
                    :-
                      I. outt(Last. Context. Q).
```

962

```prolog
outargs([Arg|Args], Context. Q)
                        :-
```

963

```prolog
outt(Arg, Context, O), dlsplay(', '), outargs(Args, Context, Q).
```

<!-- page 290 -->
APPENDIX A.3 (Continned)

% commas are used to delimit list Items, so we must bracket commas

```prolog
%
```

**w I t h I n ltens (it's a trick: we deperd on**

having

```prolog
%
```

the priority 1000 and being associative)

Iake(Id(I1(1000, na(_)), _)).

```prolog
% - - - output a list In square brackets (ci outlun - the main
%
```

Iunctor is the dot, and the list cannot be empty)

```prolog
outlist([F|rst | Tail], Q) :-
    Iake(Context), wch('['), outt(Flrst, Context, Q),
    outIist(Tail, Context, Q), wch(')').
outIist([], _, _) :- I.
outIist([Item | Items], Context, Q)
                        :-
    I, display(‘, '), outt(item, Context, Q),
    outlist(Iten's, Context, O).
```

% the bar and the closing Item (still bracketed Ii It contains commas)

```prolog
outIist(CIos'ng, Context, Q)
                    :-
    display(' I '). outt(CIosing, Context, 0).
         %IOIIOQIIIIOIQOOIQIQQOQIIOQOIIQOOIOQ
         % OOOIIIQ-iiQIIQQOIQIIIIIQOIIOQQIOIIOI
         %
              tr a n s I at o r
         % IIIOQIOIIIQQOIIOIIOIOIII-IIOIIII-Oil!-I
         % IIIOQIOI-liliiliiliIIIIOOOQOOOOIIOOOQO
```

**% read aprogram upto end. and translate it Into "kemel"lom1**

```prolog
translate(Inlile, Out¿le) :-
    see(lnlile), telI(Outlile),
    nl, repeat,
       read(Cla:se), pul(Clause), nl, -(Clause, end),
                                          I.
    seen, told, see(user), telI(user).
```

% - - - produce and output the translation oi one clause

```prolog
put(:-(Head, Body))
               :-
    I, puthead(Head, Sym_tab), putbody(Body, Sym_tab).
put(-->(Lelt, FIight))
               :-
    I, tag(transI_ruIs(Lelt, Right, :-(Head, Body»).
    puthead(Head, Sym_tab), putbody(Body, Sym_tab).
put(:-(Goal))
          :-
    I, putbody(GoaI, Sym_tab), wch(l), nl.
    once(Goal).
```

% a iailure here wouldn't matter (cl translate)

```prolog
put(snd)
       :-
         I.
put('err’) :-
          I.
put(UnitcIause)
            :- puthead(Unltclause, Sym_tab), putbody(true, _).
% - - - put a head call (it nus! be a Iunctor-temt)
puthead(Head, Sym_tab)
                   :-
    nonvar'nt(Head), I, puttem1(Head, Sym_tab).
puthead(Head, _)
              :- transl_err(Head).
```

985 986 987 988 989 990 991 992 993 994 995 996 997 998 999 1000 1001 1002 1003 1004 1005 1006 1007 1008 1009 1010 1011 1012 1013 1014 1015 1016 1017 1018 1019 1020 1021 1022 1023 1024 1025 1026 1027 1028 1029 1030 1031 1032 1033 1034 1035 1036

```prolog
%---putalistoIcallsand|]attheend
putbodg/(Body, Sym_tab)
                   :-
    punct(:), conv_body(Body, B),
                           I, putbody_c(B, Sym_tab).
```

<!-- page 291 -->
APPENDIX A.3 (Continued)

```prolog
        %seeassertetcIor conv_body
pu1b0dv_¢l[l- J
            1- L di=’-Pl=wlI]l-
putbody_c([Tem1 | Terms], Sym_tab)
                           :-
    not(integer(Tenn)),
                   I, puttem1(Term, Sym_tab),
    punct(.), putbody_c(Tem1s, Sym_tab).
putbody_c([Tem1|_], _) :- transl_err(Tem1).
pUI‘lCi(Ch)
        2- wch("), wch(Ch), nl, display(‘
                                  ').
```

% - - - put a tenn (with in¿x dots, and canonical otherwise)

```prolog
puttem1(Term,Sym_tab)
                   :-
    var(Tem1),
             I, Iookup(Tem1, Sym_tab, -1, N),
    wch(:), dlsplay(N).
putterm(Term, _)
             :- lnteger(Tem1), I. display(Terrn).
puttem1([Head | Tail], Sym_tab)
                        :-
    I, puttenn_InIist(Head, Sym_tab).
    display(‘ . '), puttem1(TaiI, Sym_tab).
puttem1(Term, Sym_tab)
                   :-
    -..(Tem1,[Name|Args]), outln(Name.""),
                                      %clWFIITE
    putargs(Args, Sym_tab).
```

% Sym_tab Is an open Ibt cl palrs vn(VarIabIe, Number)

% (this Iomtulation helps avoid too many additions)

```prolog
lookup(V, S_t_end, PrevlousN, N)
                         :-
    var(S_t_end),
               I, sum(PrevIousN, 1, N),
    -(S_t_end, [vn(V, N) | New_s_t_end]).
lookup(V, [vn(CurrV, CurrN)
                     | _], _, CurrN)
                                :-
    eqvar(V, CurrV),
                 I.
lookup(V, [vn(_, CurrN) | S_t_tail], _, N) :-
    lookup(V, S_t_tail, CurrN, N).
```

% arguments - nothing, or a list ol terms in parentheses

```prolog
putargs([|, _)
          :-
            I.
putargs(Args, Sym_tab) :-
    wcl1('('), putarglist(Args, Sym_tab), wch(')').
putarglist([Arg]. Sym_tab)
                   :-
                     I, puttem1(Arg, Sym_tab).
putarglist([Arg | Args], Sym_tab)
                        :-
    puttem1(Arg, Sym_tab), display(‘, '),
    putarglist(Args, Sym_tab).
```

**% - - - a list within a list nust be enclosed In parentheses**

```prolog
puttenn_lnlist(Tenn, Sym_tab)
                      :-
    nonvarlnt(Term), -(Term, L | _)),
                             I,
    wch('('), putterm(Tem1, Sym_tab), wch(')').
puttern1_inIist(Term, Sym_tab)
                      :- putterm(Term, Sym_tab).
```

% - - - error handing (only one error ks discovered by translate)

```prolog
lransl_err(X) :-
```

nl, display(‘-+++ Bad head or call: '), display/(X), nl, Iail. 1037 1038 1039 1040 1041 1042 1043 1044 1045 1046 1047 1048 1049 1050 1051 1052 1053 1054 1055 1056 1057 1058 1059 1060 1061 1062 1063 1064 1065 1066 1067 1068 1069 1070 1071 1072 1073 1074 1075 1076 1077 1078 1079 1080 1081 1082 1083 1084 1085 1086 1087 1088 1089

```prolog
:- see( user ), ear.
```

<!-- page 292 -->
APPENDIX A.4 Three Useful Programs

A simple ctlltor

% A slrrpie Interactive clause editor. % Watch tor name conÀicts with its procedures I % Note that this version has no saieguards agaimt Proiog's crash % (eg. due to stack overllow). % Cali edit( name/arity ) to edit the procedure oi this name and arity. % Each invocation oi edit is associated with a cursor, which is the number % oi a clause. Initially the cursor is at clause 0, i.e. belore the ¿rst % clause In this procedure. The cursors value and its associated clause % is usually displayed between commands. % Commands are listed below. Temtlnate the line immediately alter typing % last character. Don't use blanks where not shown and only one where shown % % Commands : % % % e Name/Arity - Invoke a nested instance to edit another procedure. %

The current cursor stays in place unless you happen %

to modlly this procedure within a nested Instance. % x

- exit Irom the current editor instance. % +

- move the cursor to the next clause, no action it none. % <cr>

- an empty line is an altemative lorrn oi +. % -

- move the cursor to the previous clause, no action ii at 0. % t

- top : move the cursor to 0. % b

- bottom : move the cursor to the bottom clause %

(0 lor empty procedures). % I

- list the whole procedure. % d

- delete the current clause and move the cursor to %

the next (or to the new bottom ll bottom is deleted). % i

- lnsen alter the current clause. In the following %

lines write clauses as you would alter consuit(user) %

(tenninate the sequence with end.).The cursor is %

positioned at the last inserted clause. % I Fiiename

- like I, but read the clauses from a iile. %

Take care I Àlename correctness is not checked. °/9 p

- invoke a nested instance oi Prolog. II there is %

no memory overliow, invoking stop will retum %

control to the editor. %

edit( Nams!Arity) :- not ( atom( Name ), integer( Arity) ),

I,

```prolog
write( ‘Bad parameters : ' ),
write( edit( NameIAnty) ), nl, iail.
```

edit( Name/Arity) :- predelined( Name, Arity),

I,

write( 'Can"t edit system routine : ' ),

<!-- page 293 -->
write( NamelArlty), nl, Iaii. edit( NameArity ):- tag( ed( NameArity, 0 ) ). APPENDIX A.4 (Continned)

ed( NameArity, Cursor) :- show( NameArity, Cursor),

I.

```prolog
docmd( NameArity, Cursor, NewCursor ).
ed( NameArity, NewCursor ).
```

ed( NameArity, Cursor) :- display( 'Cu|sorout oi range : ' ).

```prolog
display( Cursor ), nl, ed( NameArity, 0 ).
```

docmd( NameArity, Cursor, NewCursor) :-

repeat, % repeat over incorrect commands

```prolog
  getline( Une ), cmd( Line, NameArity, Cursor, NewCursor ),
I.
```

getIine([]) :- rch, iastch(C), kseoln(C),

I. getIine([C | L]) :- iastch( C ), getline( L).

% cmd tails tor incorrect commands. cmd( [1, NmAr, Cur, NCur) :- next_cursor( NmAr, Cur, NCur ). cmd( ['+'], NmAr, Cur, NCur) :- next_cursor( NmAr, Cur, NCur ). cmd( ['-'], _, Cur, NCur) :- prev_cursor( Cur, NCur ). cmd( [I], NmAr, _, 0 ). cmd( lb], NmAr, Cur, NCur) :- bottom_cursor( NmAr, Cur, NCur ). cmd( [I], NmAr, Cur, Cur ) :- iistlng( NmAr). cmd( [d], NmAr, Cur, NCur) :- deIete( NmAr, Cur, NCur) . cmd( [I], NmAr, Cur, NCur) :- insert( NmAr, Cur, NCur ). cmd( [i,' ' | NameStrlng], NmAr, Cur, NCur) :-

Àle_lnse|1( NameString, NmAr, Cur, NCur ). cmd( ls,’ ‘ | Args], NmAr, Cur, Cur) :-

```prolog
append( NameString, ['1' | ArityStrlng], Args ),
caIl_edlt( NameString, ArityStrlng ).
```

**Cindi III. _. _. _i 1- it-IOBXIII Bdi _. _ I )-**

cmd( [p], NmAr, Cur, Cur) :- invoke_Proiog. cmd(Str1|-|g_ __ __ _) :- display( '--incorrect command : ' ),

wrItetext( String), nl, lail.

% check is provided with the standard library ( check(C) :- not not C ) next_cursor( Name/Arity, Cursor, Next ) :-

Next is Cursor + 1, check( ciause( Name, Arity, Next, _, _) ),

I. next_cursor( _, Cursor, Cursor).

% cursor at last clause

prev_cursor( 0, 0 ). prev_cursor( Cursor, Prev ) :-

Cursor > 0, Prev is Cursor - 1.

bottom_cursor( NamelArlty, Cursor, Bottom) :-

Next is Cursor + 1, check( ciause( Name, Arity, Next, _, _ )),

I, bottom_cursor( NamelArity, Next, Bottom). bottom_cursor( _, Cursor, Cursor ).

deIete( _, 0, 0) :-

I, display( 'Can"t delete clause 0' ), nl. delete( NameIArlty, Cursor, NewCursor) :-

```prolog
retract( Name, Anty, Cursor).
cursor_ln_range( Name, Arity, Cursor, NewCursor ).
```

cursor_ln_range( Nm, Ar, Cur, Cur ) :-

<!-- page 294 -->
check( clause( Nm, Ar, Cur, _, _ )), I. APPENDIX A.4 (Continned)

cursor_ln_range( _. _. Cur. Prev) :- Prev is Cur - 1.

% conven is dellned in the standard library insert( NameArity, Cursor, NewCursor) :-

repeat,

```prolog
      % get end. or a clause oi NamelArlty, skb others
   read( Clause), convert( Clause, Head, Body ),
   accept( Head, NameArity, Clause ),
I.
end_or_proceed( Head, Body, NameArity, Cursor, NewCursor ).
```

end_or_proceed( end, []. _, Cursor, Cursor) :- I. end_or_proceed( Head, Body, NameArity, Cursor, NewCursor) :-

Next is Cursor + 1, assert( Heal, Body, Cursor),

```prolog
insert( NameArity, Next, NewCursor ).
```

accept( _. _. end ). accept( Head, NamelArity, _) :- lunctor( Head, Name, Arity ). accept( _, _, Clause) :-

dlspiay( '---clause not in edited procedure - ignored‘ ),

nl, write( Clause), iail.

Iiie_insert( FNameStrlng, NameArity, Cursor, NewCursor) :-

```prolog
pname( FiIeName, FNa|'neStrlng ),
see( FiIeName ), insert( NameArity, Cursor, NewCursor ),
seen, see( user).
```

cail_edit( NameString, ArityStrlng ) :-

```prolog
pname( Name, NameString ), pnamei( Arity, ArityStrlng ),
edit( Name/Arlty ).
```

invoke_Prolog :- tag( loop ). % this works only tor the Toy-Prolog monitor invoke_Proiog.

%( loop temtinated by tagiall )

% conv_body is de¿ned in the standard library (asserta etc.), % so is writeclause. show(NameArity,0) :-

I, write( '[0]('), write( NameArity),

rit

```prolog
      nl.
BI ‘I’ I.
```

show( Name/Arity:~Cursor) :-

```prolog
  side_ei1ects( ( clause( Name, Anty, Cursor, Head, Body ),
           conv_body( NIceBody, Body ),
           display( ‘I’ I. display( Cursor I.
           display( '1 ' I.
           writeclause( Head, NIceBody ),
           display(
                  ), nl)
                              ).
rl:l([],L,L).
```

**:3I:MiEILi-L2.IEI¢2II=-aPPBI1dil-.L2.l-l-2I-**

<!-- page 295 -->
APPENDIX A.4 (Continned)

Aprhnltiveu-ndngtool

% A primitive tracing package. % Watch tor name conÀicts with its procedures I % Use spy( Pattem ) to trace calls matching Pattem, %

nospy( Pattem ) to stop tracing. % To trace, execute trace( Goal ) Instead oi Goal. % Successful calls are displayed with a plus, tailing calls with a rnlnus. % Note: tagcut, tagexlt, tagiall and ancestor will not be executed properly %

tracelsslow: ilyouwlshtohevethelnsldesolacorrectand %

costly procedure executed at nomtal speed, add %

a predeÀned(...) assertion tor its call. spy(Ail) :- var( Ail),

I, assert(spied(All)). spy( Pattem) :- spied( Pattem ), I.

```prolog
% spied already
```

spy( Pattem) :- asse|1(spled( Pattem ) ).

nospy( Pattem) :- retract(spied( Pattem)), tall. "°$PY( _ Itrace( Goal) :- tag( runbody( Goal ) ).

runbody((A,B)):-

I, nunbody(A), nunbody(B). runb°dvlIA:BII=- I. irvnbOdviAI:runb0dyiBIIrunbody( caIl( Call ) ) :-

```prolog
var( Call),
         I, showiaiiure(call( Call) ), tail.
```

runbody(calI(CalI)) :-

I, nunbody(CalI).

```prolog
:-
  I
           call Call
```

**wrvbvdvltaslwlll**

. runbody(

I

**II-**

runbody( Cali) :- predelIned( Call),

I, runsystem( Call). runbody( Cali) :- tag( runuser( Call ) ).

runsystem( I ) :- runcut. runsystem( Forbidden ) :-

lslo|bidden(Forbldden),

I, nl,

```prolog
display( ‘FORBIDDEN CALL ' ), write( Forbidden ),
display( ' FAILS I‘), nl, tall.
```

runsystern( Call) :- not spIed( Call ),

I, Cali. runsystem( Call) :- Call, I, showsuccess(CaIl). runsystern( Call) :- showlalhure( Call ), tall.

runuser( Call) :- not spied( Call),

I,

```prolog
clause(Cali,Body), runbody(Body).
```

nunuser( Call) :- clause( Call, Body ), showsuccess( Cali ),

runbody( Body Inunuser( Call) :- showialltxe( Call ), tall.

runcut :- spied(i), simuiatecut, showsuocess(l). runcut :- simuiatecut.

sinluiatecut :- tagcut( nunuser( _ ) ). sinluiatecut :- tagcut( nurbody( _ ) ).

```prolog
% cut In inltlaigoai
```

<!-- page 296 -->
APPENDIX A.4 (Continned)

**showsuccess(CaiI) :- dispiay('+'), write(CalI), nl.**

**showiaIIure( Call) :- display( ' -'), write(CaII), nl.**

**II-**

i

i

ii n isIorbidden( tagexit( isiolbIdden( taglaiI( _' lslorblddenl tagcut( isiorbidden( ancesto?( _ ) )

predeiined( Call ) :-

Cl‘i0Cl<( ( 1t.lI'tCt0t'( Call F N )

```prolog
predeÀmd( F N ) ) )
```

<!-- page 297 -->
APPENDIX A.4 (Continued)

Aprognmsu'ucturennnlyserwIthnnnlyse|-analysed

% Given a procedure name and arity, print its call tree. % The main data structure is a queue oi procedures whose tall contains % calls which were not yet seen. Each elemert oi the queue contains a list % oi calls (references to main queue elemeris) and a variable to hold its % ordinal nurrber in the listed tree. % Queues are searched linearly : the algorithm is costly Ior large trees. % CAUTION : don't atterrpt to list a trace oi this program - cyclic structures % are formed as a rule.

calitree( NamelArity) :- add( proc( Name, Arlty, Ord, Calls), Queue),

```prolog
lill( Queue, Queue ),
prlnt_caiis([proc(Name.Arity.0rd,Cails)].3,1 ,_).
```

% add iinds (inserts) an element in ( to ) an open list add( El, [Ei|Tall]) :-

I. add( El, L | Tail] ) :- add( El, Tail ).

% iill walks the queue and expands procedures, lnsenlng their calls Into % the queue ll not yet seen. Queue begimlng ls passed along to allow search. iiII( []. _) :-

I.

% eviderlly reached the tennlnatlng variable IiII( [proc(Name,Arlty,_,|])|QTalI]. Q) :- predeÀned( NameIArlty ),

I,

Iiil( QTaii, Q ). liII( [proc(Name,Arlty,_,undeIIned)|QTail], Q ) :-

not clause( Name. Arity, 1, _, _ ),

I, ¿¿( QTaiI, Q ). IiiI( [proc(Name,ArIty,_,Calls)iQTail], Q) :-

```prolog
add_cals( Name. Arity, 1, Calls. Q ), liII( QTail, Q ).
```

% system procedures and procedures deiined In the monitor should not be shown predelined( Name I Arity) :- predeIined( Name, Arity ). % only the more commonly used procedures (but the list is easily extended) predeiined( ‘not’ I 1 ). predeÀned( nil 0 ). predellned( read I 1 ).

```prolog
predeÀned( '-..' I 2 ).
```

predeiined( op I 3 ).

```prolog
predeilmd( ‘is’ I 2 ).
```

predeIinsd( assen I 1 ).

```prolog
predeÀned( assert: I 1 ).
```

predeÀned( retract I 1 ).

```prolog
predeÀned( clause I 2 ).
```

predeÀned( write I 1 ).prede¿ned( writeq I 1).

% add_cals processes the clauses oi a procedure. adding calls to its list % oi calls and to the queue (only ¿nding In the queue ii already there) add_caiIs( Name. Arity, N, Calls, Q ) :-

```prolog
clause( Name, Arlty, N, _, Body ),
                         I,
body_caIis( Body, Calls, Q ),
                      N1 is N + 1.
add_cals( Name, Arity, N1, Calls, Q ).
```

add_caiIs( _. _. _, |], _) :-

I.

% close the list it empty

% ( only unit clauses ) add_calls( _. _, _, _, _ ).

% non-empty list lelt open

body_calls( [], _, _ ) :-

<!-- page 298 -->
I. APPENDIX A.4 (Continued)

body_cals( [Call | BodyTaIl], Calls, Q ) :-

```prolog
lunctor( Call, Name, Arity ),
add( proc(Name,Arlty,Ord,CaIlees), Calls I.
add( proc(Name,Arlty,Ord,Callees), Q I.
add_insides( Call, Calls, Q I.
body_cals( BodyTall, Calls, Q ).
```

% add_insides unpacks melaioglcal calls: ll their arguments are not variable % or integer, they are added to the queues. add_lrsides( Call. Q1, Q2 ) :- meta_call_1( Cali, Arg ), I,

```prolog
add_inside( Arg, Q1, Q2 ).
```

add_insldes( Call, Q1, Q2 ) :- meta_call_2( Call, Arg1, Arg2 ),

I,

```prolog
add_inside( Arg1, Q1, Q2 ),
add_inside( Arg2. Q1, Q2 ).
```

add_irsides( _, _, _ ).

add_inside( V, _, _) :- (var( V ) ;lnteger( V ) ),

I. add_inside( Cali, Q1, Q2) :- lunctor( Cali, Name, Arity ),

```prolog
add( proc(Name,Arity,Ord.Callees), Q1 ),
add( proc(Name,Anty,Ord.Caiiees), Q2 I.
add_lnsides( Call, Q1, Q2).
```

meta_call_1( caIl( Call ), Cali ). meta_call_1( tag( Call ), Ca¿ ). meta_call_1( not Call, Call ). meta_call_1( check( Cali ), Call ). meta_call_1( slde_ellects( Cali ), Cali ). meta_call_1( once( Ca¿ ), Call ).

meta_calI_2( meta_caii_2(

P)

UJID }>_>

IIIOJ

% Print calls, staning at given tab setting and ordinal, retuming next ordinal % number. Third clause tails ii ordinal numbers don't match, i.e. proc % was already printed In another line. prinI_0a|ls( I]. _, Ord. Ord) :- I. % this matches the temtinating var

```prolog
% oi a ca¿ list.
```

print_caIks( [proc(Name,Arity,0rd,undellned)|Calks], Tab, Ord, NOrd ) :-

I, start_undeiined( Ord, Tab),

writeq( NamelArlty ), display(‘

“unde¿ned” ), nl,

TOrd is Ord + 1, print_calks( Calls, Tab, TOrd, NOrd ). print_caIis( [proc(Name,Arlty,Ord,Callees)|Cdls], Tab. Ord, NOrd) :-

I, slart_llne( Ord, Tab), writeq( NamelArlty ), nl,

InnerTab is Tab + 3, InnerOrd is Ord + 1,

```prolog
prInt_calls( Cailees, InnerTab, InnerOrd, TOrd ),
prlnt_calis( Calhs, Tab. TOrd, NOrd ).
```

print_caiks( [proc(Name,Arity,AnotherOrd,_)|Cails], Tab, Ord, NOrd) :-

```prolog
start_unnumbered__Ilne( Tab ), writeq( NameIArity ),
repetitioni Name, Arlty, AnotherOrd ), nl,
print_caIls( Calls, Tab, Ord, NOrd ).
```

<!-- page 299 -->
APPENDIX A.4 (Continued)

repetitlon( Name. Arlty, _) :- predeÀned( Name Arity)

I repetitlon( _, _, Ord) :- display( ' (see ' ), display( Ord)

display( ‘I’ I-

% Ord numbers are printed In 4 columns, right lustilled start_llne( Ord, Tab) :- nun'ber_lne( Ord)

I

tab( Tab

) number_lne( N ) :- N < 10, display(‘

' ), display( N) number_llne( N ) :- N < 100, display(‘ '). display( N) number_lne( N ) :- N < 1000, display( ' ' ), display( N) number_Iine( N ) :- display( N ).

start_unnuni:ered_Iine( Tab) :- display(‘

)

tab( Tab

'

)

start_unde¿ned( Ord, Tab) :- nun-ber_Ine( Ord)

tab( Tab

I

0,_):

. tab(

**-I**

**tab(N,Ch):- wch(Ch),N1isN-1,tab(N1Ch)**

7 % % a sanple call and results :- calltree( calltree I 1 ).

calltree/1

add/2

1

2

3

4

I/0

addI2 (see 2)

IiIlI2

I I 0

prede¿ned I 1

5

6

prede¿ned I 2

liill 2 (see 4)

7

8

9

'not' I 1

clause I 5

add_cals I 5

clause I 5

I I 0

10

body_cals/3

**no**

11

Iunctor! 3

add I 2 (see 2)

add_lnsldes/ 3

12

13

meta_caII_1 I 2

I I 0

add_irslde I 3

';' I 2

14

15

16

17

18

call! 1

var! 1

integer! 1

I I 0

Iunctor I 3

add! 2 (see 2)

<!-- page 300 -->
add_lnsides/ 3 (see 12) APPENDIX A.4 (Continued)

19

meta_cail_2 I 3

body_caiis I 3 (see 10) 20

‘is’ I 2

add_cals I 5 (see 9) 21

pn'nt_cails I 4

I I 0 22

sta|1_undeiIned I 2 23

nurrber_iine/ 1 24

'<' I 2

‘is’ I 2 (see 20) 25

less I 2 26

display! 1 27

tab I 2

I I 0 26

wch I 1

'is'/ 2 (see 20)

tab I 2 (see 27) 29

writeq I 1

display I 1 30

nl I 0

'is' I 2 (see 20)

print_caiB I 4 (see 21) 31

start_line I 2

nurrber_|ineI 1 (see 23)

I I 0

tab I 2 (see 27) 32

start_unnumbered_iine/ 1

display! 1

tab I 2 (see 27) 33

repetition I 3

predeiinsd I 2

I I 0

display! 1

