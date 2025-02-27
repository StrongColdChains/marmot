# Roadmap

A vague list of things that we'd like to do in the near future.

## technical things

### things to do before advertising
- Turn all of the env var stuff into env vars if its relevant
  - postgres user / pass deets. Obviously production instances should be encouraged
    to use legit credentials that aren't stored in git.
- turn cce_id and monitor_id into actual foreign keys.
  - cces need to make the following distinctions
    - stationary vs mobile
    - refrigeration vs freezer
    - room vs non-room
    - mains-powered vs solar-powered
    - emd vs no emd
  - determine what distinctions we need to make for monitors.
  - figure out the PQS terms for (cce / monitor / sensor / base station) and use them.
- make alarm thresholds configurable - the various design docs imply that they should be.
- properly document dbt stuff
- review project structure of dbt. should the project be dev? should everything be
  in one schema?
- update naming of models (uptime island should be int, not mart).
- Implement ACK as time series data!
  - Good introductory feature.
- start to write some data generation tools. Look at timescale's tsbs tool for inspiration.
- (stretch goal): write a CCE report with latex. this report should be useful
  for a CCE repair person on-site.
  - contains all relevant KPIs for the CCE.
  - highlights all *points of interest* in the last X days in a graph.
  - should be able to handle arbitrary numbers of days.
  - appendix should contain all relevant info that we have on the CCE.

### Next steps (these are more fun :D)
- add sim signal strength
  - "Cell signal strength typically ranges from -50 dBm to -120 dBm"
  - if a device goes offline and the previous few days of signal strength are really
      bad, then we can attribute the offline to sim connectivity.
  - Good introductory feature.
- Make the intermediate calculations in `nonfunctional_cces` a view so that functional
    status can be easily debugged.
  - Good introductory feature.
- Make functional status a float so that we can provide a more nuanced view of
    a cce's health. Thresholds are generally bad, floats are good : )
  - Good introductory feature.
- Create basic metrics that assess the health of the underlying CCE.
  - pull out things like the range of the temperature wave. rate of temp increase.
  - see if the average temperature of the cce is consistently drifting low
    - https://github.com/facebookresearch/Kats/blob/main/tutorials/kats_202_detection.ipynb
  - ideally, this metric should be resilient to power-outage related temperature excursions.
- Make a stab at categorizing *why* excursions happen. power outage? door left open?
  - first, just look at a CCEs other data sources.
  - then, look at the facility its in
- create a tool for imputing missing data. integrate it into the dbt dag.
- actually set up tests in a good way??? don't understand dbt's testing framework yet.
- define a data model for devices, cces, facilities, and arbitrary groupings of cces.
  - facilities should be implemented as an arbitrary grouping of cces. it's a special case.
  - make a distinction between a sensor and a base station. sensors pick up temps, base stations
      send the data to the central server. a single piece of hardware can be both a sensor and
      a base station. but some aren't! might be useful to make distinctions between a cce going
      offline because of a base station (sim connectivity issues) vs a sensor (bluetooth / wire issues).
- define reasonable KPIs for arbitrary groupings of cces. 😈 this is where things get
    interesting / challenging.
- settle on a technology for visualizing time series data.
- figure out a story for performance monitoring + load testing.
- hook up https://github.com/plmercereau/chat-dbt to postgres! woo! cool! ai for cheap :p
- connectivity should also be defined for sensors, not just base stations.

## communication / writing / education things

- explain the types of actions we're trying to support.
  - equipment procurement. what types of equipment perform well in the field?
  - cce maintenance, when someone goes into the field do they have *easy* access to relevant data?
  - device procurement. what types of devices perform well in the field?
  - assessing the success of cold chain data programs. how well are the contextual databases being maintaned?
  - where are vaccines getting the most damage in the chain?
- explain the difference between created_at and received_at.
- explain the different domains that all need to go right for data to be properly interpreted.
- explain the weaknesses of E006/DS01.2, lots of improvements possible :D
- write some pieces showing off the value of various metrics (ideally, publish it when you
    implement said metric within our system).
- come up with a cute little mascot for this project : )

## misc

- think about the unique challenges that wic and wifs present. these store tons of vaccines, what
    can we do to improve their performance?
- is there any way we can measure the effectiveness of device setups? For devices that operate over
    wires, is there any way for us to know if a configuration is bad?
- is there a reason EMD alarms are defined but not KPIs?
- https://discourse.getdbt.com/t/how-to-create-near-real-time-models-with-just-dbt-sql/1457 read
    through this. Does it really make sense to not try to tackle any real-time data stuff with this
    project? What frequency limitations does this project have?

