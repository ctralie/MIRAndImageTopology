function varargout = ShuffleTest(varargin)
% SHUFFLETEST MATLAB code for ShuffleTest.fig
%      SHUFFLETEST, by itself, creates a new SHUFFLETEST or raises the existing
%      singleton*.
%
%      H = SHUFFLETEST returns the handle to a new SHUFFLETEST or the handle to
%      the existing singleton*.
%
%      SHUFFLETEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHUFFLETEST.M with the given input arguments.
%
%      SHUFFLETEST('Property','Value',...) creates a new SHUFFLETEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ShuffleTest_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ShuffleTest_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ShuffleTest

% Last Modified by GUIDE v2.5 07-Feb-2015 18:36:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ShuffleTest_OpeningFcn, ...
                   'gui_OutputFcn',  @ShuffleTest_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before ShuffleTest is made visible.
function ShuffleTest_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ShuffleTest (see VARARGIN)

disp('Initializing...');
% Choose default command line output for ShuffleTest
handles.output = hObject;
handles.song = [];
handles.cover = [];
handles.confusor = [];
handles.songshuffle = 1;
handles.confusorshuffle = 1;
handles.correct = -1;
handles.currBeat = 1;
handles.order = randperm(3);

% Update handles structure
guidata(hObject, handles);

disp('Finished initializing');

function [Y] = getImage(X)
Y = bsxfun(@minus, mean(X), X);
Norm = 1./(sqrt(sum(Y.*Y, 2)));
Y = Y.*(repmat(Norm, [1 size(Y, 2)]));
Y = squareform(pdist(Y));

function plotImages(handles)
if (~isempty(handles.song) && ~isempty(handles.cover) && ~isempty(handles.confusor))
    PCs = {handles.song{handles.songshuffle(handles.currBeat)}, ...
            handles.cover{handles.songshuffle(handles.currBeat)}, ...
            handles.confusor{handles.confusorshuffle(handles.currBeat)} };
    axes(handles.axes1);
    imagesc(getImage(PCs{handles.order(1)}));
    colormap('jet');
    axis off;
    axes(handles.axes2);
    imagesc(getImage(PCs{handles.order(2)}));
    colormap('jet');
    axis off;
    axes(handles.axes3);
    imagesc(getImage(PCs{handles.order(3)}));
    colormap('jet');
    axis off;
end

%Function that checks if all 3 songs have been loaded
function checkLoaded(handles, hObject)
if ~isempty(handles.song) && ~isempty(handles.cover) && ~isempty(handles.confusor)
    %First truncate to at most 300 beats
    NBeats = min([300, length(handles.song), length(handles.cover), length(handles.confusor)]);
    handles.song = handles.song(1:NBeats);
    handles.cover = handles.cover(1:NBeats);
    handles.confusor = handles.confusor(1:NBeats);
    
    %Now choose a shuffling order for the original and cover, plus
    %a shuffling order for the confusor
    handles.songshuffle = randperm(NBeats);
    handles.confusorshuffle = randperm(NBeats);
    %Keeps track of which beats are correct in their original order
    %-1 indicates not examined yet
    handles.correct = -1*ones(1, NBeats);
    handles.currBeat = 1;
    
    set(handles.text1, 'String', sprintf('1 of %i', length(handles.correct))); 
    
    guidata(hObject, handles);
    plotImages(handles);
end


function nextChosen(selected, handles, hObject)
if ~isempty(handles.song) && ~isempty(handles.cover) && ~isempty(handles.confusor)
    if (handles.order(selected) == 3)
        handles.correct(handles.songshuffle(handles.currBeat)) = 1;
    else
        handles.correct(handles.songshuffle(handles.currBeat)) = 0;
    end
    %Update percent correct and save what the user has done so far
    idx = handles.correct(handles.correct > -1);
    set(handles.text1, 'String', sprintf('%i of %i', length(idx)+1, length(handles.correct)));
    set(handles.text2, 'String', sprintf('%.3g percent Correct', sum(idx)/length(idx)*100.0));
    
    correct = handles.correct;
    save('performance.mat', 'correct');
    
    if (handles.currBeat < length(handles.songshuffle))
        handles.currBeat = handles.currBeat + 1;
        handles.order = randperm(3);
        plotImages(handles);
    end
    plotImages(handles);
    guidata(hObject, handles);
end

% --- Outputs from this function are returned to the command line.
function varargout = ShuffleTest_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nextChosen(1, guidata(hObject), hObject);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nextChosen(2, guidata(hObject), hObject);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nextChosen(3, guidata(hObject), hObject);

% --------------------------------------------------------------------
function loadsong_Callback(hObject, eventdata, handles)
% hObject    handle to loadsong (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s = load(uigetfile());
handles = guidata(hObject);
handles.song = s.PointClouds;
guidata(hObject, handles);
checkLoaded(handles, hObject);

% --------------------------------------------------------------------
function loadcover_Callback(hObject, eventdata, handles)
% hObject    handle to loadcover (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s = load(uigetfile());
handles = guidata(hObject);
handles.cover = s.PointClouds;
guidata(hObject, handles);
checkLoaded(handles, hObject);

% --------------------------------------------------------------------
function loadconfusor_Callback(hObject, eventdata, handles)
% hObject    handle to loadconfusor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s = load(uigetfile());
handles = guidata(hObject);
handles.confusor = s.PointClouds;
guidata(hObject, handles);
checkLoaded(handles, hObject);
