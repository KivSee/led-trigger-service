# led_trigger_service
Control the triggers for the kivsee led system.
Trigger is a single global common signal that states the current sequence to be played by all controllers in the setup. Controller can then subscribe to the mqtt topic `trigger` and receive notifications about active trigger, which is then used to play a led sequence.

## Trigger Types
There are 2 types of triggers

### Song Trigger
Trigger which plays an audio file via the wavalsaplayer and monitors the player updates reporting when song starts \ end and time updates.

### Simple Trigger
Only a led sequence with no audio is triggered.

## Prerequisites

Use ruby version manager [rbenv](https://github.com/rbenv/rbenv?tab=readme-ov-file#installation).

Install required ruby version as specified in `.ruby-version` file:
```bash
rbenv install x.x.x
```

## Usage
Install dependencies: 
```bash
bundler install
````

Run the service: 
```bash
ruby app/led_trigger_service.rb
```

Configure the service via the following environment variables or `.env` file

| name | default | description |
| --- | --- | --- |
| PORT | 4567 | service port for incomming http connections |
| APP_ENV | development | deployment environment. set this value when running in non developement environments |
| LED_SEQ_SERVICE_IP | - | host name or ip for led sequence service |
| LED_SEQ_SERVICE_PORT | 8082 | port for led sequence service |
| PLAYER_IP | - | host name or ip for wavplayeralsa service |
| PLAYER_PORT | 8080 | port for wavplayeralsa service |
| BROKER_URL | - | url for mqtt broker. example: `mqtt://10.0.0.200` |

## REST API
Triggers can be played and stopped via the following http endpoints.
To set the port for the http server, use environment variable:
```
PORT=8083
```

### Endpoints:
- POST `/song/:trigger_name/play` - play an audio file and the coresponding led sequence.example payload (all is optional):
```json
{
    "sequence_guid": "{guid}",
    "start_offset_ms": 5000
}
```

- POST `/trigger/:trigger_name` - play a single trigger. example payload (all is optional):
```json
{
    "sequence_guid": "{guid}",
    "start_offset_ms": 5000
}
```

- POST `/stop` - stop the current song or single trigger and inform controllers to clear sequence rendering
