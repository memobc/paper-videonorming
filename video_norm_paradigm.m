function video_norm_paradigm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script runs the norming experiment described in Samide, R.,
% Cooper, R., & Ritchey, M. (under review). A database of news videos for
% investigating the dynamics of emotion and memory. 

% The script plays each video while participants dynamically rate the
% pleasantness. They are also asked to make overall pleasantness, emotional
% arousal, familiartiy, and coherence judgements after each video.
%
% In a memory test, participants are cued with the first 3 seconds of each 
% clip and asked how vividly they can recollect the video content and to
% estimate how long the video was on a continuous scale.
%
% Script author: Rose Cooper - November 2017

% Note. Script assumes a main experiment directory ('myPath'), containing 
% a 'stimuli' folder that includes the video clips in a folder 'movies,' 
% and a 'task' folder that contains VideoOrders.mat (presentation order
% of stimuli per subject, per study/test phase). This script should be run
% from the main 'myPath' directory.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clearvars; close all; clc;

fs = filesep; % so that script works with PC / or MAC \
myPath    = [pwd fs];
taskPath  = [myPath 'task' fs];  %contains task script and presentation orders
stimPath  = [myPath 'stimuli' fs]; %video parent directory
moviePath = [stimPath 'movies' fs]; %list of videos
dataPath  = [myPath 'data' fs]; %to save participant data

% Load presentation orders:
load([taskPath 'VideoOrders.mat']);

numBlocks = 4; %videos divided into 4 study-test blocks

rng(sum(100*clock),'twister');



%% Participant/Session details:

% enter subject details in pop-up
prompt = {'Date (MMDDYY):', ...
        'Subject number:',...
        'Debugging? (default=0):'};
defaults = {'XXXX17','0XX','0'};
answer = inputdlg(prompt,'Experimental setup',1,defaults);

[S.Date, S.subNum, S.debug] = deal(answer{:});

S.debug    = str2num(S.debug);
S.PresOrd  = str2num(S.subNum); %set presentation order (from VideoOrders) to match current subject number

% Specify .mat file name for subject's data 
sFileName = sprintf('sub%s_%s_VideoNormData.mat',S.subNum,S.Date);
% Create directory for subject:
sDir	= [dataPath S.subNum fs];
mkdir(sDir);

% Get presentation order for this subject 
% StudyOrd and TestOrd from VideoOrders.mat, each with 8 columns:
% 1. Study Trial Number
% 2. Video ID number
% 3. Video file name
% 4. Video category label
% 5. Emotion category (pos, neg, neu)
% 6. Duration in seconds
% 7. List (1 or 2 -- each subject views only half of all videos)
% 8. Block (1-4)
S.studyOrder  = StudyOrd{S.PresOrd}(2:end,:);
S.testOrder   = TestOrd{S.PresOrd}(2:end,:);

% Calculate trials in each block:
blkStart = []; blkEnd = [];
for b = 1:numBlocks
blkStart = [blkStart min(find(cell2mat(S.testOrder(:,8))==b))];   
blkEnd   = [blkEnd max(find(cell2mat(S.testOrder(:,8))==b))];         
end



%% Psychtoolbox set up
% ----------------------------------------------------------------------- %
% Basic set up and configures the keyboard using KbName('UnifyKeyNames'):
PsychDefaultSetup(1);

% Skip all timing tests
Screen('Preference', 'SkipSyncTests', 1);

triggerKey    = KbName('s');         % 's' to start experiment
quitKey       = KbName('q');         % 'q' to quit

rightKey    = KbName('RightArrow');
leftKey     = KbName('LeftArrow');
responseKey = KbName('space');

% Set movie rate based on debugging or not
if S.debug ==0
debug_factor = 1;
else % if debugging
debug_factor = 30; %task speeds X times faster if in debugging mode 
end

fixTime       = 0.5/debug_factor; % fixation ITI
cueTime       = 3/debug_factor;   % duration of movie retrieval cue

screenColor   = 0;   % black
textColor     = 255; % white
defaultText   = 42;

HideCursor; % hides mouse from screen

% Get screenNumber to display stimuli.
screens   = Screen('Screens');
screenNum = max(screens);

