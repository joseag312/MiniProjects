import fileinput
from os import path
from pathlib import Path

# Place target directory here:
my_dir = Path(r'C:\Users\jose_\OneDrive\MyDocuments\MyCode\tabparsermsql')


def replace_file(path_name):
    for line in fileinput.input(path_name, inplace=True):
        while(line.find('\t') != -1):
            pos = line.find('\t')
            spaces = ' ' * (4 - pos%4)
            line = line[:pos] + spaces + line[pos + 1:]
        print(line, end = '')
    


def read_subfolder(path_name):    
    for x in path_name.iterdir():
        filename, extension = path.splitext(x)
        if x.is_dir():
            read_subfolder(x)
        if extension == '.sql':
            replace_file(x)
            print('File: ', x , '\n Tab to spaces parsing... Done')


read_subfolder(my_dir)