/* readCCS.c - mex file for reading CCS matrices  */
/* MEX file for reading in txt mode or bin mode CCS files */
/* Author: Suvrit Sra <suvrit@tuebingen.mpg.de> */
/* (c) Copyright 2010   Suvrit Sra */
/* Max-Planck-Institute for Biological Cybernetics */

/* This program is free software; you can redistribute it and/or */
/* modify it under the terms of the GNU General Public License */
/* as published by the Free Software Foundation; either version 2 */
/* of the License, or (at your option) any later version. */

/* This program is distributed in the hope that it will be useful, */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the */
/* GNU General Public License for more details. */

/* You should have received a copy of the GNU General Public License */
/* along with this program; if not, write to the Free Software */
/* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA. */


#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray* prhs[])
{
  double* val;
  mwSize nz;
  mwSize m, n, i;
  mwIndex *row, *col;
  int status;
  char* input_buf;
  char* out;
  int buflen;
  FILE* fp;
  int mode;
  
  if (nrhs != 2) {
    fprintf(stderr, "Error: readCCS('filename prefix', mode')\n");
    return;
  }
  
  if (nlhs > 1) {
    fprintf(stderr, "Error: Too many output arguments.\n");
    return;
  }

  if (mxIsChar(prhs[0]) != 1) {
    fprintf(stderr, "Error: Input file name must be a string.\n");
    return;
  }
  
  fprintf(stderr, "readCCS: beginning\n");
  /* Get the length of the input string. */
  buflen = (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;

  /* Allocate memory for input and output strings. */
  input_buf = mxCalloc(buflen, sizeof(char));
  out =       mxCalloc(buflen + 8, sizeof(char));

  /* Copy the string data from prhs[0] into a C string input_buf. */
  status = mxGetString(prhs[0], input_buf, buflen);
  if (status != 0) 
    fprintf(stderr, "Warning: Not enough space. String was truncated.\n");
     
  /* Get file reading mode */
  mode = (int) mxGetScalar(prhs[1]);

  if (mode != 0 && mode != 1) {
    fprintf(stderr, "Error: readCCS -- invalid read mode = %d specified\n",mode);
    return;
  }

  if (mode==0) {       /*read as a .txt file */
    sprintf(out, "%s_dim", input_buf);
    fp = fopen(out, "r");
    if (!fp) {
      fprintf(stderr, "Could not open %s_dim", out);
      return;
    }
     
    status=fscanf(fp, "%zu %zu %zu", &m, &n, &nz);    
    fclose(fp);
    sprintf (out, "%s_row_ccs", input_buf);

    plhs[0] = mxCreateSparse(m,n,nz,0);
    fprintf(stderr, "Created new matlab sparse matrix (%u, %u, %u)\n", mxGetM(plhs[0]), mxGetN(plhs[0]), mxGetNzmax(plhs[0]));

    /* Obtain pointers to correct parts of matrix */
    row = mxGetIr(plhs[0]);
    col = mxGetJc(plhs[0]);
    val = mxGetPr(plhs[0]);

    fp = fopen(out, "r");
    if (!fp) { fprintf(stderr, "Could not open the %s", out);  return; }

    for (i = 0; i < nz; i++)
      status=fscanf(fp, "%zu\n", &row[i]);
    fclose(fp);
     
    sprintf (out, "%s_col_ccs", input_buf);

    fp = fopen(out, "r");
    if (!fp) { fprintf(stderr, "Could not open the _col_ccs file"); return; }
    for (i = 0; i <= n; i++)
      status=fscanf(fp, "%zu\n", &col[i]);
    fclose(fp);
     
    sprintf (out, "%s_tfn_nz", input_buf);
    fp = fopen(out, "r");
    if (!fp) { fprintf(stderr, "Could not open the nonzeros file"); return; }
  
    for (i = 0; i < nz; i++)
      status=fscanf(fp, "%lf\n", &val[i]);
    fclose(fp);
  } else {             /* read as a .bin mode file */
    fp = fopen(input_buf, "rb");
    if (!fp) {
      fprintf(stderr, "readCCS: Error opening file %s for reading\n", input_buf);
      return;
    }

    /* load dims */
    status=fread(&m, sizeof(size_t), 1, fp);
    if (status != 1) {freadError(status, 1); return;}

    status=fread(&n, sizeof(size_t), 1, fp);
    if (status != 1) {freadError(status, 1); return;}

    status=fread(&nz, sizeof(size_t), 1, fp);
    if (status != 1) {freadError(status, 1); return;}

    fprintf(stdout, "Found matrix of size (%zu,%zu, %zu)\n", m, n, nz);

    /* Now create the matlab variable */
    plhs[0] = mxCreateSparse(m,n,nz,0);
    fprintf(stderr, "Created new matlab sparse matrix (%zu, %zu, %zu)\n", mxGetM(plhs[0]), mxGetN(plhs[0]), mxGetNzmax(plhs[0]));

    /* Obtain pointers to correct parts of matrix */
    row = mxGetIr(plhs[0]);
    col = mxGetJc(plhs[0]);
    val = mxGetPr(plhs[0]);

    /* read colptrs */
    status=fread(col, sizeof(mwSize), n+1, fp);
    if (status != n+1) { mxDestroyArray(plhs[0]); freadError(status, n+1); return;}

    /* read row indices */
    status=fread(row, sizeof(mwSize), nz, fp);
    if (status != nz) { mxDestroyArray(plhs[0]); freadError(status, nz); return;}

    /* save nonzeros */
    status=fread(val, sizeof(double), nz, fp);
    if (status != nz) { mxDestroyArray(plhs[0]); freadError(status, nz); return;}
    fclose(fp);
  }
}

int freadError(size_t got, size_t tried)
{
  fprintf(stderr, "fread error: tried to read %u values, got only %u\n", tried, got);
  return -10;
}
