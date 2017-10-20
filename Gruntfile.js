var toml = require("toml");
var S = require("string");

var CONTENT_PATH_PREFIX = "./src/content";
var SITE_IDX_DEST = "./public/js/pindex.json";

// https://github.com/uxitten/polyfill/blob/master/string.polyfill.js
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/padStart
if (!String.prototype.padStart) {
    String.prototype.padStart = function padStart(targetLength,padString) {
        targetLength = targetLength>>0; //floor if number or convert non-number to 0;
        padString = String(padString || ' ');
        if (this.length > targetLength) {
            return String(this);
        }
        else {
            targetLength = targetLength-this.length;
            if (targetLength > padString.length) {
                padString += padString.repeat(targetLength/padString.length); //append to original to ensure we are longer than needed
            }
            return padString.slice(0,targetLength) + String(this);
        }
    };
}

module.exports = function(grunt) {

	grunt.registerTask("lunr-index", function() {

		grunt.log.writeln("Build pages index");

		var indexPages = function() {
			var pagesIndex = [];
			grunt.file.recurse(CONTENT_PATH_PREFIX, function(abspath, rootdir, subdir, filename) {
				grunt.verbose.writeln("Parse file:",abspath);
				pagesIndex.push(processFile(abspath, filename));
			});

			return pagesIndex;
		};
		
		var getHref = function(frontMatter) {
			if (frontMatter.url) {
				return frontMatter.url;
			}
			// have to create from date and title or slug
			href = frontMatter.date.getFullYear() + "/"
			href += ( frontMatter.date.getMonth() + 1 ).toString().padStart(2, "0") + "/"
			href += frontMatter.date.getDate().toString().padStart(2, "0") + "/"
			if (frontMatter.slug) {
				grunt.log.ok("found slug")
				href += frontMatter.slug
			} else {
				href += frontMatter.title
			}
			href = href.toLowerCase()
			href = href.replace(/ /g, "-")
			return href
		}

		var processFile = function(abspath, filename) {
			var pageIndex;

			if (S(filename).endsWith(".html")) {
				pageIndex = processHTMLFile(abspath, filename);
			} else {
				pageIndex = processMDFile(abspath, filename);
			}

			return pageIndex;
		};

		var processHTMLFile = function(abspath, filename) {
			var content = grunt.file.read(abspath);
			var pageName = S(filename).chompRight(".html").s;
			var href = S(abspath)
				.chompLeft(CONTENT_PATH_PREFIX).s;
			return {
				title: pageName,
				href: href,
				content: S(content).trim().stripTags().stripPunctuation().s
			};
		};

		var processMDFile = function(abspath, filename) {
			var content = grunt.file.read(abspath);
			grunt.log.ok("READING FILE:" + abspath)
			var pageIndex;
			// First separate the Front Matter from the content and parse it
			content = content.split("+++");
			var frontMatter;
			try {
				frontMatter = toml.parse(content[1].trim());
			} catch (e) {
				grunt.log.error("ERROR WHILST PROCESSING: " + abspath + e.message);
			}
			href = getHref(frontMatter)
			grunt.log.ok("href created: " + href)

			// Build Lunr index for this page
			pageIndex = {
				title: frontMatter.title,
				tags: frontMatter.tags,
				href: href,
				content: S(content[2]).trim().stripTags().stripPunctuation().s
			};

			return pageIndex;
		};

		grunt.file.write(SITE_IDX_DEST, JSON.stringify(indexPages()));
		grunt.log.ok("Index built");
	});
};