% Open psychtoolbox window:
[window, winRect] = PsychImaging('OpenWindow', screenNum, screenColor, []); %full screen

% Set text properties:
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, defaultText);

% Get center coords:
[xCenter, yCenter] = RectCenter(winRect);
screenW = winRect(3); screenH = winRect(4);

Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

white = WhiteIndex(window);


% Define slider for rating/temporal scale:
baseRect = [0 0 10 30];
SliderRect = [0 0 800 5];
pixelsPerPress = 16; % how much the curser moves per key press (so 0 - 50 range)

% Inter-trial fixation:
fixFile  = [taskPath 'fix.jpg'];
fix      = imread(fixFile);
fix      = imresize(fix,[screenH*0.1 screenH*0.1]);   
trialfix = Screen('MakeTexture',window,fix);
fixSize  = size(fix);
fixRect  = [xCenter-fixSize(2)/2 yCenter-fixSize(1)/2 xCenter+fixSize(2)/2 yCenter+fixSize(1)/2];



% ----------------------------------------------------------------------- %
try
%% Display movies - STUDY PHASE
% ----------------------------------------------------------------------- %

% Loop through blocks
for blk = 1:numBlocks
    
message = sprintf('Video task - Study phase, block %d \n\nPlease press ''s'' to start',blk);
DrawFormattedText(window,message,'center','center',textColor);
Screen('Flip',window);

% Wait for trigger to start (or quit)
while 1
    [keyDown, ~, keyCodes] = KbCheck(-1);
    if keyDown
        if keyCodes(triggerKey)  % wait for trigger
            break;
        elseif keyCodes(quitKey)
            sca; return;
        end
    end
end
Priority(MaxPriority(window));


for ev = blkStart(blk):blkEnd(blk)

%%% Fixation before encoding trial
    Screen('DrawTexture', window, trialfix,[],fixRect);
    Screen('Flip',window);
    WaitSecs(fixTime);
    
    
% 1. PLAY MOVIE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open movie file:
curMovie = [moviePath S.studyOrder{ev,3}];
[movie,~,~,imgw,imgh] = Screen('OpenMovie', window, curMovie); %all 640 pixels wide but height varies
imgw = imgw*1.5;
imgh = imgh*1.5;

% Define size of movie window
mRect = [xCenter-(imgw/2) yCenter-(imgh/2) xCenter+(imgw/2) yCenter+(imgh/2)];

% Position for rating slider - starts in a random position
LineY = yCenter + (imgh/2) + 150;
LineX = xCenter - 400 + (randi([1 49])*pixelsPerPress); % random start point
centeredSlider = CenterRectOnPointd(SliderRect, xCenter, LineY);


% Start playback engine with movie, rate, loop, no sound (0) or sound (1.0):
Screen('PlayMovie', movie, debug_factor, [], 1.0);
S.onset_movieEnc(ev) = GetSecs;


TimeCount = 0; % to store dynamic plesantness key presses - records
% position of slider every 100ms (so same number of ratings for each
% subject per video)
recordTime = S.onset_movieEnc(ev); % start of video

