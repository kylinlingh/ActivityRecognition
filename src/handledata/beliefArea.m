sampledata=randn(10000,1);
a=0.01; %0.01 ��Ӧ99%�������䣬 0.05 ��Ӧ95%�������� ��0.1 ��Ӧ90%��������
if a==0.01
    n=2.576; % 2.576 ��Ӧ99%�������䣬 1.96 ��Ӧ95%�������� ��1.645 ��Ӧ90%��������
elseif a==0.05
    n=1.96;
elseif a==0.1
    n=1.645;
end
%�����Ӧ�ٷ�λֵ
meana=mean(sampledata);
stda=std(sampledata);
sorta=sort(sampledata);  %�����ݴ�С��������
leng=size(sampledata,1);
CIa(1:2,1)=[sorta(leng*a/2);sorta(leng*(1-a/2))];
%���ù�ʽ������������
CIf(1:2,1)=[meana-n*stda;meana+n*stda];