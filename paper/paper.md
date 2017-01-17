---
title: "PopperCI: Automated Reproducibility Validation"
author:
- name: "Ivo Jimenez"
  affiliation: "_UC Santa Cruz_"
  email: "`ivo@soe.ucsc.edu`"
- name: "Carlos Maltzahn"
  affiliation: "_UC Santa Cruz_"
  email: "`carlosm@soe.ucsc.edu`"
abstract: |
  PopperCI is a service hosted at UC Santa Cruz that allows 
  researchers to automate the end-to-end execution and validation of 
  experiments. PopperCI assumes that experiments follow Popper, a 
  recently proposed convention for implementing experiments and 
  writing articles following a DevOps approach. PopperCI can be used 
  to run experiments on public or government-fundend cloud 
  infrastructures. In this paper we describe the design and 
  implementation of PopperCI, and present a use case that illustrates 
  the usefulness of this service.
documentclass: ieeetran
ieeetran: true
classoption: "conference,compsocconf"
monofont-size: scriptsize
numbersections: true
usedefaultspacing: true
fontfamily: times
linkcolor: black
secPrefix: section
---

# Introduction

Independently validating experimental results in the field of computer 
systems research is a challenging task [@freire_computational_2012 ; 
@fursin_collective_2013]. Recreating an environment that resembles the 
one where an experiment was originally executed is a time-consuming 
endeavour [@collberg_repeatability_2015 ; @hoefler_scientific_2015]. 
Popper [@jimenez_popper_2016 ; @jimenez_standing_2016] is a convention 
for conducting experiments and writing academic article’s following a 
DevOps [@kim_devops_2016] approach that allows researchers to generate 
work that is easy to reproduce. While being Popper-compliant doesn't 
require projects to structure an experiment's artifacts in any 
particular way, organizing projects in the way it is described here 
allows experimenters to make use of PopperCI, a service hosted at UC 
Santa Cruz that allows researchers to automate the end-to-end 
execution and validation of experiments.

This paper introduces PopperCI, the service that executes and 
validates experiment implementations without requiring manual 
intervention. We first give a brief description of the Popper 
convention (@Sec:popper) and how experiment validations are codified 
(@Sec:validations). We then describe PopperCI (@Sec:popperci), 
followed by a use case that illustrates the usefulness of the service 
(@Sec:usecase). We briefly review related work (@Sec:related) and 
close with a brief discussion, and outline for future work 
(@Sec:conclusion).

