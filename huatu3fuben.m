

stairs(value(P_C),'y','LineWidth',2); hold on;
stairs(value(P_D),'m','LineWidth',2); hold on;
stairs(value(sum(P_u,2)),'r','LineWidth',2); hold on;
stairs(P_w_max,'b--','LineWidth',1); hold on;
stairs(value(P_w),'b','LineWidth',2);hold on;
stairs(P_ld,'black'); 

%����figure��������
t1 = title('������ģʽ','FontSize',24);
x1 = xlabel('ʱ��㣨18:00-8:00��15minΪ�����','FontSize',18);          %����������tex����
y1 = ylabel('����/MW','FontSize',18);
t1.FontName = '����';                   %�����ʽ����Ϊ���壬���������
x1.FontName = '����'; 
y1.FontName = '����'; 
legend('��������','ʵ�ʷ������');
saveas(gcf,'������.jpg'); %���浱ǰ���ڵ�ͼ��
zacconut=[zacconut,value(Z)];
zgiveup=[zgiveup,100*sum(P_w_max-value(P_w))/sum(P_w_max)];%������
zshuju=[zshuju,value(P_C),value(P_D),value(sum(P_u,2)),value(P_w)];
zacconut=[zacconut;zgiveup];