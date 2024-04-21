import requests
import dotenv
import os

dotenv.load_dotenv()
KEY = os.getenv("KEY")

product = 47433
base_url =f"https://apis.roblox.com/cloud/v2/creator-store-products/{product}"

headers = {
  "x-api-key": KEY,
}

response = requests.get(base_url, headers=headers)

print(base_url)
print(response.json())