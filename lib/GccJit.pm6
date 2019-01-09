use NativeCall;

enum GccJitType < VOID VOID-PTR BOOL CHAR SIGNED-CHAR
    UNSIGNED-CHAR SHORT UNSIGNED-SHORT INT UNSIGNED-INT
    LONG UNSIGNED-LONG LONG-LONG UNSIGNED-LONG-LONG
    FLOAT DOUBLE LONG-DOUBLE CONST-CHAR-PTR SIZE-T
    FILE-PTR COMPLEX-FLOAT COMPLEX-DOUBLE COMPLEX-LONG-DOUBLE >;

enum GccJitFuncType < EXPORTED INTERNAL IMPORTED ALWAYS_INLINE >;

enum GccJitOutputKind < ASSEMBLER OBJECT_FILE DYNAMIC_LIBRARY EXECUTABLE >;

enum GccBinOp < PLUS MINUS MULT DIVIDE MODULO BITWISE_AND BITWISE_XOR
    BITWISE_OR LOGICAL_AND LOGICAL_OR LSHIFT RSHIFT >;

class GccJit is repr("CPointer") {
    class Type is repr("CPointer") {}
    class Location is repr("CPointer") {}
    class RValue is repr("CPointer") {}
    class LValue is repr("CPointer") {}
    class Param is repr("CPointer") is RValue {
        method RValue {
            gcc_jit_param_as_rvalue self
        }
    }
    class Block is repr("CPointer") {
        method add-eval(RValue $rvalue, Location :$location) {
            gcc_jit_block_add_eval self, $location, $rvalue
        }

        method add-assignment(RValue $rvalue, LValue $lvalue, Location :$location) {
            gcc_jit_block_add_assignment self, $location, $rvalue, $lvalue
        }

        method end-with-return(RValue $rvalue, Location :$location) {
            gcc_jit_block_end_with_return self, $location, $rvalue
        }

        method end-with-void-return(Location :$location) {
            gcc_jit_block_end_with_void_return self, $location
        }
    }
    class Function is repr("CPointer") {
        method new-block(Str $name) {
            gcc_jit_function_new_block self, $name
        }
    }
    class Result is repr("CPointer") {
        method get-code(Str $name) {
            gcc_jit_result_get_code self, $name
        }
    }

    sub gcc_jit_context_acquire() returns GccJit is native("gccjit") { * }
    sub gcc_jit_context_get_type(
        GccJit,
        int16
    ) returns Type is native("gccjit") { * }
    sub gcc_jit_context_new_param(
        GccJit,
        Location,
        Type,
        Str
    ) returns Param is native("gccjit") { * }
    sub gcc_jit_context_new_binary_op(
        GccJit,
        Location,
        int16,
        Type,
        RValue,
        RValue
    ) returns RValue is native("gccjit") { * }
    sub gcc_jit_context_new_function(
        GccJit,
        Location,
        int16,
        Type,
        Str,
        int16,
        CArray[Param],
        int16
    ) returns Function is native("gccjit") { * }
    sub gcc_jit_context_compile(
        GccJit
    ) returns Result is native("gccjit") { * }
    sub gcc_jit_context_compile_to_file(
        GccJit,
        int16,
        Str
    ) is native("gccjit") { * }
    sub gcc_jit_context_new_call (
        GccJit,
        Location,
        Function,
        int16,
        CArray[RValue]
    ) returns RValue is native("gccjit") { * }
    sub gcc_jit_context_new_rvalue_from_int(
        GccJit,
        Type,
        int16
    ) returns RValue is native("gccjit") { * }
    sub gcc_jit_context_new_string_literal(
        GccJit,
        Str
    ) returns RValue is native("gccjit") { * }
    sub gcc_jit_param_as_rvalue(
        Param
    ) returns RValue is native("gccjit") { * };
    sub gcc_jit_function_new_block(
        Function,
        Str
    ) returns Block is native("gccjit") { * }
    sub gcc_jit_block_add_eval(
        Block,
        Location,
        RValue
    ) is native("gccjit") { * }
    sub gcc_jit_block_add_assignment(
        Block,
        Location,
        RValue,
        LValue
    ) is native("gccjit") { * }
    sub gcc_jit_block_end_with_return(
        Block,
        Location,
        RValue
    ) is native("gccjit") { * }
    sub gcc_jit_block_end_with_void_return(
        Block,
        Location
    ) is native("gccjit") { * }
    sub gcc_jit_result_get_code(
        Result,
        Str
    ) returns Pointer is native("gccjit") { * }

    method new { gcc_jit_context_acquire() }

    method get-type(GccJitType $type) { gcc_jit_context_get_type self, $type }
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

