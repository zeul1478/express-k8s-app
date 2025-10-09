const express = require("express");
const { Pool } = require("pg");   // PostgreSQL
const Redis = require("ioredis"); // Redis

const app = express();
const PORT = process.env.PORT || 3000;



// --- Database (Postgres) ---
const pool = new Pool({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "postgres",
  password: process.env.DB_PASSWORD || "secret",
  database: process.env.DB_NAME || "mydb",
  port: 5432,
});

// --- Cache (Redis) ---
const redis = new Redis({
  host: process.env.REDIS_HOST || "localhost",
  port: 6379,
});

// Test routes
app.get("/", (req, res) => {
  res.send("🚀 Express app connected to Postgres + Redis!");
});

// Route: write + read from Postgres
app.get("/db", async (req, res) => {
  try {
    // Create table if not exists
    await pool.query("CREATE TABLE IF NOT EXISTS visits (id SERIAL PRIMARY KEY, ts TIMESTAMP DEFAULT NOW())");
    // Insert a new visit
    await pool.query("INSERT INTO visits DEFAULT VALUES");
    // Count visits
    const result = await pool.query("SELECT COUNT(*) FROM visits");
    res.send(`📖 This page has been visited ${result.rows[0].count} times (stored in Postgres).`);
  } catch (err) {
    console.error(err);
    res.status(500).send("❌ Database error");
  }
});

// Route: write + read from Redis
app.get("/cache", async (req, res) => {
  try {
    const count = await redis.incr("counter"); // increases a counter in Redis
    res.send(`⚡ You hit this page ${count} times (stored in Redis).`);
  } catch (err) {
    console.error(err);
    res.status(500).send("❌ Redis error");
  }
});

// Health check route
app.get("/health", (req, res) => {
  res.status(200).send("OK");
});

// Start server
const server = app.listen(PORT, () => {
  console.log(`✅ Server running at http://localhost:${PORT}`);
});

// Handle SIGTERM (graceful shutdown)
process.on("SIGTERM", () => {
  console.log("🚦 SIGTERM received, shutting down gracefully...");

  // Close server
  server.close(() => {
    console.log("✅ All requests finished, server closed.");
    // Exit process
    process.exit(0);
  });
});

// Handle SIGINT (Ctrl+C)
process.on("SIGINT", () => {
  console.log("🛑 SIGINT received (Ctrl+C), shutting down...");
  process.exit(0);
});

// PR validation test
