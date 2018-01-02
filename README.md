# Zápočtový program na zimní semestr 2017 - Jiří Mayer

Převod mezi regulárními výrazy, konečnými automaty deterministickými a nedeterministickými.


# Ještě dodělat

- prázdné jazyky
- prázdné řetězce


# Dokumentace

Čtenář by měl být obeznámen s významem termínů:

- regulérní výraz
- deterministický automat
- nedeterministický automat

Ty nejsou v dokumentaci vysvětlené, dokumentace se soustředí na program samotný.


## Používání programu

Program se spouští z příkazové řádky následujícím způsobem:

    $ ./MainProgram [vstupní soubor] [výstupní soubor] [výstupní entita]

> Entitou se myslí regulérní výraz `RE`, nedeterministický automat `NDA`
nebo deterministický automat `DE`.

Program načte entitu ze vstupního souboru, provede převod na požadovanou
výstupní entitu a zapíše ji do výstupního souboru.

První dva argumenty jsou relativní cesty k souborům. Třetí argument je jeden
z kódů entit: `RE`, `NDA`, `DA`.


### Formát souborů entit

Na prvním řádku se nachází hlavička - typ entity uvnitř souboru. Hodnotou je jeden
z možných kódů `RE`, `NDA`, `DA`.

Obsah dalších řádků se liší podle typu entity.


#### Soubor regulérního výrazu

Za hlavičkou je pouze jeden řádek obsahující regulérní výraz serializovaný
v prefixové notaci. Více informací [zde](docs/regular-expression.md).


#### Soubor automatu

Formát souboru obou typů automatů je stený, liší se pouze povoleným
uspořádáním přechodů a existencí epsilonových přechodů.

První řádek za hlavičkou obsahuje serializované stavy automatu a každý další
obsahuje serializovaný právě jeden přechod. Konkrétní vzhled
je [zde](docs/automaton.md).


## Přehled algoritmu

Popis, jak funguje program algoritmicky je [zde](docs/algorithm.md).


## Struktura programu

Struktura programu z hlediska kódu je popsána [zde](docs/program-structure.md).


## Testovací data

Informace k testování jsou [zde](docs/testing.md).