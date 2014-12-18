
function data = loadEximia(filename,ch)
%read .nxe files, extracts desired channels, transforms to microvolts (only
%EEG channels)
%ch1=TMS triggers, ch2 and ch3=additional triggers, ch4=EOG, ch5-ch64=EEG channels

fid=fopen(filename,'r','l');

BLOCKLENGTH=60;
dataFormat='int16'; 
Samp_Rate=1450;
nchan=64;
info = dir(filename);
filesize=info(1).bytes;
nsamp=filesize/(nchan*2);
sf_EEG=(1/2000)*(10/65535)*1000000;
%gain=2000;-+5v=range of 10;16bit=65535;1volt=1000000 microV

data = zeros(length(ch),nsamp);
totSec = nsamp/Samp_Rate;

blockSize = BLOCKLENGTH*Samp_Rate;
totBlocks = fix(totSec/BLOCKLENGTH);
remSamps = mod(nsamp,blockSize);

%reads blocks
for i=1:totBlocks
	startSamp = blockSize*(i-1) + 1;
	endSamp = startSamp + blockSize - 1;
  	tmp = fread(fid,[nchan, blockSize], dataFormat);
	data(:,startSamp:endSamp) = tmp(ch,:);
end

%adds residuals
if remSamps > 0
	startSamp = totBlocks*blockSize + 1;
	endSamp = startSamp + remSamps - 1;
	tmp = fread(fid,[nchan, remSamps], dataFormat);
	data(:,startSamp:endSamp) = tmp(ch,:);
end
fclose(fid);

data=(data*sf_EEG)';
