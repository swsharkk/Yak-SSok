from google import genai

GOOGLE_API_KEY = "AIzaSyAFf58zmT2ZES47zQGS7q4pqeLUqQcV7H0"

client = genai.Client(api_key=GOOGLE_API_KEY)

print("Searching available models...\n")

try:
    for model in client.models.list():
        if 'gemini' in model.name.lower():
            print("Available model:", model.name)
            
    print("\nSearch complete!")
except Exception as e:
    print("Error:", e)