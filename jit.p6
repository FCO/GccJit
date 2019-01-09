use lib <lib>;
use GccJit;

given GccJit::Context.new {
    my $a        = .new-param: .int, "a";
    my $b        = .new-param: .int, "b";
    my $a-plus-b = .new-binary-op: PLUS, .int, $a.RValue, $b.RValue;
    my $add-func = .new-function: EXPORTED, .int, "add", $a, $b;
    $add-func.new-block("one-block").end-with-return: $a-plus-b;

    my $_0 = .new-rvalue-from-int: 0;
    my $_2 = .new-rvalue-from-int: 2;
    my $_3 = .new-rvalue-from-int: 3;

    my $call-add = .new-call: $add-func, $_2, $_3;

    my $main = .new-function: EXPORTED, .int, "main";
    my $main-block = $main.new-block: "_main_";

    my $format = .new-param: .const-char-ptr, "format";
    my $number = .new-param: .int, "number";
    my $printf = .new-function: IMPORTED, .int, "printf", $format, $number;

    $main-block.add-eval: .new-call: $printf, .new-string-literal("sum: %d\n"), $call-add;

    $main-block.end-with-return: $_0;

    .compile-to-file: EXECUTABLE, "./a.out";
}
