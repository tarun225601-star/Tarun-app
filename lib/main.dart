// à¤¯à¤¹ à¤à¤ à¤«à¥à¤²à¤à¤° à¤ªà¥à¤°à¥à¤à¥à¤à¥à¤ à¤¨à¤¹à¥à¤ à¤¹à¥, à¤à¤¸à¤²à¤¿à¤ à¤®à¥à¤à¤¨à¥ à¤à¤ªà¤à¥ à¤à¤¨à¥à¤°à¥à¤§ à¤à¥ à¤à¤¨à¥à¤¸à¤¾à¤° android à¤«à¤¼à¥à¤²à¥à¤¡à¤° à¤¸à¤à¤°à¤à¤¨à¤¾ à¤à¤° à¤à¤µà¤¶à¥à¤¯à¤ à¤«à¤¼à¤¾à¤à¤²à¥à¤ à¤à¤¾ à¤¨à¤¿à¤°à¥à¤®à¤¾à¤£ à¤à¤¿à¤¯à¤¾ à¤¹à¥à¥¤ 
// à¤¨à¤¿à¤®à¥à¤¨à¤²à¤¿à¤à¤¿à¤¤ à¤«à¤¼à¤¾à¤à¤²à¥à¤ à¤à¥ à¤à¤ªà¤¨à¥ à¤«à¥à¤²à¤à¤° à¤ªà¥à¤°à¥à¤à¥à¤à¥à¤ à¤à¥ android à¤«à¤¼à¥à¤²à¥à¤¡à¤° à¤®à¥à¤ à¤¸à¤¹à¥ à¤ªà¤¥ à¤ªà¤° à¤°à¤à¥à¤:

// android/settings.gradle
/*
include ':app'

def localProperties = new File(rootProject.projectDir, "local.properties")
def properties = new Properties()

assert localProperties.exists()
localProperties.withReader("UTF-8") { reader ->
    properties.load(reader)
}

def flutterSdkPath = properties.getProperty('flutter.sdk')
assert flutterSdkPath != null, "Flutter SDK not found. Define location with flutter.sdk in the local.properties file"

apply from: "$flutterSdkPath/packages/flutter_tools/gradle/flutter.gradle"
*/

// android/build.gradle
/*
buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath "com.android.tools.build:gradle:7.2.2"
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.20"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
*/

// android/app/build.gradle
/*
def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file")
}

apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

android {
    compileSdkVersion 33

    defaultConfig {
        applicationId "com.example.vizia_pro"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0"
    }
}

flutter {
    source '../..'
}
*/

// android/app/src/main/AndroidManifest.xml
/*
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.vizia_pro">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <application
        android:label="vizia_pro"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
*/