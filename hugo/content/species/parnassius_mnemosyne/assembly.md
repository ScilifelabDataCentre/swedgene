---
title: "Genome assembly"
layout: "species_assembly"
weight: 2

stats_data_path: "parnassius_mnemosyne/species_stats"
lineage_data_path: "parnassius_mnemosyne/taxonomy"

key_info:
  - "Assembly Name": "Parnassius_mnemosyne_n_2023_11"
  - "Assembly Level": "scaffold"
  - "Genome Representation": "full"
  - "Accession": "GCA_963668995"
---

### Methods

Short text about the methods used to generate the data: e.g. sequencing technology, assembly algorithm, annotation pipeline.
The genome was assembled using a combination of PacBio (HiFi) and Illumina Hi-C data. The HiFi reads had a coverage of ∼30× and were assembled using Hifiasm v0.16.0 (Cheng et al. 2021). Purge_Dups v1.2.5 (Guan et al. 2020) was used to remove putative duplications. The Hi-C sequence reads were aligned to the purged assembly and processed with pairtools v0.3.0 (Abdennur et al. 2023), and contigs were scaffolded with YaHS v1.1a (Zhou et al. 2022). Hi-C scaffolds were manually edited with JBAT v2.20.00 (Dudchenko et al. 2018), using the Hi-C contact maps and telomere motif annotation from tidk v0.2.31 (<https://github.com/tolkit/telomeric-identifier>) to produce the final assembly. Potential contamination was assessed using Mash v2.3 (Ondov et al. 2019) and the National Center for Biotechnology Information (NCBI) RefSeq database (<https://gembox.cbcb.umd.edu/mash/refseq.genomes.k21s1000.msh>), and no substantial contamination was found. Genome properties were estimated from both the HiFi reads and the final assembly using the k-mer Gene prediction was performed in 3 steps that were later combined, incorporating standard RNA-seq, protein sequences from multiple organisms, and PacBio Iso-Seq as evidence. (i) The RNA-seq reads for P. mnemosyne (Table 1) were aligned to the assembly with HiSat2 v2.1.0 (Kim et al. 2019), and BRAKER v3.0.3 (Gabriel et al. 2023) was used to extract splicing signals and to train and predict genes using Augustus. (ii) Arthropod proteins from OrthoDB v11.

|||||| Content divider - do not remove ||||||

### Contributor(s)

- [EDIT] Add information about provider
- [EDIT] The research group that published the genome and data tracks

### Publication(s)

- Jacob Höglund, Guilherme Dias, Remi-André Olsen, André Soares, Ignas Bunikis, Venkat Talla, Niclas Backström, A Chromosome-Level Genome Assembly and Annotation for the Clouded Apollo Butterfly (Parnassius mnemosyne): A Species of Global Conservation Concern, Genome Biology and Evolution, Volume 16, Issue 2, February 2024, evae031, <https://doi.org/10.1093/gbe/evae031>

### Funding

- Knut and Wallenberg Foundation
- Formas

### Acknowledgements

- SciLifeLab Data Centre
- SNP&SEQ Uppsala
- NBIS
