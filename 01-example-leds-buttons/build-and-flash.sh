#!/usr/bin/env zsh
#BOARD="tangnano9k"
FAMILY="GW1N-9C"
DEVICE="GW1NR-LV9QN88PC6/I5"

set -ue
setopt +o nomatch
# Defaults
OPT_VERIFY=false
OPT_CLEAN=false

# Parse flags
while [[ $# -gt 0 ]]; do
    case $1 in
    --verify)
        OPT_VERIFY=true
        shift
        ;;
    --clean)
        OPT_CLEAN=true
        shift
        ;;
    -*)
        echo "Unknown flag: $1"
        exit 1
        ;;
    *)
        break
        ;;
    esac
done

# Single positional argument
PROJECT_NAME="$1"

if [[ -z "$PROJECT_NAME" ]]; then
    echo "Usage: build-and-run.sh [--verify|--clean] <project_name>"
    exit 1
fi

ARTIFACTS_FOLDER=artifacts
CST_FILE="${PROJECT_NAME}.cst"
VERILOG_FILE="${PROJECT_NAME}.sv"
JSON_SYNTH="${ARTIFACTS_FOLDER}${PROJECT_NAME}.json"
PNR_FILE="${ARTIFACTS_FOLDER}${PROJECT_NAME}_pnr.json"
FS_FILE="${ARTIFACTS_FOLDER}${PROJECT_NAME}.fs"
mkdir -p "${ARTIFACTS_FOLDER}"

# Add -sv and `proc` command, not included in the reference documentation
# yosys -p "read_verilog -sv ${VERILOG_FILE}; proc; synth_gowin -json ${JSON_SYNTH}"

echo $OPT_CLEAN
if [[ $OPT_CLEAN = true ]]; then
    echo "Cleaning for project '$PROJECT_NAME'"
    rm -rf "$ARTIFACTS_FOLDER"
    exit 0
fi

if [[ $OPT_VERIFY = true ]]; then
    echo "--------------- Verifying ---------------"
    verilator --lint-only ${VERILOG_FILE}
    yosys -p "read_verilog ${VERILOG_FILE}; show;"
    echo "--------------- Verifying pass ---------------"
    exit 0
fi

echo " --------- YOSYS ------- "
yosys -p "read_verilog ${VERILOG_FILE}; synth_gowin -json ${JSON_SYNTH}"

echo " --------- PLACE and ROUTE ------- "
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
