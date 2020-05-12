%% 参数设定
clc; clear;
TIME = 56;                                                                  %时段数量
NUMOFTHERMAL = 4;                                                           %热电厂数量
a_f = [0.013 0.015 0.017 0.013];                                            %热电厂成本参数 $/MW2h
b_f = [19.71 19.71 20.39 19.71];                                            % $/MWh
c_f = [1675 1669 1650 1675];                                                % $/h
PI_C = [0.03 0.03 0.02];                                                    %充电费用（UC,UD,BD）$/kWh
PI_D = [0 0 0.04];                                                          %放电费用（UC,UD,BD）$/kWh
P_w_max = xlsread("附件2-风电出力_普通负荷预测数据.xlsx","load_wind_data","C2:C57");    %风电预测值 MW
P_ld = xlsread("附件2-风电出力_普通负荷预测数据.xlsx","load_wind_data","B2:B57");       %普通负荷   MW
%记录约束结果
P_u_result = [];
P_w_result = [];
P_C_result = [];
P_D_result = [];


%% 约束条件及优化目标
%自变量
P_w = sdpvar(TIME,1,'full');                                                %风电出力 MW
P_u = sdpvar(TIME,NUMOFTHERMAL,'full');                                     %热电厂出力 MW
P_z = binvar(TIME,1,'full');
P_C = sdpvar(TIME,1,'full');                                                %EV充电功率 MW
P_D = sdpvar(TIME,1,'full');                                                %EV放电功率 MW
R_u = zeros(TIME,1);                                                        %热电厂出力爬坡 MW/min
for k=2:TIME
    R_u(k) = (P_u(k)-P_u(k-1))/15;
end
%EV集群模型 OMEGA1  test
P_C_max = 10*ones(TIME,1);
P_D_max = 10*ones(TIME,1);


mode = [0 0 1];
for n=1:3
    Constraints = [];
    for k=1:TIME
        Constraints = [Constraints,0 <= P_C(k) <= P_C_max(k).*P_z(k)];
        Constraints = [Constraints,0 <= P_D(k) <= mode(n)*P_D_max(k).*(1-P_z(k))]; 
    end

    %热电厂模型 OMEGA2


    %系统约束
    for k=1:TIME
        Constraints = [Constraints,0 <= P_w(k) <= P_w_max(k)];              %风电出力约束
        Constraints = [Constraints,P_w(k)+sum(P_u(k,:))-P_ld(k)-P_C(k)+P_D(k) == 0];%功率平衡
    end

    %目标函数
    Z_u = 0;
    for k=1:TIME
        Z_u = Z_u+P_u(k,:)*diag(a_f)*P_u(k,:)'+b_f*P_u(k,:)'+c_f;           %热电厂成本
    end
    Z_u = sum(Z_u);
    Z_CD = PI_C(n)*sum(P_C)*1000/4 - PI_D(n)*sum(P_D)*1000/4;               %EV充放电成本
    Z = Z_u+Z_CD;
    ops = sdpsettings('solver','cplex');
    optimize(Constraints,Z,ops)

    P_u_result = [P_u_result,value(P_u)];
    P_w_result = [P_w_result,value(P_w)];
    P_C_result = [P_C_result,value(P_C)];
    P_D_result = [P_D_result,value(P_D)];
end