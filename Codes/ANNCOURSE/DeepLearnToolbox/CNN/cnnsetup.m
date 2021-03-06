function net = cnnsetup(net, x, y)
% cnnsetup用于初始化CNN的参数，返回net
% 设置各层的mapsize大小 
% assert(~isOctave() || compare_versions(OCTAVE_VERSION, '3.8.0', '>='), ['Octave 3.8.0 or greater is required for CNNs as there is a bug in convolution in previous versions. See http://savannah.gnu.org/bugs/?39314. Your version is ' myOctaveVersion]);
numInputmaps = 1;
mapsize = size(squeeze(x(:, :, 1)));%[28, 28];一个行向量。x(:, :, 1)是一个训练样本,squeeze 除去size为1的维度
% 下面通过传入net这个结构体来逐层构建CNN网络
% 初始化卷积层的卷积核、bias 
for l = 1 : numel(net.layers)   %  layer=5
    %s:降采样层
    if strcmp(net.layers{l}.type, 's')
        %降采样图的大小mapsize由28*28变为14*14。net.layers{l}.scale = 2。
        %mapsize = mapsize / net.layers{l}.scale;
        mapsize(1) = mapsize(1) / net.layers{l}.scale(1)
        mapsize(2) = mapsize(2) / net.layers{l}.scale(2);
        
        assert(all(floor(mapsize)==mapsize), ['Layer ' num2str(l) ' size must be integer. Actual: ' num2str(mapsize)]);
        for j = 1 : numInputmaps % 一个降采样层的所有输入map
            % bias统一初始化为0
            net.layers{l}.b{j} = 0;
        end
    end
    %c:卷积层
    if strcmp(net.layers{l}.type, 'c')
        %得到卷积层的featuremap的size，卷积层fm的大小 为 上一层大小 - 卷积核大小 + 1（步长为1的情况）
        mapsize = mapsize - [net.layers{l}.kernelsize(1),net.layers{l}.kernelsize(2)] + 1;
        %fan_out该层的所有连接的数量 = 卷积核数 * 卷积核size = 6*(5*5)，12*(5*5)
        fan_out = net.layers{l}.outputmaps * net.layers{l}.kernelsize(1)*net.layers{l}.kernelsize(2);
        %卷积核初始化，1层卷积为1*6个卷积核，2层卷积一共有6*12=72个卷积核。
        for j = 1 : net.layers{l}.outputmaps  %  每个卷积核
            %输入做卷积
            % fan_in = 本层的一个输出map所对应的所有卷积核，包含的权值的总数 = 1*25,6*25
            fan_in = numInputmaps * net.layers{l}.kernelsize(1)*net.layers{l}.kernelsize(2);
            for i = 1 : numInputmaps  %  input map
                %卷积核的初始化生成一个5*5的卷积核，值为-1~1之间的随机数
                %再乘以sqrt(6/(7*25))，sqrt(6/(18*25))
                net.layers{l}.k{i}{j} = (rand(net.layers{l}.kernelsize(1),net.layers{l}.kernelsize(2)) - 0.5) * 2 * sqrt(6 / (fan_in + fan_out));
            end
            % bias统一初始化为0，每个输出map只有一个bias，并非每个filter一个bias
            net.layers{l}.b{j} = 0;
        end
        numInputmaps = net.layers{l}.outputmaps;
    end
end
% 尾部单层感知机的参数设置（全连接层)
% 'onum' is the number of labels, that's why it is calculated using size(y, 1). If you have 20 labels so the output of the network will be 20 neurons.
% 'fvnum' is the number of output neurons at the last layer, the layer just before the output layer.
% 'ffb' is the biases of the output neurons.
% 'ffW' is the weights between the last layer and the output neurons. Note that the last layer is fully connected to the output layer, that's why the size of the weights is (onum * fvnum)
fvnum = prod(mapsize) * numInputmaps;%prod函数用于求数组元素的乘积，fvnum = 4*4*12 = 192，是全连接层的输入数量
onum = size(y, 1);%输出节点的数量
net.ffb = zeros(onum, 1);
net.ffW = (rand(onum, fvnum) - 0.5) * 2 * sqrt(6 / (onum + fvnum));
end
