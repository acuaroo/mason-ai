from flask import Flask, request, jsonify
from datetime import date 
from urllib.parse import quote

import requests
import pandas as pd

from dotenv import load_dotenv
import os

load_dotenv()

PORT = os.getenv("PORT")
COOKIE = os.getenv("COOKIE")

app = Flask(__name__)

session_id = f"{date.today().strftime('%Y%m%d')}-rbxldata"

@app.route("/data", methods=["POST"])
def data():
  received_data = request.json

  df = pd.DataFrame(received_data, index=[0])
  df = df.replace({"\n": " "}, regex=True)
  df.to_csv(f"../data/{session_id}.csv", mode="a", header=False, index=False)

  return jsonify({"status": "success"})

@app.route("/test", methods=["POST"])
def test():
  return jsonify({"status": "success"})

@app.route("/productid", methods=["POST"])
def productid():
  received_data = request.json

  url = f"https://apis.roblox.com/toolbox-service/v1/items/details?assetIds={received_data["asset_id"]}"
  response = requests.get(url)

  print(response, response.text)
  return response.text

@app.route("/model", methods=["POST"])
def model():  
  received_data = request.json

  xcsrf_response = requests.post("https://auth.roblox.com/v2/logout", cookies={".ROBLOSECURITY": COOKIE})
  xcsrf = xcsrf_response.headers["x-csrf-token"]

  url = f"https://apis.roblox.com/creator-marketplace-purchasing-service/v1/products/{received_data["product_id"]}/purchase"
  cookies = {".ROBLOSECURITY": COOKIE}

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

  payload = {"assetId": received_data["asset_id"], "assetType": 10, "expectedPrice": 0}
  response = requests.post(url, cookies=cookies, headers=headers, json=payload)

  print(response, response.text)
  return response.text

app.run(port=PORT, debug=True)