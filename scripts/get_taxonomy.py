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
1. add logging.
2. add error handling.
3. add CLI arguments.
4. add tests.
5. add full type hints/documentation
6. Add way to check if file already made and if so skip that one.


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

import requests
from xml.etree import ElementTree
import re
import copy
import json


# TODO - turn into CLI arguments
SPECIES_LIST = "all_species.txt"
OUTPUT_DIR = r"../hugo/data/taxonomy/"
OVERWRITE_MODE = False  # TODO - incorporate this
# TODO handle if user doesn't specify final slash


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


class EbiRestException(Exception):
    """
    Used when the EBI REST API fails to return a response
    or returns a response that we can't use
    """

    pass


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


def get_tax_id(scientific_name) -> dict[str, str]:
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
    response = requests.get(f"https://www.ebi.ac.uk/ena/browser/api/xml/{str(tax_id)}")
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
    species_to_search = read_species_list(SPECIES_LIST)

    taxids = {}
    for species in species_to_search:
        try:
            tax_id = get_tax_id(species)
        except EbiRestException as e:
            print(e)
            print(f"Species with name: {species} failed, skipping.")
            continue
        taxids[species] = get_tax_id(species)

    for species_name, tax_id in taxids.items():
        species_dict = copy.deepcopy(TEMPLATE_LINEAGE_DICT)

        # add the information for the species
        species_dict["Species"]["science_name"] = species_name
        species_dict["Species"]["tax_id"] = str(tax_id)
        species_dict["Species"]["ena_link"] = ENA_BASE_URL + str(tax_id)
        species_dict["Species"]["ncbi_link"] = NCBI_BASE_URL + str(tax_id)

        # get the lineage information
        lineage_section = get_lineage_section(tax_id)
        species_dict = append_lineage_info(
            species_dict=species_dict, lineage_section=lineage_section
        )

        output_file = OUTPUT_DIR + species_name.replace(" ", "_") + ".json"
        with open(output_file, "w") as file:
            json.dump(species_dict, file, indent=4)

        break
