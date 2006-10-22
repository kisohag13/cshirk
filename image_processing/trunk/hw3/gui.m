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

% Last Modified by GUIDE v2.5 21-Oct-2006 23:46:22

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
    global hRadioRoll;
    global hRadio4Param;
    global hRadioProjective;
    set(hRadioTranslation,'Visible','On');
    set(hRadioPanTilt,'Visible','On');
    set(hRadioZoom,'Visible','On');
    set(hRadioRoll,'Visible','On');
    set(hRadio4Param,'Visible','On');
    set(hRadioProjective,'Visible','On');
    
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

imgTmp = img; % Need to do this to get some kind of image metadata
imgTmp(1:h,1:w,1:d) = 0; % Black out modified img, initially

% Make the image 'axis' so that manipulation is aligned to
% the center of the image, and not the top-left...
% which is quadrant 1 style..
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
global hRadioRoll;
global hRadio4Param;
global hRadioProjective;

set(hRadioTranslation,'Value',0);
set(hRadioPanTilt,'Value',0);
set(hRadioZoom,'Value',0);
set(hRadioRoll,'Value',0);
set(hRadio4Param,'Value',0);
set(hRadioProjective,'Value',0);

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

global hCameraRoll;
global hCameraRollLabel;

set(hCameraRoll,'Visible','Off');
set(hCameraRollLabel,'Visible','Off');

global hC1Edit;
global hC1Label;
global hC2Edit;
global hC2Label;
global hC3Edit;
global hC3Label;
global hC4Edit;
global hC4Label;

set(hC1Edit,'Visible','Off');
set(hC1Label,'Visible','Off');
set(hC2Edit,'Visible','Off');
set(hC2Label,'Visible','Off');
set(hC3Edit,'Visible','Off');
set(hC3Label,'Visible','Off');
set(hC4Edit,'Visible','Off');
set(hC4Label,'Visible','Off');

global hA0Edit;
global hA0Label;
global hA1Edit;
global hA1Label;
global hA2Edit;
global hA2Label;
global hB0Edit;
global hB0Label;
global hB1Edit;
global hB1Label;
global hB2Edit;
global hB2Label;

set(hA0Edit,'Visible','Off');
set(hA0Label,'Visible','Off');
set(hA1Edit,'Visible','Off');
set(hA1Label,'Visible','Off');
set(hA2Edit,'Visible','Off');
set(hA2Label,'Visible','Off');
set(hB0Edit,'Visible','Off');
set(hB0Label,'Visible','Off');
set(hB1Edit,'Visible','Off');
set(hB1Label,'Visible','Off');
set(hB2Edit,'Visible','Off');
set(hB2Label,'Visible','Off');




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

[h,w,d] = size(img);

% Range 0 to 1
% Nominal at .5
% > .5? Magnify... F/F' > 1
% < .5? Uhh.. demagnify.. F/F' < 1
% Corner case will be when slider is zero... 
zoomLevel = max(get(hCameraZoom,'Value') * 2, .02);

imgTmp = img; % Need to do this to get some kind of image metadata
imgTmp(1:h,1:w,1:d) = 0; % Black out modified img, initially

% Compute image offsets so that zooming is centered
% Look at what happens to extreme top, right pixels
x_offset = floor((w - w * zoomLevel) / 2);
y_offset = floor((h - h * zoomLevel) / 2);
i_offset = 0;
j_offset = 0;

% Need to combat the black grid artifacting when zooming in
% So use two approaches, based on the zoom level
if (zoomLevel > 1)

  % Iteriate over the zoomed image
  for y=1:h
    for x=1:w
        
      % To be honest, I am too rushed to think about
      % why putting the offset / 2 in this context works...
      % But it (appears to) work...
      i = round(x / zoomLevel - y_offset / 2);
      j = round(y / zoomLevel - y_offset / 2);
      
      if ((i < 1) || (i > w) || (j < 1) || (j > h))
        % Out of bounds, so do nothing
      else
        imgTmp(y,x,1:d) = img(j,i,1:d);
      end
        
    end
  end
  
