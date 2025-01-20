## alarm thoughts

This document's purpose is to clarify thoughts around how to structure the
part of the data pipeline that calculates alarms.

Appliance "types" described by E006 DS01.2:
- stationary vs mobile
- refrigeration vs freezer
- room vs non-room
- mains-powered vs solar-powered
- emd vs no emd

These are not defined rigorously, they're just mentioned throughout the document.
It's tempting to try to create a bunch of different parameters to track all the
different "application types" but since the document is so unrigorous in defining
them, I think it's actually easier to just literally enumerate all the use cases
defined by the document. A bit tedious to maintain but introduces a lot less toil.


Right now alarms / thresholds are always being generated, but we don't need to
generate freezer heat alarms for a fridge. Let's reduce that work in the future.

## Alarm Definitions

If a CCE has an alarm (the conditions of the alarm have been met) then the alarm
will begin on the first time series data point that violates the alarm threshold
and will stop on the first time series data point that no longer violates the
alarm threshold.
