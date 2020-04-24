const WS  = require('ws');

const wss = new WS.Server({
  port: 8080,
  path: '/echo'
});

wss.on('connection', (ws) => {
  ws.send('what șup bitch');
  ws.on('message', (message) => {
    console.log("--------------------------------------------------")
    console.log(message);
    ws.send(message);
    console.log("--------------------------------------------------");
  });
});