else

  % Iteriate over the source image
  for j=1:h
    for i=1:w
      
      x = round(i * zoomLevel) + x_offset;
      y = round(j * zoomLevel) + y_offset;
     
      if ((x < 1) || (x > w) || (y < 1) || (y > h))
        % Out of bounds, so do nothing
      else
        imgTmp(y,x,1:d) = img(j,i,1:d);
      end
    
    end
  end

end

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



% --- Executes on button press in radioRoll.
function radioRoll_Callback(hObject, eventdata, handles)
% hObject    handle to radioRoll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioRoll

radioTurnAllOff();

% Set radio button -- got cleared by TurnAllOff function
global hRadioRoll;
set(hRadioRoll,'Value',1);

global hCameraRoll;
global hCameraRollLabel;
set(hCameraRoll,'Visible','On');
set(hCameraRoll,'Value',.5);
set(hCameraRollLabel,'Visible','On');

% Reset image
global img;
imshow(img);


% --- Executes during object creation, after setting all properties.
function radioRoll_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radioRoll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hRadioRoll;
hRadioRoll = hObject;



% --- Camera Roll!
function doCameraRoll()
%

global hCameraRoll;

% Let angles vary from -180 degrees to +180 degrees
% Also inverse the left-right convention to make it intuitive
rollSliderPos = 1 - get(hCameraRoll,'Value');
theta_z = 2 * pi * rollSliderPos - pi;

global img;
[h,w,d] = size(img);

imgTmp = img; % Need to do this to get some kind of image metadata
imgTmp(1:h,1:w,1:d) = 0; % Black out modified img, initially

roll = [cos(theta_z) -sin(theta_z)
        sin(theta_z) cos(theta_z)];
    
% Make the image 'axis' so that manipulation is aligned to
% the center of the image, and not the top-left...
% which is quadrant 1 style..
%
% Compute x and y offsets by looking at extreme top,right pixel movements
tmp_X = [w
         h]; % z is irrelevant -- don't care

tmp = roll * tmp_X;
x_offset = floor((w - round(tmp(1))) / 2);
y_offset = floor((h - round(tmp(2))) / 2);

for y=1:h
  showBusy(100 * (y-1) / h);
  for x=1:w
      
    tmp_X = [x
             y];
      
    tmp = roll * tmp_X;
    i = round(tmp(1)) + x_offset;
    j = round(tmp(2)) + y_offset;
    
    if ((i < 1) || (i > w) || (j < 1) || (j > h))
      % Out of bounds, so do nothing
    else
      imgTmp(y,x,1:d) = img(j,i,1:d);
    end
    
  end
end
showBusy(0);


% Save modified image
global img2;
img2 = imgTmp;




% --- Executes on slider movement.
function cameraRoll_Callback(hObject, eventdata, handles)
% hObject    handle to cameraRoll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


doCameraRoll();

global img2;
imshow(img2);




% --- Executes during object creation, after setting all properties.
function cameraRoll_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cameraRoll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

global hCameraRoll;
hCameraRoll = hObject;



% --- Executes during object creation, after setting all properties.
function cameraRollLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cameraRollLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hCameraRollLabel;
hCameraRollLabel = hObject;


% --- 4-param!
function do4Param()
%

global hC1Edit;
global hC2Edit;
global hC3Edit;
global hC4Edit;

global img;
global img2;
[h,w,d] = size(img);

c1 = str2double(get(hC1Edit,'String'));
c2 = str2double(get(hC2Edit,'String'));
c3 = str2double(get(hC3Edit,'String'));
c4 = str2double(get(hC4Edit,'String'));

% Don't do anything until we get good values
if (isnan(c1) || isnan(c2) || isnan(c3) || isnan(c4))
  img2 = img;
  return
end

c = [c1 -c2
     c2 c1];
 
c_trans = [c3
           c4];

imgTmp = img; % Need to do this to get some kind of image metadata
imgTmp(1:h,1:w,1:d) = 0; % Black out modified img, initially

% Make the image 'axis' so that manipulation is aligned to
% the center of the image, and not the top-left...
% which is quadrant 1 style..
%
% Compute x and y offsets by looking at extreme top,right pixel movements
tmp_X = [w
         h]; % z is irrelevant -- don't care

tmp = c * tmp_X; % Important: Don't normalize out c_trans
x_offset = floor((w - round(tmp(1))) / 2);
y_offset = floor((h - round(tmp(2))) / 2);

