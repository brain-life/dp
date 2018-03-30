function saveMatlabMatrix(X, fname, mode)
% saveMatlabMatrix  --- saves a matlab matrix for easy use via C
%
% Usage:
% saveMatlabMatrix(X, fname)
% saveMatlabMatrix(X, fname, 'bin')
%
% The matrix is saved in the specified file in either text mode or binary
% mode. For dense matrices, the text mode saves on the first 1ine the
% matrix dimensions. The binary mode saves using fwrite -- the matrix size
% is in the first 8 bytes on a 32 bit machine, and first 16 bytes on a 64
% bit machine. For sparse matrices, txt mode saves the matrix as a CCS
% matrix consisting of _dim, _row_ccs, _col_ccs, and _txx_nz files. 
%
%
% (c) 2010 Suvrit Sra
%
% See also: loadCmatrix
    
    
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
    if (~exist('mode', 'var'))
        asbin = 'txt';
    end

    if (isempty(X))
        error('Cannot save an empty matrix');
    end

    if (exist(fname, 'file'))
        warning('File: %s exists. Refusing to overwrite', fname);
        return;
    end

    if (issparse(X))
        saveCCS(X, fname, mode);
    else
        saveDense(X, fname, mode);
    end
end

function saveCCS(X, fname, mode)
  if (strcmp(mode, 'txt')) 
      matlab2ccs(fname, X, 0);
  elseif (strcmp(mode, 'bin'))
      matlab2ccs(fname, X, 1);
  else
      error('Invalid save mode requested');
  end
end
    
function saveDense(X, fname, mode)
    if (strcmp(mode, 'txt')) 
        fp = fopen(fname, 'w');
        fprintf(fp, '%u %u\n', size(X,1), size(X,2));
        for i=1:size(X,1)
            fprintf(fp, '%f ', X(i,:));
        end
        fclose(fp);
    elseif (strcmp(mode, 'bin'))
        fp = fopen(fname, 'wb');
        [m,n]=size(X);
        
        % make sensitive to platform --- if 64 bits then handle accordingly
        fwrite(fp, [m n], 'uint64');
        fwrite(fp, X', 'float'); %transpose since matlab saves in column major order
        fclose(fp);
    else
        error('Invalid save mode requested');
  end
end