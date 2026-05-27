import requests
import json

# 대괄호, 소괄호가 없는 순수한 인터넷 주소
BASE_URL = "http://127.0.0.1:8000"

print("\n====================================")
print("RAG 기반 복약 챗봇 테스트")
print("====================================")

# 서버로 보낼 질문과 복용 중인 약 데이터
chat_payload = {
    "question": "내가 이 약을 먹고 있는데, 속이 좀 쓰린 것 같아. 어떻게 하지?",
    "context_drugs": ["아목시실린캡슐"]
}

# 서버로 POST 요청 전송
response_2 = requests.post(f"{BASE_URL}/api/chat", json=chat_payload)
result_chat = response_2.json()

# 성공적으로 응답을 받았다면 답변 출력
if result_chat.get("status") == "success":
    print("\n[AI 약사 답변]")
    print(result_chat["answer"])
else:
    print(result_chat)