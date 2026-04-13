#!/bin/bash
# Generate PDF from ATP AsciiDoc using Red Hat Consulting theme
# Usage: ./generate-pdf.sh [optional-input-file.adoc]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -n "$1" ]; then
    INPUT_FILE="$1"
else
    INPUT_FILE="$(ls "$SCRIPT_DIR"/ATP_*.adoc 2>/dev/null | head -1)"
fi

[ -z "$INPUT_FILE" ] && { echo "ERROR: No ATP_*.adoc found"; exit 1; }

OUTPUT_FILE="${INPUT_FILE%.adoc}.pdf"
TOP_LEVEL="$(git rev-parse --show-toplevel 2>/dev/null || echo "$SCRIPT_DIR")"
REL_DIR="${SCRIPT_DIR#$TOP_LEVEL/}"

CONTAINER_CMD="docker"
command -v podman &>/dev/null && CONTAINER_CMD="podman"

if command -v $CONTAINER_CMD &>/dev/null; then
    $CONTAINER_CMD run --rm \
        -v "$TOP_LEVEL:/documents/" \
        -w "/documents/$REL_DIR" \
        quay.io/redhat-cop/ubi8-asciidoctor:v2.2.1 \
        asciidoctor-pdf \
        --verbose \
        -a allow-uri-read \
        -a lang=es_US \
        -o "$(basename "$OUTPUT_FILE")" \
        "$(basename "$INPUT_FILE")"
elif command -v asciidoctor-pdf &>/dev/null; then
    cd "$SCRIPT_DIR" && asciidoctor-pdf -a allow-uri-read -a lang=es_US -o "$OUTPUT_FILE" "$INPUT_FILE"
else
    echo "ERROR: No se encontró docker, podman ni asciidoctor-pdf."
    exit 1
fi

[ -f "$OUTPUT_FILE" ] && echo "PDF generado: $OUTPUT_FILE" || { echo "ERROR"; exit 1; }
