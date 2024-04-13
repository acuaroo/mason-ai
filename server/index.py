from flask import Flask, request, jsonify
from datetime import date 
from urllib.parse import quote

import requests
import pandas as pd

from dotenv import load_dotenv
import os

load_dotenv()

PORT = os.environ.get("PORT")
COOKIE = os.environ.get("COOKIE")
XCSRF = os.environ.get("XCSRF")

app = Flask(__name__)

session_id = f"{date.today().strftime('%Y%m%d')}-rbxldata"

@app.route("/data", methods=["POST"])
def data():
  received_data = request.json

  df = pd.DataFrame(received_data, index=[0])
  df.to_csv(f"../data/{session_id}.csv", mode="a", header=False, index=False)

  return jsonify({"status": "success"})

@app.route("/test", methods=["POST"])
def test():
  return jsonify({"status": "success"})

@app.route("/proxy", methods=["GET"])
def proxy():
  url = request.args.get("url")

  print(url)

  response = requests.get(url)

  return response.json()

@app.route("/model/", methods=["POST"])
def model():
  received_data = request.json

  headers = {
    "Referer": "https://create.roblox.com/",
    "Content-Type": "application/json-patch+json",
    "x-csrf-token": "/" + XCSRF,
    "Origin": "https://create.roblox.com",
    "Cookie": COOKIE,
  }

  payload = {
    "assetId": received_data["id"],
    "assetType": 10,
    "expectedPrice": 0,
  }

  response = requests.post(f"https://apis.roblox.com/creator-marketplace-purchasing-service/v1/products/{received_data["id"]}/purchase", headers=headers, json=payload)

  return response.json()
app.run(port=PORT, debug=True)