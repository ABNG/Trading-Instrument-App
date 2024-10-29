# Trading Instruments Real-Time Price Ticker Application

> **Note:** Due to limitations of the free-tier Finnhub API, only one app can listen to the WebSocket data per account at a time. If multiple apps are running simultaneously, only one app will receive real-time data.

### Overview

This Flutter application displays a list of trading instruments symbols along with a real-time price updates. It consumes data from the [Finnhub API](https://finnhub.io) to display live price updates.

### Features

* **Real-Time Price Updates**: Displays live price updates for each trading instrument symbol.
* **Visual Indicators**: Colors and fade animations indicate price increases, decreases, or stability.
* **Search Functionality**: Allows users to search the specific instruments by symbol.
* **Socket Reconnect Handling**: Automatically resubscribes symbols on WebSocket reconnection.
* **Error Handling**: Manages network issues and API errors gracefully.
* **High Performance**: Optimized to subscribe only to currently visible symbols on screen, minimizing data usage and processing.
* **Unit Testing**: Includes tests for API-related business logic to ensure stable and reliable functionality.
* **System-Based Light and Dark Theme**: app automatically adapts to the device's system theme, switching between light and dark modes based on user settings.

### Architecture

The app is designed with a modular architecture that separates the business logic, data handling, and UI components for better scalability and maintainability.

### Design Decisions

> **Note:** Due to limitations of the free-tier Finnhub API (50 concurrent symbol subscriptions), the app unsubscribes symbols that are not currently visible on screen and subscribes to new symbols as they appear. This strategy helps avoid "too many requests" error from websockets and optimizes data usage.

1. **API Integration**:

* **Symbol Fetching**: Retrieves available trading symbols (forex and crypto) using parallel GET requests.
* **WebSocket Data Streaming**: Receives real-time price data only for currently subscribed symbols.

2. **State Management**:

Uses `Bloc` to efficiently manage real-time updates by only updating the specific symbol price on the UI whose data updates. which allows smooth UI changes on each price updates.

3. **Data Management**:

Optimized resource loading and memory management, preventing memory leaks and enhancing performance.

4. **UI/UX**:

Designed with a minimalist UI to prioritize functionality and highlight price updates.

### Setup and Installation

1. **Clone the Repository**:
```bash
   git clone https://github.com/your-repo/trading-instruments-ticker.git
   cd trading-instruments-ticker
```

2. **Install Dependencies**:

```bash
   flutter clean && flutter pub get
```

3. **Run the App**:

```bash
   flutter run
```

### Testing

The application includes:

**Unit Tests**: Tests business logic, focusing on API responses and error handling.

**Run Tests**:
```bash
flutter test
```

### Limitations and Future Improvements
* **API Limitations**: The free-tier Finnhub API limits concurrent WebSocket connections and symbol subscriptions. For extended functionality or higher limits, consider upgrading to a paid API plan.
* **Future Enhancements**: Features such as additional instrument details, stream transform and improved data caching could further optimize performance.
