# Webhook Configuration

*Note: this feature is not released yet - see #1 for updates.*

You can configure as many webhooks as you like. Each webhook consists of 2 ENV variables:

* `CIAO_WEBHOOK_ENDPOINT_$NAME`
* `CIAO_WEBHOOK_PAYLOAD_$NAME`

`$NAME` can be any word `[A-Z0-9_]` and must be unique as it is used as an identifier.

like:

````
# Webhook for Rocketchat
CIAO_WEBHOOK_ENDPOINT_ROCKETCHAT="https://webhook.rocketchat.com/***/***"
CIAO_WEBHOOK_PAYLOAD_ROCKETCHAT='"{foo=bar}"'

# Webhook for Slack
CIAO_WEBHOOK_ENDPOINT_SLACK="https://webhook.slack.com/***/***"
CIAO_WEBHOOK_PAYLOAD_SLACK='"{foo=bar}"'

etc.
````

`CIAO_WEBHOOK_ENDPOINT_$NAME` ENV variable has to be a valid JSON one-liner wrapped in single quotes like `'{"name":"__check_name__", "status_before":"__status_before__", "status_after":"__status_after__"}'`.

## Example configurations

### RocketChat

tbd.

### Slack

tbd.
