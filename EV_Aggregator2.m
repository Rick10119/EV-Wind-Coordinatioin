%% EV constants
% remaining number of e-cars
arrive_time = EV_arrive_leave(:,1);
leave_time = EV_arrive_leave(:,2);

arrive_num = zeros(TIME, 1);
for i = 1:TIME
    arrive_num(i) = ratio*length(find(arrive_time == i));
end

leave_num = zeros(TIME, 1);
for i = 1:TIME
    leave_num(i) = ratio*length(find(leave_time == i));
end
    
car_num = zeros(TIME, 1);
for i = 1:TIME
    car_num(i) = sum(arrive_num(1:i)) - sum(leave_num(1:i));
end
% plot(car_num);

%% charging
% charging mode
% n 表示模式，已经在top中定义
max_charging_power = 10/1000;
min_charging_power = 0/1000;

% charging power constraints
P_C_min = car_num .* min_charging_power;
P_C_max = car_num .* max_charging_power;

delta_t = 0.25;  % 15min 0.25h

% efficiency of dis-/charging
yita_C = 0.85;
yita_D = 0.85;
% energy capacityP_C_result
E_A_max = 40 .* car_num./1000;
E_A_min = 8 .* car_num./1000;
% stored energy of the aggregator
S_A  = (arrive_num .* 20 - leave_num .* 40)./1000;
D_A = leave_num .* 20./1000;
%% EV variables
E_A = sdpvar(TIME, 1, 'full');     

%% EV constraints -- Omega_I
constraints1 = [];

% (3)
constraints1 = [constraints1,E_A(1) == S_A(1)];
for i = 2:TIME
    constraints1 = [constraints1,E_A(i) == E_A(i-1) + ...
        (yita_C * P_C(i) - P_D(i) / yita_D) * delta_t + S_A(i)];
end

% (1)(2)(4)(5)(6)
for i = 1:TIME
    constraints1 = [constraints1, P_C_min(i) <= P_C(i) <= P_C_max(i)];
end

for i = 2:TIME
    constraints1 = [constraints1, E_A_min(i) <= E_A(i) <= E_A_max(i)];
end 
    constraints1 = [constraints1, sum(yita_C .* P_C(1:TIME) - ...
        P_D(1:TIME) ./ yita_D) * delta_t >= sum(D_A(1:TIME))];
% Omega_I = constraints1;