
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Build
Status](https://travis-ci.org/JohannesFriedrich/HypeRIMU.svg?branch=master)](https://travis-ci.org/JohannesFriedrich/HypeRIMU)
[![Build
status](https://ci.appveyor.com/api/projects/status/lm7jn3t558yxveve?svg=true)](https://ci.appveyor.com/project/JohannesFriedrich/hyperimu)
[![Coverage
Status](https://codecov.io/gh/JohannesFriedrich/HypeRIMU/branch/master/graph/badge.svg)](https://codecov.io/gh/JohannesFriedrich/HypeRIMU)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)

HypeRIMU is an **R**-package for reading sensor data from the Android
app
[HyperIMU](https://play.google.com/store/apps/details?id=com.ianovir.hyper_imu).
Supported are transfers via TCP and File in version v.3.0.4.4.

# Installation

``` r
if(!require("devtools"))
  install.packages("devtools")
devtools::install_github("JohannesFriedrich/HypeRIMU")
```

# Motivation

Modern smartphones include a lot of sensors, e.g. for gravity or linear
acceleration. Some apps provide the data collected from these sensors.
One famous android app is “HyperIMU” (IMU: Inertial measurement unit).
There are other apps available, but HyperIMU has some advantages:

  - Choose which sensor data should be collected
  - Choose different streaming protocols: SD-card (locally on the
    smarphone), UDP, or TCP
  - The sampling rate can be adjusted

The **R**-package HypeRIMU provides some handy functions to visualise
sensor data. Different streaming protocolls are supported (a local .csv
file and TCP).

# Usage

For using the smartphone app, see
[HIMUServer](https://github.com/ianovir/HIMUServer/) and [HyperIMU
Android](https://play.google.com/store/apps/details?id=com.ianovir.hyper_imu&hl=de)
and install the app on your smartphone.

### Read sensor data

Until now two different methods to read the sensor data are supported:
TCP and a local file.

#### TCP

The TCP protocol is also supported. Using this method needs to know your
IP address to sumbit in the smartphone app, see
[HIMUServer](https://github.com/ianovir/HIMUServer/). It´s recommended
to submit the names of the sensors, see setting in the Android app
HyperIMU.

``` r
data <- execute_TCP(port = 5555)
```

#### JSON

Also JSON is supported viaTCP protocol is. The usage is very smilar to
TCP but the submitted data packages look different, see
[HyperIMU](ttps://ianovir.com/works/mobile/hyperimu/) homepage.
Nevertheless, the returned object is a data.frame. Using the argument
`return_JSON = true` will return the JSON object for further analysis.

``` r
data <- execute_JSON(port = 5555)

data <- execute_JSON(port = 5555, return_JSON = TRUE)
```

#### File

The recommended way to read the data is to save the records on your
smartphone and submit them locally to your PC as a .csv file. The
advantage from this method is the appropriation of sensor names.

The following code shows an example of using a local file. The file can
be imported via the function `execute_file()`. If your data provide a
`timestamp`, choose `TRUE` for the argument `timestamp`. The functions
tries to guess if a timestamp is available even when you set the
`timestamp` argument wrong.

When a timestamp is available in the file, the function changes the UNIX
format to as POSIXct format.

``` r
library(magrittr)

data <- system.file('extdata', 'short_y_impulse.csv', package = 'HypeRIMU') %>% 
  execute_file()
## 
## [execute_file()]: Timestamp detected. Used first coloumn as timestamp.
```

### Analyse sensor data

HypeRIMU provides a function to extract some specific sensor data, see
next code. When a sumbitted `sensorName` is not available in the `data`,
an error message is
printed.

``` r
MPL_Accelerometer <- get_specificSensor(data, sensorName = "MPL_Accelerometer")

MPL_Linear_Acceleration <- get_specificSensor(data, sensorName = "MPL_Linear_Acceleration")
```

### Plot sensor data

Visulasing the data is one of the main advantages of this **R**-package.
With some extra libraries a nice plot can be created in just a few
lines. NOTE: It is recommended to use data with a timestamp.

``` r
library(ggplot2)
library(reshape2)
library(scales)

melt(MPL_Linear_Acceleration, id.vars = "Timestamp", variable.name = "Sensor") %>% 

ggplot(aes(x = Timestamp, y = value, color = Sensor)) + 
  geom_line() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
  scale_x_datetime(labels = date_format("%H:%M:%S", tz = Sys.timezone()))
```

<img src="README_figs/README-plot_sensor_data_1-1.png" width="672" style="display: block; margin: auto;" />

``` r
MPL_Accelerometer_melt <- melt(MPL_Accelerometer, id.vars = "Timestamp", variable.name = "Sensor") %>% 

ggplot(aes(x = Timestamp, y = value, color = Sensor)) + 
  geom_line() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
  scale_x_datetime(labels = date_format("%H:%M:%S", tz = Sys.timezone()))  
```

# Related projects

  - [HIMUServer](https://github.com/ianovir/HIMUServer/)
  - [HyperIMU
    Android](https://play.google.com/store/apps/details?id=com.ianovir.hyper_imu)
  - [Android
    API](https://developer.android.com/guide/topics/sensors/index.html)

# To Do

  - support UDP stream
  - make examples
  - write function to get IP adress of server

# License

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or any later
version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
