@echo off
setlocal
cd /d "%~dp0"
title iHub Marketplace - Local Setup
where node >nul 2>nul
if errorlevel 1 (
  echo Node.js is not installed or is not on PATH.
  echo Install Node.js 20.9 or newer from https://nodejs.org/ then restart this window.
  pause
  exit /b 1
)
if not exist .env.local (
  copy .env.example .env.local >nul
  echo Created .env.local from .env.example.
)
echo.
echo STEP 1: Open .env.local and enter your Supabase project URL and anon/publishable key.
notepad .env.local
echo.
echo STEP 2: Install project dependencies. This requires internet access.
call npm install
if errorlevel 1 (
  echo Dependency installation failed. Check your internet connection and npm output.
  pause
  exit /b 1
)
echo.
echo STEP 3: Run the development server.
echo Open http://localhost:3000 after Next.js starts.
call npm run dev
pause
