# send a POST request to localhost://3232/data with the following JSON payload:
import requests

payload = {
  "name": "test",
  "description": "test2",
  "serialization" : "test3",
}

print(requests.post("http://localhost:3232/data", json=payload))