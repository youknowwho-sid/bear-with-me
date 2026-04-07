const http = require('http');
const fs = require('fs');
const path = require('path');
const { WebSocketServer } = require('ws');
const { spawn } = require('child_process');

const PORT = 3500;
const PHRASE = 'bear with me';

const MIME = {
  '.html': 'text/html',
  '.js':   'text/javascript',
  '.css':  'text/css',
  '.png':  'image/png',
  '.jpg':  'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif':  'image/gif',
  '.webm': 'video/webm',
  '.svg':  'image/svg+xml',
};

const server = http.createServer((req, res) => {
  if (req.url === '/trigger' && req.method === 'POST') {
    broadcast('BEAR_TRIGGER');
    res.writeHead(200);
    res.end('ok');
    return;
  }

  let filePath = req.url === '/' ? '/overlay.html' : req.url;
  filePath = filePath.split('?')[0];
  filePath = path.join(__dirname, filePath);

  const ext = path.extname(filePath);
  const contentType = MIME[ext] || 'text/html';

  fs.readFile(filePath, (err, data) => {
    if (err) { res.writeHead(404); res.end('Not found: ' + filePath); return; }
    res.writeHead(200, { 'Content-Type': contentType });
    res.end(data);
  });
});

const wss = new WebSocketServer({ server });
const clients = new Set();

wss.on('connection', (ws) => {
  clients.add(ws);
  console.log('[WS] Overlay connected');
  ws.on('close', () => clients.delete(ws));
});

function broadcast(msg) {
  console.log('[TRIGGER] Sending bear!');
  for (const client of clients) {
    if (client.readyState === 1) client.send(msg);
  }
}

server.listen(PORT, () => {
  console.log('');
  console.log('🐻  Bear Overlay is running!');
  console.log('');
  console.log('   Overlay URL (add this to OBS Browser Source):');
  console.log(`   http://localhost:${PORT}`);
  console.log('');
  console.log(`   Listening for: "${PHRASE.toUpperCase()}"`);
  console.log('');
  console.log('   Manual trigger: open trigger.html in your browser');
  console.log('');
});

function startVoiceDetection() {
  const pyCmd = process.platform === 'win32' ? 'python' : 'python3';
  const py = spawn(pyCmd, [path.join(__dirname, 'voice.py'), PHRASE], {
    stdio: ['ignore', 'pipe', 'pipe']
  });

  py.stdout.on('data', (data) => {
    const line = data.toString().trim();
    if (line === 'TRIGGER') {
      broadcast('BEAR_TRIGGER');
    } else if (line) {
      console.log('[VOICE]', line);
    }
  });

  py.stderr.on('data', (data) => {
    const msg = data.toString().trim();
    if (!msg.includes('ALSA') && !msg.includes('jack') && msg) {
      console.error('[VOICE ERROR]', msg);
    }
  });

  py.on('exit', (code) => {
    if (code !== 0) {
      console.log('⚠️  Voice detection could not start.');
    }
  });
}

startVoiceDetection();
