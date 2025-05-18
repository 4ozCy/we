const express = require('express');
const fetch = require('node-fetch');
const path = require('path');
const fs = require('fs');
const favicon = require('serve-favicon');

const app = express();
const PORT = 8080;

app.use(express.json());
app.use(favicon(path.join(__dirname, 'celvyn.png')));

async function fetchAndProcessScript(url, scriptName, res) {
  try {
    const response = await fetch(url);
    const script = await response.text();
    console.log(`[${scriptName}] Script fetched:`, script.slice(0, 100));
    res.send(`${scriptName} script fetched and processed on the server.`);
  } catch (err) {
    console.error(`Error fetching ${scriptName}:`, err.message);
    res.status(500).send(`Failed to process ${scriptName} script.`);
  }
}

function readAndProcessLocalFile(filePath, scriptName, res) {
  fs.readFile(filePath, 'utf8', (err, data) => {
    if (err) {
      console.error(`Error reading ${scriptName}:`, err.message);
      res.status(500).send(`Failed to read local ${scriptName}.`);
    } else {
      console.log(`[${scriptName}] Local script read:`, data.slice(0, 100));
      res.send(`${scriptName} script read and processed on the server.`);
    }
  });
}

app.get('/', (req, res) => fetchAndProcessScript('https://raw.githubusercontent.com/4ozCy/Celvyn/refs/heads/main/Main.lua', 'Main', res));
app.get('/tf', (req, res) => fetchAndProcessScript('https://raw.githubusercontent.com/4ozCy/aa/refs/heads/main/touch%20f1ing-obfuscated.lua', 'TouchF1', res));
app.get('/aimbot', (req, res) => fetchAndProcessScript('https://pastefy.app/3ChKbVJY/raw', 'Aimbot', res));
app.get('/tpwalk', (req, res) => fetchAndProcessScript('https://pastebin.com/raw/i5c8a0tv', 'TPWalk', res));
app.get('/esp', (req, res) => readAndProcessLocalFile(path.join(__dirname, 'esp.lua'), 'ESP', res));
app.get('/ip', (req, res) => res.sendFile(path.join(__dirname, 'gyi.html')));

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
