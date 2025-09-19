function out=varycolor(NumberOfLines, excludeColors)
% VARYCOLOR Produces colors with maximum variation on plots with multiple
% lines.
%
%     VARYCOLOR(X) returns a matrix of dimension X by 3.  The matrix may be
%     used in conjunction with the plot command option 'color' to vary the
%     color of lines.  
%
%     Yellow and White colors were not used because of their poor
%     translation to presentations.
% 
%     Example Usage:
%         NumberOfLines=50;
%
%         ColorSet=varycolor(NumberOfLines);
% 
%         figure
%         hold on;
% 
%         for m=1:NumberOfLines
%             plot(ones(20,1)*m,'Color',ColorSet(m,:))
%         end

%Created by Daniel Helmick 8/12/2008




narginchk(1,2)%correct number of input arguements??
nargoutchk(0, 1)%correct number of output arguements??
RequestedNumLines = NumberOfLines;
out={};
if nargin == 1
    excludeColors = {};   
else
    NumberOfLines = NumberOfLines + length(excludeColors);
end



%Take care of the anomolies
if NumberOfLines<1
    ColorSet=[];
elseif NumberOfLines==1
    ColorSet=[0 1 0];
elseif NumberOfLines==2
    ColorSet=[0 1 0; 0 1 1];
elseif NumberOfLines==3
    ColorSet=[0 1 0; 0 1 1; 0 0 1];
elseif NumberOfLines==4
    ColorSet=[0 1 0; 0 1 1; 0 0 1; 1 0 1];
elseif NumberOfLines==5
    ColorSet=[0 1 0; 0 1 1; 0 0 1; 1 0 1; 1 0 0];
elseif NumberOfLines==6
    ColorSet=[0 1 0; 0 1 1; 0 0 1; 1 0 1; 1 0 0; 0 0 0];

else %default and where this function has an actual advantage

    %we have 5 segments to distribute the plots
    EachSec=floor(NumberOfLines/5); 
    
    %how many extra lines are there? 
    ExtraPlots=mod(NumberOfLines,5); 
    
    %initialize our vector
    ColorSet=zeros(NumberOfLines,3);
    
    %This is to deal with the extra plots that don't fit nicely into the
    %segments
    Adjust=zeros(1,5);
    for m=1:ExtraPlots
        Adjust(m)=1;
    end
    
    SecOne   =EachSec+Adjust(1);
    SecTwo   =EachSec+Adjust(2);
    SecThree =EachSec+Adjust(3);
    SecFour  =EachSec+Adjust(4);
    SecFive  =EachSec;

    for m=1:SecOne
        ColorSet(m,:)=[0 1 (m-1)/(SecOne-1)];
    end

    for m=1:SecTwo
        ColorSet(m+SecOne,:)=[0 (SecTwo-m)/(SecTwo) 1];
    end
    
    for m=1:SecThree
        ColorSet(m+SecOne+SecTwo,:)=[(m)/(SecThree) 0 1];
    end
    
    for m=1:SecFour
        ColorSet(m+SecOne+SecTwo+SecThree,:)=[1 0 (SecFour-m)/(SecFour)];
    end

    for m=1:SecFive
        ColorSet(m+SecOne+SecTwo+SecThree+SecFour,:)=[(SecFive-m)/(SecFive) 0 0];
    end
end

exClr = cat(1,excludeColors{:});

if ~isempty(exClr)
    [~, Locb] = ismember(exClr,ColorSet, 'rows');
    if Locb ~= 0
        ColorSet(Locb,:) = [];
    end
    if size(ColorSet,1) > RequestedNumLines
        ColorSet = ColorSet(1:RequestedNumLines,:);
    end
end

for i = 1:size(ColorSet,1)
    out{i} = ColorSet(i,:); 
end


end