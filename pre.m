clc; clear;
% wind_curtailment1=[];
% totalcost=[];
% for ratio=[0.5,1,1.5,2]%车的数量变为 倍
ratio=1;
     Top_system1;  
%     wind_curtailment1=[wind_curtailment1;zgiveup*sum(P_w_max)/100];%弃风量
%     totalcost=[totalcost;zuacconut];
% end
% % zgiveup=[zgiveup,100*sum(P_w_max-value(P_w))/sum(P_w_max)];%弃风率










%%
% 
% clc; clear;
% ratio=1;   %车的数量变为 倍
% carbon_price;
% wind_curtailment2=zgiveup;


% data = wind_curtailment1;
 data = totalcost;
%  data = wind_curtailment1;
b = bar(data);
   ylim([300000 350000]);
t1 = title('火电总成本','FontSize',24);
x1 = xlabel('渗透率（原有的[0.5,1,1.5,2])倍','FontSize',18);          %轴标题可以用tex解释
y1 = ylabel('总成本（$/MWh)','FontSize',18);
t1.FontName = '宋体';                   %标题格式设置为宋体，否则会乱码
x1.FontName = '宋体'; 
y1.FontName = '宋体'; 
legend('无序充电','有序充电模式','有序充放模式');
saveas(gcf,'火电总成本.jpg'); %保存当前窗口的图像
