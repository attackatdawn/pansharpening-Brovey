clear; close all; clc;
addpath('Wavelet\wavelet');
NumAlgs = 5;
NumIndexes = 5;
MatrixResults = zeros(NumAlgs,NumIndexes);
%% Load Input
% Set the sensor
% sensor = 'WV2';
% sensor = 'GeoEye1';
sensor = 'IKONOS';
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
         inputImage = load('./imgs/imgwas.mat');
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
        inputImage.ratio=4;
end
I_GT     = double(inputImage.I_MS);
I_PAN_loaded = double(inputImage.I_PAN);
RGB_indexes = inputImage.RGB_indexes;
L = inputImage.L;
ratio = double(inputImage.ratio);
[I_MS_LR, I_PAN] = resize_images(I_GT, I_PAN_loaded, inputImage.ratio, inputImage.sensor);
I_MS = interp23tap(I_MS_LR,ratio);;
%% GT
[Q_avg_GT, SAM_GT, ERGAS_GT, SCC_GT_GT, Q_GT] = indexes_evaluation(I_GT,I_GT,ratio,L,Qblocks_size,flag_cut_bounds,dim_cut,thvalues);
MatrixResults(1,:) = [Q_GT,Q_avg_GT,SAM_GT,ERGAS_GT,SCC_GT_GT];
%% EXP
[Q_avg_EXP, SAM_EXP, ERGAS_EXP, SCC_GT_EXP, Q_EXP] = indexes_evaluation(I_MS,I_GT,ratio,L,Qblocks_size,flag_cut_bounds,dim_cut,thvalues);
MatrixResults(2,:) = [Q_EXP,Q_avg_EXP,SAM_EXP,ERGAS_EXP,SCC_GT_EXP];
%% Pansharpensing
%% Brovey

cd Brovey
t2=tic;
I_Brovey = Brovey(I_MS,I_PAN);
time_Brovey=toc(t2);
fprintf('Elaboration time Brovey: %.2f [sec]\n',time_Brovey);
cd ..

[Q_avg_Brovey, SAM_Brovey, ERGAS_Brovey, SCC_GT_Brovey, Q_Brovey] = indexes_evaluation(I_Brovey,I_GT,ratio,L,Qblocks_size,flag_cut_bounds,dim_cut,thvalues);
MatrixResults(3,:) = [Q_Brovey,Q_avg_Brovey,SAM_Brovey,ERGAS_Brovey,SCC_GT_Brovey];

cd Wavelet
t2=tic;
I_ATWT = ATWT(I_MS,I_PAN,ratio);
time_ATWT = toc(t2);
fprintf('Elaboration time ATWT: %.2f [sec]\n',time_ATWT);
cd ..

[Q_avg_ATWT, SAM_ATWT, ERGAS_ATWT, SCC_GT_ATWT, Q_ATWT] = indexes_evaluation(I_ATWT,I_GT,ratio,L,Qblocks_size,flag_cut_bounds,dim_cut,thvalues);

MatrixResults(4,:) = [Q_ATWT,Q_avg_ATWT,SAM_ATWT,ERGAS_ATWT,SCC_GT_ATWT];

%% ATWT

cd Wavelet
t2=tic;
I_ATWT_B= ATWT_B(I_MS,I_PAN,ratio);
time_ATWT = toc(t2);
fprintf('Elaboration time ATWT_B: %.2f [sec]\n',time_ATWT);
cd ..

[Q_avg_ATWT_B, SAM_ATWT_B, ERGAS_ATWT_B, SCC_GT_ATWT_B, Q_ATWT_B] = indexes_evaluation(I_ATWT_B,I_GT,ratio,L,Qblocks_size,flag_cut_bounds,dim_cut,thvalues);

MatrixResults(5,:) = [Q_ATWT_B,Q_avg_ATWT_B,SAM_ATWT_B,ERGAS_ATWT_B,SCC_GT_ATWT_B];

% % %% Visualization method 1
th_PAN = image_quantile(I_PAN, [0.01 0.99]);
th_MSrgb = image_quantile(I_MS(:,:,RGB_indexes), [0.01 0.99]);
district=[1:100];
subplot(2,3,1);imshow(image_stretch(I_PAN(district,district),th_PAN));
title('Panchromatic reduced-resolution');
subplot(2,3,2);imshow(image_stretch(I_MS_LR(1:25,1:25,RGB_indexes),th_MSrgb));
title('Multispectral low-resolution');
subplot(2,3,3);imshow(image_stretch(I_GT(district,district,RGB_indexes),th_MSrgb)); title('Multispectral high-resolution (reference)');
subplot(2,3,4);imshow(image_stretch(I_Brovey(district,district,RGB_indexes),th_MSrgb));title('Brovey');
subplot(2,3,5);imshow(image_stretch(I_ATWT(district,district,RGB_indexes),th_MSrgb)); title('ATWT');
subplot(2,3,6);imshow(image_stretch(I_ATWT_B(district,district,RGB_indexes),th_MSrgb)); title('ATWT-B');