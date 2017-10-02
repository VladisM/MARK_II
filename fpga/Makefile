DESIGN_NAME = MARK_II
QUARTUS_OPTIONS =


all: asm

project: $(TCL_FILE)
	quartus_sh $(QUARTUS_OPTIONS) -t $(DESIGN_NAME).tcl

map: project
	quartus_map $(QUARTUS_OPTIONS) $(DESIGN_NAME)

fit: map
	quartus_fit $(QUARTUS_OPTIONS) $(DESIGN_NAME)

asm: fit
	quartus_asm $(QUARTUS_OPTIONS) $(DESIGN_NAME)

sta: asm
	quartus_sta $(QUARTUS_OPTIONS) $(DESIGN_NAME)

load: asm
	quartus_pgm --mode=jtag -o "P;output_files/$(DESIGN_NAME).sof"

clean:
	rm -rf $(DESIGN_NAME).qpf $(DESIGN_NAME).qsf output_files/ db/ incremental_db/
