import express from 'express';
import fs from 'fs';

const app = express();
const port = 17346;

app.use(express.json());

type DbEntry = {
  SerialNumber:string,
  WindowsProductId: string,
  CsModel: string,
  CsName: string,
  ProcessorID: string,
};

const example:DbEntry = {
  SerialNumber:'5CD9260KRS', // BiosSerialNumber
  WindowsProductId: '02330-52021-77342-AAOEM', // WindowsProductId
  CsModel: 'HP ProBook 440 G6', // CsModel
  CsName: 'DESKTOP-T02RC7R', // CsName
  ProcessorID: 'BFEBFBFF050806EB', // CsProcessors[0].ProcessorID
};

app.post('/name', async (req, res) => {
  console.log(req.body);
  fs.writeFileSync('./output2.json', JSON.stringify(req.body, null, 2));
  res.send('001');
});

app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log('info', [`Web server active at http://localhost:${port}`]);
});