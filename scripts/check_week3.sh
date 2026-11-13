#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
snps_env="/Tools/synopsys-scripts/snps.sh"

if ! command -v vcs >/dev/null 2>&1 && [ -f "$snps_env" ]; then
    # shellcheck disable=SC1090
    source "$snps_env"
fi

if ! command -v vcs >/dev/null 2>&1; then
    printf 'Erro: ferramenta obrigatoria nao encontrada: vcs\n' >&2
    printf 'Carregue o ambiente Synopsys com: source %s\n' "$snps_env" >&2
    exit 127
fi

build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT

vcs -full64 -sverilog -timescale=1ns/1ps -lca \
    +lint=all \
    -l "$build_dir/compile.log" \
    -o "$build_dir/simv" \
    "$repo_root/rtl/minisoc_aes/minisoc_aes_sbox.sv" \
    "$repo_root/rtl/minisoc_aes/minisoc_aes_sub_bytes.sv" \
    "$repo_root/rtl/minisoc_aes/minisoc_aes_shift_rows.sv" \
    "$repo_root/rtl/minisoc_aes/minisoc_aes_inv_sbox.sv" \
    "$repo_root/rtl/minisoc_aes/minisoc_aes_inv_sub_bytes.sv" \
    "$repo_root/rtl/minisoc_aes/minisoc_aes_inv_shift_rows.sv" \
    "$repo_root/rtl/minisoc_aes/minisoc_aes_mix_columns.sv" \
    "$repo_root/rtl/minisoc_aes/minisoc_aes_inv_mix_columns.sv" \
    "$repo_root/rtl/minisoc_aes/minisoc_aes_add_round_key.sv" \
    "$repo_root/tb/tb_week3.sv"

(
    cd "$repo_root"
    "$build_dir/simv" -no_save -l "$build_dir/sim.log"
)

grep -q "PASS: all 256 inverse S-box entries" "$build_dir/sim.log"
grep -q "PASS: FIPS-197 Appendix B MixColumns and inverse" "$build_dir/sim.log"
grep -q "PASS: FIPS-197 Appendix B AddRoundKey" "$build_dir/sim.log"
grep -q "PASS: FIPS-197 Appendix B inverse SubBytes/ShiftRows" "$build_dir/sim.log"
grep -q "PASS: Appendix C.1 inverse round transforms" "$build_dir/sim.log"
printf 'PASS: compilacao, lint e simulacao da Semana 3 concluidos com VCS.\n'
