/* eslint-disable no-console */
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
  AssignedName: string,
};
type data = {
  config: {
    prefix: string
  },
  entries: Array<DbEntry>
}

// const example:DbEntry = {
//   SerialNumber:'5CD9260KRS', // BiosSeralNumber
//   WindowsProductId: '02330-52021-77342-AAOEM', // WindowsProductId
//   CsModel: 'HP ProBook 440 G6', // CsModel
//   CsName: 'DESKTOP-T02RC7R', // CsName
//   ProcessorID: 'BFEBFBFF050806EB', // CsProcessors[0].ProcessorID
// };

const db:data = JSON.parse(fs.readFileSync('./data.json').toString());
// yup, that's totally how databases work, for sure, definitely

app.post('/name', async (req, res) => {
  const client = req.body;
  let number:string = (db.entries.length + 1).toString();
  while (number.length < 3) {
    number = `0${number}`;
  }
  const newEntry:DbEntry = {
    SerialNumber: client.BiosSeralNumber,
    WindowsProductId: client.WindowsProductId,
    CsModel: client.CsModel,
    CsName: client.CsName,
    ProcessorID: client.CsProcessors[0].ProcessorID,
    AssignedName: `${db.config.prefix}${number}`,
  };
  if (db.entries.some(e => e.SerialNumber === client.BiosSeralNumber)) {
    const i = db.entries.findIndex(e => e.SerialNumber === client.BiosSeralNumber);
    console.log('we already have this:', client.BiosSeralNumber, db.entries[i].AssignedName);
    res.send(db.entries[i].AssignedName);
  } else {
    console.log(newEntry);
    db.entries.push(newEntry);
    fs.writeFileSync('./data.json', JSON.stringify(db, null, 2));
    res.send(newEntry.AssignedName);
  }
});

app.listen(port, () => {
  console.log(`Web server active at http://localhost:${port}`);
});