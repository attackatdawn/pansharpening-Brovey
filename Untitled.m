function I_Fus_Brovey = Brovey(I_MS,I_PAN)

imageLR = double(I_MS);
imageHR = double(I_PAN);

% Intensity Component
I = mean(imageLR,3);

% Equalization PAN component
imageHR = (imageHR - mean2(imageHR)).*(std2(I)./std2(imageHR)) + mean2(I);  

I_Fus_Brovey = imageLR .* repmat(imageHR./(I+eps),[1 1 size(imageLR,3)]);

end