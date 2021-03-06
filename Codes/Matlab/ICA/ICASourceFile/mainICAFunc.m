function [reconstructSetZero] = mainICAFunc(data)
%mainICAFunc 输入data：cxt(c通道数 t采样本点数)
% 返回reconstructSetZero结构cxt, 离群值置0后重构的结果
while 1
    [icasig, A, ~, ~, dwm] = PCA_ICA(data);
    if (size(icasig) == size(data))%防止fastICA不收敛
        break;
    end
end
SetZero = OutlierZero(icasig);
reconstructSetZero = dwm*(A*SetZero);%返回离群值置0后重构的结果
end
%======局部函数=======
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
