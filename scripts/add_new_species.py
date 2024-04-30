"""
Use this script to create a new species entry for the website.

This script will create new folders in the Hugo content and data directories.
Then template files for these directories will be added which can be filled in.
Places to fill in will be marked with: "[EDIT]"

"""

import argparse
from pathlib import Path


TEMPLATE_DIR = Path(__file__).parent / "templates"

INDEX_FILE = "_index.md"
BROWSER_FILE = "browser.md"
ASSEMBLY_FILE = "assembly.md"
DOWNLOAD_FILE = "download.md"
CONTENT_FILES = (INDEX_FILE, BROWSER_FILE, ASSEMBLY_FILE, DOWNLOAD_FILE)

STATS_FILE = "species_stats.yml"
LINEAGE_FILE = "lineage.json"
DATA_FILES = (STATS_FILE, LINEAGE_FILE)


def run_argparse() -> argparse.Namespace:
    """
    Run argparse and return the user arguments.
    """
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument(
        "--species_name",
        type=str,
        metavar="[file]",
        help="The scientific name of the species to be added. Case sensitive.",
    )

    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="""If the files for the species already exist, should they be overwritten? 
            If flag NOT provided, no overwrite performed.""",
    )

    return parser.parse_args()


def create_dirs(dir_name: str) -> tuple[Path, Path]:
    """
    Create the content and data directories for the species
    Return their locations as pathlib objects.
    """
    content_dir_path = Path(__file__).parent / f"../hugo/content/species/{dir_name}"
    content_dir_path.mkdir(parents=False, exist_ok=True)

    data_dir_path = Path(__file__).parent / f"../hugo/data/{dir_name}"
    data_dir_path.mkdir(parents=False, exist_ok=True)

    return content_dir_path, data_dir_path


def add_content_files(species_name: str, content_dir_path: Path):
    """
    Add the species name to the template content files,
    then write them to disk.
    """
    dir_name = species_name.replace(" ", "_").lower()
    for file_name in CONTENT_FILES:
        with open(TEMPLATE_DIR / file_name, "r") as file_in:
            template = file_in.read()

        template = template.replace("SPECIES_NAME", species_name)
        template = template.replace("SPECIES_FOLDER", dir_name)

        file_path = content_dir_path / file_name

        with open(file_path, "w") as file_out:
            file_out.write(template)


def add_data_files(data_dir_path: Path):
    """
    Add the species name to the template data files,
    then write them to disk.
    """
    for file_name in DATA_FILES:
        with open(TEMPLATE_DIR / file_name, "r") as file_in:
            template = file_in.read()

        # As of now, no need to replace anything in the data files
        # This is likely to change though.

        # TODO - merge get_taxonomy work into this script

        with open(data_dir_path / file_name, "w") as file_out:
            file_out.write(template)


if __name__ == "__main__":
    args = run_argparse()

    dir_name = args.species_name.replace(" ", "_").lower()
    content_dir_path, data_dir_path = create_dirs(dir_name)

    add_content_files(species_name=args.species_name, content_dir_path=content_dir_path)
    add_data_files(data_dir_path=data_dir_path)
