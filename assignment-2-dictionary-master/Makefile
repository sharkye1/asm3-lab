NASM ?= nasm
LD ?= ld

TARGET = dict
OBJECTS = main.o dict.o lib.o

DEMO = demo
DEMO_OBJECTS = demo.o dict.o lib.o

.PHONY: all test test-custom clean

all: $(TARGET)

$(DEMO): $(DEMO_OBJECTS)
	$(LD) -o $@ $(DEMO_OBJECTS)

demo.o: demo.asm colon.inc lib.inc dict.inc
	$(NASM) -f elf64 -o $@ $<

$(TARGET): $(OBJECTS)
	$(LD) -o $@ $(OBJECTS)

main.o: main.asm lib.inc dict.inc words.inc colon.inc
	$(NASM) -f elf64 -o $@ $<

dict.o: dict.asm dict.inc lib.inc
	$(NASM) -f elf64 -o $@ $<

lib.o: lib.asm lib.inc
	$(NASM) -f elf64 -o $@ $<

test: $(TARGET)
	@test "$$(printf 'cat\n' | ./$(TARGET))" = "a small kitik"
	@test "$$(printf 'dog\n' | ./$(TARGET))" = "a loyal animal"
	@test "$$(printf 'red\n' | ./$(TARGET) 2>/dev/null)" = ""
	@test "$$(printf 'unknown\n' | ./$(TARGET) 2>/dev/null)" = ""
	@printf 'Dictionary tests passed\n'

test-custom:
	@test "$$(printf 'third word\n' | ./test_custom.sh "third word=third word explanation" "first word=first word explanation" | tail -n 1)" = "third word explanation"

clean:
	rm -f $(TARGET) $(DEMO) $(OBJECTS) demo.o

