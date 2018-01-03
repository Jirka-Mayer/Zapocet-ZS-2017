# Testování

Testování se skládá ze dvou částí - unity testy a feature testy.


## Unit testy

Unit testy jsem psal v průběhu vývoje programu k testování jednotlivých procedur. K takovémuto testování je zapotřebí nějaké testovací prostředí/framework, ale nechtěl jsem nutně hned sahat po nějakých ohromných knihovnách, tak jsem si napsal vlastní drobnou.

Testovací knihovna je v jednotce `TestingFramework.pas` a umožňuje porovnávat hodnoty a při neshodě vypsat nějakou hezkou chybu. Navíc umožňuje pojmenovat skupinu testů (test suite).

Každá jednodka má k sobě připojenou jednotku s příponou `_Tests`, ve které se nacházejí právě unit testy. Každá tato jednotka musí implementovat veřejnou proceduru `runTests` a všechny tyto jednotky se načtou v programu `TestRunner.pas`, který provede jejich spuštění.

Testování tedy probíhá tak, že zkompiluji `TestRunner` - to mi provede syntaktickou a sémantickou kontrolu a jeho spuštěním provedeme kontrolu logickou.

> Poznámka: Program jsem nevyvíjel v IDE, ale v textovém editoru (Sublime Text) a kompiloval z příkazové řádky pomocí `fpc`.


## Feature testy

Nakonec jsem potřeboval otestovat, že program pracuje jako celek, včetně načítání souborů. Takže jsem napsal trochu kódu schopného kontrolovat shodnost souborů a vstupní/výstupní data testů jsem uložil pro několik případů do složky `tests/`.

Testů není mnoho, ale myšlenka je taková, že pokud se v programu objeví bug, mělo by stačit vytvořit vstupní data, která bug způsobí, přidat je mezi feature testy a bug opravit. Tím víme, že se podobná chyba v programu v budoucnu neobjeví, protože bude součástí databáze feature testů.