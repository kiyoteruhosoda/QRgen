#!/bin/bash
# deck の機械の口へリリースを積む（nolumiadeck の ADR-0069）。中身は
# `scripts/trigger_release.py`。ここはそれを**コンテナの中で走らせる**ための薄い皮。
#
# ⚠ **ランナーの中には python3 も jq も無い**（`myoung34/github-runner` は 3.8 で、
#   `PyJWT` も入らない）。ツールチェインはホストへ入れず、イメージに閉じ込める
#   ——`EPHEMERAL=1` なので入れても次のジョブには残らない。
#
# ⚠ **`--network edge` で deck の別名を直に引く。** 公開名（deck.nolumia.com）だと
#   Cloudflare を往復し、Access の関門も通ることになる。
#
# 前提:
#   - nolumialab のセルフホストランナーで走る
#   - /srv/secrets/ci/<app>/ が読める
#     （`deploy-repo` の `host/services/runner/compose.yaml` が読み取り専用で bind mount する）
#   - その client_id が deck の `RELEASE_MACHINE_CLIENTS` に載っている
#
# 資格情報は idp のクライアント `ci-<app>`（`private_key_jwt`）。
# ⚠ **deck 側に「相手ごとの絞り」は無い**（`machine_dependencies.py`：境界は許可簿だけ）。
#   名乗りを分けて得られるのは**監査の粒度と失効の粒度**であって、封じ込めではない。
#
# ⚠ 失敗したら黙らずにジョブを落とす。ここが静かに転ぶと「マージしたのに
#   いつまでも配られない」になり、気付くのが遅れる。

set -euo pipefail

APP="${DECK_APP:?DECK_APP が要る}"
SECRETS="${DECK_SECRETS_DIR:-/srv/secrets/ci/$APP}"
IMAGE="${DECK_PYTHON_IMAGE:-python:3.12.14-slim}"

if [ ! -r "$SECRETS/client.json" ]; then
  echo "trigger_release: $SECRETS/client.json が読めない。" >&2
  echo "  セルフホストランナー以外では起動できない。" >&2
  exit 1
fi

# ⚠ **作業ツリーの渡し方は 2 通りある。**
#   - **ジョブがコンテナの中で走るとき**（forge / act_runner）: 作業ツリーは
#     docker のボリュームで、**ホストから見て `$GITHUB_WORKSPACE` は存在しない**。
#     `-v` で渡すと**マウントが空のまま**動く。`--volumes-from` で自分の
#     ボリュームをそのまま兄弟へ渡す。
#   - **ホストの上で直に走るとき**（手で叩く場合）: 今までどおり `-v`。
#   ⚠ 判定は `/.dockerenv` の有無で行う。
if [ -f /.dockerenv ]; then
  WORKSPACE_MOUNT=(--volumes-from "$(hostname)")
  # ⚠ `--volumes-from` は元のボリュームの読み書きをそのまま持ってくるので、
  #   以前の `:ro` は掛からない。渡す先は自分たちのスクリプトだけである。
else
  WORKSPACE_MOUNT=(-v "${GITHUB_WORKSPACE}:${GITHUB_WORKSPACE}:ro")
fi

# ⚠ **step summary はコンテナを跨げない。** forge では `$GITHUB_STEP_SUMMARY` は
#   ジョブのコンテナの中のパスで、ホストのデーモンからは見えない（`/tmp` は
#   ボリュームではない）。いったん作業ツリーへ書かせて、あとで継ぎ足す。
SUMMARY_IN_WS="${GITHUB_WORKSPACE}/.ci-release-summary.md"
rm -f "$SUMMARY_IN_WS"

docker run --rm --network edge \
  -v "$SECRETS:$SECRETS:ro" \
  "${WORKSPACE_MOUNT[@]}" \
  -w "${GITHUB_WORKSPACE}" \
  -e DECK_CLIENT_FILE="$SECRETS/client.json" \
  -e DECK_TARGET="app/$APP" \
  -e DECK_REF="${DECK_REF:-}" \
  -e GITHUB_STEP_SUMMARY="$SUMMARY_IN_WS" \
  "$IMAGE" \
  sh -eu -c "
    pip install --quiet --disable-pip-version-check --root-user-action=ignore 'pyjwt[crypto]==2.13.0'
    python3 scripts/trigger_release.py
  "

# ⚠ 失敗しても黙って落とさない（`set -e` は上の docker run で効いている）。
if [ -n "${GITHUB_STEP_SUMMARY:-}" ] && [ -f "$SUMMARY_IN_WS" ]; then
  cat "$SUMMARY_IN_WS" >> "$GITHUB_STEP_SUMMARY" || true
fi
rm -f "$SUMMARY_IN_WS"
