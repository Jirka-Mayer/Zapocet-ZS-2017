unit Converter;

interface

uses RegularExpression, Automaton, List;

function regexToNondeterministic(exp: RegularExpression.PNode): Automaton.PAutomaton;
function nondeterministicToRegex(aut: Automaton.PAutomaton): RegularExpression.PNode;
function nondeterministicToDeterministic(nda: Automaton.PAutomaton): Automaton.PAutomaton;

implementation

//////////////////////////////////////////
// Regulární výraz na nedeterministický //
//////////////////////////////////////////

// rekurzivní tělo metody
procedure regexToNondeterministic_body(
    aut: Automaton.PAutomaton;
    exp: RegularExpression.PNode;

    // mezi těmito dvěma uzly se má vytvořit pod-automat
    initial: Automaton.PState;
    final: Automaton.PState
);
// pomocné proměnné pro ukládání stavů
var s: Automaton.PState;
begin
    if RegularExpression.isNodeOfType(exp, NODE_TYPE__SYMBOL) then begin
        Automaton.createSymbolEdge(
            aut, initial, final,
            RegularExpression.PSymbolNode(exp)^.symbol
        );
    end else if RegularExpression.isNodeOfType(exp, NODE_TYPE__CONCATENATION) then begin
        s := Automaton.createState(aut, false, false);
        regexToNondeterministic_body(
            aut, RegularExpression.PBinaryOperatorNode(exp)^.a, initial, s);
        regexToNondeterministic_body(
            aut, RegularExpression.PBinaryOperatorNode(exp)^.b, s, final);
    end else if RegularExpression.isNodeOfType(exp, NODE_TYPE__ALTERNATION) then begin
        regexToNondeterministic_body(
            aut, RegularExpression.PBinaryOperatorNode(exp)^.a, initial, final);
        regexToNondeterministic_body(
            aut, RegularExpression.PBinaryOperatorNode(exp)^.b, initial, final);
    end else if RegularExpression.isNodeOfType(exp, NODE_TYPE__KLEENE) then begin
        s := Automaton.createState(aut, false, false);
        Automaton.createEpsilonEdge(aut, initial, s);
        regexToNondeterministic_body(
            aut, RegularExpression.PUnaryOperatorNode(exp)^.a, s, s);
        Automaton.createEpsilonEdge(aut, s, final);
    end else begin
        writeln('ERROR! regexToNondeterministic_body() - unsupported node type');
        halt;
    end;
end;

{**
 * Převede regulární výraz na nedeterministický automat
 *}
function regexToNondeterministic(exp: RegularExpression.PNode): Automaton.PAutomaton;
var aut: Automaton.PAutomaton;
var initial, final: Automaton.PState;
begin
    // vytvoříme prázdný automat
    aut := Automaton.createAutomaton();

    // přidáme do něho počáteční a koncový stav
    initial := Automaton.createState(aut, true, false);
    final := Automaton.createState(aut, false, true);

    // a vytvoříme tělo automatu rekurzivně
    regexToNondeterministic_body(aut, exp, initial, final);

    // a vrátíme ho
    regexToNondeterministic := aut;
end;

//////////////////////////////////////////
// Nedeterministický na regulární výraz //
//////////////////////////////////////////

{**
 * Převede nedeterministický automat na regulární výraz
 * (destruktivně, automat se při tom zničí)
 *}
