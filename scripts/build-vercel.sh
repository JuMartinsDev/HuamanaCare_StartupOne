#!/usr/bin/env bash
set -e

echo "Baixando Flutter..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1

export PATH="$PATH:$(pwd)/flutter/bin"

echo "Versão do Flutter:"
flutter --version

echo "Instalando dependências..."
flutter pub get

if [ -z "$GEMINI_API_KEY" ]; then
  echo "ERRO: GEMINI_API_KEY não foi encontrada no ambiente da Vercel."
  exit 1
else
  echo "GEMINI_API_KEY encontrada."
fi

echo "Gerando aplicação web..."
flutter build web --release \
  --dart-define=GEMINI_API_KEY="$GEMINI_API_KEY"

echo "Build concluído."