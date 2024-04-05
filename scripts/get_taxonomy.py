"""
WIP:

This script does:
1) Reads a list of species scientific names from a file.
2) Obtains the taxonomy id (tax_id) for each species using the ENA REST API.
3) Uses this tax_id to get the full lineage information for each species which is only available in XML format.
    (The xml format includes the rank of each species which is why it is needed)
4) Saves the lineage information for each species into a JSON file which can be used by Hugo.

To run this script:
TODO


TODO :
1. Handle user output file (creation, use pathlib etc...)
2. add tests.
3. add full type hints/documentation


Taxonomic information is saved for the following levels:
- Superkingdom (Domain)
- Kingdom
- Phylum
- Class
- Order
- Family
- Genus
- Species
"""

import argparse
from pathlib import Path
import requests
from xml.etree import ElementTree
import re
import copy
import json
import logging.config


ENDPOINT_URL = r"https://www.ebi.ac.uk/ena/taxonomy/rest/scientific-name/"
ENA_BASE_URL = r"https://www.ebi.ac.uk/ena/browser/view/Taxon:"
NCBI_BASE_URL = r"https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id="


TAXONOMIC_RANKS = [
    "genus",
    "family",
    "order",
    "class",
    "phylum",
    "kingdom",
    "superkingdom",
]

# This is what the final json structure will contain for each species
TEMPLATE_LINEAGE_DICT = {
    "Species": {
        "science_name": "",
        "tax_id": "",
        "ena_link": "",
        "ncbi_link": "",
        "display_order": 1,
    },
    "Genus": {
        "science_name": "",
        "tax_id": "",
        "ena_link": "",
        "ncbi_link": "",
        "display_order": 2,
    },
    "Family": {
        "science_name": "",
        "tax_id": "",
        "ena_link": "",
        "ncbi_link": "",
        "display_order": 3,
    },
    "Order": {
        "science_name": "",
        "tax_id": "",
        "ena_link": "",
        "ncbi_link": "",
        "display_order": 4,
    },
    "Class": {
        "science_name": "",
        "tax_id": "",
        "ena_link": "",
        "ncbi_link": "",
        "display_order": 5,
    },
    "Phylum": {
        "science_name": "",
        "tax_id": "",
        "ena_link": "",
        "ncbi_link": "",
        "display_order": 6,
    },
    "Kingdom": {
        "science_name": "",
        "tax_id": "",
        "ena_link": "",
        "ncbi_link": "",
        "display_order": 7,
    },
    "Superkingdom": {
        "science_name": "",
        "tax_id": "",
        "ena_link": "",
        "ncbi_link": "",
        "display_order": 8,
    },
}

LOGGING_CONFIG = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "standard": {"format": "%(asctime)s [%(levelname)s] %(name)s: %(message)s"}
    },
    "handlers": {
        "stdout": {
            "class": "logging.StreamHandler",
            "formatter": "standard",
            "stream": "ext://sys.stdout",
        },
    },
    "loggers": {"root": {"level": "DEBUG", "handlers": ["stdout"], "propagate": False}},
}


class EbiRestException(Exception):
    """
    Used when the EBI REST API fails to return a response
    or returns a response that we can't use
    """

    pass


def run_argparse():
    """
    TODO
    """
    parser = argparse.ArgumentParser(
        description="""This script reads a list of species (scientific) names from a file, 
        and retrieves lineage information for each species using the ENA REST API.
        It then saves it as a JSON file (1 file per species) for usage with Hugo."""
    )

    parser.add_argument(
        "--species_list",
        type=str,
        default="all_species.txt",
        metavar="[file]",
        help="the file path to your list of species",
    )

    parser.add_argument(
        "--output_dir",
        type=str,
        default=r"../hugo/data/taxonomy/",
        metavar="[directory]",
        help="the path to the directory where you want to save the json files to",
    )

    parser.add_argument(
        "--overwrite",
        type=bool,
        default=False,
        metavar="[True/False]",
        help="If a prexisting json file for a species exists, should it be overwritten? Default is False.",
    )

    parser.add_argument(
        "--logging",
        type=bool,
        default=False,
        metavar="[True/False]",
        help="Run logging or not. Default is False.",
    )

    return parser.parse_args()


def read_species_list(file_path: str) -> list[str]:
    """
    Read the species list from the given file path.
    Removes empty lines, strips leading and trailing whitespaces,
    and removes quotes if present inside the names.
    """
    with open(file_path) as file:
        names = []
        with open(file_path) as file:
            for line in file.readlines():
                line = re.sub("[\"']", "", line.strip())
                if len(line) > 0:
                    names.append(line)
    return names


def create_endpoint_url(scientific_name: str) -> str:
    """
    Create the endpoint URL for the given scientific name.
    """
    return ENDPOINT_URL + scientific_name.replace(" ", "%20")


