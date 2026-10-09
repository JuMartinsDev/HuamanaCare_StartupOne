import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';

class GeminiService {
  static bool _apiAvailable = true;

  static bool get apiAvailable => _apiAvailable;

  // Em produção, a chave do Gemini NÃO fica no Flutter.
  // O app chama /api/gemini e a Vercel usa GEMINI_API_KEY no servidor.
  //
  // Para testar o Flutter local usando o backend já hospedado:
  // flutter run -d chrome \
  //   --dart-define=MILO_API_BASE_URL=https://humanacare.vercel.app
  static const String _apiBaseUrl = String.fromEnvironment(
    'MILO_API_BASE_URL',
    defaultValue: '',
  );

  static Uri get _apiUri {
    if (_apiBaseUrl.trim().isNotEmpty) {
      final base = _apiBaseUrl.endsWith('/')
          ? _apiBaseUrl.substring(0, _apiBaseUrl.length - 1)
          : _apiBaseUrl;

      return Uri.parse('$base/api/gemini');
    }

    return Uri.base.resolve('/api/gemini');
  }

  static String _systemPrompt({
    required Paciente paciente,
    required List<Remedio> remedios,
    required List<Compromisso> compromissos,
  }) {
    final remediosTexto = remedios.isEmpty
        ? 'Nenhum medicamento cadastrado.'
        : remedios
            .map(
              (r) =>
                  '- ${r.nome} (${r.tipo}) às ${r.horario} — '
                  '${r.tomado ? "tomado" : "pendente"}',
            )
            .join('\n');

    final compromissoTexto = compromissos.isEmpty
        ? 'Nenhum compromisso cadastrado.'
        : compromissos
            .map(
              (c) =>
                  '- ${c.titulo} — ${c.dia}/${c.mesAbrev} às '
                  '${c.horario} na ${c.local}',
            )
            .join('\n');

    return '''
Você é o Milo 🐘, assistente de saúde inteligente do aplicativo HumanaCare.

Sua missão é ajudar pacientes idosos, seus familiares e cuidadores no gerenciamento do cuidado domiciliar.
Você tem acesso ao contexto completo do paciente e deve responder de forma empática, clara e objetiva.

══ CONTEXTO DO PACIENTE ══

Nome: ${paciente.nome}

Idade: ${paciente.idade} anos

ID: ${paciente.id}

Data de nascimento: ${paciente.dataNascimento}

Sexo: ${paciente.sexo}

Estado civil: ${paciente.estadoCivil}

Endereço: ${paciente.endereco}

Telefone: ${paciente.telefone}

Condição de saúde: ${paciente.condicaoSaude}

Alergias: ${paciente.alergias}

Tipo sanguíneo: ${paciente.tipoSanguineo}
Dispositivos: ${paciente.dispositivos}

Observações: ${paciente.observacoes}

Cuidador principal: ${paciente.cuidadorNome}

Turno do cuidador: ${paciente.cuidadorTurno}

Carga do cuidador: ${paciente.cuidadorCarga}

══ MEDICAMENTOS ══

$remediosTexto

══ COMPROMISSOS ══

$compromissoTexto

══ REGRAS DE COMPORTAMENTO ══

- Responda sempre em português brasileiro.

- Seja empático, paciente e use linguagem simples.

- Use emojis com moderação para deixar a conversa mais amigável.
- Nunca invente informações médicas ou prescreva medicamentos.

- Se houver emergência, oriente a usar o botão SOS do app.

- Respostas curtas e diretas (máximo 3 parágrafos).

- Se perguntarem sobre remédios, consulte os dados fornecidos acima.

- Se perguntarem sobre compromissos, consulte os dados fornecidos acima.

- Não invente medicamentos ou compromissos que não estejam no contexto.

- Assine as mensagens sempre como "Milo 🐘".
''';
  }

  static Future<String> enviarMensagem({
    required String mensagemUsuario,
    required List<Map<String, String>> historico,
    required Paciente paciente,
    required List<Remedio> remedios,
    required List<Compromisso> compromissos,
  }) async {
    final contents = <Map<String, dynamic>>[];

    for (final msg in historico) {
      final role = msg['role'];
      final text = msg['text'];

      if (role == null || text == null || text.trim().isEmpty) {
        continue;
      }

      contents.add({
        'role': role,
        'parts': [
          {'text': text},
        ],
      });
    }

    contents.add({
      'role': 'user',
      'parts': [
        {'text': mensagemUsuario},
      ],
    });

    final body = jsonEncode({
      'systemPrompt': _systemPrompt(
        paciente: paciente,
        remedios: remedios,
        compromissos: compromissos,
      ),
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 512,
        'topP': 0.9,
      },
    });

    try {
      print('[GeminiService] Chamando backend seguro: $_apiUri');

      final response = await http
          .post(
            _apiUri,
            headers: {
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(
            const Duration(seconds: 20),
          );

      print('[GeminiService] Backend status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final texto = _extractTextFromResponse(data);

        if (texto != null && texto.trim().isNotEmpty) {
          _apiAvailable = true;
          return texto.trim();
        }

        throw Exception('Resposta vazia do Gemini.');
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        _apiAvailable = false;

        throw Exception(
          'O serviço de IA recusou a autenticação. '
          'Código: ${response.statusCode}. '
          'Resposta: ${response.body}',
        );
      }

      if (response.statusCode == 400) {
        throw Exception(
          'Requisição inválida para o assistente. '
          'Resposta: ${response.body}',
        );
      }

      if (response.statusCode == 404) {
        throw Exception(
          'Endpoint do assistente não encontrado. '
          'Código: ${response.statusCode}.',
        );
      }

      if (response.statusCode == 429) {
        throw Exception(
          'Limite de requisições da API do Gemini atingido. '
          'Tente novamente em alguns instantes.',
        );
      }

      throw Exception(
        'Erro ${response.statusCode}: ${response.body}',
      );
    } on http.ClientException catch (e) {
      print('[GeminiService] Erro HTTP: $e');

      throw Exception(
        'Não foi possível conectar ao assistente. '
        'Verifique sua conexão com a internet.',
      );
    } on FormatException catch (e) {
      print('[GeminiService] Erro ao interpretar JSON: $e');

      throw Exception(
        'O assistente retornou uma resposta inesperada.',
      );
    } catch (e, st) {
      print('[GeminiService] Erro: $e');
      print(st);

      rethrow;
    }
  }

  static String? _extractTextFromResponse(
    dynamic data,
  ) {
    try {
      if (data == null) {
        return null;
      }

      final candidates = data['candidates'];

      if (candidates is! List || candidates.isEmpty) {
        print('[GeminiService] Nenhum candidate encontrado.');
        return null;
      }

      final candidate = candidates.first;

      if (candidate is! Map) {
        return null;
      }

      final content = candidate['content'];

      if (content is! Map) {
        return null;
      }

      final parts = content['parts'];

      if (parts is! List || parts.isEmpty) {
        return null;
      }

      final textos = <String>[];

      for (final part in parts) {
        if (part is Map && part['text'] != null) {
          textos.add(part['text'].toString());
        }
      }

      if (textos.isEmpty) {
        return null;
      }

      return textos.join('\n');
    } catch (e, st) {
      print('[GeminiService] Erro ao extrair resposta: $e');
      print(st);
      return null;
    }
  }
}
