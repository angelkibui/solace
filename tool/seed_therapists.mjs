import { readFile } from 'node:fs/promises';

const projectId = process.argv[2] ?? 'solace-rwanda';
const accessToken = process.env.FIREBASE_ACCESS_TOKEN;

if (!accessToken) {
  throw new Error('Set FIREBASE_ACCESS_TOKEN before running this script.');
}

const sourceUrl = new URL('./therapists_seed.json', import.meta.url);
const therapists = JSON.parse(await readFile(sourceUrl, 'utf8'));

const stringValue = (value) => ({ stringValue: value });
const stringArray = (values) => ({
  arrayValue: { values: values.map(stringValue) },
});
const timestampArray = (values) => ({
  arrayValue: { values: values.map((value) => ({ timestampValue: value })) },
});

const writes = therapists.map(({ id, ...therapist }) => ({
  update: {
    name: `projects/${projectId}/databases/(default)/documents/therapists/${id}`,
    fields: {
      name: stringValue(therapist.name),
      title: stringValue(therapist.title),
      specialties: stringArray(therapist.specialties),
      languages: stringArray(therapist.languages),
      rate: { integerValue: String(therapist.rate) },
      bio: stringValue(therapist.bio),
      photoUrl: stringValue(therapist.photoUrl),
      rating: { doubleValue: therapist.rating },
      reviewCount: { integerValue: String(therapist.reviewCount) },
      location: stringValue(therapist.location),
      gender: stringValue(therapist.gender),
      providerUid: stringValue(therapist.providerUid),
      availability: timestampArray(therapist.availability),
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

console.log(`Seeded ${therapists.length} therapist profiles in ${projectId}.`);
