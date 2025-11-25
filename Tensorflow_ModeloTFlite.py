
import tensorflow as tf

# Ruta a la carpeta del modelo (NO al archivo .pb)
model_dir = r"C:\Users\dfvarelal\Downloads\mobilenet-v2-tensorflow2-100-224-classification-v2"

# Convertir el modelo a TensorFlow Lite
converter = tf.lite.TFLiteConverter.from_saved_model(model_dir)
converter.optimizations = [tf.lite.Optimize.DEFAULT]  # Opcional
tflite_model = converter.convert()

# Guardar el archivo .tflite
output_path = r"C:\Users\dfvarelal\Downloads\model.tflite"
with open(output_path, "wb") as f:
    f.write(tflite_model)

print(f"Modelo convertido y guardado en: {output_path}")
