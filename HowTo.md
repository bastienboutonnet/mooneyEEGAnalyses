
##Log in
`ssh -Y bboutonnet@teuber.psych.wisc.edu`
password "dynamics"

If you want (and should?) run matlab from the matlab computer add the following steps
`ssh -Y postlematlab`
enter password again

##Navigate to data folder
This loads the working directory
`cd ~/data/heri/Bastien/mooneys/EEG/toCheckBadChan/`

##Load Dataset
`EEG = pop_loadset('filename','3_TRIFBadChan.set');`

##Plot Continuous Data
pop_eegplot( EEG, 1, 1, 1);

##Spot Bad channels
- scroll through data at several points
- you display more seconds per screen in Settings>Time Range to Display
- you can display less channels per screen (this will allow you to see better which channels are bad) Settings>Number of channels to display

##Keep a record of the bad channels
