# Deploy ReportCyber Backend to Vercel

## Prerequisites

1. A Vercel account (sign up at https://vercel.com)
2. Git repository (recommended for automatic deployments)

## Option 1: Deploy via Vercel Website (Easiest)

### Step 1: Prepare Your Backend

Make sure your `backend/vercel.json` is configured correctly (already done ✓)

### Step 2: Install Vercel CLI

Open PowerShell and run:
```powershell
npm install -g vercel
```

If you encounter network issues, try:
```powershell
# Clear npm cache
npm cache clean --force

# Or use different registry
npm install -g vercel --registry=https://registry.npmjs.org/
```

### Step 3: Login to Vercel

```powershell
cd backend
vercel login
```

This will open your browser to authenticate.

### Step 4: Deploy to Vercel

For first deployment:
```powershell
vercel
```

The CLI will ask you:
- Set up and deploy? **Y**
- Which scope? Select your account
- Link to existing project? **N**
- What's your project's name? **reportcyber-backend**
- In which directory is your code located? **./** (just press Enter)
- Want to override settings? **N**

For production deployment:
```powershell
vercel --prod
```

### Step 5: Configure Environment Variables

After deployment, you need to add environment variables:

**Via Vercel Dashboard:**
1. Go to https://vercel.com/dashboard
2. Select your project (reportcyber-backend)
3. Go to Settings → Environment Variables
4. Add all variables from your `.env` file:

```
NODE_ENV=production
PORT=3000
MONGODB_URI=mongodb+srv://nehemiahandrew78_db_user:V3NafOqOkurb8y6t@cluster0.3r1bhkw.mongodb.net/reportcyber?retryWrites=true&w=majority&appName=Cluster0
JWT_ACCESS_SECRET=rc-prod-access-secret-key-2024-CHANGE-THIS
JWT_REFRESH_SECRET=rc-prod-refresh-secret-key-2024-CHANGE-THIS
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=7d
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
EMAIL_FROM=noreply@reportcyber.com
EMAIL_FROM_NAME=ReportCyber
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_CALLBACK_URL=https://your-domain.vercel.app/api/v1/auth/google/callback
GITHUB_CLIENT_ID=your-github-client-id
GITHUB_CLIENT_SECRET=your-github-client-secret
GITHUB_CALLBACK_URL=https://your-domain.vercel.app/api/v1/auth/github/callback
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY_ID=your-firebase-key-id
FIREBASE_PRIVATE_KEY=your-firebase-private-key
FIREBASE_CLIENT_EMAIL=your-firebase-client-email
FIREBASE_CLIENT_ID=your-firebase-client-id
FIREBASE_STORAGE_BUCKET=your-firebase-bucket.appspot.com
MAX_FILE_SIZE=10485760
ALLOWED_FILE_TYPES=image/png,image/jpeg,application/pdf,text/plain,text/log
ENCRYPTION_KEY=your-32-character-encryption-key-here
CORS_ORIGIN=http://localhost:3000,https://your-domain.vercel.app
```

**Via CLI:**
```powershell
vercel env add MONGODB_URI production
# Paste your MongoDB URI when prompted
# Repeat for each variable
```

### Step 6: Redeploy After Adding Variables

```powershell
vercel --prod
```

### Step 7: Get Your Deployment URL

After successful deployment, you'll see:
```
✅  Production: https://reportcyber-backend-xxx.vercel.app [copied to clipboard]
```

Save this URL - you'll need it for the mobile app!

## Option 2: Deploy via Git Integration (Recommended for Production)

### Step 1: Push to GitHub

```powershell
# If not already initialized
cd backend
git init
git add .
git commit -m "Initial backend commit"

# Create a new repository on GitHub, then:
git remote add origin https://github.com/yourusername/reportcyber-backend.git
git branch -M main
git push -u origin main
```

### Step 2: Import to Vercel

1. Go to https://vercel.com/new
2. Click "Import Git Repository"
3. Select your repository
4. Configure project:
   - **Framework Preset:** Other
   - **Root Directory:** `backend` (if your repo has both frontend and backend)
   - **Build Command:** (leave empty)
   - **Output Directory:** (leave empty)
5. Add environment variables (same as Option 1, Step 5)
6. Click "Deploy"

## Important Notes for Production

### 1. Update CORS Settings

In `backend/src/server.js`, update the CORS configuration to include your Vercel URL.

### 2. Update OAuth Callback URLs

Update your Google and GitHub OAuth callback URLs to use your Vercel domain:
```
https://your-domain.vercel.app/api/v1/auth/google/callback
https://your-domain.vercel.app/api/v1/auth/github/callback
```

### 3. Redis Configuration

Vercel's serverless functions don't support persistent connections. You have two options:

**Option A:** Use Upstash Redis (Recommended)
1. Sign up at https://upstash.com
2. Create a Redis database
3. Update your environment variables:
   ```
   REDIS_HOST=your-upstash-host.upstash.io
   REDIS_PORT=6379
   REDIS_PASSWORD=your-upstash-password
   ```

**Option B:** Remove Redis dependency
- Comment out Redis-related code in your application
- Use in-memory caching (not recommended for production)

### 4. File Uploads

Vercel has a 4.5MB request body limit. For file uploads:
- Use Firebase Storage directly from the frontend
- Or use a dedicated file upload service like Cloudinary or AWS S3

## Testing Your Deployment

Once deployed, test your API:

```powershell
# Test health check
curl https://your-domain.vercel.app/api/v1/health

# Or use Invoke-WebRequest in PowerShell
Invoke-WebRequest -Uri https://your-domain.vercel.app/api/v1/health
```

## Troubleshooting

### Error: "Cannot find module"
- Check that all dependencies are in `package.json`
- Ensure `node_modules` is in `.gitignore`

### Error: "Database connection timeout"
- Verify MongoDB URI is correct in environment variables
- Check MongoDB Atlas allows connections from all IPs (0.0.0.0/0)

### Error: "Function timeout"
- Vercel free tier has 10s timeout
- Optimize slow database queries
- Consider upgrading to Pro plan for 60s timeout

## Next Steps

After successful deployment:
1. ✅ Note your deployment URL
2. 📱 Update Flutter app API configuration
3. 🧪 Test all API endpoints
4. 🚀 Build and test your mobile app

Your deployment URL will be something like:
`https://reportcyber-backend-xxx.vercel.app`
