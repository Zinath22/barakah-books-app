@echo off
echo ফোনকে PC এর server এর সাথে যুক্ত করা হচ্ছে...
"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" reverse tcp:5000 tcp:5000
flutter run