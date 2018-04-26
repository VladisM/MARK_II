CC = m2-vbcc
AS = m2-assembler

BUILDDIR = build
SRCDIR   = src
CFLAGS   = -quiet -c99

SRCS = $(shell find $(SRCDIR) -name '*.c')
OBJS = $(notdir $(SRCS:%.c=%.o))

.PHONY: clean

all: $(BUILDDIR) $(addprefix $(BUILDDIR)/,$(OBJS))

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(BUILDDIR)/%.o: $(SRCDIR)/%.c include/*.h
	$(CC) $(CFLAGS) -o=$(@:.o=.asm) $<
	$(AS) -o $@ $(@:.o=.asm)
	rm -rf $(@:.o=.asm)

clean:
	rm -rf $(BUILDDIR)
