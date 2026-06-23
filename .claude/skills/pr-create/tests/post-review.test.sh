#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="$HERE/../scripts/post-review.sh"
pass=0; fail=0
check() { if [ "$2" = "$3" ]; then echo "ok   - $1"; pass=$((pass+1)); else echo "FAIL - $1 (want $2 got $3)"; fail=$((fail+1)); fi; }
command -v jq >/dev/null 2>&1 || { echo "SKIP - jq not installed"; exit 0; }

WORK="$(mktemp -d)"; BIN="$WORK/bin"; BODYLOG="$WORK/body.json"; mkdir -p "$BIN"
# fake gh api: capture the --input file (the request body) for assertions.
cat > "$BIN/gh" <<EOF
#!/usr/bin/env bash
prev=""
for a in "\$@"; do
  if [ "\$prev" = "--input" ]; then cp "\$a" "$BODYLOG"; fi
  prev="\$a"
done
echo '{"id":1}'
EOF
chmod +x "$BIN/gh"

cat > "$WORK/findings.json" <<'JSON'
{"summary":"Looks ok overall.","findings":[
  {"path":"apps/web/app/page.tsx","line":10,"severity":"warn","body":"async params"},
  {"path":"apps/native/src/bridge.ts","line":5,"severity":"info","body":"naming"}
]}
JSON

PATH="$BIN:$PATH" bash "$SCRIPT" 42 "$WORK/findings.json" >/dev/null 2>&1
check "exit 0" 0 $?
jq -e '.event=="COMMENT"' "$BODYLOG" >/dev/null   || { echo "FAIL - event COMMENT"; fail=$((fail+1)); }
jq -e '.body | test("Looks ok")' "$BODYLOG" >/dev/null || { echo "FAIL - summary body"; fail=$((fail+1)); }
jq -e '.comments | length == 2' "$BODYLOG" >/dev/null || { echo "FAIL - 2 inline comments"; fail=$((fail+1)); }
jq -e '.comments[0].path=="apps/web/app/page.tsx" and .comments[0].line==10' "$BODYLOG" >/dev/null \
  || { echo "FAIL - inline path/line mapped"; fail=$((fail+1)); }

# usage error
PATH="$BIN:$PATH" bash "$SCRIPT" >/dev/null 2>&1; check "no args -> 2" 2 $?

echo "---- $pass passed, $fail failed"
[ "$fail" -eq 0 ]
