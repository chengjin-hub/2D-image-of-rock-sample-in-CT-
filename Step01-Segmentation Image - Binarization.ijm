// ==== 参数设置 ==== //
inputDir = getDirectory("Choose a folder with CT slices");
outputFile = inputDir + "Pore_Analysis_Results.csv";
thresholdMin = 115;
thresholdMax = 255;
minPoreSize = 10;
connectivity = 8;
useFixedROI = true;
roiRect = newArray(298, 304, 1007, 1007); // 替换为你的样品 ROI（单位：像素）

// ==== mean 计算函数定义 ==== //
function mean(arr) {
    sum = 0;
    for (i = 0; i < arr.length; i++) sum += arr[i];
    return sum / arr.length;
}

// ==== 文件初始化 ==== //
File.delete(outputFile);
header = "Filename,Porosity,Pore_Count,Mean_Area(mm2),Mean_Diameter(mm),Mean_Circularity,Mean_AR,Mean_Solidity,Max_Feret(mm),Min_Feret(mm),Skeleton_Length(mm),Branches,Endpoints,Open_Pores,Closed_Pores,Mean_Throat_Width(mm)\n";
File.append(header, outputFile);

// ==== 处理所有图像 ==== //
list = getFileList(inputDir);
setBatchMode(true);

for (i = 0; i < list.length; i++) {
    if (endsWith(list[i], ".tif") || endsWith(list[i], ".png") || endsWith(list[i], ".jpg")) {
        filePath = inputDir + list[i];
        dotIndex = indexOf(list[i], ".");
        fileName = substring(list[i], 0, dotIndex);

        open(filePath);
        rename(fileName);
        run("8-bit");
        run("Set Scale...", "distance=1 known=0.2646 unit=mm pixel=1 global");

        if (useFixedROI) {
            makeRectangle(roiRect[0], roiRect[1], roiRect[2], roiRect[3]);
            run("Crop");
        }

        setThreshold(thresholdMin, thresholdMax);
        run("Convert to Mask");
        run("Invert");

        // 保存掩码图
        saveAs("Tiff", inputDir + fileName + "_mask.tif");

        run("Analyze Particles...", "size=" + minPoreSize + "-Infinity clear add");

        roiManager("Select All");
        run("Measure");
        totalArea = getResult("Area", 0);
        poreArea = 0;
        for (r = 0; r < nResults; r++) poreArea += getResult("Area", r);
        porosity = poreArea / totalArea;

        run("Set Measurements...", "area perimeter feret's shape redirect=None decimal=3");
        roiManager("Measure");

        n = nResults;
        areaCol = newArray(n);
        circCol = newArray(n);
        arCol = newArray(n);
        feretCol = newArray(n);
        minFeretCol = newArray(n);

        for (j = 0; j < n; j++) {
            areaCol[j] = getResult("Area", j);
            circCol[j] = getResult("Circ.", j);
            arCol[j] = getResult("AR", j);
            feretCol[j] = getResult("Feret", j);
            minFeretCol[j] = getResult("MinFeret", j);
        }

        meanArea     = mean(areaCol);
        meanCirc     = mean(circCol);
        meanAR       = mean(arCol);
        maxFeret     = mean(feretCol);
        minFeret     = mean(minFeretCol);
        poreCount    = n;

        run("Analyze Regions", "connectivity=" + connectivity);
        nSolid = nResults;
        solidities = newArray(nSolid);
        for (k = 0; k < nSolid; k++) {
            solidities[k] = getResult("Solidity", k);
        }
        meanSolidity = mean(solidities);
        close("Region Analysis");

        run("Duplicate...", "title=Mask");
        selectWindow("Mask");
        run("Skeletonize");

        // 保存骨架图
        saveAs("Tiff", inputDir + fileName + "_skeleton.tif");

        run("Analyze Skeleton (2D/3D)", "prune=none calculate");
        selectWindow("Results");
        skelLen = getResult("Skeleton length", 0);
        branches = getResult("Branches", 0);
        endpoints = getResult("Endpoints", 0);
        close("Results");
        close("Mask");

        openPores = 0;
        closedPores = 0;
        roiManager("Select All");
        for (r = 0; r < roiManager("count"); r++) {
            roiManager("Select", r);
            getBoundingRect(x, y, w, h);
            if (x <= 1 || y <= 1 || (x + w) >= getWidth() - 1 || (y + h) >= getHeight() - 1) {
                openPores++;
            } else {
                closedPores++;
            }
        }

        run("Duplicate...", "title=For_DistMap");
        selectWindow("For_DistMap");
        run("Convert to Mask");
        run("Distance Map", "pixels");
        getStatistics(area, meanVal, min, max, stdDev);
        meanThroatWidth = 2 * meanVal * 0.2646;
        close();

        meanDiameter = 2 * sqrt(meanArea / PI);
        line = list[i] + "," + porosity + "," + poreCount + "," + meanArea + "," + meanDiameter + "," +
               meanCirc + "," + meanAR + "," + meanSolidity + "," + maxFeret + "," + minFeret + "," +
               skelLen + "," + branches + "," + endpoints + "," + openPores + "," + closedPores + "," +
               meanThroatWidth + "\n";
        File.append(line, outputFile);

        roiManager("Reset");
        close("*");
    }
}

setBatchMode(false);
print("分析完成！结果保存在: " + outputFile);
