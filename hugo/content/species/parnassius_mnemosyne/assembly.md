---
title: "Genome assembly"
layout: "species_assembly"
weight: 2

stats_data_path: "parnassius_mnemosyne/species_stats"
lineage_data_path: "parnassius_mnemosyne/taxonomy"

key_info:
  - "Assembly Name": "Parnassius_mnemosyne_n_2023_11"
  - "Assembly Type": "haploid"
  - "Assembly Level": "scaffold"
  - "Genome Representation": "full"
  - "Accession": "GCA_963668995"
---

|||||| Content divider - do not remove ||||||

### Publication(s)

Unless specified otherwise, the data displayed in the genome portal and the information about the assembly comes from:

- Höglund, J., Dias, G., Olsen, R. A., Soares, A., Bunikis, I., Talla, V., & Backström, N. (2024). A Chromosome-Level Genome Assembly and Annotation for the Clouded Apollo Butterfly (*Parnassius mnemosyne*): A Species of Global Conservation Concern. Genome Biology and Evolution, 16(2), evae031. <https://doi.org/10.1093/gbe/evae031>

### Methods

*Below is a brief summary of the methodology used to produce the genome data, as described in Höglund et al. (2024). For more details, please refer to the original publication.*

#### Samples

Thorax muscle tissue from two female Clouded Apollo individuals (PM1 and PM2) from a captive population was used for the sequencing experiments. DNA was extracted from PM1 and PM2 and used for PacBio HiFi, and Illumina Hi-C sequencing, respectively. RNA was extracted from PM2 and used for Illumina short-read and PacBio Iso-seq sequencing.

#### Genome assembly

The *P. mnemosyne* genome was assembled using the PacBio HiFi and Illumina Hi-C data. Hifiasm (v0.16.0; Cheng et al. 2021) was used to assemble the PacBio reads. Putative duplications were removed from the assembly using purge_drops (v1.2.5; Guan et al. 2020) before aligning the Hi-C reads with pairtools (v0.3.0; Abdenur et al. 2023). Scaffolding was then performed using YaHS (v1.1a; Zhou et al. 2022). After a manual curation using the Hi-C contact maps and telomere motifs, the final assembly was produced. The mitochondrial genome was extracted from the primary assembly using MitoHiFi (v2.2; Uliano-Silva et al. 2023).

#### Genome annotation

Repeats were identified with RepeatModeler2 (v2.0.2a; Flynn et al. 2020) and were used to soft-mask the assembly before the annotation. Gene prediction was performed using the Illumina RNAseq data, a database of Arthropod proteins, and the PacBio Iso-seq data using BRAKER (v3.03; Gabriel et al. 2023), GALBA (v1.0.6; Brůna et al. 2023), and GeneMarkS-T (v5.1; Tang et al. 2015) pipelines, respectively. The resulting gene models were combined and filtered using TSEBRA (long_reads branch: commit 1f2614; Gabriel et al. 2021) and AGAT (v1.2.0; Dainat et al. 2023) was used to remove overlapping genes. The combined gene model was functionally annotated by the NBIS nextflow pipeline. Prediction of tRNA genes was done with tRNAscan (v2.0.12; Chan et al. 2021) and nonconding RNAs with Infernal (v1.1.4; Nawrocki and Eddy 2013). The mitochondrial genome was annotated using MitoFinder (v1.4.1.; Allio et al. 2020).

##### Method references

