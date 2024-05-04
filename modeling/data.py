from datetime import date 
from datasets import load_dataset
import pandas as pd
import glob

all_files = glob.glob("../data/*.csv")
data_list = []

session_id = f"{date.today().strftime('%Y%m%d')}-rbxldata"

for filename in all_files:
  df = pd.read_csv(filename)
  df.columns = ["Serialized", "Name", "Description"]  
  data_list.append(df)

data = pd.concat(data_list, ignore_index=True)

data.drop_duplicates(subset="Serialized")
data.dropna(how="any", inplace=True, ignore_index=True, subset=["Serialized"])

# Get rid of any weird carriage returns or tabs
data.replace(to_replace=[r"\\t|\\n|\\r", "\t|\n|\r"], value=["",""], regex=True, inplace=True)

data.to_csv(f"clean-data/{session_id}.csv", index=False)

#################################################
# Technically inefficient but works for now, was spliced from old modeling

def create_instruction(sample):
  return {
    "prompt": sample["Name"] + ". " + (sample["Description"] if sample["Description"] else ""),
    "completion": sample["Serialized"]
  }

dataset = load_dataset("csv", data_files=f"clean-data/{session_id}.csv", delimiter=",")
dataset = dataset.shuffle()

dataset = dataset.map(create_instruction, remove_columns=dataset["train"].column_names, batched=False)
dataset["train"].to_json("clean-data/train_dataset.json", orient="records")