#!/usr/bin/env python3

import argparse
import json
import os
import shutil

SCRIPTS_DIRECTORY = os.path.dirname(os.path.abspath(__file__))
ROOT_DIRECOTRY = os.path.dirname(SCRIPTS_DIRECTORY)
RESOURCES_DIRECTORY = os.path.join(ROOT_DIRECOTRY, "Symbolic", "Resources")

MATERIAL_ICONS_DIRECTORY = os.path.join(RESOURCES_DIRECTORY, "material-icons")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("src")
    options = parser.parse_args()

    manifest = {}
    manifest["id"] = "material-icons"
    manifest["name"] = "Material Icons"
    manifest["symbols"] = []

    src_directory = os.path.abspath(options.src)
    categories = os.listdir(src_directory)
    for category in categories:
        category_path = os.path.join(src_directory, category)
        icons = os.listdir(category_path)
        for icon in icons:
            symbol = {
                "id": icon,
                "name": icon.replace("_", " ").title(),
                "variants": {}
            }

            icon_base_path = os.path.join(category_path, icon)
            variants = os.listdir(icon_base_path)

            for variant in variants:
                assert variant.startswith("materialicons")
                variant_name = variant[len("materialicons"):]
                variant_key = variant_name if variant_name else "default"
                icon_path = os.path.join(category_path, icon, variant, "24px.svg")
                basename = "%s.%s.svg" % (icon, variant_key)
                shutil.copyfile(icon_path, os.path.join(MATERIAL_ICONS_DIRECTORY, basename))
                symbol["variants"][variant_key] = {
                    "path": basename
                }
            manifest["symbols"].append(symbol)

    with open(os.path.join(MATERIAL_ICONS_DIRECTORY, "manifest.json"), "w") as fh:
        json.dump(manifest, fh, indent=4)


if __name__ == "__main__":
    main()