library(readr)
library(dplyr)
library(readxl)
library(writexl)

#load data
load("~/Box/CogNeuroLab/Aging Decision Making R01/Data/combined_data_2020-01-30.RData")

cr <- select(d, record_id, actamp:fact, IS:RA)
cr$actquot <- cr$actamp/cr$actmesor
cr <- cr[complete.cases(cr) == TRUE,]

dti = c()
dti$files = list.files("/Volumes/schnyer/Aging_DecMem/Scan_Data/BIDS/derivatives/tbss/origdata/")
dti$record_id = substr(dti$files, 5, 9)

neuro <- read_csv('~/Box/CogNeuroLab/Aging Decision Making R01/Data/Neuropsych/AgingDecMemNeuropsyc_DATA_2019-06-12_0708.csv')

neuro_ya <- readxl::read_xlsx("Box/CogNeuroLab/Aging Decision Making R01/Data/Neuropsych/Neuropsych_Data_YA.xlsx", sheet = "TOTALS")
neuro_oa <- readxl::read_xlsx("Box/CogNeuroLab/Aging Decision Making R01/Data/Neuropsych/Neuropsych_Data_OA.xlsx", sheet = "TOTALS")
colnames(neuro_ya) <- c("record_id", "Executive function")
ef <- rbind(neuro_ya, select(neuro_oa, record_id, `Executive function`))
ef

#create dataframe containing relevant variables
dsnmat <- merge(select(neuro, record_id, age, trails_b_z_score), select(cr, record_id, IS:RA, actamp:fact), by = 'record_id', all=TRUE)
dsnmat <- merge(dti, dsnmat, by = "record_id", all=FALSE)
dsnmat <- merge(dsnmat, ef, by = "record_id")
dsnmat$record_id <- as.character(dsnmat$record_id)

dsnmat$age[dsnmat$record_id == "40876"] = 71
dsnmat$age[dsnmat$record_id == "40878"] = 71

dsnmat_ya <- dsnmat[dsnmat$record_id < 40000, ]
dsnmat_oa <- dsnmat[dsnmat$record_id > 40000, ]

writexl::write_xlsx(dsnmat, '/Volumes/schnyer/Aging_DecMem/Scan_Data/BIDS/derivatives/tbss/dsnmat_data.xlsx')
writexl::write_xlsx(dsnmat_ya, '/Volumes/schnyer/Aging_DecMem/Scan_Data/BIDS/derivatives/tbss/dsnmat_data_ya.xlsx')
writexl::write_xlsx(dsnmat_oa, '/Volumes/schnyer/Aging_DecMem/Scan_Data/BIDS/derivatives/tbss/dsnmat_data_oa.xlsx')

#demean every column
id <- select(dsnmat, record_id, files)
id_ya <- id[id$record_id < 40000, ]
id_oa <- id[id$record_id > 40000, ]

dsnmat <- select(dsnmat, -record_id, -files)
dsnmat_ya <- select(dsnmat_ya, -record_id, -files)
dsnmat_oa <- select(dsnmat_oa, -record_id, -files)

center_colmeans <- function(x) {
  xcenter = colMeans(x, na.rm = TRUE)
  x - rep(xcenter, rep.int(nrow(x), ncol(x)))
}

dsnmat_demeaned <- center_colmeans(dsnmat)
dsnmat_demeaned_ya <- center_colmeans(dsnmat_ya)
dsnmat_demeaned_oa <- center_colmeans(dsnmat_oa)

dsnmat_demeaned <- cbind(id, dsnmat_demeaned)
dsnmat_demeaned_ya <- cbind(id_ya, dsnmat_demeaned_ya)
dsnmat_demeaned_oa <- cbind(id_oa, dsnmat_demeaned_oa)

#save as csv for input into fsl_gui
writexl::write_xlsx(dsnmat_demeaned, '/Volumes/schnyer/Aging_DecMem/Scan_Data/BIDS/derivatives/tbss/dsnmat_demeaned_data.xlsx')
writexl::write_xlsx(dsnmat_demeaned_ya, '/Volumes/schnyer/Aging_DecMem/Scan_Data/BIDS/derivatives/tbss/dsnmat_demeaned_ya_data.xlsx')
writexl::write_xlsx(dsnmat_demeaned_oa, '/Volumes/schnyer/Aging_DecMem/Scan_Data/BIDS/derivatives/tbss/dsnmat_demeaned_oa_data.xlsx')

