const express = require("express");
const dotenv = require("dotenv");
const prisma = require("./prisma");

dotenv.config();
const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get("/", (req, res) => {
  res.send("Hello World");
});

app.get("/db-status", async (req, res) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    res.send("Database connection using Prisma is healthy!");
  } catch (error) {
    res.status(500).send("Database connection failed: " + error.message);
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
