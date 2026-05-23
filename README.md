# Supplementary Thermal Context Analysis

## Overview

This repository contains the code, source data, and outputs used to generate **Supplementary Figure S1** and **Supplementary Table S1** for a manuscript currently under peer review.

The repository is intentionally anonymized for review purposes.

This workflow reconstructs **warm-season bottom-temperature variability** from field observations and uses these observations to provide environmental context for experimental thermal-profile design.

Specifically, the analysis addresses three questions:

1. What bottom temperatures naturally occur at the study site during the warm season?
2. Is the selected ambient experimental temperature environmentally realistic?
3. Does the selected heatwave scenario approximate environmentally relevant warming conditions?

---

## Supplementary outputs

### Supplementary Figure S1

Warm-season bottom-temperature dynamics reconstructed from field observations.

![Supplementary Figure S1](Fig_S1_field_bottom_temperature_aligned.png)

The figure shows:

- observed daily mean bottom temperatures during warm seasons
- the selected ambient experimental reference temperature (**27 °C**)
- the simulated marine heatwave treatment temperature (**31 °C**)
- temporal clustering of warm periods
- recovery intervals between warm periods

Grey shading indicates detected warm periods based on consecutive days above the ambient reference threshold.

---

### Supplementary Table S1

Summary statistics of warm-season bottom-temperature conditions.

| Year | Mean (°C) | Max (°C) | Warm days ≥27 °C | Warm periods | Longest (d) | Mean length (d) |
|------|------:|------:|------:|------:|------:|------:|
| 2021 | 27.7 | 30.0 | 104 | 5 | 41 | 23 |
| 2023 | 27.1 | 29.3 | 85 | 5 | 35 | 17 |

These metrics summarize the temporal structure of natural warming and provide environmental context for selecting experimental thermal profiles.

---

## Key observations

- Mean warm-season bottom temperature was close to the selected ambient experimental reference of **27 °C**.
- Daily mean bottom temperatures frequently exceeded **27 °C** during the warm season.
- Warm periods occurred repeatedly and often persisted for multiple days to weeks.
- These field observations support the use of temporally structured warming and recovery profiles in experimental thermal-stress studies.

---

## Data source

Field temperature observations were obtained from the **Cape D’Aguilar monitoring station** through the Aqualink platform.

Source:

https://aqualink.org/sites/2975

Original downloaded file:

```text
data_site_2975_2021_05_20_2026_03_30.csv
```

The analysis uses daily mean bottom-temperature observations to quantify warm-season thermal structure and derive environmentally relevant experimental conditions.

---

## Project concept

Experimental thermal studies often simplify environmental stress into fixed temperature treatments.

This workflow instead begins with **observed environmental conditions** and reconstructs thermal structure before experimental implementation.

Analysis pipeline:

```text
Field observations
      ↓
Daily bottom temperatures
      ↓
Warm-period detection
      ↓
Thermal summary metrics
      ↓
Experimental temperature selection
```

Outputs provide environmental justification for:

- ambient baseline temperature
- simulated heatwave temperature
- warming duration
- recovery structure

---

## Repository contents

```text
.
├── FigS1_n_TableS1.R
├── Fig_S1_field_bottom_temperature_aligned.png
├── Table_S1_field_temperature_summary.csv
├── data_site_2975_2021_05_20_2026_03_30.csv
└── README.md
```

---

## Reproducibility

To reproduce the figure and summary table, run:

```r
source("FigS1_n_TableS1.R")
```

Expected outputs:

```text
Fig_S1_field_bottom_temperature_aligned.png
Fig_S1_field_bottom_temperature_aligned.pdf
Table_S1_field_temperature_summary.csv
field_warm_periods_by_year.csv
```

---

## R workflow

### 1. Import and clean observations

Purpose:

Prepare bottom-temperature observations for analysis.

Main steps:

- import raw field records
- convert timestamps to local time
- remove missing observations
- filter unrealistic temperature values
- retain warm-season data

Output:

clean bottom-temperature dataset

---

### 2. Calculate daily thermal structure

Purpose:

Convert field observations into daily ecological descriptors.

Calculations:

- daily mean bottom temperature
- daily minimum bottom temperature
- daily maximum bottom temperature
- warm-day classification

Definition:

```text
Warm day = daily mean bottom temperature ≥ 27 °C
```

Output:

daily thermal time series

---

### 3. Detect warm periods

Purpose:

Describe temporal thermal structure rather than isolated warm days.

Rules:

- minimum warm-event duration = 2 consecutive warm days
- short cool interruptions are merged
- event durations are summarized

Definition:

```text
Warm period = at least two consecutive warm days
```

Output:

- number of warm periods
- longest warm period
- mean warm-period duration

---

### 4. Generate Supplementary Figure S1

Purpose:

Visualize environmental thermal context.

Figure components:

- observed daily mean bottom-temperature trajectory
- ambient reference line at **27 °C**
- simulated heatwave reference line at **31 °C**
- warm-period shading
- point classification above or below the ambient reference threshold

Output:

publication-ready supplementary figure

---

### 5. Generate Supplementary Table S1

Purpose:

Summarize warm-season bottom-temperature conditions.

Metrics:

- mean bottom temperature
- maximum bottom temperature
- number of warm days
- number of warm periods
- longest warm-period duration
- mean warm-period duration

Output:

supplementary summary table

---

## Software

Tested using:

- R ≥ 4.4
- tidyverse
- lubridate

---

## Notes

This repository contains supplementary analysis code, source data, and environmental context outputs only.

No author-identifying information, manuscript metadata, or review-sensitive materials are included.
