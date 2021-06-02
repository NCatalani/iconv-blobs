#!/bin/bash
#
# Bash wrapper to process big files with iconv

readonly BLOB_SIZE="100M"

ShowUsage() {
    echo "Usage: $0 [iconv_options...] [files...]"
}

BlobAndRun() {
    local file

    file="$1"

    split - -d --line-bytes="$BLOB_SIZE" blob < "$file"

    ls blob* | while read blob
    do
        RunIconv "$blob"
    done

    rm blob*
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
