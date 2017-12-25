unit List;

interface

{**
 * Prvky spojového seznamu
 *}
type
    PList = ^TList;
    TList = record
        next: PList;
        item: Pointer;
    end;

function getAt(list: PList; index: integer): Pointer;
function indexOf(list: PList; item: Pointer): integer;
function getLength(list: PList): integer;
procedure append(var list: PList; item: Pointer);
procedure remove(var list: PList; item: Pointer);
procedure destroy(var list: PList);
function clone(source: PList): PList;
function pop(var list: PList): Pointer;
function setsEqual(a, b: PList): boolean;
function getLast(list: PList): Pointer;

implementation

{**
 * Vrátí prvek na dané pozici
 *}
function getAt(list: PList; index: integer): Pointer;
var i: integer;
begin
    i := 1;
    while list <> nil do begin
        if i = index then begin
            getAt := list^.item;
            exit;
        end;
        i += 1;
        list := list^.next;
    end;
    
    writeln('Index out of bounds!');
    halt;
end;

{**
 * Vrátí index prvku
 *}
function indexOf(list: PList; item: Pointer): integer;
begin
    indexOf := 1;

    while list <> nil do begin
        if list^.item = item then
            exit;

        indexOf += 1;
        list := list^.next;
    end;

    indexOf := -1;
end;

{**
 * Vrátí délku seznamu
 *}
function getLength(list: PList): integer;
begin
    getLength := 0;
    while list <> nil do begin
        getLength += 1;
        list := list^.next;
    end;
end;

{**
 * Přidá prvek na konec seznamu
 *}
procedure append(var list: PList; item: Pointer);
var p, tail: PList;
var n: PList;
begin
    if list = nil then begin
        new(n);
        n^.item := item;
        n^.next := nil;
        list := n;
        exit;
    end;

    tail := nil;
    p := list;

    while p <> nil do begin
        tail := p;
        p := p^.next;
    end;

    new(n);
    n^.item := item;
    n^.next := nil;
    tail^.next := n;
end;

{**
 * Odebere prvek ze seznamu (první, na který narazí, pokud je tam víckrát)
 *}
procedure remove(var list: PList; item: Pointer);
var p, tail: PList;
begin
    p := list;
    tail := nil;

    while p <> nil do begin
        if p^.item = item then begin
            if tail = nil then begin
                list := p^.next;
                dispose(p);
            end else begin
                tail^.next := p^.next;
                dispose(p);
            end;
            exit;
        end;
        tail := p;
        p := p^.next;
    end;
end;

{**
 * Zničí seznam, uvolní ho z paměti
 *}
procedure destroy(var list: PList);
var tmp: PList;
begin
    while list <> nil do begin
        tmp := list^.next;
        dispose(list);
        list := tmp;
    end;
end;

{**
 * Vytvoří kopii seznamu, která ukazuje na stejné prvky (^.item)
 *}
function clone(source: PList): PList;
begin
    clone := nil;

    while source <> nil do begin
        List.append(clone, source^.item);
        source := source^.next;
    end;
end;

{**
 * Odebere a vrátí první prvek ze seznamu
 *}
function pop(var list: PList): Pointer;
begin
    if list = nil then begin
        writeln('ERROR! Popping empty list');
        halt;
    end;

    pop := list^.item;
    list := list^.next;
end;

{**
 * Porovná dva seznamy jako množiny - zda obsahují stejné prvky
 *}
function setsEqual(a, b: PList): boolean;
begin
    // zkontrolujeme velikosti
    if getLength(a) <> getLength(b) then begin
        setsEqual := false;
        exit;
    end;

    // když jsou stejně velké, stačí iterovat jen přes jeden z nich
    while a <> nil do begin
        // je prvek i v druhém seznamu?
        if indexOf(b, a^.item) = -1 then begin
            // není -> jsou různé
            setsEqual := false;
            exit;
        end;

        a := a^.next;
    end;

    setsEqual := true;
end;

{**
 * Vrátí poslední prvek seznamu
 *}
function getLast(list: PList): Pointer;
begin
    // ne úplně ideální implementace, ale funkce
    // existuje (zatím) jen kvůli lazení
    getLast := getAt(list, getLength(list));
end;

end.