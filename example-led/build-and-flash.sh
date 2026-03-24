#!/usr/bin/env zsh
#BOARD="tangnano9k"
FAMILY="GW1N-9C"
DEVICE="GW1NR-LV9QN88PC6/I5"
PROJECT_NAME=$1
CST_FILE="${PROJECT_NAME}.cst"
VERILOG_FILE="${PROJECT_NAME}.sv"
JSON_SYNTH="${PROJECT_NAME}.json"
PNR_FILE="${PROJECT_NAME}_pnr.json"
FS_FILE="${PROJECT_NAME}.fs"


set -ue


# Add -sv and `proc` command, not included in the reference documentation 
# yosys -p "read_verilog -sv ${VERILOG_FILE}; proc; synth_gowin -json ${JSON_SYNTH}"
yosys -p "read_verilog ${VERILOG_FILE}; synth_gowin -json ${JSON_SYNTH}"
# Place and Route
nextpnr-himbaechel \
    --json ${JSON_SYNTH} \
    --write ${PNR_FILE} \
    --device ${DEVICE} \
    --vopt family=${FAMILY} \
    --vopt cst=${CST_FILE} \
    --freq 27

echo "-------------------------------"
gowin_pack -d ${FAMILY} -o ${FS_FILE} ${PNR_FILE} 

exit 1
# -------- UNTESTED FROM HERE ON --------
# Program Board
openFPGALoader -b ${BOARD} ${FS_FILE} -f

# Generate Simulation
iverilog -o app_test.o -s test app.v app_tb.v

# Run Simulation
vvp app_test.o

# Cleanup build artifacts
rm app.vcd app.fs app_test.o
