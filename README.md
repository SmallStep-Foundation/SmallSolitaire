# SmallSolitaire

Klondike solitaire for GNUstep. Uses [SmallStepLib](../SmallStepLib) for app lifecycle, menus, window style, and About panel.

## Build

1. Build and install SmallStepLib:
   ```bash
   cd ../SmallStepLib && make && sudo make install
   ```
   Or build only (link from `SmallSolitaire.app` to the framework in SmallStepLib):
   ```bash
   cd ../SmallStepLib && make
   ```

2. Build SmallSolitaire:
   ```bash
   cd SmallSolitaire && make
   ```

## Run

```bash
openapp ./SmallSolitaire.app/SmallSolitaire
```

Or from an environment where GNUstep is set up:
```bash
./SmallSolitaire.app/SmallSolitaire
```

## Features

- **Klondike rules**: 7 tableau columns, 4 foundations, stock and waste.
- **Draw one**: Click the stock to draw one card to the waste; when the stock is empty, waste is recycled.
- **Drag & drop**: Drag from waste, tableau, or foundation to a valid tableau column or foundation.
- **Double-click**: Double-click the top card of the waste or a tableau column to try moving it to a foundation.
- **New game**: Menu → New Game or Cmd+N.

## SmallStepLib usage

- **SSHostApplication** + **SSAppDelegate**: App entry via `[SSHostApplication runWithDelegate:]`; lifecycle in `AppDelegate` (`applicationDidFinishLaunching`, `applicationShouldTerminateAfterLastWindowClosed:`).
- **SSMainMenu**: App menu with New Game and Quit.
- **SSAboutPanel**: About menu item and panel (logo.png from bundle).
- **SSWindowStyle**: Standard window mask for the game window.
