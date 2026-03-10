abstract class AppConstants {
  static const String appTitle = 'Plushie Yourself';

  // OpenAI endpoints
  static const String openAiResponsesUrl =
      'https://api.openai.com/v1/responses';

  // Prompt sent to Responses API (single call — keeps real background)
  static const String plushiePrompt =
      'Transform the subject or image into an adorable plushie-style form with soft textures and rounded proportions. '
      'If a person is present, preserve recognizable traits; otherwise, reinterpret the object or animal as a cozy stuffed toy using felt or fleece textures. '
      'Give it a cozy felt or fleece texture, simplified shapes, and gentle embroidered details for the eyes, mouth, and features. '
      'Use a warm, pastel or neutral color palette with smooth shading and subtle seams, like a handcrafted stuffed toy. '
      'Keep the expression friendly and cute, with a slightly oversized head, short limbs, and a cuddly silhouette. '
      'The final image should feel like a charming, collectible plush toy - cozy, wholesome, and huggable, while still recognizable as the original subject. '
      'Keep the real photo background and environment exactly as-is. Keep the clothing and scene unchanged. '
      'Transform only the faces into plushie style: rounded felt face, large embroidered eyes with white highlight dot, rosy blush cheeks, stitched smile, felt skin texture.';
}
