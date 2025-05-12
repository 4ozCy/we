const express = require('express');
const fetch = require('node-fetch');
const path = require('path');
const fs = require('fs');
const bodyParser = require('body-parser');
const Discord = require('discord.js-selfbot-v13');
const favicon = require('serve-favicon');
const app = express();
const PORT = 8080;

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

app.get('/', (req, res) => text('https://raw.githubusercontent.com/4ozCy/Celvyn/refs/heads/main/Main.lua', res));
app.get('/tf', (req, res) => text('https://raw.githubusercontent.com/4ozCy/aa/refs/heads/main/touch%20f1ing-obfuscated.lua', res));
app.get('/aimbot', (req, res) => text('https://pastefy.app/3ChKbVJY/raw', res));
app.get('/tpwalk', (req, res) => text('https://pastebin.com/raw/i5c8a0tv', res));
app.get('/esp', (req, res) => file(path.join(__dirname, 'esp.lua'), res));
app.get('/ip', (req, res) => res.sendFile(path.join(__dirname, 'gyi.html')));
app.get('/info', (req, res) => res.sendFile(path.join(__dirname, 'userinfo.html')));

app.post('/userinfo-token', async (req, res) => {
  const token = req.body.token;
  if (!token) return res.status(400).json({ error: 'Missing token.' });

  const client = new Discord.Client({ checkUpdate: false });

  client.on('ready', async () => {
    try {
      const user = client.user;
      const friends = client.relationships.cache.filter(r => r.type === 1);
      const nitro = user.premiumType ? ['None', 'Nitro Classic', 'Nitro'][user.premiumType] : 'None';

      const info = {
        username: `${user.username}#${user.discriminator}`,
        id: user.id,
        createdAt: user.createdAt.toDateString(),
        email: user.email || 'Unknown',
        phone: user.phone || 'Unknown',
        avatar: user.displayAvatarURL({ format: 'png', size: 512 }),
        locale: user.locale || 'Unknown',
        verified: user.verified || false,
        mfaEnabled: user.mfaEnabled || false,
        nitro: nitro,
        publicFlags: user.flags?.toArray() || [],
        guilds: client.guilds.cache.size,
        friends: friends.size
      };

      await client.destroy();
      res.json(info);
    } catch {
      res.status(500).json({ error: 'Failed to fetch user data.' });
    }
  });

  client.on('error', () => {
    res.status(401).json({ error: 'Invalid or banned token.' });
  });

  try {
    await client.login(token);
  } catch {
    res.status(401).json({ error: 'Failed to login with provided token.' });
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
