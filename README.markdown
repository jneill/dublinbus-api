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

**GET [/stops](http://dublinbus-api.heroku.com/stops)**

List all the bus stops in the system with the following optional parameter constraints:

* *origin*: a 'lat,lng' value which serves as a reference point from which distances are measured. Defaults to '53.347778,-6.259722' (54 O'Connell St, Dublin 1)
* *range*: return only stops within *range* kilometers of *origin*. Default is unbounded.
* *count*: return only the *count* closest stops to *origin*. Default is unbounded.
* *route*: return only stops where buses on *route* stop

Example: GET [/stops?origin=53.343488,-6.249311&range=0.2&count=3](http://dublinbus-api.heroku.com/stops?origin=53.343488,-6.249311&range=0.2&count=3)

Gets all bus stops within 200m of Pearse St Dart station, limited to the nearest three.

Result:

    {
      "stops": [
        {
          "href":"/stop/westland+row/00495",
          "loc":"53.343536,-6.249864",
          "routes":["7"],
          "name":"Westland Row"
        },
        {
          "href":"/stop/westland+row/02809",
          "loc":"53.34303,-6.249845",
          "routes":["7"],
          "name":"Westland Row"
        },
        {
          "href":"/stop/pearse+street/00399",
          "loc":"53.343863,-6.248146",
          "routes":["7"],
          "name":"Pearse Street"
        }
      ]
    }

* *href*: absolute path to the bus stop resource
* *loc*: the 'lat,lng' position of the bus stop
* *routes*: the routes that stop at the bus stop
* *name*: a non-unique name given to the bus stop

**GET [/stops/{name}/{id}](http://dublinbus-api.heroku.com/stops/lower+o%27connell+st/00271)**

Get the current live information for a particular bus stop.

* *name*: the name of the bus stop
* *id*: the ID of the bus stop

Example: GET [/stops/lower+o%27connell+st/00271](http://dublinbus-api.heroku.com/stops/lower+o%27connell+st/00271)

Gets the current information for the number 2 bus stop on Lower O'Connell St

Result:

    {
      "stops": [
        {
          "href":"/stop/lower+o%27connell+st/00271",
          "loc":"53.348513,-6.259624",
          "routes":["2","7","14","14A","48A"],
          "name":"Lower O'Connell St",
          "live": {
            "updated":"2011-03-23T02:58:14Z",
            "services":[
              {
                "route":"48A",
                "dest":"Parnell Square West via Ranelagh",
                "time":"7"
              },
              {
                "route":"7",
                "dest":"O'Connell St via Ballsbridge",
                "time":"17"
              },
              {
                "route":"14A",
                "dest":"Parnell Square East via Rathmines",
                "time":"37"
              },
              {
                "route":"14",
                "dest":"Parnell Square via Rathmines",
                "time":"47"
              }
            ]
          }
        }
      ]
    }

The *href*, *loc*, *routes* and *name* fields are the same as above while the *live* 
field contains the live departure information for the bus stop.

* *updated*: the ISO-8601 time indicating when the data was last updated (currently always within the last 30 seconds)
* *services*: the buses on their way to the stop
  * *route*: the route of the bus
  * *dest*: the destination of the bus
  * *time*: the number of minutes before the bus departs the stop




