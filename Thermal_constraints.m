% ��ԭ�е�Լ���ϣ������ȵ糧��Լ��

%%  �ȵ糧����
% % NUMOFTHERMAL = 4;

%%
%����Լ��(MW)
P_u_min = [20, 20, 25, 25];
P_u_max = [130, 130, 162, 162];
%����Լ��(MW/min)*��min)
dt = 15;                                                                    %����Ϊ15min
R_u_dM = dt * [ -1.5, -3.0, -1.5, -1.8];
R_u_uM = dt * [ 1.5, 3.0, 1.5, 1.8];
%������top���Ѿ����壩
% P_u = sdpvar(TIME,NUMOFTHERMAL,'full');                                   %�ȵ糧���� MW
% R_u = zeros(TIME,1);                                                      %�ȵ糧�������� MW/min

%���ºͳ����Ĺ�ϵ
R_u = P_u - [P_u(TIME,:); P_u(1:TIME-1,:)];

%%
Constraints2 = [];
% ����Լ��
for i = 1:NUMOFTHERMAL
    for k = 1:TIME
        Constraints2 = [Constraints2, P_u_min(i) <= P_u(k,i) <= P_u_max(i)];
    end
end

% ����Լ��
for i = 1:NUMOFTHERMAL
    for k = 2:TIME %�ӵڶ���ʱ�̿�ʼ����Լ������Ϊʱ�䲻����β������
        Constraints2 = [Constraints2, R_u_dM(i)  <= R_u(k,i) <= R_u_uM(i)];
    end
end