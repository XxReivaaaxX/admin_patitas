# Reglas necesarias para TensorFlow Lite (tflite_flutter)
# Evita que R8 optimice o elimine las clases del delegado de GPU/NNAPI

-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.nnapi.** { *; }
-keep class org.tensorflow.lite.examples.classification.** { *; }
-keep class org.tensorflow.lite.examples.detection.** { *; }