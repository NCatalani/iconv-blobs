#!/bin/bash
#
# Bash wrapper to process big files with iconv

readonly BLOB_SIZE=$((1024 * 1024 * 100))

ShowUsage() {
    echo "Usage: $0 [iconv_options...] [files...]"
}

CreateTmp() {
    local tmp

    tmp=$(mktemp) || exit 1

    echo "$tmp"
}

RemoveTmp() {
    local tmp

    tmp=$1
    
    rm -f "$tmp" || exit 1
}

BlobAndRun() {
    local file
    local filesize 
    local linesize
    local tmp 

    file=$1
    filesize=0
    tmp=$(CreateTmp)

    while IFS= read -r line; do
        linesize=$(echo "$line" | wc -c)
        echo "$line" >> "$tmp"
        (( filesize += linesize )) 

        (( filesize >= BLOB_SIZE )) && RunIconv "$tmp" && RemoveTmp "$tmp" && tmp=$(CreateTmp) && filesize=0
    done < "$file"
    
    (( filesize > 0)) && RunIconv "$tmp" && RemoveTmp "$tmp"
}

RunIconv() {
    local file

    file="$1"

    iconv $flags $file || exit 1
}

(( $# < 1 )) && ShowUsage && exit 1

declare -a files
declare -- flags
declare -i use_stdin=0

#Parsing args
for arg in "$@"; do
    [[ "$arg" = "-" ]]  &&  use_stdin=1     && continue
    [[ -f $arg ]]       &&  files+=("$arg") && continue
    flags+=$(printf ' %s' "$arg")
done

#Partitioning into smaller pieces and processing with iconv
for file in "${files[@]}"; do
    BlobAndRun "$file"
done

(( use_stdin == 1 )) && BlobAndRun /dev/stdin