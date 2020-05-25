%% 参数设定

TIME = 56;                                                                  %时段数量
NUMOFTHERMAL = 4;                                                           %热电厂数量
a_f = [0.013 0.015 0.017 0.013];                                            %热电厂成本参数 $/MW2h
b_f = [19.71 19.71 20.39 19.71];                                            % $/MWh
c_f = [1675 1669 1650 1675];                                                % $/h
PI_C = [0.03 0.03 0.02];                                                    %充电费用（UC,UD,BD）$/kWh
PI_D = [0 0 0.04];                                                          %放电费用（UC,UD,BD）$/kWh
Data_load;                                                                  %调用，读取数据


%记录约束结果
P_u_result = [];
P_w_result = [];
P_C_result = [];
P_D_result = [];


%% mode1 UC 无序充电
n = 1;
%自变量
P_C = zeros(TIME,1);
P_D = zeros(TIME,1);
P_w = sdpvar(TIME,1,'full');                                                %风电出力 MW
P_u = sdpvar(TIME,NUMOFTHERMAL,'full');                                     %热电厂出力 MW
% EV约束, 调用
EV_Aggregator1;

%热电厂模型 OMEGA2 约束，调用
Thermal_constraints;
Constraints = [];
Constraints = [Constraints,Constraints2];

%系统约束
for k=1:TIME
    Constraints = [Constraints,0 <= P_w(k) <= P_w_max(k)];              %风电出力约束
    Constraints = [Constraints,P_w(k)+sum(P_u(k,:))-P_ld(k)-P_C(k)+P_D(k) == 0];%功率平衡
end

%目标函数
Z_u = 0;
for k=1:TIME
    Z_u = Z_u+sum(P_u(k,:).^2*a_f'+b_f*P_u(k,:)'+c_f);           %热电厂成本
end
Z_u = Z_u/4;
Z_CD = -PI_C(n)*sum(P_C)*1000/4 + PI_D(n)*sum(P_D)*1000/4;               %EV充放电成本
Z = Z_u+Z_CD;

ops = sdpsettings('debug',1,'solver','cplex','savesolveroutput',1,'savesolverinput',1);
optimize(Constraints,Z,ops)

% P_u_result = [P_u_result,value(P_u)];
% P_w_result = [P_w_result,value(P_w)];
% P_C_result = [P_C_result,value(P_C)];
% P_D_result = [P_D_result,value(P_D)];
% end

huatu;
close;

%% mode2 UD 有序充电
n = 2;
%自变量
P_w = sdpvar(TIME,1,'full');                                                %风电出力 MW
P_u = sdpvar(TIME,NUMOFTHERMAL,'full');                                     %热电厂出力 MW
P_C = sdpvar(TIME,1,'full');                                                %EV充电功率 MW
P_D = zeros(TIME,1);

Constraints = [];
% EV约束, 调用
EV_Aggregator2;
Constraints = [Constraints,constraints1];

%热电厂模型 OMEGA2 约束，调用
Thermal_constraints;
Constraints = [Constraints,Constraints2];

%系统约束
for k=1:TIME
    Constraints = [Constraints,0 <= P_w(k) <= P_w_max(k)];              %风电出力约束
    Constraints = [Constraints,P_w(k)+sum(P_u(k,:))-P_ld(k)-P_C(k)+P_D(k) == 0];%功率平衡
end

Z_u = 0;
for k=1:TIME
    Z_u = Z_u+sum(P_u(k,:).^2*a_f'+b_f*P_u(k,:)'+c_f);           %热电厂成本
end
Z_u = Z_u/4;
Z_CD = -PI_C(n)*sum(P_C)*1000/4 + PI_D(n)*sum(P_D)*1000/4;               %EV充放电成本
Z = Z_u+Z_CD;

ops = sdpsettings('debug',1,'solver','cplex','savesolveroutput',1,'savesolverinput',1);
optimize(Constraints,Z,ops)

% P_u_result = [P_u_result,value(P_u)];
% P_w_result = [P_w_result,value(P_w)];
% P_C_result = [P_C_result,value(P_C)];

huatu2;
close;
% % end


%% mode3 BD 有序充放电
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



Z_u = 0;
for k=1:TIME
    Z_u = Z_u+sum(P_u(k,:).^2*a_f'+b_f*P_u(k,:)'+c_f);           %热电厂成本
end
Z_u = Z_u/4;
Z_CD = (-PI_C(n)*sum(P_C)*1000 + PI_D(n)*sum(P_D)*1000)*delta_t;               %EV充放电成本
Z = Z_u+Z_CD;


ops = sdpsettings('debug',1,'solver','cplex','savesolveroutput',1,'savesolverinput',1);
optimize(Constraints,Z,ops)

huatu3;
close;
% P_u_result = [P_u_result(:,1:8),value(P_u)];
% P_w_result = [P_w_result(:,1:2),value(P_w)];
% P_C_result = [P_C_result(:,1),value(P_C)];
% P_D_result = value(P_D);

