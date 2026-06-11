"""saved_medicines 컬렉션의 중복을 정리한다.

같은 (uid, 약이름) 끼리 묶어 가장 최근 것 하나만 남기고,
문서 ID를 신규 저장과 동일한 안정적 ID(sm_<hash>)로 통합한다.
이렇게 해두면 이후 같은 약을 다시 저장해도 업서트되어 중복이 안 생긴다.

사용법 (Back-end 디렉터리에서):
    python scripts/dedup_saved_medicines.py            # 미리보기(dry-run)
    python scripts/dedup_saved_medicines.py --apply     # 실제 적용
"""

import os
import sys
import hashlib
from collections import defaultdict

import requests

# authorization 모듈 import (Back-end 루트를 경로에 추가)
BACKEND_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, BACKEND_DIR)

# authorization 은 import 시점에 firestore.client() 를 호출하므로 먼저 앱 초기화
import firebase_admin  # noqa: E402
from firebase_admin import credentials  # noqa: E402

if not firebase_admin._apps:
    _cred_path = os.path.join(
        BACKEND_DIR, "yakssok-backend-firebase-adminsdk-fbsvc-15c58432ef.json"
    )
    firebase_admin.initialize_app(credentials.Certificate(_cred_path))

import authorization  # noqa: E402


def stable_id(uid: str, name: str) -> str:
    key = f"{uid}:{name.strip()}"
    return "sm_" + hashlib.sha1(key.encode("utf-8")).hexdigest()


def list_all(collection: str) -> list[dict]:
    """컬렉션 전체 문서를 페이지네이션으로 모두 가져온다."""
    rows: list[dict] = []
    page_token = None
    while True:
        params = {"pageSize": 300}
        if page_token:
            params["pageToken"] = page_token
        resp = requests.get(
            f"{authorization.FIRESTORE_BASE_URL}/{collection}",
            headers=authorization._rest_headers(),
            params=params,
            timeout=15,
        )
        resp.raise_for_status()
        body = resp.json()
        for doc in body.get("documents", []):
            data = authorization._from_firestore_fields(doc.get("fields", {}))
            data["id"] = doc["name"].split("/")[-1]
            rows.append(data)
        page_token = body.get("nextPageToken")
        if not page_token:
            break
    return rows


def main() -> None:
    apply = "--apply" in sys.argv
    mode = "APPLY(실제 삭제)" if apply else "DRY-RUN(미리보기)"
    print(f"=== saved_medicines 중복 정리 [{mode}] ===\n")

    rows = list_all("saved_medicines")
    print(f"전체 문서: {len(rows)}개\n")

    # (uid, 약이름) 기준 그룹핑
    groups: dict[tuple, list[dict]] = defaultdict(list)
    for r in rows:
        uid = r.get("uid") or ""
        name = (r.get("medicine_name") or "").strip()
        if not uid or not name:
            continue
        groups[(uid, name)].append(r)

    dup_groups = 0
    to_delete: list[str] = []
    to_upsert: list[tuple] = []  # (canonical_id, data)

    for (uid, name), docs in groups.items():
        canonical = stable_id(uid, name)
        # 최신 것 선택 (created_at ISO 문자열 내림차순)
        docs_sorted = sorted(docs, key=lambda d: d.get("created_at") or "", reverse=True)
        keep = docs_sorted[0]

        if len(docs) > 1:
            dup_groups += 1
            print(f"[{name}] {len(docs)}개 → 1개 (uid={uid[:8]}…)")

        # 최신 데이터를 안정적 ID로 통합 (id가 이미 canonical이면 그대로)
        data = {k: v for k, v in keep.items() if k != "id"}
        if keep["id"] != canonical:
            to_upsert.append((canonical, data))
        # canonical 이 아닌 문서는 전부 삭제 대상
        for d in docs:
            if d["id"] != canonical:
                to_delete.append(d["id"])

    print(f"\n중복 그룹: {dup_groups}개")
    print(f"통합(업서트)할 문서: {len(to_upsert)}개")
    print(f"삭제할 문서: {len(to_delete)}개")

    if not apply:
        print("\n(미리보기입니다. 실제로 적용하려면 --apply 를 붙여 다시 실행하세요.)")
        return

    print("\n적용 중...")
    for canonical, data in to_upsert:
        authorization.firestore_patch("saved_medicines", canonical, data)
    for doc_id in to_delete:
        authorization.firestore_delete("saved_medicines", doc_id)
    print(f"완료: 업서트 {len(to_upsert)}, 삭제 {len(to_delete)}")


if __name__ == "__main__":
    main()
