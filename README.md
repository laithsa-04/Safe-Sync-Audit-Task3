# Safe Sync & Audit Script

## Overview

This Bash script safely processes log files from the `~/Dropzone` directory and moves them to `~/Archive`.

## Features

- Creates `~/Dropzone` if it does not exist.
- Checks whether `~/Dropzone` has write permissions.
- Creates `~/Archive` if it does not exist.
- Moves all `.log` files from Dropzone to Archive.
- Deletes empty (0 byte) `.log` files.
- Prevents accidental overwriting of existing files.
- Adds a timestamp to filenames when a collision occurs.
- Handles filenames containing spaces.
- Calculates the total storage saved in Dropzone.
- Displays a final summary.

## Example

If `error.log` already exists in Archive, the new file is renamed with a timestamp:

```text
error_20260829_231508.log

