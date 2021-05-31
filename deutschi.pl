/** <module> Deutschi is a Prolog based interpreter for the German language.

This module contains parsing rules for the German language in terms of simple
predicates and DCGs. One can use it to understand the syntactical structure or
the abstract syntax tree of a given phrase in German.

@author Drazen Popovic
@email bladyjoker@gmail.com
@license GPL
*/
:- module(deutschi, [deutschi/2]).
:- use_module(library(dcg/basics)).
:- set_prolog_flag(double_quotes, chars).

%! example(-GermanPhrase:string, -TranslatedPhrase) is nondet
%  Some useful and otherwise interesting german phrases and their
%  meaning/translation in some other language (mostly english).
example("Wir sind hier wegen der Anmmeldung.", en("We're here about the registration of residence.")).
example("Also, mal sehen.", en("Well, let's see.")).
example("Lass uns gehen.", en("Let's go.")).
example("eins plus fuenf is gleich sechs.", math("1+5=6")).
example("Erzähl mal, Freddy.", en("Tell me, Freddy.")).
example("Klingt gut!.", en("Sounds good!")).
example("Wo wohnst du eigentlich, Anna?", en("Where do you live actually, Anna?")).
example("Das klingt toll!", en("That sounds great!")).
example("Du musst mich mal einladen.", en("You have to invite me some time")).
example("Es gibt sogar eine Hängematte.", en("There's even a hammock.")).
example("Du hast Recht.", en("You're right.")).
example("Noch etwas?", en("Anything else?")).
example("Ich haette gerne einen Kaffe.", en("I would like to have a coffee.")).
example("Nein danke, das ist alles.", en("No thanks, that's everything/all.")).
example("Zusammen oder getrennt?", en("Together or separate?")).
example("Stimmt so.", en("Keep the change.")).
example("Wohin fahren wir?", en("Where are we going/driving?")).
example("Wohin", hr("Kamo")).
example("Woher", hr("Odakle")).
example("Ist das Wort einzahl oder mehrzahl?", en("Is the word singular or plural?")).
example("Ist es warm draußen?", en("Is it warm outside?")).
example("Ich komme mit! Ich brauche noch ein paar Sachen für die Geburtstagsparty.", en("I'm coming with! I need another couple of things for the birthday party.")).
example("Mal sehen.", en("Let's see.")).
example("Aber gewiss.", en("Of course.")).
example("Moment mal.", en("Moment, please.")).
example("Wie viel Urh ist es?", en("What's the time?")).
example("Um wie viel Uhr?", en("At what time?")).

% # The interpreter
% The interpreter is built with Prolog DCGs and some simple helper predicates.
% That means it can be used in several modes, to generate valid sentences, to
% check validity of sentences and parse a sentence into its syntactical components.

%! deutschi(-GermanPhrase:string, Parsed:sentence) is nondet
%  Can be used in all modes, but most often one would supply a GermanPhrase and
%  get a Parsed structure out.
deutschi(String, Parsed) :-
    phrase(sentence(Parsed), String).

%% ## Simple helper predicates

%! gender(-Gender:atom) is nondet
%  Grammatical genders in the language.
% @see https://en.wikipedia.org/wiki/Grammatical_gender
gender(masculine).
gender(feminine).
gender(neutral).

%! gnumber(-GrammaticalNumber:atom) is nondet
%  Grammatical numbers in the language.
% @see https://en.wikipedia.org/wiki/Grammatical_number
gnumber(single).
gnumber(plural).

%! numgen(-NumberGender:atom) is nondet
%  Joined Grammatical numbers and genders in the language.
numgen(single(G)) :-
    gender(G).
numgen(plural).

%! article(-ArticleType:atom) is nondet
%  Article types in the language.
% @see https://en.wikipedia.org/wiki/Article_(grammar)
article(definite).
article(indefinite).
article(possesive(Whos)) :-
  ownership(Whos).
article(negative).

