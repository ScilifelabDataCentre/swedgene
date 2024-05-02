"""
Use this script to create a new species entry for the website.

This script will create new folders in the Hugo content and data directories.
Then template files for these directories will be added which can be filled in.
Places to fill in will be marked with: "[EDIT]"

"""

import argparse
from pathlib import Path
import shutil

from get_taxonomy import get_taxonomy, EbiRestException


TEMPLATE_DIR = Path(__file__).parent / "templates"

INDEX_FILE = "_index.md"
BROWSER_FILE = "browser.md"
ASSEMBLY_FILE = "assembly.md"
DOWNLOAD_FILE = "download.md"
CONTENT_FILES = (INDEX_FILE, BROWSER_FILE, ASSEMBLY_FILE, DOWNLOAD_FILE)

STATS_FILE = "species_stats.yml"
DATA_FILES = (STATS_FILE,)

LINEAGE_FILE = "lineage.json"


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
        metavar="[species name]",
        help="""The scientific name of the species to be added. 
            Case sensitive. Wrap the name in quotes.""",
        required=True,
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


def add_content_files(species_name: str, content_dir_path: Path) -> None:
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

        output_file_path = content_dir_path / file_name

        with open(output_file_path, "w") as file_out:
            file_out.write(template)
        print(f"File created: {output_file_path.resolve()}")


def add_stats_file(data_dir_path: Path) -> None:
    """
    Add the species name to the template data files,
    then write them to disk.
    """
    for file_name in DATA_FILES:
        template_file_path = TEMPLATE_DIR / file_name
        output_file_path = data_dir_path / file_name
        shutil.copy(template_file_path, output_file_path)
        print(f"File created: {output_file_path.resolve()}")


if __name__ == "__main__":
    args = run_argparse()

    dir_name = args.species_name.replace(" ", "_").lower()
    content_dir_path, data_dir_path = create_dirs(dir_name)

    if not args.overwrite:
        if (content_dir_path / INDEX_FILE).exists():
            raise FileExistsError(
                f"""
                It appears that a species entry already exists for: "{args.species_name}",
                If you are sure you want to overwrite these files, add the flag "--overwrite".
                Exiting..."""
            )

    print("Retriveing taxonomy information, this shouldn't take more than a minute...")
    try:
        get_taxonomy(species_name=args.species_name, overwrite=args.overwrite)
    except EbiRestException:
        print(
            f"""WARNING: Failed to get taxonomy information for species: {args.species_name}
            All other files will now be generated except this file"""
        )

    add_stats_file(data_dir_path=data_dir_path)
    add_content_files(species_name=args.species_name, content_dir_path=content_dir_path)
