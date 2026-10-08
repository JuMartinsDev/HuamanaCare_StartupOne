
#!/usr/bin/env bash
set -e

# Instala o Flutter no ambiente da Vercel
git clone https://github.com/flutter/flutter.git \
  --depth 1 --branch stable /tmp/flutter

export PATH="/tmp/flutter/bin:$PATH"

# Prepara o Flutter Web
flutter config --enable-web
flutter pub get

# Compila o aplicativo para produção
flutter build web --release
