unit List_Tests;

interface

procedure runTests();

implementation

uses TestingFramework, List;

type PChar = ^char;

// helper (create char list)
function ccl(c: PChar; next: PList): PList;
begin
    new(ccl);
    ccl^.item := c;
    ccl^.next := next;
end;

procedure runTests();
var l, m: PList;
var a, b, c: ^char;
begin
    TestingFramework.testSuite('List');

    // seznam vytvořený bezpečně
    new(a); new(b); new(c);
    a^ := 'a';
    b^ := 'b';
    c^ := 'c';
    l := ccl(a, ccl(b, ccl(c, nil)));

    // testujeme získávání prvku
    TestingFramework.assertPointerEquals(a, List.getAt(l, 1));
    TestingFramework.assertPointerEquals(b, List.getAt(l, 2));
    TestingFramework.assertPointerEquals(c, List.getAt(l, 3));

    // testujeme indexof
    TestingFramework.assertIntEquals(1, List.indexOf(l, a));
    TestingFramework.assertIntEquals(2, List.indexOf(l, b));
    TestingFramework.assertIntEquals(3, List.indexOf(l, c));

    // délka
    TestingFramework.assertIntEquals(3, List.getLength(l));

    // zahodíme bezpečně vytvořený seznam a jdeme testovat vytváření
    destroy(l);

    // vytvoříme ho appendováním
    append(l, a);
    append(l, b);
    append(l, c);

    // otestujem pořadí prvků
    TestingFramework.assertIntEquals(1, List.indexOf(l, a));
    TestingFramework.assertIntEquals(2, List.indexOf(l, b));
    TestingFramework.assertIntEquals(3, List.indexOf(l, c));

    TestingFramework.assertPointerEquals(a, List.getAt(l, 1));
    TestingFramework.assertPointerEquals(b, List.getAt(l, 2));
    TestingFramework.assertPointerEquals(c, List.getAt(l, 3));

    // odebereme druhý prvek a ujistíme se, že se indexy posunuly
    List.remove(l, b);
    TestingFramework.assertIntEquals(1, List.indexOf(l, a));
    TestingFramework.assertIntEquals(2, List.indexOf(l, c));

    // zkusíme klonování
    m := List.clone(l);
    List.destroy(l);
    TestingFramework.assertIntEquals(1, List.indexOf(m, a));
    TestingFramework.assertIntEquals(2, List.indexOf(m, c));
end;

end.