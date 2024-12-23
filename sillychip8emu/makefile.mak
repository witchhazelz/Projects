#Makefile for windows and linux (MinGW) 

CC= gcc
CFLAGS = -Wall -Wextra -I./src

#source files

SRC = src/chip8.c src/render.c src/bmp.c src/gdi.c asm/c8asm.c asm/c8dasm.c

#executables

EXEC_CHIP8 = chip8
EXEC_ASM = c8asm
EXEC_DASM = c8dasm

#default target

all: $(EXEC_CHIP8) $(EXEC_ASM) $(EXEC_DASM)

#build chip8 interpreter

$(EXEC_CHIP8): $(OBJ)
	$(CC) -o $@ $^ $(LDFLAGS)

#assembler build
$(EXEC_ASM): asm/c8asm.o
	$(CC) -o $@ $^
#disassembler build
$(EXEC_DASM):asm/c8dasm.o
	$(CC) -o $@ $^

#compile src files
%.o: %.c8asm
	$(CC) $(CFLAGS) -c $< -o $@

#cleanup
clean: 
	rm -f $(OBJ) $(EXEC_CHIP8) $(EXEC_ASM) $(EXEC_DASM)
PHONY: all clean

#hooray!! the makefile is now complete!!!

