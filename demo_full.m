clear; close all; clc;

%% Setup
% Set Matconvnet Path
% matConvnetPath = '...Your Matconvnet Path Here (tested on 1.0-beta18 version)...';
% run(fullfile(matConvnetPath,'matlab\vl_setupnn'));
NumAlgs = 5;

NumIndexes = 3;

MatrixResults = zeros(NumAlgs,NumIndexes);
%% Load Input
% sensor = 'WV2';
sensor = 'GeoEye1';
switch sensor
        case 'GeoEye1'
        inputImage = load('./imgs/imgGeoEye1.mat');
        % Quality Index Blocks
        Qblocks_size = 32;
        % Interpolator
        bicubic = 0;
        % Cut Final Image
        flag_cut_bounds = 1;
        dim_cut = 11;
        % Threshold values out of dynamic range
        thvalues = 0;
        % Print Eps
        printEPS = 0;
        im_tag = 'Tls1';
    case 'IKONOS'
        inputImage = load('./imgs/imgIKONOS.mat');
        % Quality Index Blocks
        Qblocks_size = 32;
        % Interpolator
        bicubic = 0;
        % Cut Final Image
        flag_cut_bounds = 1;
        dim_cut = 11;
        % Threshold values out of dynamic range
        thvalues = 0;
        % Print Eps
        printEPS = 0;
        im_tag = 'Tls1';
    case 'WV2';
        inputImage = load('./imgs/imgWV2.mat');
        % Quality Index Blocks
        Qblocks_size = 32;
        % Interpolator
        bicubic = 0;
        % Cut Final Image
        flag_cut_bounds = 1;
        dim_cut = 11;
        % Threshold values out of dynamic range
        thvalues = 0;
        im_tag='WV2';
        % Print Eps
        printEPS = 0;
end
I_MS_LR = double(inputImage.I_MS);
I_PAN   = double(inputImage.I_PAN);
ratio = double(inputImage.ratio);
L = double(inputImage.L);
I_MS = interp23tap(I_MS_LR,ratio);
RGB_indexes = inputImage.RGB_indexes;
[D_lambda_EXP,D_S_EXP,QNRI_EXP,SAM_EXP,SCC_EXP] = indexes_evaluation_FS(I_MS,I_MS_LR,I_PAN,L,thvalues,I_MS,sensor,im_tag,ratio);
MatrixResults(1,:) = [D_lambda_EXP,D_S_EXP,QNRI_EXP];
%% Pansharpensing
%% Brovey

cd Brovey
t2=tic;
I_Brovey = Brovey(I_MS,I_PAN);
time_Brovey=toc(t2);
fprintf('Elaboration time Brovey: %.2f [sec]\n',time_Brovey);
cd ..

[D_lambda_Brovey,D_S_Brovey,QNRI_Brovey,SAM_Brovey,SCC_Brovey] = indexes_evaluation_FS(I_Brovey,I_MS_LR,I_PAN,L,thvalues,I_MS,sensor,im_tag,ratio);

MatrixResults(2,:) = [D_lambda_Brovey,D_S_Brovey,QNRI_Brovey];

%% ATWT

cd Wavelet
t2=tic;
I_ATWT = ATWT(I_MS,I_PAN,ratio);

time_ATWT = toc(t2);
fprintf('Elaboration time ATWT: %.2f [sec]\n',time_ATWT);
cd ..
[D_lambda_ATWT,D_S_ATWT,QNRI_ATWT,SAM_ATWT,SCC_ATWT] = indexes_evaluation_FS(I_ATWT,I_MS_LR,I_PAN,L,thvalues,I_MS,sensor,im_tag,ratio);
MatrixResults(3,:) = [D_lambda_ATWT,D_S_ATWT,QNRI_ATWT];

cd Wavelet
t2=tic;
I_ATWT_B = ATWT_B(I_MS,I_PAN,ratio);

time_ATWT_2= toc(t2);
fprintf('Elaboration time ATWT_2: %.2f [sec]\n',time_ATWT);
cd ..
[D_lambda_ATWT_B,D_S_ATWT_B,QNRI_ATWT_B,SAM_ATWT_B,SCC_ATWT_B] = indexes_evaluation_FS(I_ATWT_B,I_MS_LR,I_PAN,L,thvalues,I_MS,sensor,im_tag,ratio);
MatrixResults(4,:) = [D_lambda_ATWT_B,D_S_ATWT_B,QNRI_ATWT_B];


%% Visualization
figure();
subplot(2,3,1);
th_PAN = image_quantile(I_PAN, [0.01 0.99]);
imshow( image_stretch(I_PAN,th_PAN)); title('Panchromatic');

subplot(2,3,2);
th_MSrgb = image_quantile(I_MS_LR(:,:,RGB_indexes), [0.01 0.99]);
imshow(image_stretch(I_MS_LR(:,:,RGB_indexes),th_MSrgb)); title('Multispectral low-resolution');

subplot(2,3,3);
imshow(image_stretch(I_Brovey(:,:,RGB_indexes),th_MSrgb)); title('Brovey');

subplot(2,3,4);
imshow(image_stretch(I_ATWT(:,:,RGB_indexes),th_MSrgb)); title('ATWT');

subplot(2,3,5);
imshow(image_stretch(I_ATWT_B(:,:,RGB_indexes),th_MSrgb)); title('ATWT-B');



