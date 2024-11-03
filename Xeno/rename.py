def replace_xeno(input_file='include/client.lua', output_file='include/client.lua'):
    with open(input_file, 'r') as f:
        content = f.read()
    
    content = content.replace('Xeno.', 'LuauAPI.')
    content = content.replace('Xeno ', 'LuauAPI ')
    content = content.replace('Xeno\n', 'LuauAPI\n')
    content = content.replace('Xeno{', 'LuauAPI{')
    content = content.replace('Xeno=', 'LuauAPI=')
    
    with open(output_file, 'w') as f:
        f.write(content)

replace_xeno()