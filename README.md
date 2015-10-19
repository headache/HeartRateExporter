# HealthKit Heart Rate Exporter (modified) #

based on application 'HealthKit Heart Rate Exporter' developed by Brad Larson https://github.com/BradLarson/HealthKitHeartRateExporter

## Overview ##

It accesses HealthKit (where the Apple Watch or other Hear Rate devices stores its measurements) and queries for the last 600 (or configurabale amount) heart rate measurements. When it has those values, it logs them out to the console and to a CSV file called "heartratedata.csv". The application has iTunes file sharing enabled, so you can then grab this file from within iTunes. 

CSV line example: 
"Source,Time,Date,Heartrate(BPM)

Apple Watch Pavel",14:05:06,10/19/2015,97.0"

## License ##

Public domain. Don't really care what you do with this.
