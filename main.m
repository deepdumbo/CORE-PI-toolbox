clear all;
close all;

% This Matlab code includes an implementation of the CORE-PI reconstruction 
% method that was published in:
%     Shimron, Webb, Azhari, "CORE-PI: Non-iterative convolution-based 
%     reconstruction for parallel MRI in the wavelet domain." 
%     Medical Physics 46.1 (2019):199-214

% CORE-PI is a general reconstrution method, suitable for image reconstruction
% from multi-coil (parallel imaging) acquisition of 2D Cartesian k-space
% data. CORE-PI is a parameter-free non-iterative method. 

% The code package contains exmaples with two datasets: 
% (1) In-vivo 7t brain imaging data.
% (2) Data of a Realistic Analytical Brain Phantom, reproduced with
% permission from the authors of this paper:
%     Guerquin-Kern, Matthieu, et al. "Realistic analytical phantoms for parallel 
%     magnetic resonance imaging." IEEE Transactions on Medical Imaging 31.3
%     (2011): 626-636.

% Whenever you present or publish results that are based on this code,
% please kindly cite the CORE-PI paper (see above).
% If you use the brain phantom data, please also cite its publication. 

% (c) E. Shimron, H. Azhari, 2019

% ====================================================
%      CHOOSE ONE EXAMPLE FROM THE FOLLOWING LISTS 
% ====================================================
% ---- examples with different subsampling schemes, all with a reduction factor of R=6  ----
demo = 'brain_phantom_example';  sampling_scheme='periodic';          wavelet_type = 'db2';
demo = 'brain_phantom_example';  sampling_scheme='variying-period';   wavelet_type = 'db2';
%demo = 'brain_phantom_example';  sampling_scheme='variable-density';  wavelet_type = 'db2';
demo = 'brain_phantom_example';  sampling_scheme='random';            wavelet_type = 'db2';

% --- examples with different wavelet types (R=6) ---
% demo = 'brain_phantom_example';  sampling_scheme='periodic';   wavelet_type = 'haar';  %  Try different wavelet types: 'haar' / 'db5' / 'sym4' / 'coif1' (see fig. 5)
%demo = 'brain_phantom_example';  sampling_scheme='periodic';   wavelet_type = 'coif1';  %  Try different wavelet types: 'haar' / 'db5' / 'sym4' / 'coif1' (see fig. 5)
%demo = 'brain_phantom_example';  sampling_scheme='periodic';   wavelet_type = 'sym4';  %  Try different wavelet types: 'haar' / 'db5' / 'sym4' / 'coif1' (see fig. 5)

% ---- examples with in-vivo data, all with R=4 --------
 demo = 'In_vivo_example_1';      sampling_scheme='periodic';          wavelet_type = 'db2';
% demo = 'In_vivo_example_2';      sampling_scheme='periodic';          wavelet_type = 'db2';


% NOTE: this code currently supports various types of under-sampling
% for the brain phantom data, and only periodic under-sampling for
% the in-vivo data. 

% ================ preparations load k-space data & sensitivity maps  ================
D = DataProcess(demo,sampling_scheme,wavelet_type);

% ================ display sampling mask  ================
figure;
imshow(D.KspaceSampPattern_DC_in_center); axis equal; axis tight; axis off;
title_str = [sampling_scheme,' Sampling, R=',num2str(D.R)];
title(title_str,'FontSize',12);  colormap (gray);

% ================ display gold standard image ================
figure; imagesc(D.GoldStandard4display); title(['Gold Standard']); caxis([D.cmin D.cmax]); axis off; colormap (gray); axis image;

% ============================================
%                     CORE-PI               
% ============================================
% compute the CORE-PI reconstruction
D = CORE_PI(D);

% ======== display wavelet-domain coeffs ======

% concatenate matrices for visualizing
SWT_Rec_MAT_CORE_PI = [D.conv_image_LP_channel_4display  ones(D.N,5) D.conv_image_HP_channel_4display  ];

figure; imagesc(abs([SWT_Rec_MAT_CORE_PI])); axis off; axis image; colormap gray; caxis([0 D.cmax]);
title(['Low-Pass (approximation)      High-Pass (details)      '])
suptitle('Reconstructed SWT decomposition')

% ========= Calc error image & NRMSE ========
err_mat = abs(abs(D.GoldStandard4display)- abs(D.CORE_PI_Rec4display));
NRMSE = calc_NRMSE(D.GoldStandard4display,D.CORE_PI_Rec4display);

% ======== display Gold Standard + Rec + Error ======
MAT = [D.GoldStandard4display   ones(D.N,5) D.CORE_PI_Rec4display ; ones(2,5+2*D.N); ones(D.N,D.N)  ones(D.N,5) err_mat*4];

figure; imagesc(abs(MAT)); axis off; axis image; colormap gray; caxis([0 D.cmax]);
text(10,10,'Gold Standard','Color','w')
text(10+D.N,10,'CORE-PI','Color','w')
text(10+D.N,D.N+2+10,'Error magnified x4','Color','w');
text(10+D.N,2*D.N-10,sprintf('NRMSE=%.5f',NRMSE),'Color','w');


