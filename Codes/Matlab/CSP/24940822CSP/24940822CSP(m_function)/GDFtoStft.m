clc;clear;
global Fs;%采样频率
global N;%提取特征对数
global DATA_CHANNEL;%通道数
global DATA_LENGTH;%样本长度
global time_start;%开始时间
global time_end;%结束时间
global data_source;%存放原始数据
global data_x;%存放滤波后的数据
global data_y;%存放数据对应标签
global R;%样本的相关系数
global data_size;%样本数量
global data_index;%数据池指针
global F;%CSP所寻找到的投影方向
global w;%LDA权值
global b;%LDA偏移
global filter_a;%滤波系数a
global filter_b;%滤波系数b

%读取数据
[signal,h] = sload('D:\MyFiles\EEGProject\BCICompetitionIV\BCICIV_2a_gdf\A06T.gdf');%,0,'OVERFLOWDETECTION:OFF'
save GDFA06T signal h;
%属性设置
Fs=h.EVENT.SampleRate;%采样率
%DATA_CHANNEL=h.NS;%通道数
DATA_CHANNEL=22;
%DATA_LENGTH=h.NRec;%数据长度3000个点
DATA_LENGTH=313;
time_start=1;
time_end=DATA_LENGTH;
data_source=s;
data_size = length(h.Classlabel);
N=3;
POS = h.EVENT.POS;%标签位置
TYP = h.EVENT.TYP;%标签类型
DUR = h.EVENT.DUR;%持续时间

%样本的脑电部分
data_source =data_source(:, 1:22);
smean = nanmean(data_source);
s1 = (isnan(data_source)==1);
s2 = zeros(size(data_source));
for i = DATA_CHANNEL    
    s2(:,i) = smean(i).* s1(:,i);
end
data_source(isnan(data_source)==1)=0;
data_source = data_source + s2;
%所有左的样本
num_left = sum(TYP == 769);
onset_left_POS = POS(TYP == 769);
onset_left_DUR = DUR(TYP == 769);
onset_left =cell(1,num_left);%左样本的个数
y_left=cell(1,num_left);
for i=1 : num_left
    onset_left{i} = data_source(onset_left_POS(i)-1125+1:onset_left_POS(i)-375, :);
    onsetLeftC3{i} = onset_left{i}(:,8);
    onsetLeftC4{i} = onset_left{i}(:,12);
    y_left{i} = 1;
end

%所有右的样本
num_right = sum(TYP == 770);
onset_right_POS = POS(find(TYP == 770));
onset_right_DUR = DUR(find(TYP == 770));
onset_right = cell(1,num_right);%右样本的个数
y_right = cell(1,num_right);
for i=1 : num_right
    onset_right{i} = data_source(onset_right_POS(i)-1125+1:onset_right_POS(i)-375, :);
    onsetRightC3{i} = onset_right{i}(:,8);
    onsetRightC4{i} = onset_right{i}(:,12);
    y_right{i} = -1;
end

% csp_2(onset_left,onset_right);

% data_save('data.mat');

%===============
x = [onset_right onset_left];%1*144cell
x_Train = [x(1:13) x(15:21) x(73:92)];%删除第14组数据 左右各20训练集 
x_Test = [x(22:72) x(93:144)];%51右 52左测试集
% x_Train = [x(1:13) x(15:51) x(73:122)];%删除第14组数据 左右各50训练集 
% x_Test = [x(52:72) x(123:144)];%21右 22左测试集
x = [x_Train x_Test];%1*143
y = [y_right y_left];
y_Train = [y(1:13) y(15:21) y(73:92)];
y_Test = [y(22:72) y(93:144)];
% y_Train = [y(1:13) y(15:51) y(73:122)];%删除第14组数据 左右各50训练集 
% y_Test = [y(52:72) y(123:144)];%21右 22左测试集
y = [y_Train y_Test];
%===============
filt_n =5;%带通滤波器阶数

%Wn截止频率(带通滤波范围)
%8Hz-30Hz带通滤波：8/(Fs/2)~30/(Fs/2)
Wn=[8 30]/(Fs/2);

%[b,a]=butter(n,Wn)设计一个带通滤波器，生成滤波系数
%n为阶数，Wn为截止频率(与采样频率Fs有关)
%b,a为滤波器系数 用于filter(b,a,x)函数
[filter_b,filter_a]=butter(filt_n,Wn);

right=0;all=0;
save MIdata onsetLeftC3 onsetLeftC4 onsetRightC3 onsetRightC4;