SCAD=openscad

STLOPTS= --export-format binstl
PNGOPTS= --colorscheme BeforeDawn --viewall --autocenter --imgsize 800,800 \
	 --render

STLDIR = stlout
PNGDIR = pngout

SRC = $(wildcard *.scad)

STL = $(addprefix $(STLDIR)/,$(SRC:.scad=.stl))
PNG = $(addprefix $(PNGDIR)/,$(SRC:.scad=.png))

BITSTORAGE_SIZES = $(STLDIR)/bitstorage_1x1x6.35.stl $(STLDIR)/bitstorage_1x2x6.35.stl $(STLDIR)/bitstorage_2x2x6.35.stl \
	$(STLDIR)/bitstorage_1x1x4.stl $(STLDIR)/bitstorage_1x2x4.stl $(STLDIR)/bitstorage_2x2x4.stl

.PHONY: _default
_default: stl

.PHONY: all
all: clean stl png

.PHONY: stl
stl: $(STLDIR) $(STL)

$(STLDIR)/gridfinity.stl: gridfinity.scad
	@echo

$(STLDIR)/bitstorage_%.stl: bitstorage.scad
	@echo [ STL ] $< $*
	@$(SCAD) $(STLOPTS) \
		-D ux=$(firstword $(subst x, ,$*)) -D uy=$(word 2,$(subst x, ,$*)) \
		-D wrench_size=$(word 3,$(subst x, ,$*))\
		-o $@ $<

$(STLDIR)/bitstorage.stl: $(BITSTORAGE_SIZES)
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
