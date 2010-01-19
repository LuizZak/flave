The Flash Verlet Engine - Flave v0.6.2b

This is the first public beta release of the Flave engine.
Many things are yet to be fixed and many features are half-baked,
but still, it's one nifty little engine that I'm sure will be
useful to someone!



TODO List

- Change the raycast engine so it casts the rays instead of adding them
  to the broad-phase grid.


Version History

Legend:
+ Feature add
- Feature remove
* Fix
. Note

v0.6.3b

* Ray-casting code revisited, ray-casting is now 23% faster

v0.6.2b

+ The engine now has a fancy-pants logo!
+ Added a few more samples to the Sample file
* Fixed some typos on the docs
* Fixed a bug were the ray-caster would point lastHit incorrectly
* Fixed a bug with the ray-caster rendering engine on CS3
* Fixed a bug which would resolve collision with fixed particles
* Fixed the collision resolving bug that could happen when the delta
  between a particle and a joint was 0

v0.6b

. First public release


FLAVE IS LICENSED UNDER THE MIT LICENSE. SEE LICENSE.TXT FOR MORE INFORMATION AND THE LICENSE.