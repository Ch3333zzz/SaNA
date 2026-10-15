ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
TEMPLATE_DIR := $(ROOT_DIR)/report-template

PANDOC := pandoc
PDF_ENGINE := xelatex

.PHONY: pdf clean

pdf:
	$(PANDOC) README.md \
		--pdf-engine=$(PDF_ENGINE) \
		--template="$(TEMPLATE_DIR)/template.latex" \
		--toc \
		--number-sections \
		--highlight-style=tango \
		-V papersize=a4 \
		-V geometry:margin=20mm \
		-V fontsize=12pt \
		-V mainfont="DejaVu Serif" \
		-V sansfont="DejaVu Sans" \
		-V monofont="DejaVu Sans Mono" \
		-V lang=ru-RU \
		-V toc-title="Содержание" \
		-o report.pdf

clean:
	rm -f report.pdf

