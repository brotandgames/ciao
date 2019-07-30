# Webhook Configuration

*Note: this feature is not released yet - see #1 for updates.*

You can configure as many webhooks as you like. Each webhook consists of 2 ENV variables:

* `WEBHOOK_ENDPOINT_$NAME`
* `WEBHOOK_PAYLOAD_$NAME`

`$NAME` can be any word `[A-Z0-9_]` and must be unique as it is used as an identifier.

like:

````
# Webhook for Rocketchat
WEBHOOK_ENDPOINT_ROCKETCHAT="https://webhook.rocketchat.com/***/***"
WEBHOOK_PAYLOAD_ROCKETCHAT='"{foo=bar}"'

# Webhook for Slack
WEBHOOK_ENDPOINT_SLACK="https://webhook.slack.com/***/***"
WEBHOOK_PAYLOAD_SLACK='"{foo=bar}"'

etc.
````

`WEBHOOK_PAYLOAD_$NAME` ENV variable has to be a valid JSON one-liner wrapped in single quotes like `'{"text":"Example message"}'`.

## Example configurations

### RocketChat

tbd.

### Slack

tbd.
