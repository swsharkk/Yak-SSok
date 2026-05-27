import os
import json
import uvicorn
from fastapi import FastAPI
from pydantic import BaseModel
from google import genai
from dotenv import load_dotenv

# 보안 처리: .env 파일에서 키를 몰래 불러옴
load_dotenv()
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")

# 구글 최신 공식 SDK 클라이언트 연결
client = genai.Client(api_key=GOOGLE_API_KEY)

app = FastAPI(title="약 봉투 파싱 AI 서버 (최신 SDK 버전)")

class OcrRequest(BaseModel):
    raw_text: str

@app.post("/api/parse-prescription")
def parse_prescription(request: OcrRequest):
    print("[데이터 수신] 텍스트가 도착했습니다. 최신 Gemini가 분석을 시작합니다.")
    
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
        # AI에게 작업 지시
        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt
        )
        
        result_text = response.text
        clean_json = result_text.replace("```json", "").replace("```", "").strip()
        parsed_data = json.loads(clean_json)
        
        print("[AI 분석 완료] JSON 데이터 반환")
        return {"status": "success", "data": parsed_data}

    except Exception as e:
        print(f"[에러 발생] {e}")
        return {"status": "error", "message": str(e)}