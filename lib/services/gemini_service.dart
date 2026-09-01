import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../data/mock_data.dart';

class GeminiService {
  static bool _apiAvailable = true;
  static bool get apiAvailable => _apiAvailable;
  // ⚠️  Não commite esta chave em repositórios públicos.
  //     Em produção, mova para variáveis de ambiente ou backend próprio.
  //     Execute com: flutter run --dart-define=GCP_API_KEY=sua_chave_aqui
  // Coloque sua chave aqui para não precisar alterar ao rodar o app.
  // (Foi pedido para evitar alteração via código/flags.)
  static const String _apiKey = 'COLOQUE SUA CHAVE API GEMINI AQUI';

  static const _model  = 'gemini-2.0-flash';
  static const _url    =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';

  // ── Prompt de sistema com contexto completo do projeto ──────────────────
  static String _systemPrompt() {
    final p = MockData.paciente;
    final remedios = MockData.remedios()
        .map((r) => '- ${r.nome} (${r.tipo}) às ${r.horario} — ${r.tomado ? "tomado" : "pendente"}')
        .join('\n');

    return '''
Você é o Milo 🐘, assistente de saúde inteligente do aplicativo HumanaCare.

Sua missão é ajudar pacientes idosos, seus familiares e cuidadores no gerenciamento do cuidado domiciliar.
Você tem acesso ao contexto completo do paciente e deve responder de forma empática, clara e objetiva.

══ CONTEXTO DO PACIENTE ══
Nome: ${p.nome}
Idade: ${p.idade} anos
ID: ${p.id}
Data de nascimento: ${p.dataNascimento}
Condição de saúde: ${p.condicaoSaude}
Alergias: ${p.alergias}
Tipo sanguíneo: ${p.tipoSanguineo}
Dispositivos: ${p.dispositivos}
Cuidador principal: ${p.cuidadorNome} (turno ${p.cuidadorTurno}, ${p.cuidadorCarga})

══ MEDICAMENTOS DE HOJE ══
$remedios

══ PRÓXIMO COMPROMISSO ══
${MockData.compromisso.titulo} — ${MockData.compromisso.dia}/${MockData.compromisso.mesAbrev} às ${MockData.compromisso.horario} na ${MockData.compromisso.local}

══ REGRAS DE COMPORTAMENTO ══
- Responda sempre em português brasileiro
- Seja empático, paciente e use linguagem simples (o usuário pode ser idoso)
- Use emojis com moderação para deixar a conversa mais amigável
- Nunca invente informações médicas ou prescreva medicamentos
- Se houver emergência, oriente a usar o botão SOS do app
- Respostas curtas e diretas (máximo 3 parágrafos)
- Se perguntarem sobre remédios, consulte os dados acima
- Assine as mensagens sempre como "Milo 🐘"
''';
  }

