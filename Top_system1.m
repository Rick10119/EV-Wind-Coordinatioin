%% �����趨

TIME = 56;                                                                  %ʱ������
NUMOFTHERMAL = 4;                                                           %�ȵ糧����
a_f = [0.013 0.015 0.017 0.013];                                            %�ȵ糧�ɱ����� $/MW2h
b_f = [19.71 19.71 20.39 19.71];                                            % $/MWh
c_f = [1675 1669 1650 1675];                                                % $/h
PI_C = [0.03 0.03 0.02];                                                    %�����ã�UC,UD,BD��$/kWh
PI_D = [0 0 0.04];                                                          %�ŵ���ã�UC,UD,BD��$/kWh
Data_load;                                                                  %���ã���ȡ����


%��¼Լ�����
P_u_result = [];
P_w_result = [];
P_C_result = [];
P_D_result = [];


%% mode1 UC ������
n = 1;
%�Ա���
P_C = zeros(TIME,1);
P_D = zeros(TIME,1);
P_w = sdpvar(TIME,1,'full');                                                %������ MW
P_u = sdpvar(TIME,NUMOFTHERMAL,'full');                                     %�ȵ糧���� MW
% EVԼ��, ����
EV_Aggregator1;

%�ȵ糧ģ�� OMEGA2 Լ��������
Thermal_constraints;
Constraints = [];
Constraints = [Constraints,Constraints2];

%ϵͳԼ��
for k=1:TIME
    Constraints = [Constraints,0 <= P_w(k) <= P_w_max(k)];              %������Լ��
    Constraints = [Constraints,P_w(k)+sum(P_u(k,:))-P_ld(k)-P_C(k)+P_D(k) == 0];%����ƽ��
end

%Ŀ�꺯��
Z_u = 0;
for k=1:TIME
    Z_u = Z_u+sum(P_u(k,:).^2*a_f'+b_f*P_u(k,:)'+c_f);           %�ȵ糧�ɱ�
end
Z_u = Z_u/4;
Z_CD = -PI_C(n)*sum(P_C)*1000/4 + PI_D(n)*sum(P_D)*1000/4;               %EV��ŵ�ɱ�
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

%% mode2 UD ������
n = 2;
%�Ա���
P_w = sdpvar(TIME,1,'full');                                                %������ MW
P_u = sdpvar(TIME,NUMOFTHERMAL,'full');                                     %�ȵ糧���� MW
P_C = sdpvar(TIME,1,'full');                                                %EV��繦�� MW
P_D = zeros(TIME,1);

Constraints = [];
% EVԼ��, ����
EV_Aggregator2;
Constraints = [Constraints,constraints1];

%�ȵ糧ģ�� OMEGA2 Լ��������
Thermal_constraints;
Constraints = [Constraints,Constraints2];

%ϵͳԼ��
for k=1:TIME
    Constraints = [Constraints,0 <= P_w(k) <= P_w_max(k)];              %������Լ��
    Constraints = [Constraints,P_w(k)+sum(P_u(k,:))-P_ld(k)-P_C(k)+P_D(k) == 0];%����ƽ��
end

Z_u = 0;
for k=1:TIME
    Z_u = Z_u+sum(P_u(k,:).^2*a_f'+b_f*P_u(k,:)'+c_f);           %�ȵ糧�ɱ�
end
Z_u = Z_u/4;
Z_CD = -PI_C(n)*sum(P_C)*1000/4 + PI_D(n)*sum(P_D)*1000/4;               %EV��ŵ�ɱ�
Z = Z_u+Z_CD;

ops = sdpsettings('debug',1,'solver','cplex','savesolveroutput',1,'savesolverinput',1);
optimize(Constraints,Z,ops)

% P_u_result = [P_u_result,value(P_u)];
% P_w_result = [P_w_result,value(P_w)];
% P_C_result = [P_C_result,value(P_C)];

huatu2;
close;
% % end


%% mode3 BD �����ŵ�
n = 3;
%�Ա���
P_w = sdpvar(TIME,1,'full');                                                %������ MW
P_u = sdpvar(TIME,NUMOFTHERMAL,'full');                                     %�ȵ糧���� MW
P_z = binvar(TIME,1,'full');
P_C = sdpvar(TIME,1,'full');                                                %EV��繦�� MW
P_D = sdpvar(TIME,1,'full');                                                %EV�ŵ繦�� MW

Constraints = [];
% EVԼ��, ����
EV_Aggregator3;
Constraints = [Constraints,constraints1];

%�ȵ糧ģ�� OMEGA2 Լ��������
Thermal_constraints;
Constraints = [Constraints,Constraints2];

%ϵͳԼ��
for k=1:TIME
    Constraints = [Constraints,0 <= P_w(k) <= P_w_max(k)];              %������Լ��
    Constraints = [Constraints,P_w(k)+sum(P_u(k,:))-P_ld(k)-P_C(k)+P_D(k) == 0];%����ƽ��
end



Z_u = 0;
for k=1:TIME
    Z_u = Z_u+sum(P_u(k,:).^2*a_f'+b_f*P_u(k,:)'+c_f);           %�ȵ糧�ɱ�
end
Z_u = Z_u/4;
Z_CD = (-PI_C(n)*sum(P_C)*1000 + PI_D(n)*sum(P_D)*1000)*delta_t;               %EV��ŵ�ɱ�
Z = Z_u+Z_CD;


ops = sdpsettings('debug',1,'solver','cplex','savesolveroutput',1,'savesolverinput',1);
optimize(Constraints,Z,ops)

huatu3;
close;
% P_u_result = [P_u_result(:,1:8),value(P_u)];
% P_w_result = [P_w_result(:,1:2),value(P_w)];
% P_C_result = [P_C_result(:,1),value(P_C)];
% P_D_result = value(P_D);

