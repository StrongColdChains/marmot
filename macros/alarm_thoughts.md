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
Future refactor work would be think through whether its worth trying to
rethink how we handle temperature alarms.


We probably shouldn't generate alarms / intervals for
CCEs that don't validate.

For each alarm we support, we should have an interval generated.

Each interval should limit the CCEs it pulls and calculates stats
for.

Maybe all the alarms get dumped into the same model?

Well, are the KPIs shared across alarms? Not really, each is defined
individually.

Uptime is defined on all the alarms.


We either have them fan in, then fan out again for KPIs, OR just keep
them separated out and fan them in for the uptime def.