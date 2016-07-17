###Development of iOS App for Exam Preparation###

This repo houses my TFG, Trabajo Fin de Grado, the Spanish version of a bachelors thesis. My tutor is Luis R. Izquierdo Millán. 


The application is capable of loading topic specific question catalogues from the cloud and presents them in an organized and easy to navigate manner to the user. Questions can incorporate hints and feedback to facilitate the learning process. Statistics show the users their current progress which is saved to the cloud and synchronizes seamlessly between multiple devices.
The application is functional when not connected to the internet and is localized to English, Spanish and German. When it has access to the internet, it supports a multi-user environment and the cloud synchronization makes it possible to work on multiple devices while always having access to the latest data.
The application was developed in Xcode using Swift, a programming language that was only recently released. It was designed following Apple’s Human Interface Guidelines to ensure ideal compatibility with the latest versions of iOS and to make it feel instantly familiar to new users. Furthermore, an onboarding process helps to explain the application’s key functionality when it is opened for the first time.
Several frameworks and libraries such as Realm, Parse and Onboard were used during development. The question catalogues are created in the CSV format and uploaded through a separate app called Uploader. The data is saved in a data base using MongoDB, hosted by Heroku and can be managed through the Parse interface.


![Statistics view](/Screenshots/Poster.jpeg?raw=true)

Available und GNU GPLv3
#### Who do I talk to? ####

* Repo owner and admin: Johannes Berger