function nondeterministicToRegex(aut: Automaton.PAutomaton): RegularExpression.PNode;
var initial, final: Automaton.PState;
var s, input, output: List.PList;
var inputs, outputs: List.PList;
var loop: Automaton.PRegexEdge;
begin
    // přidáme (hlavní) počáteční a koncový vrchol
    // (ale nebudou mít flag, aby nebyly v seznamech)
    initial := Automaton.createState(aut, false, false);
    final := Automaton.createState(aut, false, false);

    // spojím je epsilon přechodem s ostatními
    s := aut^.initialStates;
    while s <> nil do begin
        Automaton.createEpsilonEdge(aut, initial, Automaton.PState(s^.item));
        s := s^.next;
    end;

    s := aut^.finalStates;
    while s <> nil do begin
        Automaton.createEpsilonEdge(aut, Automaton.PState(s^.item), final);
        s := s^.next;
    end;

    // hrany převedeme na regex typ
    Automaton.edgesToRegex(aut);

    // jdeme přes všechny stavy mezi počátečním a koncovým
    s := aut^.states;
    while s <> nil do begin
        // přes všechny stavy krom začátečního a koncového
        if (s^.item = initial) or (s^.item = final) then begin
            s := s^.next;
            continue;
        end;

        // DEBUG
        //Automaton.printAutomaton(aut);

        // najdeme smyčku a vyzobneme ji
        // (musí být první - smyčka je jak vstup, tak výstup)
        loop := Automaton.PRegexEdge(
            Automaton.pickLoop(aut, Automaton.PState(s^.item)));

        // vyzobeme všechny vstupní hrany
        inputs := Automaton.pickInputEdges(aut, Automaton.PState(s^.item));

        // vyzobeme všechny výstupní hrany
        outputs := Automaton.pickOutputEdges(aut, Automaton.PState(s^.item));

        // pro každou kombinaci vstup/výstup vložíme novou hranu
        input := inputs;
        while input <> nil do begin
            output := outputs;
            while output <> nil do begin

                // vytvoříme hranu bez smyčky
                if loop = nil then begin
                    Automaton.createRegexEdge(aut,
                        PEdge(input^.item)^.origin,
                        PEdge(output^.item)^.target,
                        RegularExpression.createConcatenationNode(
                            RegularExpression.clone(PRegexEdge(input^.item)^.expression),
                            RegularExpression.clone(PRegexEdge(output^.item)^.expression)
                        )
                    );
                // vytvoříme hranu se smyčkou
                end else begin
                    Automaton.createRegexEdge(aut,
                        PEdge(input^.item)^.origin,
                        PEdge(output^.item)^.target,
                        RegularExpression.createConcatenationNode(
                            RegularExpression.clone(PRegexEdge(input^.item)^.expression),
                            RegularExpression.createConcatenationNode(
                                RegularExpression.createKleeneNode(
                                    RegularExpression.clone(loop^.expression)
                                ),
                                RegularExpression.clone(PRegexEdge(output^.item)^.expression)
                            )
                        )
                    );
                end;

                output := output^.next;
            end;
            input := input^.next;
        end;

        // zahodíme původní hrany (z paměti)
        input := inputs;
        while input <> nil do begin
            Automaton.destroyEdge(PEdge(input^.item));
            input := input^.next;
        end;
        List.destroy(input);

        output := outputs;
        while output <> nil do begin
            Automaton.destroyEdge(PEdge(output^.item));
            output := output^.next;
        end;
        List.destroy(output);

        // odstraníme stav
        // (vlastně nemusíme, ono by se akorát posunuly indexy a bylo by
        // těžší program ladit, navíc se automat stejně nakonec zahodí)

        // další stav
        s := s^.next;
    end;

    // vrátíme zbylý regulární výraz mezi počátečním a koncovým stavem
    nondeterministicToRegex := RegularExpression.clone(
        Automaton.PRegexEdge(initial^.edges^.item)^.expression);
end;

//////////////////////////////////////////
// Nedeterministický na deterministický //
//////////////////////////////////////////

// tabulka potřebná pro výpočet
type TStateTable = record
    // možné množiny stavů (záznamy v tabulce)
    records: List.PList; // of TTableRecord

    // množiny stavů, u kterých se ještě neví kam se zobrazí
    unresolved: List.PList; // of List of Set (List) of PState
end;

// záznam v tabulce
type
    PTableRecord = ^TTableRecord;
    TTableRecord = record
        // počáteční stav (množina stavů)
        stateSet: List.PList; // Set of PState

        // přechody do jiných stavů
        transitions: List.PList; // of TStateTransition

        // reprezentující stav v deterministickém automatu
        daState: Automaton.PState;
    end;

// u každého záznamu mapa, na který znak kam přejde
type
    PStateTransition = ^TStateTransition;
    TStateTransition = record
        symbol: char;
        stateSet: List.PList; // (set) of PState
    end;

{**
 * Procedura na lazení - vytiskne na výstup množinu stavů
 *}
