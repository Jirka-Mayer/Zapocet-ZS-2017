{
    Kód pro práci s regulárními výrazy
}
unit RegularExpression;

interface

{**
 * Konfigurace vzhledu regulárních výrazů
 *}
const ALTERNATION_SYMBOL = '+';
const CONCATENATION_SYMBOL = '.';
const KLEENE_SYMBOL = '*';
const EPSILON_SYMBOL = '!';

// identifikátory typů uzlů
const NODE_TYPE__EMPTY_SET = 0;       // 0
const NODE_TYPE__SYMBOL = 100;        // a
const NODE_TYPE__CONCATENATION = 200; // RS
const NODE_TYPE__ALTERNATION = 201;   // R|S
const NODE_TYPE__KLEENE = 202;        // R*

// Ukazatel na libovolný uzel stromu
// s těmito typy se pracuje ze vně knihovny
type PNode = Pointer;

function serializeInfix(expression: PNode): AnsiString;
function serializePrefix(expression: PNode): AnsiString;
procedure print(expression: PNode);
procedure destroyExpression(expression: PNode);
function parse(serialized: AnsiString): PNode;

function createSymbolNode(symbol: char): PNode;
function createEpsilonNode(): PNode;
function createConcatenationNode(a, b: PNode): PNode;
function createAlternationNode(a, b: PNode): PNode;
function createKleeneNode(a: PNode): PNode;
function clone(source: PNode): PNode;

function isNodeOfType(node: PNode; nodeType: byte): boolean;

// list stromu - symbol abecedy
type TSymbolNode = record
    nodeType: byte;
    symbol: char;
end;
type PSymbolNode = ^TSymbolNode;

// uzel binárního operátoru
type TBinaryOperatorNode = record
    nodeType: byte;
    a, b: PNode;
end;
type PBinaryOperatorNode = ^TBinaryOperatorNode;

// uzel unárního operátoru
type TUnaryOperatorNode = record
    nodeType: byte;
    a: PNode;
end;
type PUnaryOperatorNode = ^TUnaryOperatorNode;

implementation

// ukazatel na byte (protože ^byte(..) při přetypování mi blblo při kompilaci)
type PByte = ^byte;

////////////////////////
// Symbol node logika //
////////////////////////

{**
 * Vytvoří uzel symbolu - nějaký znak možného vstupu
 *}
function createSymbolNode(symbol: char): PNode;
var symbolNode: PSymbolNode;
begin
    new(symbolNode);

    symbolNode^.nodeType := NODE_TYPE__SYMBOL;
    symbolNode^.symbol := symbol;

    createSymbolNode := PNode(symbolNode);
end;

{**
 * Vytvoří uzel symbolu epsilon
 *}
function createEpsilonNode(): PNode;
begin
    createEpsilonNode := createSymbolNode(EPSILON_SYMBOL);
end;

{**
 * Uvolní z paměti uzel se symbolem
 *}
procedure destroySymbolNode(symbolNode: PNode);
begin
    if not isNodeOfType(symbolNode, NODE_TYPE__SYMBOL) then begin
        writeln('ERROR! Calling destroySymbolNode with wrong node type!');
        halt;
    end;

    // uvolníme paměť správné délky
    dispose(PSymbolNode(symbolNode));
end;

///////////////////////////////
// Concatenation node logika //
///////////////////////////////

{**
 * Vytvoří concatenation operátor
 * a, b - dva operandy operátoru
 *}
function createConcatenationNode(a, b: PNode): PNode;
var node: PBinaryOperatorNode;
begin
    new(node);

    node^.nodeType := NODE_TYPE__CONCATENATION;
    node^.a := a;
    node^.b := b;

    createConcatenationNode := PNode(node);
end;

{**
 * Uvolní z paměti uzel konkatenace
 *}
procedure destroyConcatenationNode(node: PNode);
begin
    if not isNodeOfType(node, NODE_TYPE__CONCATENATION) then begin
        writeln('ERROR! Calling destroyConcatenationNode with wrong node type!');
        halt;
    end;

    destroyExpression(PBinaryOperatorNode(node)^.a);
    destroyExpression(PBinaryOperatorNode(node)^.b);

    // uvolníme paměť správné délky
    dispose(PBinaryOperatorNode(node));
end;

/////////////////////////////
// Alternation node logika //
/////////////////////////////

{**
 * Vytvoří alternation operátor
 * a, b - dva operandy operátoru
 *}
function createAlternationNode(a, b: PNode): PNode;
var node: PBinaryOperatorNode;
begin
    new(node);

    node^.nodeType := NODE_TYPE__ALTERNATION;
    node^.a := a;
    node^.b := b;

    createAlternationNode := PNode(node);
end;

{**
 * Uvolní z paměti uzel konkatenace
 *}
