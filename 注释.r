---
title: "文献复现"
author: "max"
date: now
output: html_document
---

# 分组数据分析实战

在这一部分，将以论文中的数据分析为例，展示分组数据分析和可视化的重复性研究。首先，我们简单介绍一下论文的研究背景、方法和主要结果。然后，使用原始数据进行可重复研究，通过复现论文中的图片，展示分组数据分析和可视化的重复性研究。

## 论文研究概述

## 数据准备

论文的原始数据及分析代码都在 [GitHub](https://github.com/daniosro/Si_biomineralization_ANME_SRB.git) 上。首先，使用 Git 命令将代码克隆到本地：

```bash
git clone https://github.com/daniosro/Si_biomineralization_ANME_SRB.git --depth 1

#| label: packages 
library(readxl)       # 用于读取Excel文件
library(tidyverse)    # 包含ggplot2、dplyr等数据科学工具包

# 设置默认主题为黑白主题
theme_set(theme_bw())

# 读取数据集S3.xlsx文件，包含(Mg+Al+Fe)/Si比值数据
# 数据包括无沉积物的ANME-SRB联合体、沉积物中的ANME-SRB联合体以及不含ANME-SRB联合体的沉积物
file = xfun::magic_path("Dataset S3.xlsx")  # 自动查找文件路径
octtet_data <- read_excel(file)  # 读取Excel文件

octtet_data  # 显示数据

# 按类别筛选数据
# 1. 从Jaco Scar获取的沉积物和ANME-SRB联合体附着的硅酸盐
octtet_data_Jaco <- octtet_data |> 
  filter(Basin == "Jaco Scar") |>  # 筛选Jaco Scar盆地的数据
  select(mg_al_fe_to_si, Source, Basin, source_order, basin_order) |>  # 选择特定列
  mutate(Source = as_factor(Source))  # 将Source列转换为因子

# 2. 从Santa Monica盆地获取的沉积物和ANME-SRB联合体附着的硅酸盐
octtet_data_SMB <- subset(octtet_data, Basin == "Santa Monica", 
                         select = c("mg_al_fe_to_si","Source","Basin","source_order","basin_order"))

# 3. 从Santa Monica盆地培养实验中无沉积物的ANME-SRB联合体附着的富含硅相
octtet_data_SMB_sedfree <- subset(octtet_data_SMB,
                                 Source == "Aggregate-attached, Sediment-free" | Source == "Sediment", 
                                 select = c("mg_al_fe_to_si","Source","Basin","source_order","basin_order"))

# 4. Santa Monica盆地沉积物中ANME-SRB联合体附着的硅酸盐
octtet_data_SMB_fromsed <- subset(octtet_data_SMB,
                                 Source == "Aggregate-attached" | Source == "Sediment", 
                                 select = c("mg_al_fe_to_si","Source","Basin","source_order","basin_order"))

# 5. Santa Monica盆地沉积物中ANME-SRB联合体附着的硅酸盐与培养实验中无沉积物的ANME-SRB联合体附着的富含硅相
octtet_data_SMB_freevsfromsed<- subset(octtet_data_SMB,
                                      Source == "Aggregate-attached" | Source == "Aggregate-attached, Sediment-free", 
                                      select = c("mg_al_fe_to_si","Source","Basin","source_order","basin_order"))

# 6. Eel River盆地的沉积物和ANME-SRB联合体附着的硅酸盐
octtet_data_ERB <- subset(octtet_data, Basin == "Eel River", 
                          select = c("mg_al_fe_to_si","Source","Basin","source_order","basin_order"))

# 对Jaco Scar沉积物和ANME-SRB联合体附着的硅酸盐进行单因素方差分析
summary(octtet_data_Jaco)  # 显示数据摘要
resot1.aov <- aov(mg_al_fe_to_si ~ Source, data = octtet_data_Jaco)  # 执行ANOVA
summary(resot1.aov)  # 显示ANOVA结果

# 对Santa Monica盆地培养实验中无沉积物的ANME-SRB联合体附着的富含硅相进行单因素方差分析
resot2.aov <- aov(mg_al_fe_to_si ~ Source, data = octtet_data_SMB_sedfree)
summary(resot2.aov)

# 对Santa Monica盆地沉积物中ANME-SRB联合体附着的硅酸盐进行单因素方差分析
resot3.aov <- aov(mg_al_fe_to_si ~ Source, data = octtet_data_SMB_fromsed)
summary(resot3.aov)

# 对Santa Monica盆地沉积物中ANME-SRB联合体附着的硅酸盐与培养实验中无沉积物的ANME-SRB联合体附着的富含硅相进行单因素方差分析
resot4.aov <- aov(mg_al_fe_to_si ~ Source, data = octtet_data_SMB_freevsfromsed)
summary(resot4.aov)

# 对Eel River盆地的沉积物和ANME-SRB联合体附着的硅酸盐进行单因素方差分析
resot5.aov <- aov(mg_al_fe_to_si ~ Source, data = octtet_data_ERB)
summary(resot5.aov)

library(ggpubr)  # 加载ggpubr包用于统计可视化

# 重新组织数据
octtet_data$new_source_order <- reorder(octtet_data$Source, octtet_data$source_order)  # 按source_order重新排序Source
octtet_data$new_basin_order <- reorder(octtet_data$Basin, octtet_data$basin_order)  # 按basin_order重新排序Basin

# 创建小提琴图
ot = ggplot(octtet_data, aes(new_source_order, mg_al_fe_to_si))  # 设置基础图形

ot + 
  geom_violin() +  # 添加小提琴图
  geom_boxplot(width=0.2, outliers = FALSE) +  # 添加窄箱线图，不显示异常值
  stat_compare_means(method = "aov", label = "p", size = 3) +  # 添加ANOVA p值
  stat_compare_means(method = 't.test', label.y = 2,
                     ref.group = "Sediment", label = "p.signif") +  # 添加与Sediment组的t检验显著性标记
  facet_grid(~new_basin_order, scales = "free", space = "free") +  # 按盆地分面，自由调整比例和空间
  theme(axis.text.x = element_text(angle = 30, hjust = 1, vjust = 1)) +  # 调整x轴标签角度
  labs(x = "", y = "(Mg+Al+Fe)/Si")  # 设置轴标签

# 读取数据集S2.xlsx文件，包含Al/Si比值数据
AlSi_data <- read_excel(xfun::magic_path('Dataset S2.xlsx'))
AlSi_data

# 按类别筛选数据
# 1. Jaco Scar的沉积物和ANME-SRB联合体附着的硅酸盐
AlSi_data_Jaco <- subset(AlSi_data, Basin == "Jaco Scar", 
                        select = c("Al.per.Si","Source","Basin","Source order","Basin order"))
# 2. Santa Monica盆地的沉积物和ANME-SRB联合体附着的硅酸盐
AlSi_data_SMB <- subset(AlSi_data, Basin == "Santa Monica", 
                        select = c("Al.per.Si","Source","Basin","Source order","Basin order"))
# 3. Santa Monica盆地培养实验中无沉积物的ANME-SRB联合体附着的富含硅相
AlSi_data_SMB_sedfree <- subset(AlSi_data_SMB,
                               Source == "Aggregate-attached, Sediment-free" | Source == "Sediment", 
                               select = c("Al.per.Si","Source","Basin","Source order","Basin order"))
# 4. Santa Monica盆地沉积物中ANME-SRB联合体附着的硅酸盐
AlSi_data_SMB_fromsed <- subset(AlSi_data_SMB,
                               Source == "Aggregate-attached" | Source == "Sediment", 
                               select = c("Al.per.Si","Source","Basin","Source order","Basin order"))
# 5. Santa Monica盆地沉积物中ANME-SRB联合体附着的硅酸盐与培养实验中无沉积物的ANME-SRB联合体附着的富含硅相
AlSi_data_SMB_freevsfromsed<- subset(AlSi_data_SMB,
                                    Source == "Aggregate-attached" | Source == "Aggregate-attached, Sediment-free", 
                                    select = c("Al.per.Si","Source","Basin","Source order","Basin order"))
# 6. Eel River盆地的沉积物和ANME-SRB联合体附着的硅酸盐
AlSi_data_ERB <- subset(AlSi_data, Basin == "Eel River", 
                        select = c("Al.per.Si","Source","Basin","Source order","Basin order"))
# 设置因子顺序
source_order = c("Sediment", "Aggregate-attached","Aggregate-attached, Sediment-free")
basin_order = c("Eel River", "Jaco Scar", "Santa Monica")
AlSi_data = AlSi_data |> 
  mutate(Source = factor(Source, levels = source_order),  # 按指定顺序设置Source因子
         Basin = factor(Basin, levels = basin_order))  # 按指定顺序设置Basin因子

# 创建Al/Si比值的小提琴图
ot = ggplot(AlSi_data, aes(Source, Al.per.Si))  # 设置基础图形

ot + 
  geom_violin() +  # 添加小提琴图
  geom_boxplot(width=0.2, outliers = FALSE) +  # 添加窄箱线图，不显示异常值
  stat_compare_means(method = "aov", label = "p", size = 3) +  # 添加ANOVA p值
  stat_compare_means(method = 't.test', label.y = 1,
                     ref.group = "Sediment", label = "p.signif") +  # 添加与Sediment组的t检验显著性标记
  facet_grid(~Basin, scales = "free", space = "free") +  # 按盆地分面，自由调整比例和空间
  theme(axis.text.x = element_text(angle = 30, hjust = 1, vjust = 1)) +  # 调整x轴标签角度
  labs(x = "", y = "(Al per Si")  # 设置轴标签

 # 对Jaco Scar沉积物和ANME-SRB联合体附着的硅酸盐进行单因素方差分析(Al/Si比值)
resot6.aov <- aov(Al.per.Si ~ Source, data = AlSi_data_Jaco)
summary(resot6.aov)

# 对Santa Monica盆地培养实验中无沉积物的ANME-SRB联合体附着的富含硅相进行单因素方差分析(Al/Si比值)
resot7.aov <- aov(Al.per.Si ~ Source, data = AlSi_data_SMB_sedfree)
summary(resot7.aov)

# 对Santa Monica盆地沉积物中ANME-SRB联合体附着的硅酸盐进行单因素方差分析(Al/Si比值)
resot8.aov <- aov(Al.per.Si ~ Source, data = AlSi_data_SMB_fromsed)
summary(resot8.aov)

# 对Santa Monica盆地沉积物中ANME-SRB联合体附着的硅酸盐与培养实验中无沉积物的ANME-SRB联合体附着的富含硅相进行单因素方差分析(Al/Si比值)
resot9.aov <- aov(Al.per.Si ~ Source, data = AlSi_data_SMB_freevsfromsed)
summary(resot9.aov)

# 对Eel River盆地的沉积物和ANME-SRB联合体附着的硅酸盐进行单因素方差分析(Al/Si比值)
resot10.aov <- aov(Al.per.Si ~ Source, data = AlSi_data_ERB)
summary(resot10.aov)