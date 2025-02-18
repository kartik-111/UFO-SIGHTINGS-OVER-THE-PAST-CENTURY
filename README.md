# UFO Sightings Over the Past Century – An Interactive R-Shiny Application  


## Overview  

The idea of life existing in other corners of the universe and visiting our planet has captivated the imagination of millions of people around the globe. This topic has come into the limelight again in the past few years due increased number of sightings in the past few years. This project, with the help of interactive visualizations aims to answers the following questions:

1. Mapping the UFO sightings around the world over the past century and determining the hotspots.

2. Which is the most commonly spotted UFO shape and how to most spotted shape has changed over the decades.

3. Is there a relationship between economic prosperity of a country and the number of UFO sightings? Do wealthier countries have more sightings and do the number of UFO sightings increase as the economic prosperity of a country increases?

## Key Features  
✅ **Interactive UFO Sightings Map** – A globe visualization that maps recorded UFO sightings from the 1930s onwards, categorized by decade.  
✅ **UFO Shape Analysis** – A pie chart and time-series visualization illustrating how the most commonly reported UFO shapes have evolved over time.  
✅ **Economic Prosperity vs. Sightings** – A scatter plot investigating whether wealthier nations report more UFO sightings, using GDP per capita as a measure of prosperity.  
✅ **Data Exploration & Cleaning** – Comprehensive data wrangling processes applied to UFO sighting and GDP datasets, handling missing values, standardizing date formats, and geocoding locations.  
✅ **Fully Interactive UI** – Users can **zoom, hover, filter, and adjust parameters** to explore trends in UFO sightings dynamically.  

## Technology Stack  
- **R-Shiny** – Interactive web app framework for R  
- **tidyverse (dplyr, ggplot2)** – Data manipulation and visualization  
- **plotly** – Interactive graphs and maps  
- **shinythemes & shinyalert** – UI enhancements and notifications  
- **Geopy & JSON Handling (Python preprocessing)** – Geocoding and extracting structured data from raw JSON files  

## Data Sources  
- **UFO Sightings Dataset:** [NUFORC Reports](https://data.world/timothyrenner/ufo-sightings)  
- **Economic Data:** [World Bank GDP per Capita](https://data.worldbank.org/indicator/NY.GDP.PCAP.CD)  

## Data Cleaning & Wrangling  

### **1️UFO Sighting Data**  
- The dataset was extracted from a **raw JSON file** containing **138,018 sightings** dating back to the 1930s.  
- Data fields extracted: `datetime`, `city`, `state`, `country`, `shape`, `duration`, and `summary`.  
- **Challenges:**
  - City names were inconsistent, requiring standardization.
  - The `datetime` field contained mixed formats (`MM/DD/YYYY` and `DD/MM/YYYY`), which were corrected to a uniform `DD/MM/YYYY` format.
  - Missing latitude/longitude coordinates were generated using the **geopy** library in Python.
 
### **GDP per Capita Data
  -Extracted from the World Bank, covering GDP per capita for every country from 1960 onwards.
  -Transformed into decade-wise averages to align with UFO sighting data.

### Merging Data for Visualization
 -The UFO sightings dataset was merged with GDP per capita data based on country and decade.
 -Rows with missing country values or invalid data were removed to improve accuracy.

## Insights & Findings  
📌 **UFO Sightings are geographically skewed:** The USA reports an overwhelming majority of sightings, followed by Canada, the UK, Australia, and India.  
📌 **UFO shapes have changed over time:** Disks were commonly reported in the mid-20th century, while “Lights” have become the dominant shape in recent years.  
📌 **Economic Prosperity Correlation:** The data suggests that countries with higher GDP per capita report more UFO sightings, but **correlation does not imply causation**—factors like media coverage, internet access, and population density may also contribute.  
