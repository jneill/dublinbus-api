Dublin Bus Real Time API
========================

API access to the [Real Time Passenger Information](http://rtpi.ie/) (RTPI) for Dublin Bus services.

Setup and run the Ruby/Sinatra app yourself or use the existing service at [http://dublinbus-api.heroku.com/stops](http://dublinbus-api.heroku.com/stops).
Note that usage of the running service is permitted for non-commercial use only. There are currently no rate
limits but please be respectful with your usage.

Disclaimer
----------

This service is in no way affiliated with Dublin Bus or the providers of the RTPI service.

A warning about the availability of the data from this API. The data is taken from the still-in-development [RTPI](http://rtpi.ie/) site. That site will likely
change greatly in the near future meaning this code will probably break without warning. Even if the
site remains stable, I wouldn't be shocked if The Powers That Be decided this isn't a permitted use
of the data and prevent its use either technically or legally. For now I'm working on the assumption that
the data is free to use since the RTPI site doesn't list any licensing information and doesn't have a
[robots.txt](http://www.robotstxt.org/robotstxt.html).

REST API
--------

The API is exposed as a very simple REST interface. 

JSON is the only format supported. JSONP will be returned if a *callback* parameter is passed.

### Stops

**GET [/stops](http://dublinbus-api.heroku.com/stops)**

List all the bus stops in the system with the following optional parameter constraints:

* *origin*: a 'lat,lng' value which serves as a reference point from which distances are measured. Defaults to '53.347778,-6.259722' (54 O'Connell St)
* *range*: return only stops within *range* kilometers of *origin*. Default is unbounded.
* *routes*: return only stops along the comma separated *routes*

**note** results are limited to 30 entries per request, pagination will be implemented

Example: GET [/stops?origin=53.343488,-6.249311&range=0.2&routes=2,3](http://dublinbus-api.heroku.com/stops?origin=53.343488,-6.249311&range=0.2&routes=2,3)

Gets all #2 or #3 bus stops within 200m of Pearse St Dart station

Result:

    {
      "data": [
        {
          "href": "/stop/westland+row/00495",
          "name": "Westland Row"
          "location": "53.343536,-6.249864",
          "services": [
            {
              "href": "/services/2/0203",
              "route": "2",
              "from": {
                "href": "/stops/park+avenue/00381",
                "name": "Park Avenue",
                "location": "53.324195,-6.212297"
              },
              "to": {
                "href": "/stops/upper+o%27connell+st/00279",
                "name": "Upper O'Connell St",
                "location": "53.350012,-6.260653"
              }
            },
            ...
          ],
        },
        ...
      ]
    }

* *href*: absolute path to the bus stop resource
* *name*: a non-unique name given to the bus stop
* *location*: the 'lat,lng' position of the bus stop
* *services*: the set of services that stop at the stop
  * *href*: absolute path to the service
  * *route*: the name of the service's route
  * *from*: the bus stop that the route starts at
  * *to*: the bus stop that the route stops at

**GET [/stops/{name}/{id}](http://dublinbus-api.heroku.com/stops/lower+o%27connell+st/00271)**

Get the current live information for a particular bus stop.

* *name*: the name of the bus stop
* *id*: the ID of the bus stop

Example: GET [/stops/lower+o%27connell+st/00271](http://dublinbus-api.heroku.com/stops/lower+o%27connell+st/00271)

Gets the current information for the number 2 bus stop on Lower O'Connell St

Result:

    {
      "data": [
        {
          "href": "/stop/westland+row/00495",
          "name": "Westland Row"
          "location": "53.343536,-6.249864",
          "services": [
            {
              "href": "/services/2/0203",
              "route": "2",
              "from": {
                "href": "/stops/park+avenue/00381",
                "name": "Park Avenue",
                "location": "53.324195,-6.212297"
              },
              "to": {
                "href": "/stops/upper+o%27connell+st/00279",
                "name": "Upper O'Connell St",
                "location": "53.350012,-6.260653"
              }
            },
            ...
          ],
          "buses": [
            {
              "route": "2",
              "destination": "Upper O'Connell St",
              "time": "7"
            },
            {
              "route": "3",
              "destination": "Upper O'Connell St",
              "time": "15"
            },
            ...
          ]
        }
      ]
    }

The *href*, *name*, *location* and *services* fields are the same as above while the *buses* 
field contains the live departure information for the bus stop.

* *buses*: the buses on their way to the stop
  * *route*: the route of the bus
  * *destination*: the destination of the bus
  * *time*: the number of minutes before the bus departs the stop

### Services

**GET [/services](http://dublinbus-api.heroku.com/services)**

List all the services in the system. 

Result:

    {
      "data": [
        {
          "href": "/services/2/0203",
          "route": "2",
          "from": {
            "href": "/stops/park+avenue/00381",
            "name": "Park Avenue",
            "location": "53.324195,-6.212297"
          },
          "to": {
            "href": "/stops/upper+o%27connell+st/00279",
            "name": "Upper O'Connell St",
            "location": "53.350012,-6.260653"
          }
        },
        {
          "href": "/services/2/0202",
          "route": "2",
          "from": {
            "href": "/stops/ucd+belfield/00766",
            "name": "UCD Belfield",
            "location": "53.305397,-6.218354"
          },
          "to": {
            "href": "/stops/upper+o%27connell+st/00279",
            "name": "Upper O'Connell St",
            "location": "53.350012,-6.260653"
          }
        },
        ...

**GET [/services/{route}](http://dublinbus-api.heroku.com/services/2)**

Get detailed stop information for all services on a particular route

* *route*: the name of the route the services operates on

Example: GET [/services/2](http://dublinbus-api.heroku.com/services/2)

Gets stop information for services on the #2 route

Result:

    {
      "data": [
        {
          "href": "/services/2/0202",
          "route": "2",
          "from": {
            "href": "/stops/ucd+belfield/00766",
            "name": "UCD Belfield",
            "location": "53.305397,-6.218354"
          },
          "to": {
            "href": "/stops/upper+o%27connell+st/00279",
            "name": "Upper O'Connell St",
            "location": "53.350012,-6.260653"
          },
          "stops": [
            {
              "href": "/stops/ucd+belfield/00766",
              "name": "UCD Belfield",
              "location": "53.305397,-6.218354"
            },
            {
              "href": "/stops/nutley+lane/02085",
              "name": "Nutley Lane",
              "location": "53.315171,-6.220177"
            },
            ...
          ]
        },
        ...
      ]
    }

**GET [/services/{route}/{id}](http://dublinbus-api.heroku.com/services/2/0202)**

Get detailed stop information for a particular service

* *route*: the name of the route the service operates on
* *id*: the ID of the route

Example: GET [/services/2/0202](http://dublinbus-api.heroku.com/services/2/0202)

Gets stop information for the #2 from UCD to O'Connell St

Result is exactly as for /services/{route} but the data array will contain exactly one item
