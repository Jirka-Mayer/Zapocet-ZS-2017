# Regulární výraz

Formální regulární výrazy se od těch používaných v počítačích nepatrně liší. Například nepodporují operátory `?`, `[0-9]` a navíc se liší i notace operátorů. Tento program pracuje s výrazy formálními, tedy jediné operace jsou:

| Operace         | Znak operace                | Konstanta znaku        |
| --------------- | --------------------------- | ---------------------- |
| Symbol          | jakýkoliv jiný znak z ASCII | není                   |
| Konkatenace     | `.`                         | `CONCATENATION_SYMBOL` |
| Alternace       | `+`                         | `ALTERNATION_SYMBOL`   |
| Kleeneho hvězda | `*`                         | `KLEENE_SYMBOL`        |
| Epsilon         | `!`                         | `EPSILON_SYMBOL`       |

> Konstanty znaků jsou v souboru `RegularExpression.pas` a lze je změnit pro své potřeby.


## Serializace výrazu

Výraz se běžně zapisuje v infixové notaci s výjimkou kleeneho hvězdy, která je v postfixu. To je sice čitelný způsob, ale pracně se parsuje, proto jsem pro ukládání výrazů použil prefixovou.

> Je možné vypsat výraz v infixové notaci (plné závorek) pomocí funkce `RegularExpression.serializeInfix`. Funkce existuje kvůli lazení.

Soubor s výrazem má pod hlavičkou jeden řádek se serializovaným výrazem v prefixu, tedy výraz `/ax*|b/` bude v souboru (včetně hlavičky) vypadat takto:

    RE
    +.a*xb

tedy v rozepsané podobě:

    +(
        .(
            a,
            *(x)
        ),
        b
    )

> Pozor! Parser nepodporuje závorky, v prefixovém tvaru závorky nemají symsl.

Serializaci provádí funkce `RegularExpression.serializePrefix`, ta vrátí `AnsiString`.

Parsování řetězce provádí funkce `RegularExpression.parse` a vrátí ukazatel na výraz.


## Reprezentace výrazu v paměti

Regulární výraz je stromem binárních a unárních operátorů, je tedy logické ho jako strom reprezentovat. V paměti budou jednotlivé uzly a budou na sebe odkazovat pomocí pointerů (jako ve spojovém seznamu). Uzel stromu bude buď operátor s jedním nebo dvěma syny, nebo to bude symbol - uzel bez synů.

> Dědičnost struktur je popsaná v dokumentu [struktury programu](program-structure.md#dedicnost-struktur).

Uzel stromu je struktura `RegularExpression.TNode`, ve které je uložený typ uzlu a další vlastnosti se liší podle typu:

Symbolový uzel má vlastnost `symbol`, dále máme unární a binární operátor, které mají vlastnosti `a` a `a`, `b` respektive, které jsou pointerem na další uzly.

Jediným unárním operátorem je kleeneho hvězda, ostatní (konktenace, alternace) jsou binární.

Struktury konkrétního typu operátoru mají své ID (např. `NODE_TYPE__KLEENE`), ale jelikož nemají žádnou zvláštní logiku, přistupuje se k nim pouze jako k obecným strukturám operátorů. (tzn. neexistuje žádná struktura `TKleeneNode`)


### Epsilon symbol

Epsilon je reprezentován klasickým uzlem symbolu, jen hodnota symbolu je předem určená - konkrétně hodnota konstanty `RegularExpression.EPSILON_SYMBOL`.

> Na to se musí dávat pozor při práci se symbolovými uzly - metoda `isNodeOfType` s parametrem `NODE_TYPE__SYMBOL` vrátí `true` pro epsilonovou hranu.

> Žádný typ `NODE_TYPE__EPSILON` neexistuje.


### Prázdný jazyk

Jelikož se s výrazy pracuje jako s ukazateli na uzly, tak prázdný jazyk reprezentuje ukazatel s hodnotou `nil`.

Ten se smí nacházet pouze v kořeni, kdekoliv jinde je to považováno za chybu a program by se choval nepředpovídatelně.

> Poznámka: Nejsem si jistý, zda všechny metody pracující s regulárními výrazy kontrolují `nil` na všech příslušných místech. Kontrola probíhá jen na místech, kde se může vyskytovat prázdný jazyk. Je to možnost vylepšení programu do budoucna.