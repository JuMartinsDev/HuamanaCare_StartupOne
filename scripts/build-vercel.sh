#!/usr/bin/env bash
set -e

echo "Baixando Flutter..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1

export PATH="$PATH:$(pwd)/flutter/bin"

echo "Versão do Flutter:"
flutter --version

echo "Instalando dependências..."
flutter pub get

echo "Gerando aplicação web..."
flutter build web --release

echo "Build concluído."
