% 在原有的约束上，加上热电厂的约束

%%  热电厂数量
% % NUMOFTHERMAL = 4;

%%
%出力约束(MW)
P_u_min = [20, 20, 25, 25];
P_u_max = [130, 130, 162, 162];
%爬坡约束(MW/min)*（min)
dt = 15;                                                                    %步长为15min
R_u_dM = dt * [ -1.5, -3.0, -1.5, -1.8];
R_u_uM = dt * [ 1.5, 3.0, 1.5, 1.8];
%出力（top中已经定义）
% P_u = sdpvar(TIME,NUMOFTHERMAL,'full');                                   %热电厂出力 MW
% R_u = zeros(TIME,1);                                                      %热电厂出力爬坡 MW/min

%爬坡和出力的关系
R_u = P_u - [P_u(TIME,:); P_u(1:TIME-1,:)];

%%
Constraints2 = [];
% 出力约束
for i = 1:NUMOFTHERMAL
    for k = 1:TIME
        Constraints2 = [Constraints2, P_u_min(i) <= P_u(k,i) <= P_u_max(i)];
    end
end

% 爬坡约束
for i = 1:NUMOFTHERMAL
    for k = 2:TIME %从第二个时刻开始计算约束，因为时间不是首尾相连的
        Constraints2 = [Constraints2, R_u_dM(i)  <= R_u(k,i) <= R_u_uM(i)];
    end
end