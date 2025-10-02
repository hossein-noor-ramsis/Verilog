SRC = tb_and_gate.v and_gate.v
OUT = and_test

all:
    iverilog -o $(OUT) $(SRC)

run: all
    vvp $(OUT)

clean:
    del $(OUT).exe
    del wave.vcd

# make run    # compiles & runs
# make clean  # cleans files
