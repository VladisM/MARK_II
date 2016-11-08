########################################################################
### Simple makefile for tex documents.
###
###	Author: Vladislav Mlejnecký
### Email:  v.mlejnecky@seznam.cz, st49545@student.upce.cz
### Date:   28.06.2016

# Write main filename:
MAIN = main

###	There should be nothing to edit bellow.
########################################################################

.PHONY: clean clean-all clean_all

all: $(MAIN).pdf
	
#compile tex document
$(MAIN).pdf: ./tex/$(MAIN).tex
	pdflatex ./tex/$(MAIN).tex
	pdflatex ./tex/$(MAIN).tex

#compile tex and clean
bake: $(MAIN).pdf
	rm -f *.aux *.log *.out *.toc *.lof *.lot tex/*.aux	
	
#delete all unnecessary files including .pdf
clean-all: clean_all
clean_all:
	rm -f *.aux *.log *.out *.toc *.lof *.lot tex/*.aux *.pdf
	
#delete unnecessary files
clean:
	rm -f *.aux *.log *.out *.toc *.lof *.lot tex/*.aux

