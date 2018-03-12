% Function that applies a transformation matrix A and B to a features point
% and transform it to the new system coordinates.
% Input arguments
% ---------------
% A = Rotation matrix of the new coordinate system
% B = Translation matrix of the new coordinate system
% Fcoords = Row vector with feature coordinates as [x1 y1 x2 y2..... x5 y5]
%
% Output
% ---------------
% Fprime = Row vector with transform coordinates of Fcoords as [x1' y1'....
% x5' y5']
function Fprime = ApplyTransformation(A,B,Fcoords)
    fi_x = Fcoords(1:2:end);
    fi_y = Fcoords(2:2:end);
    Fprime = [];
    for j = 1:5
        f_feature = [fi_x(j) fi_y(j)]';
        fi_feature = A*f_feature+B;
        Fprime = [Fprime fi_feature'];
    end
end