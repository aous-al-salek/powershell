@echo off & setlocal

echo Hello!
powershell -ExecutionPolicy ByPass -Window Minimized -Command ".\Create-NTPServer.ps1"