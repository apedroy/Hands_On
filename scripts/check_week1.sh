#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
snps_env="/Tools/synopsys-scripts/snps.sh"

# Carrega o ambiente Synopsys se o VCS ainda nao estiver no PATH.
if ! command -v vcs >/dev/null 2>&1; then
    if [ -f "$snps_env" ]; then
        # shellcheck disable=SC1090
        source "$snps_env"
    fi
fi

for tool in vcs; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        printf 'Erro: ferramenta obrigatoria nao encontrada: %s\n' "$tool" >&2
        printf 'Carregue o ambiente Synopsys com: source %s\n' "$snps_env" >&2
        exit 127
    fi
done

build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT

# Compilacao + elaboracao com lint habilitado.
vcs -full64 -sverilog -timescale=1ns/1ps -lca \
    +lint=all \
    -l "$build_dir/compile.log" \
    -o "$build_dir/simv" \
    "$repo_root/rtl/week1_smoke.v" \
    "$repo_root/tb/tb_week1.sv"

# Simulacao.
"$build_dir/simv" -no_save -l "$build_dir/sim.log"

if ! grep -q "PASS: all 4 smoke-test vectors" "$build_dir/sim.log"; then
    printf 'FAIL: simulacao nao confirmou os vetores do smoke-test.\n' >&2
    exit 1
fi

printf 'PASS: compilacao, lint e simulacao concluidos com VCS.\n'