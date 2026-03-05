const express = require('express');
const cors = require('cors');
const path = require('path');
const app = express();

app.use(cors());

// Serve static compiled UI files
app.use(express.static(path.join(__dirname, 'build/web'), {
    setHeaders: (res, path) => {
        res.setHeader('Cross-Origin-Opener-Policy', 'same-origin');
        res.setHeader('Cross-Origin-Embedder-Policy', 'credentialless');
        res.setHeader('Cache-Control', 'no-store');
    }
}));

// Mock backend API for the screenshot script
app.post('/api/auth/login', (req, res) => {
    setTimeout(() => res.json({ success: true, data: { token: 'mock', user: { id: 1, username: 'Demo User', email: 'demo@trustos.app', trust_score: 850 } } }), 50);
});
app.post('/api/auth/register', (req, res) => {
    setTimeout(() => res.json({ success: true, data: { token: 'mock', user: { id: 1, username: 'Demo User', email: 'demo@trustos.app', trust_score: 850 } } }), 50);
});
app.get('/api/trust-score', (req, res) => res.json({ success: true, data: { score: 850, last_updated: new Date().toISOString() } }));
app.get('/api/requests', (req, res) => res.json({ success: true, data: [] }));
app.get('/api/network', (req, res) => res.json({ success: true, data: [] }));
app.get('/api/alerts', (req, res) => res.json({ success: true, data: [] }));

app.use((req, res) => {
    res.sendFile(path.join(__dirname, 'build/web/index.html'));
});

app.listen(5000, () => console.log('Node Server running on port 5000'));
