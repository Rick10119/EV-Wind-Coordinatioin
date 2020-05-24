

stairs(value(P_C),'y','LineWidth',2); hold on;
stairs(value(P_D),'m','LineWidth',2); hold on;
stairs(value(sum(P_u,2)),'r','LineWidth',2); hold on;
stairs(P_w_max,'b--','LineWidth',1); hold on;
stairs(value(P_w),'b','LineWidth',2);hold on;
stairs(P_ld,'black'); 

%设置figure各个参数
t1 = title('有序充放模式','FontSize',24);
x1 = xlabel('时间点（18:00-8:00以15min为间隔）','FontSize',18);          %轴标题可以用tex解释
y1 = ylabel('功率/MW','FontSize',18);
t1.FontName = '宋体';                   %标题格式设置为宋体，否则会乱码
x1.FontName = '宋体'; 
y1.FontName = '宋体'; 
legend('最大风电出力','实际风机出力');
saveas(gcf,'有序充放.jpg'); %保存当前窗口的图像
zacconut=[zacconut,value(Z)];
zgiveup=[zgiveup,100*sum(P_w_max-value(P_w))/sum(P_w_max)];%弃风率
zshuju=[zshuju,value(P_C),value(P_D),value(sum(P_u,2)),value(P_w)];
zacconut=[zacconut;zgiveup];