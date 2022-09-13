function out = arnold1(im,num)
[rown,coln]=size(im);
figure(1)
for inc=1:num
for row=1:rown
    for col=1:coln
        
        nrowp = row;
        ncolp=col;
        for ite=1:inc
            newcord =[1 1;1 2]*[nrowp ncolp]';
            nrowp=newcord(1);
            ncolp=newcord(2);
        end
        newim(row,col)=im((mod(nrowp,rown)+1),(mod(ncolp,coln)+1));
        
    end
end
end
end