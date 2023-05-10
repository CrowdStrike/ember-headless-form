import syncPnpm from '../index.js';

let watchMode = process.argv.find((arg) => arg === '--watch') !== undefined;

await syncPnpm({ watchMode });
