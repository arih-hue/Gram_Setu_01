import os
import re

files_to_modify = ['home.dart', 'doctor.dart', 'asha_worker.dart', 'panchayat.dart']

for root, _, files in os.walk('lib'):
    for file in files:
        if file in files_to_modify:
            filepath = os.path.join(root, file)
            with open(filepath, 'r+', encoding='utf-8') as f:
                content = f.read()
                
                # Check if it needs import
                if 'TranslatedText' not in content:
                    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../widgets/translated_text.dart';")
                
                # Replace specific Text('...') patterns safely
                # Look for Text('Alphabetical or strings with spaces'
                content = re.sub(r"Text\(\s*('[A-Za-z\s&/,!?.-]+')\s*,", r"TranslatedText(\1,", content)
                
                f.seek(0)
                f.write(content)
                f.truncate()
