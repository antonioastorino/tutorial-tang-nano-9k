#!/usr/bin/env zsh
BOARD="tangnano9k"
FAMILY="GW1N-9C"
DEVICE="GW1NR-LV9QN88PC6/I5"

set -ue
setopt +o nomatch
# Defaults
OPT_VERIFY=false
OPT_CLEAN=false
OPT_FLASH=false
PROJECT_NAME=""

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
    --flash)
        OPT_FLASH=true
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

set +u
PROJECT_NAME="$1"
set -u

if [[ -z "$PROJECT_NAME" ]]; then
    echo "-----------------------------------------------------------------"
    echo "Usage: build-and-run.sh [--verify|--clean|--flash] <project_name>"
    echo "-----------------------------------------------------------------"
    exit 1
fi

cd "${PROJECT_NAME}"

ARTIFACTS_FOLDER=artifacts
CST_FILE="${PROJECT_NAME}.cst"
VERILOG_FILE="${PROJECT_NAME}.sv"
JSON_SYNTH="${ARTIFACTS_FOLDER}/${PROJECT_NAME}.json"
PNR_FILE="${ARTIFACTS_FOLDER}/${PROJECT_NAME}_pnr.json"
FS_FILE="${ARTIFACTS_FOLDER}/${PROJECT_NAME}.fs"
mkdir -p "${ARTIFACTS_FOLDER}"

# Add -sv and `proc` command, not included in the reference documentation
# yosys -p "read_verilog -sv ${VERILOG_FILE}; proc; synth_gowin -json ${JSON_SYNTH}"

if [[ $OPT_CLEAN = true ]]; then
    echo "Cleaning for project '$PROJECT_NAME'"
    rm -rf "$ARTIFACTS_FOLDER"
    exit 0
fi

files=(*.sv)

if [[ $OPT_VERIFY = true ]]; then
    echo "--------------- Verifying ---------------"
    verilator --lint-only *.sv
    yosys -p "read_verilog $(echo ${files[@]}); hierarchy -top top; show top;"
    echo "--------------- Verifying pass ---------------"
    exit 0
fi

echo " --------- YOSYS ------- "
yosys -p "read_verilog $(echo ${files[@]}); hierarchy -top top; synth_gowin -json ${JSON_SYNTH}"

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

# Program Board
echo "Programming.."
if [[ $OPT_FLASH = true ]]; then
    # Write to FLASH
    openFPGALoader -b ${BOARD} ${FS_FILE} -f
else
    # Write to SRAM
    openFPGALoader -b ${BOARD} ${FS_FILE}
fi
exit 1

# -------- UNTESTED FROM HERE ON --------
# Generate Simulation
iverilog -o app_test.o -s test app.v app_tb.v

# Run Simulation
vvp app_test.o

# Cleanup build artifacts
rm app.vcd app.fs app_test.o
