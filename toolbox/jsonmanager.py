import json
import pandas as pd

class JsonManager:
    
    schema_path = './data/json/schemas/standard.json'
    schema = json.load(open(schema_path))

    def __init__(self):
        self.titles_description()
        self.patient_level = self.descriptions[self.descriptions['depth'] == 2]
        self.visit_level = self.descriptions[self.descriptions['depth'] > 2]

    def titles_description(self, data=schema, out={}, name='schema', iter=0):
        out = out
        if isinstance(data, dict):
            for key, value in data.items():
                if 'title' in data:
                    out[name] = {'title': data['title'], 
                                 'depth': iter}
                if isinstance(value, (dict, list)):
                    self.titles_description(value, out, key, iter=iter+1)
        elif isinstance(data, list):
            for item in data:
                self.titles_description(item, out, name, iter=iter+1)
        
        self.descriptions = pd.DataFrame(out).T

    @staticmethod
    def save_json(data: dict, path: str):
        with open(path, 'w') as f:
            json.dump(data, f, indent=4)

    
#-------------- TESTING --------------#

# print(pd.DataFrame(JsonManager().patient_level['title']))
# print(json.dumps(JsonManager().descriptions, indent=4))

        

