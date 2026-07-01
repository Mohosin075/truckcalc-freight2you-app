import re
import base64

svg_path = r'C:\Users\Mohosin\StudioProjects\truckcalc-freight2you-app\assets\images\store-thump.svg'
out_path = r'C:\Users\Mohosin\StudioProjects\truckcalc-freight2you-app\assets\images\store-thump-icon.png'

with open(svg_path, 'r', encoding='utf-8') as f:
    content = f.read()

match = re.search(r'xlink:href="data:image/png;base64,([^"]+)"', content)
if match:
    b64 = match.group(1).strip()
    png_data = base64.b64decode(b64)
    with open(out_path, 'wb') as out:
        out.write(png_data)
    print('SUCCESS: store-thump-icon.png created, size:', len(png_data), 'bytes')
else:
    print('ERROR: No base64 PNG found in SVG')
