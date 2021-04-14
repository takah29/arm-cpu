# Tool

## Requirements

* Python 3.8
* Clang 9.0

## Usage

```text
$ cd tool
$ python get_instruction_data.py test/add_test.c
$ cat program.dat
10d04de2
0000a0e3
0c008de5
0110a0e3
08108de5
0210a0e3
04108de5
08109de5
04209de5
021081e0
00108de5
10d08de2
1eff2fe1
00000000
01000000
```

```text
$ python get_instruction_data.py test/add_test.c -d

add_test.o:	file format ELF32-arm-little


Disassembly of section .text:

00000000 main:
; int main() {
       0: 10 d0 4d e2                  	sub	sp, sp, #16
       4: 00 00 a0 e3                  	mov	r0, #0
       8: 0c 00 8d e5                  	str	r0, [sp, #12]
       c: 01 10 a0 e3                  	mov	r1, #1
;     a = 1;
      10: 08 10 8d e5                  	str	r1, [sp, #8]
      14: 02 10 a0 e3                  	mov	r1, #2
;     b = 2;
      18: 04 10 8d e5                  	str	r1, [sp, #4]
;     c = a + b;
      1c: 08 10 9d e5                  	ldr	r1, [sp, #8]
      20: 04 20 9d e5                  	ldr	r2, [sp, #4]
      24: 02 10 81 e0                  	add	r1, r1, r2
      28: 00 10 8d e5                  	str	r1, [sp]
;     return 0;
      2c: 10 d0 8d e2                  	add	sp, sp, #16
      30: 1e ff 2f e1                  	bx	lr
```

## Refference

* [Cross-compilation using Clang](https://clang.llvm.org/docs/CrossCompilation.html)