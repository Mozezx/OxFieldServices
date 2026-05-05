#!/bin/sh
set -e

echo "Running migrations..."
npx prisma migrate deploy

echo "Starting OX API..."
node dist/main.js
