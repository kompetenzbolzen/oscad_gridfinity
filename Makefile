SCAD=openscad

STLOPTS= --export-format binstl
PNGOPTS= --colorscheme BeforeDawn --viewall --autocenter --imgsize 800,800 \
	 --render

STLDIR = stlout
PNGDIR = pngout

SRC = $(wildcard *.scad)

STL = $(addprefix $(STLDIR)/,$(SRC:.scad=.stl))
PNG = $(addprefix $(PNGDIR)/,$(SRC:.scad=.png))

.PHONY: _default
_default: stl

.PHONY: all
all: clean stl png

.PHONY: stl
stl: $(STLDIR) $(STL)

$(STLDIR)/gridfinity.stl: gridfinity.scad
	@echo

$(STLDIR)/bitstorage_1x2.stl: bitstorage.scad
	@echo [ STL ] $<
	@$(SCAD) $(STLOPTS) -D ux=2 -o $@ $<

$(STLDIR)/bitstorage_1x1.stl: bitstorage.scad
	@echo [ STL ] $<
	@$(SCAD) $(STLOPTS) -D ux=1 -o $@ $<

$(STLDIR)/bitstorage.stl: $(STLDIR)/bitstorage_1x1.stl $(STLDIR)/bitstorage_1x2.stl
	@echo

$(STLDIR)/%.stl: %.scad
	@echo [ STL ] $<
	@$(SCAD) $(STLOPTS) -o $@ $<

png: $(PNGDIR) $(PNG)

$(PNGDIR)/gridfinity.png: gridfinity.scad
	@echo

$(PNGDIR)/%.png: %.scad
	@echo [ PNG ] $<
	@$(SCAD) $(PNGOPTS) -o $@ $<

$(PNGDIR):
	@mkdir -p $(PNGDIR)/

$(STLDIR):
	@mkdir -p $(STLDIR)/

.PHONY: clean
clean:
	@rm -rf $(STLDIR)/
	@rm -rf $(PNGDIR)/
