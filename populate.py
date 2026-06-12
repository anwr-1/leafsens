import json

classes = [
    "Apple___Apple_scab", "Apple___Black_rot", "Apple___Cedar_apple_rust", "Apple___healthy",
    "Blueberry___healthy", "Cherry_(including_sour)___Powdery_mildew", "Cherry_(including_sour)___healthy",
    "Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot", "Corn_(maize)___Common_rust_", "Corn_(maize)___Northern_Leaf_Blight", "Corn_(maize)___healthy",
    "Grape___Black_rot", "Grape___Esca_(Black_Measles)", "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)", "Grape___healthy",
    "Orange___Haunglongbing_(Citrus_greening)", "Peach___Bacterial_spot", "Peach___healthy",
    "Pepper,_bell___Bacterial_spot", "Pepper,_bell___healthy", "Potato___Early_blight", "Potato___Late_blight", "Potato___healthy",
    "Raspberry___healthy", "Soybean___healthy", "Squash___Powdery_mildew", "Strawberry___Leaf_scorch", "Strawberry___healthy",
    "Tomato___Bacterial_spot", "Tomato___Early_blight", "Tomato___Late_blight", "Tomato___Leaf_Mold", "Tomato___Septoria_leaf_spot",
    "Tomato___Spider_mites Two-spotted_spider_mite", "Tomato___Target_Spot", "Tomato___Tomato_Yellow_Leaf_Curl_Virus", "Tomato___Tomato_mosaic_virus", "Tomato___healthy"
]

dart_code = "const Map<String, Map<String, List<String>>> treatments = {\n"

for c in classes:
    if "healthy" in c.lower():
        symptoms = "['النبات يبدو بصحة ممتازة', 'الأوراق خضراء خالية من البقع أو العيوب']"
        causes = "['رعاية جيدة', 'ظروف بيئية مناسبة']"
        treatments_list = "['استمر في الرعاية الحالية، لا حاجة لأي تدخل']"
    else:
        symptoms = "['ظهور بقع وتغير في لون الأوراق', 'ضعف عام في النبات وتراجع في النمو']"
        causes = "['عدوى فطرية أو بكتيرية أو فيروسية', 'رطوبة عالية وسوء تهوية']"
        treatments_list = "['إزالة الأجزاء المصابة فوراً وإتلافها', 'استخدام مبيد مناسب (فطري/بكتيري)', 'تحسين التهوية وتقليل الرطوبة حول النبات']"
    
    dart_code += f"  '{c}': {{\n"
    dart_code += f"    'symptoms': {symptoms},\n"
    dart_code += f"    'causes': {causes},\n"
    dart_code += f"    'treatment': {treatments_list},\n"
    dart_code += "  },\n"

dart_code += "};\n"

# Open the treatments_data.dart file and append this map
file_path = r"C:\Users\nnasr\OneDrive\Desktop\leafsense\mobile\lib\core\constants\treatments_data.dart"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

import re
# Replace the empty map with the full map
new_content = re.sub(r"const Map<String, Map<String, List<String>>> treatments = \{.*?};", dart_code, content, flags=re.DOTALL)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(new_content)
