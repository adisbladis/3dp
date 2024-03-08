#!/usr/bin/env python
#
# A HTML "linker" that substitutes Nix store paths in a HTML document
#
from bs4 import BeautifulSoup
import os.path
import shutil
import sys
import os

STORE_PREFIX = "/nix/store"


def make_dest(origin: str) -> str:
    return origin.replace(STORE_PREFIX, "store", 1)


if __name__ == "__main__":
    store_paths: set[str] = set()

    with open("../graph") as f:
        for line in f.readlines():
            if line.startswith(STORE_PREFIX):
                store_paths.add(line.strip())

    print("Scanning for store paths:")
    for store_path in store_paths:
        print(store_path)

    found_files: set[str] = set()

    with open(sys.argv[1]) as f:
        html = f.read()
        soup = BeautifulSoup(html, features="html.parser")

    # Rewrite HTML to local store
    for tag in soup.find_all():
        for attr, value in tag.attrs.items():
            for store_path in store_paths:
                if not value.startswith(store_path):
                    continue

                found_files.add(value)
                # tag[attr] = make_dest(value)

    # Copy files to local store
    for origin in found_files:
        dest = make_dest(origin)
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        shutil.copy(origin, dest)

        # Substitute files in the raw HTML stream so that things that are not strict prefix matches still work.
        html = html.replace(origin, dest)

    # print(str(soup))
    with open(sys.argv[1], "w") as f:
        f.write(html)
