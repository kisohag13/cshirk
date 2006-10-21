function varargout = gui(varargin)
% GUI M-file for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 21-Oct-2006 14:29:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Start off loading an image...
% Don't force user to click button
doLoadImage();


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Load Image; called by loadImage_Callback and program init
function doLoadImage()
[filename, pathname, filteridx] = uigetfile('*.jpg','Load Image');
if (filename ~= 0)
    
    fullname = strcat(pathname, filename);
    global img;
    img = imread(fullname);
    
   
    % Create Area for image
    subplot(2,1,2);
    
    % Now show unmodified image
    imshow(img);
    
    % Turn on mod buttons
    global hRadioTranslation;
    global hRadioPanTilt;
    global hRadioZoom;
    set(hRadioTranslation,'Visible','On');
    set(hRadioPanTilt,'Visible','On');
    set(hRadioZoom,'Visible','On');
    
    % Default to 'Translation' mode
    doRadioTranslation();    
       
end


% --- Executes on button press in loadImage.
function loadImage_Callback(hObject, eventdata, handles)
% hObject    handle to loadImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
doLoadImage();


% --- Track helper function
function doTrack()
% slider_pos  .5    normal
%             < .5  left shift
%             > .5  right shift

global img;
global img2;
global hCameraTrack;

sliderPos = get(hCameraTrack,'Value');

[h,w,d] = size(img);

%
% slider position (.5, 1]? slide image to the right
%
% (slider position - .5) * 2 * w = number of pixels to shift to the right
%
if (sliderPos > 1)
  error 'slider out of range';
    
elseif (sliderPos >= .5)
  px_shift = floor((sliderPos - .5) * 2 * w);
    
  % e.g.: px_shift=64 ==> 65:640 = 1:(640-65)
  img2(1:h, (1+px_shift):w, 1:d) = img(1:h, 1:(w-px_shift), 1:d);
    
  % fill in black
  img2(1:h, 1:px_shift, 1:d) = 0;
    
%  
% slider position [0, .5)? slide image to the left
%
% slider position * 2 * w = number of pixels to shift to the left
%
elseif (sliderPos >= 0)
  px_shift = floor((.5 - sliderPos) * 2 * w);
    
  img2 = img(1:h, (1+px_shift):w, 1:d);
    
  % fill in black
  img2(1:h, (w - px_shift + 1):w, 1:d) = 0;
            
else
  error 'slider out of range';
end




% --- Boom helper function
function doBoom()
% slider_pos  .5    normal
%             < .5  left shift
%             > .5  right shift

global img2;
global hCameraBoom;

sliderPos = get(hCameraBoom,'Value');

[h,w,d] = size(img2);

%
% slider position (.5, 1]? slide image to the right
%
% (slider position - .5) * 2 * w = number of pixels to shift to the right
%
if (sliderPos > 1)
  error 'slider out of range';
    
elseif (sliderPos >= .5)
  px_shift = floor((sliderPos - .5) * 2 * h);
    
  % e.g.: px_shift=64 ==> 65:640 = 1:(640-65)
  imgTmp((1+px_shift):h, 1:w, 1:d) = img2(1:(h-px_shift), 1:w, 1:d);
    
  % fill in black
  imgTmp(1:px_shift, 1:w, 1:d) = 0;
    
%  
% slider position [0, .5)? slide image to the left
%
% slider position * 2 * w = number of pixels to shift to the left
%
elseif (sliderPos >= 0)
  px_shift = floor((.5 - sliderPos) * 2 * h);
  
  imgTmp = img2((1+px_shift):h, 1:w, 1:d);
    
  % fill in black
  imgTmp((h - px_shift + 1):h, 1:w, 1:d) = 0;
            
else
  error 'slider out of range';
end

% Save modified image
img2 = imgTmp;


% --- Pan/tilt helper function
function doPanTilt()
%

global img;
global img2;
global hCameraPan;
global hCameraTilt;

panSliderPos = get(hCameraPan,'Value');
tiltSliderPos = get(hCameraTilt,'Value');

[h,w,d] = size(img);

% Let angles vary from -90 degrees to + 90 degrees
theta_x = pi * tiltSliderPos - pi/2;
theta_y = pi * panSliderPos - pi/2;

% Camera Pan/Tilt
% Assuming parallel projection: x = X, y = Y
%
% pg. 131
% X' = [Rx][Ry]X        (5.5.2)
% Not assuming small angles, so we use (5.5.3) and (5.5.4)
%
% [Rx] = [  1               0               0
%           0               cos(Theta_x)    -sin(Theta_x)
%           0               sin(Theta_x)    cos(Theta_x)    ]
%
% [Ry] = [  cos Theta_y     0               sin Theta_y
%           0               1               0
%           -sin Theta_y    0               cos Theta_y     ]
%
%