%! ownership(-Ownership:string) is nondet
%  Grammatical ownership in the language.
% @tbd Find how this is called in linguistics.
ownership("mein").
ownership("dein").
ownership("Ihr").
ownership("sein").
ownership("ihr").
ownership("sein").
ownership("unser").
ownership("euer").
ownership("eure").

%! capitalized(-String:string) is nondet
%  Uppercase strings.
capitalized([X|_]) :-
    char_type(X, upper).

%! day(-Day:string) is nondet
%  Days in a week.
day("Montag").
day("Dienstag").
day("Mittwoch").
day("Fonnerstag").
day("Freitag").
day("Samstag").
day("Sonntag").

%! month(-Month:string) is nondet
%  Months in a year.
month("Januar").
month("Februar").
month("März").
month("April").
month("Mai").
month("Juni").
month("Juli").
month("August").
month("September").
month("Oktober").
month("November").
month("Dezember").

%! season(-Season:string) is nondet
%  Season in a year.
season("Frühling").
season("Sommer").
season("Herbst").
season("Winter").

% ## Variable naming
%
% A few notes on the terminology and how variables are named are shortened to
% have concise code statements.
%
% - Case - C
% - Persona - P
% - Article - Ar
% - Adjective - Adj
% - Adverb - Adv

% ## Sentences

ws --> [C], {char_type(C, white)}, ([];ws).
statement_end --> ".";"!".

sentence([entity(case(C), persona(P), article(ArType), adjectives([AdjTerm]), noun([Root, Suffix]))]) --> article(C, P, ArType), ws, adjective(AdjTerm, C, P, ctx(ArType)), ws, noun(Root, P, Suffix).

% ## Nouns

noun_ng("Kind", single(neutral)).
noun_ng("Schwester", single(feminine)).
noun_ng("Schlag", single(masculine)).


% ### Masculine
noun(Matched, single(masculine), [Day]) --> {day(Day), capitalized(Day), Day = Matched}, Day.
noun("Tag", single(masculine), ["Tag"]) --> "Tag".
noun(Matched, single(masculine), [Month]) --> {month(Month), capitalized(Month), Month = Matched}, Month.
noun(Matched, single(masculine), [Season]) --> {season(Season), capitalized(Season), Season = Matched}, Season.
noun(Matched, single(masculine), [Root, Suffix]) -->
    {capitalized(Root)},
    string(Root),
    {member(Suffix, ["er", "en", "el"])},
    Suffix,
    {append(Root, Suffix, Matched)}.
noun(Matched, single(masculine), [Root, Suffix]) -->
    {capitalized(Root)},
    string(Root),
    {member(Suffix, ["ich", "ig", "ismus", "ist", "ling", "us"])},
    Suffix,
    {append(Root, Suffix, Matched)}.
noun(Matched, single(masculine), [Root, "tag"]) --> string(Root), "tag", {append(Root, "tag", Matched)}.

% ### Feminine
noun(Matched, single(feminine), [Root, Suffix]) -->
    {capitalized(Root)},
    string(Root),
    {member(Suffix, ["e", "a", "in", "ei", "heit", "keit", "ie", "ik", "nz", "schaft", "ion", "tät", "ung", "ur"])},
    Suffix,
    {append(Root, Suffix, Matched)}.

% ### Neutral
noun(Matched, single(neutral), [Root, Suffix]) -->
    {capitalized(Root)},
    string(Root),
    {member(Suffix, ["chen", "lein", "en", "nis", "ment", "tel", "tum", "um"])},
    Suffix,
    {append(Root, Suffix, Matched)}.

noun(Matched, single(neutral), [Prefix, Root]) -->
    {member(Prefix, ["Ge"])},
    string(Prefix),
    string(Root),
    {append(Prefix, Root, Matched)}.

% ### Plural
noun(Matched, plural, [Root, Suffix]) -->
    {capitalized(Root)},
    string(Root),
    {member(Suffix, ["n", "en", "s"])},
    Suffix,
    {append(Root, Suffix, Matched)}.

