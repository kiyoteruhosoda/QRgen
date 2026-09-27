#!/usr/bin/env python3
"""deck の機械の口へ「配れ」と伝える（nolumiadeck の ADR-0069）。

**main のリリースを起動する口はここだけ。** 版を上げたあとに呼ばれる
（ADR は各リポジトリの「リリースの起動を version_bump に一本化する」）。

⚠ **2026-09-10 に Komodo から deck へ付け替えた。** それまでは
``http://komodo-core:9120`` へ ``PullRepo`` を投げていたが、Komodo は k3s 移行で
停止しており、**マージのたびに `Could not resolve host` で赤くなっていた。**

やっていること:

1. idp から機械のトークンを取る（``private_key_jwt`` ／ ``resource=api://nolumiadeck``）
2. ``GET /api/machine/releases/<宛名>/plan`` で**起きるはずの段**を引く
3. ``POST /api/machine/releases/<宛名>`` に**その段をそのまま添えて**積む

⚠ **段を添えるのは必須である**（ADR-0069）。宣言が動いた・誰かが先に押した、
のどれでも 409 で弾かれる ——**押す前に何が起きるか分からないボタンを作らない**
という規律を、画面の無いところで果たすための手当て。

⚠ **待たない。** ここで見ているのは「積んだ」までで、焼き上がりは deck の
``/apps`` で確かめる。
"""

from __future__ import annotations

import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid

import jwt  # PyJWT（RS256 の client assertion を作るためだけに使う）

#: ⚠ Cloudflare は Python-urllib 系の UA を弾く（1010）。素直に名乗る
USER_AGENT = "nolumia-ci-release/1.0"

#: client assertion の寿命。idp の上限は 5 分
ASSERTION_TTL = 120


def die(message: str) -> None:
    print(f"trigger_release: {message}", file=sys.stderr)
    raise SystemExit(1)


def fetch(url: str, *, data: bytes | None = None, headers: dict[str, str] | None = None) -> dict:
    request = urllib.request.Request(url, data=data, headers={"User-Agent": USER_AGENT, **(headers or {})})
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            return json.loads(response.read().decode())
    except urllib.error.HTTPError as error:
        body = error.read().decode(errors="replace")[:400]
        die(f"{url} が HTTP {error.code} を返した\n  {body}")
    except urllib.error.URLError as error:
        die(f"{url} へ届かない: {error.reason}")
    raise AssertionError("unreachable")


def machine_token(client: dict, key: str) -> str:
    """``private_key_jwt`` で client_credentials のトークンを取る。

    ⚠ **``resource`` を省くと ``aud`` が ``/userinfo`` になり、deck では 401 になる。**
    ⚠ **``scope`` は送らない**（client_credentials に利用者由来の scope は載らない）。
    """
    discovery = fetch(f"{client['issuer']}/.well-known/openid-configuration")
    now = int(time.time())
    assertion = jwt.encode(
        {
            "iss": client["client_id"],
            "sub": client["client_id"],
            "aud": client["issuer"],
            "jti": str(uuid.uuid4()),
            "iat": now,
            "exp": now + ASSERTION_TTL,
        },
        key,
        algorithm="RS256",
        headers={"kid": client["kid"]},
    )
    body = urllib.parse.urlencode(
        {
            "grant_type": "client_credentials",
            "resource": client.get("resource", "api://nolumiadeck"),
            "client_assertion_type": "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
            "client_assertion": assertion,
        }
    ).encode()
    token = fetch(
        discovery["token_endpoint"],
        data=body,
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )
    return token["access_token"]


def main() -> None:
    client_file = os.environ.get("DECK_CLIENT_FILE", "")
    target = os.environ.get("DECK_TARGET", "")
    base = os.environ.get("DECK_URL", "http://nolumiadeck-prod")
    ref = os.environ.get("DECK_REF", "")
    if not client_file or not target:
        die("DECK_CLIENT_FILE と DECK_TARGET が要る")

    try:
        client = json.loads(open(client_file, encoding="utf-8").read())
        key = open(client["key_file"], encoding="utf-8").read()
    except OSError as error:
        die(f"資格情報が読めない（{error}）。セルフホストのランナー以外では起動できない")

    token = machine_token(client, key)
    auth = {"Authorization": f"Bearer {token}"}

    plan = fetch(f"{base}/api/machine/releases/{target}/plan", headers=auth)
    steps = plan["steps"]
    print(f"trigger_release: {target} の段は {' → '.join(steps)}")

    started = fetch(
        f"{base}/api/machine/releases/{target}",
        data=json.dumps({"expect_steps": steps, "ref": ref}).encode(),
        headers={**auth, "Content-Type": "application/json"},
    )
    print(f"trigger_release: 積んだ（{started['action']} / {started['namespace']}）")
    print("  ⚠ ここで見ているのは *積んだ* まで。焼き上がりは deck で確かめる:")
    print("     https://deck.nolumia.com/apps")

    summary = os.environ.get("GITHUB_STEP_SUMMARY", "")
    if summary:
        with open(summary, "a", encoding="utf-8") as handle:
            handle.write(f"deck へ `{target}` のリリースを積んだ（{' → '.join(steps)}）。\n\n")
            handle.write("_焼き上がりは [deck](https://deck.nolumia.com/apps) で確かめる。_\n")


if __name__ == "__main__":
    main()
