---
title: "chess-widget"
date: 2026-05-28
description: "An embeddable chess game analysis widget. PGN in, annotated replay with Stockfish 18 eval, move classification and bookmarks out. Built to scratch a chess.com itch."
tags:
  [
    "chess",
    "stockfish",
    "rails",
    "postgres",
    "web-components",
    "no-build",
    "javascript",
    "cucumber",
  ]
---

# Chess Widget

I started playing chess "seriously". Decent against bots, still pretty low aura against humans, practicing. I wanted to embed annotated games on my page. The chess.com share widget is nice but not customizable and ties you to their player. I could not find a widget that did what I wanted, so I built my own.

What I wanted from it:

- Simple. Paste PGN, get a self-contained block I can drop into any HTML page.
- Customizable via CSS. People should be able to embed it in their blog and have it match their theme.
- Real analysis: blunders, mistakes, checkmates, move-by-move eval, sound on moves.
- Jump to key moves. Bookmarks for every blunder and mistake so you skip the boring parts.
- In control. No dependency on an external service at runtime, stateless, embeddable anywhere.

Repository: [https://github.com/cb341/chess-widget](https://github.com/cb341/chess-widget)

### chess.com's widget

![The chess.com share widget. Looks fine, but no way to customize the board, no eval chart, and you are stuck on their player.](/assets/projects/chess-widget/chess_com-widget.webp)

### lichess embed

![Lichess study embed. Functional but takes you out of the page, no eval-over-time, no move classification on top.](/assets/projects/chess-widget/lichess.webp)

### ChessBase / Fritz embed

![ChessBase Fritz embed. Heavier UI, locked to their styling, not something you would drop into a personal blog post.](/assets/projects/chess-widget/embedfritz.webp)

### chess.cb341.dev widget (MINE)

![My widget. Newspaper-style board, eval-over-time chart, bookmarks panel for every blunder and mistake in the game.](/assets/projects/chess-widget/chess_cb341_dev-widget.webp)

## Architecture

Two parts, cleanly separated:

- **Widget.** A custom element `<chess-widget>`, no build step, no framework. Reads a precomputed analysis JSON payload embedded in the page and renders the board, stepper, eval chart and bookmarks. Stateless. Makes zero API calls at runtime. Does not depend on `chess.cb341.dev`. The host page brings the payload, the widget renders it.
- **Analysis.** A Rails service that takes a PGN, replays SAN to FENs, shells out to a local [Stockfish 18](https://github.com/official-stockfish/Stockfish) binary for per-position evaluation, classifies moves and emits the widget-ready JSON.

PostgreSQL is purely for bookkeeping on the analysis side. Games are keyed by a deterministic SHA-256 prefix of the PGN, so submitting the same game twice is a no-op. The widget itself has no idea Postgres exists.

The widget could eventually opt in to live calls against `chess.cb341.dev` (on-the-fly analysis from a PGN string), but that is not a dependency, it is a future enhancement.

## Hosting

- [chess.cb341.dev](https://chess.cb341.dev). Rails analysis app, hosted on [deplo.io](https://deplo.io)
- [Stockfish 18](https://github.com/official-stockfish/Stockfish) runs alongside Rails in the same container
- PostgreSQL for bookkeeping of analyzed games

## Compression

The analysis JSON for a 45-move game is not tiny. Embedding it raw in the HTML is wasteful, so the payload is gzipped, base64 encoded and dropped into a `<script type="application/x-gzip-json">`. The widget decompresses it in the browser using the built-in `DecompressionStream` API. No external libraries, works everywhere modern.

```js
async function decompressJson(base64) {
  const bytes = Uint8Array.from(atob(base64), c => c.charCodeAt(0));
  const stream = new Blob([bytes])
    .stream()
    .pipeThrough(new DecompressionStream("gzip"));
  const text = await new Response(stream).text();
  return JSON.parse(text);
}
```

## Testing

High-level Cucumber specs drive both the analysis service and the rendering paths. I do not care much about low-level unit tests here. The value is in the end-to-end shape of the response and the rendered output.

```gherkin
Feature: Server-side chess analysis
  The analysis app turns a pasted PGN into text analysis and widget-ready JSON.

  Background:
    Given the sample Chess.com PGN from the project prompt

  Scenario: Analyze the sample game
    When I submit the PGN to the analysis app
    Then I see progress while Stockfish analysis is running
    Then the response includes parsed game metadata
    And the response includes 46 board positions
    And the response includes 45 analyzed moves
    And move 11 for White is marked as castling
    And move 23 for White is marked as checkmate
    And every position includes an evaluation bar

  Scenario: Render a plain text analysis
    When I submit the PGN to the analysis app
    Then the text analysis includes Unicode chess pieces
    And the text analysis includes compact annotations such as "!", "?!", "??", or "!!"
    And the text analysis includes a text evaluation bar

  Scenario: Render a Markdown analysis response
    When I submit the PGN to the analysis app
    Then the Markdown analysis includes Unicode chess pieces
    And the Markdown analysis includes compact annotations such as "!", "?!", "??", or "!!"
    And the Markdown analysis includes a move table
    And the Markdown analysis includes a Markdown-safe evaluation bar

  Scenario: Use Stockfish when available
    Given Stockfish 18 is available in the container
    When the analysis app evaluates a position
    Then it asks Stockfish for a UCI evaluation
    And it falls back to material evaluation if Stockfish fails or times out

  Scenario: Review saved analyses
    Given at least one game has been analyzed
    When I open the analyses index
    Then I see the saved games
    And I can open a saved game
    And I can inspect its metadata, moves, evaluations, and board snapshots
```

The Stockfish fallback scenario is the one I care about most. If the binary is missing or hangs, the service returns a material-only evaluation and flags the result as approximate, instead of failing the request outright.

## Agentic Workflow

First project I built almost entirely in an agentic manner. I wrote the spec in Markdown and mostly stayed high-level: architecture, route layout, widget UX, what the analysis payload should look like. I nudged the LLM into the decisions that mattered. The database schema, the shape of the widget's custom element API, how bookmarks should hang off the move list without coupling to it. I did not read every line of code.

## Future Development

- Comments in analysis mode. Annotate a move and the widget will display the comment when you land on that ply.
- Threat lines. Show the engine's suggested continuation as an overlay on the board.
- Puzzle mode. Pick a position from a game and let the reader try to find the best move before revealing it.
- Piece and board image customization. Swap piece sets and board themes via CSS variables, no rebuild.

## Demo

Live demo at [chess.cb341.dev/about](https://chess.cb341.dev/). A game not particularly proud of but shows what the widget is about.
