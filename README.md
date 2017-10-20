# Testing Commands

local server

	hugo server --verbose --source=src --destination=public
	
local scss -> css build

	node-sass.cmd _scss/main.scss src/static/css/main.css


# Requirements

* hugo (can be installed either in the `/` directory of the site, or in the `%PATH%`)
* node
   * grunt
   * grunt-cli
   * node-sass (global is ideal)
   * toml
   * string

# Installation

`git clone https://gitlab.com/erichiller/erichiller.gitlab.io`

1. From the repo directory run `npm install` - this will install `grunt` and dependencies
2. `hugo new` in order to create new articles will open Visual Studio code which is the currently configured editor
3. Once finished, simply `git commit` , `git add` and `git push`


# To Do

- revive `Manage-Site.ps1` for testing and other utilitarian purposes