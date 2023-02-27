import { join, dirname } from 'node:path';
import { createRequire } from 'node:module';

import { getPackages } from '@manypkg/get-packages';
import { findRoot } from '@manypkg/find-root';
import { readJson, pathExists, remove } from 'fs-extra/esm';
import { hardLinkDir } from '@pnpm/fs.hard-link-dir';
import resolvePackagePath from 'resolve-package-path';
import Debug from 'debug';

const require = createRequire(import.meta.url);
const debug = Debug('sync-pnpm');

const syncDir = './dist';

export default async function syncPnpm(dir = process.cwd()) {
  const root = await findRoot(dir);
  const ownPackageJson = await readJson(join(dir, 'package.json'));
  const ownDependencies = [
    ...Object.keys(ownPackageJson.dependencies ?? {}),
    ...Object.keys(ownPackageJson.devDependencies ?? {}),
  ];

  const localPackages = (await getPackages(root.rootDir)).packages;

  const packagesToSync = localPackages.filter(
    (p) =>
      p.packageJson.name !== 'sync-pnpm' &&
      ownDependencies.includes(p.packageJson.name)
  );

  for (const pkg of packagesToSync) {
    const syncFrom = join(pkg.dir, syncDir);
    const resolvedPackagePath = dirname(
      resolvePackagePath(pkg.packageJson.name, dir)
    );
    const syncTo = join(resolvedPackagePath, syncDir);

    if (await pathExists(syncFrom)) {
      if (await pathExists(syncTo)) {
        await remove(syncTo);
        debug(`removed ${syncTo} before syncing`);
      }

      debug(`syncing from ${syncFrom} to ${syncTo}`);
      await hardLinkDir(syncFrom, [syncTo]);
    }
  }
}
