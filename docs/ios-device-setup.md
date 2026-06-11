# 아이폰 실물기기 연결 & 실행 가이드 (무료 Apple 계정 기준)

새 맥/새 폰에서 약쏙 앱을 실물 아이폰에 올릴 때 이 순서대로 진행한다.

## 1. 기기 연결

- USB 케이블로 아이폰 ↔ 맥 연결 (무선보다 안정적)
- 아이폰: "이 컴퓨터를 신뢰하시겠습니까?" → **신뢰**
- 아이폰: 설정 → 개인정보 보호 및 보안 → **개발자 모드 켜기** → 재부팅
- 확인:
  ```bash
  flutter devices
  ```
  목록에 폰 이름이 뜨면 OK.

## 2. Xcode 서명 설정 (최초 1회)

```bash
open ios/Runner.xcworkspace
```

1. **Xcode → Settings → Accounts → ＋ → Apple ID 로그인** (Personal Team 자동 생성)
2. 좌측 맨 위 파란 **Runner** → TARGETS **Runner** → **Signing & Capabilities**
   - ☑ Automatically manage signing
   - **Team** → Personal Team 선택
3. **YakssokMedicineWidget** 타겟도 똑같이 Team 선택

## 3. 무료 계정 제약 처리 (핵심)

무료 Apple ID는 아래 기능을 못 쓰므로 **로컬에서만** 제거한다. (이 변경들은 커밋하지 않는다 — 팀 빌드가 깨짐)

- **Bundle ID**: `com.example.*` → 고유값으로 변경 (예: `com.dammmnn.yakssokFront`)
- **entitlements 비우기**: `ios/Runner/Runner.entitlements`, `ios/YakssokMedicineWidget/YakssokMedicineWidget.entitlements`
  에서 **HealthKit · App Group** 키 제거 → 빈 `<dict></dict>`
- Signing & Capabilities 화면에 해당 capability 카드가 있으면 **× 로 삭제**

> 유료 개발자 계정($99/년)으로 전환하면 위 제거 없이 그대로 동작한다.

## 4. 실행

```bash
flutter run --release -d <기기ID> \
  --dart-define=API_BASE_URL=http://<맥LAN_IP>:8000 \
  --dart-define=NAVER_SEARCH_CLIENT_ID=... \
  --dart-define=NAVER_SEARCH_CLIENT_SECRET=...
```

- 편하게: `bash scripts/run_with_api_keys.sh <기기ID>` (`.env.api_keys` + `Back-end/.env` 자동 주입)
- 맥 LAN IP 확인: `ipconfig getifaddr en0`
- 디버그/핫리로드가 무선에서 자꾸 멈추면 `--release` 로 실행 (디버거 미연결, 안정적)

## 5. 아이폰에서 개발자 신뢰 (최초 1회)

첫 실행 시 "신뢰할 수 없는 개발자" → 설정 → 일반 → **VPN 및 기기 관리** → Apple Development 계정 → **신뢰**

---

## 트러블슈팅

| 증상 | 원인 / 해결 |
|---|---|
| `No development certificates` | Xcode에 Apple ID 로그인 안 됨 → 2단계 |
| `com.example` 서명 거부 | Bundle ID를 고유값으로 변경 |
| HealthKit / App Group 서명 실패 | 무료 계정 불가 → entitlements 비우기 (3단계) |
| `Rosetta` 에러 | `sudo softwareupdate --install-rosetta --agree-to-license` |
| 키체인 암호 팝업 | **맥 로그인 비번** 입력 + **항상 허용** |
| `Installing` 멈춤 / 디버거 멈춤 | 무선 불안정 → USB 연결 + `--release` 실행 |
| 백엔드 로그인/통신 실패 | `127.0.0.1` 대신 **맥 LAN IP** 사용 (실물폰은 localhost가 폰 자신) |
| 네이버 지도 회색 화면 | NCP 콘솔에 현재 Bundle ID 등록 필요 |
