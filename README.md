## What are these codes?
This is the offical implementation of the published paper. Please cite this work:  
>D. Kodaira and K. Junji, “Probabilistic Forecasting Model for Non-normally Distributed EV Charging Demand,” in 2020 International Conference on Smart Grids and Energy Systems (SGES 2020), 2020, [https://doi.org/10.1109/SGES51519.2020.00116](https://doi.org/10.1109/SGES51519.2020.00116).

### Abstract
A method for probabilistic electric vehicle (EV) demand forecasting is proposed in this paper. The EV demand in a certain area is forecasted by an ensemble forecasting model. The forecast result includes a deterministic forecasting and prediction interval that indicates the probability of deviation from deterministic forecasting. In the case study, an actual observed dataset from the UK is used to verify the proposed algorithm. The results show that the target EV charging demand to be forecasted shows 80% prediction interval coverage for 27 days out of 30 simulated days.

## Required packages
Matlab 2020b  

## About the author
- [Daisuke Kodaira](https://scholar.google.com/citations?user=dK5dNcoAAAAJ&hl=en), daisuke.kodaira03 AT gmail.com
- [Junji Kondoh](https://www.rs.tus.ac.jp/j.kondoh/english.html)

## Structure of the code
1. Train the ML model with past data  
setEVModel/main.m  
-> This model is under modification, so it doesn't work as it is.  

2. Get the prediction for the test data  
getEVModel/main_MultipleDayForecast.m  
-> you can get some results from this code.  
