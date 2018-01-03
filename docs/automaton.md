# Automat

Deterministický konečný automat je množina stavů, z nichž jeden je počáteční a některé mohou být koncové a množina orientovaných hran (přechodů) mezi stavy, každá ohodnocená nějakým symbolem.

Nedeterministický může mít více než jeden počáteční stav a více hran z jednoho stavu pro stejný symbol. Navíc může obsahovat epsilon přechody.

> Poznámka: Program nijak nerozlišuje typ automatu za běhu. Pokud funkce očekává deterministický automat a dostane nedeterministický, bude s ním pracovat jako s deterministickým, v lepším případě skončí program chybou, v horším vrátí výsledek s epsilonem jako běžným symbolem.

V programu existuje ještě speciální typ automatu, který je nedeterministický, ale hrany nejsou ohodnoceny symbolem, ale regulárním výrazem. Tento automat se používá pouze při převodu `NDA` na `RE` a jedná se o interní záležitost.


## Serializace automatu

Automat je množina stavů a množina přechodů.

Stavy lze serializovat pomocí funkce `Automaton.serializeStates`, ta vrátí řetězec, kde každý znak reprezentuje jeden stav. Jeho pořadí je index stavu a znak může být jedním ze čtyř možných.

- `X` je obecný stav
- `I` je počáteční stav
- `F` je koncový stav
- `T` je stav, který je začáteční a koncový zároveň

Tedy serializované stavy automatu se čtyřmi stavy mohou vypadat takto:

    IXXF

Hrany se serializují po jedné - každá na samostatný řádek. Řetězec obsahuje mezerami oddělené: index počátečního stavu, index cílového stavu, typ stavu (symbol/epsilon) a pokud je přechod symbolový, tak ještě symbol.

> Indexace stavů začíná jedničkou (ne nulou) - v rámci pascalového zvyku

Hrana ze stavu 2 do stavu 5, symbolová na symbol `a` vypadá takto:

    2 5 S a

V souboru je za hlavičkou nejprve řádek stavů a poté je na každém řádku jedna hrana.

Automat odpovídající výrazu `/a(x|y)/` by vypadal následovně:

    DA
    IXF
    1 2 S a
    2 3 S x
    2 3 S y

Epsilonová hrana vypadá třeba takto:

    5 3 E

> Poznámka: V serializaci automatu sice není epsilonový symbol, ale vnitřně je epsilonový přechod implementován jako symbolový se symbolem `RegularExpression.EPSILON_SYMBOL`.


## Reprezentace automatu v paměti

Automat je reprezentován strukturou `Automaton.TAutomaton`. Jejím obsahem je množina stavů `states` a množina hran `edges`. Počáteční a koncové stavy jsou pro lepší přístupnost ještě vypsány ve vlastnostech `initialStates` a `finalStates`.

Stav je struktura `Automaton.TState`. Obsahuje informaci, zda je stav počáteční nebo koncový - `isInitial`, `isFinal` a seznam hran, které ze stavu vedou `edges`.

> V seznamech se ukládají pouze pointery na hray, takže lze snadno kontolovat rovnost dvou hran, nedochází ke kopírování dat hrany a lze mít i kruhové odkazy (stav > hrana > stav).

Hrana je reprezentována strukturou `Automaton.TEdge`, která obsahuje odkaz na počáteční stav `origin` a cílový stav `target`. Struktura samotná se ale nepoužívá, spíše její dvě varianty: hrana symbolová `TSymbolEdge` a hrana s regulárním výrazem `TRegexEdge`.


### Epsilon přechod

Epsilon přechod je stejně jako v případě regulárních výrazů reprezentován symbolovou hranou, kde symbol se rovná konstantě `RegularExpression.EPSILON_SYMBOL`.


### Prázdný jazyk

Prázdný jazyk vyplývá z konkrétní struktury automatu, není třeba ho definovat jako explicitní hodnotu.