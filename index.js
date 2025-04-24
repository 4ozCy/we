const express = require('express');
const fetch = require('node-fetch');
const path = require('path');
const multer = require('multer');
const crypto = require('crypto');
const mime = require('mime');
const fs = require('fs');
const app = express();
const PORT = 8080;

if (!fs.existsSync('uploads')) fs.mkdirSync('uploads');

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) => {
    const hash = crypto.createHash('sha256').update(file.originalname).digest('hex');
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, `${hash}${ext}`);
  }
});

const fileFilter = (req, file, cb) => {
  const allowed = /jpeg|jpg|png|gif|mp4|mov|avi/;
  const extOk = allowed.test(path.extname(file.originalname).toLowerCase());
  const mimeOk = allowed.test(file.mimetype);
  cb(null, extOk && mimeOk);
};

const upload = multer({
  storage,
  limits: { fileSize: 100 * 1024 * 1024 },
  fileFilter
});

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
app.get('/esp', (req, res) => fetchText('https://pastefy.app/lgzQL4sX/raw', res));
app.get('/a', (req, res) => res.sendFile(path.join(__dirname, 'upload.html')));

app.post('/b', upload.single('file'), (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'No file uploaded' });
  const fileUrl = `https://celvyn.site/${encodeURIComponent(req.file.filename)}`;
  res.json({ message: 'File uploaded successfully', url: fileUrl });
});

app.get('/:filename', (req, res) => {
  const filePath = path.join(__dirname, 'uploads', req.params.filename);
  if (fs.existsSync(filePath)) {
    const type = mime.getType(filePath);
    res.setHeader('Content-Type', type);
    res.sendFile(filePath);
  } else {
    res.status(404).json({ error: 'File not found' });
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
