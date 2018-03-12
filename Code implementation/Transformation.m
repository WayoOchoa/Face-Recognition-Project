% Function that calculates the Transformation matrix A and B to a window of
% 64x64 image. 
% Input parameters
% ----------------
% Fp = Column vector that holds the coordinates of the 5 features of a face
% in a 64x64 window
% Fcoords = Row vector with the 5 features coordinates of the original
% window size
%
% Output parameters
% -----------------
% A and B transformation matrix
function [A,B] = Transformation(Fp, Fcoords)
    System_matrix = [Fcoords(1:2) 0 0 1 0; 0 0 Fcoords(1:2) 0 1;
        Fcoords(3:4) 0 0 1 0; 0 0 Fcoords(3:4) 0 1;
        Fcoords(5:6) 0 0 1 0; 0 0 Fcoords(5:6) 0 1;
        Fcoords(7:8) 0 0 1 0; 0 0 Fcoords(7:8) 0 1;
        Fcoords(9:10) 0 0 1 0; 0 0 Fcoords(9:10) 0 1;];
    x = System_matrix\Fp; %Least square solution of the system created
    A = [x(1) x(2); x(3) x(4)]; % Defining the A and b transformation
    B = [x(5); x(6)];
end