## autobuzz

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

![](http://f.cl.ly/items/1d1j42352s063C432b0c/image.jpg)
