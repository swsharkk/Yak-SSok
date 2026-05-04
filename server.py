import os
import json
import requests
import uvicorn
from fastapi import FastAPI
from pydantic import BaseModel
from google import genai
from dotenv import load_dotenv

# 환경 변수 로드
load_dotenv()
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
PUBLIC_DATA_API_KEY = os.getenv("DATA_GO_KR_API_KEY")

# 구글 제미나이 클라이언트 초기화
client = genai.Client(api_key=GOOGLE_API_KEY)
app = FastAPI(title="노년층 맞춤형 지능형 의약품 관리 AI 서버")

class OcrRequest(BaseModel):
    raw_text: str

@app.post("/api/parse-prescription")
def parse_prescription(request: OcrRequest):
    prompt = f"""
    너는 정확한 의료 데이터 분석 AI야.
    아래에 사용자가 추출한 약국 영수증 텍스트를 줄게. 오타를 문맥에 맞게 교정해서
    반드시 아래 JSON 배열 형태로만 대답해. 마크다운 기호(```json)나 다른 설명은 절대 넣지마.

    [출력 JSON 양식]
    [
      {{
        "drug_name": "약이름(실제 식약처 등록 명칭)",
        "daily_frequency": 1일복용횟수(숫자),
        "duration_days": 총투약일수(숫자)
      }}
    ]

    [사용자 영수증 텍스트]
    {request.raw_text}
    """
    try:
        response = client.models.generate_content(model='gemini-2.5-flash', contents=prompt)
        clean_json = response.text.replace("```json", "").replace("```", "").strip()
        parsed_data = json.loads(clean_json)
        return {"status": "success", "data": parsed_data}
    except Exception as e:
        return {"status": "error", "message": str(e)}

class ChatRequest(BaseModel):
    question: str
    context_drugs: list[str] = []

def fetch_drug_info_from_api(drug_name: str) -> str:
    if not PUBLIC_DATA_API_KEY: return "API 키 오류"
    
    # 식약처 API 주소 (마크다운 오류 수정됨)
    url = "[http://apis.data.go.kr/1471000/DrbEasyDrugInfoService/getDrbEasyDrugList](http://apis.data.go.kr/1471000/DrbEasyDrugInfoService/getDrbEasyDrugList)"
    params = {"serviceKey": PUBLIC_DATA_API_KEY, "itemName": drug_name, "type": "json", "numOfRows": 1, "pageNo": 1}
    
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
        response = client.models.generate_content(model='gemini-2.5-flash', contents=system_prompt)
        return {"status": "success", "answer": response.text}
    except Exception as e:
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    uvicorn.run("server:app", host="0.0.0.0", port=8000, reload=True)