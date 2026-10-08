#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

for tool in iverilog vvp verilator; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        printf 'Erro: ferramenta obrigatoria nao encontrada: %s\n' "$tool" >&2
        printf 'Instale Icarus Verilog e Verilator antes de executar este fluxo.\n' >&2
        exit 127
    fi
done

build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT

iverilog -g2012 -Wall -s tb_week1 \
    -o "$build_dir/tb_week1.vvp" \
    "$repo_root/rtl/week1_smoke.v" \
    "$repo_root/tb/tb_week1.sv"
vvp "$build_dir/tb_week1.vvp"

verilator --lint-only --Wall --top-module week1_smoke \
    "$repo_root/rtl/week1_smoke.v"

printf 'PASS: compilacao, simulacao e lint concluidos.\n'