% Playback loop: Runs until end of movie
while 1
    [~, ~, keyCode] = KbCheck(-1);
    
   if max(keyCode) ==1  % if participant has pressed key
       if keyCode(quitKey) % allows to quit program in middle of a video
            sca; return;
       else
       if keyCode(leftKey) % if moving down in pleasantness
            LineX = LineX - pixelsPerPress;
          if LineX < (xCenter-400)  % never go lower than 0
             LineX = xCenter-400; end
       elseif keyCode(rightKey) % if moving up in pleasantness
            LineX = LineX + pixelsPerPress;
          if LineX > (xCenter+400)  % never go above 800 (length of scale)
             LineX = xCenter+400; end    
       end
       end
   end
   
    % Wait for next movie frame, retrieve its texture handle 
    tex = Screen('GetMovieImage', window, movie);
    
    % Valid texture returned? A negative value means end of movie reached:
    if tex<=0
        % We're done, break out of loop:
        break;
    end
    
    % Draw the new texture immediately to screen:
    Screen('DrawTexture', window, tex, [], mRect);
    
    % Draw the dyanmic plesantness rating scale 
    DrawFormattedText(window,'Pleasantness','center',yCenter+(imgh/2) + 100,textColor);
    DrawFormattedText(window,'Extremely Unpleasant',xCenter - 600,yCenter+(imgh/2) + 220,textColor);
    DrawFormattedText(window,'Extremely Pleasant',xCenter + 200,yCenter+(imgh/2) + 220,textColor);
    centeredRect = CenterRectOnPointd(baseRect, LineX, LineY); %updated pointer on scale
    Screen('FillRect', window, white, centeredSlider);
    Screen('FillRect', window, white, centeredRect);
    
    % Update display:
    Screen('Flip', window);
    
    % Release texture:
    Screen('Close', tex);
    
   % Store position of slider every 100ms:
   if GetSecs >= recordTime + 0.1 %if moved on at least 100ms since last recorded
   TimeCount = TimeCount + 1;
   recordTime = GetSecs;
   S.dynamicKey{ev}(TimeCount)  = (LineX - xCenter + 400)/pixelsPerPress; %convert from pixels to seconds range (0-50)
   S.dynamicTime{ev}(TimeCount) = recordTime;
   end
   
end % end of while loop for movie playback

% Stop playback:
Screen('PlayMovie', movie, 0);

% Close movie:
Screen('CloseMovie', movie);

%%% Fixation before questions
    Screen('DrawTexture', window, trialfix,[],fixRect);
    Screen('Flip',window);
    WaitSecs(fixTime);

    
% 2. ASK FOR RATINGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% A) Overall pleasantness:

message = '1) How pleasant did you find the video overall?';
DrawFormattedText(window,message,'center',yCenter,textColor);
message = 'Extremely Unpleasant -   1     2     3     4     5     6     7     8     9   - Extremely Pleasant';
DrawFormattedText(window,message,'center',yCenter + 200,textColor);

Screen('Flip',window);
S.onset_valence(ev) = GetSecs;

exit = 0; key = -1;
while exit ==0
    [~, pressTime, keyCode] = KbCheck(-1); % waits for a key press
    if max(keyCode) ==1
       key = min(find(keyCode==1));
        if key >=30 && key <=38 % move on only if participant responded between 1 and 9
          exit = 1;
        end
    end
end

S.valenceRT(ev)  = pressTime - S.onset_valence(ev);
S.valenceKey(ev) = key-29; % convert to 1-9

%%% Fixation 
Screen('DrawTexture', window, trialfix,[],fixRect);
Screen('Flip',window);
WaitSecs(fixTime);


% B) Overall Emotional Arousal/Intensity:

message = '2) How emotionally intense did you find the video overall?';
DrawFormattedText(window,message,'center',yCenter,textColor);
message = 'Not at all Intense -   1     2     3     4     5     6     7     8     9   - Extremely Intense';
DrawFormattedText(window,message,'center',yCenter + 200,textColor);

Screen('Flip',window);
S.onset_arousal(ev) = GetSecs;

% Collect arousal response:
exit = 0; key = -1;
while exit ==0
    [~, pressTime, keyCode] = KbCheck(-1); % waits for a key press
    if max(keyCode) ==1
       key = min(find(keyCode==1));
        if key >=30 && key <=38 % move on only if participant responded between 1 and 9
          exit = 1;
        end
    end
end

S.arousalRT(ev)  = pressTime - S.onset_arousal(ev);
S.arousalKey(ev) = key-29; % convert to 1-9

%%% Fixation 
Screen('DrawTexture', window, trialfix,[],fixRect);
Screen('Flip',window);
WaitSecs(fixTime);


% C) Familiarity:

message = '3) Have you seen or heard of this news story before?';
DrawFormattedText(window,message,'center',yCenter,textColor);
message = '1 - Yes, I have seen this exact news footage before';
DrawFormattedText(window,message,'center',yCenter + 150,textColor);
message = '2 - Yes, I am familiar with the news story, but I have not seen this footage';
DrawFormattedText(window,message,'center',yCenter + 200,textColor);
message = '3 - No, I have not seen or heard of this news story before';
DrawFormattedText(window,message,'center',yCenter + 250,textColor);

Screen('Flip',window);
S.onset_familiar(ev) = GetSecs;

