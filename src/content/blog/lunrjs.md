+++
title="Setting up Search on a Static Website"
date=2015-11-15T12:00:00-08:00
tags=[
	"hugo",
	"web",
	"javascript",
	"search",
	"lunr.js"]
+++

Creating a static website has a number of advantages, not least of which is speed. However there can certainly be some difficulties in creating ease-of-use features for visitors. One such feature that I wanted for this site, was a on-site search feature, as my intention is gradually convert my local documentation and upload it. In order for me to implement this I had to find a client-side solution as the server was to be entirely static, enter [lunr.js](https://lunrjs.com/). lunr.js is written in javascript, and has an indexer that runs on node on your local machine, goes over your site files generating a json index file, then has a search library that you call from your web frontend (and thus in the client's browser) which reads and searches that index file. This allows for your site to stay static, and still have the dynamic feature of search. Thanks to these clever folks, search implementation became a snap for my static, hugo powered website.

Here I have put together a gist on how to get up and running:

{{< gist 08fd60c5490667cc371b >}}