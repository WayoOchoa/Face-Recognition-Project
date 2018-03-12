clear all;
close all;

%files_path = uigetdir(' '); %Getting the directory where the images are.
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
[Min index] = sort(Distance); % finding the k's minimum distances

k=10; %number of faces in which you want to look
for nfaces = 1:k %%
Iz = D(index(nfaces),:); % Most similar k face
% Iz = reshape(Iz,64,64);
% figure,imshow(Iz,[]);
% 
% Lt(index(nfaces),:)
% test_file(t).name(1:3)
% strcmp(Lt(index,:),test_file(t).name(1:3))
if strcmp(Lt(index(nfaces),:),test_file(t).name(1:3))
    break;
end
if nfaces==k
    accuracy_error = accuracy_error+1;
    nfaces=1;
    break;
end
end
% if not(strcmp(Lt(index,:),test_file(t).name(1:3)))
%     accuracy_error = accuracy_error+1;
% end
close all;
end

accuracy = (1-(accuracy_error/size(test_file,1)))*100;

%Iz = reshape(Iz,64,64);
%figure,imshow(Iz,[]);