#!/usr/bin/env python
import os

configfile: "config.yaml"

SAMPLES = config["samples"]

localrules:
    all, convert_coverage

rule all:
    input:
        expand("coverage/{sample}_{strand}.bedgraph", sample=SAMPLES, strand=["plus", "minus"]),
        expand("coverage/{sample}_{strand}.bw", sample=SAMPLES, strand=["SENSE", "ANTISENSE"])

rule convert_coverage:
    input:
        coverage = lambda wildcards: "data/" + SAMPLES[wildcards.sample]["id"] + "_pos.bw" if wildcards.strand=="plus" else "data/" + SAMPLES[wildcards.sample]["id"] + "_neg.bw",
        fasta = config["fasta"]
    output:
        bedgraph = "coverage/{sample}_{strand}.bedgraph",
    log: "logs/convert_coverage/convert_coverage-{sample}-{strand}.log"
    wildcard_constraints:
        strand="plus|minus"
    shell: """
        (bigWigToBedGraph {input.coverage} coverage/.{wildcards.sample}-{wildcards.strand}.temp) &> {log}
        (bedtools unionbedg -i coverage/.{wildcards.sample}-{wildcards.strand}.temp <(echo) -empty -g <(faidx {input.fasta} -i chromsizes) | cut -f1-4 | awk 'BEGIN{{FS=OFS="\t"}}{{$4 < 0 ? $4=-$4: $4; print $0}}'> {output.bedgraph}) &>> {log}
        """

rule make_stranded_bedgraph:
    input:
        plus = "coverage/{sample}_plus.bedgraph",
        minus = "coverage/{sample}_minus.bedgraph",
    output:
        sense = "coverage/{sample}_SENSE.bedgraph",
        antisense = "coverage/{sample}_ANTISENSE.bedgraph",
    log: "logs/make_stranded_bedgraph/make_stranded_bedgraph_{sample}.log"
    shell: """
        (bash scripts/makeStrandedBedgraph.sh {input.plus} {input.minus} > {output.sense}) &> {log}
        (bash scripts/makeStrandedBedgraph.sh {input.minus} {input.plus} > {output.antisense}) &>> {log}
        """

rule bedgraph_to_bigwig:
    input:
        bedgraph = "coverage/{sample}_{strand}.bedgraph",
        fasta = config["fasta"]
    output:
        "coverage/{sample}_{strand}.bw",
    params:
        stranded = lambda wc: [] if wc.strand in ["plus", "minus"] else """| awk 'BEGIN{{FS=OFS="\t"}}{{print $1"-plus", $2; print $1"-minus", $2}}' | LC_COLLATE=C sort -k1,1"""
    log: "logs/bedgraph_to_bigwig/bedgraph_to_bigwig-{sample}-{strand}.log"
    shell: """
        (bedGraphToBigWig {input.bedgraph} <(faidx {input.fasta} -i chromsizes {params.stranded}) {output}) &> {log}
        """

