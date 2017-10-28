CC = m2-vbcc
AS = m2-assembler

OBJS = vgaio.o

BUILDDIR = build
SRCDIR   = src
CFLAGS   = -Iinclude -I../spl -quiet -c99

.PHONY: clean

all: $(BUILDDIR) $(addprefix $(BUILDDIR)/,$(OBJS))
	rm -rf $(BUILDDIR)/*.asm

$(BUILDDIR):
	mkdir $(BUILDDIR)

$(BUILDDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) -o=$(@:.o=.asm) $<
	$(AS) -o $@ $(@:.o=.asm)

clean:
	rm -rf $(BUILDDIR)
