## autobuzz

autobuzz hooks up your apartment's call box.

Features:

- allows for a custom numeric password to open the door via the call box
- sends you a text message whenever someone is let in
- timed "auto-open" mode for when you're expecting deliveries (enabled via text message)
- always forwards the call to your phone as a fallback

### create a heroku app

```
$ heroku apps:create autobuzz
$ heroku addons:add --app autobuzz rediscloud:20
$ heroku config:set --app autobuzz PHONENUMBER=+11231231234 DOORCODE=1111

$ git clone https://github.com/bleikamp/autobuzz
$ cd autobuzz
$ git remote add heroku git@heroku.com:autobuzz.git
$ git push heroku master
```

### configure twilio

Point your twilio number to point to the heroku instance. Make sure you select **GET**:

![](http://f.cl.ly/items/3B1C3r3O1T0e2j0O2B08/Screen%20Shot%202013-07-25%20at%2010.20.09%20PM.png)

### control via text message

![](https://f.cloud.github.com/assets/2567/867804/471a2064-f739-11e2-969c-6d3126a911ad.png)

### protips

* To forward an existing Google Voice number to Twilio, use `http://twimlets.com/forward?PhoneNumber=415-555-1212` as the `Voice Request URL` to bypass the verification system.