% Collect familiarity response:
exit = 0; key = -1;
while exit ==0
    [~, pressTime, keyCode] = KbCheck(-1); % waits for a key press
    if max(keyCode) ==1
       key = min(find(keyCode==1));
        if key >=30 && key <=32 % move on only if participant responded between 1 and 3
          exit = 1;
        end
    end
end

S.familiarityRT(ev)  = pressTime - S.onset_familiar(ev);
S.familiarityKey(ev) = key-29; % convert to 1-2

%%% Fixation 
Screen('DrawTexture', window, trialfix,[],fixRect);
Screen('Flip',window);
WaitSecs(fixTime);


% D) Coherence:

message = '4) Was the plot of this news story easy to follow?';
DrawFormattedText(window,message,'center',yCenter,textColor);
message = '1 - YES          2 - NO';
DrawFormattedText(window,message,'center',yCenter + 200,textColor);

Screen('Flip',window);
S.onset_coherence(ev) = GetSecs;

% Collect coherence response:
exit = 0; key = -1;
while exit ==0
    [~, pressTime, keyCode] = KbCheck(-1); % waits for a key press
    if max(keyCode) ==1
       key = min(find(keyCode==1));
        if key >=30 && key <=31 % move on only if participant responded between 1 and 2
          exit = 1;
        end
    end
end

S.coherenceRT(ev)  = pressTime - S.onset_coherence(ev);
S.coherenceKey(ev) = key-29; % convert to 1-2

%%% Fixation 
Screen('DrawTexture', window, trialfix,[],fixRect);
Screen('Flip',window);
WaitSecs(fixTime);


% ---------------------------------------------------------------------- %
end %end of loop through trials %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% ----------------------------------------------------------------------- %
%% Memory test on videos
% ----------------------------------------------------------------------- %

message = sprintf('Video task - Test phase, block %d \n\nGet ready to start...',blk);
DrawFormattedText(window,message,'center','center',textColor);
Screen('Flip',window);
WaitSecs(5);


for ev = blkStart(blk):blkEnd(blk) % ----------- > start of loop

%%% Fixation before trial
Screen('DrawTexture', window, trialfix,[],fixRect);
Screen('Flip',window);
WaitSecs(fixTime);

% Play 3 second clip of movie as the 'cue': %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Open movie file:
curMovie = [moviePath S.testOrder{ev,3}];
[movie,~,~,imgw,imgh] = Screen('OpenMovie', window, curMovie); % all 640 pixels wide but height varies
imgw = imgw*1.5;
imgh = imgh*1.5;

% Define size of movie window
mRect = [xCenter-(imgw/2) yCenter-(imgh/2) xCenter+(imgw/2) yCenter+(imgh/2)];

% Start playback engine with movie, rate, loop, no sound (0) or sound (1.0):
Screen('PlayMovie', movie, debug_factor, [], 1.0);
S.onset_movieRet(ev) = GetSecs;

recordTime = S.onset_movieRet(ev); %start of video

% Playback loop
while GetSecs < recordTime + cueTime  %only show 3 second cue for retrieval
   
    % Wait for next movie frame, retrieve texture handle to it
    tex = Screen('GetMovieImage', window, movie);
    
    % Valid texture returned? A negative value means end of movie reached:
    if tex<=0
        % We're done, break out of loop:
        break;
    end
    
    % Draw the new texture immediately to screen:
    Screen('DrawTexture', window, tex, [], mRect);
    % Update display:
    Screen('Flip', window);
    % Release texture:
    Screen('Close', tex);
   
end % end of while loop for movie playback

% Stop playback:
Screen('PlayMovie', movie, 0);
% Close movie:
Screen('CloseMovie', movie);

% ----------------------------------------------------------------------%
% Question 1 - visual vividness:

message = 'How vividly can you recollect the visual content of this video?';
DrawFormattedText(window,message,'center',yCenter,textColor);
message = 'Not at all Vividly -   1     2     3     4     5     6     7     8     9   - Extremely Vividly';
DrawFormattedText(window,message,'center',yCenter + 100,textColor);

Screen('Flip',window);
S.onset_VisViv(ev) = GetSecs;

