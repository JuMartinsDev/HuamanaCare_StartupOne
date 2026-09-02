import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';

class GeminiService {
  static bool _apiAvailable = true;

  static bool get apiAvailable => _apiAvailable;

  // A chave NÃO fica escrita no código.
  //
  // Execute o projeto com:
  // flutter run --dart-define=GEMINI_API_KEY=sua_chave_aqui
  //
  // Nunca coloque a chave diretamente neste arquivo.
  static const String _apiKey =
      String.fromEnvironment('CHAVE API');

  static const String _model = 'gemini-2.5-flash-lite';

  static const String _url =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  // ── Prompt de sistema com contexto real do paciente ────────────────

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

  // ── Envio da mensagem para o Gemini ────────────────────────────────

  static Future<String> enviarMensagem({
    required String mensagemUsuario,
    required List<Map<String, String>> historico,
    required Paciente paciente,
    required List<Remedio> remedios,
    required List<Compromisso> compromissos,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'Chave de API do Gemini não configurada.\n\n'
        'Execute o aplicativo usando --dart-define=GEMINI_API_KEY=...',
      );
    }

    final contents = <Map<String, dynamic>>[];

    for (final msg in historico) {
      contents.add({
        'role': msg['role'],
        'parts': [
          {
            'text': msg['text'],
          },
        ],
      });
    }

    contents.add({
      'role': 'user',
      'parts': [
        {
          'text': mensagemUsuario,
        },
      ],
    });

    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {
            'text': _systemPrompt(
              paciente: paciente,
              remedios: remedios,
              compromissos: compromissos,
            ),
          },
        ],
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 512,
        'topP': 0.9,
      },
    });

    final response = await http
        .post(
          Uri.parse('$_url?key=$_apiKey'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: body,
        )
        .timeout(
          const Duration(seconds: 15),
        );

    // Logs para depuração.
    print('[GeminiService] Model: $_model');
    print('[GeminiService] Response status: ${response.statusCode}');
    print('[GeminiService] Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final texto = _extractTextFromResponse(data);

      print(
        '[GeminiService] Extracted text: ${texto ?? "<null>"}',
      );

      if (texto != null && texto.trim().isNotEmpty) {
        return texto.trim();
      }

      throw Exception('Resposta vazia do Gemini');
    }

    if (response.statusCode == 401 ||
        response.statusCode == 403) {
      _apiAvailable = false;

      throw Exception(
        'Chave da API do Gemini inválida ou sem permissão. '
        'Código: ${response.statusCode}',
      );
    }

    throw Exception(
      'Erro ${response.statusCode}: ${response.body}',
    );
  }

  // ── Extrai o texto da resposta do Gemini ───────────────────────────

  static String? _extractTextFromResponse(
    dynamic data,
  ) {
    try {
      if (data == null) return null;

      final candidates = data['candidates'];

      if (candidates is! List || candidates.isEmpty) {
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
      print(
        '[GeminiService] Erro ao extrair resposta: $e',
      );
      print(st);

      return null;
    }
  }
}