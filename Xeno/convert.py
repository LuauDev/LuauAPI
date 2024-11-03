import re

def convert_functions(file_path):
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Convert function declarations
    converted = re.sub(
        r'function Xeno\.(\w+)\((.*?)\)',
        r'Xeno.\1 = function(\2)',
        content
    )
    
    with open(file_path, 'w') as f:
        f.write(converted)

# Use it on your file
convert_functions('include/client.lua')