function [Hst] = getTfString(H)

num = H.num{1};
den = H.den{1};

nnum = length(num);
nden = length(den);

numSt = [];

stformat = '% 6.1f';

for i = 1:nnum
    
    inum = num(i);
    
    if inum>0 && i~=1
        inumSt = ['+',num2str(inum,stformat)];
    else
        if i==1 && inum~=1
            inumSt = [num2str(inum,stformat)];
        else
            inumSt = [];
        end
    end
    
    if inum ~=0
        if i~=nnum && (nnum-i~=1)
            numSt = [numSt,inumSt,'s^',num2str(nnum-i)];
        elseif i~=nnum && (nnum-i==1)
            numSt = [numSt,inumSt,'s'];
        else
            numSt = [numSt,inumSt];
        end
    end
end

denSt = [];
for i = 1:nden
    
    iden = den(i);
    
    if iden>0 && i~=1
        idenSt = ['+',num2str(iden,stformat)];
    else
        if i==1 && iden~=1
            idenSt = [num2str(iden,stformat)];
        else
            idenSt = [];
        end
    end
    
    if iden~=0
        if i~=nden && (nden-i~=1)
            denSt = [denSt,idenSt,'s^',num2str(nden-i)];
        elseif i~=nden && (nden-i==1)
            denSt = [denSt,idenSt,'s'];
        else
            denSt = [denSt,idenSt];
        end
    end
end

Hst = ['\left(\frac{' numSt '}{' denSt '}\right)'];

% figure;
% title(Hst,'interpreter','latex','fontsize',15);