;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: wasm-opt %s -all --dae -S -o - | filecheck %s

(module
 ;; CHECK:      (type $"{}" (sub (struct)))
 (type $"{}" (sub (struct)))

 ;; CHECK:      (type $"return_{}" (func (result (ref $"{}"))))
 (type $"return_{}" (func (result (ref $"{}"))))

 ;; CHECK:      (type $"{i32}" (sub $"{}" (struct (field i32))))
 (type $"{i32}" (sub $"{}" (struct (field i32))))

 ;; CHECK:      (type $"{i32_f32}" (sub $"{i32}" (struct (field i32) (field f32))))
 (type $"{i32_f32}" (sub $"{i32}" (struct (field i32) (field f32))))

 ;; CHECK:      (type $"{i32_i64}" (sub $"{i32}" (struct (field i32) (field i64))))
 (type $"{i32_i64}" (sub $"{i32}" (struct (field i32) (field i64))))

 (table 1 1 funcref)

 ;; We cannot refine the return type if nothing is actually returned.
 ;; CHECK:      (func $refine-return-no-return (type $0) (result anyref)
 ;; CHECK-NEXT:  (local $temp anyref)
 ;; CHECK-NEXT:  (local.set $temp
 ;; CHECK-NEXT:   (call $refine-return-no-return)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (unreachable)
 ;; CHECK-NEXT: )
 (func $refine-return-no-return (result anyref)
  ;; Call this function, so that we attempt to optimize it. Note that we do not
  ;; just drop the result, as that would cause the drop optimizations to kick
  ;; in.
  (local $temp anyref)
  (local.set $temp (call $refine-return-no-return))
  (unreachable)
 )

 ;; We cannot refine the return type if it is already the best it can be.
 ;; CHECK:      (func $refine-return-no-refining (type $0) (result anyref)
 ;; CHECK-NEXT:  (local $temp anyref)
 ;; CHECK-NEXT:  (local $any anyref)
 ;; CHECK-NEXT:  (local.set $temp
 ;; CHECK-NEXT:   (call $refine-return-no-refining)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (local.get $any)
 ;; CHECK-NEXT: )
 (func $refine-return-no-refining (result anyref)
  (local $temp anyref)
  (local $any anyref)

  (local.set $temp (call $refine-return-no-refining))

  (local.get $any)
 )

 ;; Refine the return type based on the value flowing out.
 ;; CHECK:      (func $refine-return-flow (type $3) (result i31ref)
 ;; CHECK-NEXT:  (local $temp anyref)
 ;; CHECK-NEXT:  (local $i31 i31ref)
 ;; CHECK-NEXT:  (local.set $temp
 ;; CHECK-NEXT:   (call $refine-return-flow)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (local.get $i31)
 ;; CHECK-NEXT: )
 (func $refine-return-flow (result anyref)
  (local $temp anyref)
  (local $i31 (ref null i31))

  (local.set $temp (call $refine-return-flow))

  (local.get $i31)
 )
 ;; CHECK:      (func $call-refine-return-flow (type $3) (result i31ref)
 ;; CHECK-NEXT:  (local $temp anyref)
 ;; CHECK-NEXT:  (local.set $temp
 ;; CHECK-NEXT:   (call $call-refine-return-flow)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (if (result i31ref)
 ;; CHECK-NEXT:   (i32.const 1)
 ;; CHECK-NEXT:   (then
 ;; CHECK-NEXT:    (call $refine-return-flow)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (else
 ;; CHECK-NEXT:    (call $refine-return-flow)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $call-refine-return-flow (result anyref)
  (local $temp anyref)
  (local.set $temp (call $call-refine-return-flow))

  ;; After refining the return value of the above function, refinalize will
  ;; update types here, which will lead to updating the if, and then the entire
  ;; function's return value.
  (if (result anyref)
   (i32.const 1)
   (then
    (call $refine-return-flow)
   )
   (else
    (call $refine-return-flow)
   )
  )
 )

 ;; Refine the return type based on a return.
 ;; CHECK:      (func $refine-return-return (type $3) (result i31ref)
 ;; CHECK-NEXT:  (local $temp anyref)
 ;; CHECK-NEXT:  (local $i31 i31ref)
 ;; CHECK-NEXT:  (local.set $temp
 ;; CHECK-NEXT:   (call $refine-return-return)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (return
 ;; CHECK-NEXT:   (local.get $i31)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $refine-return-return (result anyref)
  (local $temp anyref)
  (local $i31 (ref null i31))

  (local.set $temp (call $refine-return-return))

  (return (local.get $i31))
 )

 ;; Refine the return type based on multiple values.
 ;; CHECK:      (func $refine-return-many (type $3) (result i31ref)
 ;; CHECK-NEXT:  (local $temp anyref)
 ;; CHECK-NEXT:  (local $i31 i31ref)
 ;; CHECK-NEXT:  (local.set $temp
 ;; CHECK-NEXT:   (call $refine-return-many)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (if
 ;; CHECK-NEXT:   (i32.const 1)
 ;; CHECK-NEXT:   (then
 ;; CHECK-NEXT:    (return
 ;; CHECK-NEXT:     (local.get $i31)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (if
 ;; CHECK-NEXT:   (i32.const 2)
 ;; CHECK-NEXT:   (then
 ;; CHECK-NEXT:    (return
 ;; CHECK-NEXT:     (local.get $i31)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (local.get $i31)
 ;; CHECK-NEXT: )
 (func $refine-return-many (result anyref)
  (local $temp anyref)
  (local $i31 (ref null i31))

  (local.set $temp (call $refine-return-many))

  (if
   (i32.const 1)
   (then
    (return (local.get $i31))
   )
  )
  (if
   (i32.const 2)
   (then
    (return (local.get $i31))
   )
  )
  (local.get $i31)
 )

 ;; CHECK:      (func $refine-return-many-lub (type $7) (result eqref)
 ;; CHECK-NEXT:  (local $temp anyref)
 ;; CHECK-NEXT:  (local $i31 i31ref)
 ;; CHECK-NEXT:  (local $struct structref)
 ;; CHECK-NEXT:  (local.set $temp
 ;; CHECK-NEXT:   (call $refine-return-many-lub)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (if
 ;; CHECK-NEXT:   (i32.const 1)
 ;; CHECK-NEXT:   (then
 ;; CHECK-NEXT:    (return
 ;; CHECK-NEXT:     (local.get $i31)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (if
 ;; CHECK-NEXT:   (i32.const 2)
 ;; CHECK-NEXT:   (then
 ;; CHECK-NEXT:    (return
 ;; CHECK-NEXT:     (local.get $struct)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (local.get $i31)
 ;; CHECK-NEXT: )
 (func $refine-return-many-lub (result anyref)
  (local $temp anyref)
  (local $i31 (ref null i31))
  (local $struct (ref null struct))

  (local.set $temp (call $refine-return-many-lub))

  (if
   (i32.const 1)
   (then
    (return (local.get $i31))
   )
  )
  (if
   (i32.const 2)
   ;; The refined return type has to be a supertype of struct.
   (then
    (return (local.get $struct))
   )
  )
  (local.get $i31)
 )

 ;; CHECK:      (func $refine-return-many-lub-2 (type $7) (result eqref)
 ;; CHECK-NEXT:  (local $temp anyref)
 ;; CHECK-NEXT:  (local $i31 i31ref)
 ;; CHECK-NEXT:  (local $struct structref)
 ;; CHECK-NEXT:  (local.set $temp
 ;; CHECK-NEXT:   (call $refine-return-many-lub-2)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (if
 ;; CHECK-NEXT:   (i32.const 1)
 ;; CHECK-NEXT:   (then
 ;; CHECK-NEXT:    (return
 ;; CHECK-NEXT:     (local.get $i31)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (if
 ;; CHECK-NEXT:   (i32.const 2)
 ;; CHECK-NEXT:   (then
 ;; CHECK-NEXT:    (return
 ;; CHECK-NEXT:     (local.get $i31)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (local.get $struct)
 ;; CHECK-NEXT: )
 (func $refine-return-many-lub-2 (result anyref)
  (local $temp anyref)
  (local $i31 (ref null i31))
  (local $struct (ref null struct))

  (local.set $temp (call $refine-return-many-lub-2))

  (if
   (i32.const 1)
   (then
    (return (local.get $i31))
   )
  )
  (if
   (i32.const 2)
   (then
    (return (local.get $i31))
   )
  )
  ;; The refined return type has to be a supertype of struct.
  (local.get $struct)
 )

 ;; We can refine the return types of tuples.
 ;; CHECK:      (func $refine-return-tuple (type $8) (result i31ref i32)
 ;; CHECK-NEXT:  (local $temp anyref)
 ;; CHECK-NEXT:  (local $i31 i31ref)
 ;; CHECK-NEXT:  (local.set $temp
 ;; CHECK-NEXT:   (tuple.extract 2 0
 ;; CHECK-NEXT:    (call $refine-return-tuple)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (tuple.make 2
 ;; CHECK-NEXT:   (local.get $i31)
 ;; CHECK-NEXT:   (i32.const 1)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $refine-return-tuple (result anyref i32)
  (local $temp anyref)
  (local $i31 (ref null i31))

  (local.set $temp
   (tuple.extract 2 0
    (call $refine-return-tuple)
   )
  )

  (tuple.make 2
   (local.get $i31)
   (i32.const 1)
  )
 )

 ;; This function does a return call of the one after it. The one after it
 ;; returns a ref.func of this one. They both begin by returning a funcref;
 ;; after refining the return type of the second function, it will have a more
 ;; specific type (which is ok as subtyping is allowed with tail calls).
 ;; CHECK:      (func $do-return-call (type $6) (result funcref)
 ;; CHECK-NEXT:  (return_call $return-ref-func)
 ;; CHECK-NEXT: )
 (func $do-return-call (result funcref)
  (return_call $return-ref-func)
 )
 ;; CHECK:      (func $return-ref-func (type $9) (result (ref $6))
 ;; CHECK-NEXT:  (ref.func $do-return-call)
 ;; CHECK-NEXT: )
 (func $return-ref-func (result funcref)
  (ref.func $do-return-call)
 )

 ;; Show that we can optimize the return type of a function that does a tail
 ;; call.
 ;; CHECK:      (func $tail-callee (type $"return_{}") (result (ref $"{}"))
 ;; CHECK-NEXT:  (unreachable)
 ;; CHECK-NEXT: )
 (func $tail-callee (result (ref $"{}"))
  (unreachable)
 )
 ;; CHECK:      (func $tail-caller-yes (type $"return_{}") (result (ref $"{}"))
 ;; CHECK-NEXT:  (return_call $tail-callee)
 ;; CHECK-NEXT: )
 (func $tail-caller-yes (result anyref)
  ;; This function's return type can be refined because of this call, whose
  ;; target's return type is more specific than anyref.
  (return_call $tail-callee)
 )
 ;; CHECK:      (func $tail-caller-no (type $0) (result anyref)
 ;; CHECK-NEXT:  (local $any anyref)
 ;; CHECK-NEXT:  (if
 ;; CHECK-NEXT:   (i32.const 1)
 ;; CHECK-NEXT:   (then
 ;; CHECK-NEXT:    (return
 ;; CHECK-NEXT:     (local.get $any)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (return_call $tail-callee)
 ;; CHECK-NEXT: )
 (func $tail-caller-no (result anyref)
  (local $any anyref)

  ;; This function's return type cannot be refined because of another return
  ;; whose type prevents it.
  (if (i32.const 1)
   (then
    (return (local.get $any))
   )
  )
  (return_call $tail-callee)
 )
 ;; CHECK:      (func $tail-call-caller (type $4)
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (call $tail-caller-yes)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (call $tail-caller-no)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $tail-call-caller
  ;; Call the functions to cause optimization to happen.
  (drop
   (call $tail-caller-yes)
  )
  (drop
   (call $tail-caller-no)
  )
 )

 ;; As above, but with an indirect tail call.
 ;; CHECK:      (func $tail-callee-indirect (type $"return_{}") (result (ref $"{}"))
 ;; CHECK-NEXT:  (unreachable)
 ;; CHECK-NEXT: )
 (func $tail-callee-indirect (result (ref $"{}"))
  (unreachable)
 )
 ;; CHECK:      (func $tail-caller-indirect-yes (type $"return_{}") (result (ref $"{}"))
 ;; CHECK-NEXT:  (return_call_indirect $0 (type $"return_{}")
 ;; CHECK-NEXT:   (i32.const 0)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $tail-caller-indirect-yes (result anyref)
  (return_call_indirect (type $"return_{}") (i32.const 0))
 )
 ;; CHECK:      (func $tail-caller-indirect-no (type $0) (result anyref)
 ;; CHECK-NEXT:  (local $any anyref)
 ;; CHECK-NEXT:  (if
 ;; CHECK-NEXT:   (i32.const 1)
 ;; CHECK-NEXT:   (then
 ;; CHECK-NEXT:    (return
 ;; CHECK-NEXT:     (local.get $any)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (return_call_indirect $0 (type $"return_{}")
 ;; CHECK-NEXT:   (i32.const 0)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $tail-caller-indirect-no (result anyref)
  (local $any anyref)

  (if (i32.const 1)
   (then
    (return (local.get $any))
   )
  )
  (return_call_indirect (type $"return_{}") (i32.const 0))
 )
 ;; CHECK:      (func $tail-call-caller-indirect (type $4)
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (call $tail-caller-indirect-yes)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (call $tail-caller-indirect-no)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $tail-call-caller-indirect
  (drop
   (call $tail-caller-indirect-yes)
  )
  (drop
   (call $tail-caller-indirect-no)
  )
 )

 ;; As above, but with a tail call by function reference.
 ;; CHECK:      (func $tail-callee-call_ref (type $"return_{}") (result (ref $"{}"))
 ;; CHECK-NEXT:  (unreachable)
 ;; CHECK-NEXT: )
 (func $tail-callee-call_ref (result (ref $"{}"))
  (unreachable)
 )
 ;; CHECK:      (func $tail-caller-call_ref-yes (type $"return_{}") (result (ref $"{}"))
 ;; CHECK-NEXT:  (local $"return_{}" (ref null $"return_{}"))
 ;; CHECK-NEXT:  (return_call_ref $"return_{}"
 ;; CHECK-NEXT:   (local.get $"return_{}")
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $tail-caller-call_ref-yes (result anyref)
  (local $"return_{}" (ref null $"return_{}"))

  (return_call_ref $"return_{}" (local.get $"return_{}"))
 )
 ;; CHECK:      (func $tail-caller-call_ref-no (type $0) (result anyref)
 ;; CHECK-NEXT:  (local $any anyref)
 ;; CHECK-NEXT:  (local $"return_{}" (ref null $"return_{}"))
 ;; CHECK-NEXT:  (if
 ;; CHECK-NEXT:   (i32.const 1)
 ;; CHECK-NEXT:   (then
 ;; CHECK-NEXT:    (return
 ;; CHECK-NEXT:     (local.get $any)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (return_call_ref $"return_{}"
 ;; CHECK-NEXT:   (local.get $"return_{}")
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $tail-caller-call_ref-no (result anyref)
  (local $any anyref)
  (local $"return_{}" (ref null $"return_{}"))

  (if (i32.const 1)
   (then
    (return (local.get $any))
   )
  )
  (return_call_ref $"return_{}" (local.get $"return_{}"))
 )
 ;; CHECK:      (func $tail-caller-call_ref-unreachable (type $0) (result anyref)
 ;; CHECK-NEXT:  (block ;; (replaces unreachable CallRef we can't emit)
 ;; CHECK-NEXT:   (drop
 ;; CHECK-NEXT:    (unreachable)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (unreachable)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $tail-caller-call_ref-unreachable (result anyref)
  ;; An unreachable means there is no function signature to even look at. We
  ;; should not hit an assertion on such things.
  (return_call_ref $"return_{}" (unreachable))
 )
 ;; CHECK:      (func $tail-call-caller-call_ref (type $4)
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (call $tail-caller-call_ref-yes)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (call $tail-caller-call_ref-no)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (call $tail-caller-call_ref-unreachable)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $tail-call-caller-call_ref
  (drop
   (call $tail-caller-call_ref-yes)
  )
  (drop
   (call $tail-caller-call_ref-no)
  )
  (drop
   (call $tail-caller-call_ref-unreachable)
  )
 )

 ;; CHECK:      (func $update-null (type $10) (param $x i32) (param $y i32) (result (ref null $"{i32}"))
 ;; CHECK-NEXT:  (if
 ;; CHECK-NEXT:   (local.get $x)
 ;; CHECK-NEXT:   (then
 ;; CHECK-NEXT:    (if
 ;; CHECK-NEXT:     (local.get $y)
 ;; CHECK-NEXT:     (then
 ;; CHECK-NEXT:      (return
 ;; CHECK-NEXT:       (struct.new_default $"{i32_f32}")
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:     (else
 ;; CHECK-NEXT:      (return
 ;; CHECK-NEXT:       (ref.null none)
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (else
 ;; CHECK-NEXT:    (return
 ;; CHECK-NEXT:     (struct.new_default $"{i32_i64}")
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $update-null (param $x i32) (param $y i32) (result anyref)
  ;; Of the three returns here, the null can be updated, and the LUB is
  ;; determined by the other two, and is their shared parent $"{}."
  (if
   (local.get $x)
   (then
    (if
     (local.get $y)
     (then
      (return (struct.new_default $"{i32_f32}"))
     )
     (else
      (return (ref.null any))
     )
    )
   )
   (else
    (return (struct.new_default $"{i32_i64}"))
   )
  )
 )

 ;; CHECK:      (func $call-update-null (type $0) (result anyref)
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (call $update-null
 ;; CHECK-NEXT:    (i32.const 0)
 ;; CHECK-NEXT:    (i32.const 1)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (call $update-null
 ;; CHECK-NEXT:   (i32.const 1)
 ;; CHECK-NEXT:   (i32.const 0)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $call-update-null (result anyref)
  ;; Call $update-null so it gets optimized. (Call it with various values so
  ;; that other opts do not inline the constants.)
  (drop
   (call $update-null
    (i32.const 0)
    (i32.const 1)
   )
  )
  (call $update-null
   (i32.const 1)
   (i32.const 0)
  )
 )
)
