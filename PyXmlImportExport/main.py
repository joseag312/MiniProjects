import xml.etree.ElementTree as ET
from os import path
from pathlib import Path

###########################
#####  XML file read  #####

my_dir = Path(r'C:\Users\jose_\OneDrive\MyDocuments\MyCode\MiniProjects\PyXMLImportExport')

def scan_XML(path_name):
    tree = ET.parse(path_name)
    root = tree.getroot()
    print(root.tag, "child elements:")
    for child in root.iter():
        print(child.tag, child.attrib)

def read_subfolder(path_name):    
    for x in path_name.iterdir():
        filename, extension = path.splitext(x)
        if x.is_dir():
            read_subfolder(x)
        if extension == '.xml':
            scan_XML(x)
            print('File: ', x , '\n XML scan... Done')

read_subfolder(my_dir)