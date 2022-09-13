clc;
clear all;
close all;
tic;
a = imread('Peppers.png');          
a=imresize(a,[512 512]);       
imshow(a);            
title('Input image'); 
% pannel separation4
R = a(:,:,1);
G = a(:,:,2);
B = a(:,:,3);
G = double(G);
% % % % % 1 level decomp
pv=round(10*rand(512,512));
q=(pv+pv')/2;
[v,d]=eig(q);
v1=GramSchmidt(v);
a=0.5;
m=1;n=0:511;
da=exp(-1i*pi*2*n*a/m);da=diag(da);%Fractional Fourier Transform 
ra1=v1*da*v1';
rx=ra1*G*ra1';
 [LL1 LH1 HL1 HH1]=dwt2(rx,'Haar');
    aa1 = [LL1 LH1;HL1 HH1];    
    figure;
    imshow(aa1,[]);
    title('one level wavelet Decomposition');
    figure,imshow(LL1,[]);
    title('1 Level LL band of G panel');
    si = imread('cameraman.tif');    
    si = imresize(si,[256 256]);
figure, imshow(si);
title('secret image');
% embedding process
si = double(si);
alpha = 0.05;
for i = 1:4:size(LL1,1)
    for j = 1:4:size(LL1,2);
        block = LL1(i:i+3,j:j+3);
        block1 = si(i:i+3,j:j+3);
        emb(i:i+3,j:j+3) = ((1-alpha)*block)+(alpha*block1);
    end
end
figure,imshow(emb,[]);title('embeded image');
% inverse transform
z=idwt2(emb,LH1,HL1,HH1,'haar');
a=-0.5;n=0:511;
ida=exp(-1i*pi*2*n*a/m);ida=diag(ida);
ira=v1*ida*v1';
out1=ira*z*ira';
figure,imshow(abs(out1),[]);
title('inverse transform image');
% stego image
SI(:,:,1) = R;
SI(:,:,2) = out1;
SI(:,:,3) = B;
imshow(SI,[]);
title('stegno image');
imwrite(SI,'result.png','png')
% extraction
A = out1;
a=0.5;
m=1;n=0:511;
da=exp(-1i*pi*2*n*a/m);da=diag(da);%Fractional Fourier Transform 
ra1=v1*da*v1';
rx=ra1*A*ra1';
[ll1 lh1 hl1 hh1]=dwt2(rx,'haar');
alpha = 0.05;
for i = 1:4:size(ll1,1)
    for j = 1:4:size(ll1,2);
        par = ll1(i:i+3,j:j+3);
        par1 = LL1(i:i+3,j:j+3);
        ext(i:i+3,j:j+3) = (par-((1-alpha)*par1))./alpha;
    end
end
figure,imshow(ext,[]);
title('extracted secret image');
% validation
input = double(G);
output = double(out1);
[r c] = size(input);
MSE1 = sum(sum((input-output).^2))/(r*c);
disp('MSE1');
disp(abs(MSE1));
PSNR1 = 10*log10(255*255/MSE1);
disp('PSNR1');
disp(abs(PSNR1));
toc;

