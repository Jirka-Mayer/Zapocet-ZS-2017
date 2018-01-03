# Struktura programu

Program je rozdělen na jednotky `unit`, kde každá má na starost jednu věc. Umožňuje to využít ty samé procedury jak v programu samotném, tak v [testech](testing.md). Právě v rámci testování má každá jednotka svoji verzi `_Tests`, která obsahuje příslušné unit testy.

Hlavní program je v souboru `MainProgram.pas`. Obsahuje minimální množství kódu - jen slepí volání programu s argumenty s jednotkou `Converter`.

Testy se spouští programem `TestRunner.pas`, více v [sekci o testování](testing.md).

Jednotka `Converter.pas` obsahuje veškerou logiku převodů mezi jednotlivými entitami.

Jednotky `RegularExpression.pas` a `Automaton.pas` obsahují logiku pro vytváření a práci s regulárními výrazy a automaty.

Jednotka `List.pas` obsahuje pomocné funkce pro práci se spojovými seznamy.


## Dědičnost struktur

Jelikož je kód plný dědičných datových typů (hrana > symbolová hrana), je potřeba mít nějakou dědičnost i v datech. Řešením by bylo použití objektivně orientovaného programování. K úkolu jsem si ale vybral pascal, jednak jako jeho procvičení, ale také za účelem procvičení pointerů na předmět principy počítačů. Jinak bych si zvolil python a na celý problém se vrhnul čistě objektivně a bez použití pointerů:

```python
class Edge():
    ...

class SymbolEdge(Edge):
    ...
```

> V pythnou by se mi jistě mnohem snáze ladilo a nemusel bych si programovat jednotku `List.pas`.

Dědičnosti jsem docílil díky možnosti přetypovat pointer a typ struktury jsem uložil v prvním bajtu každé struktury (které se dědičnosti účastní).

Hodnoty tohoto bajtu pro jednotlivé typy jsou uloženy v konstantách (například `NODE_TYPE__SYMBOL`).

## Jazyk (přirozený)

Kód jsem psal anglicky, protože diakritika v kódu většinou nefunguje a bez ní se těžko určuje, co autor myslel.

> `rada` je `hint`, nebo `series`?


## Proč zrovna `AnsiString`?

Načítání entit ze souboru by jistě šlo udělat přímo bez potřeby nejdříve načíst obsah řádky souboru do stringové proměnné. To akorát přináší omezení v podobě maximální délky stringu a zbytečné zabírání paměti. Což by byl problém pro velké automaty a výrazy, program je ale míněný jako "proof of concept", nepočítám, že by do něho někdo cpal takový objem dat.

> Některé části programu by se daly impementovat i lépe z hlediska časové složitosti.

Důvodem byla snadná testovatelnost. Je hezčí, když proceduře mohu předat string a testovat, co z ní vypadne, nebo naopak hlídat, jaký string z ní padá.

Jelikož je ale klasický `string` omezený na 256 znaků, použil jsem `AnsiString`.