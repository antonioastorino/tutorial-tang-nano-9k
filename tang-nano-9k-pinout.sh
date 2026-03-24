#!/usr/bin/env zsh
# ------------------------------------------------------------
#  Tang Nano 9K - terminal pinout viewer
#  Usage:  zsh tangnano9k-pinout.zsh [--no-color] [--j5] [--j6]
#
#  --j5        show J5 (left/USB-C header) only
#  --j6        show J6 (right/HDMI header) only
#  --j5 --j6   show both headers (same as default)
#  --no-color  disable ANSI colours
# ------------------------------------------------------------

# -- argument parsing ----------------------------------------
OPT_NOCOLOR=0 OPT_J5=0 OPT_J6=0 OPT_EXPLICIT=0
for arg in "$@"; do
    case $arg in
    --no-color) OPT_NOCOLOR=1 ;;
    --j5)
        OPT_J5=1
        OPT_EXPLICIT=1
        ;;
    --j6)
        OPT_J6=1
        OPT_EXPLICIT=1
        ;;
    *)
        echo "Unknown option: $arg" >&2
        echo "Usage: zsh tangnano9k-pinout.zsh [--no-color] [--j5] [--j6]" >&2
        exit 1
        ;;
    esac
done
# if neither --j5 nor --j6 given, show both (default/full mode)
if ((OPT_J5 == 0 && OPT_J6 == 0)); then
    OPT_J5=1 OPT_J6=1
fi

# -- colour palette ------------------------------------------
if ((OPT_NOCOLOR)) || [[ -z "$TERM" || "$TERM" == "dumb" ]]; then
    RST="" BOLD="" DIM=""
    CPWR="" CGND="" CGPIO="" CSPI="" CHDMI="" CCLK="" CLED=""
    CBTN="" CUART="" CRGB="" C1V8="" CJTAG=""
else
    RST=$'\e[0m'
    BOLD=$'\e[1m'
    DIM=$'\e[2m'
    CPWR=$'\e[38;5;220m'  # gold   - 3.3 V / 5 V
    CGND=$'\e[38;5;239m'  # grey   - GND
    CGPIO=$'\e[38;5;39m'  # blue   - general IO
    CSPI=$'\e[38;5;208m'  # orange - SPI / TF-card
    CHDMI=$'\e[38;5;198m' # pink   - HDMI
    CCLK=$'\e[38;5;118m'  # green  - clock / PLL
    CLED=$'\e[38;5;226m'  # yellow - LEDs
    CBTN=$'\e[38;5;213m'  # violet - buttons
    CUART=$'\e[38;5;87m'  # cyan   - UART
    CRGB=$'\e[38;5;183m'  # lilac  - RGB LCD
    C1V8=$'\e[38;5;203m'  # red    - 1.8 V IO
    CJTAG=$'\e[38;5;244m' # silver - JTAG
fi

# -- helper --------------------------------------------------
# col <color> <text>  ->  colored, fixed-width label
col() {
    printf "${1}%-22s${RST}" "$2"
}

# -- pin data ------------------------------------------------
# Format per row:  left-pin  left-label  left-color  right-pin  right-label  right-color
# J5 = left header (pins 1-24),  J6 = right header (pins 1-24, mirrored as 48-25)

typeset -a LEFT_PIN LEFT_LBL LEFT_COL
typeset -a RIGHT_PIN RIGHT_LBL RIGHT_COL

# J5 - left connector (USB-C side)
LEFT_PIN=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24)
LEFT_LBL=(
    "PIN38 TF_CS"
    "PIN37 TF_MOSI"
    "PIN36 TF_SCLK"
    "PIN39 TF_MISO"
    "PIN25 IOB8A"
    "PIN26 IOB8B"
    "PIN27 IOB11A"
    "PIN28 IOB11B"
    "PIN29 IOB13A"
    "PIN30 IOB13B"
    "PIN33 RGB_DE"
    "PIN34 RGB_VS"
    "PIN40 RGB_HS"
    "PIN35 RGB_CK"
    "PIN41 RGB_B7"
    "PIN42 RGB_B6"
    "PIN51 RGB_B5"
    "PIN53 RGB_B4"
    "PIN54 RGB_B3"
    "PIN55 RGB_G7"
    "PIN56 RGB_G6"
    "PIN57 RGB_G5"
    "GND"
    "3V3"
)
LEFT_COL=(
    $CSPI $CSPI $CSPI $CSPI
    $CGPIO $CGPIO $CGPIO $CGPIO $CGPIO $CGPIO
    $CRGB $CRGB $CRGB $CRGB $CRGB $CRGB $CRGB $CRGB $CRGB $CRGB $CRGB $CRGB
    $CGND $CPWR
)

