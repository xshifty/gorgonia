// +build sse
// +build amd64

#include "textflag.h"

// func vecMul(a, b []float64)
TEXT ·vecMul(SB), NOSPLIT, $0
	MOVQ a_data+0(FP), SI
	MOVQ b_data+24(FP), DI  		// use detination index register for this

	MOVQ a_len+8(FP), AX 			// len(a) into AX - +8, because first 8 is pointer, second 8 is length, third 8 is cap
	MOVQ b_len+32(FP), BX			// len(b) into BX

	// check if they're the same length
	CMPQ AX, BX
	JNE panic						// jump to panic if not the same length. TOOD: return bloody errors

	SUBQ $8, AX 					// 4 items or more?
	JL remainder

loop:

	// a[0]
	MOVAPD (SI), X0
	MOVAPD (DI), X1
	MULPD X0, X1
	MOVAPD X1, (SI)

	MOVAPD 16(SI), X2
	MOVAPD 16(DI), X3
	MULPD X2, X3
	MOVAPD X3, 16(SI)

	MOVAPD 32(SI), X4
	MOVAPD 32(DI), X5
	MULPD X4, X5
	MOVAPD X5, 32(SI)

	MOVAPD 48(SI), X6
	MOVAPD 48(DI), X7
	MULPD X6, X7
	MOVAPD X7, 48(SI)



	// update pointers (4 * 2 * 8) - 2*2 elements each time, each element is 8 bytes
	ADDQ $64, SI
	ADDQ $64, DI

	// start of array is now 8*2 less
	SUBQ	$8, AX
	JGE		loop

remainder:
	ADDQ 	$8, AX
	JE 		done

remainderloop:
	
	// copy into the appropriate registers
	MOVSD 	(SI), X0
	MOVSD 	(DI), X1
	MULSD	X0, X1

	// save it back
	MOVSD	X1, (SI)


	// update pointer to the top of the data
	ADDQ 	$8, SI
	ADDQ	$8, DI

	DECQ 	AX
	JNE 	remainderloop

done:
	RET

panic:
	CALL 	runtime·panicindex(SB)
	RET
	