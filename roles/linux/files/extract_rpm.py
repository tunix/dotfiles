#!/usr/bin/env python3
"""Extract a single file from an RPM without rpm2cpio/cpio.

Usage: extract_rpm.py <rpm_path> <member_path> <dest_path>

Uses only the Python 3 standard library: decompresses the cpio payload
(gzip/xz/zstd-free) and parses the NEWC cpio archive to write out the
requested member. Enables installing user-level tools from RPMs on
systems that ship neither rpm2cpio nor cpio.
"""
import gzip
import lzma
import os
import sys

NEWC_MAGIC = b"070701"
TRAILER = b"TRAILER!!!"


def find_payload(data):
    """Locate the start of the compressed cpio payload.

    Tries each candidate offset for xz/gzip magic after the 96-byte RPM
    lead and returns the first offset whose full stream decompresses and
    looks like a NEWC cpio archive.
    """
    candidates = []
    for magic in (b"\xfd7zXZ\x00", b"\x1f\x8b"):
        pos = 96
        while True:
            pos = data.find(magic, pos)
            if pos == -1:
                break
            candidates.append(pos)
            pos += 1
    candidates.sort()
    for pos in candidates:
        try:
            if data[pos : pos + 6] == b"\xfd7zXZ\x00":
                payload = lzma.decompress(data[pos:])
            else:
                payload = gzip.decompress(data[pos:])
        except (lzma.LZMAError, OSError, EOFError):
            continue
        if payload[:6] == NEWC_MAGIC:
            return payload
    raise SystemExit("error: no compressed cpio payload found in RPM")


def extract_member(payload, member, dest):
    """Walk the NEWC cpio archive and write out the matching member."""
    pos = 0
    found = False
    while payload[pos : pos + 6] == NEWC_MAGIC:
        fields = [
            int(payload[pos + 6 + i * 8 : pos + 14 + i * 8], 16)
            for i in range(13)
        ]
        # NEWC field order: ... mtime, filesize, ..., namesize, check.
        filesize = fields[6]
        namesize = fields[11]
        name_start = pos + 110
        # Archive paths carry a leading "./"; compare without it.
        name = payload[name_start : name_start + namesize - 1].lstrip(b"./")
        if name == TRAILER:
            break
        # Name and data are padded to 4-byte boundaries; the name padding
        # is computed on the absolute offset (110-byte header + name).
        data_start = pos + ((110 + namesize + 3) & ~3)
        data = payload[data_start : data_start + filesize]
        pos = data_start + ((filesize + 3) & ~3)
        if name == member.encode():
            with open(dest, "wb") as fh:
                fh.write(data)
            # Preserve the member's permission bits (e.g. executables).
            os.chmod(dest, fields[1] & 0o7777)
            found = True
    if not found:
        raise SystemExit(f"error: member {member!r} not found in RPM")


def main():
    if len(sys.argv) != 4:
        raise SystemExit(__doc__)
    rpm_path, member, dest = sys.argv[1:4]
    with open(rpm_path, "rb") as fh:
        data = fh.read()
    extract_member(find_payload(data), member, dest)


if __name__ == "__main__":
    main()
