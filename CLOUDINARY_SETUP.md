# Cloudinary Setup Guide

This guide will help you set up Cloudinary for image uploads in your Find It app.

## Step 1: Create a Cloudinary Account

1. Go to [https://cloudinary.com/](https://cloudinary.com/)
2. Sign up for a free account
3. Verify your email address

## Step 2: Get Your Cloud Name

1. After logging in, you'll see your **Dashboard**
2. Your **Cloud Name** is displayed at the top of the dashboard
3. Copy this value (e.g., `dxyz123abc`)

## Step 3: Create an Upload Preset

1. Go to **Settings** → **Upload** → **Upload presets**
2. Click **Add upload preset**
3. Configure the preset:
   - **Preset name**: Give it a name (e.g., `findit_unsigned`)
   - **Signing mode**: Select **Unsigned** (important for client-side uploads)
   - **Folder**: Optional - you can organize images in folders (e.g., `lost_found_items`)
   - **Format**: Leave as default or set to `auto` for automatic format optimization
   - **Quality**: Set to `auto` for automatic quality optimization
4. Click **Save**

## Step 4: Update Your App Configuration

1. Open `lib/core/constants/cloudinary_config.dart`
2. Replace the placeholder values:

```dart
class CloudinaryConfig {
  // Replace with your Cloudinary Cloud Name
  static const String cloudName = 'YOUR_CLOUD_NAME';  // e.g., 'dxyz123abc'
  
  // Replace with your Upload Preset name
  static const String uploadPreset = 'YOUR_UPLOAD_PRESET';  // e.g., 'findit_unsigned'
}
```

**Example:**
```dart
class CloudinaryConfig {
  static const String cloudName = 'dxyz123abc';
  static const String uploadPreset = 'findit_unsigned';
}
```

## Step 5: Install Dependencies

Run the following command to install the HTTP package:

```bash
flutter pub get
```

## How It Works

1. **Image Picker**: Users can select up to 3 images using the image picker
2. **Upload to Cloudinary**: When the form is submitted, images are uploaded to Cloudinary using HTTP multipart requests
3. **Get URLs**: Cloudinary returns secure URLs for each uploaded image
4. **Store in Firestore**: The image URLs are stored in the `imageUrls` array field in the `LostItems` or `FoundItems` collection

## Image URL Format

After upload, Cloudinary returns URLs in this format:
```
https://res.cloudinary.com/YOUR_CLOUD_NAME/image/upload/v1234567890/IMAGE_ID.jpg
```

These URLs are stored in Firestore and can be used directly in your app to display images.

## Free Tier Limits

Cloudinary's free tier includes:
- 25 GB storage
- 25 GB monthly bandwidth
- Unlimited transformations
- This should be sufficient for most small to medium apps

## Security Notes

- The upload preset is set to **Unsigned** for client-side uploads
- This means anyone with your cloud name and preset can upload images
- For production, consider implementing server-side uploads with signed requests
- You can also set upload restrictions in Cloudinary settings (file size, formats, etc.)

## Testing

1. Run your app
2. Go to "Report Lost Item" or "Report Found Item"
3. Select up to 3 images
4. Fill in the form and submit
5. Check your Cloudinary Media Library to see uploaded images
6. Check Firestore to see the image URLs stored in the document

## Troubleshooting

### Error: "Invalid upload preset"
- Make sure the preset name matches exactly (case-sensitive)
- Ensure the preset is set to "Unsigned"

### Error: "Invalid cloud name"
- Double-check your cloud name in the dashboard
- Make sure there are no extra spaces

### Images not uploading
- Check your internet connection
- Verify the Cloudinary service is accessible
- Check the console logs for detailed error messages

## Additional Resources

- [Cloudinary Documentation](https://cloudinary.com/documentation)
- [Upload API Reference](https://cloudinary.com/documentation/upload_images)
- [Upload Presets Guide](https://cloudinary.com/documentation/upload_presets)

