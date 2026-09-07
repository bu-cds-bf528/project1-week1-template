# Project Overview

For this first project, you will be developing a nextflow pipeline to assemble
a bacterial genome from long and short read sequencing data. You will be provided
a scaffold of the nextflow pipeline and asked to implement the various steps
outlined in the pipeline. You will not have to complete the entire pipeline, but
will instead be asked to focus on various aspects of the workflow as we progress
and get more comfortable with the tools and concepts. This project is broken up
into weeks and each week will focus on different tasks. Future projects you will
be working in a more open-ended manner and will be asked to implement the entire
pipeline on your own. 

For this week, you will be given a scaffolded nextflow pipeline and every week,
we will continue to update and refine it until it resembles a final pipeline. 
The weeks after the first will include the previous week's pipeline as well as
additional improvements. 

# Week 1 - Understanding channels

As we will discuss in class, hybrid assembly approaches combine the benefits of
both long and short read sequencing technologies. The long read sequencing
provides improved contiguity and longer reads, which can better capture regions
of the genome previously difficult to sequence using short reads. This is especially
useful during genome assembly, where the longer reads are more likely to span
all regions of the genome, greatly aiding in the assembly process. However,
short reads are still useful and are commonly utilized to "polish" the assembly
and remove systematic errors from the assembly of the long reads. 

We will talk in more detail about short and long reads as well as genome assembly.
Focus for now on the specific concepts and tools in nextflow. 

We will be generating a nextflow pipeline that will perform the following steps:

1. Assembly of the nanopore reads
2. Polishing of the nanopore assembly with the Illumina reads
3. Quality Control of the polished assembly and comparison the reference genome
4. Annotation of the genome and visualization of genomic features

## Relevant Resources

