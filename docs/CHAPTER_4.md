# CHAPTER FOUR

## SYSTEM IMPLEMENTATION

### 4.1 System Implementation

Implementation is an activity that is contained throughout the development phase. It is a process of bringing out a developed system into operational use and turning it over to the user. The new system and its components are to be tested in a structured and planned manner. In computer science, implementation is the realization of a technical solution or algorithm as a program, software component, or computer system through programming and development.

Implementation is the stage of the system when the theoretical design is turned into a working system. The implementation involves careful planning, investigation of the current system and its constraints on implementing, design methods to achieve the changeover, training of users on procedures, and evaluation of the changeover method.

The main objective of system implementation is to produce a fully developed, functioning, and integrated system in accordance with the functional specifications, ready for testing and acceptance.

The ReportCyber system implementation follows a modern microservices architecture approach, with a clear separation between the frontend mobile application and the backend API server. The implementation process included:

1. **Backend Development**: Setting up the Node.js/Express server with RESTful API endpoints
2. **Database Configuration**: Integrating Firebase for authentication and cloud storage, along with MongoDB for data persistence
3. **Frontend Development**: Building the cross-platform mobile application using Flutter framework
4. **Security Implementation**: Implementing JWT authentication, rate limiting, and data encryption
5. **Testing and Deployment**: Comprehensive testing of all modules and deployment to production environments

### 4.2 Hardware Requirements

The selection of hardware is very important in the existence and working of any system. When selecting hardware, the size and capacity requirements are also very important. Under this section, the minimum requirements and the software specifications are outlined to give a detailed overview of the hardware requirements.

#### 4.2.1 Server Requirements (Backend Hosting)

The hardware requirements for the backend server are:

- **Processor**: Intel Core i5/i7 or AMD Ryzen 5/7 processor running at 2.5 GHz or higher
- **RAM**: Minimum 4GB (8GB recommended for production)
- **Storage**: Minimum 50GB SSD storage for application files, logs, and temporary uploads
- **Network**: Stable internet connection with minimum 100 Mbps bandwidth
- **Operating System**: Linux (Ubuntu 20.04 LTS or higher), Windows Server 2019+, or macOS

#### 4.2.2 Client Requirements (Mobile Devices)

The hardware requirements for end-user devices running the mobile application are:

**Android Devices:**
- **Processor**: Quad-core ARM processor running at 1.5 GHz or higher
- **RAM**: Minimum 2GB (3GB recommended)
- **Storage**: Minimum 100MB free space for application installation
- **Display**: 5.0-inch screen or larger with minimum 720p resolution
- **Operating System**: Android 6.0 (Marshmallow) or higher
- **Camera**: Rear camera with minimum 5MP resolution (for evidence capture)
- **Network**: 3G/4G/5G or Wi-Fi connectivity

**iOS Devices:**
- **Device**: iPhone 7 or newer, iPad (5th generation) or newer
- **RAM**: Minimum 2GB
- **Storage**: Minimum 100MB free space for application installation
- **Operating System**: iOS 12.0 or higher
- **Network**: 3G/4G/5G or Wi-Fi connectivity

#### 4.2.3 Development Environment Requirements

The hardware requirements for development workstations are:

- **Processor**: Intel Core i5/i7 or AMD Ryzen 5/7 processor running at 2.8 GHz or higher
- **RAM**: Minimum 8GB (16GB recommended)
- **Storage**: Minimum 100GB SSD storage
- **Display**: Full HD (1920x1080) or higher resolution
- **Operating System**: Windows 10/11, macOS 10.14+, or Linux (Ubuntu 18.04+)

### 4.3 Software Specifications

The software specifications outline the technologies, frameworks, and tools used in the development and deployment of the ReportCyber system.

#### 4.3.1 Frontend Technologies

- **Framework**: Flutter 3.0+ (Dart SDK ≥3.0.0 <4.0.0)
- **Programming Language**: Dart
- **State Management**: Flutter Bloc (BLoC pattern) v9.1.1
- **Navigation**: GoRouter v17.0.1
- **HTTP Client**: Dio v5.4.0 with Retrofit v4.0.3
- **Local Storage**: 
  - SharedPreferences v2.2.2 for simple key-value storage
  - FlutterSecureStorage v10.0.0 for sensitive data
  - Hive v2.2.3 for local database
