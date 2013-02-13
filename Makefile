CXX = g++
CFLAGS_OPT = -O2 #-flto=jobserver
CFLAGS := ${CFLAGS_OPT} -Wall -W --std=gnu99 -g $(shell sdl-config --cflags)
CXXFLAGS := ${CFLAGS_OPT} -Wall -W $(shell sdl-config --cflags)
CPPFLAGS = -Iobj_dir -I/usr/share/verilator/include
OBJECTS = main.o verilated.o UT88.o
LIBS := -pthread -lrt $(shell sdl-config --libs)

VERILOG_TOPLEVEL = UT88
VERILOG_SOURCES = UT88.v Decoder.v IRAM.v tv80_alu.v tv80_core.v tv80_mcode.v \
		  tv80_reg.v TV80SI.v tv80s.v I8080Bootstrap.v ROM.v \
		  VideoController.v VRAM.v VideoSync.v CGROM.v VideoChargen.v \
		  math.v KeyboardController.v i8255.v RowRAM.v MatrixEncoder.v \
		  KeyboardDeserializer.v
VERILOG_LIBRARY = obj_dir/V${VERILOG_TOPLEVEL}__ALL.a

all: ut88

clean:
	rm -rf obj_dir ut88 ${OBJECTS}

${VERILOG_LIBRARY}: ${VERILOG_SOURCES}
	verilator --cc $<
	${MAKE} -C obj_dir -f V${VERILOG_TOPLEVEL}.mk OPT="${CFLAGS_OPT}" || rm -rf obj_dir

ut88: ${VERILOG_LIBRARY} ${OBJECTS}
	+${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -o $@ -Wl,-\( $^ ${LIBS} -Wl,-\)

%.cpp: /usr/share/verilator/include/%.cpp
	cp $< $@

