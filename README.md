# kabukabar

> 日本語のREADMEはこちらです: [README.ja.md](README.ja.md)

A simple macOS menu bar application that displays a specific stock price from Yahoo Finance.


![A screenshot showing the stock price for 'AAPL' in the macOS menu bar. A right-click context menu is open, showing options in Japanese to set the stock symbol and quit the application.](https://user-images.githubusercontent.com/1561955/291617260-2212269a-6536-4148-8926-7876774c2057.png)


## Features

- **Live Stock Price:** Displays the price of a user-specified stock directly in the menu bar.
- **Customizable Symbol:** Supports any stock symbol from Yahoo Finance (e.g., `AAPL`, `5244.T`).
- **Quick Web Access:** Left-click the price to instantly open the stock's detailed page on Yahoo Finance.
- **Simple Configuration:** Right-click for a context menu to change the symbol or quit the app.
- **Automatic Refresh:** The stock price updates automatically every hour.

## Requirements

- macOS 14.5 or later
- An active internet connection

## Installation & Usage

1.  Download the latest `kabukabar.app.zip` from the [Releases page](https://github.com/fukunotaisuke/kabukabar/releases).
2.  Unzip the file and move `kabukabar.app` to your `/Applications` folder.
3.  Launch the application. A stock price (default: `AAPL`) will appear in your menu bar.

**Actions:**
- **Left-click:** Opens the stock's webpage on Yahoo Finance.
- **Right-click:** Opens a menu with the following options (in Japanese):
    - `銘柄を設定...` (Set Symbol): Opens a dialog to enter a new stock symbol.
    - `終了` (Quit): Closes the application.

## Data Source

This application fetches data from the public Yahoo Finance API.

```swift
// API endpoint used to fetch the stock price
let apiUrl = "https://query1.finance.yahoo.com/v8/finance/chart/" + symbol
```

## License

MIT License — see [LICENSE](LICENSE).