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

# Isola tambem os intermediarios do VCS, sem alterar csrc/ do repositorio.
(
    cd "$build_dir"
    vcs -full64 -sverilog -timescale=1ns/1ps -lca \
        +lint=all -top tb_week4 \
        -l "$build_dir/compile.log" \
        -o "$build_dir/simv" \
        "$repo_root/rtl/minisoc_aes/"*.sv \
        "$repo_root/tb/tb_week4.sv"
    "$build_dir/simv" -no_save -l "$build_dir/sim.log"
)

if ! grep -q '^PASS: all Week 4 tests$' "$build_dir/sim.log"; then
    printf 'FAIL: simulacao nao confirmou todos os testes da Semana 4.\n' >&2
    exit 1
fi

printf 'PASS: compilacao, lint e simulacao da Semana 4 concluidos com VCS.\n'
