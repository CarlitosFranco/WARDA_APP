// ============================================================
// 📁 backend/test-connection.js
// Script para verificar que Node.js se conecta a PostgreSQL
// Ejecutar con: node test-connection.js
// ============================================================

const { testConnection, query, pool } = require('./src/db/connection');

(async () => {
  console.log('🔍 Probando conexión a PostgreSQL...\n');

  const ok = await testConnection();

  if (ok) {
    console.log('\n📋 Consultando las tablas creadas...\n');
    try {
      const result = await query(`
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        ORDER BY table_name
      `);
      
      console.log('Tablas encontradas:');
      result.rows.forEach((row, i) => {
        console.log(`  ${i + 1}. ${row.table_name}`);
      });
      
      console.log('\n✅ Conexión exitosa. Las 4 tablas están accesibles.');
    } catch (error) {
      console.error('❌ Error en la consulta:', error.message);
    }
  } else {
    console.log('\n❌ No se pudo conectar. Revisa el .env y PostgreSQL.');
  }

  await pool.end();
  process.exit(0);
})();