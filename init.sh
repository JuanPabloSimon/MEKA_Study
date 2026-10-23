#!/usr/bin/env bash
# init.sh — verificación ejecutable del repositorio MEKA.
# Uso: ./init.sh        (desde la raíz del repo)
# Código de salida: 0 = verde, 1 = hay fallas.
set -uo pipefail
cd "$(dirname "$0")"

FAIL=0
WARN=0
ok()   { echo "  ✓ $1"; }
warn() { echo "  ⚠ $1"; WARN=$((WARN + 1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

echo "== MEKA · init.sh =="

# ---------------------------------------------------------------- 1. Entorno
echo "[1/4] Entorno"
if command -v node >/dev/null 2>&1; then
  NODE_MAJOR=$(node -p "process.versions.node.split('.')[0]")
  if [ "$NODE_MAJOR" -ge 20 ]; then ok "Node $(node -v)"; else fail "Se requiere Node 20 o superior (actual: $(node -v))"; fi
else
  fail "Node no está instalado"
fi
if command -v npm >/dev/null 2>&1; then ok "npm $(npm -v)"; else fail "npm no está instalado"; fi

# ------------------------------------------------------------ 2. Archivos base
echo "[2/4] Archivos base"
for f in AGENTS.md CHECKPOINTS.md feature_list.json init.sh \
         .antigravity/rules.md \
         .antigravity/agents/leader.md .antigravity/agents/spec_author.md \
         .antigravity/agents/implementer.md .antigravity/agents/reviewer.md \
         docs/architecture.md docs/conventions.md docs/specs.md docs/verification.md docs/design.md \
         progress/current.md progress/history.md; do
  if [ -s "$f" ]; then ok "$f"; else fail "Falta o está vacío: $f"; fi
done

# ------------------------------------- 3. Estado, specs, aprobaciones, trazabilidad
echo "[3/4] Estado, specs y trazabilidad"
if command -v node >/dev/null 2>&1; then
NODE_SCRIPT=$(cat <<'JS'
import fs from "node:fs";
import path from "node:path";

const out = (tag, msg) => console.log(`${tag}:${msg}`);
const exists = (p) => fs.existsSync(p);
const nonEmpty = (p) => exists(p) && fs.statSync(p).size > 0;
const rtokens = (s) => [...s.matchAll(/\bR(\d+)\b/g)].map((m) => `R${m[1]}`);

let data;
try {
  data = JSON.parse(fs.readFileSync("feature_list.json", "utf8"));
} catch (e) {
  out("FAIL", `feature_list.json no es JSON válido: ${e.message}`);
  process.exit(0);
}
const feats = Array.isArray(data.features) ? data.features : null;
if (!feats) { out("FAIL", "feature_list.json: falta el arreglo 'features'"); process.exit(0); }

const STATES = new Set(["pending", "spec_ready", "in_progress", "done", "blocked"]);
const byName = new Map();
const seenIds = new Set();
let structural = 0;
for (const f of feats) {
  for (const k of ["id", "name", "title", "scope", "status"]) {
    if (!f[k]) { out("FAIL", `Feature ${f.id ?? "?"}: falta el campo '${k}'`); structural++; }
  }
  if (seenIds.has(f.id)) { out("FAIL", `Id duplicado: ${f.id}`); structural++; }
  if (byName.has(f.name)) { out("FAIL", `Nombre duplicado: ${f.name}`); structural++; }
  seenIds.add(f.id);
  byName.set(f.name, f);
  if (!STATES.has(f.status)) { out("FAIL", `${f.id}: estado inválido '${f.status}'`); structural++; }
}
for (const f of feats) {
  for (const d of f.depends_on ?? []) {
    if (!byName.has(d)) { out("FAIL", `${f.id}: depende de '${d}', que no existe`); structural++; }
  }
}

// Una sola in_progress por scope
const inProgress = feats.filter((f) => f.status === "in_progress");
const perScope = {};
for (const f of inProgress) (perScope[f.scope] ??= []).push(f.id);
for (const [scope, ids] of Object.entries(perScope)) {
  if (ids.length > 1) { out("FAIL", `Más de una feature in_progress en el scope '${scope}': ${ids.join(", ")}`); structural++; }
}

// Archivos de tests del repo
const testFiles = [];
const walk = (dir) => {
  if (!exists(dir)) return;
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    if (e.name === "node_modules" || e.name.startsWith(".")) continue;
    const p = path.join(dir, e.name);
    if (e.isDirectory()) walk(p);
    else if (/\.(test|spec)\.(ts|tsx)$/.test(e.name)) testFiles.push(p);
  }
};
walk("src");
walk("e2e");
const testText = testFiles.map((p) => ({ p, s: fs.readFileSync(p, "utf8") }));

// Prohibido it.only / it.skip / test.only / describe.skip ...
for (const { p, s } of testText) {
  if (/\b(it|test|describe)\.(only|skip)\s*\(/.test(s)) {
    out("FAIL", `${p}: contiene .only/.skip`);
    structural++;
  }
}

// Reglas por feature según estado
let traceIssues = 0;
for (const f of feats) {
  const dir = path.join("specs", f.scope, f.name);
  const req = path.join(dir, "requirements.md");
  const des = path.join(dir, "design.md");
  const tsk = path.join(dir, "tasks.md");

  if (f.status === "blocked" && !f.blocked_reason) {
    out("FAIL", `${f.id}: está blocked sin 'blocked_reason'`); traceIssues++;
  }

  if (["spec_ready", "in_progress", "done"].includes(f.status) && f.sdd !== false) {
    for (const p of [req, des, tsk]) {
      if (!nonEmpty(p)) { out("FAIL", `${f.id} (${f.status}): falta o está vacío ${p}`); traceIssues++; }
    }
  }

  if (["in_progress", "done"].includes(f.status)) {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(f.approved_at ?? "")) {
      out("FAIL", `${f.id} (${f.status}): falta 'approved_at' (aprobación humana de la spec)`); traceIssues++;
    }
    for (const d of f.depends_on ?? []) {
      if (byName.get(d) && byName.get(d).status !== "done") {
        out("FAIL", `${f.id} (${f.status}): su dependencia '${d}' no está done`); traceIssues++;
      }
    }
  }

  // Cobertura requisito -> tarea (specs ya entregadas)
  if (["spec_ready", "in_progress", "done"].includes(f.status) && nonEmpty(req) && nonEmpty(tsk)) {
    const reqIds = [...new Set([...fs.readFileSync(req, "utf8").matchAll(/^\s*(?:[-*]\s*)?\*{0,2}R(\d+)\*{0,2}[.:)]/gm)].map((m) => `R${m[1]}`))];
    const taskText = fs.readFileSync(tsk, "utf8");
    const covered = new Set([...taskText.matchAll(/cubre:\s*([^\n*]*)/gi)].flatMap((m) => rtokens(m[1])));
    const uncovered = reqIds.filter((r) => !covered.has(r));
    if (reqIds.length === 0) { out("FAIL", `${f.id}: requirements.md no tiene requisitos con formato R<n>`); traceIssues++; }
    if (uncovered.length) { out("FAIL", `${f.id}: requisitos sin tarea (cubre:) → ${uncovered.join(", ")}`); traceIssues++; }

    // Cobertura requisito -> test
    if (["in_progress", "done"].includes(f.status)) {
      const esc = f.name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
      const re = new RegExp(`\\[${esc}\\s+([^\\]]*)\\]`, "g");
      const tested = new Set();
      for (const { s } of testText) for (const m of s.matchAll(re)) rtokens(m[1]).forEach((r) => tested.add(r));
      const untested = reqIds.filter((r) => !tested.has(r));
      if (untested.length) {
        if (f.status === "done") { out("FAIL", `${f.id} (done): requisitos sin test [${f.name} R<n>] → ${untested.join(", ")}`); traceIssues++; }
        else out("WARN", `${f.id} (in_progress): requisitos aún sin test → ${untested.join(", ")}`);
      }
    }
  }
}

const scaffold = byName.get("project_scaffold");
if (scaffold && scaffold.status === "done" && !exists("package.json")) {
  out("FAIL", "project_scaffold está done pero no existe package.json"); traceIssues++;
}

const count = {};
for (const f of feats) count[f.status] = (count[f.status] ?? 0) + 1;
const resumen = Object.entries(count).map(([k, v]) => `${k}: ${v}`).join(", ");
if (structural + traceIssues === 0) out("OK", `feature_list.json consistente (${feats.length} features — ${resumen})`);
out("INFO", `Archivos de test detectados: ${testFiles.length}`);
JS
)
  while IFS= read -r line; do
    case "$line" in
      OK:*)   ok "${line#OK:}" ;;
      WARN:*) warn "${line#WARN:}" ;;
      FAIL:*) fail "${line#FAIL:}" ;;
      INFO:*) echo "    ${line#INFO:}" ;;
    esac
  done < <(node --input-type=module -e "$NODE_SCRIPT" 2>&1)
else
  warn "Se omiten los chequeos de estado (Node no disponible)"
fi

# ------------------------------------------------------------ 4. Verificación
echo "[4/4] Verificación (lint, tipos, tests, build)"
if [ ! -f package.json ]; then
  warn "Sin package.json todavía (F01 project_scaffold pendiente): se omite npm run verify"
elif ! node -e "process.exit(require('./package.json').scripts?.verify ? 0 : 1)" 2>/dev/null; then
  fail "package.json no define el script 'verify' (lint + typecheck + test + build)"
elif [ ! -d node_modules ]; then
  fail "Faltan dependencias: ejecuta 'npm install'"
else
  if npm run verify --silent; then ok "npm run verify en verde"; else fail "npm run verify falló"; fi
fi

# ------------------------------------------------------------------ Resumen
echo "------------------------------------------"
if [ "$FAIL" -gt 0 ]; then
  echo "RESULTADO: ROJO — $FAIL falla(s), $WARN advertencia(s)"
  exit 1
fi
echo "RESULTADO: VERDE — 0 fallas, $WARN advertencia(s)"
exit 0
