# 岩石样本CT扫描的2D图像处理项目 (2D Image Processing of Rock Samples in CT)

## 项目简介
本项目包含了一系列用于处理岩石样本 CT 扫描二维图像的 ImageJ 宏脚本。主要目标是提取切片中的孔隙特征

## 文件说明
第一步：将获取的2D图片保存在一个文件夹中，使用ImageJ软件，通过路径：Plugins-Macros-Edit路径打开'Step01-Segmentation Image - Binarization.ijm',run 运行即可获得图像分割和二值化处理结果文件。需要注意的是：'Step01-Segmentation Image - Binarization.ijm'文件中关于Threshold需要自己设定最大值和最小值，同时样品的位置参数也需要自己提前测量好，输入。
* `Step01-Segmentation Image - Binarization.ijm`: 此脚本用于图像分割和二值化处理。
第二步：将图像分割和二值化处理结果图复制到新的文件夹中，运行'Step02-Sample pore invert.ijm',获得invert的结果图
* `Step02-Sample pore invert.ijm`: 此脚本用于...
第三步：将获得invert的结果图复制到新的文件夹中，运行'Step03-Pore feature extraction.ijm',获得孔隙特征的结果
* `Step03-Pore feature extraction.ijm`: 此脚本用于提取孔隙特征，例如...

## 如何使用
1.  确保您已安装 [ImageJ](https://imagej.nih.gov/ij/) 软件。
2.  打开 ImageJ。
3.  通过 `Plugins > Macros > Run...` 来依次运行本项目的脚本文件。

如果想要获得更多的孔隙特征可以自己添加相关代码即可。
