SLIDE_MD=$(shell fd '.*\.slide.md')
SLIDE_PDF=$(patsubst %.slide.md,%.slide.pdf,$(SLIDE_MD))

REPORT_MD=$(shell fd '.*\.report.md')
REPORT_PDF=$(patsubst %.report.md,%.report.pdf,$(REPORT_MD))


all: $(SLIDE_PDF) $(REPORT_PDF)

clean:
	rm $(SLIDE_PDF)
	rm $(REPORT_PDF)

%.slide.pdf: %.slide.md
	cd `dirname $<`; \
	pandoc `basename $<` \
		--pdf-engine=xelatex \
		-t beamer \
		--toc \
		-V header-includes='\usepackage{tikz}' \
		-V header-includes='\usetikzlibrary{shapes,arrows}' \
		-V theme:metropolis \
		--highlight-style pygments \
		--filter allowFrameBreaks \
		--filter frameTitleContinuation \
		-o `basename $@`

%.report.pdf: %.report.md
	cd `dirname $<`; \
	pandoc `basename $<` \
		-V header-includes='\usepackage{indentfirst}' \
		-V CJKmainfont='Noto Sans CJK SC' \
		-V indent=2 \
		-V mainfont='Noto Sans CJK SC' \
		--pdf-engine=xelatex \
		-o `basename $@`
