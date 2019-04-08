#### Created By Matthew McMillian

# Description
This app is a companion app for the videogame [Apex Legends](https://www.ea.com/games/apex-legends).
The Purpose of this app is to provide players with an easy way to look-up other player stats and to get articles pertaining to the game from various gaming news sources.
The app consists of two main features:
- Search for players (PC players only for now) who play Apex Legends and view their statistics
- View recent articles regarding the game Apex Legends (currently only from [GameSpot](https://www.gamespot.com/))

# Things to Consider
Due to some of the limitations from the current endpoint(s) available (The Apex Legends developers are working to publicize the endpoints more), 
some stats are limited for certain players, and the formatting is inconsistent. Because of this, I have included some sample search queries that display more information.

# Application Testing Specifications
Tested Using:
- Dart 2.2.1 (build 2.2.1-dev.0.0 571ea80e11)
- Flutter 1.3.9-pre.17 • channel master

# Running the Application
The only dart file is **lib/main.dart**, so executing **flutter run main.dart --release** from the home directory should be all you need to run the application!

# Sample Search Queries
*These queries are **NOT** case sensitive*
- tamiyocs
- proxsv
- keisezrG
- Skadewdle

# Cool Features I wanted to add but the space limitation wouldn't allow for it :(
- More article sources
- Better UI options (Stacking Widgets)
- Account Linking

# DEMO
![Home Page](https://github.com/Tamiyo/Flutter-Create-Submission/blob/master/assets/demo/1.png){:height="270px" width="30%"}
![Search Page](https://github.com/Tamiyo/Flutter-Create-Submission/blob/master/assets/demo/2.png){:height="30%" width="30%"}
![Player Page 1](https://github.com/Tamiyo/Flutter-Create-Submission/blob/master/assets/demo/3.png){:height="30%" width="30%"}
![Player Page 2](https://github.com/Tamiyo/Flutter-Create-Submission/blob/master/assets/demo/4.png){:height="30%" width="30%"}
![Article Page](https://github.com/Tamiyo/Flutter-Create-Submission/blob/master/assets/demo/5.png){:height="30%" width="30%"}
