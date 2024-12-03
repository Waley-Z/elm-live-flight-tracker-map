# Elm Live Flight Tracker

A real-time flight tracking web app built with [Elm](https://elm-lang.org/) and [Mapbox](https://www.mapbox.com/), utilizing the [OpenSky Network API](https://openskynetwork.github.io/opensky-api/rest.html) to display live aircraft positions on an interactive map.

Live demo: [here](https://waley-z.github.io/elm-live-flight-tracker-map/)

![screenshot](README.assets/screenshot.png)

## Introduction

Elm Live Flight Tracker is a web application that visualizes live aircraft data from the OpenSky Network API on an interactive Mapbox map. It demonstrates the power of functional programming with Elm by efficiently handling real-time data updates, user interactions, and rendering complex UI components.

This project was developed by Hongxiao Zheng and Max Lan for [COSC 59: Principles of Programming Languages](https://cosc59.gitlab.io/) in Fall 2024.

## Features

- **Real-time Flight Data**: Fetches live aircraft positions every 10 seconds from the OpenSky Network API.
- **Interactive Map**: Displays aircraft positions on a Mapbox GL JS map using the `elm-mapbox` library.
- **Aircraft Details**: Click on an aircraft symbol to view detailed information.
- **Dynamic Map Styling**: Uses predefined Mapbox styles and layers to render the map and aircraft symbols.
- **Smooth Animations**: Utilizes Mapbox commands provided by the `elm-mapbox` library to provide a seamless user experience.

## Why Elm?

Elm is a purely functional programming language that compiles to JavaScript, designed for building reliable and maintainable web applications. By using Elm for this project, we benefit from:

- **No Runtime Exceptions**: Elm's compiler catches errors at compile time, ensuring a smooth user experience without crashes or unexpected behaviors.
- **Functional Paradigm**: Enables clear and concise code, making it easier to reason about complex UI logic, asynchronous data fetching, and state management.
- **Immutable Data Structures**: Simplifies handling real-time data updates without side effects, making code more predictable and easier to debug.
- **Strong Static Type System**: Provides type safety, reducing bugs and improving code quality. JSON decoding, a common source of runtime errors, is handled reliably with Elm's type system.
- **Great Performance**: Elm applications are optimized for speed and efficiency, providing a responsive user interface even when handling real-time data updates.
- **Powerful Tooling**: Elm's compiler provides helpful error messages, and the ecosystem includes tools that streamline development.

This project leverages Elm's strengths to manage:

- **Asynchronous Data Fetching**: Using Elm's `Http` module to fetch data from the OpenSky Network API.
- **JSON Decoding**: Safely parsing complex JSON data structures with Elm's `Json.Decode` module.
- **State Management**: Using Elm's `Model` and `update` architecture to manage application state in a predictable way.
- **User Interaction**: Handling events such as mouse hover and clicks on map features.
- **Integration with JavaScript Libraries**: Utilizing `elm-mapbox` to integrate Mapbox GL JS into an Elm application.

## Installation

### Prerequisites

- [Node.js](https://nodejs.org/) (version 16 or higher)
- [Elm](https://guide.elm-lang.org/install/elm.html) (version 0.19.1)
- A Mapbox access token

### Steps

1. **Clone the repository**

   ```bash
   git clone https://github.com/Waley-Z/elm-live-flight-tracker-map
   cd elm-live-flight-tracker
   ```

2. **Install npm dependencies**

   ```bash
   npm install
   ```

3. **Configure Mapbox Access Token**

   Update the Mapbox access token in your `index.html` file or wherever the token is specified in the code:

   ```html
   <script>
     elmMapbox.registerCustomElement({ token: "YOUR_MAPBOX_ACCESS_TOKEN" });
     // ...
   </script>
   ```

   Replace `YOUR_MAPBOX_ACCESS_TOKEN` with your actual Mapbox token.

4. **Build the Elm application**

   ```bash
   elm make src/Main.elm --output=main.js
   ```

5. **Open static files in a browser**

   Open the `index.html` file in your browser to view the application.

## Usage

Once the application is running, you'll see a world map displaying live aircraft positions.

- **Hover over aircraft**: See the aircraft's position displayed at the bottom left corner.
- **Click on an aircraft**: View detailed information about the flight in an info panel on the upper left corner.
- **Map Interactions**: Zoom in/out and pan around the map to explore different regions.

Notice that there is a [limitation](https://openskynetwork.github.io/opensky-api/rest.html#limitations) on the OpenSky Network API requests. The API will return 429 when the limit is reached.
