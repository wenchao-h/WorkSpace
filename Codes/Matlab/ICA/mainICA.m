load A01T1X144X750X22
x = x{1}';
% [icasig, A, W, wm, dwm] = PCA_ICA(x{1}',1,22);
% % figure;strips(x{1});
% figure;strips(icasig');
% %离群值检验
% [TF,lower,upper,center] = isoutlier(icasig, 'quartiles', 2);
% 
% xxx = 1:750;
% ica = icasig(1,:);
% tfi = TF(1,:);
% figure;plot(xxx,ica,xxx(tfi),ica(tfi),'x',xxx,lower(1)*ones(1,750),xxx,upper(1)*ones(1,750),xxx,center(1)*ones(1,750));
% %离群值置0
% icasig(TF)=0;
% 
% xxx = 1:750;
% ica = icasig(1,:);
% tfi = TF(1,:);
% figure;plot(xxx,ica,xxx(tfi),ica(tfi),'x',xxx,lower(1)*ones(1,750),xxx,upper(1)*ones(1,750),xxx,center(1)*ones(1,750));
% figure;strips(icasig');
% 
% s = A*icasig;
% figure;strips(s');
% 
% s1 = s';icasig1 = icasig';
% figure;plot(s1(:,1));figure;plot(icasig1(:,1));
load icasig.mat
% figure;strips(x{1});title('源信号');
SetZero = OutlierZero(icasig);

figure;strips(icasig');title('ICA分解');
reconstructicasig = dwm*(A*icasig);
figure;strips(reconstructicasig');title('ICA分解后重构');
figure;strips(SetZero');title('离群值置0');
reconstructSetZero = dwm*(A*SetZero);
figure;strips(reconstructSetZero');title('离群值置0后重构');

function outputx = OutlierZero(inputx)
%x是一个向量
isOutlier = zeros(size(inputx));
outputx = zeros(size(inputx));
lower = zeros(size(inputx,1),1);
upper = zeros(size(inputx,1),1);
for i = 1:size(inputx,1)
    [isOutlier(i,:), lower(i), upper(i)] = ADJBP(inputx(i,:));
    outlier = isOutlier(i,:);vector = inputx(i,:);
    vector(logical(outlier)) = 0;
    outputx(i,:) = vector;
end
end
