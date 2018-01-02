# Algoritmus

Program se vlastně skládá z několika převaděčů mezi jednotlivými typy entit.

Entit je 8, převodů by tedy mělo být 6, ale můžeme ušetřit - není třeba
psát převaděč `DA -> NDA` protože deterministický automat je vlastně
speciálním případem nedeterministického (implicitní přechod). Dále je zbytečné
umět převod `RE -> DA`, když stačí zřetězit převody `RE -> NDA -> DA`.
Podobným způsobem můžeme dorazit na pouze 3 potřebné
přechody (a jeden implicitní):

<img src="../pics/conversion-diagram.jpg" style="width: 300px">

Převody `RE <-> NDA` se k sobě navíc hodí, protože epsilonové hrany se
velmi snadno převádí na epsilonové výrazy a naopak.

Program tedy provede potřebné převody po sobě tak, aby se dostal z počátečního
uzlu v diagramu výše do cílového.

Převod `DA -> NDA` zde popisovat nebudu, protože se ani o převod defakto nejedná.

> Pozn: Při vymýšlení implementace algoritmu jsem uvažoval i jak jednotlivé
entity reprezentovat v paměti, aby se převod zbytečně nekomplikoval.
Reprezentace je popsaná na stránce [výrazů](regular-expression.md)
a [automatů](automaton.md).


## Regulérní výraz na nedeterministický automat

Nedeterministický automat bude mít jeden počáteční a jeden koncový stav. A mezi
nimi se vytvoří přechody a stavy, které budou reprezentovat výraz.

<img src="../pics/RE-to-NDA.jpg" style="width: 300px">

Tedy uvažujme nějakou funkci, která dostane odkaz na počáteční a koncový
stav a nějaký regulární výraz a vytvoří mezi zadanými stavy
odpovídající automat.

Taková funkce má zřejmě rekurzivní charakter, který vyplývá z rekurzivní povahy
regulérních výrazů.

Tedy stačí nám vymyslet, jak reprezentovat elementární operátory regulárního
výrazu a pomocí rekurze můžeme zkonstruovat libovolný výraz.


### Symbol

Symbol v automatu je reprezentován přechodem pro daný symbol.

<img src="../pics/symbol.jpg" style="width: 300px">


### Konkatenace

Konkatenace dvou výrazů `R` a `S` znamená, že nejprve musí proběhnout první
výraz a dostat se do stavu někde "na půl cesty" a poté proběhnout druhý výraz.

Tedy bude potřeba přidat do automatu jeden nový stav.

<img src="../pics/concatenation.jpg" style="width: 300px">


### Alternace

Alternace znamená mít možnost jít buď jednou, nebo druhou cestou. Tedy
vzniknou nám mezi počátečním a koncovým stavem dvě paralelní větve automatu.

Zde se nám hodí to, že automat je nedeterministický, takže při jeho průchodu
se vybere ta "příznivá" cesta vedoucí k cíli.

<img src="../pics/alternation.jpg" style="width: 300px">


### Kleeneho hvězda

Když je automat v nějakém stavu, tak kleeneho hvězda by znamenala udělat
přechod z tohoto stavu do něho samotného (udělat smyčku). Jenže my nevíme,
jestli počáteční a koncový stav nám zadaný je jeden a ten samý (dokonce na
začátku určitě není). Tedy opět se nám hodí to, že automat je nedeterministický
a můžeme použít epsilon přechody.

<img src="../pics/kleene.jpg" style="width: 300px">


### Epsilon

Epsilonový výraz vypadá stejně jako běžný symbol. Dokonce mají stejnou
implementaci (epsilon je jen specielním symbolem).

<img src="../pics/epsilon.jpg" style="width: 300px">


## Nedeterministický automat na regulární výraz

### Odstranění přebytečných epsilonů


## Nedeterministický automat na deterministický