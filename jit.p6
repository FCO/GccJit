use NativeCall;

enum GccJitType <
  VOID
  VOID-PTR
  BOOL
  CHAR
  SIGNED-CHAR
  UNSIGNED-CHAR
  SHORT
  UNSIGNED-SHORT
  INT
  UNSIGNED-INT
  LONG
  UNSIGNED-LONG
  LONG-LONG
  UNSIGNED-LONG-LONG
  FLOAT
  DOUBLE
  LONG-DOUBLE
  CONST-CHAR-PTR
  SIZE-T
  FILE-PTR
  COMPLEX-FLOAT
  COMPLEX-DOUBLE
  COMPLEX-LONG-DOUBLE
>;

enum GccJitFuncType < EXPORTED INTERNAL IMPORTED ALWAYS_INLINE >;

enum GccJitOutputKind < ASSEMBLER OBJECT_FILE DYNAMIC_LIBRARY EXECUTABLE >;

enum GccBinOp <
    PLUS
    MINUS
    MULT
    DIVIDE
    MODULO
    BITWISE_AND
    BITWISE_XOR
    BITWISE_OR
    LOGICAL_AND
    LOGICAL_OR
    LSHIFT
    RSHIFT
>;

class GccJit::Context {
    class Type is repr("CPointer") {}

    sub gcc_jit_context_acquire() returns Pointer is native("gccjit") { * }
    sub gcc_jit_context_get_type(Pointer, int16) returns GccJit::Context::Type is native("gccjit") { * }
    sub gcc_jit_context_new_param(Pointer, Pointer, Type, Str) returns Pointer is native("gccjit") { * }
    sub gcc_jit_context_new_binary_op(Pointer, Pointer, int16, Pointer, Pointer, Pointer) returns Pointer is native("gccjit") { * }
    sub gcc_jit_context_new_function(Pointer, Pointer, int16, Pointer, Str, int16, CArray[Pointer], int16) returns Pointer is native("gccjit") { * }
    sub gcc_jit_context_compile(Pointer) returns Pointer is native("gccjit") { * }
    sub gcc_jit_context_compile_to_file(Pointer, int16, Str) is native("gccjit") { * }
    sub gcc_jit_context_new_call (Pointer, Pointer, Pointer, int16, CArray[Pointer]) returns Pointer is native("gccjit") { * }
    sub gcc_jit_context_new_rvalue_from_int(Pointer, Pointer, int16) returns Pointer is native("gccjit") { * }
    sub gcc_jit_context_new_string_literal(Pointer, Str) returns Pointer is native("gccjit") { * }

    sub gcc_jit_param_as_rvalue(Pointer) returns Pointer is native("gccjit") { * };

    sub gcc_jit_function_new_block(Pointer, Str) returns Pointer is native("gccjit") { * }
    sub gcc_jit_block_add_eval(Pointer, Pointer, Pointer) is native("gccjit") { * }
    sub gcc_jit_block_add_assignment(Pointer, Pointer, Pointer, Pointer) is native("gccjit") { * }
    sub gcc_jit_block_end_with_return(Pointer, Pointer, Pointer) returns Pointer is native("gccjit") { * }
    sub gcc_jit_block_end_with_void_return(Pointer, Pointer) returns Pointer is native("gccjit") { * }
    sub gcc_jit_result_get_code(Pointer, Str) returns Pointer is native("gccjit") { * }

        has Pointer $.context = gcc_jit_context_acquire();

    class RValue {
        has Pointer $.context;
        has Pointer $.rvalue;
    }

    class Param {
        has Pointer $.context   is required;
        has Pointer $.location;
        has Type    $.type      is required;
        has Str     $.name      is required;
        has Pointer $.param   = gcc_jit_context_new_param($!context, $!location, $!type, $!name);

        method RValue {
            RValue.new: :$!context, :rvalue(gcc_jit_param_as_rvalue $!param)
        }
    }

    class Block {
        has Pointer $.context   is required;
        has Pointer $.block     is required;

        method add-eval(RValue $rvalue, Pointer :$location) {
            gcc_jit_block_add_eval $!block, $location, $rvalue.rvalue
        }

        method add-assignment(RValue $rvalue, Pointer $lvalue, Pointer :$location) {
            gcc_jit_block_add_assignment $!block, $location, $rvalue.rvalue, $lvalue
        }

