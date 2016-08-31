
@rem
@rem TFS to Git migration
@rem

@rem WHAT IT DOES:
@rem - cleanup of huge files (e.g. Github denies > 100Mb and does not recommend >50Mb)
@rem - cleanup of unnecessary files from the history, like per-user settings files, binaries, caches, etc

@rem PRERERQUISITES:
@rem - TFS Team Explorer installed
@rem - git installed and in %PATH%
@rem - Git TFS installed and in %PATH%
@rem - java installed and in %PATH% (used by BFG)
@rem - BFG 1.12.7: https://rtyley.github.io/bfg-repo-cleaner/

@rem USAGE:
@rem   1) Modify parameters in file: config.bat
@rem   2) Run script as: > migrate.bat > log.txt 2>&1
