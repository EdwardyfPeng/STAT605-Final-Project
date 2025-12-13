#!/bin/bash


FILE_RAW="$1"


FILE=$(echo "${FILE_RAW}" | tr -d '\r\n\t ')


DATA_FILE="${FILE}"
LDSC_DIR="ldsc-2.0.1"
REF_DIR="1KG_REF"
LDSCORE_DIR="${REF_DIR}/LDscore"
WEIGHTS_DIR="${REF_DIR}/weights"
OUTDIR="ldsc_results"

MERGE_SNPLIST="w_hm3.snplist"


PYTHON="python3"

mkdir -p "${OUTDIR}"

BASENAME="${FILE%.txt}"

INPUT="${DATA_FILE}"
MUNGED="${OUTDIR}/${BASENAME}.munged"

echo "==== Processing raw='${FILE_RAW}' clean='${FILE}' ===="
echo "CWD          : $(pwd)"
echo "Input file   : ${INPUT}"
echo "Munged prefix: ${MUNGED}"
ls -R

# Safety check
if [ ! -f "${INPUT}" ]; then
    echo "ERROR: Input file not found: ${INPUT}"
    exit 1
fi
if [ ! -f "${MERGE_SNPLIST}" ]; then
    echo "ERROR: Merge-alleles file not found: ${MERGE_SNPLIST}"
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

# Step 1: Munge summary statistics WITH --merge-alleles
"${PYTHON}" "${LDSC_DIR}/munge_sumstats.py" \
    --sumstats "${INPUT}" \
    --out "${MUNGED}" \
    --snp ID \
    --a1 A1 \
    --a2 REF \
    --p P \
    --signed-sumstats BETA,0 \
    --N-col OBS_CT \
    --merge-alleles "${MERGE_SNPLIST}"

if [ $? -ne 0 ]; then
    echo "ERROR: munge_sumstats.py failed for ${FILE}"
    exit 1
fi

# Step 2: LDSC heritability
REF_LD_PREFIX="${LDSCORE_DIR}/LDscore."
W_LD_PREFIX="${WEIGHTS_DIR}/weights.hm3_noMHC."

"${PYTHON}" "${LDSC_DIR}/ldsc.py" \
    --h2 "${MUNGED}.sumstats.gz" \
    --ref-ld-chr "${REF_LD_PREFIX}" \
    --w-ld-chr "${W_LD_PREFIX}" \
    --out "${OUTDIR}/${BASENAME}.ldsc"

if [ $? -ne 0 ]; then
    echo "ERROR: ldsc.py failed for ${FILE}"
    exit 1
fi

echo "==== Done ${FILE} ===="
