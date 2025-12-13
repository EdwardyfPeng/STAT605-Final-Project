#!/bin/bash

T1_RAW="$1"
T2_RAW="$2"

T1=$(echo "${T1_RAW}" | tr -d '\r\n\t ')
T2=$(echo "${T2_RAW}" | tr -d '\r\n\t ')


MUNGED_DIR="ldsc_results"     # transferred from submit node
LDSC_DIR="ldsc-2.0.1"         # LDSC code
REF_DIR="1KG_REF"             # reference files
LDSCORE_DIR="${REF_DIR}/LDscore"
WEIGHTS_DIR="${REF_DIR}/weights"
OUTDIR="gc_results"

PYTHON="python3"

mkdir -p "${OUTDIR}"

echo "==== Running rg for ${T1} vs ${T2} ===="
echo "CWD         : $(pwd)"
echo "MUNGED_DIR  : ${MUNGED_DIR}"
echo "LDSC_DIR    : ${LDSC_DIR}"
echo "REF_DIR     : ${REF_DIR}"
ls -R

# Paths to munged sumstats
SUM1="${MUNGED_DIR}/${T1}.munged.sumstats.gz"
SUM2="${MUNGED_DIR}/${T2}.munged.sumstats.gz"

# Safety checks
if [ ! -f "${SUM1}" ]; then
    echo "ERROR: Sumstats not found: ${SUM1}"
    exit 1
fi
if [ ! -f "${SUM2}" ]; then
    echo "ERROR: Sumstats not found: ${SUM2}"
    exit 1
fi

# Ensure bitarray 
${PYTHON} -c "import bitarray" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "bitarray not found; installing with pip..."
    ${PYTHON} -m pip install --user bitarray || {
        echo "ERROR: failed to install bitarray"
        exit 1
    }
fi

OUT_PREFIX="${OUTDIR}/${T1}__${T2}.rg"

# Run LDSC genetic correlation
"${PYTHON}" "${LDSC_DIR}/ldsc.py" \
    --rg "${SUM1},${SUM2}" \
    --ref-ld-chr "${LDSCORE_DIR}/LDscore." \
    --w-ld-chr "${WEIGHTS_DIR}/weights.hm3_noMHC." \
    --out "${OUT_PREFIX}"

if [ $? -ne 0 ]; then
    echo "ERROR: ldsc.py --rg failed for ${T1} vs ${T2}"
    exit 1
fi

echo "==== Done ${T1} vs ${T2} ===="
