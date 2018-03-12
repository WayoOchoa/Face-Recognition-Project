function varargout = Face_recognition(varargin)
% FACE_RECOGNITION MATLAB code for Face_recognition.fig
%      FACE_RECOGNITION, by itself, creates a new FACE_RECOGNITION or raises the existing
%      singleton*.
%
%      H = FACE_RECOGNITION returns the handle to a new FACE_RECOGNITION or the handle to
%      the existing singleton*.
%
%      FACE_RECOGNITION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FACE_RECOGNITION.M with the given input arguments.
%
%      FACE_RECOGNITION('Property','Value',...) creates a new FACE_RECOGNITION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Face_recognition_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Face_recognition_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Face_recognition

% Last Modified by GUIDE v2.5 14-Jan-2018 13:56:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Face_recognition_OpeningFcn, ...
                   'gui_OutputFcn',  @Face_recognition_OutputFcn, ...
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


% --- Executes just before Face_recognition is made visible.
function Face_recognition_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Face_recognition (see VARARGIN)

% Choose default command line output for Face_recognition
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

set(handles.text_state,'String',' ');
set(handles.textaccu,'String','');
% UIWAIT makes Face_recognition wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Face_recognition_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = get(hObject,'Value');
test_file = handles.test_file;
set(handles.test_name,'String',test_file(index).name);
imagetest = imread(cat(2,test_file(index).folder,'\',test_file(index).name));
imshow(imagetest,'Parent',handles.axes_test);

handles.index = index;
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    k = handles.k;  
    set(handles.text_state,'String','Loading.....');
    %files_path = uigetdir(' '); %Getting the directory where the images are.
    if k==0 | not(isnumeric(k))
        k=1;
    end
    
    files_path = 'C:\Users\Eduardo\Google Drive\Applied Maths\Face Recognition Project\Normalized images\train_images';
    files = fullfile(files_path,'*.jpg');
    train_file = dir(files);

    D = [];
    Lt = []; %Label matrix
    % j = 1; % Counter for the label matrix names

    % Creating a matrix D with each image in a row as a vector of 1xN^2
    for i = 1:length(train_file)
        image = imread(cat(2,train_file(i).folder,'\',train_file(i).name));
        image_vector = reshape(image,1,64*64); % Resizing the image as a vector 1x4096
        D = [D;image_vector];
        %Lt = [Lt;cat(2,train_file(i).name(1:3),num2str(j))];
        Lt = [Lt;train_file(i).name(1:3)];
    %     j = j+1;
    %     if j == 4
    %         j=1;
    %     end
    end

    % Calculation of the mean vector of the matrix D
    mean_vector = mean(D);
    mean_vector = floor(mean_vector);
    D = double(D);
    %mean_vector = uint8(mean_vector);

    % Removing the mean to form the covariance matrix
    Q = D-mean_vector;
    %Q = D-mean_vector; %NOTE: Right now this removes the mean but because of the unsigned integers you get 0s
    %Q = double(Q);
    Cov = 1/(size(Q,1)-1)*Q*Q'; % Covariance matrix computation
    [eigvect,eigval] = eig(Cov); % Eigenvectors and eigenvalues of the convariance matrix

    % Finding PCA of D
    %Phi = D'*eigvect; %Check if its with Q or D for the eigenvectors
    Phi = Q'*eigvect;

    % Computing feature vectors
    Ft = []; % Feature vector matrix
    for j = 1:size(D,1)
        Ft(j,:) = D(j,:)*Phi; % Feature vector of each image
    end

    test_path = 'C:\Users\Eduardo\Google Drive\Applied Maths\Face Recognition Project\Normalized images\test_images';
    test = fullfile(test_path,'*.jpg');
    test_file = dir(test);
    % Loading an image from the test set
    Tlabel = [];
    accuracy_error = 0;
    for t = 1:size(test_file,1)
    image_test = imread(cat(2,test_file(t).folder,'\',test_file(t).name));
    image_test = double(image_test);
    % figure, imshow(image_test,[])

    Tlabel = [Tlabel;test_file(t).name(1:3)];

    % Reshaping the test image
    X_j = reshape(image_test,1,64*64);
    phi_j = X_j*Phi; % Projecting the test image into PCA space

    % Euclidean distances between every feature vector and the feature test
    % vector
    Distance = pdist2(Ft,phi_j);
    [Min index] = sort(Distance);
    
    for nfaces = 1:k %%
    Iz = D(index(nfaces),:); % Most similar k face
    % Iz = reshape(Iz,64,64);
    % figure,imshow(Iz,[]);
    if strcmp(Lt(index(nfaces),:),test_file(t).name(1:3))
        break;
    end
    if nfaces==k
        accuracy_error = accuracy_error+1;
        nfaces=1;
        break;
    end
    end
%     [Min index] = min(Distance); % finding the minimum distance
%     Iz = D(index,:); % Most similar face
%     Iz = reshape(Iz,64,64);
%     % figure,imshow(Iz,[]);
%     if not(strcmp(Lt(index,:),test_file(t).name(1:3)))
%         accuracy_error = accuracy_error+1;
%     end
    end

    accuracy = (1-(accuracy_error/size(test_file,1)))*100;
    accuracy = floor(accuracy);
    percentage = num2str(accuracy);
    accuracy2 = cat(2,percentage,'%');
    
    handles.test_file = test_file;
    handles.Phi = Phi;
    handles.Ft = Ft;
    handles.D = D;
    handles.train_file = train_file;
    handles.Lt = Lt;
    guidata(hObject,handles);
    
    set(handles.popupmenu1,'String',Tlabel);
    set(handles.text_state,'String','Done!');
    set(handles.textaccu,'String',num2str(accuracy2));


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = handles.index;
test_file = handles.test_file;
Phi = handles.Phi;
Ft = handles.Ft;
train_file = handles.train_file;
D = handles.D;
k = handles.k;
Lt = handles.Lt;

    if k==0 | not(isnumeric(k))
        k=1;
    end

    itest = imread(cat(2,test_file(index).folder,'\',test_file(index).name));
    itest = double(itest);
    
    % Reshaping the test image
    X_j = reshape(itest,1,64*64);
    phi_j = X_j*Phi; % Projecting the test image into PCA space

    % Euclidean distances between every feature vector and the feature test
    % vector
    Distance = pdist2(Ft,phi_j);
    [Min position] = sort(Distance); % finding the k's minimum distances

    for nfaces = 1:k %%
    Iz = D(position(nfaces),:); % Most similar k face
    % Iz = reshape(Iz,64,64);
    % figure,imshow(Iz,[]);

    if strcmp(Lt(position(nfaces),:),test_file(index).name(1:3))
        break;
    end
    if nfaces==k
        nfaces=1;
        break;
    end
    end
    
    
%     [Min position] = min(Distance); % finding the minimum distance
    Iz = D(position(nfaces),:); % Most similar face
    Iz = reshape(Iz,64,64);
    
    set (handles.text4,'String',train_file(position(nfaces)).name);
    imshow(Iz,[],'Parent', handles.axes2);
    
    
    


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function k_faces_Callback(hObject, eventdata, handles)
% hObject    handle to k_faces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
k = uint8(str2double(get(hObject,'String')));

handles.k = k;
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of k_faces as text
%        str2double(get(hObject,'String')) returns contents of k_faces as a double



% --- Executes during object creation, after setting all properties.
function k_faces_CreateFcn(hObject, eventdata, handles)
% hObject    handle to k_faces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
k = uint8(str2double(get(hObject,'String')));

handles.k = k;
guidata(hObject,handles);