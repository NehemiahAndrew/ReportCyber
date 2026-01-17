# Quick Deploy Script for ReportCyber

Write-Host "ReportCyber Deployment Helper" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""

$choice = Read-Host "What would you like to do?
1. Create Android platform files
2. Build debug APK
3. Build release APK
4. Deploy backend to Vercel
5. Show deployment status
Enter choice (1-5)"

switch ($choice) {
    "1" {
        Write-Host "`nCreating Android platform files..." -ForegroundColor Yellow
        Set-Location frontend
        flutter create . --platforms=android
        Write-Host "`nAndroid platform files created!" -ForegroundColor Green
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "1. Configure app in android/app/build.gradle"
        Write-Host "2. Add permissions to AndroidManifest.xml"
        Write-Host "See BUILD_APK_GUIDE.md for details"
    }
    "2" {
        Write-Host "`nBuilding debug APK..." -ForegroundColor Yellow
        Set-Location frontend
        flutter clean
        flutter pub get
        flutter build apk --debug
        Write-Host "`nDebug APK built successfully!" -ForegroundColor Green
        Write-Host "Location: frontend\build\app\outputs\flutter-apk\app-debug.apk"
        Write-Host "Install with: adb install build\app\outputs\flutter-apk\app-debug.apk"
    }
    "3" {
        Write-Host "`nBuilding release APK..." -ForegroundColor Yellow
        $signed = Read-Host "Do you have signing keys configured? (y/n)"
        Set-Location frontend
        flutter clean
        flutter pub get
        if ($signed -eq "y") {
            flutter build apk --release --split-per-abi
            Write-Host "`nSigned release APK built!" -ForegroundColor Green
        } else {
            flutter build apk --release
            Write-Host "`nUnsigned release APK built!" -ForegroundColor Yellow
            Write-Host "For a signed APK, see BUILD_APK_GUIDE.md Step 6" -ForegroundColor Cyan
        }
        Write-Host "Location: frontend\build\app\outputs\flutter-apk\"
    }
    "4" {
        Write-Host "`nDeploying backend to Vercel..." -ForegroundColor Yellow
        
        # Check if Vercel CLI is installed
        $vercelInstalled = Get-Command vercel -ErrorAction SilentlyContinue
        if (-not $vercelInstalled) {
            Write-Host "Vercel CLI not found. Installing..." -ForegroundColor Yellow
            npm install -g vercel
        }
        
        Set-Location backend
        Write-Host "`nStarting Vercel deployment..." -ForegroundColor Cyan
        Write-Host "You'll need to:" -ForegroundColor Yellow
        Write-Host "1. Link to your Vercel account"
        Write-Host "2. Configure environment variables"
        Write-Host "3. Set MongoDB URI"
        Write-Host ""
        vercel --prod
        
        Write-Host "`nDeployment initiated!" -ForegroundColor Green
        Write-Host "Don't forget to:" -ForegroundColor Cyan
        Write-Host "1. Add environment variables in Vercel dashboard"
        Write-Host "2. Update API URL in frontend/lib/core/config/app_config.dart"
        Write-Host "See DEPLOYMENT_GUIDE.md for complete instructions"
    }
    "5" {
        Write-Host "`nDeployment Status Check" -ForegroundColor Cyan
        Write-Host "========================" -ForegroundColor Cyan
        
        # Check backend files
        if (Test-Path "backend\vercel.json") {
            Write-Host "✓ Backend Vercel config exists" -ForegroundColor Green
        } else {
            Write-Host "✗ Backend Vercel config missing" -ForegroundColor Red
        }
        
        # Check Android files
        if (Test-Path "frontend\android") {
            Write-Host "✓ Android platform files exist" -ForegroundColor Green
            
            if (Test-Path "frontend\android\key.properties") {
                Write-Host "✓ Release signing configured" -ForegroundColor Green
            } else {
                Write-Host "⚠ Release signing not configured" -ForegroundColor Yellow
            }
        } else {
            Write-Host "✗ Android platform files missing" -ForegroundColor Red
            Write-Host "  Run: flutter create . --platforms=android" -ForegroundColor Yellow
        }
        
        # Check for built APK
        if (Test-Path "frontend\build\app\outputs\flutter-apk\app-release.apk") {
            Write-Host "✓ Release APK exists" -ForegroundColor Green
        } else {
            Write-Host "⚠ No release APK found" -ForegroundColor Yellow
        }
        
        Write-Host "`nFor detailed guides, see:" -ForegroundColor Cyan
        Write-Host "- DEPLOYMENT_GUIDE.md (Backend deployment)"
        Write-Host "- BUILD_APK_GUIDE.md (Android APK building)"
    }
    default {
        Write-Host "Invalid choice. Please run the script again." -ForegroundColor Red
    }
}

Write-Host "`nDone!" -ForegroundColor Green
