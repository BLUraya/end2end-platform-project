const express = require('express');
const app = express();
const port = process.env.PORT || 3000;


const mySecret = process.env.SECRET_WORD || "No secret injected yet";

app.get('/', (req, res) => {
  res.send(`
    <h1>Hello Infinity Labs!!</h1>
    <p>this app is running on EKS and was deployed via GitLab CI.</p>
    <p>The secret injected from Vault is: <strong>${mySecret}</strong></p>
  `);
});


app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

app.listen(port, () => {
  console.log(`Server is listening on port ${port}`);
});