# Admissions Data

This simple repo contains an `R` script that demonstrates how quickly and easily you can download data from [IPEDS]("http://www.nces.ed.gov/ipeds") and manipulate the data programmatically.  Recently, we were talking internally about national admit rates and where we stood on that spectrum.  

As luck would have it, I saw the following [tweet](https://twitter.com/karlynmb/status/474549593724964864).  

Because grabbing the data with `R` is so easy, I took a few minutes to calculate the answer myself.  In short, 281 schools admit less than half of their applicants.  However, because schools have the ability to report data from 2 years ago (as opposed to last year), we need to control for the reporting date.  For schools that reported Fall 2012 data, 226 schools had admit rates < 50%.


## Admit rate distribution

The image below shows the histogram of schools in our universe by admit rate.  It's clear that the majority of institutions accept more applicants than they deny.

![Histogram]("figs/hist.png")



## Admit and Yield

I also wanted to look at the correlation of admit rate and yield rate.

![Scatter]("figs/Admit-Yield.png")

