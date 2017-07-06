########################################################################
### Simple makefile for tex documents.
###
###	Author: Vladislav Mlejnecký
### Email:  v.mlejnecky@seznam.cz, vladislav.mlejnecky@student.upce.cz
### Date:   28.06.2016

# Write output filename into this variable:
OUT_FILENAME = MARK-II_ref_man
# Write main filename:
MAIN = main

###	There should be nothing to edit bellow.
########################################################################

.PHONY: clean clean-all clean_all

all: $(OUT_FILENAME).pdf

#compile tex document
$(OUT_FILENAME).pdf: $(MAIN).tex
	pdflatex $(MAIN).tex
	pdflatex $(MAIN).tex

#delete all unnecessary files including .pdf
clean-all: clean_all
clean_all:
	rm -f *.aux *.log *.out *.toc *.lof tex/*.aux *.pdf

#delete unnecessary files
clean:
	rm -f *.aux *.log *.out *.toc *.lof tex/*.aux
