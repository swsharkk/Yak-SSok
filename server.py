import os
import json
import requests
import uvicorn
from fastapi import FastAPI, Body
from pydantic import BaseModel, Field
from google import genai
from google.genai import types
from dotenv import load_dotenv

# 환경 변수 로드
load_dotenv()
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
PUBLIC_DATA_API_KEY = os.getenv("DATA_GO_KR_API_KEY")

# 구글 최신 공식 SDK 클라이언트 연결
client = genai.Client(api_key=GOOGLE_API_KEY)

app = FastAPI(title="노년층 맞춤형 지능형 의약품 관리 AI 서버 (최종 통합본)")

# ----------------------------------------------------
# 1. OCR 파싱용 AI 출력 양식 (앱으로 보낼 JSON 규칙)
# ----------------------------------------------------
class DrugInfo(BaseModel):
    drug_name: str = Field(description="약이름(실제 식약처 등록 명칭)")
    daily_frequency: int = Field(description="1일복용횟수(숫자)")
    duration_days: int = Field(description="총투약일수(숫자)")

class PrescriptionResult(BaseModel):
    drugs: list[DrugInfo]

# ----------------------------------------------------
# API 1: 약 봉투 파싱 (앱에서 ML Kit '순수 텍스트'를 그대로 던져주면 됨)
# ----------------------------------------------------
@app.post("/api/parse-prescription")
def parse_prescription(raw_text: str = Body(..., media_type="text/plain")):
    print("[데이터 수신] 텍스트가 도착했습니다. 최신 Gemini 2.5가 분석을 시작합니다.")
    
    prompt = f"""
    너는 정확한 의료 데이터 분석 AI야. 
    아래에 사용자가 추출한 약국 영수증 텍스트를 줄게. 오타를 문맥에 맞게 교정해서 약 정보를 추출해줘.
    
    [사용자 영수증 텍스트]
    {raw_text}
    """

    try:
        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                response_schema=PrescriptionResult,
                temperature=0.1, 
            )
        )
        
        parsed_data = json.loads(response.text)
        print("[AI 분석 완료] JSON 데이터 반환 성공")
        return {"status": "success", "data": parsed_data["drugs"]}

    except Exception as e:
        error_msg = str(e)
        print(f"[에러 발생] {error_msg}")
        if "429" in error_msg or "RESOURCE_EXHAUSTED" in error_msg:
            return {"status": "error", "message": "현재 AI 요청이 너무 많습니다. 약 1분 후 다시 시도해 주세요."}
        return {"status": "error", "message": error_msg}

# ----------------------------------------------------
# API 2: 약 정보 조회 및 AI 약사 채팅
# ----------------------------------------------------
class ChatRequest(BaseModel):
    question: str
    context_drugs: list[str] = []

def fetch_drug_info_from_api(drug_name: str) -> str:
    if not PUBLIC_DATA_API_KEY: 
        return "API 키 오류"
    
    # 식약처 API 주소
    url = "http://apis.data.go.kr/1471000/DrbEasyDrugInfoService/getDrbEasyDrugList"
    params = {
        "serviceKey": PUBLIC_DATA_API_KEY, 
        "itemName": drug_name, 
        "type": "json", 
        "numOfRows": 1, 
        "pageNo": 1
    }
    
    try:
        res = requests.get(url, params=params)
        res.raise_for_status()
        items = res.json().get("body", {}).get("items")
        if items:
            drug_data = items[0]
            return f"[효능]\n{drug_data.get('efcyQesitm', '')}\n[용법]\n{drug_data.get('useMethodQesitm', '')}\n[주의사항]\n{drug_data.get('atpnQesitm', '')}"
        return "정보 없음"
    except Exception as e:
        return f"통신 오류: {str(e)}"

@app.post("/api/chat")
def rag_chat(request: ChatRequest):
    retrieved_info = ""
    for drug in request.context_drugs:
        retrieved_info += f"--- 약품명: {drug} ---\n{fetch_drug_info_from_api(drug)}\n\n"

    system_prompt = f"""
    너는 어르신들의 건강을 챙겨주는 친절하고 다정한 전문 약사 AI야.
    [검색된 의약품 정보]
    {retrieved_info if request.context_drugs else "약 정보 없음"}
    [질문]
    {request.question}
    """
    try:
        response = client.models.generate_content(
            model='gemini-2.5-flash', 
            contents=system_prompt
        )
        return {"status": "success", "answer": response.text}
        
    # 챗봇 에러 방어 코드 (429 및 503 처리 완벽 적용)
    except Exception as e:
        error_msg = str(e)
        print(f"[챗봇 에러 발생] {error_msg}")
        if "429" in error_msg or "RESOURCE_EXHAUSTED" in error_msg:
            return {"status": "error", "message": "현재 챗봇 상담이 너무 많아 대기 중입니다. 1분 후 다시 질문해 주세요."}
        elif "503" in error_msg or "UNAVAILABLE" in error_msg:
            return {"status": "error", "message": "현재 구글 AI 서버에 접속자가 몰려 답변이 지연되고 있습니다. 잠시 후 다시 시도해 주세요."}
        return {"status": "error", "message": error_msg}

if __name__ == "__main__":
    uvicorn.run("server:app", host="0.0.0.0", port=8000, reload=True)