procedure printStateSet(aut: Automaton.PAutomaton; stateSet: List.PList);
begin
    write('{');
    while stateSet <> nil do begin
        write(List.indexOf(aut^.states, stateSet^.item), ', ');
        stateSet := stateSet^.next;
    end;
    writeln('}');
end;

{**
 * Přidá do záznamu přechod na symbol do stavu
 *
 * (vrací hodnotu jen pro ladící účely)
 *}
function addTransitionToRecord(
    rec: PTableRecord;
    symbol: char;
    target: Automaton.PState
): PStateTransition;
var t, s: List.PList;
var transition: PStateTransition;
begin
    // najdeme přechod pro daný symbol
    transition := nil;
    t := rec^.transitions;
    while t <> nil do begin
        if PStateTransition(t^.item)^.symbol = symbol then begin
            transition := PStateTransition(t^.item);
            break;
        end;
        t := t^.next;
    end;

    // pokud žádný není, vytvoříme
    if transition = nil then begin
        new(transition);
        transition^.symbol := symbol;
        transition^.stateSet := nil;
        List.append(rec^.transitions, transition);
    end;

    // zkontrolujeme, že v množině stavů náš stav není,
    // pokud ano, nemusíme nic dělat
    s := transition^.stateSet;
    while s <> nil do begin
        if s^.item = target then
            exit; 
        s := s^.next;
    end;

    // přidáme do množiny stavů náš stav
    List.append(transition^.stateSet, target);

    // vrátíme přechod:
    addTransitionToRecord := transition;
end;

{**
 * Vrátí true, pokud je daná stavová množina v seznamu table.records
 *}
function isStateSetResolved(var table: TStateTable; stateSet: List.PList): boolean;
var rec: List.PList;
begin
    isStateSetResolved := false;

    // projdeme všechny záznamy a porovnáme
    rec := table.records;
    while rec <> nil do begin
        // pokud se stavy shodují, je tento stav v seznamu
        if List.setsEqual(PTableRecord(rec^.item)^.stateSet, stateSet) then begin
            isStateSetResolved := true;
            exit;
        end;

        rec := rec^.next;
    end;
end;

{**
 * Vrátí true, pokud je daná stavová množina v seznamu table.unresolved
 *}
function isStateSetInUnresolvedList(var table: TStateTable; stateSet: List.PList): boolean;
var s: List.PList;
begin
    isStateSetInUnresolvedList := false;

    // projdeme záznamy a porovnáme
    s := table.unresolved;
    while s <> nil do begin
        // pokud se stavy shodují, je v seznamu
        if List.setsEqual(s^.item, stateSet) then begin
            isStateSetInUnresolvedList := true;
            exit;
        end;

        s := s^.next;
    end;
end;

{**
 * Z daného stavu (množiny stavů) vytvoří záznam v tabulce
 *}
procedure renderStateSet(
    aut: Automaton.PAutomaton;
    var table: TStateTable;
    stateSet: List.PList
);
var rec: PTableRecord;
var s, e, t: List.PList;
//var transition: PStateTransition; // DEBUG
begin
    // DEBUG
    //writeln();
    //write('Render state set: ');
    //printStateSet(aut, stateSet);

    // vytvoříme záznam tabulky
    new(rec);
    rec^.stateSet := List.clone(stateSet);
    rec^.transitions := nil;
    rec^.daState := nil;

    // přes všechny stavy NDA
    s := stateSet;
    while s <> nil do begin
        // a přes všechny hrany v tom stavu
        e := Automaton.PState(s^.item)^.edges;
        while e <> nil do begin
            // zkontrolujeme, že je hrana symbolová
            if not Automaton.isEdgeOfType(e^.item, EDGE_TYPE__SYMBOL) then begin
                writeln('ERROR! converting NDA to DA, but NDA has non-symbol edges!');
                halt;
            end;

            // zobrazíme stav na cílový
            // a ten přidáme do záznamu
            {transition := }addTransitionToRecord(
                rec,
                Automaton.PSymbolEdge(e^.item)^.symbol,
                Automaton.PSymbolEdge(e^.item)^.target
            );

            // DEBUG
            //writeln('Adding transition [', transition^.symbol, ']:');
            //write('state set sofar: ');
            //printStateSet(aut, transition^.stateSet);

            e := e^.next;
        end;

        s := s^.next;
    end;

    // přidáme záznam do tabulky
    // (důležité, protože ji budeme hnedka prohledávat)
    List.append(table.records, rec);
    
    // projdeme vzniklé stavy (množiny)
    t := rec^.transitions;
    while t <> nil do begin
        s := PStateTransition(t^.item)^.stateSet; // recyklujem proměnnou "s"

        // a která množina není vyřešená, přidáme do unresolved
        if not isStateSetResolved(table, s) then begin
            // ale jen pokud v unresolved už není
            if not isStateSetInUnresolvedList(table, s) then begin
                List.append(table.unresolved, List.clone(s));
            end;
        end;

        t := t^.next;
    end;
