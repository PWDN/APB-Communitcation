MODEL_DIR          = ./MODEL
APB_UNIT_1_DIR     = ${MODEL_DIR}/APB_EXE_UNIT_1
APB_UNIT_2_DIR     = ${MODEL_DIR}/APB_EXE_UNIT_2
APB_CONTROLLER_DIR = ${MODEL_DIR}/APB_CONTROLLER
APB_BUS_DIR        = ${MODEL_DIR}/APB_BUS
TESTBENCH_DIR      = ./TEST
SYNDTH_DIR         = ./SYNTH
BUILD_DIR          = ./WORK
PROJECT_NAME       = "APB"



waves:
	gtkwave WORK/signals.vcd &

rtl: 
	yosys -s ${SYNTH}/run.ys | tee /synth.log

sim: compile
	./${PROJECT_NAME}.vpp
	mv signals.vcd ${BUILD_DIR}/signals.vcd
	mv ${PROJECT_NAME}.vpp ${BUILD_DIR}/${PROJECT_NAME}.vpp
compile: clear
	iverilog -g2005-sv -tvvp -Wall             \
	    ${APB_BUS_DIR}/*.sv ${APB_CONTROLLER_DIR}/*.sv ${TESTBENCH_DIR}/*.sv \
		-o ./${PROJECT_NAME}.vpp              \
		    | tee ${BUILD_DIR}/${PROJECT_NAME}.iveri.log

clear:
	rm -r ${BUILD_DIR}/* || true