% ### Exceptions
noun(Matched, NG, [Matched]) -->
    {capitalized(Matched), noun_ng(Matched, NG)},
    string(Matched).

:- discontiguous pronoun/5.
:- discontiguous adjective/6.
:- discontiguous article/6.
:- discontiguous case_inflection/4.

% ## Nominative objects

% ### Pronouns
pronoun("ich", nom, single(G)) --> "ich", {gender(G)}.
pronoun("du", nom, single(G)) --> "du", {gender(G)}.
pronoun("Sie", nom, single(G)) --> "Sie", {gender(G)}.
pronoun("er", nom, single(masculine)) --> "er".
pronoun("sie", nom, single(feminine)) --> "sie".
pronoun("es", nom, single(neutral)) --> "es".
pronoun("wir", nom, plural) --> "wir".
pronoun("ihr", nom, plural) --> "ihr".
pronoun("sie", nom, plural) --> "sie".

% ### Case inflections
% @see https://en.wikipedia.org/wiki/Inflection
case_inflection(nom, single(masculine), Root, Root).
case_inflection(nom, single(neutral), Root, Root).
case_inflection(nom, NG, Root, IRoot) :-
    (NG = single(feminine); NG = plural),
    append(Root, "e", IRoot).

% ### Articles
% #### Definite
article("der", nom, single(masculine), definite) --> "der".
article("die", nom, single(feminine), definite) --> "die".
article("das", nom, single(neutral), definite) --> "das".
article("die", nom, plural, definite) --> "die".
% #### Indefinite
article(Matched, nom, single(G), indefinite) -->
    {case_inflection(nom, single(G), "ein", Matched)}, Matched.
% #### Possesive
article(Owner, nom, single(masculine), possesive(Owner)) -->
    {ownership(Owner), Owner \= "eure"}, string(Owner).
article(Matched, nom, single(feminine), possesive(Owner)) -->
    {ownership(Owner), Owner \= "euer", append(Owner, "e", Matched)}, Matched;
    {ownership(Owner), Owner = "eure", Matched = Owner}, Matched.
article(Matched, nom, single(neutral), possesive(Owner)) -->
    article(Matched, nom, single(masculine), possesive(Owner)).
article(Matched, nom, plural, possesive(Owner)) -->
    article(Matched, nom, single(feminine), possesive(Owner)).
% #### Negative
article(Matched, nom, NG, negative) -->
    {case_inflection(nom, NG, "kein", Matched)}, Matched.

% ### Adjectives
adjective(Matched, nom, single(G), ctx(definite)) -->
    string(Root), "e", {gender(G), append(Root, "e", Matched)}.
adjective(Matched, nom, plural, ctx(definite)) -->
    string(Root), "en", {append(Root, "en", Matched)}.
adjective(Matched, nom, single(masculine), ctx(Ctx)) -->
    string(Root), "er", {append(Root, "er", Matched)}, {Ctx = free; Ctx = indefinite}.
adjective(Matched, nom, single(feminine), ctx(Ctx)) -->
    string(Root), "e", {append(Root, "e", Matched)}, {Ctx = free; Ctx = indefinite}.
adjective(Matched, nom, single(neutral), ctx(Ctx)) -->
    string(Root), "es", {append(Root, "es", Matched)}, {Ctx = free; Ctx = indefinite}.
adjective(Matched, nom, plural, ctx(indefinite)) -->
    string(Root), "en", {append(Root, "en", Matched)}.
adjective(Matched, nom, plural, ctx(free)) -->
    string(Root), "e", {append(Root, "e", Matched)}.

% ## Dativ objects
% ### Pronouns
pronoun("mir", dat, single(G)) --> "mir", {gender(G)}.
pronoun("dir", dat, single(G)) --> "dir", {gender(G)}.
pronoun("Ihnen", dat, single(G)) --> "Ihnen", {gender(G)}.
pronoun("ihm", dat, single(masculine)) --> "ihm".
pronoun("ihr", dat, single(feminine)) --> "ihr".
pronoun("ihm", dat, single(neutral)) --> "ihm".
pronoun("uns", dat, plural) --> "uns".
pronoun("euch", dat, plural) --> "euch".
pronoun("ihnen", dat, plural) --> "ihnen".

