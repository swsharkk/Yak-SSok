import os
from google import genai
from dotenv import load_dotenv

# 보안 처리: .env 파일에서 키를 몰래 불러옴
load_dotenv()
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")

client = genai.Client(api_key=GOOGLE_API_KEY)

print("Searching available models...\n")

try:
    for model in client.models.list():
        if 'gemini' in model.name.lower():
            print("Available model:", model.name)
            
    print("\nSearch complete!")
except Exception as e:
    print("Error:", e)