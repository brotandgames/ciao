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

`CIAO_WEBHOOK_ENDPOINT_$NAME` ENV variable has to be a valid JSON one-liner wrapped in single quotes like `'{"name":"__name__", "status_before":"__status_before__", "status_after":"__status_after__", "check_url":"__check_url__", "url":"__url__"}'`.

## Example configurations

### RocketChat

````
CIAO_WEBHOOK_ENDPOINT_ROCKETCHAT="https://chat.yourchat.net/hooks/****/****"

CIAO_WEBHOOK_PAYLOAD_ROCKETCHAT='{"username":"Brot & Games","icon_url":"https://avatars0.githubusercontent.com/u/43862266?s=400&v=4","text":"[ciao] __name__: Status changed (__status_after__)"}'

````

### Slack

tbd.
