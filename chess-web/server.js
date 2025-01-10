const express = require('express');
const path = require('path');
const mime = require('mime-types'); // Ensure you install mime with `npm install mime`

const app = express();
const port = 3003;

// Serve the chessboardai directory, including images, with MIME type correction for CSS files
app.use('/chessboardai', express.static(path.join(__dirname, 'chessboardai'), {
    setHeaders: (res, filePath) => {
        // Check if the file is a CSS file and set the correct Content-Type
        if (mime.lookup(filePath) === 'text/css') {
            // Your code here        
            res.setHeader('Content-Type', 'text/css');
        }
    }
}));

// Serve the index.html file
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// Start the server
app.listen(port, () => {
    console.log(`Chess app running at http://localhost:${port}`);
});
