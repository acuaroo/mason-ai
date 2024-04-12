from flask import Flask, request, jsonify
from datetime import date 

import csv

PORT = 3232
app = Flask(__name__)

session_id = f"{date.today().strftime('%Y%m%d')}-rbxldata"

@app.route("/data", methods=["POST"])
def data():
  received_data = request.json

  with open(f"../data/{session_id}.csv", mode="a") as data_file:
    data_writer = csv.writer(data_file, delimiter=",", quotechar="\"", quoting=csv.QUOTE_MINIMAL)
    data_writer.writerow([received_data["name"], received_data["description"], received_data["serialization"]])

  return jsonify({"status": "success"})


app.run(port=PORT, debug=True)