![This will show the PopperCI pipeline.
](figures/devops_approach.png){#fig:popperci}

# Popper and Experiment Validations

In this section we give a brief introduction to Popper 
[@jimenez_popper_2016 ; @jimenez_standing_2016], in particular we look 
at how experiment validations are codified.

## Popper {#sec:popper}

Popper revisits the idea of an executable paper 
[@strijkers_executable_2011 ; @dolfi_model_2014 ; 
@leisch_executable_2011 ; @kauppinen_linked_2011], which proposes the 
integration of executables and data with scholarly articles to help 
facilitate its reproducibility. The goal of Popper is to implement 
executable papers in today's cloud-computing world by treating an 
article as an open source software (OSS) project. Popper is realized 
in the form of a convention for systematically implementing the 
different stages of the experimentation process following a DevOps 
[@kim_devops_2016] approach (see @Fig:devops-approach). The convention 
can be summarized by the following three high-level guidelines:

 1. Pick a DevOps tool for each stage of the scientific 
    experimentation workflow.
 2. Put all associated scripts (experiment and manuscript) in version 
    control, in order to provide a self-contained repository.
 3. Document changes as experiment evolves, in the form of version 
    control commits.

By following these guidelines researchers can make all associated 
artifacts publicly available with the goal of minimizing the effort 
for others to re-execute and validation experiments.

![A generic experimentation workflow typically followed by researchers 
in projects with a computational component viewed through a DevOps 
looking glass. The logos correspond to commonly used tools from the 
"DevOps toolkit". From left-to-right, top-to-bottom: git, mercurial, 
subversion (code); docker, vagrant, spack, nix (packaging); git-lfs, 
datapackages, artifactory, archiva (input data); bash, ansible, 
puppet, slurm (execution); git-lfs, datapackages, icinga, nagios 
(output data and runtime metrics); jupyter, paraview, travis, jenkins 
(analysis, visualization and continuous integration); restructured 
text, latex, asciidoctor and markdown (manuscript); gitlab, bitbucket 
and github (experiment changes).
](figures/devops_approach.png){#fig:devops-approach}

## Experiment Validations {#sec:validations}

One optional but important component in Popper is the validation of 
experiments by explicitly codifying expectations. These 
domain-specific tests ensure that the claims made about the results of 
an experiment are valid after every re-execution. An example of this 
is performance regression testing done in software projects (e.g. 
[ScalaMeter](https://scalameter.github.io)). In general, this can be 
part of the analysis/visualization phase of the experimentation 
workflow. To illustrate this stage further, consider an experiment 
that measures the scalability of the system as the number of nodes 
increases. One assertion might be like the following:

```sql
IF
  NOT network_saturated AND num_nodes=*
THEN
  system_throughput >= (baseline_throughput * 0.9)
```

The above is written in the Aver[^aver] [@jimenez_aver_2016] language 
and expresses linear scalability with respect to the underlying raw 
performance, i.e. "regardless of the number of nodes in the system, 
its throughput is always at least 90% of the raw performance". The 
boolean value for `network_saturated` comes from network metrics that 
are captured at runtime. For example, some switches implement the SNMP 
protocol that allows to identify if the network is getting saturated. 
In general, for experiments in the computer and networking systems 
research domain, most of the data that is used at this stage comes 
from capturing runtime metrics about the underlying resources. 
Monitoring tools such as [Nagios](http://nagios.org) and 
[`collectd`](http://collectd.org) can be used for this purpose. Other 
examples of this type of assertions are: "the runtime of our algorithm 
is 10x better than the baseline when the level of parallelism exceeds 
4 concurrent threads"; or "for dataset A, our model predicts the 
outcome with an error of 95%".

[^aver]: Aver is a language and tool that can be used to check the 
integrity of runtime performance metrics that claims make reference 
to. The tool evaluates simple if-then statements in SQL-like syntax 
against metrics captured in tabular format files (e.g. CSV files).

# PopperCI {#sec:popperci}

Following the Popper convention results in producing self-contained 
experiments and articles, and reduces significantly the amount of work 
that a reviewer or reader has to undergo in order to re-execute 
experiments. However, it still requires manual effort in order to 
re-execute an experiment. For single-node experiments, this is not an 
issue since usually an experiment is executed by typing a couple of 
commands to re-execute and validate an experiment. In the case of 
multi-node experiments, this is not as straight-forward since there is 
a significant amount of effort involved in requesting and configuring 
the hardware.

The idea behind PopperCI is simple: by structuring a project in a 
commonly agreed way, experiment execution and validation can be 
automated without the need for manual intervention. In addition to 
this, the status of an experiment (integrity over time) can be tracked 
by the service hosted at <popperci.falsifiable.us>. In this section we 
describe the workflow that one follows in order to make an experiment 
suitable for automation on the PopperCI service. In the next section, 
we show a use case that illustrates the usage with a concrete example.

## Experiment Folder Structure

A minimal experiment folder structure for an experiment is shown 
below:

```bash
$> tree -a paper-repo/experiments/myexp
paper-repo/experiments/myexp/
|-- README.md
|-- run.sh
|-- validate.sh
```

Every experiment has a `run.sh` and `validate.sh` scripts that serve 
as the interface to the experiment. Both return non-zero exit codes if 
there's a failure. `validate.sh` prints to standard output one line 
per validation, denoting whether a validation passed or not. In 
general, the form for validation results is `[true|false] 
<statement>`. For example:

```bash
[true]  algorithm A outperforms B
[false] network throughput is 2x the IO bandwidth
```

## Special Subfolders

Folders named `docker`, `ansible`, `datapackages` or `vagrant` have 
special meaning. For each of these, tests are executed that check the 
integrity of the associated files. In the example shown below, we have 
an experiment that is orchestrated with [Ansible](http://ansible.com), 
so the associated files are stored in an `ansible` folder. When 
checking the integrity of this experiment, this folder is inspected 
and associated files are checked to see if they're healthy. The 
following is a list of currently supported folder names and their CI 
semantics (support for others is in the making):

  * `docker`. An image is created for every subfolder containing a 
    `Dockerfile`.
  * `ansible`. The YAML syntax for any `.yml` file is checked.
  * `datapackages`. Data packages are checked to see if they can be 
    installed.
  * `vagrant`. The definition of the vagrant machine is checked and 
    `vagrant up` is executed.

```bash
$> tree -a paper-repo/experiments/myexp
paper-repo/experiments/myexp/
|-- README.md
|-- ansible
|   |-- ansible.cfg
|   |-- machines
|   |-- playbook.yml
|   |-- vars.yml
|-- run.sh
|-- validate.sh
```

## CI Functionality

Assuming a user has created an account and linked a git repository at 
<popperci.falsifiable.us>, after a new commit is pushed to the 
repository that stores the experiments, PopperCI goes over the 
following steps:

 1. Ensure that every versioned dependency is healthy. For example, 
    ensure that external repos can be cloned correctly.
 2. Check the integrity of every special subfolder (see previous 
    subsection).
 3. For every experiment, trigger an execution (invokes `run.sh`), 
    possibly launching the experiment on remote infrastructure (see 
    next section).
 4. After the experiment finishes, execute validations on the output 
    (invoke `validate.sh` command).
 5. Keep track of every experiment and report its status.

## Multi-node Experiment Execution

For multi-node experiments that run on remote infrastructure, PopperCI 
leverages [Terraform](https://terraform.io) to initialize the 
resources that an experiment has available to it. A special 
`terraform/` folder contains one or more Terraform [configuration 
files](https://www.terraform.io/docs/configuration/) (JSON-compatible, 
declarative format) that specify the infrastructure that needs to be 
instantiated in order for the experiment to execute. In this case, the 
`run.sh` script assumes that there is a `terraform.tfstate` folder 
that contains the output of the `terraform apply`. For example, this 
folder contains information about the available hostnames or IPs 
assigned by the backend (e.g. AWS's EC2). Once Terraform has 
initialized all the remote resources, the `run.sh` script is invoked.

## PopperCI Dashboard

The website at `popperci.falsifiable.us`, once users have logged in, 
shows the status of the experiments for their projects. For each 
project, there is a table with the follow columns:

```bash
| experiment | revision | status | time | date |
```

There are three possible statuses for every experiment: `FAIL`, `PASS` 
and `GOLD`. Clicking an entry on the above table shows a `validations` 
sub-table with the following columns:

```bash
| validations | status |
```

There are two possible values for the status of a validation, `FAIL` 
or `PASS`. When the experiment status is `FAIL`, this list is empty 
since the experiment execution has failed and validations are not able 
to execute at all. When the experiment status is `GOLD`, the status of 
all validations is `PASS`. When the experiment runs correctly but one 
or more validations fail (experiment's status is `PASS`), the status 
of one or more validations is `FAIL`.

## Popper CLI

Researchers that decide to follow Popper are faced with a steep 
learning curve, especially if they have only used a couple of tools 
from the DevOps toolkit. To lower the entry barrier, we have developed 
a command line interface (CLI) tool[^link:cli] to help bootstrap a 
paper repository that follows the Popper convention and that makes use 
of PopperCI. The CLI tool can list and show information about 
available experiments.

```{#lst:poppercli .bash caption="Initialization of a Popper repo."}
$ cd mypaper-repo
$ popper init
-- Initialized Popper repo

$ popper experiment list
-- available templates ---------------
ceph-rados        proteustm  mpi-comm-variability
cloverleaf        gassyfs    zlog
spark-standalone  torpor     malacology

$ popper add torpor myexp
```

# Use Case {#sec:usecase}

DigitalOcean, Ansible, Docker, Jupyter

In this use case we show an experiment showing.

**NOTE**: We'll show a demo of this experiment.

# Discussion {#sec:discussion}

Heterogeneity is here to stay. Even in HPC settings, scheduling work 
on multi-node, heterogeneous resources is not trivial. Terraform 
allows to abstract this in a clean manner.

PopperCI implicitly defines repeatability and reproducibility in the 
following way:

  * Repeatability. An experiment can be re-executed without errors.
  * Reproducibility. The output of an experiment validates the 
    original experiment.

# Related Work {#sec:related}

We don't know of anything like this yet, we need to investigate what's 
the closest to this.

# Conclusion and Future Work {#sec:conclusion}

Our plan is to create a Terraform provider for CloudLab so that 
researchers can integrate. We could also have one for SLURM so that 
HPC people can use this

# Bibliography

<!-- hanged biblio -->

\noindent
\vspace{-2em}
\setlength{\parindent}{-0.26in}
\setlength{\leftskip}{0.2in}
\setlength{\parskip}{8pt}
