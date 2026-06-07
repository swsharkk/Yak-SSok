import os
from datetime import datetime, timedelta
import pandas as pd
from firebase_admin import firestore

db = firestore.client()

# OCR 분석 결과를 기반으로 시간대별 복약 일정 일괄 생성 (Bulk Create)
def setup_medication_schedule(elder_uid, medicine_name, total_days, daily_times):
    base_date = datetime.now()
    
    for day in range(total_days):
        target_date = (base_date + timedelta(days=day)).strftime("%Y-%m-%d")
        for time in daily_times:
            db.collection("schedules").add({
                "elder_uid": elder_uid,
                "medicine_name": medicine_name,
                "date": target_date,
                "time": time,
                "is_taken": False  # 초기 복용 상태는 미복용(False)으로 강제 고정 
            })
    return "스케줄 생성 완료"


# DUR 공공데이터 로드 — 검색 경로 우선순위
_BASE = os.path.dirname(__file__)
_DUR_SEARCH_PATHS = [
    os.path.join(_BASE, "data"),
    os.path.join(_BASE, "..", "local_backend", "data"),
    os.path.join(_BASE, "..", "Back-end", "data"),
    "/Users/parkhyeondam/yakssok_front/local_backend/data",
]

dur_df = None

try:
    csv_dir = next((p for p in _DUR_SEARCH_PATHS if os.path.isdir(p)), None)
    if csv_dir:
        data_files = [
            f for f in os.listdir(csv_dir)
            if f.endswith('.csv') or f.endswith('.xlsx') or f.endswith('.xls')
        ]
        df_list = []
        for file in data_files:
            if file.startswith('.'):
                continue
            path = os.path.join(csv_dir, file)
            if file.endswith('.csv'):
                for enc in ("utf-8-sig", "cp949", "euc-kr"):
                    try:
                        df_list.append(pd.read_csv(path, encoding=enc, low_memory=False))
                        break
                    except UnicodeDecodeError:
                        continue
            else:
                df_list.append(pd.read_excel(path))

        if df_list:
            dur_df = pd.concat(df_list, ignore_index=True)
            print(f"✅ [성공] DUR 병용금기 데이터 로드 완료! 총 {len(dur_df)}건")
        else:
            print("⚠️ [경고] data 폴더에 CSV/Excel 파일이 없습니다.")
    else:
        print("❌ [에러] DUR 데이터 폴더를 찾을 수 없습니다.")
except Exception as e:
    print(f"⚠️ [크래시] DUR 데이터 로드 실패: {e}")
    dur_df = None


# 데이터베이스 연동형 고속 병용금기 전수 검증 알고리즘 (Async 지원 전환)
async def check_drug_interaction(elder_uid: str, new_med_name: str) -> dict:
    """
    하이브리드 비동기 통신 규격으로 교정하여 main.py와 완벽하게 싱크를 맞춥니다.
    """
    if dur_df is None:
        return {"interact": False, "message": "DUR 시스템 점검 중입니다."}

    try:
        # 1. Firestore에서 해당 사용자의 복용 중인 약 리스트 쿼리
        schedules_ref = db.collection("schedules")
        docs = schedules_ref.where("uid", "==", elder_uid).stream()

        current_med_list = set()
        for doc in docs:
            data = doc.to_dict()
            if data.get("status") != "taken":
                med_name = data.get("medicine_name")
                if med_name:
                    current_med_list.add(med_name.strip())

        if not current_med_list:
            return {"interact": False, "message": "현재 복용 중인 약물이 없으므로 안전하게 등록 가능합니다."}

        # 2. Pandas Vectorization 연산을 통한 고속 양방향 성분 충돌 감지 매핑 
        for existing_med in current_med_list:
            match = dur_df[
                ((dur_df['제품명A'].str.contains(new_med_name, na=False, regex=False)) & (dur_df['제품명B'].str.contains(existing_med, na=False, regex=False))) |
                ((dur_df['제품명B'].str.contains(new_med_name, na=False, regex=False)) & (dur_df['제품명A'].str.contains(existing_med, na=False, regex=False)))
            ]

            if not match.empty:
                reason = match.iloc[0]['상세정보'] if '상세정보' in dur_df.columns else "병용 금기 의약품 위험군"
                return {
                    "interact": True,
                    "message": f"⚠️ 병용 오남용 위험 경고: 현재 복용 중이신 [{existing_med}]과 새로 등록하려는 [{new_med_name}]은 함께 복용 시 부작용 위험이 있습니다. (사유: {reason})"
                }

        return {"interact": False, "message": "안전한 의약품 조합입니다."}

    except Exception as e:
        return {"interact": False, "message": f"데이터 처리 중 일시적인 제약이 발생했습니다: {str(e)}"}
