%% �����趨
clc; clear;
TIME = 56;                                                                  %ʱ������
NUMOFTHERMAL = 4;                                                           %�ȵ糧����
a_f = [0.013 0.015 0.017 0.013];                                            %�ȵ糧�ɱ����� $/MW2h
b_f = [19.71 19.71 20.39 19.71];                                            % $/MWh
c_f = [1675 1669 1650 1675];                                                % $/h
PI_C = [0.03 0.03 0.02];                                                    %�����ã�UC,UD,BD��$/kWh
PI_D = [0 0 0.04];                                                          %�ŵ���ã�UC,UD,BD��$/kWh
P_w_max = xlsread("����2-������_��ͨ����Ԥ������.xlsx","load_wind_data","C2:C57");    %���Ԥ��ֵ MW
P_ld = xlsread("����2-������_��ͨ����Ԥ������.xlsx","load_wind_data","B2:B57");       %��ͨ����   MW
%��¼Լ�����
P_u_result = [];
P_w_result = [];
P_C_result = [];
P_D_result = [];


%% Լ���������Ż�Ŀ��
%�Ա���
P_w = sdpvar(TIME,1,'full');                                                %������ MW
P_u = sdpvar(TIME,NUMOFTHERMAL,'full');                                     %�ȵ糧���� MW
P_z = binvar(TIME,1,'full');
P_C = sdpvar(TIME,1,'full');                                                %EV��繦�� MW
P_D = sdpvar(TIME,1,'full');                                                %EV�ŵ繦�� MW
R_u = zeros(TIME,1);                                                        %�ȵ糧�������� MW/min
for k=2:TIME
    R_u(k) = (P_u(k)-P_u(k-1))/15;
end
%EV��Ⱥģ�� OMEGA1  test
P_C_max = 10*ones(TIME,1);
P_D_max = 10*ones(TIME,1);


mode = [0 0 1];
for n=1:3
    Constraints = [];
    for k=1:TIME
        Constraints = [Constraints,0 <= P_C(k) <= P_C_max(k).*P_z(k)];
        Constraints = [Constraints,0 <= P_D(k) <= mode(n)*P_D_max(k).*(1-P_z(k))]; 
    end

    %�ȵ糧ģ�� OMEGA2


    %ϵͳԼ��
    for k=1:TIME
        Constraints = [Constraints,0 <= P_w(k) <= P_w_max(k)];              %������Լ��
        Constraints = [Constraints,P_w(k)+sum(P_u(k,:))-P_ld(k)-P_C(k)+P_D(k) == 0];%����ƽ��
    end

    %Ŀ�꺯��
    Z_u = 0;
    for k=1:TIME
        Z_u = Z_u+P_u(k,:)*diag(a_f)*P_u(k,:)'+b_f*P_u(k,:)'+c_f;           %�ȵ糧�ɱ�
    end
    Z_u = sum(Z_u);
    Z_CD = PI_C(n)*sum(P_C)*1000/4 - PI_D(n)*sum(P_D)*1000/4;               %EV��ŵ�ɱ�
    Z = Z_u+Z_CD;
    ops = sdpsettings('solver','cplex');
    optimize(Constraints,Z,ops)

    P_u_result = [P_u_result,value(P_u)];
    P_w_result = [P_w_result,value(P_w)];
    P_C_result = [P_C_result,value(P_C)];
    P_D_result = [P_D_result,value(P_D)];
end