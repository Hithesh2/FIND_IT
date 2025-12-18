class CloudinaryConfig {
  // Replace these with your actual Cloudinary credentials
  // Get them from: https://console.cloudinary.com/

  // Your Cloudinary Cloud Name (found in Dashboard)
  static const String cloudName = 'dpmqtduf5';

  // Upload Preset Name (create one in Settings > Upload > Upload presets)
  // Make sure it's set to "Unsigned" for client-side uploads
  static const String uploadPreset = 'findit_unsigned';

  // Optional: API Key and Secret (only needed for server-side operations)
  // For client-side uploads with unsigned preset, you don't need these
  // static const String apiKey = 'YOUR_API_KEY';
  // static const String apiSecret = 'YOUR_API_SECRET';
}