# J6 - right connector (HDMI/far side)
RIGHT_PIN=(48 47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25)
RIGHT_LBL=(
    "PIN63 RGBINIT"
    "PIN86 BL_PWM 1V8"
    "PIN85 1V8"
    "PIN84 1V8"
    "PIN83 1V8"
    "PIN82 1V8"
    "PIN81 1V8"
    "PIN80 1V8"
    "PIN79 1V8"
    "PIN77 SPILCD_MO"
    "PIN76 SPILCD_MCLK"
    "HDMI_D2_P"
    "HDMI_D2_N"
    "HDMI_D1_P"
    "HDMI_D1_N"
    "HDMI_D0_P"
    "HDMI_D0_N"
    "HDMI_CK_P"
    "HDMI_CK_N"
    "GND"
    "GND"
    "5V"
    "3V3"
    "GND"
)
RIGHT_COL=(
    $CRGB $C1V8 $C1V8 $C1V8 $C1V8 $C1V8 $C1V8 $C1V8 $C1V8
    $CSPI $CSPI
    $CHDMI $CHDMI $CHDMI $CHDMI $CHDMI $CHDMI $CHDMI $CHDMI
    $CGND $CGND $CPWR $CPWR $CGND
)

# -- onboard peripherals (always shown below the header) -----
typeset -a OB_LBL OB_VAL OB_COL
OB_LBL=("CLK (27 MHz)" "LED1" "LED2" "LED3" "LED4" "LED5" "LED6" "BTN S1 (USER)" "BTN S2 (RESET)" "UART TX->FPGA" "UART RX<-FPGA" "JTAG TMS" "JTAG TCK" "JTAG TDI" "JTAG TDO")
OB_VAL=("PIN52" "PIN10" "PIN11" "PIN13" "PIN14" "PIN15" "PIN16" "PIN88 (MODE0)" "PIN87 (MODE1)" "PIN18 (BL702)" "PIN17 (BL702)" "IOL11A" "IOL11B" "IOL12B" "IOL13A")
OB_COL=($CCLK $CLED $CLED $CLED $CLED $CLED $CLED $CBTN $CBTN $CUART $CUART $CJTAG $CJTAG $CJTAG $CJTAG)

# -- legend entries ------------------------------------------
# Each entry has: colour, label, source flags (j5=1, j6=2, onboard=4; combined with |)
typeset -a LEG_COL LEG_LBL LEG_SRC
LEG_COL=($CPWR $CGND $CGPIO $CSPI $CHDMI $CCLK $CLED $CBTN $CUART $CRGB $C1V8 $CJTAG)
LEG_LBL=("Power" "GND" "GPIO" "SPI/TF" "HDMI" "Clock" "LED" "Button" "UART" "RGB LCD" "1.8V IO" "JTAG")
LEG_SRC=(3 3 1 3 2 4 4 4 4 3 2 4)
# source key: 1=J5 only, 2=J6 only, 3=J5+J6, 4=onboard only

# ============================================================
#  RENDER
# ============================================================

# -- determine which legend sources to include ---------------
# source key: 1=J5, 2=J6, 4=onboard; combined with bitwise OR
local src_mask=0
((OPT_J5)) && ((src_mask |= 1))
((OPT_J6)) && ((src_mask |= 2))
# onboard peripherals shown only in full (default) mode, not when --j5/--j6 explicit
local show_onboard=0
if ((!OPT_EXPLICIT)); then
    show_onboard=1
    ((src_mask |= 4))
