# TFS to Git migration

## What it does
- cleanup of huge files (e.g. Github denies > 100Mb and does not recommend >50Mb)
- cleanup of unnecessary files from the history, like per-user settings files, binaries, caches, etc

## Prerequisites
- TFS Team Explorer installed
- git installed and in %PATH%
- Git TFS installed and in %PATH%
- java installed and in %PATH% (used by BFG)
- BFG 1.12.7: https://rtyley.github.io/bfg-repo-cleaner/

## Usage
1. Modify parameters in file: ```config.bat```
2. Run script as: ```migrate.bat > log.txt 2>&1```