Rx = [1   0              0
      0   cos(theta_x)   -sin(theta_x)
      0   sin(theta_x)   cos(theta_x)];

Ry = [cos(theta_y)   0   sin(theta_y)
      0              1   0
      -sin(theta_y)  0   cos(theta_y)];

nExceed = 0;
imgTmp = img; % Need to do this to get some kind of image metadata
imgTmp(1:h,1:w,1:d) = 0; % Black out modified img, initially

% In order to avoid rotating such that it looks like graph is
% in the first quadrant -- make it so the axis is centrally
% aligned w.r.t. the image
%
% Compute x and y offsets by looking at extreme top,right pixel movements
big_X = [w
         h
         0]; % z is irrelevant -- don't care

tmp = Rx * Ry * big_X;
x_offset = floor((w - round(tmp(1))) / 2);
y_offset = floor((h - round(tmp(2))) / 2);

for j=1:h
  for i=1:w
   
    big_X = [i
             j
             0]; % z is irrelevant -- don't care
      
    tmp = Rx * Ry * big_X;
    x = round(tmp(1)) + x_offset;
    y = round(tmp(2)) + y_offset;
    
    if ((x < 1) || (x > w) || (y < 1) || (y > h))
      % Out of bounds, so do nothing
      nExceed = nExceed + 1;
    else
      imgTmp(y,x,1:d) = img(j,i,1:d);
    end
    
  end
end

% Save modified image
img2 = imgTmp;

% --- Executes on slider movement.
function cameraTrack_Callback(hObject, eventdata, handles)
% hObject    handle to cameraTrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Adjust image -- track first, then boom
doTrack();
doBoom();

% Show modified image
global img2;
imshow(img2);


% --- Executes on slider movement.
function cameraBoom_Callback(hObject, eventdata, handles)
% hObject    handle to cameraBoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of
%        slider

% Adjust image -- track first, then boom
doTrack();
doBoom();

% Show modified image
global img2;
imshow(img2);


% --- Executes during object creation, after setting all properties.
function cameraTrack_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cameraTrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

global hCameraTrack;
hCameraTrack = hObject;


% --- Executes during object creation, after setting all properties.
function cameraBoom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cameraBoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

global hCameraBoom;
hCameraBoom = hObject;


% --- Executes during object creation, after setting all properties.
function cameraTrackLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cameraTrackLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hCameraTrackLabel;
hCameraTrackLabel = hObject;


% --- Executes during object creation, after setting all properties.
function cameraBoomLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cameraBoomLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hCameraBoomLabel;
hCameraBoomLabel = hObject;


% --- Executes on slider movement.
function cameraPan_Callback(hObject, eventdata, handles)
% hObject    handle to cameraPan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Adjust image -- Pan/Tilt
doPanTilt();

% Show modified image
global img2;
imshow(img2);


% --- Executes during object creation, after setting all properties.
function cameraPan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cameraPan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

global hCameraPan;
hCameraPan = hObject;


% --- Executes on slider movement.
function cameraTilt_Callback(hObject, eventdata, handles)
% hObject    handle to cameraTilt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Adjust image -- Pan/Tilt
doPanTilt();

% Show modified image
global img2;
imshow(img2);


% --- Executes during object creation, after setting all properties.
function cameraTilt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cameraTilt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

global hCameraTilt;
hCameraTilt = hObject;


% --- Turns off all radio buttons and associated controls
function radioTurnAllOff()
% Note: Call before setting any new radio button

global hRadioTranslation;
global hRadioPanTilt;
global hRadioZoom;

set(hRadioTranslation,'Value',0);
set(hRadioPanTilt,'Value',0);
set(hRadioZoom,'Value',0);

global hCameraTrack;
global hCameraTrackLabel;
global hCameraBoom;
global hCameraBoomLabel;

set(hCameraTrack,'Visible','Off');
set(hCameraBoom,'Visible','Off');
set(hCameraTrackLabel,'Visible','Off');
set(hCameraBoomLabel,'Visible','Off');

global hCameraPan;
global hCameraTilt;
global hCameraPanLabel;
global hCameraTiltLabel;

set(hCameraPan,'Visible','Off');
set(hCameraTilt,'Visible','Off');
set(hCameraPanLabel,'Visible','Off');
set(hCameraTiltLabel,'Visible','Off');

global hCameraZoom;
global hCameraZoomLabel;

set(hCameraZoom,'Visible','Off');
set(hCameraZoomLabel,'Visible','Off');



% --- Radio Translation Helper
function doRadioTranslation()
%

