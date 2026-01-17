# Production Deployment Checklist

## Backend Deployment

### MongoDB Setup
- [ ] MongoDB Atlas account created
- [ ] Cluster created (M0 free tier or paid)
- [ ] Database user created with strong password
- [ ] IP whitelist configured (0.0.0.0/0 for all IPs or specific Vercel IPs)
- [ ] Connection string obtained
- [ ] Database name set in connection string

### Vercel/Railway/Render Setup
- [ ] Account created on chosen platform
- [ ] Repository pushed to GitHub (if using git deployment)
- [ ] Project created and connected

### Environment Variables Configured
- [ ] MONGODB_URI
- [ ] JWT_SECRET (use strong random string)
- [ ] JWT_EXPIRE
- [ ] EMAIL_HOST
- [ ] EMAIL_PORT
- [ ] EMAIL_USER
- [ ] EMAIL_PASSWORD
- [ ] EMAIL_FROM
- [ ] NODE_ENV=production
- [ ] CLIENT_URL (your frontend URL)
- [ ] ENCRYPTION_KEY (32 characters)
- [ ] FIREBASE_PROJECT_ID (if using Firebase)
- [ ] FIREBASE_PRIVATE_KEY (if using Firebase)
- [ ] FIREBASE_CLIENT_EMAIL (if using Firebase)

### Backend Code Updates
- [ ] CORS configured for production domains
- [ ] Rate limiting configured appropriately
- [ ] Error messages don't expose sensitive info
- [ ] File upload limits configured
- [ ] Logging configured (not console.log in production)

### Testing Backend
- [ ] Health check endpoint works
- [ ] Authentication endpoints work
- [ ] Report submission works
- [ ] File upload works (or cloud storage configured)
- [ ] Email sending works
- [ ] All API endpoints tested with Postman/Insomnia

---

## Frontend (Flutter App) Preparation

### Code Updates
- [ ] API base URL updated to production backend
- [ ] Remove any console.log or print statements
- [ ] Error handling added for all API calls
- [ ] Loading states implemented
- [ ] Offline mode handling (if applicable)

### Android Setup
- [ ] Android platform files created (`flutter create . --platforms=android`)
- [ ] Application ID set in build.gradle
- [ ] App name set in AndroidManifest.xml
- [ ] Permissions added to AndroidManifest.xml:
  - [ ] INTERNET
  - [ ] CAMERA (if using camera)
  - [ ] READ_EXTERNAL_STORAGE
  - [ ] READ_MEDIA_IMAGES
  - [ ] READ_MEDIA_VIDEO
- [ ] Min SDK version set (21+)
- [ ] Target SDK version set (33)
- [ ] Version code and version name set

### App Signing (For Release)
- [ ] Keystore file generated (.jks)
- [ ] key.properties file created
- [ ] key.properties added to .gitignore
- [ ] build.gradle configured for signing
- [ ] Keystore file backed up securely

### App Assets
- [ ] App icon created and added (all sizes)
- [ ] Splash screen configured
- [ ] App name finalized
- [ ] Colors and branding finalized

### Testing
- [ ] App tested on multiple Android versions
- [ ] App tested on different screen sizes
- [ ] All features tested on physical device
- [ ] Camera functionality tested
- [ ] File upload tested
- [ ] Network error handling tested
- [ ] Offline behavior tested

---

## Google Play Store Preparation (If Publishing)

### Account Setup
- [ ] Google Play Console account created ($25 fee)
- [ ] Payment information added

### App Information
- [ ] App title (max 50 characters)
- [ ] Short description (max 80 characters)
- [ ] Full description (max 4000 characters)
- [ ] App category selected
- [ ] Content rating completed

### Graphics Assets
- [ ] App icon (512x512 PNG)
- [ ] Feature graphic (1024x500 PNG/JPG)
- [ ] Phone screenshots (2-8, 16:9 or 9:16 ratio)
- [ ] Tablet screenshots (optional, 16:9 or 9:16 ratio)

### Legal
- [ ] Privacy policy created and hosted
- [ ] Terms of service created
- [ ] Support email set up
- [ ] Website URL (optional)

### App Content
- [ ] Content rating questionnaire completed
- [ ] Target audience and content declared
- [ ] Data safety section filled out

