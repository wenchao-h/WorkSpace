# -*- coding: utf-8 -*-
import scipy.io as sio
from FBCSPTrain import CSPTrain
from FBCSPSpatialFilter import CSPSpatialFilter
trainx = sio.loadmat(r'D:\Myfiles\WorkSpace\Codes\PythonProjects\Data\trainx.mat')
trainy = sio.loadmat(r'D:\Myfiles\WorkSpace\Codes\PythonProjects\Data\trainy.mat')
train_x = trainx['train_x']  # shape(750,22,60)
train_y = trainy['train_y']  # shape(1,60)
m = 3
csp_ProjMatrix = CSPTrain(train_x, train_y.ravel(), m)
xAfterCSP = CSPSpatialFilter(train_x, csp_ProjMatrix)
print xAfterCSP.shape()