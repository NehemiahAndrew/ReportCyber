# Quick Deployment and APK Build Script

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ReportCyber Deployment & Build Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if a command exists
function Test-Command($command) {
    try {
        if (Get-Command $command -ErrorAction Stop) {
            return $true
        }
    }
    catch {
        return $false
    }
}

# Step 1: Check prerequisites
Write-Host "[1/6] Checking prerequisites..." -ForegroundColor Yellow

if (-not (Test-Command "flutter")) {
    Write-Host "❌ Flutter is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Flutter from https://flutter.dev/docs/get-started/install" -ForegroundColor Red
    exit 1
}

if (-not (Test-Command "vercel")) {
    Write-Host "⚠️  Vercel CLI not installed" -ForegroundColor Yellow
    Write-Host "Installing Vercel CLI..." -ForegroundColor Yellow
    npm install -g vercel
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to install Vercel CLI" -ForegroundColor Red
        Write-Host "Please run: npm install -g vercel" -ForegroundColor Yellow
        $skipVercel = $true
    }
}

Write-Host "✅ Prerequisites checked" -ForegroundColor Green
Write-Host ""

# Step 2: Ask user what they want to do
Write-Host "[2/6] What would you like to do?" -ForegroundColor Yellow
Write-Host "1. Deploy backend to Vercel only" -ForegroundColor White
Write-Host "2. Build Flutter APK only" -ForegroundColor White
Write-Host "3. Both (Deploy backend + Build APK)" -ForegroundColor White
Write-Host ""
$choice = Read-Host "Enter your choice (1, 2, or 3)"

# Step 3: Deploy to Vercel
if ($choice -eq "1" -or $choice -eq "3") {
    if (-not $skipVercel) {
        Write-Host ""
        Write-Host "[3/6] Deploying backend to Vercel..." -ForegroundColor Yellow
        
        Set-Location backend
        
        Write-Host "Logging in to Vercel..." -ForegroundColor Cyan
        vercel login
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "Deploying to production..." -ForegroundColor Cyan
            vercel --prod
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Backend deployed successfully!" -ForegroundColor Green
                Write-Host ""
                Write-Host "⚠️  IMPORTANT: Don't forget to:" -ForegroundColor Yellow
                Write-Host "1. Add environment variables in Vercel dashboard" -ForegroundColor White
                Write-Host "2. Copy your deployment URL" -ForegroundColor White
                Write-Host "3. Update VERCEL_URL.txt with your actual URL" -ForegroundColor White
                Write-Host ""
                
                # Prompt for Vercel URL
                $vercelUrl = Read-Host "Enter your Vercel deployment URL (e.g., https://reportcyber-backend-xxx.vercel.app)"
                if ($vercelUrl) {
                    $vercelUrl | Out-File -FilePath "../VERCEL_URL.txt" -Encoding UTF8
                    Write-Host "✅ Saved Vercel URL to VERCEL_URL.txt" -ForegroundColor Green
                }
            } else {
                Write-Host "❌ Deployment failed" -ForegroundColor Red
                Set-Location ..
                exit 1
            }
        } else {
            Write-Host "❌ Vercel login failed" -ForegroundColor Red
            Set-Location ..
            exit 1
        }
        
        Set-Location ..
    } else {
        Write-Host "⚠️  Skipping Vercel deployment (CLI not available)" -ForegroundColor Yellow
    }
} else {
    Write-Host "[3/6] Skipping Vercel deployment" -ForegroundColor Gray
}

