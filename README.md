
# Supplementary Thermal Context Analysis

## Overview

This repository contains the code and outputs used to generate **Supplementary Figure S1** and **Supplementary Table S1** accompanying a peer-reviewed manuscript currently under review.

The repository is intentionally anonymized for peer-review purposes.

This project reconstructs **warm-season bottom-temperature dynamics** from field observations and translates them into an ecologically grounded thermal framework for experimental design.

The workflow was developed to answer three questions:

1. What temperatures naturally occur at the study site during the warm season?
2. Is the selected ambient temperature biologically realistic?
3. Does the simulated marine heatwave scenario reflect environmentally relevant warming?

---

## Project concept

Experimental studies often simplify thermal stress into fixed temperatures.

This workflow instead begins with **observed field temperatures** and derives experimental conditions from natural thermal structure.

The analysis:

Field observations
→ daily bottom temperature
→ warm-period detection
→ thermal summary metrics
→ experimental temperature selection

Outputs provide environmental justification for:
- ambient baseline temperature
- heatwave treatment temperature
- duration and recovery logic

---

## Repository contents

```
.
├── FigS1_n_TableS1.R
├── Fig_S1_field_bottom_temperature_aligned.png
├── Table_S1_field_temperature_summary.csv
├── README.md
```

---

## R workflow

### 1. Import and clean observations

Purpose:
Prepare bottom-temperature observations for analysis.

Main operations:
- import raw observations
- convert dates
- remove missing values
- retain warm-season records

Output:
clean daily dataset

---

### 2. Calculate daily thermal structure

Purpose:
Convert observations into ecological metrics.

Calculations:
- daily mean temperature
- daily maximum
- warm-day classification

Definition:

Warm day:
daily mean ≥ ambient threshold

Output:
daily thermal time series

---

### 3. Detect warm periods

Purpose:
Describe temporal structure rather than isolated hot days.

Rules:

- minimum warm-event duration = 2 consecutive days
- short cool interruptions are merged
- duration statistics are calculated

Output:
- number of warm periods
- longest warm period
- mean warm duration

---

### 4. Generate Supplementary Figure S1

Purpose:
Visualize field temperature context.

Figure layers:

- temperature trajectory
- ambient reference line
- simulated heatwave reference
- warm-period shading
- threshold classification

Output:
publication-ready figure

---

### 5. Generate Supplementary Table S1

Purpose:
Summarize warm-season conditions.

Metrics:

- mean temperature
- maximum temperature
- warm days
- warm periods
- longest duration
- mean duration

Output:
supplementary summary table

---

## Software

Tested using:

- R (4.4+)
- tidyverse
- lubridate

---

## Notes

This repository contains analysis code and supporting outputs only.

No identifying information, manuscript metadata, or review-sensitive details are included.
