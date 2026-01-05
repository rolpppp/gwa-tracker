# Keep PDF library classes
-keep class com.tom_roush.pdfbox.** { *; }
-keep class com.gemalto.jp2.** { *; }
-dontwarn com.gemalto.jp2.**
-dontwarn com.tom_roush.pdfbox.**

# Keep PDF text reader plugin
-keep class com.example.read_pdf_text.** { *; }