    method new-param(Type $type, Str $name, Location :$location) {
        gcc_jit_context_new_param self, $location, $type, $name
    }
    method new-function(GccJitFuncType $ftype, Type $type, Str $name, *@params, Location :$location, Bool :$variadic = False) {
        gcc_jit_context_new_function self, $location, $ftype,
            $type, $name, +@params, CArray[Param].new(|@params), +$variadic
    }
    method new-exported-function(Type $type, Str $name, *@params, Location :$location, Bool :$variadic = False) {
        gcc_jit_context_new_function self, $location, EXPORTED,
            $type, $name, +@params, CArray[Param].new(|@params), +$variadic
    }
    method new-internal-function(Type $type, Str $name, *@params, Location :$location, Bool :$variadic = False) {
        gcc_jit_context_new_function self, $location, INTERNAL,
            $type, $name, +@params, CArray[Param].new(|@params), +$variadic
    }
    method new-imported-function(Type $type, Str $name, *@params, Location :$location, Bool :$variadic = False) {
        gcc_jit_context_new_function self, $location, IMPORTED,
            $type, $name, +@params, CArray[Param].new(|@params), +$variadic
    }
    method new-inlined-function(Type $type, Str $name, *@params, Location :$location, Bool :$variadic = False) {
        gcc_jit_context_new_function self, $location, ALWAYS_INLINE,
            $type, $name, +@params, CArray[Param].new(|@params), +$variadic
    }
    method new-binary-op(GccBinOp $op, Type $type, RValue $a, RValue $b, Location :$location) {
            gcc_jit_context_new_binary_op self, $location, +$op, $type, $a, $b
    }
    method new-binary-plus(Type $type, RValue $a, RValue $b, Location :$location) {
        self.new-binary-op(PLUS, $type, $a, $b, :$location)
    }
    method new-binary-minus(Type $type, RValue $a, RValue $b, Location :$location) {
        self.new-binary-op(MINUS, $type, $a, $b, :$location)
    }
    method new-binary-mult(Type $type, RValue $a, RValue $b, Location :$location) {
        self.new-binary-op(MULT, $type, $a, $b, :$location)
    }
    method new-binary-divide(Type $type, RValue $a, RValue $b, Location :$location) {
        self.new-binary-op(DIVIDE, $type, $a, $b, :$location)
    }
    method new-binary-modulo(Type $type, RValue $a, RValue $b, Location :$location) {
        self.new-binary-op(MODULO, $type, $a, $b, :$location)
    }
    method new-binary-bitwise_and(Type $type, RValue $a, RValue $b, Location :$location) {
        self.new-binary-op(BITWISE_AND, $type, $a, $b, :$location)
    }
    method new-binary-bitwise_xor(Type $type, RValue $a, RValue $b, Location :$location) {
        self.new-binary-op(BITWISE_XOR, $type, $a, $b, :$location)
    }
    method new-binary-bitwise_or(Type $type, RValue $a, RValue $b, Location :$location) {
        self.new-binary-op(BITWISE_OR, $type, $a, $b, :$location)
    }
    method new-binary-logical_and(Type $type, RValue $a, RValue $b, Location :$location) {
        self.new-binary-op(LOGICAL_AND, $type, $a, $b, :$location)
    }
    method new-binary-logical_or(Type $type, RValue $a, RValue $b, Location :$location) {
        self.new-binary-op(LOGICAL_OR, $type, $a, $b, :$location)
    }
    method new-binary-lshift(Type $type, RValue() $a, RValue() $b, Location :$location) {
        self.new-binary-op(LSHIFT, $type, $a, $b, :$location)
    }
    method new-binary-rshift(Type $type, RValue $a, RValue $b, Location :$location) {
        self.new-binary-op(RSHIFT, $type, $a, $b, :$location)
    }
    method new-call (Function $func, *@args, Location :$location) {
            gcc_jit_context_new_call self, $location, $func, +@args , CArray[RValue].new: |@args
    }
    method new-rvalue-from-int(Int $val) {
        gcc_jit_context_new_rvalue_from_int self, self.int, $val
    }
    method new-string-literal(Str $val) {
        gcc_jit_context_new_string_literal self, $val
    }
    method compile {
        gcc_jit_context_compile self;
    }
    method compile-to-file(GccJitOutputKind $kind, Str $file) {
        gcc_jit_context_compile_to_file self, $kind, $file
    }
    method compile-to-assembler(Str $file) {
        gcc_jit_context_compile_to_file self, ASSEMBLER, $file
    }
    method compile-to-object(Str $file) {
        gcc_jit_context_compile_to_file self, OBJECT_FILE, $file
    }
    method compile-to-dyn-lib(Str $file) {
        gcc_jit_context_compile_to_file self, DYNAMIC_LIBRARY, $file
    }
    method compile-to-executable(Str $file) {
        gcc_jit_context_compile_to_file self, EXECUTABLE, $file
    }
}
