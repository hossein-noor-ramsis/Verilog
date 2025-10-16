# -----------------------------
# Flexible Verilog Makefile (all testbenches)
# -----------------------------

# All testbenches in test/
TBS := $(wildcard tb/*.v)

# All module files in src/
SRC := $(wildcard src/*.v)

# Output folder
OUTDIR := build

# Flatten testbench names
TB_BASENAMES := $(notdir $(TBS:.v=))

# Build targets
OUTS := $(TB_BASENAMES:%=$(OUTDIR)/%.out)

# OS detection
ifeq ($(OS),Windows_NT)
    MKDIR = if not exist $(OUTDIR) mkdir $(OUTDIR) & if not exist wave mkdir wave
    RM = del /Q
    RM_WAVE = del /Q wave\*.vcd 2>nul || true
else
    MKDIR = mkdir -p $(OUTDIR) wave
    RM = rm -f
    RM_WAVE = rm -f wave/*.vcd
endif

# -----------------------------
# Build all testbenches
# -----------------------------
all: $(OUTS)

$(OUTDIR)/%.out: tb/%.v $(SRC)
	@$(MKDIR)
	iverilog -o $@ $< $(SRC)

# Run all testbenches
run: all
ifeq ($(OS),Windows_NT)
	@for %%T in ($(TB_BASENAMES)) do @echo Running build\%%T.out & vvp build\%%T.out
else
	@for tb in $(TB_BASENAMES); do \
		echo "Running $$tb.out"; \
		vvp build/$$tb.out; \
	done
endif

# Clean
clean:
	$(RM) $(OUTDIR)\*.out 2>nul || true
	$(RM_WAVE)
