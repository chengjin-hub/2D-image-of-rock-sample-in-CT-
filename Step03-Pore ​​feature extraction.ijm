// -------- 设置处理文件类型 --------
inputDir = getDirectory("Choose a Folder");   // 用户选择一个文件夹
fileList = getFileList(inputDir);             // 获取文件夹下的所有文件

// -------- 遍历所有图像文件 --------
for (i = 0; i < fileList.length; i++) {
    filename = fileList[i];
    if (endsWith(filename, ".tif") || endsWith(filename, ".png") || endsWith(filename, ".jpg")) {
        
        // -------- 打开图像并运行分析 --------
        open(inputDir + filename);
        run("8-bit");
        setThreshold(0, 0);
        setOption("BlackBackground", true);
        run("Analyze Particles...", "size=10-Infinity show=Overlay display summarize");

        // -------- 设置输出路径 --------
        dotIndex = indexOf(filename, ".");
        baseName = substring(filename, 0, dotIndex);

        summaryPath = inputDir + baseName + "_Summary.csv";
        detailsPath = inputDir + baseName + "_Results.csv";
        imagePath   = inputDir + baseName + "_Overlay.png";
        connectivityPath = inputDir + baseName + "_Connectivity.csv";
        fractalPath = inputDir + baseName + "_FractalPlot.png";

        // -------- 导出 Summary 表 --------
        selectWindow("Summary");
        saveAs("Results", summaryPath);
        close("Summary");

        // -------- 导出 Results 表 --------
        selectWindow("Results");
        saveAs("Results", detailsPath);
        close("Results");

        // -------- 保存叠加图像 --------
        selectWindow(filename);
        run("Flatten");
        saveAs("PNG", imagePath);
        close();

        // -------- 连通性分析 --------
        open(inputDir + filename);
        run("8-bit");
        setThreshold(0, 0);
        setOption("BlackBackground", true);
        run("Analyze Particles...", "size=10-Infinity display summarize");

        selectWindow("Summary");
        connectivityCount = getResult("Count", 0);
        connectivityArea = getResult("Total Area", 0);
        close("Summary");

        // 保存连通性结果
        File.saveString("Count,Total_Area\n" + connectivityCount + "," + connectivityArea + "\n", connectivityPath);

        // -------- 分形维数分析 --------
        open(inputDir + filename);
        run("8-bit");
        setThreshold(0, 0);
        setOption("BlackBackground", true);
        run("Convert to Mask");
        run("Invert");

        run("Fractal Box Count...");
        waitForUser("图像 " + filename + "：记录 Fractal Dimension 后点击 OK");

// 保存 Fractal 图像
fractalImagePath = inputDir + baseName + "_FractalPlot.png";
saveAs("PNG", fractalImagePath);
close("Fractal Box Count");


        print("✅ 完成文件：" + filename);
    }
}

// -------- 所有完成 --------
print("🎉 批量分析完成！");
