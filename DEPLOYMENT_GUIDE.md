# ReportCyber Deployment Guide

## Backend Deployment on Vercel

### Prerequisites
1. Create a [MongoDB Atlas](https://www.mongodb.com/cloud/atlas) account (free tier available)
2. Create a [Vercel](https://vercel.com) account
3. Install Vercel CLI: `npm install -g vercel`

### Step 1: Set Up MongoDB Atlas
1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create a new cluster (free M0 tier)
3. Create a database user with password
4. Whitelist all IPs: `0.0.0.0/0` (or specific Vercel IPs)
5. Get your connection string (looks like: `mongodb+srv://username:password@cluster.mongodb.net/`)

### Step 2: Configure Environment Variables
1. Copy `.env.example` to `.env` locally
2. Fill in all required values
3. **DO NOT commit `.env` to git**

### Step 3: Deploy Backend to Vercel

#### Option A: Using Vercel Dashboard (Recommended)
1. Go to [vercel.com/new](https://vercel.com/new)
2. Import your GitHub repository (push code to GitHub first)
3. Select the `backend` folder as root directory
4. Add environment variables in Vercel dashboard:
   - Go to Project Settings → Environment Variables
   - Add all variables from `.env.example`
5. Deploy!

#### Option B: Using Vercel CLI
```bash
cd backend
vercel login
vercel --prod
```

Then add environment variables:
```bash
vercel env add MONGODB_URI
vercel env add JWT_SECRET
vercel env add EMAIL_HOST
# ... add all other variables
```

### Step 4: Update Frontend API URL
After deploying backend, update the API URL in your Flutter app:

**File:** `frontend/lib/core/config/app_config.dart`
```dart
class AppConfig {
  static const String baseUrl = 'https://your-backend.vercel.app';
  // ... rest of config
}
```

---

## Building Android APK

### Prerequisites
1. Android Studio or Android SDK installed
2. Flutter SDK installed
3. Java JDK 11 or higher

### Step 1: Configure App
1. Update `frontend/android/app/build.gradle`:
   - Set `applicationId`
   - Set version numbers

2. Generate app signing key:
```bash
cd frontend/android/app
keytool -genkey -v -keystore reportcyber-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias reportcyber
```

3. Create `frontend/android/key.properties`:
```properties
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=reportcyber
storeFile=reportcyber-key.jks
```

### Step 2: Build APK
```bash
cd frontend
flutter clean
flutter pub get
flutter build apk --release
```

The APK will be at: `frontend/build/app/outputs/flutter-apk/app-release.apk`

### Step 3: Build App Bundle (for Google Play)
```bash
flutter build appbundle --release
```

The bundle will be at: `frontend/build/app/outputs/bundle/release/app-release.aab`

---

## Alternative: Backend on Railway (Recommended for Express Apps)

Railway is better suited for traditional Node.js apps with MongoDB:

1. Go to [railway.app](https://railway.app)
2. Create new project → Deploy from GitHub
3. Select your repository
4. Add MongoDB plugin (built-in)
5. Add environment variables
6. Deploy automatically!

Railway provides:
- Free tier with 500 hours/month
- Built-in MongoDB
- Automatic deployments
- Better suited for Express apps with WebSockets/long-running processes

---

## Alternative: Backend on Render

1. Go to [render.com](https://render.com)
2. Create new Web Service
3. Connect GitHub repository
4. Select `backend` folder
5. Add environment variables
6. Deploy!

Render provides:
- Free tier available
- Good for Express apps
- Automatic deployments from git

---

## Post-Deployment Checklist

### Backend
- [ ] MongoDB Atlas cluster created and accessible
- [ ] All environment variables set in hosting platform
- [ ] CORS configured for your frontend domain
- [ ] File upload working (use Cloudinary/S3 for production)
- [ ] Email service configured
- [ ] API endpoints tested

### Frontend (APK)
- [ ] API base URL updated to production backend
- [ ] App signed with release key
- [ ] APK tested on physical device
- [ ] Permissions configured in AndroidManifest.xml
- [ ] App icon and name set correctly

---

## Troubleshooting

### Backend Issues
- **MongoDB connection failed**: Check IP whitelist in MongoDB Atlas
- **Environment variables not working**: Verify they're set in Vercel dashboard
- **File upload not working**: Vercel has read-only filesystem, use cloud storage (Cloudinary, AWS S3)
- **Cold starts**: Vercel serverless functions have cold starts, consider Railway/Render for always-on server

### APK Build Issues
- **Build fails**: Run `flutter clean` and `flutter pub get`
- **Signing errors**: Verify `key.properties` path and credentials
- **App crashes**: Check logs with `flutter logs` or `adb logcat`

---

## Production Recommendations

### Backend Hosting Priority:
1. **Railway** - Best for Express + MongoDB, easy setup
2. **Render** - Good free tier, reliable
3. **Vercel** - Works but limited for traditional servers
4. **Heroku** - Reliable but no free tier anymore

### Database:
- **MongoDB Atlas** (Free tier: 512MB)

### File Storage:
- **Cloudinary** (Free tier: 25GB)
- **AWS S3** (Pay as you go)

### Email:
- **SendGrid** (Free tier: 100 emails/day)
- **Mailgun** (Free tier: 5000 emails/month)
