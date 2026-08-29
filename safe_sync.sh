#!/bin/bash

# ==========================================
# Safe Sync & Audit Script
# ==========================================

DROPZONE="$HOME/Dropzone"
ARCHIVE="$HOME/Archive"

# Counters
moved_count=0
deleted_count=0
saved_bytes=0

echo "=========================================="
echo "       SAFE SYNC & AUDIT SCRIPT"
echo "=========================================="

# ==========================================
# 1. Check / Create Dropzone
# ==========================================

if [ ! -d "$DROPZONE" ]; then
    echo "Dropzone does not exist."
    echo "Creating: $DROPZONE"

    if ! mkdir -p "$DROPZONE"; then
        echo "ERROR: Could not create Dropzone."
        exit 1
    fi

    echo "Dropzone created successfully."
fi

# Check write permission
if [ ! -w "$DROPZONE" ]; then
    echo "ERROR: Dropzone is not writable."
    echo "Path: $DROPZONE"
    exit 2
fi

echo "Dropzone is ready."

# ==========================================
# 2. Check / Create Archive
# ==========================================

if [ ! -d "$ARCHIVE" ]; then
    echo "Archive does not exist."
    echo "Creating: $ARCHIVE"

    if ! mkdir -p "$ARCHIVE"; then
        echo "ERROR: Could not create Archive."
        exit 3
    fi

    echo "Archive created successfully."
fi

# ==========================================
# 3. Process .log files
# ==========================================

echo
echo "Processing .log files..."
echo "------------------------------------------"

while IFS= read -r -d '' file; do

    filename=$(basename "$file")

    # Get file size in bytes
    filesize=$(stat -c%s "$file")

    # ======================================
    # Empty file
    # ======================================

    if [ "$filesize" -eq 0 ]; then

        echo "EMPTY: $filename"
        echo "       Deleting..."

        if rm -- "$file"; then
            echo "       Deleted successfully."
            deleted_count=$((deleted_count + 1))
        else
            echo "ERROR: Could not delete $filename"
        fi

        echo
        continue
    fi

    # ======================================
    # Normal file
    # ======================================

    destination="$ARCHIVE/$filename"

    # ======================================
    # Collision handling
    # ======================================

    if [ -e "$destination" ]; then

        base="${filename%.log}"
        timestamp=$(date +"%Y%m%d_%H%M%S")

        destination="$ARCHIVE/${base}_${timestamp}.log"

        counter=1

        while [ -e "$destination" ]; do
            destination="$ARCHIVE/${base}_${timestamp}_${counter}.log"
            counter=$((counter + 1))
        done

        echo "COLLISION: $filename"
        echo "           Existing file found."
        echo "           New name: $(basename "$destination")"

    fi

    # ======================================
    # Move file
    # ======================================

    echo "MOVING: $filename"

    if mv -- "$file" "$destination"; then

        echo "       Archived successfully."

        moved_count=$((moved_count + 1))
        saved_bytes=$((saved_bytes + filesize))

    else

        echo "ERROR: Could not move $filename"

    fi

    echo

done < <(find "$DROPZONE" -maxdepth 1 -type f -name "*.log" -print0)

# ==========================================
# 4. Storage Calculation
# ==========================================

if command -v numfmt >/dev/null 2>&1; then
    saved_human=$(numfmt --to=iec "$saved_bytes")
else
    saved_human="$saved_bytes bytes"
fi

# ==========================================
# 5. Final Summary
# ==========================================

echo "=========================================="
echo "              FINAL SUMMARY"
echo "=========================================="
echo "Files archived       : $moved_count"
echo "Empty files deleted  : $deleted_count"
echo "Storage saved        : $saved_human"
echo "Dropzone             : $DROPZONE"
echo "Archive              : $ARCHIVE"
echo "=========================================="

exit 0
