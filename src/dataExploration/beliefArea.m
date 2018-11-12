sampledata=randn(10000,1);
a=0.01; %0.01 对应99%置信区间， 0.05 对应95%置信区间 ，0.1 对应90%置信区间
if a==0.01
    n=2.576; % 2.576 对应99%置信区间， 1.96 对应95%置信区间 ，1.645 对应90%置信区间
elseif a==0.05
    n=1.96;
elseif a==0.1
    n=1.645;
end
%计算对应百分位值
meana=mean(sampledata);
stda=std(sampledata);
sorta=sort(sampledata);  %对数据从小到大排序
leng=size(sampledata,1);
CIa(1:2,1)=[sorta(leng*a/2);sorta(leng*(1-a/2))];
%利用公式计算置信区间
CIf(1:2,1)=[meana-n*stda;meana+n*stda];