  // ── Histórico de mensagens (para manter contexto da conversa) ────────────
  static Future<String> enviarMensagem({
    required String mensagemUsuario,
    required List<Map<String, String>> historico,
  }) async {
    // Valida se a chave de API foi configurada
    if (_apiKey.isEmpty) {
      throw Exception(
        'Chave de API do Gemini não configurada!\n\n'
        'Execute o aplicativo com:\n'
        'flutter run --dart-define=GCP_API_KEY=sua_chave_aqui\n\n'
        'Obtenha a chave em: https://aistudio.google.com/app/apikeys'
      );
    }

    // Monta o array de "contents" com histórico + nova mensagem
    final contents = <Map<String, dynamic>>[];

    // Adiciona histórico anterior
    for (final msg in historico) {
      contents.add({
        'role': msg['role'], // 'user' ou 'model'
        'parts': [{'text': msg['text']}],
      });
    }

    // Adiciona a mensagem atual
    contents.add({
      'role': 'user',
      'parts': [{'text': mensagemUsuario}],
    });

    final body = jsonEncode({
      'system_instruction': {
        'parts': [{'text': _systemPrompt()}],
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 512,
        'topP': 0.9,
      },
      'safetySettings': [
        {'category': 'HARM_CATEGORY_HARASSMENT',        'threshold': 'BLOCK_NONE'},
        {'category': 'HARM_CATEGORY_HATE_SPEECH',       'threshold': 'BLOCK_NONE'},
        {'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'threshold': 'BLOCK_NONE'},
        {'category': 'HARM_CATEGORY_DANGEROUS_CONTENT', 'threshold': 'BLOCK_NONE'},
      ],
    });

    final response = await http.post(
      Uri.parse('$_url?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    ).timeout(const Duration(seconds: 15));

    // Logs para depuração
    try {
      final preview = body.length > 1000 ? body.substring(0, 1000) + '...[truncated]' : body;
      print('[GeminiService] Request body (preview): $preview');
    } catch (_) {}
    print('[GeminiService] Request URL: $_url (key redacted)');

    print('[GeminiService] Response status: ${response.statusCode}');
    print('[GeminiService] Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final texto = _extractTextFromResponse(data);
      print('[GeminiService] Extracted text: ${texto ?? "<null>"}');
      if (texto != null && texto.isNotEmpty) {
        return texto.trim();
      }
      throw Exception('Resposta vazia do Gemini');
    } else {
      if (response.statusCode == 401 || response.statusCode == 403) {
        _apiAvailable = false;
        print('[GeminiService] Gemini API marcada como indisponível. Código ${response.statusCode}');
      }
      throw Exception('Erro ${response.statusCode}: ${response.body}');
    }
  }

  // Tenta extrair o texto do corpo da resposta em diferentes formatos
  static String? _extractTextFromResponse(dynamic data) {
    try {
      if (data == null) return null;

      // 1) candidates -> content (list) -> first -> text OR parts[0].text
      final candidates = data['candidates'];
      if (candidates is List && candidates.isNotEmpty) {
        final c0 = candidates[0];

        // candidates[0].content as List
        final content = c0['content'];
        if (content is List && content.isNotEmpty) {
          final cont0 = content[0];
          if (cont0 is Map) {
            if (cont0['text'] != null) return cont0['text'].toString();
            final parts = cont0['parts'];
            if (parts is List && parts.isNotEmpty && parts[0]['text'] != null) {
              return parts[0]['text'].toString();
            }
          }
        }

        // candidates[0].content as Map with parts
        if (content is Map) {
          final parts = content['parts'];
          if (parts is List && parts.isNotEmpty && parts[0]['text'] != null) {
            return parts[0]['text'].toString();
          }
        }

        // candidates[0].output -> content
        final output = c0['output'];
        if (output is List && output.isNotEmpty) {
          final out0 = output[0];
          final outContent = out0['content'];
          if (outContent is List && outContent.isNotEmpty) {
            final oc0 = outContent[0];
            if (oc0 is Map) {
              if (oc0['text'] != null) return oc0['text'].toString();
              final parts = oc0['parts'];
              if (parts is List && parts.isNotEmpty && parts[0]['text'] != null) {
                return parts[0]['text'].toString();
              }
            }
          }
        }
      }

      // 2) top-level output -> content
      final outputTop = data['output'];
      if (outputTop is List && outputTop.isNotEmpty) {
        final out0 = outputTop[0];
        final outContent = out0['content'];
        if (outContent is List && outContent.isNotEmpty) {
          final oc0 = outContent[0];
          if (oc0 is Map) {
            if (oc0['text'] != null) return oc0['text'].toString();
            final parts = oc0['parts'];
            if (parts is List && parts.isNotEmpty && parts[0]['text'] != null) {
              return parts[0]['text'].toString();
            }
          }
        }
      }

      return null;
    } catch (e, st) {
      print('[GeminiService] _extractTextFromResponse error: $e');
      print(st);
      return null;
    }
  }
}
