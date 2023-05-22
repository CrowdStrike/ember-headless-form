import { join, dirname } from 'node:path';
import { createRequire } from 'node:module';

import { getPackages } from '@manypkg/get-packages';
import { findRoot } from '@manypkg/find-root';
import { readJson, pathExists, remove } from 'fs-extra/esm';
import { hardLinkDir } from '@pnpm/fs.hard-link-dir';
import resolvePackagePath from 'resolve-package-path';
import Debug from 'debug';
import lockfile from 'proper-lockfile';
import Watcher from 'watcher';

const require = createRequire(import.meta.url);
const debug = Debug('sync-pnpm');

const syncDir = './dist';

const DEBOUNCE_INTERVAL = 50;

export default async function syncPnpm({ dir = process.cwd(), watchMode = false }) {
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

  let paths = {};

  for (const pkg of packagesToSync) {
    const syncFrom = join(pkg.dir, syncDir);

    const resolvedPackagePath = dirname(
      resolvePackagePath(pkg.packageJson.name, dir)
    );
    const syncTo = join(resolvedPackagePath, syncDir);

    if (await pathExists(syncFrom)) {
      paths[syncFrom] = syncTo;
    }
  }

  if (!watchMode) {
    for (const [syncFrom, syncTo] of Object.entries(paths)) {
      syncDependency(syncFrom, syncTo);
    }

    return;
  }

  let fromPaths = Object.keys(paths);
  let watcher = new Watcher(fromPaths);

  let dirtyPaths = [];

  watcher.on('all', (event, targetPath, targetPathNext) => {
    dirtyPaths.push(targetPath);
  });

  async function handleDirtyPaths() {
    if (dirtyPaths.length) {
      let foundFromPaths = {};
      for (let dirtyPath of dirtyPaths) {
        let path = fromPaths.find((p) => dirtyPath.startsWith(p));
        if (path === undefined) {
          debug(`path not under watched root ${dirtyPath}`);
        } else {
          foundFromPaths[path] = true;
        }
      }
      dirtyPaths = [];

      for (let foundFromPath of Object.keys(foundFromPaths)) {
        await syncDependency(foundFromPath, paths[foundFromPath]);
      }
    }

    setTimeout(handleDirtyPaths, DEBOUNCE_INTERVAL);
  }

  handleDirtyPaths();
}

async function syncDependency(syncFrom, syncTo) {

  let releaseLock;
  try {
    releaseLock = await lockfile.lock(syncTo, { realpath: false });
    debug(`lockfile created for syncing to ${syncTo}`);
  } catch (e) {
    debug(
      `lockfile already exists for syncing to ${syncTo}, some other sync process is already handling this directory, so skipping...`
    );
    return;
  }

  if (await pathExists(syncTo)) {
    await remove(syncTo);
    debug(`removed ${syncTo} before syncing`);
  }

  debug(`syncing from ${syncFrom} to ${syncTo}`);
  await hardLinkDir(syncFrom, [syncTo]);
  releaseLock();
}