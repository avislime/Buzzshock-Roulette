# Buzzshock Roulette
## Customizable [Pishock](https://pishock.com/) and [Intiface Central](https://intiface.com/) integration for Buckshot Roulette

Made on Buckshot Roulette 2.2.0.6, built for [BRML-E](https://github.com/D1GQ/BuckshotRouletteModLoaderExtended) 1.0.2.
Made this in 2 days after having 0 knowledge on scripting in Godot for fun. Not much else to it, nor is it tested super thoroughly. It's on the list, however.

Features:
* Websocket API support for [Multishock](https://mshock.akiradev.me/) and [Intiface Central](https://intiface.com/)
* Granular event types
  * Gunshots
    * Distinct events for if bullet is live or blank, sawed off/double damage, and if it kills
  * Individiaul events for all items
    * Expired Medicine outcomes have distinct events
    * Player Jammed has a distinct event
* Flexible event configuration
  * Config is in human readable JSON (Located within %AppData$\Godot\app_userdata\Buckshot Roulette - Modded)
  * Each individual event allows for device type, action, intensity, and duration to be changed.

Todo:
  * Actually sane configuration defaults
  * Add Events for kicking the doors down. For the bit.
  * Port to BRMLNeo (On hold until release)
  * Multiplayer support (On hold)
