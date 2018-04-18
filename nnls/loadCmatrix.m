function X=loadCmatrix(fname, type)
% loadCmatrix  --- loads a C matrix for use in matlab
%
% Usage:
% X=loadCmatrix(fname)
% X=loadCmatrix(fname, type)
%  
%   type: 'd' -- dense matrix from .txt mode file
%         'D' -- dense matrix from .bin mode file
%         's' -- sparse matrix from _ccs files
%         'S' -- sparse matrix from a .bin mode saved CCS mtx
% 
% The matrix is loaded from the specified file in either text mode or binary
% mode. For dense matrices, the text mode reads from the first 1ine the
% matrix dimensions. The binary mode reads using fread -- the matrix size
% is in the first 8 bytes on a 32 bit machine, and first 16 bytes on a 64
% bit machine. For sparse matrices, txt mode saves the matrix as a CCS
% matrix consisting of _dim, _row_ccs, _col_ccs, and _txx_nz files. 
%
%
% (c) 2010 Suvrit Sra
%
% See also: saveMatlabMatrix

    
% ================ LICENSE BOILERPLATE =====================    
    
% Copyright (C) 2010 Suvrit Sra (suvrit@tuebingen.mpg.de)

% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.

% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

%begin
    if (~exist('type', 'var'))
        type = 'd';
    end

    switch type
      case 'd'
        X = readDense(fname, type);
      case 'D'
        X = readDense(fname, type);
      case 's'
        X = readSparse(fname, type);
      case 'S'
        X = readSparse(fname, type);
      otherwise
        error('Unknown file read mode: %s requested', type);
    end
end


function X = readSparse(fname, type)
    if (strcmp(type, 's'))
        X = readCCS(fname, 0);
    else
        X = readCCS(fname, 1);
    end
end
    
function X = readDense(fname, type)
    if (strcmp(type, 'd')) 
        fp = fopen(fname, 'r');
        m=fscanf(fp, '%u', 1);
        n=fscanf(fp, '%u');
        n=n(1);
        X = zeros(m,n);
        X = fscanf(fp, '%f', [n, m]);
        X=X';
        fclose(fp);
    elseif (strcmp(type, 'D'))
        fp = fopen(fname, 'rb');
        % make sensitive to platform --- if 64 bits then handle accordingly
        m=fread(fp, 1, 'uint64');
        n=fread(fp, 1, 'uint64');
        X = zeros(m,n);
        X=fread(fp, m*n, 'double'); 
        X = reshape(X, n, m); % deal with row-col-major messup
        X = X';               % necessary for the row-col-major jnk
        fclose(fp);
    else
        error('Invalid save mode requested');
  end
end