###############################################################################
## How many schools admit less than half of the applicants
###############################################################################

options(stringsAsFactors=F)


## load the packages
library(ggplot2)
library(plyr)


## get the IPEDS data
BASE = "http://nces.ed.gov/ipeds/datacenter/data/"
SURVEYS = c('HD2012', 'IC2012')
SUFFIX = ".zip"
for (SURVEY in SURVEYS) {
  URL = paste0(BASE, SURVEY, SUFFIX)
  download.file(URL, destfile = file.path("data", paste0(SURVEY, SUFFIX)))
  cat("finished ", SURVEY, "\n")
}


## unzip the datasets into CSV
for (FILE in list.files("data", pattern = ".zip$", full.names = T)) {
  unzip(FILE, exdir = "data")
}


## read in the datasets
hd = read.csv("data/hd2012.csv")
colnames(hd) = tolower(colnames(hd))
ic = read.csv("data/ic2012.csv")
colnames(ic) = tolower(colnames(ic))


## keep only a core set of schools
dir = subset(hd, sector %in% c(1, 2))
dir = subset(dir, obereg %in% c(1:8))
dir = subset(dir, pset4flg == 1)
dir = subset(dir, deggrant == 1)
dir = subset(dir, carnegie > 0)  ## has a basic carnegie classification



## keep only the schools in IC that are in the directory of schools
adm = subset(ic, unitid %in% dir$unitid)


## fix the column types
adm$applcn = as.numeric(adm$applcn)
adm$admssn = as.numeric(adm$admssn)
adm$enrlt = as.numeric(adm$enrlt)
adm$enrlft = as.numeric(adm$enrlft)
adm$enrlpt = as.numeric(adm$enrlpt)


## keep only the schools that have valid admissions data 
## NOTE:  I am using data for ANY reported year.  
## NOTE:  Admissions data will not be from the same year for all schools
adm = subset(adm, applcn > 0 & admssn > 0 & enrlt > 0)


## calc some standard admissions metrics
## NOTE:  I am ignoring the year the data actually apply to
adm = transform(adm,
                admit_rate = admssn / applcn,
                yield_rate = enrlt / admssn,
                pct_ft = enrlft / enrlt)


## standardize the metrics against themselves
adm = transform(adm,
                applcn_z = scale(applcn),
                admit_rate_z = scale(admit_rate),
                yield_rate_z = scale(yield_rate),
                pct_ft_z =  scale(pct_ft))

## keep only schools that are +/- 2.5 sigmas
adm = subset(adm, abs(applcn_z) <= 2.5)


## create some ranks (negative value for largest to get 1)
adm = transform(adm,
                applcn_r = rank(-applcn, ties.method="min"),
                admit_rate_r = rank(admit_rate, ties.method="min"),
                yield_rate_r = rank(-yield_rate, ties.method="min"))

## arrange the data by admit rate
adm = arrange(adm, admit_rate_r)

## merge the data
app_data = merge(adm, dir)

## flag the app reporting year
app_data$fall = NA
app_data$fall[app_data$appdate == 1] = "Fall 2011"
app_data$fall[app_data$appdate == 2] = "Fall 2012"


## quick answer: how many admitted less than half of their apps?
sum(as.numeric(app_data$admit_rate < .5))

## do a table by Fall reporting year
with(app_data, table(fall, admit_rate < .5))


## plots
ggplot(app_data, aes(admit_rate, yield_rate)) + 
  geom_point(aes(colour=fall), alpha=.5) + 
  xlab("Yield Rate %") + 
  ylab("Admit Rate %") +
  ggtitle("Admit Rate and Yield Rate Colored \n by the Year Reported by the School")
ggsave(filename="figs/Admit-Yield.png")


ggplot(app_data, aes(admit_rate)) + 
  geom_histogram(fill="blue") + 
  xlab("Admit Rate %") + 
  ggtitle("Frequency Distribution of Admit Rate % for all Schools")
ggsave("figs/hist.png")


# ggplot(app_data, aes(yield_rate, pct_ft)) + geom_point(alpha=.6)
# ggplot(app_data, aes(admit_rate_z, applcn_z)) + geom_point(alpha=.6)
# ggplot(app_data, aes(yield_rate, applcn_z)) + geom_point(alpha=.6) + geom_smooth()


## save out the datasets
saveRDS(app_data, file="data/app-data.rds")
tmp = subset(app_data, select = c(unitid,
                                  instnm,
                                  stabbr,
                                  obereg,
                                  admit_rate,
                                  yield_rate,
                                  pct_ft,
                                  applcn_z,
                                  admit_rate_z,
                                  yield_rate_z,
                                  pct_ft_z,
                                  applcn_r,
                                  admit_rate_r,
                                  yield_rate_r,
                                  carnegie,
                                  longitud,
                                  latitude,
                                  fall,
                                  satpct,
                                  actpct,
                                  satvr75,
                                  satmt75,
                                  actcm75,
                                  acten75,
                                  actmt75))
write.table(tmp, file="data/app-data.csv", sep=",", row.names=F)
