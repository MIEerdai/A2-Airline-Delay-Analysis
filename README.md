# ✈️ Airline On-Time Performance Analysis (2004) 

## 📌 Project Overview | 项目概述

This project analyzes the **Airline On-Time Performance** dataset for the year **2004**, sourced from [Kaggle](https://tinyurl.com/u8rzvdsx). 
This project aims to analyze airline on-time performance and cancellations, identifying underperforming routes, carriers, and flight numbers, and investigating the key reasons behind delays and cancellations. Using the 2004 US domestic flight data, we aim to provide insights for optimizing airline operations and assisting traveler decisions.
The project focuses on the following core questions: 

1.  Delay patterns by time of day, day of the week, and season;
2.  Top contributing factors to flight delays and their quantitative impact;
3.  Analysis of flight cancellation reasons and trends;
4.  Identification and diagnosis of consistently problematic flights, routes, or carriers.

Data was processed using Hive to clean and aggregate large-scale datasets. The resulting summaries were exported as CSV files, and visualizations were created in Jupyter Notebook using Python libraries such as pandas, matplotlib, and seaborn.




本项目使用来自 [Kaggle](https://tinyurl.com/u8rzvdsx) 的“航班准点表现”数据集旨在分析航空公司航班准点率与取消情况，识别航线、航空公司、航班号等维度下的表现不佳者，并探索延误和取消的主要原因。通过分析2004年美国航空运输数据，我们希望为航空运营优化和乘客出行决策提供有价值的参考。

项目内容涵盖以下几个核心问题：

1.  不同时间段、星期几、月份的延误模式；

2.  导致航班延误的主要因素及其影响程度；

3.  航班取消的原因分析；

4.  表现最差的航线、承运人和航班号，并对问题航班进行深入探讨。

数据处理部分使用 Hive 对大规模原始数据进行清洗与聚合，最终结果导出为 CSV 文件；可视化分析部分在 Jupyter Notebook 中利用 Python 的 pandas、matplotlib 和 seaborn 库完成。

---

## 📂 Dataset Description | 数据集说明

- **Year | 年份**: 2004  
- **Source | 来源**: U.S. Department of Transportation  
- **Fields | 字段**: Flight date/time, carrier, origin/destination, delay/cancellation reasons, etc.  
  航班日期/时间、航空公司、起点/终点、延误/取消原因等

---

## 🔍 Visualizations  & Analysis 

### 1. Delay Patterns | 延误模式分析
- ⏰ Which time of day has the lowest average delays?  
  哪个时段（早/中/晚）平均延误最少？
图Flight Volume and Average Delay by Time of Day

  该图展示了2004年一天中不同时段（早晨、下午、晚上）的航班总量和平均延误时间。蓝色柱状图表示航班总量，绿色线表示平均起飞延误（分钟），红色线表示平均到达延误（分钟）。如图所示早上的航班总量最大，且平均的延误时间最低；晚上的航班量最小但是平均的延误时间最高。

  总而言之，在所采用的2004年数据集中体现出来的是：早晨时段的平均延误时间最少，相较于下午和晚上。这可能归因于多个因素。早晨是航班起降的高峰时段，尽管航班数量多，但航空公司可能在早晨安排了更充足的资源和更紧凑的调度，以确保航班按时起飞。而晚上由于一天的累积效应，前面航班的延误可能会对后续航班产生连锁反应，导致晚上航班的延误时间更长。


  
- 📅 Which weekdays have better on-time performance?  
  星期几的航班更准时？
  图On-Time Rate by Day of Week

  该柱状图展示了2004年每周各天的航班准点率。横轴表示一周中的天数（1到7，1代表周一），纵轴表示准点率（0到1）。如图所示周一、周四、周五和周七的准点率较低（0.62-0.64），剩下的准点率相对较高（0.68-0.69），但实际上差别不是很大。
  
   工作周的中间几天通常航班流量较低，航空公司可能更容易管理调度和维护，从而保持较高的准点率。相比之下，周末和周五由于商务旅行和休闲旅行的增加，航班流量较大，增加了延误的可能性。
  



  
- 🗓️ Which months are most punctual?  
  哪些月份航班更准时？
 图On-Time Rate by Month

  该折线图展示了2004年每个月的航班准点率。横轴表示月份（1到12月），纵轴则表示准点率（0到1）。从图中可以看到，准点率在9月达到最高点（74%），而12月的准点率最低（56%）。
  航班在9月以及冬季的1月和2月最有可能准点。9月天气稳定，旅游需求较低，航空公司能够高效运营，准点率达到了全年的最高点0.74。相比之下，12月由于年末假期，旅游需求激增，航班流量大幅增加，导致机场拥堵和运营压力增大，准点率降至全年最低的0.568。此外，12月的冬季天气状况（如暴风雪和结冰）也给航班运营带来了挑战.
  

  




  

### 2. Delay Factors | 延误因素分析
- 🔝  Delay Factors  
  延误因素
 图表2：Proportion of Delay Factors

该饼图展示了2004年美国航班延误的主要因素及其占总延误时间的百分比.

图表1：Total Delay Minutes by Factor

该柱状图展示了2004年美国航班延误的主要因素及其总延误时间（以分钟为单位）。横轴表示总延误时间，纵轴表示延误类型。


   结合图1和图2可知，飞机晚到和国家空管系统问题是导致航班延误的主要因素，两者合计占总延误时间的约67.1%。这表明航空系统内部的协调和管理问题对航班准点率有着显著影响。航空公司原因占总延误时间的约25.8%，这可能与航空公司的运营效率、飞机维护、机组人员调度等因素有关。天气原因占总延误时间的约6.9%，虽然比例相对较小，但在实际运营中仍然是一个不可忽视的因素，尤其是在恶劣天气频发的季节或地区。安全原因占总延误时间的约0.2%，表明安全检查和相关程序对航班延误的影响极小。



### 3. Cancellation Analysis | 取消航班分析
- 🛑 Primary cancellation reasons  
  主要取消原因分类

  
- 🧭 Are cancellations tied to airlines/airports/times?  
  取消是否与航空公司、机场或时间段有关？

  

### 4. Problematic Routes | 问题航线分析
- 📉 Identify poorly performing routes/carriers/flights  
  表现差的航线、航空公司或航班编号

  
- 🔍 Analyze underlying issues  
  分析这些航班延误或取消的原因

  

---

## 🧪 Tools & Technologies | 使用工具

- **Data Querying | 数据查询**: Apache Hive 
- **Data Analysis & Visualization | 数据分析与可视化**: Python (Pandas, Matplotlib, Seaborn) 
- **IDE**: Jupyter Notebook  


---

## 📈 Tips 

> 🖼️ Insert chart previews or links here  
> 📊 此处插入你生成的图表或其预览/链接

---

## 🗃️ Folder Structure | 项目目录结构

