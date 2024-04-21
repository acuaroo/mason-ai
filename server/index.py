from flask import Flask, request, jsonify
from datetime import date 
from urllib.parse import quote

import requests
import pandas as pd

from dotenv import load_dotenv
import os

load_dotenv()

PORT = os.environ.get("PORT")
KEY = os.getenv("KEY")

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
  response = requests.get(url)

  return response.json()

@app.route("/model/", methods=["POST"])
def model():
  received_data = request.json
  product = received_data["id"]
  base_url =f"https://apis.roblox.com/cloud/v2/creator-store-products/{product}"

  headers = {
    "x-api-key": KEY,
  }

  response = requests.get(base_url, headers=headers)

  print(base_url)
  print(response.json())

  return response.json()
app.run(port=PORT, debug=True)