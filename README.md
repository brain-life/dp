# Diff_Pred_code4BrainLife
This repo includes the scripts with the code that need to be implemented in Brain-Life.
We provide scripts for four apps (see description below), which are included in the folder \scripts.

**App A: Fit the model**
This app performs two steps:
*STEP 1: Model parameter tuning (grid search)*
The model has 3 parameters that need to be tuned to the available data (dWI+Tractography). The parameters are: (1) An l2 regularizer parameter alpha_v, and the axial and radial diffusivities (2) lambda_1 and (3) lambda_2, respectively. To fit these parameters we do crossvalidation, which consists on fitting the model using a grid on values (alpha_v, lambda_1, lambda_2) on a subset of gradient directions (50%, Training dataset). Once the model is fit, we test it on the non-used gradient directions (50%, Testing dataset) and compute the Testing Error for each point in the grid (alpha_v, lambda_1, lambda_2). Finally, we choose the optimal values of parameters (alpha_v, lambda_1, lambda_2) such that the obtained Testing Error is minimum.

*STEP 2: Final model fitting**
Once the optimal parameters (alpha_v, lambda_1, lambda_2) were chosen in the previous step. We run the model for this parameter setting using 100% of the gradient directions.

*INPUTs*
The inputs needed to fit the model are:
1. The diffusion data (a nifti file)
2. The tractography (a .tck or .mat file)

All the inputs are provided in the dataset folder here /N/dc2/projects/lifebid/code/ccaiafa/Diffusion_predictor_paper/Code_for_BL/data

*OUTPUT*
During the STEP 1, multiple .mat files are saved to the folder results for each point of the grid search. 
The STEP 2 gives as output an fe-structure with the fitted model saved in a .mat file in the same folder.

**App B: Compute nifti files for profiles**
This app performes two steps:
*STEP 1: Generate tract predictions*
In this step the app takes the fe-structure generated by App A and generate nifti files with diffusion predictions obtained based on tracts CST and SLF for the following cases:
- Using all fibers in the connectome (full prediction) 
- Using only CST fascicles
- Using only SLF fascicles
- Using only CST+SLF fascicles

*STEP 2: Compute FA
In this step, the Fractional Anisotropy (FA) is computed for each one of the diffusion signals generated in the step 1.

*INPUTs*
1. fe-structure generated by App A
3. The fiber classification (a .mat file)

*OUTPUT*
nifti files with diffusion data and FA values which are saved to the folder \results\niftis

**App C: Plot results A**
To check the results of App A (Model Fit), in this App we load the results of the grid search and plot the error as a function of the three parameters: alpha_v, lambda_1, and lambda_2.

**App D: Plot FA tract profiles**
This app generate the tract profiles (FA) to be used in the paper.



