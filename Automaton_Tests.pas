unit Automaton_Tests;

interface

procedure runTests();

implementation

uses TestingFramework, Automaton, List;

procedure runTests();
var aut: PAutomaton;
var a, b: PState;
var e: PEdge;
begin
    TestingFramework.testSuite('Automaton');

    // vytvoříme automat
    aut := createAutomaton();

    // přidáme dva stavy
    a := createState(aut, true, false);
    b := createState(aut, false, true);

    // a otestujeme, že jsou kde mají být
    TestingFramework.assertIntEquals(1, List.indexOf(aut^.states, a));
    TestingFramework.assertIntEquals(2, List.indexOf(aut^.states, b));
    TestingFramework.assertIntEquals(1, List.indexOf(aut^.initialStates, a));
    TestingFramework.assertIntEquals(1, List.indexOf(aut^.finalStates, b));

    // přidáme hranu
    e := createSymbolEdge(aut, a, b, 'x');

    // a otestujeme, že je kde má být
    TestingFramework.assertIntEquals(1, List.indexOf(aut^.edges, e));
    TestingFramework.assertIntEquals(1, List.indexOf(a^.edges, e));
    TestingFramework.assertPointerEquals(a, e^.origin);
    TestingFramework.assertPointerEquals(b, e^.target);

    // zkusíme serializovat stavy a hranu
    TestingFramework.assertStringEquals('IF', serializeStates(aut));
    TestingFramework.assertStringEquals('1 2 S x', serializeEdge(aut, e));

    // už nebudeme potřebovat tenhle automat
    Automaton.destroy(aut);

    // zkusíme parsování stavů
    aut := createAutomaton();
    parseStates(aut, 'IXF');
    TestingFramework.assertStringEquals('IXF', serializeStates(aut));

    // přidáme parsování hran
    e := parseEdge(aut, '1 2 S a');
    TestingFramework.assertStringEquals('1 2 S a', serializeEdge(aut, e));
    e := parseEdge(aut, '2 3 E');
    TestingFramework.assertStringEquals('2 3 E', serializeEdge(aut, e));
    e := parseEdge(aut, '1 3 R +ab');
    TestingFramework.assertStringEquals('1 3 R +ab', serializeEdge(aut, e));
end;

end.