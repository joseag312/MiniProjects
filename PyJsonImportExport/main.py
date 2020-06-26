import json
from os import path
from pathlib import Path

### Inline json processing ###
a = {"legs": ["frontleft", "frontright", "backleft", "backright"], "IsYoung": False, "Age": 12, "Color": "Black", "Owners": ["Pancho", "Claudia"], "MedicalHistory": {"NumberOfProcs": 1,  "Procs": ["BathLol"]}}
#print(json.dumps(a, sort_keys=True, indent=4))

###########################
##### json file read  #####

my_dir = Path(r'C:\Users\jose_\OneDrive\MyDocuments\MyCode\MiniProjects\PyJsonImportExport')

def scan_json(path_name):
    with open(path_name) as f:
        read_data = f.read()
        obj = json.loads(read_data)
    print(json.dumps(obj, indent=4))

def read_subfolder_json_read(path_name):    
    for x in path_name.iterdir():
        filename, extension = path.splitext(x)
        if x.is_dir():
            read_subfolder(x)
        if extension == '.json':
            scan_json(x)
            print('File: ', x , '\n JSON scan... Done')

read_subfolder_json_read(my_dir)

###########################
##### json file write #####

my_dir = Path(r'C:\Users\jose_\OneDrive\MyDocuments\MyCode\MiniProjects\PyJsonImportExport')

def create_json(path_name):
    f= open(path_name.joinpath(r'Ex3.json'),"w+")
    f.write(json.dumps(a, indent=4))

create_json(my_dir)