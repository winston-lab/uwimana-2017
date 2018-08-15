
# [Uwimana *et al*., 2017](https://doi.org/10.1093/nar/gkx242)

## description

Code used to convert RNA-seq coverage from [Uwimana *et al*., 2017](https://doi.org/10.1093/nar/gkx242) into coverage files compatible with [data integration](https://github.com/winston-lab/integrated-datavis) and other pipelines. The archived version of this analysis used in [our preprint](https://doi.org/10.1101/347575) is available at [Zenodo](https://doi.org/10.5281/zenodo.1325930).

## requirements

### required software

- Unix-like operating system (tested on CentOS 7.2.1511)
- Git
- [conda](https://conda.io/docs/user-guide/install/index.html)

### required files

Again, to reproduce the results from our paper, use the archived version of this analysis from [Zenodo](https://doi.org/10.5281/zenodo.1325930).

- FASTA file of the *S. cerevisiae* genome, [available here](https://github.com/winston-lab/genomefiles-cerevisiae).
    - in the Zenodo archive, this file is in the `genomefiles_cerevisiae` directory

## instructions

**0**. Create and activate the `uwimana17` virtual environment for this pipeline using conda. This can take a while, be patient. 

```bash
# create the uwimana17 environment
conda env create -v -f envs/default.yaml

# activate the environment
source activate uwimana17

# to deactivate the environment
# source deactivate
```

**1**. The configuration file `config.yaml` is set up to point to the *S. cerevisiae* FASTA file in the `genomefiles_cerevisiae` directory of the Zenodo archive. If using a different genome build for some reason, edit the config file.

```bash
# edit the configuration file
vim config.yaml    # or use your favorite editor
```

**2**. With the `uwimana17` environment activated, do a dry run of the pipeline to see what files will be created.

```bash
snakemake -p --use-conda --dry-run
```

**3**. If running the pipeline on a local machine, you can run the pipeline using the above command, omitting the `--dry-run` flag. You can also use N cores by specifying the `--cores N` flag. The first time the pipeline is run, conda will create separate virtual environments for some of the jobs to operate in. Running the pipeline on a local machine can take a long time, so it's recommended to use an HPC cluster if possible. On the HMS O2 cluster, which uses the SLURM job scheduler, entering `sbatch slurm.sh` will submit the pipeline as a single job which spawns individual subjobs as necessary. This can be adapted to other job schedulers and clusters by modifying `slurm.sh` and `cluster.yaml`, which specifies the resource requests for each type of job.