### Release
- [ ] App bundle (.aab) uploaded
- [ ] Release notes written
- [ ] Pricing set (free or paid)
- [ ] Countries/regions selected
- [ ] Age rating confirmed
- [ ] Internal testing completed (optional)
- [ ] Closed testing completed (optional)
- [ ] Open testing completed (optional)
- [ ] Production release submitted for review

---

## Security Checklist

### Backend Security
- [ ] HTTPS enforced (not HTTP)
- [ ] JWT secrets are strong and random
- [ ] Passwords are hashed (bcrypt)
- [ ] SQL/NoSQL injection prevention in place
- [ ] XSS prevention implemented
- [ ] CSRF protection enabled
- [ ] Rate limiting configured
- [ ] Input validation on all endpoints
- [ ] File upload validation (type, size)
- [ ] Sensitive data encrypted in database
- [ ] API keys not hardcoded
- [ ] Environment variables secured

### Frontend Security
- [ ] No API keys or secrets in code
- [ ] Secure storage for tokens
- [ ] HTTPS used for all API calls
- [ ] Input validation on forms
- [ ] No sensitive data in logs
- [ ] WebView security configured (if using)

---

## Performance Checklist

### Backend
- [ ] Database indexes created
- [ ] Query optimization done
- [ ] Caching implemented (Redis/in-memory)
- [ ] Image optimization for uploads
- [ ] API response compression enabled
- [ ] Connection pooling configured

### Frontend
- [ ] Images optimized
- [ ] Lazy loading implemented
- [ ] Pagination for lists
- [ ] Caching strategy implemented
- [ ] App size optimized (<50MB recommended)
- [ ] Build shrinking enabled

---

## Monitoring & Analytics (Optional but Recommended)

### Backend Monitoring
- [ ] Error tracking (Sentry, Rollbar)
- [ ] Performance monitoring (New Relic, DataDog)
- [ ] Uptime monitoring (UptimeRobot, Pingdom)
- [ ] Log aggregation (LogDNA, Papertrail)

### App Analytics
- [ ] Firebase Analytics integrated
- [ ] Crashlytics for crash reporting
- [ ] User analytics (MixPanel, Amplitude)

---

## Pre-Launch Final Checks

### Backend
- [ ] All endpoints tested in production
- [ ] Database backups configured
- [ ] SSL certificate valid
- [ ] Domain configured correctly
- [ ] Email sending works
- [ ] File uploads work (to cloud storage)

### App
- [ ] Final build tested on real devices
- [ ] All features working with production backend
- [ ] No debug code or logs in production build
- [ ] App performance is acceptable
- [ ] Memory leaks checked
- [ ] Battery usage acceptable

### Business
- [ ] Support email monitored
- [ ] Privacy policy accessible
- [ ] Terms of service accessible
- [ ] User feedback mechanism in place
- [ ] Update strategy planned

---

## Post-Launch Monitoring

### Week 1
- [ ] Monitor crash reports daily
- [ ] Check user reviews
- [ ] Monitor backend errors
- [ ] Check API response times
- [ ] Monitor database performance

### Ongoing
- [ ] Weekly review of analytics
- [ ] Monthly review of user feedback
- [ ] Regular security updates
- [ ] Regular dependency updates
- [ ] Plan feature updates

---

## Useful Commands

```bash
# Backend deployment
cd backend
vercel --prod  # or railway up, or git push

# Android build
cd frontend
flutter clean
flutter pub get
flutter build apk --release --split-per-abi

# App bundle for Play Store
flutter build appbundle --release

# Check app size
flutter build apk --release --analyze-size

# Run in release mode
flutter run --release

# Check for outdated dependencies
flutter pub outdated
```

---

## Quick Reference URLs

- **MongoDB Atlas**: https://cloud.mongodb.com
- **Vercel**: https://vercel.com
- **Railway**: https://railway.app
- **Render**: https://render.com
- **Google Play Console**: https://play.google.com/console
- **Firebase Console**: https://console.firebase.google.com
- **Flutter Docs**: https://docs.flutter.dev
- **Material Design Icons**: https://fonts.google.com/icons

---

**Remember:** 
- Test everything in production environment before launch
- Keep your signing keys and secrets secure
- Have a rollback plan
- Monitor actively in first week after launch
- Respond to user feedback quickly
