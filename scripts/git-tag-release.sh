#!/usr/bin/env bash
# Create and push an annotated release tag, then trigger CI
set -euo pipefail

VERSION="${1:?Usage: $0 <version>  e.g. 1.4.2}"
REMOTE="${2:-origin}"

# Validate semver-ish
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$ ]]; then
  echo "Version '$VERSION' doesn't look like semver (X.Y.Z or X.Y.Z-suffix)." >&2
  exit 1
fi

TAG="v$VERSION"

echo "Creating annotated tag $TAG on $(git rev-parse --short HEAD)..."
git tag -a "$TAG" -m "Release $TAG"

echo "Pushing tag to $REMOTE..."
git push "$REMOTE" "$TAG"

echo "Tag $TAG pushed. CI should pick it up."
