MGH_medical_AI
=========================

## Introduction
* This repository records MIT-MGH researches on medical data
* This research is for academic purpose and not for commercial purpose
* All rights reserved to MIT-MGH research team
* The research aims to analyze Mimic III and Biobank data sets, explore approaches to support MD on more effective medical decisions
* Tools used: PostgreSQL 10, Python 3.6.6, Jupyter Notebook

## References
* Alistair E.W. Johnson, Tom J. Pollard, Lu Shen, Li-wei H. Lehman, Mengling Feng, Mohammad Ghassemi, Benjamin Moody, Peter Szolovits, Leo Anthony Celi & Roger G. Mark, Scientific Data volume 3, Article number: 160035 (2016), [Mimic 3 Original Paper](https://www.nature.com/articles/sdata201635)
* MIMIC-III, a freely accessible critical care database. Johnson AEW, Pollard TJ, Shen L, Lehman L, Feng M, Ghassemi M, Moody B, Szolovits P, Celi LA, and Mark RG. Scientific Data (2016). DOI: 10.1038/sdata.2016.35. Available from: http://www.nature.com/articles/sdata201635
* Hrayr Harutyunyan, Hrant Khachatrian, David C. Kale, and Aram Galstyan. Multitask Learning and Benchmarking with Clinical Time Series Data. arXiv:1703.07771 which is now available on [arXiv](https://arxiv.org/abs/1703.07771)



## Files 
Note: All individual stuties have been clear on purpose with cited reference materials
* 1_Mimic3_preview.ipynb - Introduce Mimic III data sets, table correlations, and preload local data (*.csv) for preview
* 2_Mimic3_Postgres_setup.ipynb - Introduce using PostgreSQL to build local database, and Python (in Jupyter Notebook IDE) to query data
* 3_Diabetic_Patients.ipynb - With intereset to analyze diabetic patients, introduce how to make specific queries and analytics
* 4_ML_code_practise - Understand how the ML data reader and basic model works
* 5_ML_new_model - Develop new models for research purpose
