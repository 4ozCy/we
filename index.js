const express = require('express');
const axios = require('axios');
const app = express();
const PORT = 3000;

app.get('/', async (req, res) => {
  try {
    const response = await axios.get('https://raw.githubusercontent.com/4ozCy/Celvyn/refs/heads/main/Main.lua');
    res.type('text/plain').send(response.data);
  } catch {
    res.status(500).send('Failed to fetch script.');
  }
});

app.get('/tf', async (req, res) => {
  try {
    const response = await axios.get('https://raw.githubusercontent.com/4ozCy/aa/refs/heads/main/touch%20f1ing-obfuscated.lua');
    res.type('text/plain').send(response.data);
  } catch {
    res.status(500).send('Failed to fetch script.');
  }
});

app.get('/aimbot', async (req, res) => {
  try {
    const response = await axios.get('https://pastebin.com/raw/QE0GzMDq');
    res.type('text/plain').send(response.data);
  } catch {
    res.status(500).send('Failed to fetch script.');
  }
});

app.get('/tpwalk', async (req, res) => {
  try {
    const response = await axios.get('https://pastebin.com/raw/i5c8a0tv');
    res.type('text/plain').send(response.data);
  } catch {
    res.status(500).send('Failed to fetch script.');
  }
});

app.get('/esp', async (req, res) => {
  try {
    const response = await axios.get('https://pastebin.com/raw/Hsvmj2mw');
    res.type('text/plain').send(response.data);
  } catch {
    res.status(500).send('Failed to fetch script.');
  }
});

app.get('/fps', async (req, res) => {
  try {
    const response = await axios.get('https://pastebin.com/raw/M5ASu6cf');
    res.type('text/plain').send(response.data);
  } catch {
    res.status(500).send('Failed to fetch script.');
  }
});

app.get('/tp', async (req, res) => {
  try {
    const response = await axios.get('https://pastebin.com/raw/XSmS9zZQ');
    res.type('text/plain').send(response.data);
  } catch {
    res.status(500).send('Failed to fetch script.');
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
