clc;
clear all;
close all;
a = imread('peppers.png');          
a=imresize(a,[512 512]); 
figure(1);
imshow(a);            
title('Input image');
% pannel separation4
R = a(:,:,1);
G = a(:,:,2);
B = a(:,:,3);
G = double(G);
%  3 level wavelet transform
% % % % % 1 level decomp
    [LL1, LH1, HL1, HH1] = dwt2(G,'haar');
% % % % 2nd level decomp
    [LL2, LH2, HL2, HH2] = dwt2(LL1,'haar');
% % % 3rd level Decomp
    [LL3, LH3, HL3, HH3] = dwt2(LL2,'haar');
    aa1 = [LL3 LH3;HL3 HH3];
    aa2 = [aa1 LH2;HL2 HH2];
    aa3 = [aa2 LH1;HL1 HH1];    
    figure(2);
    imshow(aa3,[]);
    title('three level wavelet Decomposition');
    figure(3);
    imshow(LL3,[]);
    title('3Level LL band of G panel');
    
    % selection of secret image
    si = imread('cameraman.tif');
    si = imresize(si,[64 64]);
    s_img_arnold=arnold(si, 50);
    figure(4);
    imshow(uint8(s_img_arnold));
    s_scramble=hb_imageScramble(uint8(s_img_arnold),4,true);
    %figure(5);
    %imshow(uint8(s_scramble));
 
% end
   
figure, imshow(si);
title('secret image');
 
% embedding process
 
s_scramble = double(s_scramble);
alpha = 0.05;
for i = 1:4:size(LL3,1)
    for j = 1:4:size(LL3,2);
        block = LL3(i:i+3,j:j+3);
        block1 = s_scramble(i:i+3,j:j+3);
        emb(i:i+3,j:j+3) = ((1-alpha)*block)+(alpha*block1);
    end
end
%figure,imshow(emb,[]);
% inverse transform
out3 = idwt2(emb,LH3,HL3,HH3,'haar');
out2 = idwt2(out3,LH2,HL2,HH2,'haar');
out1 = idwt2(out2,LH1,HL1,HH1,'haar');
figure,imshow(out1,[]);
title('inverse transform image');
 
% stego image
 
SI(:,:,1) = R;
SI(:,:,2) = out1;
SI(:,:,3) = B;
imshow(SI,[]);
title('stego image');
% extraction
A = out1;
[ll1 lh1 hl1 hh1] = dwt2(A,'haar');
[ll2 lh2 hl2 hh2] = dwt2(ll1,'haar');
[ll3 lh3 hl3 hh3] = dwt2(ll2,'haar');
 
alpha = 0.05;
for i = 1:4:size(ll3,1)
    for j = 1:4:size(ll3,2);
        par = ll3(i:i+3,j:j+3);
        par1 = LL3(i:i+3,j:j+3);
        ext(i:i+3,j:j+3) = (par-((1-alpha)*par1))./alpha;
    end
end
figure,imshow(ext,[]);
title('extracted secret image');
%si_unscramble=unscramble(ext);
%outimg=iarnold(si_unscramble,50);
%figure;
%imshow(outimg);
% validation
input = double(G);
output = double(out1);
[r c] = size(input);
MSE1 = 0.5*sum(sum((input-output).^2))/(r*c);
disp('MSE1');
disp(MSE1);
PSNR1 = 10*log10(255*255/MSE1);
disp('PSNR1');
disp(PSNR1);
