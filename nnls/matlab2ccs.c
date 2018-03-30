/* matlab2ccs.c - mex file for writing out CCS matrices  */
/* MEX file for saving in txt mode or bin mode CCS files */

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

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray* prhs[])
{

  double* val;
  mwSize nz;
  mwSize m, n, i;
  mwIndex *row, *col;
  int mode;
  int status;
  char* prefix;
  char* out;
  int buflen;
  FILE* fp;

  if (nrhs < 2 || nrhs > 3) {
    fprintf(stderr, "Error: matlab2ccs('filename prefix', X, mode)\n");
    fprintf(stderr, "mode must be 0 for txt (default) or 1 (bin)\n");
    return;
  }

  if (nlhs > 0) {
    fprintf(stderr, "Error: Too many output arguments.\n");
    return;
  }

  if (!mxIsSparse(prhs[1])) {
    fprintf(stderr, "Error: Input matrix must be sparse. Use sparse(X)\n");
    return;
  }

  if (mxIsChar(prhs[0]) != 1) {
    fprintf(stderr, "Error: Input file name must be a string.\n");
    return;
  }

  if (nrhs == 2) {
    mode = 0;
  } else {
    mode = (int) mxGetScalar(prhs[2]);
  }

  /* Get the length of the input string. */
  buflen = (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;

  /* Allocate memory for input and output strings. */
  prefix = mxCalloc(buflen, sizeof(char));
  out =       mxCalloc(buflen + 8, sizeof(char));

  /* Copy the string data from prhs[0] into a C string  input_buf. */
  status = mxGetString(prhs[0], prefix, buflen);

  if (status != 0) 
    fprintf(stderr, "Warning: Not enough space. String got truncated.\n");
     
  val  = mxGetPr(prhs[1]);
  col  = mxGetJc(prhs[1]);
  row  = mxGetIr(prhs[1]);

  m    = mxGetM(prhs[1]);
  n    = mxGetN(prhs[1]);
  nz   = mxGetNzmax(prhs[1]);

  if (mode) {                 /* save as binary file */
    fp = fopen(prefix, "wb");
    if (!fp) {
      fprintf(stderr, "Could not open %s for writing\n", prefix);
      return;
    }

    /* write the dimension info */
    if (fwrite(&m,  sizeof(size_t), 1, fp) != 1) {
      fprintf(stderr, "matlab2ccs:: Error writing M (numrows) to %s\n", prefix);
      fclose(fp);
      return;
    }

    if (fwrite(&n,  sizeof(size_t), 1, fp) != 1) {
      fprintf(stderr, "matlab2ccs:: Error writing N (numcols) to %s\n", prefix);
      fclose(fp);
      return;
    }

    if (fwrite(&nz, sizeof(size_t), 1, fp) != 1) {
      fprintf(stderr, "matlab2ccs:: Error writing #NNZ (nnz) to %s\n", prefix);
      fclose(fp);
      return;
    }

     /* write the colptrs */
    if (fwrite(col, sizeof(size_t), n+1, fp) != n+1) {
      fprintf(stderr, "matlab2ccs:: Error writing colptrs to %s\n", prefix);
      fclose(fp);
      return;
    }

    /* write the row indices */
    if (fwrite(row, sizeof(size_t), nz, fp) != nz) {
      fprintf(stderr, "matlab2ccs:: Error writing rowindices to %s\n", prefix);
      fclose(fp);
      return;
    }

    /* write the nonzeros themselves */
    if (fwrite(val, sizeof(double), nz, fp) != nz) {
      fprintf(stderr, "matlab2ccs:: Error writing nonzeros to %s\n", prefix);
      fclose(fp);
      return;
    }
    fclose(fp);

  } else {
    sprintf(out, "%s_dim", prefix);

    fp = fopen(out, "w");
    if (fp == NULL) {
      fprintf(stderr, "Could not open the _dim file");
      return;
    }
     
    fprintf(fp, "%zu %zu %zu", m, n, nz);
    fclose(fp);
    sprintf (out, "%s_row_ccs", prefix);

    fp = fopen(out, "w");
    if (fp == NULL) {
      fprintf(stderr, "Could not open the _row_ccs file");
      return;
    }
    for (i = 0; i < nz; i++)
      fprintf(fp, "%zu\n", row[i]);

    fclose(fp);
     
    sprintf (out, "%s_col_ccs", prefix);

    fp = fopen(out, "w");
    if (fp == NULL) {
      fprintf(stderr, "Could not open the _col_ccs file");
      return;
    }
    for (i = 0; i <= n; i++)
      fprintf(fp, "%zu\n", col[i]);

    fclose(fp);
     
    sprintf (out, "%s_txx_nz", prefix);

    fp = fopen(out, "w");
    if (fp == NULL) {
      fprintf(stderr, "Could not open the _txx_nz file");
      return;
    }

    for (i = 0; i < nz; i++)
      fprintf(fp, "%lf\n", val[i]);

    fclose(fp);
  }
}
