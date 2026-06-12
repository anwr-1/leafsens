import requests
import json

url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent"
headers = {
    "Content-Type": "application/json",
    "X-goog-api-key": "AQ.Ab8RN6JPrBya6gVrIRK9HOD-I4yLttzsvT3dgGW5p2y4MywF8Q"
}
data = {
    "contents": [
        {
            "parts": [
                {"text": "Explain how AI works in a few words"}
            ]
        }
    ]
}

response = requests.post(url, headers=headers, json=data)
print("STATUS:", response.status_code)
print("RESPONSE:", response.text)