procedure destroyAlternationNode(node: PNode);
begin
    if not isNodeOfType(node, NODE_TYPE__ALTERNATION) then begin
        writeln('ERROR! Calling destroyAlternationNode with wrong node type!');
        halt;
    end;

    destroyExpression(PBinaryOperatorNode(node)^.a);
    destroyExpression(PBinaryOperatorNode(node)^.b);

    // uvolníme paměť správné délky
    dispose(PBinaryOperatorNode(node));
end;

////////////////////////
// Kleene node logika //
////////////////////////

{**
 * Vytvoří kleene star operátor
 *}
function createKleeneNode(a: PNode): PNode;
var node: PUnaryOperatorNode;
begin
    new(node);

    node^.nodeType := NODE_TYPE__KLEENE;
    node^.a := a;

    createKleeneNode := PNode(node);
end;

{**
 * Uvolní z paměti uzel kleene star
 *}
procedure destroyKleeneNode(node: PNode);
begin
    if not isNodeOfType(node, NODE_TYPE__KLEENE) then begin
        writeln('ERROR! Calling destroyKleeneNode with wrong node type!');
        halt;
    end;

    destroyExpression(PUnaryOperatorNode(node)^.a);

    dispose(PUnaryOperatorNode(node));
end;

//////////////////////////////
// Logika obecně pro výrazy //
//////////////////////////////

{**
 * Vytvoří kopii regulárního výrazu
 *}
function clone(source: PNode): PNode;
begin
    if isNodeOfType(source, NODE_TYPE__SYMBOL) then begin
        clone := createSymbolNode(PSymbolNode(source)^.symbol);
    end else if isNodeOfType(source, NODE_TYPE__CONCATENATION) then begin
        clone := createConcatenationNode(
            clone(PBinaryOperatorNode(source)^.a),
            clone(PBinaryOperatorNode(source)^.b)
        );
    end else if isNodeOfType(source, NODE_TYPE__ALTERNATION) then begin
        clone := createAlternationNode(
            clone(PBinaryOperatorNode(source)^.a),
            clone(PBinaryOperatorNode(source)^.b)
        );
    end else if isNodeOfType(source, NODE_TYPE__KLEENE) then begin
        clone := createKleeneNode(
            clone(PUnaryOperatorNode(source)^.a)
        );
    end else begin
        writeln('ERROR! unknown node type in clone()');
        halt;
    end;
end;

{**
 * Kontroluje, zda je uzel daného typu
 *
 * node - testovaný uzel
 * nodeType - jedna z konstant NODE_TYPE__
 *}
function isNodeOfType(node: PNode; nodeType: byte): boolean;
begin
    // nil se testuje jinak
    if nodeType = NODE_TYPE__EMPTY_SET then begin
        isNodeOfType := node = nil;
        exit;
    end;

    // zde už by nil neměl být
    if node = nil then begin
        writeln('ERROR! isNodeOfType, nil given');
        halt;
    end;

    // klasický test - kouknout na typovou hodnotu
    isNodeOfType := PByte(node)^ = nodeType;
end;

{**
 * Převede regulární výraz na text v infixovém tvaru
 *}
function serializeInfix(expression: PNode): AnsiString;
begin
    serializeInfix := '';

    if isNodeOfType(expression, NODE_TYPE__SYMBOL) then begin
        serializeInfix += PSymbolNode(expression)^.symbol;
    end else if isNodeOfType(expression, NODE_TYPE__CONCATENATION) then begin
        serializeInfix += '(' +
            serializeInfix(PBinaryOperatorNode(expression)^.a)
            + CONCATENATION_SYMBOL +
            serializeInfix(PBinaryOperatorNode(expression)^.b) + ')';
    end else if isNodeOfType(expression, NODE_TYPE__ALTERNATION) then begin
        serializeInfix += '(' +
            serializeInfix(PBinaryOperatorNode(expression)^.a)
            + ALTERNATION_SYMBOL +
            serializeInfix(PBinaryOperatorNode(expression)^.b) + ')';
    end else if isNodeOfType(expression, NODE_TYPE__KLEENE) then begin
        serializeInfix += '(' +
            serializeInfix(PBinaryOperatorNode(expression)^.a)
            + ')' + KLEENE_SYMBOL;
    end else begin
        writeln('ERROR! unknown node type in serializeInfix()');
        halt;
    end;
end;

{**
 * Převede regulární výraz na text v prefixovém tvaru
 *}
function serializePrefix(expression: PNode): AnsiString;
begin
    serializePrefix := '';

    if isNodeOfType(expression, NODE_TYPE__SYMBOL) then begin
        serializePrefix += PSymbolNode(expression)^.symbol;
    end else if isNodeOfType(expression, NODE_TYPE__CONCATENATION) then begin
        serializePrefix += 
            CONCATENATION_SYMBOL +
            serializePrefix(PBinaryOperatorNode(expression)^.a) +
            serializePrefix(PBinaryOperatorNode(expression)^.b);
    end else if isNodeOfType(expression, NODE_TYPE__ALTERNATION) then begin
        serializePrefix += 
            ALTERNATION_SYMBOL +
            serializePrefix(PBinaryOperatorNode(expression)^.a) +
            serializePrefix(PBinaryOperatorNode(expression)^.b);
    end else if isNodeOfType(expression, NODE_TYPE__KLEENE) then begin
        serializePrefix +=
            KLEENE_SYMBOL +
            serializePrefix(PBinaryOperatorNode(expression)^.a);
    end else begin
        writeln('ERROR! unknown node type in serializePrefix()');
        halt;
    end;
