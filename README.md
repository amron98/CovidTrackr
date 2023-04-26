# CovidTrackr

CovidTrackr is an iOS app for visualizing global COVID-19 data from the [disease.sh](https://disease.sh) API and features animated line and bar charts, as well as a [Choropleth map](https://datavizcatalogue.com/methods/choropleth.html).

![previewed](https://user-images.githubusercontent.com/54814481/234190409-6734e9de-ee70-4baf-bfe6-cc56ad5dc2e4.png)

## Installation
### Clone Repository
Clone the CovidTrackr repository by entering the following command in your Terminal shell from a suitable location in your computer.
```
git clone https://github.com/amroncodes/CovidTrackr.git
```
You may also use Git GUIs such as GitHub Desktop to clone the repository.

## Initial Setup
### Mapbox Access Token
This app requires access to Mapbox via an access token. You may refer to this tutorial to learn
[ how to setup your private key](https://docs.mapbox.com/help/getting-started/access-tokens/). Then, open the project with XCode proceed to enter the following into the info.plist file. You may refer to this tutorial to learn[ how to add properties to the info.plist file from the project navigator](https://www.youtube.com/watch?v=tTsm-i4iJYA).

<table>
  <tr>
    <td> Key </td>
    <td> Type </td>
    <td> Value </td>
  </tr> 
  <tr>
     <td>MBXAccessToken</td>
     <td>String</td>
     <td>pk.your_private_key</td>
  </tr> 
 <table>

## Running the App
Once opened in XCode, click the ‘Run’ button to start the app. 

## Demo Of Current Version
  <p align="center">
    <img src="https://user-images.githubusercontent.com/54814481/234215006-d576d92d-2c32-4f08-8b11-4febf998a4b9.gif" alt="demo" height="812" width="375"/>
  <p>




