#!/bin/bash

summary_file="gc_summary.txt"
GC_DIR="gc_results"

echo -e "trait1\ttrait2\trg\trg_se\tz\tp" > "$summary_file"

for logfile in "${GC_DIR}"/*.rg.log; do
    [ -e "$logfile" ] || continue


    summary_line=$(sed 's/\r$//' "$logfile" \
        | awk '/Summary of Genetic Correlation Results/ {getline; getline; print; exit}')


    if [ -z "$summary_line" ]; then
        echo "Warning: No summary line found in $logfile, skipping." >&2
        continue
    fi

    # Extract fields: p1, p2, rg, se, z, p
    p1=$(echo "$summary_line" | awk '{print $1}')
    p2=$(echo "$summary_line" | awk '{print $2}')
    rg=$(echo "$summary_line" | awk '{print $3}')
    se=$(echo "$summary_line" | awk '{print $4}')
    z=$(echo "$summary_line" | awk '{print $5}')
    p=$(echo "$summary_line" | awk '{print $6}')


    trait1=$(basename "$p1" .sumstats.gz | sed 's/^munged_//; s/\.munged$//')
    trait2=$(basename "$p2" .sumstats.gz | sed 's/^munged_//; s/\.munged$//')


    echo -e "${trait1}\t${trait2}\t${rg}\t${se}\t${z}\t${p}" >> "$summary_file"
done

echo "Done. Summary written to ${summary_file}"
