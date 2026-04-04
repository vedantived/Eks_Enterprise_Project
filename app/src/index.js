const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.json({
    message: "EKS Zero Trust App Running",
    status: "success"
  });
});

app.listen(3000, () => {
  console.log("Server running on port 3000");
});

console.log(JSON.stringify({
  level: "info",
  message: "Server started",
  service: "node-app",
  env: "prod",
  timestamp: new Date().toISOString()
}));

console.log(JSON.stringify({
  level: "error",
  message: "SNS TEST ERROR",
  service: "EKS-Project"
}));
