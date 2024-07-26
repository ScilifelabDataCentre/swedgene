#!/urs/bin/env bats

setup() {
    source "${BATS_TEST_DIRNAME}"/../../scripts/utils.sh
}

@test "Normalize FASTA extensions" {
    res="$(normalize_filename foo.fasta.gz)"
    [ ${res} = foo.fna.gz ]

    res="$(normalize_filename foo.fa.zip)"
    [ ${res} = foo.fna.zip ]
}

@test "Normalize GFF extensions" {

    res="$(normalize_filename foo.gff3.zip)"
    [ ${res} = foo.gff.zip ]

    # Noop
    res="$(normalize_filename foo.gff.zip)"
    [ ${res} = foo.gff.zip ]
}
