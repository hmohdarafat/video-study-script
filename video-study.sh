output="video_durations.csv"
total=0

echo "file,duration_hms,challenge_hms,script" > "$output"

while IFS= read -r -d '' f; do

  dur=$(ffprobe -v error -show_entries format=duration \
    -of default=noprint_wrappers=1:nokey=1 "$f")

  secs=$(awk -v d="$dur" 'BEGIN {print int(d)}')
  total=$((total + secs))

  # duration
  h=$((secs / 3600))
  m=$(((secs % 3600) / 60))
  s=$((secs % 60))
  hms=$(printf "%02d:%02d:%02d" "$h" "$m" "$s")

  # challenge
  ch=$((secs / 2))
  ch_h=$((ch / 3600))
  ch_m=$(((ch % 3600) / 60))
  ch_s=$((ch % 60))
  challenge_hms=$(printf "%02d:%02d:%02d" "$ch_h" "$ch_m" "$ch_s")

  # script column
  script="video=\"$f\"; t=\"$challenge_hms\"; xdg-open \"\$video\" >/dev/null 2>&1 & IFS=: read h m s <<< \"\$t\"; total=\$((10#\$h*3600+10#\$m*60+10#\$s)); while [ \$total -ge 0 ]; do printf \"\\\\r%02d:%02d:%02d\" \$((total/3600)) \$(((total%3600)/60)) \$((total%60)); sleep 1; ((total--)); done; echo; for i in 1 2 3; do paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null; done"

  printf "%-60s %s (challenge: %s)\n" "$f" "$hms" "$challenge_hms"

  printf "\"%s\",%s,%s,\"%s\"\n" "$f" "$hms" "$challenge_hms" "$script" >> "$output"

done < <(find . -type f -iname "*.mp4" -print0 | sort -zV)

# ---- TOTAL ----
total_h=$((total / 3600))
total_m=$(((total % 3600) / 60))
total_s=$((total % 60))
total_hms=$(printf "%02d:%02d:%02d" "$total_h" "$total_m" "$total_s")

printf "\nTOTAL: %s\n" "$total_hms"
printf "\"TOTAL\",%s,,\n" "$total_hms" >> "$output"

# ---- TIME BLOCK ----

now_hms=$(date +"%I:%M:%S %p")
now_epoch=$(date +%s)

max_epoch=$((now_epoch + total))
max_deadline=$(date -d "@$max_epoch" +"%I:%M:%S %p")

half_total=$((total / 2))
challenge_epoch=$((now_epoch + half_total))
challenge_deadline=$(date -d "@$challenge_epoch" +"%I:%M:%S %p")

printf "CURRENT TIME %s (00:00:00)\n" "$now_hms"
printf "MAX DEADLINE %s (%s)\n" "$max_deadline" "$total_hms"
printf "CHALLENGE DEADLINE %s (%s)\n" "$challenge_deadline" "$(printf '%02d:%02d:%02d' $((half_total/3600)) $(((half_total%3600)/60)) $((half_total%60)))"

printf "\"CURRENT TIME\",%s (00:00:00)\n" "$now_hms" >> "$output"
printf "\"MAX DEADLINE\",%s (%s)\n" "$max_deadline" "$total_hms" >> "$output"
printf "\"CHALLENGE DEADLINE\",%s (%s)\n" "$challenge_deadline" "$(printf '%02d:%02d:%02d' $((half_total/3600)) $(((half_total%3600)/60)) $((half_total%60)))" >> "$output"