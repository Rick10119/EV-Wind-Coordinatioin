%% comments
% variable[i][k] variable at the kth bus for the ith time period
% Omega_I EV constraints set
% P_C[i][k] charging power of an aggregator
% P_D[i][k] discharging power of an aggregator 
% E_A[i][k] charged energy of an aggregator 
% yita_C EV charging efficiency
% yita_D EV discharging efficiency
% delta_t time step
% S_A[i][k] step change in the stored energy due to EV's move
% arrive_num[i] number of cars arrived in the ith time period
% leave_num[i] leave numbers
% car_num[i] number of cars in the aggregator in the ith time period

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


%% charging
delta_t = 0.25;  % 15min 0.25h
E_A = zeros(TIME, 1);

% efficiency of dis-/charging
yita_C = 0.85;
yita_D = 0.85;
% stored energy of the aggregator
S_A  = (arrive_num .* 20 - leave_num .* 40) ./ 1000;


for i = 1:8
    P_C(i) = car_num(i) .* 10 / 1000;
    P_D(i) = 0;
end
for i = 9:TIME
    P_C(i) = sum(arrive_num(i-7:i)) .* 10 / 1000;
    P_D(i) = 0;
end

E_A(1) = S_A(1);
for i = 2:TIME
    E_A(i) = E_A(i-1) + (yita_C * P_C(i) - P_D(i) / yita_D) * delta_t + S_A(i);
end

constraints1 = [];


    


