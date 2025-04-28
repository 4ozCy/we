const express = require('express');
const fetch = require('node-fetch');
const path = require('path');
const app = express();
const PORT = 8080;

async function fetchText(url, res) {
  try {
    const response = await fetch(url);
    const data = await response.text();
    res.type('text/plain').send(data);
  } catch {
    res.status(500).send('Failed to fetch script.');
  }
}

app.get('/', (req, res) => fetchText('https://raw.githubusercontent.com/4ozCy/Celvyn/refs/heads/main/Main.lua', res));
app.get('/tf', (req, res) => fetchText('https://raw.githubusercontent.com/4ozCy/aa/refs/heads/main/touch%20f1ing-obfuscated.lua', res));
app.get('/aimbot', (req, res) => fetchText('https://pastefy.app/3ChKbVJY/raw', res));
app.get('/tpwalk', (req, res) => fetchText('https://pastebin.com/raw/i5c8a0tv', res));
app.get('/esp', (req, res) => fetchText('https://raw.githubusercontent.com/4ozCy/Celvyn/refs/heads/main/esp.lua', res));

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