        method end-with-return(RValue $rvalue, Pointer :$location) {
            gcc_jit_block_end_with_return $!block, $location, $rvalue.rvalue
        }

        method end-with-void-return(Pointer :$location) {
            gcc_jit_block_end_with_void_return $!block, $location
        }
    }

    class Function {
        has Pointer         $.context   is required;
        has Pointer         $.location;
        has GccJitFuncType  $.ftype     is required;
        has Type            $.type      is required;
        has Str             $.name      is required;
        has                 @.params;
        has Bool            $.variadic  is required;
        has Pointer         $.function = gcc_jit_context_new_function(
            $!context,
            $!location,
            $!ftype,
            $!type,
            $!name,
            +@!params,
            CArray[Pointer].new(|@!params>>.param),
            +$!variadic
        );

        method new-block(Str $name) {
            Block.new: :$!context, :block(gcc_jit_function_new_block $!function, $name)
        }
    }

    class Result {
        has Pointer $.context;
        has Pointer $.result = gcc_jit_context_compile $!context;

        method get-code(Str $name) {
            gcc_jit_result_get_code $!result, $name
        }
    }

    method get-type(GccJitType $type) { gcc_jit_context_get_type($!context, $type) }
    method void                 { $ //= self.get-type: VOID                }
    method void-ptr             { $ //= self.get-type: VOID-PTR            }
    method bool                 { $ //= self.get-type: BOOL                }
    method char                 { $ //= self.get-type: CHAR                }
    method signed-char          { $ //= self.get-type: SIGNED-CHAR         }
    method unsigned-char        { $ //= self.get-type: UNSIGNED-CHAR       }
    method short                { $ //= self.get-type: SHORT               }
    method unsigned-short       { $ //= self.get-type: UNSIGNED-SHORT      }
    method int                  { $ //= self.get-type: INT                 }
    method unsigned-int         { $ //= self.get-type: UNSIGNED-INT        }
    method long                 { $ //= self.get-type: LONG                }
    method unsigned-long        { $ //= self.get-type: UNSIGNED-LONG       }
    method long-long            { $ //= self.get-type: LONG-LONG           }
    method unsigned-long-long   { $ //= self.get-type: UNSIGNED-LONG-LONG  }
    method float                { $ //= self.get-type: FLOAT               }
    method double               { $ //= self.get-type: DOUBLE              }
    method long-double          { $ //= self.get-type: LONG-DOUBLE         }
    method const-char-ptr       { $ //= self.get-type: CONST-CHAR-PTR      }
    method size-t               { $ //= self.get-type: SIZE-T              }
    method file-ptr             { $ //= self.get-type: FILE-PTR            }
    method complex-float        { $ //= self.get-type: COMPLEX-FLOAT       }
    method complex-double       { $ //= self.get-type: COMPLEX-DOUBLE      }
    method complex-long-double  { $ //= self.get-type: COMPLEX-LONG-DOUBLE }

    method new-param(GccJit::Context::Type $type, Str $name, Pointer :$location) {
        Param.new: :$!context, :$location, :$type, :$name
    }
    method new-function(GccJitFuncType $ftype, Type $type, Str $name, *@params, Pointer :$location, Bool :$variadic = False) {
        Function.new: :$!context, :$location, :$ftype, :$type, :$name, :@params, :$variadic
    }
    method compile { Result.new: :$!context }
    method compile-to-file(GccJitOutputKind $kind, Str $file) {
        gcc_jit_context_compile_to_file $!context, $kind, $file
    }
    method new-binary-op(GccBinOp $op, Type $type, RValue $a, RValue $b, Pointer :$location) {
        RValue.new: :$!context, :rvalue(
            gcc_jit_context_new_binary_op $!context, $location, +$op, $type, $a.rvalue, $b.rvalue
        )
    }
    method new-call (Function $func, *@args, Pointer :$location) {
        RValue.new: :$!context, :rvalue(
            gcc_jit_context_new_call $!context, $location, $func.function, +@args , CArray[Pointer].new: |@args>>.rvalue
        )
    }
    method new-rvalue-from-int(Int $val) {
        RValue.new: :$!context, :rvalue(gcc_jit_context_new_rvalue_from_int $!context, self.int, $val)
    }
    method new-string-literal(Str $val) {
        RValue.new: :$!context, :rvalue(gcc_jit_context_new_string_literal $!context, $val)
    }
}


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