# Step 4: Update Flutter API configuration
if ($choice -eq "2" -or $choice -eq "3") {
    Write-Host ""
    Write-Host "[4/6] Configuring Flutter app..." -ForegroundColor Yellow
    
    # Check if VERCEL_URL.txt exists
    if (Test-Path "VERCEL_URL.txt") {
        $backendUrl = Get-Content "VERCEL_URL.txt" -Raw
        $backendUrl = $backendUrl.Trim()
        
        if ($backendUrl) {
            Write-Host "Found backend URL: $backendUrl" -ForegroundColor Cyan
            
            # Update app_config.dart
            $configPath = "frontend\lib\core\config\app_config.dart"
            $config = Get-Content $configPath -Raw
            
            $newConfig = $config -replace "static const String prodBaseUrl =\s*'.*?';", 
                "static const String prodBaseUrl = '$backendUrl/api/v1';"
            
            $newConfig | Out-File -FilePath $configPath -Encoding UTF8 -NoNewline
            
            Write-Host "✅ Updated API configuration" -ForegroundColor Green
        }
    } else {
        Write-Host "⚠️  VERCEL_URL.txt not found" -ForegroundColor Yellow
        Write-Host "Please update frontend/lib/core/config/app_config.dart manually" -ForegroundColor Yellow
    }
    
    # Step 5: Create Android folder if it doesn't exist
    Write-Host ""
    Write-Host "[5/6] Preparing Android build..." -ForegroundColor Yellow
    
    Set-Location frontend
    
    if (-not (Test-Path "android")) {
        Write-Host "Creating Android platform files..." -ForegroundColor Cyan
        flutter create . --platforms=android
    } else {
        Write-Host "✅ Android folder exists" -ForegroundColor Green
    }
    
    # Clean and get dependencies
    Write-Host "Cleaning and getting dependencies..." -ForegroundColor Cyan
    flutter clean
    flutter pub get
    
    # Step 6: Build APK
    Write-Host ""
    Write-Host "[6/6] Building APK..." -ForegroundColor Yellow
    Write-Host "This may take several minutes..." -ForegroundColor Cyan
    Write-Host ""
    
    # Ask user which build type
    Write-Host "Select build type:" -ForegroundColor Yellow
    Write-Host "1. Debug APK (faster, for testing)" -ForegroundColor White
    Write-Host "2. Release APK (optimized, for distribution)" -ForegroundColor White
    $buildType = Read-Host "Enter your choice (1 or 2)"
    
    if ($buildType -eq "2") {
        Write-Host "Building Release APK..." -ForegroundColor Cyan
        flutter build apk --release
        $apkPath = "build\app\outputs\flutter-apk\app-release.apk"
        $buildTypeStr = "Release"
    } else {
        Write-Host "Building Debug APK..." -ForegroundColor Cyan
        flutter build apk --debug
        $apkPath = "build\app\outputs\flutter-apk\app-debug.apk"
        $buildTypeStr = "Debug"
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "  ✅ BUILD SUCCESSFUL!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "APK Location:" -ForegroundColor Yellow
        Write-Host "$apkPath" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Full Path:" -ForegroundColor Yellow
        Write-Host "$(Get-Location)\$apkPath" -ForegroundColor Cyan
        Write-Host ""
        
        # Copy APK to root folder for easy access
        $outputName = "ReportCyber-$buildTypeStr-$(Get-Date -Format 'yyyyMMdd').apk"
        Copy-Item $apkPath -Destination "..\$outputName"
        Write-Host "APK also copied to:" -ForegroundColor Yellow
        Write-Host "$(Split-Path (Get-Location) -Parent)\$outputName" -ForegroundColor Cyan
        Write-Host ""
        
        Write-Host "Next Steps:" -ForegroundColor Yellow
        Write-Host "1. Transfer APK to your Android device" -ForegroundColor White
        Write-Host "2. Enable 'Install from Unknown Sources' in Android settings" -ForegroundColor White
        Write-Host "3. Install and test the app" -ForegroundColor White
        Write-Host ""
        
        # Ask if user wants to install on connected device
        Write-Host "Do you have an Android device connected via USB? (Y/N)" -ForegroundColor Yellow
        $installNow = Read-Host
        
        if ($installNow -eq "Y" -or $installNow -eq "y") {
            Write-Host "Installing on device..." -ForegroundColor Cyan
            flutter install
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ App installed on device!" -ForegroundColor Green
            } else {
                Write-Host "❌ Installation failed. Please install manually." -ForegroundColor Red
            }
        }
    } else {
        Write-Host ""
        Write-Host "❌ Build failed!" -ForegroundColor Red
        Write-Host "Please check the error messages above." -ForegroundColor Red
        Set-Location ..
        exit 1
    }
    
    Set-Location ..
} else {
    Write-Host "[4/6] Skipping Flutter build" -ForegroundColor Gray
    Write-Host "[5/6] Skipping Flutter build" -ForegroundColor Gray
    Write-Host "[6/6] Skipping Flutter build" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  🎉 All tasks completed!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "For more information:" -ForegroundColor Yellow
Write-Host "- Backend deployment: See VERCEL_DEPLOYMENT.md" -ForegroundColor White
Write-Host "- APK building: See BUILD_APK_GUIDE.md" -ForegroundColor White
Write-Host ""
