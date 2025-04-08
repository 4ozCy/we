const express = require('express');
const fetch = require('node-fetch');
const app = express();
const PORT = 3000;

async function fetchText(url, res) {
  try {
    const response = await fetch(url);
    const data = await response.text();
    res.type('text/plain').send(data);
  } catch {
    res.status(500).send('Failed to fetch script.');
  }
}

app.get('/', (req, res) => {
  fetchText('https://raw.githubusercontent.com/4ozCy/Celvyn/refs/heads/main/Main.lua', res);
});

app.get('/tf', (req, res) => {
  fetchText('https://raw.githubusercontent.com/4ozCy/aa/refs/heads/main/touch%20f1ing-obfuscated.lua', res);
});

app.get('/aimbot', (req, res) => {
  fetchText('https://pastebin.com/raw/QE0GzMDq', res);
});

app.get('/tpwalk', (req, res) => {
  fetchText('https://pastebin.com/raw/i5c8a0tv', res);
});

app.get('/esp', (req, res) => {
  fetchText('https://pastebin.com/raw/Hsvmj2mw', res);
});

app.get('/fps', (req, res) => {
  fetchText('https://pastebin.com/raw/M5ASu6cf', res);
});

app.get('/tp', (req, res) => {
  fetchText('https://pastebin.com/raw/XSmS9zZQ', res);
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