end;

{**
 * Vrátí true, pokud je množina stavů koncová
 * (obsahuje alespoň jeden koncový stav)
 *}
function isStateSetFinal(stateSet: List.PList): boolean;
begin
    while stateSet <> nil do begin
        if Automaton.PState(stateSet^.item)^.isFinal then begin
            isStateSetFinal := true;
            exit;
        end;
        stateSet := stateSet^.next;
    end;

    isStateSetFinal := false;
end;

{**
 * Vrátí stav deterministického automatu odpovídající dané množině stavů NDA
 *}
function getDaState(var table: TStateTable; stateSet: List.PList): Automaton.PState;
var rec: List.PList;
begin
    rec := table.records;
    while rec <> nil do begin
        if List.setsEqual(PTableRecord(rec^.item)^.stateSet, stateSet) then begin
            getDaState := PTableRecord(rec^.item)^.daState;
            exit;
        end;
        rec := rec^.next;
    end;

    writeln('ERROR! getDaState() - no corresponding state found');
    halt;
end;

{**
 * Převede nedeterministický automat na deterministický
 * (vytvoří nový, starý zachová)
 *}
function nondeterministicToDeterministic(nda: Automaton.PAutomaton): Automaton.PAutomaton;
var da: Automaton.PAutomaton;
var table: TStateTable;
var stateSet: List.PList;
var r, t: List.PList;
var first: boolean;
begin

    //
    // vytvoříme tabulku stavů
    //
    
    table.records := nil;
    table.unresolved := nil;
    List.append(table.unresolved, List.clone(nda^.initialStates));
    while table.unresolved <> nil do begin // dokud máme něco na práci
        // vytáhneme další stav
        stateSet := List.pop(table.unresolved);

        // provedeme jeho zobrazení
        renderStateSet(nda, table, stateSet);

        // množinu stavů můžeme zahodit
        List.destroy(stateSet);
    end;

    //
    // vytvoříme deterministický automat z tabulky
    // 

    da := Automaton.createAutomaton();

    // vytvoříme příslušný počet stavů ve správném pořadí
    r := table.records;
    first := true; // první stav je počáteční
    while r <> nil do begin
        PTableRecord(r^.item)^.daState := Automaton.createState(
            da, first, isStateSetFinal(PTableRecord(r^.item)^.stateSet));
        first := false;
        r := r^.next;
    end;

    // znovu projdeme stavy a vytvoříme příslušné hrany
    r := table.records;
    while r <> nil do begin
        // projdeme všechny hrany
        t := PTableRecord(r^.item)^.transitions;
        while t <> nil do begin
            Automaton.createSymbolEdge(da,
                PTableRecord(r^.item)^.daState,
                getDaState(table, PStateTransition(t^.item)^.stateSet),
                PStateTransition(t^.item)^.symbol
            );
            t := t^.next;
        end;
        r := r^.next;
    end;

    //
    // dokončení
    // 

    // zahodíme tabulku
    r := table.records;
    while r <> nil do begin
        // projdeme všechny hrany
        t := PTableRecord(r^.item)^.transitions;
        while t <> nil do begin
            List.destroy(PStateTransition(t^.item)^.stateSet);
            dispose(PStateTransition(t^.item));
            t := t^.next;
        end;
        List.destroy(PTableRecord(r^.item)^.transitions);
        dispose(PTableRecord(r^.item));

        r := r^.next;
    end;
    List.destroy(table.records);

    // table.unresolved už je nil, není třeba mazat

    // vrátíme automat
    nondeterministicToDeterministic := da;
end;

end.