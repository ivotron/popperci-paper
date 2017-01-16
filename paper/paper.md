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
convention and how experiment validations are codified (@Sec:popper). 
We then describe PopperCI (@Sec:popperci), followed by a use case that 
illustrates the usefulness of the service (@Sec:usecase). We briefly 
review related work (@Sec:related) and close with a brief discussion, 
and outline for future work (@Sec:conclusion).

# Popper and Experiment Validations

In this section we give a brief introduction to Popper 
[@jimenez_popper_2016 ; @jimenez_standing_2016], in particular we look 
at how experiment validations are codified.

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
increases. One assertion

The above expression is written in the Aver [@jimenez_aver_2016] 
language. Aver is a language and tool that can be used to check the 
integrity of runtime performance metrics that claims make reference 
to. Examples of these type of assertions are: "the runtime of our 
algorithm is 10x better than the baseline when the level of 
parallelism exceeds 4 concurrent threads"; or "for dataset A, our 
model predicts the outcome with an error of 95%". A more concrete 
example is given in @Sec:usecase.

# PopperCI {#sec:popperci}

# Use Case {#sec:usecase}

DigitalOcean, Ansible, Docker, Jupyter

In this use case we show an experiment showing.

**NOTE**: We'll show a demo of this experiment.

# Discussion {#sec:discussion}

PopperCI implicitly defines

# Related Work {#sec:related}

We don't know of anything like this. This is the cutting edge.

# Conclusion and Future Work {#sec:conclusion}

Our plan is to create a Terraform provider for CloudLab so that 
researchers can integrate.

# Bibliography

<!-- hanged biblio -->

\noindent
\vspace{-2em}
\setlength{\parindent}{-0.26in}
\setlength{\leftskip}{0.2in}
\setlength{\parskip}{8pt}