end;

{**
 * Serializuje výraz na standartní výstup
 *}
procedure print(expression: PNode);
begin
    writeln(serializeInfix(expression));
end;

{**
 * Uvolní z paměti daný výraz
 *}
procedure destroyExpression(expression: PNode);
begin
    // provedeme uvolnění podle typu
    if isNodeOfType(expression, NODE_TYPE__SYMBOL) then begin
        destroySymbolNode(expression);
    end else if isNodeOfType(expression, NODE_TYPE__CONCATENATION) then begin
        destroyConcatenationNode(expression);
    end else if isNodeOfType(expression, NODE_TYPE__ALTERNATION) then begin
        destroyAlternationNode(expression);
    end else if isNodeOfType(expression, NODE_TYPE__KLEENE) then begin
        destroyKleeneNode(expression);
    end else begin
        writeln('ERROR! unknown node type in destroyExpression()');
        halt;
    end;
end;

/////////////
// Parsing //
/////////////

// privátní globální proměnné pro parser
var textToParse: AnsiString;
var textToParse_start, textToParse_end: integer;

// vrátí další písmeno vstupu bez ukousnutí
function parserSeek(): char;
begin
    parserSeek := textToParse[textToParse_start];
end;

// vrátí a vykousne další písmeno vstupu
function parserPop(): char;
begin
    parserPop := textToParse[textToParse_start];
    textToParse_start += 1;
end;

// vrátí true, pokud jsme v parsování dorazili na konec vstupu
function parserEnd(): boolean;
begin
    parserEnd := textToParse_start > textToParse_end;
end;

// dopředná deklarace kvůli rekurentnímu volání
function parseStart: PNode; forward;

// vypíše chybu při parsování
procedure parserError(message: AnsiString);
begin
    writeln('Parser error!');
    writeln(message);
    writeln('============================');
    writeln('input:');
    writeln(textToParse);
    writeln('at: ', textToParse_start);
    halt;
end;

// zkusí zparsovat symbol
function parseSymbol(): PNode;
var s: char;
begin
    if parserEnd() then
        parserError('Parsing symbol but parser already ended');

    s := parserSeek();
    if not ((s in ['A'..'Z']) or (s in ['a' .. 'z'])) then
        parserError('Uknown symbol character');

    parseSymbol := createSymbolNode(parserPop());
end;

// zparsuje konkatonaci
function parseConcatenation(): PNode;
var a, b: PNode;
begin
    if parserEnd() then
        parserError('Parsing concatenation but parser already ended');

    if parserPop() <> CONCATENATION_SYMBOL then
        parserError('Parsing concat but no concat symbol found');

    // nevolám v argumentu, protože zálží na volací konvenci
    // může mi to vyhodnotit odzadu (a taky se tak stalo)
    a := parseStart();
    b := parseStart();
    parseConcatenation := createConcatenationNode(a, b);
end;

// zparsuje alternaci
function parseAlternation(): PNode;
var a, b: PNode;
begin
    if parserEnd() then
        parserError('Parsing alternation but parser already ended');

    if parserPop() <> ALTERNATION_SYMBOL then
        parserError('Parsing alternation but no alternation symbol found');

    // nevolám v argumentu, protože zálží na volací konvenci
    // může mi to vyhodnotit odzadu (a taky se tak stalo)
    a := parseStart();
    b := parseStart();
    parseAlternation := createAlternationNode(a, b);
end;

// zparsuje kleene star
function parseKleene(): PNode;
begin
    if parserEnd() then
        parserError('Parsing kleene but parser already ended');

    if parserPop() <> KLEENE_SYMBOL then
        parserError('Parsing kleene but no kleene symbol found');

    // tady je jen jeden argument, nezáleží na
    // volací konvenci, ale jinak POZOR!
    parseKleene := createKleeneNode(parseStart());
end;

// start parseru - zkusí zparsovat cokoliv
function parseStart(): PNode;
begin
    if parserSeek() = CONCATENATION_SYMBOL then begin
        parseStart := parseConcatenation();
    end else if parserSeek() = ALTERNATION_SYMBOL then begin
        parseStart := parseAlternation();
    end else if parserSeek() = KLEENE_SYMBOL then begin
        parseStart := parseKleene();
    end else begin
        parseStart := parseSymbol();
    end;
end;

{**
 * Načte výraz z textu (V prefixovém tvaru!)
 *
 * Vrátí nil v případě chyby
 *}
function parse(serialized: AnsiString): PNode;
begin
    textToParse := serialized;
    textToParse_start := 1;
    textToParse_end := length(serialized);

    parse := parseStart();
end;

end.