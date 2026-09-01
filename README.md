# HumanaCare Paciente

Aplicativo Flutter para gerenciamento de cuidados domiciliares com assistente de saúde alimentado por IA (Gemini).

## 📋 Pré-requisitos

- Flutter SDK (versão 3.0 ou superior)
- Dart SDK
- Chave de API do Google Gemini

## ⚙️ Configuração Inicial

### 1. Obter a Chave de API do Google Gemini

1. Acesse [Google AI Studio](https://aistudio.google.com/app/apikeys)
2. Clique em "Create API Key"
3. Copie a chave gerada

### 2. Configurar a Chave no Projeto

A chave deve ser passada como variável de ambiente ao executar o projeto.

**Abra o arquivo `lib/services/gemini_service.dart` e substitua:**

```dart
static final _apiKey = const String.fromEnvironment('GCP_API_KEY');
```

## 🚀 Como Executar o Projeto

### No Windows/Web:

```bash
flutter pub get
flutter run -d windows --dart-define=GCP_API_KEY=sua_chave_aqui
```

### No Android:

```bash
flutter pub get
flutter run -d android --dart-define=GCP_API_KEY=sua_chave_aqui
```

### No iOS (macOS):

```bash
flutter pub get
flutter run -d ios --dart-define=GCP_API_KEY=sua_chave_aqui
```

### Para Debug Web:

```bash
flutter run -d chrome --dart-define=GCP_API_KEY=sua_chave_aqui
```

**Substitua `sua_chave_aqui` pela chave de API do Gemini obtida anteriormente.**

## 📱 Funcionalidades

- Gerenciamento de informações do paciente
- Histórico de medicamentos
- Assistente de saúde com IA (Milo 🐘)
- Agendamento de compromissos
- Interface intuitiva para idosos e cuidadores

## 📚 Recursos

- [Documentação Flutter](https://docs.flutter.dev/)
- [Google AI Studio](https://aistudio.google.com/)
- [Documentação da API Gemini](https://ai.google.dev/docs)
