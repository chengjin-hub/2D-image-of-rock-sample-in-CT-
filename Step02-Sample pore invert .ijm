// ==== 参数设置 ====
inputDir = getDirectory("Choose a folder with preprocessed mask images");
outputFile = inputDir + "Pore_Analysis_Results.csv";
minPoreSize = 10;        // 面积阈值，单位为像素
pxSize = 0.2646;         // 像素大小（mm/pixel）

// ==== 辅助函数 ====
function mean(arr) {
    sum = 0;
    for (i = 0; i < arr.length; i++) sum += arr[i];
    return sum / arr.length;
}
function stddev(arr) {
    mu = mean(arr);
    sumsq = 0;
    for (i = 0; i < arr.length; i++) sumsq += pow(arr[i] - mu, 2);
    return sqrt(sumsq / arr.length);
}

// ==== 写入CSV文件表头 ====
File.saveString("File,Total_Pore_Area(px),Pore_Ratio(%)\n", outputFile);

// ==== 主循环 ====
list = getFileList(inputDir);
setBatchMode(true);

for (i = 0; i < list.length; i++) {
  if (endsWith(list[i], ".tif") || endsWith(list[i], ".png") || endsWith(list[i], ".jpg")) {
    fileName = substring(list[i], 0, lastIndexOf(list[i], "."));
    open(inputDir + list[i]);
    rename(fileName);

    // 设置比例尺
    run("Set Scale...", "distance=1 known=" + pxSize + " unit=mm global");

    // 图像预处理
    run("8-bit");
    run("Invert");  // 将孔隙设为前景（白色）

    // 保存反转图像
    saveAs("PNG", inputDir + fileName + "_inverted.png");

    close(); // 关闭图像窗口
  }
}

setBatchMode(false);

