#!/bin/bash

echo "🔧 Tulpar Kilit Sistemi Kurulumu"
echo "================================"

# Backend kurulumu
echo ""
echo "📦 Backend bağımlılıkları yükleniyor..."
cd backend
npm install
cd ..

# Desktop kurulumu
echo ""
echo "🐍 Desktop uygulaması bağımlılıkları yükleniyor..."
cd desktop

# Sistem paketleri (Pardus/Debian için)
sudo apt-get update
sudo apt-get install -y python3-gi python3-gi-cairo gir1.2-gtk-3.0 python3-pip

pip3 install --break-system-packages -r requirements.txt
cd ..

echo ""
echo "✅ Kurulum tamamlandı!"
echo ""
echo "🚀 Başlatma komutları:"
echo "  Backend: cd backend && npm start"
echo "  Frontend: cd frontend && python3 -m http.server 8080"
echo "  Desktop: cd desktop && python3 tulpar_lock.py"
