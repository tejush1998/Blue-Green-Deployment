import express from 'express'
const app = express();

// Define a route handler for the root URL ("/")
app.get('/', (req, res) => {
  // Send the HTML file as the response
  res.send(`
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Simple HTML Page</title>
    </head>
    <body>
      <h1>Hello, world!</h1>
      <p>This is a <span style="color: blue;">blue</span> deployment.</p>
    </body>
    </html>
  `);
});

// Start the server on port 3000
app.listen(3000, () => {
  console.log('Server is up and running on port 3000');
});
