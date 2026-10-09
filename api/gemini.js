const MODEL = 'gemini-3.5-flash-lite';
const GEMINI_URL =
  `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent`;

function setCors(req, res) {
  const origin = req.headers.origin || '';
  const allowed =
    !origin ||
    origin === 'https://humanacare.vercel.app' ||
    /^https:\/\/.*\.vercel\.app$/.test(origin) ||
    /^http:\/\/localhost:\d+$/.test(origin) ||
    /^http:\/\/127\.0\.0\.1:\d+$/.test(origin);

  if (!allowed) return false;

  if (origin) {
    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Vary', 'Origin');
  }

  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  return true;
}

export default async function handler(req, res) {
  if (!setCors(req, res)) {
    return res.status(403).json({ error: 'Origem não permitida.' });
  }

  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }

  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST, OPTIONS');
    return res.status(405).json({ error: 'Método não permitido.' });
  }

  const apiKey = process.env.GEMINI_API_KEY;

  if (!apiKey) {
    console.error('[Milo API] GEMINI_API_KEY ausente no ambiente da Vercel.');
    return res.status(500).json({
      error: 'Configuração do assistente indisponível.',
    });
  }

  try {
    const body = req.body ?? {};
    const { systemPrompt, contents, generationConfig } = body;

    if (typeof systemPrompt !== 'string' || systemPrompt.trim().length === 0) {
      return res.status(400).json({ error: 'systemPrompt inválido.' });
    }

    if (!Array.isArray(contents) || contents.length === 0) {
      return res.status(400).json({ error: 'contents inválido.' });
    }

    const serializedSize = JSON.stringify(body).length;
    if (serializedSize > 100_000) {
      return res.status(413).json({ error: 'Requisição muito grande.' });
    }

    const geminiResponse = await fetch(GEMINI_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: JSON.stringify({
        system_instruction: {
          parts: [{ text: systemPrompt }],
        },
        contents,
        generationConfig: generationConfig ?? {
          temperature: 0.7,
          maxOutputTokens: 512,
          topP: 0.9,
        },
      }),
    });

    const raw = await geminiResponse.text();

    let data;
    try {
      data = JSON.parse(raw);
    } catch {
      data = { error: raw || 'Resposta inválida do Gemini.' };
    }

    if (!geminiResponse.ok) {
      console.error(`[Milo API] Gemini respondeu ${geminiResponse.status}.`);
    }

    return res.status(geminiResponse.status).json(data);
  } catch (error) {
    console.error('[Milo API] Falha ao chamar o Gemini:', error);
    return res.status(502).json({
      error: 'Não foi possível conectar ao serviço de IA.',
    });
  }
}