- **Authentication**: 
  - Firebase Auth v6.1.3
  - Google Sign-In v7.2.0
- **UI Components**:
  - Flutter SVG v2.0.9
  - CachedNetworkImage v3.3.1
  - Shimmer v3.0.0
  - FlutterSpinkit v5.2.0
- **Forms**: 
  - FlutterFormBuilder v10.2.0
  - FormBuilderValidators v11.2.0

#### 4.3.2 Backend Technologies

- **Runtime Environment**: Node.js v18.x or higher
- **Framework**: Express.js v4.18.2
- **Programming Language**: JavaScript (ES6+)
- **Database**: 
  - MongoDB v8.0.3 (via Mongoose ODM)
  - Firebase Realtime Database/Firestore
- **Authentication & Security**:
  - JSON Web Tokens (jsonwebtoken v9.0.2)
  - bcryptjs v2.4.3 for password hashing
  - Passport.js v0.7.0 (OAuth strategies)
  - Helmet v7.1.0 for security headers
  - express-rate-limit v7.1.5
- **Cloud Services**:
  - Firebase Admin SDK v12.0.0
  - Firebase Storage v13.0.5
- **File Processing**:
  - Multer v1.4.5-lts.1 for file uploads
  - Sharp v0.33.5 for image processing
- **Email Service**: Nodemailer v6.9.7
- **Validation**: 
  - express-validator v7.0.1
  - Validator.js v13.11.0
  - sanitize-html v2.11.0
- **Logging**: Winston v3.11.0
- **Task Queue**: Bull v4.12.0
- **Caching**: Redis v4.6.12
- **Real-time Communication**: Socket.IO v4.6.2
- **Additional Utilities**:
  - Axios v1.13.2 (HTTP client)
  - crypto-js v4.2.0 (encryption)
  - QRCode v1.5.3 (QR code generation)
  - UUID v9.0.1 (unique identifiers)

#### 4.3.3 Development Tools

- **Version Control**: Git
- **Code Repository**: GitHub/GitLab
- **Code Editor**: Visual Studio Code, Android Studio, or IntelliJ IDEA
- **API Testing**: Postman or Insomnia
- **Package Managers**: 
  - npm (Node Package Manager) for backend
  - pub for Flutter/Dart packages
- **Testing Frameworks**:
  - Jest v29.7.0 (backend unit tests)
  - Flutter Test (frontend unit/widget tests)
- **Code Quality**:
  - ESLint v8.56.0 (backend)
  - Dart Analyzer (frontend)

#### 4.3.4 Deployment & DevOps

- **Hosting Platform**: 
  - Vercel (backend API)
  - Firebase Hosting (web version)
- **Mobile App Distribution**:
  - Google Play Store (Android)
  - Apple App Store (iOS)
- **Process Manager**: PM2 or Nodemon (development)
- **Environment Management**: dotenv v16.3.1
- **Compression**: compression v1.7.4

#### 4.3.5 Third-Party Services

- **Authentication**: Firebase Authentication, Google OAuth 2.0, GitHub OAuth
- **Cloud Storage**: Firebase Cloud Storage
- **Database**: MongoDB Atlas (cloud-hosted), Firebase Firestore
- **Email Delivery**: SMTP service (via Nodemailer)
- **URL Safety Verification**: External API integration for phishing detection
- **Analytics**: Firebase Analytics (optional)

#### 4.3.6 Mobile Platform Requirements

**For Android Development:**
- Android SDK 23+ (Android 6.0 Marshmallow)
- Gradle 7.0+
- Kotlin 1.7+ (for native modules if needed)

**For iOS Development:**
- Xcode 13.0+
- CocoaPods 1.11+
- Swift 5.5+ (for native modules if needed)
- iOS deployment target: 12.0+

### 4.4 System Architecture

The ReportCyber system follows a client-server architecture with the following components:

1. **Mobile Client (Flutter)**: Cross-platform application for Android and iOS devices
2. **Backend Server (Node.js/Express)**: RESTful API server handling business logic
3. **Database Layer**: MongoDB for structured data, Firebase for authentication and file storage
4. **Caching Layer**: Redis for session management and performance optimization
5. **Queue System**: Bull for background job processing (email notifications, report processing)
6. **Real-time Communication**: Socket.IO for live notifications and updates

This architecture ensures scalability, maintainability, and optimal performance for the crowdsourced cyber reporting platform.
