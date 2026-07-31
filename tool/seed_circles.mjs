import { readFile } from 'node:fs/promises';

const projectId = process.argv[2] ?? 'solace-rwanda';
const accessToken = process.env.FIREBASE_ACCESS_TOKEN;

if (!accessToken) {
  throw new Error('Set FIREBASE_ACCESS_TOKEN before running this script.');
}

const sourceUrl = new URL('./circles_seed.json', import.meta.url);
const circles = JSON.parse(await readFile(sourceUrl, 'utf8'));

const stringValue = (value) => ({ stringValue: value });
const stringArray = (values) => ({
  arrayValue: { values: values.map(stringValue) },
});

const writes = circles.map(({ id, ...circle }) => ({
  update: {
    name: `projects/${projectId}/databases/(default)/documents/circles/${id}`,
    fields: {
      name: stringValue(circle.name),
      description: stringValue(circle.description),
      category: stringValue(circle.category),
      memberCount: { integerValue: String(circle.memberCount) },
      isModerated: { booleanValue: circle.isModerated },
      moderatorName: stringValue(circle.moderatorName),
      createdAt: { timestampValue: new Date().toISOString() },
      imageUrl: stringValue(circle.imageUrl),
      memberIds: stringArray(circle.memberIds),
    },
  },
}));

const endpoint =
  `https://firestore.googleapis.com/v1/projects/${projectId}` +
  '/databases/(default)/documents:commit';
const response = await fetch(endpoint, {
  method: 'POST',
  headers: {
    authorization: `Bearer ${accessToken}`,
    'content-type': 'application/json',
  },
  body: JSON.stringify({ writes }),
});

if (!response.ok) {
  throw new Error(`Firestore seed failed (${response.status}): ${await response.text()}`);
}

console.log(`Seeded ${circles.length} circles in ${projectId}.`);
