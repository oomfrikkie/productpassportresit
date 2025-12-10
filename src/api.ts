import express from "express";
import mariadb from "mariadb";

const app = express();
const port = process.env.API_PORT || 3001;

// MariaDB connection pool
const pool = mariadb.createPool({
    host: process.env.MARIADB_HOST || "mariadb",
    user: process.env.MARIADB_USER || "admin",
    password: process.env.MARIADB_PASSWORD || "admin",
    database: process.env.MARIADB_DB || "producttracking",
    connectionLimit: 10
});

// GET /events → returns latest 50 events
app.get("/events", async (req, res) => {
    try {
        const conn = await pool.getConnection();
        const rows = await conn.query(
            `SELECT event_id, scanner_id, product_id, material_id, event_type, timestamp
             FROM material_event
             ORDER BY timestamp DESC
             LIMIT 50;`
        );
        conn.release();
        res.json(rows);
    } catch (err) {
        console.error("DB error:", err);
        res.status(500).json({ error: "Database query failed" });
    }
});

app.listen(port, () => {
    console.log(`API running on http://localhost:${port}`);
});
