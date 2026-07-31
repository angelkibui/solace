import { readFile } from 'node:fs/promises';
import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const serviceAccountPath = process.argv[2];
if (!serviceAccountPath) {
  throw new Error(
    'Usage: node tool/seed_circles_admin.mjs <path-to-serviceAccountKey.json>',
  );
}

const serviceAccount = JSON.parse(await readFile(serviceAccountPath, 'utf8'));
initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore();

const sourceUrl = new URL('./circles_seed.json', import.meta.url);
const circles = JSON.parse(await readFile(sourceUrl, 'utf8'));

const batch = db.batch();
for (const { id, ...circle } of circles) {
  const ref = db.collection('circles').doc(id);
  batch.set(ref, { ...circle, createdAt: new Date() });
}
await batch.commit();

console.log(`Seeded ${circles.length} circles into Firestore.`);