#!/bin/bash
#sh/define_shell.sh
LOG_FILE=shell_build.log
VIVADO_XLNX=$1

if [ "$VIVADO_XLNX" = "" ]; then
	echo -e "\r\n"
	echo "[MEEP] INFO: Vivado Path not provided. Make sure you have it added to your PATH"
	VIVADO_XLNX="vivado"
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
CR='\U+2261'

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "This DIR: $SCRIPT_DIR"

echo -e "\r\n"
echo "[MEEP] ***************************************"
echo -e "[MEEP] *** $YELLOW MEEP SHELL GENERATION PROCESS$NC  ***"
echo "[MEEP] ***************************************"
echo "[MEEP] *                                     *"
echo "[MEEP] *   https://www.bsc.es/               *"
echo "[MEEP] *   https://meep-project.eu/          *"
echo "[MEEP] *                                     *"
echo -e "[MEEP] ***************************************\r\n"

EAURL=`grep -o ea_url.txt -e https.*$`
EANAME=$(grep -o ea_url.txt -e NAME.*$ | awk -F ':' '$2 {print $2}')

echo -e "[MEEP] Emulated accelerator:$EANAME\r\n\r\n\t$GREEN $EAURL $NC\r\n"


### Call the main program
$VIVADO_XLNX -mode batch -nolog -nojournal -notrace -source ./tcl/gen_meep.tcl | tee $LOG_FILE

CriticalWarnings=$(grep -riw $LOG_FILE -e Critical)

if [ -n "$CriticalWarnings" ]; then	
	echo -e "$YELLOW[MEEP] Critical warnings summary: $NC\r\n"
	echo "$CriticalWarnings"
fi
