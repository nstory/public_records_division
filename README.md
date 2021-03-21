# Public Records Division Scraper

Scraper for the [Public Records Appeals Database](https://www.sec.state.ma.us/AppealsWeb/AppealsStatus.aspx) maintained by the Secretary of the Commonwealth of Massachusetts.

You probably want to check out our web interface to this data: [Appeals — The Woke Windows Project](https://www.wokewindows.org/appeals).

## HOW TO BUILD
Everything is run using `make`. Run `make all` to run all the tasks. WARNING: if you haven't run this before, building will download ~1.5 GB of data from [sec.state.ma.us](https://www.sec.state.ma.us/)

* `input/` stores the pages and files downloaded from the Appeals Database website
* `output/` stores files generated from the data in `input/`

## CHALLENGES
There were two challenging aspects to implementing this scraper:

The [www.sec.state.ma.us](https://www.sec.state.ma.us/) website is fronted by the [Imperva Incapsula](https://en.wikipedia.org/wiki/Incapsula) content delivery network (CDN). Incapsula attempts to block website scrapers (or "bots") from accessing a protected site

The Appeals Database appears to be built using [ASP.NET Web Forms](https://en.wikipedia.org/wiki/ASP.NET_Web_Forms). Web Forms apps are really annoying to scrape; they store information in hidden form inputs (e.g. `__VIEWSTATE`) which must be passed with each form submit.

Both of these problems were mostly solved by employing [Headless Chrome](https://developers.google.com/web/updates/2017/04/headless-chrome) to access the site. This makes the scraper indistinguishable from a human user, so we are not blocked by Incapsula. This also frees us from having to know the implementation details of ASP.NET Web Forms, we can rely on Chrome to submit the forms, AJAX requests, etc. correctly.

## LICENSE
This project is released under the MIT License.
