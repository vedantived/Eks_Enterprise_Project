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