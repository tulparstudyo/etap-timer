#!/bin/bash

echo "🚀 Tulpar Kilit Sistemi Başlatılıyor..."
echo ""

# Backend + Frontend aynı portta
echo "📡 Backend başlatılıyor (API + Web Arayüz)..."
cd backend
node server.js &
BACKEND_PID=$!
cd ..

echo ""
echo "✅ Sistem başlatıldı!"
echo ""
echo "📍 Adresler:"
echo "   Backend API + Web Arayüz: http://localhost:3000"
echo "   Kayıt: http://localhost:3000/register.html"
echo "   Giriş:  http://localhost:3000/login.html"
echo ""
echo "🔒 Desktop uygulamasını başlatmak için:"
echo "   cd desktop && python3 tulpar_lock.py"
echo ""
echo "⏹️  Durdurmak için: kill $BACKEND_PID"
echo ""

trap "kill $BACKEND_PID; exit" INT

wait