fi

echo ""
echo "${BOLD}  +----------------------------------------------------------+${RST}"
echo "${BOLD}  |          Tang Nano 9K - GW1NR-9C FPGA Pinout            |${RST}"
echo "${BOLD}  +----------------------------------------------------------+${RST}"
echo ""

local n=${#LEFT_PIN[@]}

# -- both headers --------------------------------------------
if ((OPT_J5 && OPT_J6)); then
    echo "  ${DIM}Left header (J5)                    Right header (J6)${RST}"
    echo "  ${DIM}------------------------------------------------------------${RST}"
    printf "  ${DIM}%-4s %-22s        %-22s %-4s${RST}\n" "Pin" "Signal" "Signal" "Pin"
    echo "  ${DIM}------------------------------------------------------------${RST}"
    for ((i = 1; i <= n; i++)); do
        printf "  ${LEFT_COL[$i]}%2s${RST}   " "${LEFT_PIN[$i]}"
        col "${LEFT_COL[$i]}" "${LEFT_LBL[$i]}"
        printf "  ||  "
        col "${RIGHT_COL[$i]}" "${RIGHT_LBL[$i]}"
        printf " ${RIGHT_COL[$i]}%2s${RST}\n" "${RIGHT_PIN[$i]}"
    done

# -- J5 only -------------------------------------------------
elif ((OPT_J5)); then
    echo "  ${DIM}Left header (J5) - USB-C side${RST}"
    echo "  ${DIM}-----------------------------${RST}"
    printf "  ${DIM}%-4s %-22s${RST}\n" "Pin" "Signal"
    echo "  ${DIM}-----------------------------${RST}"
    for ((i = 1; i <= n; i++)); do
        printf "  ${LEFT_COL[$i]}%2s${RST}   " "${LEFT_PIN[$i]}"
        printf "${LEFT_COL[$i]}%s${RST}\n" "${LEFT_LBL[$i]}"
    done

# -- J6 only -------------------------------------------------
elif ((OPT_J6)); then
    echo "  ${DIM}Right header (J6) - HDMI side${RST}"
    echo "  ${DIM}-----------------------------${RST}"
    printf "  ${DIM}%-4s %-22s${RST}\n" "Pin" "Signal"
    echo "  ${DIM}-----------------------------${RST}"
    for ((i = 1; i <= n; i++)); do
        printf "  ${RIGHT_COL[$i]}%2s${RST}   " "${RIGHT_PIN[$i]}"
        printf "${RIGHT_COL[$i]}%s${RST}\n" "${RIGHT_LBL[$i]}"
    done
fi

# -- onboard peripherals (default/full mode only) ------------
if ((show_onboard)); then
    echo ""
    echo "  ${DIM}------------------------------------------------------------${RST}"
    echo "  ${BOLD}Onboard peripherals${RST}"
    echo "  ${DIM}------------------------------------------------------------${RST}"
    local ob_n=${#OB_LBL[@]}
    for ((i = 1; i <= ob_n; i++)); do
        printf "  ${OB_COL[$i]}%-20s${RST}  %s\n" "${OB_LBL[$i]}" "${OB_VAL[$i]}"
    done
fi

# -- legend (filtered to active sources) ---------------------
echo ""
echo "  ${DIM}------------------------------------------------------------${RST}"
echo "  ${BOLD}Legend${RST}"
echo "  ${DIM}------------------------------------------------------------${RST}"

local leg_n=${#LEG_COL[@]}
local per_row=4
local col_count=0
for ((i = 1; i <= leg_n; i++)); do
    # include entry if any of its source bits overlap with the active mask
    if ((LEG_SRC[$i] & src_mask)); then
        printf "  ${LEG_COL[$i]}* %-10s${RST}" "${LEG_LBL[$i]}"
        ((col_count++))
        if ((col_count % per_row == 0)); then echo ""; fi
    fi
done
((col_count % per_row != 0)) && echo ""
echo ""
echo "  ${DIM}Tip: zsh tangnano9k-pinout.zsh [--no-color] [--j5] [--j6]${RST}"
echo ""
