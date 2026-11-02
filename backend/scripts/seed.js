const path = require('node:path');
const { createStrapi } = require('@strapi/strapi');

async function seed() {
  process.env.SKIP_SOCKET_SERVER = 'true';
  const app = await createStrapi({
    appDir: process.cwd(),
    distDir: path.join(process.cwd(), 'dist'),
  }).load();
  try {
    const { seedDatabase } = require('../dist/src/services/seed.js');
    await seedDatabase(app);
    console.info('Smart House seed completed.');
  } finally {
    await app.destroy();
  }
}

seed().catch((error) => {
  console.error('Smart House seed failed:', error);
  process.exitCode = 1;
});
