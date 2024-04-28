from datetime import date 
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
data.replace(to_replace=[r"\\t|\\n|\\r", "\t|\n|\r"], value=["",""], regex=True, inplace=True)

data.to_csv(f"clean-data/{session_id}.csv", index=False)

print(data.head())