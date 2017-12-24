unit RegularExpression_Tests;

interface

procedure runTests;

implementation

uses TestingFramework, RegularExpression;

procedure testSerialization(expression: AnsiString);
var e: PNode;
begin
    e := parse(expression);
    TestingFramework.assertStringEquals(expression, serializePrefix(e));
    destroyExpression(e);
end;

procedure runTests();
var a, b: PNode;
begin
    TestingFramework.testSuite('RegularExpression');

    // symbol
    a := createSymbolNode('a');
    TestingFramework.assertStringEquals('a', serializePrefix(a));

    // konkatenace
    a := createConcatenationNode(
        createSymbolNode('a'),
        createSymbolNode('b')
    );
    TestingFramework.assertStringEquals('.ab', serializePrefix(a));

    // alternace
    a := createAlternationNode(
        createSymbolNode('a'),
        createSymbolNode('b')
    );
    TestingFramework.assertStringEquals('+ab', serializePrefix(a));

    // kleene
    a := createKleeneNode(
        createSymbolNode('a')
    );
    TestingFramework.assertStringEquals('*a', serializePrefix(a));

    // testování parsováním tam a zpět
    testSerialization('a');
    testSerialization('.ab');
    testSerialization('..abc');
    testSerialization('.a.bc');
    testSerialization('+ab');
    testSerialization('++abc');
    testSerialization('+a+bc');
    testSerialization('*a');

    // složitější test všeho
    testSerialization('+.x*a.bd');

    // vyzkoušíme klonování
    a := parse('+.x*a.bd');
    b := clone(a);
    destroyExpression(a);
    TestingFramework.assertStringEquals('+.x*a.bd', serializePrefix(b));
    destroyExpression(b);

    // zjednodušování epsilon výrazů
    a := parse('.!x');
    removeUselessEpsilons(a);
    TestingFramework.assertStringEquals('x', serializePrefix(a));
    destroyExpression(a);

    a := parse('...!xy!');
    removeUselessEpsilons(a);
    TestingFramework.assertStringEquals('.xy', serializePrefix(a));
    destroyExpression(a);

    a := parse('*!');
    removeUselessEpsilons(a);
    TestingFramework.assertStringEquals('!', serializePrefix(a));
    destroyExpression(a);

    a := parse('.a*!');
    removeUselessEpsilons(a);
    TestingFramework.assertStringEquals('a', serializePrefix(a));
    destroyExpression(a);

    a := parse('.+..!ab.!c!');
    removeUselessEpsilons(a);
    TestingFramework.assertStringEquals('+.abc', serializePrefix(a));
    destroyExpression(a);
end;

end.