const express = require('express');
const fetch = require('node-fetch');
const bodyParser = require('body-parser');
const path = require('path');
const fs = require('fs');
const favicon = require('serve-favicon');
const app = express();
const PORT = 3000;

app.use(bodyParser.json());
app.use(favicon(path.join(__dirname, 'celvyn.png')));

async function text(url, res) {
  try {
    const response = await fetch(url);
    const data = await response.text();
    res.type('text/plain').send(data);
  } catch {
    res.status(500).send('Failed to fetch script.');
  }
}

function file(filePath, res) {
  fs.readFile(filePath, 'utf8', (err, data) => {
    if (err) {
      res.status(500).send('Failed to read local file.');
    } else {
      res.type('text/plain').send(data);
    }
  });
}

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

app.get('/hub', (req, res) => {
  file(path.join(__dirname, 'main.lua'), res);
});

app.get('/tf', (req, res) => {
  text('https://raw.githubusercontent.com/4ozCy/aa/refs/heads/main/touch%20f1ing-obfuscated.lua', res);
});

app.get('/aimbot', (req, res) => {
  text('https://pastefy.app/3ChKbVJY/raw', res);
});

app.get('/tpwalk', (req, res) => {
  text('https://pastebin.com/raw/i5c8a0tv', res);
});

app.get('/esp', (req, res) => {
  file(path.join(__dirname, 'esp.lua'), res);
});

app.get('/tp', (req, res) => {
  file(path.join(__dirname, 'tp.lua'), res);
});

app.get('/ip', (req, res) => {
  res.sendFile(path.join(__dirname, 'gyi.html'));
});

app.get('/:file', (req, res) => {
  const fileName = req.params.file;
  const filePath = path.join(__dirname, fileName);

  res.sendFile(filePath, (err) => {
    if (err) {
      const notFoundPath = path.join(__dirname, '404.html');
      res.status(404).sendFile(notFoundPath);
    }
  });
});

app.listen(PORT, (err) => {
  if (err) {
    console.error('Error in server setup');
  } else {
    console.log(`Server listening on Port ${PORT}`);
  }
});