def get_tax_id(scientific_name: str) -> dict[str, str]:
    """
    Get the taxonomy id from the scientific name.
    Search by name is case insensitive.
    """
    url = create_endpoint_url(scientific_name)
    response = requests.get(url)

    if response.status_code != 200:
        raise EbiRestException(f"Failed to get taxonomy info for {scientific_name}")

    if len(response.json()) == 0:
        raise EbiRestException(f"No taxonomy info found for {scientific_name}")

    if len(response.json()) > 1:
        raise EbiRestException(f"Multiple taxonomy results found for {scientific_name}")

    full_taxon_info = response.json()[0]

    tax_id = full_taxon_info["taxId"]
    return tax_id


def get_lineage_section(tax_id: str | int) -> str:
    """
    Search for the taxonomy information by the taxonomy id.

    Returns the lineage section of the XML response as a string.
    """
    try:
        response = requests.get(
            f"https://www.ebi.ac.uk/ena/browser/api/xml/{str(tax_id)}"
        )
    except requests.exceptions.RequestException as e:
        raise EbiRestException(
            f"""Failed to get lineage info for tax_id: {tax_id} .Error is as follows:
            {e}"""
        )

    tree = ElementTree.fromstring(response.content)
    lineage_element = tree.find(".//lineage")
    lineage_section = ElementTree.tostring(lineage_element).decode()

    return lineage_section


def append_lineage_info(
    species_dict: dict[str, dict[str, str]], lineage_section: str
) -> dict[str, dict[str, str]]:
    """
    Add lineage information to the template lineage dictionary.
    """
    for line in lineage_section.split("\n"):
        for tax_rank in TAXONOMIC_RANKS:
            tax_rank_caps = tax_rank.capitalize()

            rank = rf'rank="{tax_rank}"'
            if rank in line:
                name_match = re.search(r'scientificName="([^"]*)"', line)
                if name_match:
                    species_dict[tax_rank_caps]["science_name"] = name_match.group(1)

                taxid_match = re.search(r'taxId="([^"]*)"', line)
                if taxid_match:
                    tax_id = taxid_match.group(1)
                    species_dict[tax_rank_caps]["tax_id"] = tax_id
                    species_dict[tax_rank_caps]["ena_link"] = ENA_BASE_URL + tax_id
                    species_dict[tax_rank_caps]["ncbi_link"] = NCBI_BASE_URL + tax_id

    return species_dict


if __name__ == "__main__":
    args = run_argparse()
    species_to_search = read_species_list(args.species_list)

    if args.logging:
        logger = logging.getLogger(__name__)
        logging.config.dictConfig(LOGGING_CONFIG)

    failed_species: list[str] = []
    for species_name in species_to_search:
        # build the output file path first so can check if file already exists
        output_file = Path(args.output_dir + species_name.replace(" ", "_") + ".json")
        if not args.overwrite:
            if output_file.exists():
                if args.logging:
                    logger.info(
                        f"skipping species: {species_name} as output file already exists"
                    )
                continue

        try:
            tax_id = get_tax_id(species_name)
        except EbiRestException as e:
            if args.logging:
                logger.warning(f"""Species with name: {species_name} failed tax_id search, skipping.
                    Error type is: {type(e).__name__}
                    Error message is: {e}""")

            failed_species.append(species_name)
            continue

        # Create and populate the species dictionary
        species_dict = copy.deepcopy(TEMPLATE_LINEAGE_DICT)

        species_dict["Species"]["science_name"] = species_name
        species_dict["Species"]["tax_id"] = str(tax_id)
        species_dict["Species"]["ena_link"] = ENA_BASE_URL + str(tax_id)
        species_dict["Species"]["ncbi_link"] = NCBI_BASE_URL + str(tax_id)

        # get the lineage information for all the taxonomic ranks
        try:
            lineage_section = get_lineage_section(tax_id)
        except EbiRestException as e:
            if args.logging:
                logger.warning(
                    f"""Species with name: {species_name} failed lineage search, skipping.
                    Error type is: {type(e).__name__}
                    Error message is: \n {e}
                    """
                )

            failed_species.append(species_name)
            continue

        species_dict = append_lineage_info(
            species_dict=species_dict, lineage_section=lineage_section
        )

        with open(output_file, "w") as file:
            json.dump(species_dict, file, indent=4)

        if args.logging:
            logger.info(f"Saved lineage info for species: {species_name}")

    # warning message for anyone using this script, regarding of logging.
    if failed_species:
        print("WARNING: For the following species no taxonomy information was found:")
        for numb, species in enumerate(failed_species, start=1):
            print(f"{numb}: {species}")
        print("Make sure their scientific name is/are spelled correctly.")
