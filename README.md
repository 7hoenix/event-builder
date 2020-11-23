# Event Builder

## Setup

To get this to work you will need to generate a credentials.json file that will correspond with a google account that you ow that will correspond with a google account that you own.

Follow this: [https://developers.google.com/calendar/quickstart/ruby](https://developers.google.com/calendar/quickstart/ruby)

It will also lead you through the creation / authorization of the token.yaml file

## Usage

Run the program with:

`bin/run.sh`

Will need to have set CALENDAR_KEY environment variable somehow.

I use a file called aliases.sh which has the following in it:

```sh
export CALENDAR_KEY="some-calendar-key"
```

If you just want to put stuff on your main calendar then just set this to 'primary'
ls {lib,spec}/*.rb | entr rspec
