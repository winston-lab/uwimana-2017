#!/usr/bin/env python
import os

configfile: "config.yaml"

SAMPLES = config["samples"]

localrules:
    all, convert_coverage, make_stranded_genome

rule all:
    input:
        expand("coverage/{sample}_{strand}.bedgraph", sample=SAMPLES, strand=["plus", "minus"]),
        expand("coverage/{sample}_{strand}.bw", sample=SAMPLES, strand=["SENSE", "ANTISENSE"])

rule convert_coverage:
    input:
        lambda wildcards: "data/" + SAMPLES[wildcards.sample]["id"] + "_pos.bw" if wildcards.strand=="plus" else "data/" + SAMPLES[wildcards.sample]["id"] + "_neg.bw"
    output:
        bedgraph = "coverage/{sample}_{strand}.bedgraph",
    log: "logs/convert_coverage/convert_coverage-{sample}-{strand}.log"
    wildcard_constraints:
        strand="plus|minus"

    shell: """
        (bigWigToBedGraph {input} {output.bedgraph}) &> {log}
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

rule make_stranded_genome:
    input:
        exp = config["chrsizes"],
    output:
        exp = os.path.splitext(config["chrsizes"])[0] + "-STRANDED.tsv",
    log: "logs/make_stranded_genome.log"
    shell: """
        (awk 'BEGIN{{FS=OFS="\t"}}{{print $1"-plus", $2}}{{print $1"-minus", $2}}' {input.exp} > {output.exp}) &> {log}
        """

rule bedgraph_to_bigwig:
    input:
        bedgraph = "coverage/{sample}_{strand}.bedgraph",
        chrsizes = lambda wildcards: config["chrsizes"] if wildcards.strand in ["plus", "minus"] else os.path.splitext(config["chrsizes"])[0] + "-STRANDED.tsv"
    output:
        "coverage/{sample}_{strand}.bw",
    log: "logs/bedgraph_to_bigwig/bedgraph_to_bigwig-{sample}-{strand}.log"
    shell: """
        (bedGraphToBigWig {input.bedgraph} {input.chrsizes} {output}) &> {log}
        """