for y=1:h
  for x=1:w
      
    tmp_X = [x
             y];
    
    tmp = c * tmp_X + c_trans;
    i = round(tmp(1)) + x_offset;
    j = round(tmp(2)) + y_offset;
    
    if ((i < 1) || (i > w) || (j < 1) || (j > h))
      % Out of bounds, so do nothing
    else
      imgTmp(y,x,1:d) = img(j,i,1:d);
    end
         
  end
end

% Save modified image
img2 = imgTmp;



% --- Executes on button press in radio4Param.
function radio4Param_Callback(hObject, eventdata, handles)
% hObject    handle to radio4Param (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio4Param

radioTurnAllOff();

% Set radio button -- got cleared by TurnAllOff function
global hRadio4Param;
set(hRadio4Param,'Value',1);

% Enable controls...
global hC1Edit;
global hC1Label;
global hC2Edit;
global hC2Label;
global hC3Edit;
global hC3Label;
global hC4Edit;
global hC4Label;
set(hC1Edit,'Visible','On');
set(hC1Edit,'String','');
set(hC1Label,'Visible','On');
set(hC2Edit,'Visible','On');
set(hC2Edit,'String','');
set(hC2Label,'Visible','On');
set(hC3Edit,'Visible','On');
set(hC3Edit,'String','');
set(hC3Label,'Visible','On');
set(hC4Edit,'Visible','On');
set(hC4Edit,'String','');
set(hC4Label,'Visible','On');

% Reset image
global img;
imshow(img);


% --- Executes during object creation, after setting all properties.
function radio4Param_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radio4Param (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hRadio4Param;
hRadio4Param = hObject;



function c1Edit_Callback(hObject, eventdata, handles)
% hObject    handle to c1Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of c1Edit as text
%        str2double(get(hObject,'String')) returns contents of c1Edit as a double

do4Param();

global img2;
imshow(img2);


% --- Executes during object creation, after setting all properties.
function c1Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to c1Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global hC1Edit;
hC1Edit = hObject;




% --- Executes during object creation, after setting all properties.
function c1Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to c1Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hC1Label;
hC1Label = hObject;




function c2Edit_Callback(hObject, eventdata, handles)
% hObject    handle to c2Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of c2Edit as text
%        str2double(get(hObject,'String')) returns contents of c2Edit as a double

do4Param();

global img2;
imshow(img2);


% --- Executes during object creation, after setting all properties.
function c2Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to c2Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global hC2Edit;
hC2Edit = hObject;



% --- Executes during object creation, after setting all properties.
function c2Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to c2Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hC2Label;
hC2Label = hObject;



function c3Edit_Callback(hObject, eventdata, handles)
% hObject    handle to c3Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of c3Edit as text
%        str2double(get(hObject,'String')) returns contents of c3Edit as a double

do4Param();

global img2;
imshow(img2);


% --- Executes during object creation, after setting all properties.
function c3Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to c3Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global hC3Edit;
hC3Edit = hObject;




% --- Executes during object creation, after setting all properties.
function c3Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to c3Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hC3Label;
hC3Label = hObject;




% --- Executes during object creation, after setting all properties.
function c4Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to c4Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hC4Label;
hC4Label = hObject;



function c4Edit_Callback(hObject, eventdata, handles)
% hObject    handle to c4Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of c4Edit as text
%        str2double(get(hObject,'String')) returns contents of c4Edit as a double

do4Param();

global img2;
imshow(img2);



% --- Executes during object creation, after setting all properties.
function c4Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to c4Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global hC4Edit;
hC4Edit = hObject;


% --- Display busy indicator
function showBusy(percentage)

return % this blasted function isn't working

global hLoadImage;

get(hLoadImage,'String')
set(hLoadImage,'String','wtf')
subplot(2,1,1)
refresh
subplot(2,1,2)

if (percentage == 0) % Done
    set(hLoadImage,'String','Load Image');
    disp wtf
    return
end

num = floor(percentage);

tmp = sprintf('%3d%% Done', num);
%set(hLoadImage,'String',tmp);
refresh;



% --- Executes during object creation, after setting all properties.
function loadImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hLoadImage;
hLoadImage = hObject;

get(hLoadImage,'String')


% --- Executes on button press in radioProjective.
function radioProjective_Callback(hObject, eventdata, handles)
% hObject    handle to radioProjective (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioProjective

radioTurnAllOff();

% Set radio button -- got cleared by TurnAllOff function
global hRadioProjective;
set(hRadioProjective,'Value',1);

% Enable controls...
global hC1Edit;
global hC1Label;
global hC2Edit;
global hC2Label;
global hA0Edit;
global hA0Label;
global hA1Edit;
global hA1Label;
global hA2Edit;
global hA2Label;
global hB0Edit;
global hB0Label;
global hB1Edit;
global hB1Label;
global hB2Edit;
global hB2Label;

set(hC1Edit,'Visible','On');
set(hC1Edit,'String','');
set(hC1Label,'Visible','On');
set(hC2Edit,'Visible','On');
set(hC2Edit,'String','');
set(hC2Label,'Visible','On');
set(hA0Edit,'Visible','On');
set(hA0Edit,'String','');
set(hA0Label,'Visible','On');
set(hA1Edit,'Visible','On');
set(hA1Edit,'String','');
set(hA1Label,'Visible','On');
set(hA2Edit,'Visible','On');
set(hA2Edit,'String','');
set(hA2Label,'Visible','On');
set(hB0Edit,'Visible','On');
set(hB0Edit,'String','');
set(hB0Label,'Visible','On');
set(hB1Edit,'Visible','On');
set(hB1Edit,'String','');
set(hB1Label,'Visible','On');
set(hB2Edit,'Visible','On');
set(hB2Edit,'String','');
set(hB2Label,'Visible','On');



% --- Executes during object creation, after setting all properties.
function radioProjective_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radioProjective (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hRadioProjective;
hRadioProjective = hObject;




function a0Edit_Callback(hObject, eventdata, handles)
% hObject    handle to a0Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a0Edit as text
%        str2double(get(hObject,'String')) returns contents of a0Edit as a double


% --- Executes during object creation, after setting all properties.
function a0Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a0Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global hA0Edit;
hA0Edit = hObject;


% --- Executes during object creation, after setting all properties.
function a0Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a0Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hA0Label;
hA0Label = hObject;



function a1Edit_Callback(hObject, eventdata, handles)
% hObject    handle to a1Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a1Edit as text
%        str2double(get(hObject,'String')) returns contents of a1Edit as a
%        double


% --- Executes during object creation, after setting all properties.
function a1Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a1Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global hA1Edit;
hA1Edit = hObject;



function a2Edit_Callback(hObject, eventdata, handles)
% hObject    handle to a2Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a2Edit as text
%        str2double(get(hObject,'String')) returns contents of a2Edit as a double


% --- Executes during object creation, after setting all properties.
function a2Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a2Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global hA2Edit;
hA2Edit = hObject;


% --- Executes during object creation, after setting all properties.
function a1Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a1Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hA1Label;
hA1Label = hObject;


% --- Executes during object creation, after setting all properties.
function a2Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a2Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hA2Label;
hA2Label = hObject;



function b0Edit_Callback(hObject, eventdata, handles)
% hObject    handle to b0Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of b0Edit as text
%        str2double(get(hObject,'String')) returns contents of b0Edit as a
%        double


% --- Executes during object creation, after setting all properties.
function b0Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b0Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global hB0Edit;
hB0Edit = hObject;



function b1Edit_Callback(hObject, eventdata, handles)
% hObject    handle to b1Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of b1Edit as text
%        str2double(get(hObject,'String')) returns contents of b1Edit as a double


% --- Executes during object creation, after setting all properties.
function b1Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b1Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global hB1Edit;
hB1Edit = hObject;



function b2Edit_Callback(hObject, eventdata, handles)
% hObject    handle to b2Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of b2Edit as text
%        str2double(get(hObject,'String')) returns contents of b2Edit as a double



% --- Executes during object creation, after setting all properties.
function b2Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b2Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global hB2Edit;
hB2Edit = hObject;


% --- Executes during object creation, after setting all properties.
function b1Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b1Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hB1Label;
hB1Label = hObject;



% --- Executes during object creation, after setting all properties.
function b2Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b2Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hB2Label;
hB2Label = hObject;


% --- Executes during object creation, after setting all properties.
function b0Label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b0Label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global hB0Label;
hB0Label = hObject;
