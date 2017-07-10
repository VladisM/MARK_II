
.PHONY: clean clean-all clean_all

all:
	pdflatex main.tex
	pdflatex main.tex

#delete all unnecessary files including .pdf
clean-all: clean_all
clean_all: clean
	rm -f main.pdf

#delete unnecessary files
clean:
	rm -f *.log *.out *.toc *.lof *.lot
	find . -name '*.aux' -delete
