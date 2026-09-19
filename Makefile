SCAD=openscad

STLOPTS= --export-format binstl
PNGOPTS= --colorscheme BeforeDawn --viewall --autocenter --imgsize 800,800 \
	 --render

STLDIR = stlout
PNGDIR = pngout

SRC = $(wildcard *.scad)

STL = $(addprefix $(STLDIR)/,$(SRC:.scad=.stl))
PNG = $(addprefix $(PNGDIR)/,$(SRC:.scad=.png))

MULTISIZE_1D = case_clip
MULTISIZE_2D = case_base dip
MULTISIZE_3D = simplebox bitstorage_norm bitstorage_small

SIZES_1D = 1 2 3 4 5 6 7 8 9 10
SIZES_2D = 2x1 2x2 2x3 2x4 3x3 3x4 3x5 3x6 4x4 4x5 4x6 5x5
SIZES_3D = 1x1x4 2x1x4 2x1x3 3x1x4 3x1x3 2x2x4 2x2x4 2x1x5 2x2x5 3x1x5 4x1x5 4x1x6 2x1x6

#STL_MULTI_1D = $(addsuffix .stl,$(foreach model,$(MULTISIZE_1D),$(addprefix $(STLDIR)/multi_$(model)-,$(SIZES_1D))))
#STL_MULTI_2D = $(addsuffix .stl,$(foreach model,$(MULTISIZE_2D),$(addprefix $(STLDIR)/multi_$(model)-,$(SIZES_2D))))
#STL_MULTI_3D = $(addsuffix .stl,$(foreach model,$(MULTISIZE_3D),$(addprefix $(STLDIR)/multi_$(model)-,$(SIZES_3D))))
STL_MULTI_1D = $(addsuffix .stl,$(foreach model,$(MULTISIZE_1D),$(addprefix $(STLDIR)/$(model)-,$(SIZES_1D))))
STL_MULTI_2D = $(addsuffix .stl,$(foreach model,$(MULTISIZE_2D),$(addprefix $(STLDIR)/$(model)-,$(SIZES_2D))))
STL_MULTI_3D = $(addsuffix .stl,$(foreach model,$(MULTISIZE_3D),$(addprefix $(STLDIR)/$(model)-,$(SIZES_3D))))

.PHONY: _default
_default: stl

.PHONY: all
all: clean stl png

.PHONY: multi
multi: $(STL_MULTI_3D) $(STL_MULTI_2D) $(STL_MULTI_1D)

.PHONY: stl
stl: $(STLDIR) $(STL) multi


# TODO test and implement this
# Goal here is to not have the variant parsing seperate below and replace with this.

#$(addprefix $(STLDIR)/,$(addsuffix .stl,$(MULTISIZE_1D) $(MULTISIZE_2D) $(MULTISIZE_3D))): $(STL_MULTI_2D)
#	@echo done

#.PHONY: $(STL_MULTI_2D)
#$(STLDIR)/multi_%.stl:
#	$(eval TARGET_SPLIT=$(subst -, ,$*))
#	$(eval NAME=$(firstword $(TARGET_SPLIT)))
#	$(eval SIZE=$(word 2,$(TARGET_SPLIT)))
#	$(eval SUBST=$(subst x, ,$(SIZE)))
#	$(eval X=$(firstword $(SUBST)))
#	$(eval Y=$(word 2,$(SUBST)))
#	$(eval Z=$(word 3,$(SUBST)))
#	@echo [ STL ] $(NAME) as $(X)x$(Y)$(Z)
#	@$(SCAD) $(STLOPTS) \
#		-D ux=$(X) -D uy=$(Y) -D uz=$(Z) \
#		-o $@ $(NAME).scad
#

# Project specific config

$(STLDIR)/gridfinity.stl: gridfinity.scad
	@echo

$(STLDIR)/psu.stl: psu.scad
	@echo

$(STLDIR)/psu-%.stl: psu.scad
	@echo [ STL ] $< $*
	@$(SCAD) $(STLOPTS) -o $@ psu_$*.scad

$(STLDIR)/bitstorage_small-%.stl: bitstorage.scad
	@echo [ STL ] $< small $*
	@$(SCAD) $(STLOPTS) \
		-D ux=$(firstword $(subst x, ,$*)) -D uy=$(word 2,$(subst x, ,$*)) \
		-D uz=$(word 3,$(subst x, ,$*))\
		-D wrench_size=4\
		-o $@ $<

$(STLDIR)/bitstorage_norm-%.stl: bitstorage.scad
	@echo [ STL ] $< normal $*
	@$(SCAD) $(STLOPTS) \
		-D ux=$(firstword $(subst x, ,$*)) -D uy=$(word 2,$(subst x, ,$*)) \
		-D uz=$(word 3,$(subst x, ,$*))\
		-D wrench_size=6.35\
		-o $@ $<

$(STLDIR)/simplebox-%.stl: simplebox.scad
	@echo [ STL ] $< $*
	@$(SCAD) $(STLOPTS) \
		-D ux=$(firstword $(subst x, ,$*)) -D uy=$(word 2,$(subst x, ,$*)) \
		-D uz=$(word 3,$(subst x, ,$*))\
		-o $@ $<

$(STLDIR)/case_clip-%.stl: case_clip.scad case_base.scad
	@echo [ STL ] $< $*
	@$(SCAD) $(STLOPTS) \
		-D height=$* \
		-o $@ $<

$(STLDIR)/case_base-%.stl: case_base.scad
	@echo [ STL ] $< $*
	@$(SCAD) $(STLOPTS) \
		-D ux=$(firstword $(subst x, ,$*)) -D uy=$(word 2,$(subst x, ,$*)) \
		-o $@ $<

$(STLDIR)/dip-%.stl: dip.scad
	@echo [ STL ] $< $*
	@$(SCAD) $(STLOPTS) \
		-D ux=$(firstword $(subst x, ,$*)) -D uy=$(word 2,$(subst x, ,$*)) \
		-o $@ $<

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
