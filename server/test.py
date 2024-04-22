import requests
import dotenv
import os

dotenv.load_dotenv()
COOKIE = os.getenv("COOKIE")

product = 47433

auth_url = "https://auth.roblox.com/v2/logout"

def get_xcsrf():
    xsrfRequest = requests.post(auth_url, cookies={
      ".ROBLOSECURITY": COOKIE
    })

    return xsrfRequest.headers["x-csrf-token"]

xcsrf = get_xcsrf()
url = f"https://apis.roblox.com/creator-marketplace-purchasing-service/v1/products/1376409798/purchase"

cookies = {
  ".ROBLOSECURITY": COOKIE,
}

headers = {
  "Host": "apis.roblox.com",
  "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:125.0) Gecko/20100101 Firefox/125.0",
  "Accept": "*/*",
  "Accept-Language": "en-US,en;q=0.5",
  "Accept-Encoding": "gzip, deflate, br",
  "Referer": "https://create.roblox.com/",
  "Content-Type": "application/json-patch+json",
  "x-csrf-token": xcsrf,
  "Origin": "https://create.roblox.com",
  "DNT": "1",
  "Sec-GPC": "1",
  "Connection": "keep-alive",
  "Sec-Fetch-Dest": "empty",
  "Sec-Fetch-Mode": "cors",
  "Sec-Fetch-Site": "same-site",
  "TE": "trailers"
}

payload = {"assetId": 12470604445, "assetType": 10, "expectedPrice": 0}

response = requests.post(url, cookies=cookies, headers=headers, json=payload)

print(url, COOKIE, xcsrf)
print(response, response.text)
