function [reconstructSetZero] = mainICAFunc(data)
%mainICAFunc ����data��cxt(cͨ���� t����������)
% ����reconstructSetZero�ṹcxt, ��Ⱥֵ��0���ع��Ľ��
while 1
    [icasig, A, ~, ~, dwm] = PCA_ICA(data);
    if (size(icasig) == size(data))%��ֹfastICA������
        break;
    end
end
SetZero = OutlierZero(icasig);
reconstructSetZero = dwm*(A*SetZero);%������Ⱥֵ��0���ع��Ľ��
end
%======�ֲ�����=======
function outputx = OutlierZero(inputx)
%x��һ������
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