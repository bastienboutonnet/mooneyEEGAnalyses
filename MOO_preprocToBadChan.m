% This script runs the initial and time consuming routines which
% are usually ran at night especially if ICA decomposition is included
%
% Author: Bastien Boutonnet, bastien.b@icloud.com
 
 
subject={'4'};
 
pathname_read='~/data/heri/Bastien/mooneys/EEG/toAnalyse/';
pathname_write='~/data/heri/Bastien/mooneys/EEG/toCheckBadChan/';
pathname_eventTracker='~/data/heri/Bastien/mooneys/eventTrackers/';
pathname_chanLocs='~/data/heri/Bastien/mooneys/EEG/scripts/';

%BadChannelDictionary
%subjects={'1',...
 %   '2'};
%badChans={[1,2],...
 %   2};
%badChanDict=containers.Map(subjects,badChans);
 
for s=1:length(subject)
   fprintf('Processing Subject #%g : %s...\n', s, subject{s});
 
%creates the destination folder assuming you have not created it manually before
%if test makes sure the folder only gets created once.
    if isequal(exist(pathname_write, 'dir'),7) %7 = directory
        display('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Destination folder exists. All Good to go!');
    else
        [mdirstatus, mdirmessage]=mkdir(pathname_write)
        display('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Destination folder does not exist. Chillax! Will be created');
    end


%TODO:
%Implement data structure for badchannels
%Implement channel interpolation



%ch2 = trig1: prime
%ch3 = trig2: target

    filename = [pathname_read,'MOOS',subject{s},'_1.nxe'];



    EEGdata = loadEximia(filename, [1:64]);
    EEGdata = EEGdata';

    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    EEG = pop_importdata('dataformat','array','nbchan',64,'data','EEGdata','setname',filename,'srate',...
        1450,'subject', 1,'pnts',0,'xmin',0);


    %find triggers
    %prime onset sample
    prime_ind = find(EEGdata(2,:)>200);
    cnt = 1;        
    prime_ind2 = {};
    prime_ind2{1}(1) = prime_ind(1);
            for i = 2:length(prime_ind)
                if (prime_ind(i)-prime_ind(i-1))>1450
                cnt = cnt + 1;
                prime_ind2{1}(cnt) = prime_ind(i);    
                end
            end

            %target onset sample
    targ_ind = find(EEGdata(3,:)>200);
    cnt = 1;        
    targ_ind2 = {};
    targ_ind2{1}(1) = targ_ind(1);
            for i = 2:length(targ_ind)
                if (targ_ind(i)-targ_ind(i-1))>1450
                cnt = cnt + 1;
                targ_ind2{1}(cnt) = targ_ind(i);    
                end
            end

    EEG = eeg_addnewevents(EEG,prime_ind2,{'primeOn'}); 
    EEG = eeg_addnewevents(EEG,targ_ind2,{'targOn'});

    events = importEventFile([pathname_eventTracker,'MOOEEG_',subject{s},'_eventTrackerTest.txt'], 13,1000); %change filename to pick up subjInfo
    t = cell2mat(events(:,1))+1;
    events(:,1) = num2cell(t);

    %import events
    EEG = pop_editeventfield(EEG, 'trialNum', cell2mat(events(:,1)),'compTime',cell2mat(events(:,2)), 'condition',events(:,3), 'pictName', events(:,4),'stimType', events(:,5));

    %remove trig and EOG channels for parstim
    EEG = pop_select( EEG,'nochannel',[1:4]); %THIS MAY HAVE TO BE EXTENDED TO 4
    %load channel locs
    EEG = pop_chanedit(EEG, 'load',{[pathname_chanLocs,'nex_net.LOC'] 'filetype' 'loc'});
    
    %save for bad Channel Inspection
    EEG.setname = [subject{s} '_TRIFBadChan'];
    EEG = pop_saveset( EEG,  'filename', [pathname_write subject{s} '_TRIFBadChan.set']);
end

