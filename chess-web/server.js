const express = require('express');
const path = require('path');

const app = express();
const port = 3002;

// Serve the chessboardjs directory, including images
app.use('/chessboardjs', express.static(path.join(__dirname, 'chessboardjs')));

// Serve the index.html file
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

app.listen(port, () => {
    console.log(`Chess app running at http://localhost:${port}`);
});