- Abdennur, N., Fudenberg, G., Flyamer, I. M., Galitsyna, A. A., Goloborodko, A., Imakaev, M., & Venev, S. V. (2023). Pairtools: From sequencing data to chromosome contacts. *bioRxiv*, 2023.02.13.528389. <https://doi.org/10.1101/2023.02.13.528389>
- Allio, R., Schomaker-Bastos, A., Romiguier, J., Prosdocimi, F., Nabholz, B., & Delsuc, F. (2020). MitoFinder: Efficient automated large-scale extraction of mitogenomic data in target enrichment phylogenomics. *Molecular Ecology Resources*, *20*(4), 892–905. <https://doi.org/10.1111/1755-0998.13160>
- Brůna, T., Li, H., Guhlin, J., Honsel, D., Herbold, S., Stanke, M., Nenasheva, N., Ebel, M., Gabriel, L., & Hoff, K. J. (2023). Galba: Genome annotation with miniprot and AUGUSTUS. *BMC Bioinformatics*, *24*(1), 327. <https://doi.org/10.1186/s12859-023-05449-z>
- Cheng, H., Concepcion, G. T., Feng, X., Zhang, H., & Li, H. (2021). Haplotype-resolved de novo assembly using phased assembly graphs with hifiasm. *Nature Methods*, *18*(2), 170–175. <https://doi.org/10.1038/s41592-020-01056-5>
- Chan, P.P., Lin, B.Y., Mak, A.J. & Lowe, T.M. (2021). tRNAscan-SE 2.0: improved detection and functional classification of transfer RNA genes. *Nucleic Acids Research* 49:9077–9096. <https://doi.org/10.1093/nar/gkab688>
- Dainat, J., Hereñú, D., Murray,  K. D., Davis, E., Crouch, K., LucileSol, Agostinho, N. pascal-git, Zollman, Z., & tayyrov. (2023). NBISweden/AGAT: AGAT-v1.2.0 (v1.2.0). Zenodo. <https://doi.org/10.5281/zenodo.8178877>
- Flynn, J. M., Hubley, R., Goubert, C., Rosen, J., Clark, A. G., Feschotte, C., & Smit, A. F. (2020). RepeatModeler2 for automated genomic discovery of transposable element families. *Proceedings of the National Academy of Sciences*, *117*(17), 9451–9457.
- Gabriel, L., Brůna, T., Hoff, K. J., Ebel, M., Lomsadze, A., Borodovsky, M., & Stanke, M. (2023). BRAKER3: Fully Automated Genome Annotation Using RNA-Seq and Protein Evidence with GeneMark-ETP, AUGUSTUS and TSEBRA. *bioRxiv*, 2023.06.10.544449. <https://doi.org/10.1101/2023.06.10.544449>
- Gabriel, L., Hoff, K. J., Brůna, T., Borodovsky, M., & Stanke, M. (2021). TSEBRA: transcript selector for BRAKER. *BMC Bioinformatics*, *22*(1), 566. <https://doi.org/10.1186/s12859-021-04482-0>
- Guan, D., McCarthy, S. A., Wood, J., Howe, K., Wang, Y., & Durbin, R. (2020). Identifying and removing haplotypic duplication in primary genome assemblies. *Bioinformatics*, *36*(9), 2896–2898. <https://doi.org/10.1093/bioinformatics/btaa025>
- Nawrocki, E. P., & Eddy, S. R. (2013). Infernal 1.1: 100-fold faster RNA homology searches. *Bioinformatics*, *29*(22), 2933–2935. <https://doi.org/10.1093/bioinformatics/btt509>
- Uliano-Silva, M., Ferreira, J. G. R. N., Krasheninnikova, K., Blaxter, M., Mieszkowska, N., Hall, N., Holland, P., Durbin, R., Richards, T., Kersey, P., Hollingsworth, P., Wilson, W., Twyford, A., Gaya, E., Lawniczak, M., Lewis, O., Broad, G., Martin, F., Hart, M., … Darwin Tree of Life Consortium. (2023). MitoHiFi: A python pipeline for mitochondrial genome assembly from PacBio high fidelity reads. *BMC Bioinformatics*, *24*(1), 288. <https://doi.org/10.1186/s12859-023-05385-y>
- Tang, S., Lomsadze, A., & Borodovsky, M. (2015). Identification of protein coding regions in RNA transcripts. *Nucleic Acids Research*, *43*(12), e78–e78. <https://doi.org/10.1093/nar/gkv227>
- Zhou, C., McCarthy, S. A., & Durbin, R. (2023). YaHS: yet another Hi-C scaffolding tool. *Bioinformatics*, *39*(1), btac808. <https://doi.org/10.1093/bioinformatics/btac808>

### Funding

*The study in which the genome data was generated (Höglund et al. 2024) was funded by:*

- Swedish Research Council (Grant number [2019-04791](https://www.vr.se/english/swecris.html#/project/2019-04791_VR))
- NBIS/SciLifeLab long-term bioinformatics support
- Swedish Rescue Program for *P. mnemosyne* through the local administrative board (Länsstyrelsen) of Blekinge

### Acknowledgements

*The study in which the genome data was generated (Höglund et al. 2024) acknolowledges the following support:*

Assistance in massive parallel sequencing and computational infrastructure was provided by:

- Science for Life Laboratory (SciLifeLab)
- National Genomics Infrastructure (NGI)
- Uppsala Multidisciplinary Center for Advanced Computational Science (UPPMAX)
- Swedish National Infrastructure for Computing (SNIC). Computations were performed under project SNIC 2020-5-20

Assistance with dissections was provided by:

- Veronika Mrazek

Assistance with OmniC and RNA-seq was provided by:

- The ERGA hubs at the University of Antwerp (Henrique Leitão, Genevieve Diedericks, Hannes Svardal) and University of Florence (Claudio Ciofi)
