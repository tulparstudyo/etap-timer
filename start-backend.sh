#!/bin/bash

echo "📡 Backend başlatılıyor..."
cd backend
node server.js &
BACKEND_PID=$!
cd ..

echo "✅ Backend başlatıldı!"
echo "   Backend API + Web Arayüz: http://localhost:3000"
echo "   Kayıt: http://localhost:3000/register.html"
echo "   Giriş:  http://localhost:3000/login.html"
echo "⏹️  Durdurmak için: kill $BACKEND_PID"

trap "kill $BACKEND_PID; exit" INT
wait
