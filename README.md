# Testing Commands

local server

	hugo server --verbose --source=src --destination=public
	
local scss -> css build

	node-sass.cmd _scss/main.scss src/static/css/main.css


# Requirements

* hugo (can be installed either in the `/` directory of the site, or in the `%PATH%`)
* node
   * grunt
   * node-sass (global)
   * toml
   * string

# Installation

`git clone https://github.com/erichiller/erichiller.github.io -b source`

1. Go into `/indexer` and run `npm install` - this will install `grunt` and dependencies
2. in `/` execute `Manage-Site.ps1`