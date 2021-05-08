# Tool

## Requirements

* Python 3.8
* arm-none-eabi-gcc (gcc version 6.3.1 20170620)

## Usage

```text
$ cd tool
$ python get_text_section.py test/add_test.c
$ cat program.dat
e52db004
e28db000
e24dd014
e3a03001
e50b3008
e3a03002
e50b300c
e51b2008
e51b300c
e0823003
e50b3010
e3a03000
e1a00003
e28bd000
e49db004
e12fff1e
```

```text
$ python get_text_section.py test/add_test.c -d

add_test.o:	file format ELF32-arm-little


Disassembly of section .text:

00000000 main:
; int main() {
       0: 04 b0 2d e5                  	str	r11, [sp, #-4]!
       4: 00 b0 8d e2                  	add	r11, sp, #0
       8: 14 d0 4d e2                  	sub	sp, sp, #20
;     a = 1;
       c: 01 30 a0 e3                  	mov	r3, #1
      10: 08 30 0b e5                  	str	r3, [r11, #-8]
;     b = 2;
      14: 02 30 a0 e3                  	mov	r3, #2
      18: 0c 30 0b e5                  	str	r3, [r11, #-12]
;     c = a + b;
      1c: 08 20 1b e5                  	ldr	r2, [r11, #-8]
      20: 0c 30 1b e5                  	ldr	r3, [r11, #-12]
      24: 03 30 82 e0                  	add	r3, r2, r3
      28: 10 30 0b e5                  	str	r3, [r11, #-16]
;     return 0;
      2c: 00 30 a0 e3                  	mov	r3, #0
; }
      30: 03 00 a0 e1                  	mov	r0, r3
      34: 00 d0 8b e2                  	add	sp, r11, #0
      38: 04 b0 9d e4                  	ldr	r11, [sp], #4
      3c: 1e ff 2f e1                  	bx	lr
```

```text
$ ./compiling_for_armv5.sh test/float_add_mul_test.c
$ python get_text_section.py a.out -e -d

a.out:	file format ELF32-arm-little


Disassembly of section .text:

00008018 register_fini:
    8018: 18 30 9f e5                  	ldr	r3, [pc, #24]
    801c: 00 00 53 e3                  	cmp	r3, #0
    8020: 1e ff 2f 01                  	bxeq	lr
    8024: 10 40 2d e9                  	push	{r4, lr}
    8028: 0c 00 9f e5                  	ldr	r0, [pc, #12]
    802c: 25 02 00 eb                  	bl	#2196 <atexit>
    8030: 10 40 bd e8                  	pop	{r4, lr}
    8034: 1e ff 2f e1                  	bx	lr

00008038 $d:
    8038:	00 00 00 00	.word	0x00000000
    803c:	1c 89 00 00	.word	0x0000891c

...
```

## Refference

* [Cross-compilation using Clang](https://clang.llvm.org/docs/CrossCompilation.html)