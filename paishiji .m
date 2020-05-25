n = 3;
%自变量
P_w = sdpvar(TIME,1,'full');                                                %风电出力 MW
P_u = sdpvar(TIME,NUMOFTHERMAL,'full');                                     %热电厂出力 MW
P_z = binvar(TIME,1,'full');
P_C = sdpvar(TIME,1,'full');                                                %EV充电功率 MW
P_D = sdpvar(TIME,1,'full');                                                %EV放电功率 MW

Constraints = [];
% EV约束, 调用
EV_Aggregator3;
Constraints = [Constraints,constraints1];

%热电厂模型 OMEGA2 约束，调用
Thermal_constraints;
Constraints = [Constraints,Constraints2];

%系统约束
for k=1:TIME
    Constraints = [Constraints,0 <= P_w(k) <= P_w_max(k)];              %风电出力约束
    Constraints = [Constraints,P_w(k)+sum(P_u(k,:))-P_ld(k)-P_C(k)+P_D(k) == 0];%功率平衡
end
%实际
shiji;
P_C_pai = sum(P_C_shiji(:,2:end),1)'/1000; 
for k=1:TIME
    Constraints = [Constraints, -0.1 <= P_C_pai(k)- P_C(k)+ P_D(k) <= 0.1];              %实际出力约束
end

Z_u = 0;
for k=1:TIME
    Z_u = Z_u+sum(P_u(k,:).^2*a_f'+b_f*P_u(k,:)'+c_f);           %热电厂成本
end
Z_u = Z_u/4;
Z_CD = (-PI_C(n)*sum(P_C)*1000 + PI_D(n)*sum(P_D)*1000)*delta_t;               %EV充放电成本
Z = Z_u+Z_CD;


ops = sdpsettings('debug',1,'solver','cplex','savesolveroutput',1,'savesolverinput',1);
optimize(Constraints,Z,ops)

%%
stairs(P_C,'y','LineWidth',2); hold on;
stairs(value(P_D),'m','LineWidth',2); hold on;
stairs(value(sum(P_u,2)),'r','LineWidth',2); hold on;
stairs(P_w_max,'b--','LineWidth',1); hold on;
stairs(value(P_w),'b','LineWidth',2);hold on;
stairs(P_ld,'black'); 

%设置figure各个参数
t1 = title('有序充放模式(实际）','FontSize',24);
x1 = xlabel('时间点（18:00-8:00以15min为间隔）','FontSize',18);          %轴标题可以用tex解释
y1 = ylabel('功率/MW','FontSize',18);
t1.FontName = '宋体';                   %标题格式设置为宋体，否则会乱码
x1.FontName = '宋体'; 
y1.FontName = '宋体'; 
legend('电动汽车充电总功率','电动汽车放电总功率','火电厂总出力', ...
    '最大风电出力','实际风机出力','其他负荷');
saveas(gcf,'有序充放（实际）.jpg'); %保存当前窗口的图像
zacconut=[zacconut,value(Z)];
zgiveup=[zgiveup,100*sum(P_w_max-value(P_w))/sum(P_w_max)];%弃风率
zshuju=[zshuju,value(P_C),value(P_D),value(sum(P_u,2)),value(P_w)];
% close;
% P_u_result = [P_u_result(:,1:8),value(P_u)];
% P_w_result = [P_w_result(:,1:2),value(P_w)];
% P_C_result = [P_C_result(:,1),value(P_C)];
% P_D_result = value(P_D);