- [Nextflow Operators](https://docs.seqera.io/nextflow/tutorials/static-types-operators)
- [Nextflow Tutorial](https://training.nextflow.io/latest/hello_nextflow/)
- [CLI Resources]({{site.baseurl}}/guides/cli_resources/)
- [Computational Environments]({{site.baseurl}}/guides/computational_environments/)
- [Basic Conda]({{site.baseurl}}/guides/conda_guide/)
- [Nextflow Basics]({{site.baseurl}}/guides/nextflow_basics/)
- [Nextflow Channels]({{site.baseurl}}/guides/nextflow_channels/)

## Objectives 

For the first week, we will focus on understanding how channels work in
Nextflow and how they connect the processes in a pipeline together. You will
annotate the provided `week1.nf` pipeline to explain what each channel
operation is doing, complete the `specifications.md` file to describe the
pipeline at a higher level, generate the appropriate computational
environments for each tool, and fill in the commands for the two simpler
tools in the pipeline, FastQC and filtlong. From a pipeline standpoint, we
will be performing quality control on the short reads, quality control of the
long reads, and then assembly of the long reads. 

## Setting up

For this week, I have provided you with a mostly complete nextflow pipeline
that will let you see how it works while focusing just on learning a few key
concepts we will be using throughout the semester. 

To start, open a VSCode session in **your** directory under the BF528 project
(i.e. `/projectnb/bf528/students/<your_username>/`). Please replace the
`<your_username>` with your BU ID and no @bu.edu. So if your BU ID was `jstudent`
then your directory would be `/projectnb/bf528/students/jstudent/`

Ensure that you have selected `miniconda` in the Additional Modules to load
section of the VSCode OnDemand interface. 

When your session has launched, remember to activate the conda environment
you created for nextflow using the following command:

```bash
conda activate nextflow_latest
```

1. Please clone the github repo for this project in your student folder - you may
find the link on blackboard. In your student directory, you may use the following
command to clone your repo after copying the **SSH** link from your repo made for
you on classroom50:

```bash
git clone <repo_url>
```

This will make a clone of the repo to your student directory and all of your work
for this week should be done in this directory. You will push your changes to
GitHub as you go, which will also enable us to evaluate your work and help
troubleshoot. 

2. Open this directory in your VSCode session. 

3. Familiarize yourself with the directory you are working in. Throughout the semester,
we will be using the same structure and organization in all of the projects.

## Tasks

### Understanding the channels

1. Open `week1.nf`. This is a fully working pipeline, already wired up
to run end to end. Add a comment above each of the following explaining, in
plain English, what it is doing:

Single line comments in Groovy / Nextflow start with `//` and multi line begin with
`/*` and end with `*/`

- The `record` block definitions (`AssemblyReads`, `FastqRead`, `FastqcReport`)
  - How many fields does each record type have, and what type is each field?
  - Which record type represents a single read file, and which represents an
  entire sample's set of reads (long + paired short reads)?

- The `read_pairs_ch` assignment (what does `splitCsv` do, and what does the
`map` produce for each row of the CSV?)
  - Given the number of rows in `bac_samples.csv`, how many items will be
  emitted into `read_pairs_ch`?
  - How many fields does each item in `read_pairs_ch` have?

- The `fastqc_ch` assignment (why is `flatMap` used here instead of `map`, and
how does the shape of `fastqc_ch` differ from `read_pairs_ch`?)
  - For every one item that comes out of `read_pairs_ch`, how many items does
  `fastqc_ch` produce? Why that number specifically?
  - If `bac_samples.csv` had 5 rows instead of 1, how many total items would
  flow through `fastqc_ch`?

- The `input:` and `output:` blocks of each process (what type is expected in,
and what is being produced out?)
  - How many named outputs does each process declare, and how many actual
  files on disk does each output correspond to?
  - How many times will `FASTQC` run, and how does that relate to the number
  of items in `fastqc_ch`?
  - Does the output type of `FILTLONGER` match the input type expected by
  `FLYE`? How do you know they can be connected directly?

- The use of `$reads.read` (in `FASTQC`'s script block) and `${reads.name}`                                                                                                                                                                                            
(in `FILTLONGER`'s and `FLYE`'s output/script blocks)                                                                                                                                                                                                                
  - What field of the record is being accessed in each case, and why does                                                                                                                                                                                              
  that field need to exist on the record type declared in that process's                                                                                                                                                                                               
  `input:` block?                                                                                                                                                                                                                                                      
  - Why does `${reads.name}` need curly braces while `$reads.read` doesn't —                                                                                                                                                                                           
  what would `$reads.name.filtered.fastq.gz` (no braces) be interpreted as                                                                                                                                                                                             
    instead?      

You don't need to modify any of the logic here as your goal is to demonstrate
that you can read Nextflow code and explain what each channel operation is doing.
You'll be writing this kind of logic yourself later in the class. 

### Completing specifications.md

Open `specifications.md` in the root of the repo. This document describes the
full pipeline we'll be building over the course of the semester, independent
of any particular week's code.

1. Fill in the **Pipeline Steps** table with one row per process in the final
pipeline (not just what's implemented in `week1.nf` so far), using the
Objective and Outputs sections above it as a guide. This will help you understand
dependencies and what processes can happen in parallel and which must wait for the
outputs of other steps.

2. Fill in the **Environment and Reproducibility** table, noting whether each
tool's conda environment pins an exact version.

3. Fill in the **Validation Table** with rows specific to this pipeline
(delete the RNA-seq example rows once you've replaced them) describing how
you would justify and validate each step's parameters.

This document should give someone unfamiliar with the code a clear sense of
what the pipeline does and how you'd know it worked correctly, even without
reading `week1.nf` itself. Eventually, this will serve as scaffolding for
you and potentially agentic coding harnesses to understand and implement
the project at a high level. 

### Specifying appropriate computational environments

The channel and process logic for this pipeline is already written in the
week1.nf file, but you will need to specify the appropriate computational
environments for each process. In general, we will endeavor to always use 
the most up-to-date version of a tool. In the  envs/ directory, you will find
empty conda environment files for each tool already created for you that you
will need to complete. 

1. Use the appropriate conda command to find the most recent version of each tool
available on bioconda and update the YML files accordingly. Keep in mind the 
following:

- The command is `conda search -c conda-forge -c bioconda <tool_name>`
- Use the most up-to-date version and specify it as so: `tool_name=<version>`, 
which will normally look like `samtools=1.17`. Conda will list all available
versions and the most-up-to-date version will be the last one in the list and
should be the numerically highest version. 

2. Only specify a single version of a tool in each YML file. While you can
specify multiple versions of a tool in a single YML file, we will try to 
minimize this as much as possible to avoid running into issues with conda being
unable to resolve the dependencies. 

3. Once you've filled in the YML files, add the relative path to the YML file
for each process after the line that begins with `conda` in the process. 

This will look something like below:

```
process EXAMPLE {
    label 'process_single'
    conda 'envs/<name_of_yml_file>.yml
    ...
}
```
Make sure to replace <name_of_yml_file> with the name of the YML file you created
and with no <> characters in the final replacement. Now when you run nextflow, it 
will build and load the appropriate conda environment for each process. 

Please note how the path is relative to where the week1.nf file is located. 

### Finding the appropriate commands for FastQC and filtlong

You'll notice that the `script` block for the `FASTQC` and `FILTLONGER`
processes in week1.nf are blank. Flye's command is already provided for you,
since it's a more complex, computationally expensive step to iterate on — but
you will need to find the appropriate commands for FastQC and filtlong and
fill them in yourself.

1. For FastQC, you may use the quick start command provided in the
documentation.

2. For filtlong, you may use the quick start command provided in the
documentation. Choose the command for running **without an external
reference**.

A few hints:

- You can refer to a field on a record using the `$` symbol followed by the
variable name and the field, since we typically save the whole record to one
named variable in `input:` rather than unpacking it into separate variables.
i.e. if the input is declared as `reads: FastqRead`, you'd refer to its file
with `$reads.read`.
- You can make strings by using string interpolation "${variable_name}.txt"
will create a string using the value of the variable_name variable - i.e. if
variable_name is "test", then "${variable_name}.txt" will create the string
"test.txt".
- The file created by the tool should be specified in the `output` block of
the process.

Once you have found the appropriate commands, fill in the `script` block for
each of the two processes in week1.nf.

Once you've filled in your environments, wired up the `conda` paths, and
written the FastQC and filtlong commands, run the pipeline with the `-stub`
flag to confirm the pipeline logic and channel wiring are correct:

```bash
nextflow run week1.nf -stub
```

This command should finish nearly instantaneously, since a `-stub` run
executes each process's `stub:` block (the placeholder `touch` commands)
instead of its real `script:` block, and doesn't require building the conda
environments. That means a successful stub run only tells you that your
channels and processes are wired together correctly and producing outputs
named the way downstream steps expect — it does **not** confirm that your
conda environments resolve or that the FastQC/filtlong commands you wrote are
actually correct. If you want to sanity check those separately, you can test
a command directly in a terminal with the appropriate environment activated.
Later in the semester, once we're confident in the full pipeline, we'll
switch to running it for real. 

## Week 1 Recap

- [ ] Clone the github repo for this project
- [ ] Familiarize yourself with the directory you are working in
- [ ] Annotate the channel logic in week1.nf
- [ ] Complete the Pipeline Steps, Environment and Reproducibility, and
Validation Table sections of specifications.md
- [ ] Specify the appropriate computational environments for each process in the YML
file and add the path to each YML file in the appropriate process
- [ ] Find the appropriate commands for FastQC and filtlong and fill them in
- [ ] Run the pipeline with `-stub` and confirm it completes successfully