#!/bin/bash

# Directory containing LDSC log files
LOG_DIR="ldsc_results"

# Output summary file
OUT_FILE="h2_summary.txt"

# Write header
echo -e "trait\th2\th2_se\tlambda_gc\tmean_chi2\tintercept\tintercept_se\tratio\tratio_se" > "${OUT_FILE}"

# Loop over all .ldsc.log files
for log in "${LOG_DIR}"/*.ldsc.log; do
    # Skip if no files match
    [ -e "$log" ] || continue

    # Trait name from file name, e.g. BMI.ldsc.log -> BMI
    trait=$(basename "$log" .ldsc.log)

    # Total Observed scale h2: 0.1864 (0.0051)
    h2_line=$(grep -m1 "Total Observed scale h2" "$log")
    if [ -z "$h2_line" ]; then
        echo "Warning: No h2 line found in $log, skipping."
        continue
    fi
    h2=$(echo "$h2_line" | awk '{print $5}')
    h2_se=$(echo "$h2_line" | awk '{gsub("[()]", "", $6); print $6}')

    # Lambda GC: 2.5926
    lam_line=$(grep -m1 "Lambda GC" "$log")
    lambda_gc=$(echo "$lam_line" | awk '{print $3}')

    # Mean Chi^2: 3.7647
    chi_line=$(grep -m1 "Mean Chi" "$log")
    mean_chi2=$(echo "$chi_line" | awk '{print $4}')

    # Intercept: 1.1079 (0.0182)
    int_line=$(grep -m1 "^Intercept:" "$log")
    intercept=$(echo "$int_line" | awk '{print $2}')
    intercept_se=$(echo "$int_line" | awk '{gsub("[()]", "", $3); print $3}')

    # Ratio: 0.039 (0.0066)
    ratio_line=$(grep -m1 "^Ratio:" "$log")
    ratio=$(echo "$ratio_line" | awk '{print $2}')
    ratio_se=$(echo "$ratio_line" | awk '{gsub("[()]", "", $3); print $3}')

    # Append to summary file
    echo -e "${trait}\t${h2}\t${h2_se}\t${lambda_gc}\t${mean_chi2}\t${intercept}\t${intercept_se}\t${ratio}\t${ratio_se}" >> "${OUT_FILE}"
done

echo "Done. Summary written to ${OUT_FILE}"
