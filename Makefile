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

SIMPLEBOX_SIZES = $(STLDIR)/simplebox_1x1x4.stl $(STLDIR)/simplebox_2x1x4.stl $(STLDIR)/simplebox_2x1x3.stl \
		  $(STLDIR)/simplebox_3x1x4.stl $(STLDIR)/simplebox_3x1x3.stl $(STLDIR)/simplebox_2x2x4.stl \
		  $(STLDIR)/simplebox_2x2x4.stl

CASE_CLIP_SIZES = $(STLDIR)/case_clip_2.stl $(STLDIR)/case_clip_3.stl $(STLDIR)/case_clip_4.stl $(STLDIR)/case_clip_5.stl \
		  $(STLDIR)/case_clip_6.stl $(STLDIR)/case_clip_7.stl $(STLDIR)/case_clip_8.stl $(STLDIR)/case_clip_9.stl \
		  $(STLDIR)/case_clip_10.stl

CASE_BASE_SIZES = $(STLDIR)/case_base_2x1.stl $(STLDIR)/case_base_2x2.stl $(STLDIR)/case_base_2x3.stl $(STLDIR)/case_base_2x4.stl \
		  $(STLDIR)/case_base_3x3.stl $(STLDIR)/case_base_3x4.stl $(STLDIR)/case_base_3x5.stl $(STLDIR)/case_base_3x6.stl \
		  $(STLDIR)/case_base_4x4.stl $(STLDIR)/case_base_4x5.stl $(STLDIR)/case_base_4x6.stl \
		  $(STLDIR)/case_base_5x5.stl

.PHONY: _default
_default: stl

.PHONY: all
all: clean stl png

.PHONY: stl
stl: $(STLDIR) $(STL)

# Project specific config

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

$(STLDIR)/simplebox_%.stl: simplebox.scad
	@echo [ STL ] $< $*
	@$(SCAD) $(STLOPTS) \
		-D ux=$(firstword $(subst x, ,$*)) -D uy=$(word 2,$(subst x, ,$*)) \
		-D uz=$(word 3,$(subst x, ,$*))\
		-o $@ $<

$(STLDIR)/simplebox.stl: $(SIMPLEBOX_SIZES)
	@echo

$(STLDIR)/case_clip_%.stl: case_clip.scad case_base.scad
	@echo [ STL ] $< $*
	@$(SCAD) $(STLOPTS) \
		-D height=$* \
		-o $@ $<

$(STLDIR)/case_clip.stl: $(CASE_CLIP_SIZES)
	@echo

$(STLDIR)/case_base_%.stl: case_base.scad
	@echo [ STL ] $< $*
	@$(SCAD) $(STLOPTS) \
		-D ux=$(firstword $(subst x, ,$*)) -D uy=$(word 2,$(subst x, ,$*)) \
		-o $@ $<

$(STLDIR)/case_base.stl: $(CASE_BASE_SIZES)
	@echo

# Generic Builds

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
