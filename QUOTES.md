# Daily quotes

The 31 bundled lines in Quotes.js are original cyberpunk-style writing for this
plugin. They are not game dialogue, anime subtitles, or book/comic excerpts,
and are not attributed to characters.

Research references for the setting and creative direction:
- Cyberpunk 2077 official overview (mercenaries, power, body modification):
  https://www.cyberpunk.net/us/en/cyberpunk-2077
- Netflix's official Edgerunners synopsis (survival and body modification):
  https://media.netflix.com/en/only-on-netflix/81054853
- Official Edgerunners site (characters and wider setting):
  https://www.cyberpunk.net/en/edgerunners
- Dark Horse's Cyberpunk 2077 Library Edition listing, collecting Trauma Team,
  You Have My Word, and Blackout:
  https://digital.darkhorse.com/books/335aca11132d43048c81333811253230/cyberpunk-2077-library-edition-volume-1

These were setting references, not sources of verbatim quotes. No claim is made
to have verified dialogue against the full games, episodes, or books.

Selection uses local day of the month: day 1 selects entry 1, etc. The quote is
stable across refreshes/restarts during a day and changes at local midnight.
It repeats monthly. Editing the quote list can change that day's quote.

settings.json:
- "quotes": null (or omitted): bundled collection
- "quotes": ["Your own line", "Another line"]: custom rotation
- "quotes": []: hide the quote

The exact original three bundled placeholders are recognized as legacy defaults
and replaced by the new collection when the new code is installed. Custom lists
are preserved, as are other installed settings such as the search engine.
