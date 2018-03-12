clear all;
close all;

files_path = uigetdir(' '); %Getting the directory where the images are.
files = fullfile(files_path,'*.txt');
txt_file = dir(files); %Creating an structure to traverse all the .txt on the folder

Fp = [13 20 50 20 34 34 16 50 48 50]; %Predetermined location for transforming the points
                                         %into a 64x64 window
error = true;
iterations =0;

%Loading the .txt of the first image to initialize F_bar
F1_path = fullfile(txt_file(1).folder,txt_file(1).name);
f1 = load(F1_path); 
f1prime = f1';
f_bar = f1prime(1:end); %Initialization of the f_bar vector

while  error
    Fpred = Fp';
    % Finding the transformation matrix A and B for F_bar
    [A,b] = Transformation(Fpred,f_bar); 
    % apply to f_bar
    f_bar_prime = ApplyTransformation(A,b,f_bar);
    
    %Applying functions to each image
    fi_matrix = [];
    for i = 1:length(txt_file)
        Fi_path = fullfile(txt_file(i).folder,txt_file(i).name); %Extracting the .txt of every image feature
        fi = load(Fi_path);
        fi = fi';
        fi = fi(1:end);
        % Finding the tranformation A and B to each fi with the f_bar founded
        Fi_bar = f_bar_prime';
        [Ai,Bi] = Transformation(Fi_bar,fi);
        % Applying the Ai and Bi transformation that best fit fi to the new
        % coordinate system
        fi_prime = ApplyTransformation(Ai,Bi,fi);
        
        % Creating a matrix of the features transformed points
        fi_matrix = [fi_matrix;fi_prime];
    end
    f_mean = mean(fi_matrix);
    %f_mean = round(f_mean);
    %f_bar = round(f_bar);
    
    % Comparing if the mean vector is equal to f_bar
    if immse(f_mean,f_bar)<=0.00000001
        error = false;
        break;
    end
    f_bar = f_mean;
    iterations=iterations+1;
end

% Transforming the original images into the new space
% Finding the best fit tranformation with the resulting f_bar
files_jpg = fullfile(files_path,'*.jpg');
jpg_file = dir(files_jpg);
for i = 1:length(txt_file)
    Fi_path = fullfile(txt_file(i).folder,txt_file(i).name); %Extracting the .txt of every image feature
    fi = load(Fi_path);
    fi = fi';
    fi = fi(1:end);
    % Finding the tranformation A and B to each fi with the f_bar founded
    Fi_bar = f_bar';
    [A,B] = Transformation(Fi_bar,fi);

    
    % Mapping of image i into the space 64x64 window
    image_trans = zeros(64,64);
    image_i = imread(cat(2,jpg_file(i).folder,'\',jpg_file(i).name));
    image_irgb = rgb2gray(image_i);
    mkdir('Normalized images'); %Creates a new directory in the path specified
%     tform = projective2d([cat(2,A,[0;0]);B' 1]);
%    tform = projective2d([cat(2, A, B); [0 0 1]]);
%     image_trans = imwarp(image_irgb,tform,'linear','OutputView',imref2d([64,64]));
    for k = 1:64
        for j = 1:64
            xy_prime = inv(A)*([k;j]-B);
            xy_prime = ceil(xy_prime);
            if xy_prime(1,1)<=0
                xy_prime(1,1)=1;
            end
            if xy_prime(1,1)>240
                xy_prime(1,1)=240;
            end
            if xy_prime(2,1)<=0
                    xy_prime(2,1)=1;
            end
            if xy_prime(2,1)>320
                xy_prime(2,1)=320;
            end
            image_trans(j,k) = image_irgb(xy_prime(2),xy_prime(1));
        end
    end
    image_trans = uint8(image_trans);
    imwrite(image_trans,fullfile('Normalized images',jpg_file(i).name));
end