%% 参数设定
clc; clear;
TIME = 56;                                                                  %时段数量
NUMOFTHERMAL = 4;                                                           %热电厂数量
a_f = [0.013 0.015 0.017 0.013];                                            %热电厂成本参数 $/MW2h
b_f = [19.71 19.71 20.39 19.71];                                            % $/MWh
c_f = [1675 1669 1650 1675];                                                % $/h
PI_C = [0.03 0.03 0.02];                                                    %充电费用（UC,UD,BD）$/kWh
PI_D = [0 0 0.04];                                                          %放电费用（UC,UD,BD）$/kWh
Data_load;                                                                  %调用，读取数据
%风电预测值 MW   P_w_max
%普通负荷   MW   P_ld

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



%% mode: n = 1:3 表示无序充电、有序充电、有序充放电

for n =1:3            %不同模式
    Constraints = [];
    % EV约束, 调用
    EV_Aggregator;
    Constraints = [Constraints,constraints1];

    %热电厂模型 OMEGA2 约束，调用
    Thermal_constraints;
    Constraints = [Constraints,Constraints2];

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
