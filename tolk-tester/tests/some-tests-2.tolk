import "@stdlib/tvm-lowlevel"

fun pair_first<X, Y>(p: [X, Y]): X asm "FIRST";

fun one(dummy: tuple?) {
    return 1;
}

fun main(a: int, x: int) {
    var y: int = 0;
    var z: int = 0;
    while ((y = x * x) > a) {
        x -= 1;
        z = one(null);
    }
    return (y, z);
}

fun throwIfLt10(x: int): void {
    if (x > 10) {
        return;
    }
    throw 234;
    return;
}

@method_id(88)
fun test88(x: int) {
    try {
        var x: void = throwIfLt10(x);
        return 0;
    } catch(code) {
        return code;
    }
}

@method_id(89)
fun test89(last: int): (int, int, int, int) {
    var t: tuple = createEmptyTuple();
    t.tuplePush(1);
    t.tuplePush(2);
    t.tuplePush(3);
    t.tuplePush(last);
    return (t.tupleAt(0), t.tupleAt(t.tupleSize() - 1), t.tupleFirst(), t.tupleLast());
}

@pure fun get10() { return 10; }

@method_id(91)
fun touchCodegen2() {
    var f = get10();
    f.stackMoveToTop();
    return f;
}

@method_id(92)
fun testDumpDontPolluteStack() {
    var f = get10();
    f.debugPrint();
    debugPrint(10);
    var s = "asdf";
    s.debugPrintString();
    debugDumpStack();
    debugPrintString("my");
    return (f, getRemainingBitsCount(s));
}

@method_id(93)
fun testStartBalanceCodegen1() {
    var t = getMyOriginalBalanceWithExtraCurrencies();
    var first = t.pair_first();
    return first;
}

@method_id(94)
fun testStartBalanceCodegen2() {
    var first = getMyOriginalBalance();
    return first;
}

global cur: [int, int, int];
global next: [int, int, int];

@method_id(95)
fun test95() {
    cur = [1, 2, 3];
    next = [2, 3, 4];
    (cur, next) = (next, [3, 4, 5]);
    return (cur, next);
}

/**
    method_id | in     | out
@testcase |  0 | 101 15 | 100 1
@testcase |  0 | 101 14 | 100 1
@testcase |  0 | 101 10 | 100 0
@testcase |  0 | 100 10 | 100 0
@testcase |  0 | 100 10 | 100 0
@testcase | 88 | 5      | 234
@testcase | 88 | 50     | 0
@testcase | 89 | 4      | 1 4 1 4
@testcase | 91 |        | 10
@testcase | 92 |        | 10 32
@testcase | 95 |        | [ 2 3 4 ] [ 3 4 5 ]

@fif_codegen
"""
  touchCodegen2 PROC:<{
    //
    get10 CALLDICT	//  f
  }>
"""

@fif_codegen
"""
  testDumpDontPolluteStack PROC:<{
    ...
    DUMPSTK
    x{6d79} PUSHSLICE	//  f s '5
    STRDUMP DROP
    SBITS	//  f '6
  }>
"""

@fif_codegen
"""
  testStartBalanceCodegen1 PROC:<{
    //
    BALANCE // t
    FIRST	//  first
  }>
"""

@fif_codegen
"""
  testStartBalanceCodegen2 PROC:<{
    //
    BALANCE
    FIRST	//  first
  }>
"""

@fif_codegen
"""
  test95 PROC:<{
    ...
    next GETGLOB	//  g_next
    3 PUSHINT	    //  g_next '14=3
    4 PUSHINT	    //  g_next '14=3 '15=4
    5 PUSHINT	    //  g_next '14=3 '15=4 '16=5
    TRIPLE	        //  '10 '11
    SWAP
    cur SETGLOB
    next SETGLOB
    cur GETGLOB	    //  g_cur
    next GETGLOB	//  g_cur g_next
  }>
"""
*/
