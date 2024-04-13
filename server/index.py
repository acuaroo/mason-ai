from flask import Flask, request, jsonify
from datetime import date 

import pandas as pd

PORT = 3232
app = Flask(__name__)

session_id = f"{date.today().strftime('%Y%m%d')}-rbxldata"

@app.route("/data/", methods=["POST"])
def data():
  received_data = request.json

  df = pd.DataFrame(received_data, index=[0])
  df.to_csv(f"../data/{session_id}.csv", mode="a", header=False, index=False)

  return jsonify({"status": "success"})


app.run(port=PORT, debug=True)