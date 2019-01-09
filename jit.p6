use lib <lib>;
use GccJit;

given GccJit.new {
    my $a        = .new-param: .int, "a";
    my $b        = .new-param: .int, "b";
    my $a-plus-b = .new-binary-plus: .int, $a, $b;
    my $add-func = .new-exported-function: .int, "add", $a, $b;
    $add-func.new-block("one-block").end-with-return: $a-plus-b;

    my $call-add = .new-call: $add-func, .new-rvalue-from-int(2), .new-rvalue-from-int: 3;

    my $main     = .new-exported-function: .int, "main";
    my $main-blk = $main.new-block: "_main_";

    my $format   = .new-param: .const-char-ptr, "format";
    my $number   = .new-param: .int, "number";
    my $printf   = .new-imported-function: .int, "printf", $format, $number;

    $main-blk.add-eval: .new-call: $printf, .new-string-literal("sum: %d\n"), $call-add;

    $main-blk.end-with-return: .new-rvalue-from-int: 0;

    .compile-to-executable: "./a.out";
}
