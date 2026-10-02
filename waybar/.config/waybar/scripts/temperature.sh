#!/bin/bash
set -euo pipefail
shopt -s nullglob

# Cache resolved sensor paths in memory. Never persist boot-dependent hwmon numbers.
kind=${1:-}
shift || true
root=/sys/class/hwmon
interval=0
while (($#)); do
    case "$1" in
        --watch) interval=$2; shift 2 ;;
        --hwmon-root) root=$2; shift 2 ;;
        *) exit 2 ;;
    esac
done
[[ $kind == cpu || $kind == gpu ]] || exit 2
[[ $interval =~ ^[0-9]+([.][0-9]+)?$ ]] || exit 2
paths=(); labels=(); next_discovery=0
warning=70000

read_value() {
    local raw=
    { IFS= read -r raw < "$1"; } 2>/dev/null || [[ -n $raw ]] || return 1
    [[ $raw =~ ^[0-9]+$ && ${#raw} -le 6 ]] || return 1
    value=$((10#$raw))
    ((value > 0 && value < 150000))
}

cpu_rank() {
    rank=99
    case "$1:$2" in
        k10temp:Tctl|zenpower:Tctl|coretemp:'Package id '*) rank=0 ;;
        k10temp:Tdie|zenpower:Tdie) rank=1 ;;
        coretemp:'Core '*) rank=2 ;;
        *) case "${2,,}" in cpu|'cpu temperature'|'cpu temp') rank=3 ;; esac ;;
    esac
}

discover() {
    local device name input label resolved best=99 rank
    paths=(); labels=()
    for device in "$root"/hwmon*; do
        name=
        { IFS= read -r name < "$device/name"; } 2>/dev/null || [[ -n $name ]] || continue
        if [[ $kind == gpu && $name != amdgpu && $name != nouveau ]]; then continue; fi
        for input in "$device"/temp*_input; do
            label=''
            { IFS= read -r label < "${input%_input}_label"; } 2>/dev/null || true
            if [[ $kind == cpu ]]; then
                cpu_rank "$name" "$label"
                ((rank <= best && rank < 99)) || continue
                read_value "$input" || continue
                if ((rank < best)); then paths=(); labels=(); best=$rank; fi
                label=CPU
            else
                case "$label" in
                    edge) label=GPU ;;
                    junction) label=Hotspot ;;
                    mem) label=Memory ;;
                    *)
                        if [[ ${input##*/} == temp1_input && ( $name == nouveau || -z $label ) ]]; then
                            label=GPU
                        else
                            continue
                        fi ;;
                esac
            fi
            resolved=$(readlink -f -- "$input") || continue
            paths+=("$resolved"); labels+=("$label")
        done
    done
    # Refresh identities once a minute; retry unavailable devices every 15 seconds.
    next_discovery=$((SECONDS + 60))
    ((${#paths[@]})) || next_discovery=$((SECONDS + 15))
}

sample() {
    local i label missing=0
    hottest=0; tooltip=''
    for i in "${!paths[@]}"; do
        label=${labels[i]}
        if ! read_value "${paths[i]}"; then
            # Invalid optional GPU readings are omitted; missing files need rediscovery.
            if [[ $kind == cpu || $label == GPU || ! -e ${paths[i]} ]]; then missing=1; fi
            continue
        fi
        if [[ $kind == cpu || $label == GPU ]]; then
            ((value <= hottest)) || hottest=$value
        fi
        if [[ $kind == gpu ]]; then
            [[ -z $tooltip ]] || tooltip+='\n'
            tooltip+="$label: $(((value + 50) / 100 / 10)).$(((value + 50) / 100 % 10))°C"
        fi
    done
    ((missing == 0))
}

while true; do
    if ((SECONDS >= next_discovery)); then discover; fi
    if ! sample; then
        discover
        sample || true
    fi
    if ((hottest == 0)); then
        printf '{"text":"N/A","tooltip":"%s temperature unavailable","class":"unavailable"}\n' "${kind^^}"
    else
        if [[ $kind == cpu ]]; then
            tooltip="CPU: $(((hottest + 50) / 100 / 10)).$(((hottest + 50) / 100 % 10))°C"
        fi
        class=normal
        if ((hottest >= warning)); then
            class=warning
            tooltip+="\nWarning: ${kind^^} temperature is at or above 70°C"
        fi
        printf '{"text":"%s°C","tooltip":"%s","class":"%s"}\n' \
            "$(((hottest + 500) / 1000))" "$tooltip" "$class"
    fi
    [[ $interval != 0 ]] || break
    sleep "$interval"
done
