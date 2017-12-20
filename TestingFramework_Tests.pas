{
    Testy testovacího frameworku.

    Jen pro kontrolu, že správný vstup assert funkcí
    mi nemůže hodit chybu.
}
unit TestingFramework_Tests;

interface

procedure runTests;

implementation

uses TestingFramework;

procedure runTests;
var foo: byte;
var bar: Pointer;
begin
    TestingFramework.testSuite('TestingFramework');

    // rovnost integerů
    foo := 42;
    TestingFramework.assertIntEquals(42, foo);

    // rovnost řetězců
    TestingFramework.assertStringEquals('bar', 'bar');

    // rovnost pointerů
    bar := @foo;
    TestingFramework.assertPointerEquals(bar, @foo);
end;

end.