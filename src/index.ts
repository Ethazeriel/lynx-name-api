import express from 'express';

const app = express();
const port = 17346;

app.use(express.json());

app.post('/name', async (req, res) => {
  console.log(req.body);
  res.send('name');
});

app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log('info', [`Web server active at http://localhost:${port}`]);
});