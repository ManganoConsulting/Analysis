function [] = xset_legend(legtitle,col)
import FilterDesign.*
figure(999);
set(gcf,'visible','off');
for i = 1:length(legtitle)
    h = plot(0,0,'LineWidth',2,'Color',col{i});
    hold on;
end
legend(legtitle,'location','north');
set(gca,'visible','off');
%set(gcf,'units','normalized','position',[0.64    0.2676    0.25    0.6123]);
set(gcf,'Name','Legend');
set(gcf,'visible','on');
hold off;