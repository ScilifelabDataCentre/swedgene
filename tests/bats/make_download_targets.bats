SRC="${BATS_TEST_DIRNAME}"/../../scripts/make_download_targets

@test "list_urls" {
    . "${SRC}"
    res=$(list_urls - <<EOF
assembly:
  url: foo
tracks:
  - url: bar
    fileName: bar.gff
EOF
       )
    expected=$(printf '%s\n' \
		      'foo;;-' \
		      'bar;bar.gff;-')
    [ "${res}" = "${expected}" ]
}

@test "list_download_targets" {
    . "${SRC}"
    SWG_DATA_DIR=data
    SWG_CONFIG_DIR=config
    res=$(list_download_targets <<EOF
http://figshare.example/1234;foo.gff.gz;config/tiny_herb/config.yaml
http://figshare.example/bar.fasta;;config/tiny_herb/config.yaml
EOF
       )

    expected=$(cat <<EOF
data/tiny_herb/foo.gff.gz;http://figshare.example/1234
data/tiny_herb/bar.fna.nozip;http://figshare.example/bar.fasta
EOF
	    )
    [ "${res}" = "${expected}" ]
}

@test "filter_download_targets" {
    . "${SRC}"
    res=$(filter_download_targets <<EOF
data/tiny_herb/foo.gff.gz;http://figshare.example/1234
data/tiny_herb/bar.fna.nozip;http://figshare.example/bar.fasta
data/tiny_herb/baz.txt;http://figshare.example/baz.txt
EOF
       )
    expected=$(cat <<EOF
data/tiny_herb/foo.gff.gz;http://figshare.example/1234
data/tiny_herb/bar.fna.nozip;http://figshare.example/bar.fasta
EOF
	    )
    [ "${res}" = "${expected}" ]
}
