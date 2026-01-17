# Quick Start: Deploy & Build

## Step 1: Deploy Backend to Vercel (5 minutes)

### Option A: Using Vercel CLI (Recommended)

```powershell
# Install Vercel CLI
npm install -g vercel

# Navigate to backend
cd backend

# Login to Vercel
vercel login

# Deploy to production
vercel --prod
```

Save the deployment URL you receive (e.g., `https://reportcyber-backend-xxx.vercel.app`)

### Option B: Using Vercel Dashboard

1. Go to https://vercel.com
2. Click "Add New" → "Project"
3. Import your Git repository (or drag & drop the backend folder)
4. Click "Deploy"

### Step 2: Add Environment Variables

In Vercel Dashboard:
1. Go to your project → Settings → Environment Variables
2. Add these **IMPORTANT** variables:

```
MONGODB_URI=mongodb+srv://nehemiahandrew78_db_user:V3NafOqOkurb8y6t@cluster0.3r1bhkw.mongodb.net/reportcyber?retryWrites=true&w=majority&appName=Cluster0
JWT_ACCESS_SECRET=your-secure-secret-change-this
JWT_REFRESH_SECRET=your-secure-refresh-secret-change-this
NODE_ENV=production
```

3. Click "Deploy" again to apply changes

---

## Step 2: Build Flutter APK (10 minutes)

### Update API URL First

1. Open `frontend/lib/core/config/app_config.dart`
2. Update line 11 with your Vercel URL:
   ```dart
   static const String prodBaseUrl = 'https://your-vercel-url.vercel.app/api/v1';
   ```

### Build the APK

```powershell
# Navigate to frontend
cd frontend

# Create Android platform files (if not exists)
flutter create . --platforms=android

# Clean and get dependencies
flutter clean
flutter pub get

# Build debug APK (for testing)
flutter build apk --debug
```

**APK Location:** `frontend/build/app/outputs/flutter-apk/app-debug.apk`

### Install on Device

**Via USB:**
```powershell
flutter install
```

**Or manually:**
1. Copy `app-debug.apk` to your phone
2. Enable "Install from Unknown Sources"
3. Tap the APK file to install

---

## Quick Commands

### Just Deploy Backend
```powershell
cd backend
vercel --prod
```

### Just Build APK
```powershell
cd frontend
flutter build apk --debug
```

### Both (Using Script)
```powershell
.\deploy-and-build.ps1
```

---

## Testing Checklist

After deployment:

- [ ] Test API: Visit `https://your-url.vercel.app/api/v1/health`
- [ ] Install APK on Android device
- [ ] Test user registration
- [ ] Test login
- [ ] Test report submission
- [ ] Test file upload

---

## Troubleshooting

**Vercel deployment fails?**
- Check `backend/vercel.json` exists
- Ensure all dependencies are in `package.json`
- Check deployment logs in Vercel dashboard

**APK build fails?**
- Run `flutter doctor` to check setup
- Run `flutter clean` then try again
- Check for errors in `pubspec.yaml`

**App can't connect to backend?**
- Verify API URL in `app_config.dart`
- Check Vercel deployment is live
- Test API endpoint in browser

---

## Production Build

For app store release:
```powershell
flutter build apk --release --split-per-abi
```

This creates optimized APKs for different architectures.