% Collect visual vividness response:
exit = 0; key = -1;
while exit ==0
    [~, pressTime, keyCode] = KbCheck(-1); % waits for a key press
    if max(keyCode) ==1
       key = min(find(keyCode==1));
        if key >=30 && key <=38 % move on only if participant responded between 1 and 9
          exit = 1;
        end
    end
end

S.visVividRT(ev)  = pressTime - S.onset_VisViv(ev);
S.visVividKey(ev) = key-29; %convert to 1-9


% Question 2 - auditory vividness:

%%% Fixation before trial
Screen('DrawTexture', window, trialfix,[],fixRect);
Screen('Flip',window);
WaitSecs(fixTime);

message = 'How vividly can you recollect the auditory content of this video?';
DrawFormattedText(window,message,'center',yCenter,textColor);
message = 'Not at all Vividly -   1     2     3     4     5     6     7     8     9   - Extremely Vividly';
DrawFormattedText(window,message,'center',yCenter + 100,textColor);

Screen('Flip',window);
S.onset_AudViv(ev) = GetSecs;

% Collect auditory vividness response:
exit = 0; key = -1;
while exit ==0
    [~, pressTime, keyCode] = KbCheck(-1); %waits for a key press
    if max(keyCode) ==1
       key = min(find(keyCode==1));
        if key >=30 && key <=38 %move on only if participant responded between 1 and 9
          exit = 1;
        end
    end
end

S.audVividRT(ev)  = pressTime - S.onset_AudViv(ev);
S.audVividKey(ev) = key-29; %convert to 1-9


% Question 3 - duration estimate

%%% Fixation before trial
Screen('DrawTexture', window, trialfix,[],fixRect);
Screen('Flip',window);
WaitSecs(fixTime);

% Position for duration slider - starts in a random position
LineY = yCenter + 150;
LineX = xCenter - 400 + (randi([1 49])*pixelsPerPress); %random start point
centeredSlider = CenterRectOnPointd(SliderRect, xCenter, LineY);


exit = 0;   % keep changing (going through loop) stimulus until chosen
S.onset_duration(ev) = GetSecs;

% Collect duration estimate response - self-paced
while exit == 0
    [~, pressTime, keyCode] = KbCheck(-1);
    
   if max(keyCode) ==1  % if participant has pressed key
       if keyCode(responseKey)%if participant confirmed response
            exit = 1;
       else % if participant not responded yet
       if keyCode(leftKey) % if moving down in duration
            LineX = LineX - pixelsPerPress;
          if LineX < (xCenter-400)  % never go lower than 0
             LineX = xCenter-400; end
       elseif keyCode(rightKey) % if moving up in duration
            LineX = LineX + pixelsPerPress;
          if LineX > (xCenter+400)  % never go above 800 (length of scale)
             LineX = xCenter+400; end    
       end
       end
   end
      
    message = 'How long was the video (in seconds)?';
    DrawFormattedText(window,message,'center',yCenter,textColor);
    message = '10          20          30          40          50          60';
    DrawFormattedText(window,message,'center',yCenter + 220,textColor);

    centeredRect = CenterRectOnPointd(baseRect, LineX, LineY);
    Screen('FillRect', window, white, centeredSlider);
    Screen('FillRect', window, white, centeredRect);
    
    % Update display:
    Screen('Flip', window);
   
end % end of while loop

  S.durationRT(ev)  = pressTime - S.onset_duration(ev);
  S.durationKey(ev) = (LineX - xCenter + 400)/pixelsPerPress; %so range from 0-50 (10-60s);


% ---------------------------------------------------------------------- %
end % end of loop through trials %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Fixation  after all trials in block
Screen('DrawTexture', window, trialfix,[],fixRect);
Screen('Flip',window);
WaitSecs(fixTime);


% save data after each block:
save([sDir sFileName],'S');

    
end % end of loop through blocks

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
message = 'End of Experiment! \n\nPlease press any key to exit.';
DrawFormattedText(window,message,'center','center',textColor);
Screen('Flip',window);
KbStrokeWait(-1);
Screen('Close',window);


catch ME
Screen('Close',window);
fprintf('Error: %s\n',ME.message)
end % end of try loop
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