% ### Case inflections
% @see https://en.wikipedia.org/wiki/Inflection
case_inflection(dat, single(G), Root, IRoot) :-
    (G = masculine; G = neutral),
    append(Root, "em", IRoot).
case_inflection(dat, single(feminine), Root, IRoot) :-
    append(Root, "er", IRoot).
case_inflection(dat, plural, Root, IRoot) :-
    append(Root, "en", IRoot).

% ### Articles
% #### Definite
article("dem", dat, single(masculine), definite) --> "dem".
article("der", dat, single(feminine), definite) --> "der".
article("dem", dat, single(neutral), definite) --> "dem".
% #### Indefinite
article(Matched, dat, single(G), indefinite) -->
    {case_inflection(dat, single(G), "ein", Matched)}, Matched.
article(Matched, plural, definite) --> {member(Matched, ["den", "denn"])}, Matched.
% #### Possesive
article(Matched, dat, CaG, possesive(Owner)) -->
    {(ownership(Owner), Owner \= "euer", Owner \= "eure"); Owner = "eur"},
    {case_inflection(dat, CaG, Owner, Matched)}, Matched.
% #### Negative
article(Matched, dat, CaG, negative) -->
    {case_inflection(dat, CaG, "kein", Matched)}, Matched.

% ### Adjectives
adjective(Matched, dat, NG, ctx(Ctx)) -->
    string(Root), "en",
    {numgen(NG), append(Root, "en", Matched), member(Ctx, [definite, indefinite])}.
adjective(Matched, dat, NG, ctx(free)) -->
    string(Root),
    {numgen(NG), case_inflection(dat, NG, Root, Matched), append(Root, Suffix, Matched)},
    Suffix.

:- begin_tests(deutschi).
:- set_prolog_flag(double_quotes, chars).

test(capitalized) :-
    deutschi:capitalized("True").

test(capitalized) :-
    \+deutschi:capitalized("false").

test_noun_gender(String, G, Parts) :-
    phrase(deutschi:noun(String, single(G), Parts), String).

test(noun_gender, [nondet]) :-
    test_noun_gender("Apfel", masculine, ["Apf", "el"]),
    test_noun_gender("Bruder", masculine, ["Brud", "er"]),
    test_noun_gender("Übung", feminine, ["Üb", "ung"]),
    test_noun_gender("Gesetz", neutral, ["Ge", "setz"]),
    test_noun_gender("Reise", feminine, ["Reis", "e"]),
    test_noun_gender("Album", neutral, ["Alb", "um"]),
    test_noun_gender("Krankheit", feminine, ["Krank", "heit"]),
    test_noun_gender("Schwester", feminine, ["Schwester"]),
    test_noun_gender("Apartment", neutral, ["Apart", "ment"]),
    test_noun_gender("Qualität", feminine, ["Quali", "tät"]),
    test_noun_gender("Eleganz", feminine, ["Elega", "nz"]),
    test_noun_gender("Onkel", masculine, ["Onk", "el"]),
    test_noun_gender("Explosion", feminine, ["Explos", "ion"]),
    test_noun_gender("Eigenschaft", feminine, ["Eigen", "schaft"]),
    test_noun_gender("Lehre", feminine, ["Lehr", "e"]),
    test_noun_gender("Schlag", masculine, ["Schlag"]),
    test_noun_gender("Ereignis", neutral, ["Ereig", "nis"]),
    test_noun_gender("Museum", neutral, ["Muse", "um"]),
    test_noun_gender("Honig", masculine, ["Hon", "ig"]),
    test_noun_gender("Sozialismus", masculine, ["Sozial", "ismus"]),
    test_noun_gender("Regen", masculine, ["Reg", "en"]).

:- end_tests(deutschi).

:- doc_server(4000).    % Start PlDoc at port 4000
:- portray_text(true).  % Enable portray of strings