% Enable translation controls
global hCameraTrack;
global hCameraTrackLabel;
global hCameraBoom;
global hCameraBoomLabel;
set(hCameraTrack,'Visible','On');
set(hCameraTrack,'Value', .5);
set(hCameraBoom,'Visible','On');
set(hCameraBoom,'Value', .5);
set(hCameraTrackLabel,'Visible','On');
set(hCameraBoomLabel,'Visible','On');

% Set radio button -- got cleared by TurnAllOff function
global hRadioTranslation;
set(hRadioTranslation,'Value',1);

% Reset image
global img;
imshow(img);


% --- Radio Pan/Tilt Helper
function doRadioPanTilt()
%

% Enable Pan/Tilt controls
global hCameraPan;
global hCameraPanLabel;
global hCameraTilt;
global hCameraTiltLabel;
set(hCameraPan,'Visible','On');
set(hCameraPan,'Value',.5);
set(hCameraTilt,'Visible','On');
set(hCameraTilt,'Value',.5);
set(hCameraPanLabel,'Visible','On');
set(hCameraTiltLabel,'Visible','On');

% Set radio button -- got cleared by TurnAllOff function
global hRadioPanTilt;
set(hRadioPanTilt,'Value',1);

% Reset image
global img;
imshow(img);




% --- Executes during object creation, after setting all properties.
function radioTranslation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radioTranslation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hRadioTranslation;
hRadioTranslation = hObject;

% --- Executes on button press in radioTranslation.
function radioTranslation_Callback(hObject, eventdata, handles)
% hObject    handle to radioTranslation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioTranslation

radioTurnAllOff();
doRadioTranslation();


% --- Executes during object creation, after setting all properties.
function radioPanTilt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radioPanTilt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hRadioPanTilt;
hRadioPanTilt = hObject;


% --- Executes on button press in radioPanTilt.
function radioPanTilt_Callback(hObject, eventdata, handles)
% hObject    handle to radioPanTilt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioPanTilt

radioTurnAllOff();
doRadioPanTilt();


% --- Executes during object creation, after setting all properties.
function cameraPanLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cameraPanLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hCameraPanLabel;
hCameraPanLabel = hObject;


% --- Executes during object creation, after setting all properties.
function cameraTiltLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cameraTiltLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hCameraTiltLabel;
hCameraTiltLabel = hObject;


% --- Zoom!
function doCameraZoom()
% Camera Zoom:
%   [x'  = [F/F' x
%    y']    F/F' y]       (5.5.6)
%

global img;
global img2;
global hCameraZoom;
global hCameraZoomLabel;

zoomSliderPos = get(hCameraZoom,'Value');

[h,w,d] = size(img);

% Range 0 to 1
% Nominal at .5
% > .5? Magnify... F/F' > 1
% < .5? Uhh.. demagnify.. F/F' < 1
% Corner case will be when slider is zero... 
zoomLevel = max(get(hCameraZoom,'Value') * 2, .02);

imgTmp = img; % Need to do this to get some kind of image metadata
imgTmp(1:h,1:w,1:d) = 0; % Black out modified img, initially

nExceed = 0;
for j=1:h
  for i=1:w
      
    x = round(i * zoomLevel);
    y = round(j * zoomLevel);
     
    if ((x < 1) || (x > w) || (y < 1) || (y > h))
      % Out of bounds, so do nothing
      nExceed = nExceed + 1;
    else
      imgTmp(y,x,1:d) = img(j,i,1:d);
    end
    
  end
end

sprintf('nExceed = %d', nExceed)

% Save modified image
img2 = imgTmp;





% --- Executes on button press in radioZoom.
function radioZoom_Callback(hObject, eventdata, handles)
% hObject    handle to radioZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioZoom

radioTurnAllOff();

% Set radio button -- got cleared by TurnAllOff function
global hRadioZoom;
set(hRadioZoom,'Value',1);

global hCameraZoom;
global hCameraZoomLabel;
set(hCameraZoom,'Visible','On');
set(hCameraZoom,'Value',.5);
set(hCameraZoomLabel,'Visible','On');

% Reset image
global img;
imshow(img);


% --- Executes during object creation, after setting all properties.
function radioZoom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radioZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hRadioZoom;
hRadioZoom = hObject;




% --- Executes on slider movement.
function cameraZoom_Callback(hObject, eventdata, handles)
% hObject    handle to cameraZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

doCameraZoom();

global img2;
imshow(img2);


% --- Executes during object creation, after setting all properties.
function cameraZoom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cameraZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

global hCameraZoom;
hCameraZoom = hObject;


% --- Executes during object creation, after setting all properties.
function cameraZoomLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cameraZoomLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hCameraZoomLabel;
hCameraZoomLabel = hObject;

