SCAD=openscad

STLOPTS= --export-format binstl
PNGOPTS= --viewall --autocenter --imgsize 400,400 --render

SRC = $(wildcard *.scad)

STL = $(SRC:.scad=.stl)
PNG = $(SRC:.scad=.png)

_default: stl

all: clean stl png

stl: $(STL)

gridfinity.stl: gridfinity.scad
	@echo

%.stl: %.scad
	@echo [ STL ] $<
	@$(SCAD) $(STLOPTS) -o $@ $<


png: $(PNG)

gridfinity.png: gridfinity.scad
	@echo

%.png: %.scad
	@echo [ PNG ] $<
	@$(SCAD) $(SCADOPTS) -o $@ $<

.PHONY: clean
clean:
	@rm -f *.stl
	@rm -f *.png
