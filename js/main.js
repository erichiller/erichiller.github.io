window.onload = function() {
	
	var getMax = function(){
		console.log(document.body.scrollHeight + " - " + document.body.clientHeight + " = " + (document.body.scrollHeight - document.body.clientHeight) + "//" + window.innerHeight)
		
		/**
		 * Use `window.innerHeight` for determining the browser viewport height
		 * not `document.body.clientHeight` as it is non-standards based and will break
		 * when the document is declared with `<!DOCTYPE html>`
		 * 
		 * */
		return document.body.scrollHeight - window.innerHeight;
	}
	
	var getValue = function(){
		return document.body.scrollTop;
	}
	
	var max = getMax(),
		value, width;
		
	var getWidth = function() {
      // Calculate width in percentage
      value = getValue();            
      width = (value/max) * 100;
      width = width + '%';
	  console.log(value + "/" + max + "=" + width +"%")
      return width;
    }
	
	var $readProgressBarArr = document.getElementsByClassName('readProgressBar')
	
	var setWidth = function(){
		var arrayLength = $readProgressBarArr.length;
		for (var i = 0; i < arrayLength; i++) {
			var el = $readProgressBarArr[i]
			el.style.width = getWidth();
		}
	}
	
	var setMax = function(){
		max = getMax();
		setWidth();
	}
	
	document.addEventListener('scroll', setWidth);
	window.addEventListener('resize',setMax)
	
	
/** ORIGINAL MAIN.JS **/
	
	var $menuIcon = document.getElementsByClassName('menu-icon')[0],
        $offCanva = document.getElementsByClassName('off-canvas')[0],
        $siteWrap = document.getElementsByClassName('site-wrapper')[0];

    $menuIcon.addEventListener('click', function() {
        toggleClass($menuIcon, 'close');
        toggleClass($offCanva, 'toggled');
        toggleClass($siteWrap, 'open');
    }, false);

    $menuIcon.addEventListener('mouseenter', function() {
        addClass($menuIcon, 'hover');
    });

    $menuIcon.addEventListener('mouseleave', function() {
        removeClass($menuIcon, 'hover');
    });

    function addClass(element, className) {
        element.className += " " + className;
    }

    function removeClass(element, className) {
        // Capture any surrounding space characters to prevent repeated
        // additions and removals from leaving lots of spaces.
        var classNameRegEx = new RegExp("\\s*" + className + "\\s*");
        element.className = element.className.replace(classNameRegEx, " ");
    }

    function toggleClass(element, className) {
        if (!element || !className) {
            return;
        }

        if (element.className.indexOf(className) === -1) {
            addClass(element, className);
        } else {
            removeClass(element, className);
        }
    }

	// Open shares
	var $popup
	var $elarr = document.getElementsByClassName('popup')
	var arrayLength = $elarr.length;
	for (var i = 0; i < arrayLength; i++) {
		$popup = $elarr[i]
		$popup.addEventListener('click', function(e) {
			e.preventDefault()
			var width  = 575,
				height = 400,
				right   = (document.documentElement.clientWidth  - width)  / 2,
				top    = (document.documentElement.clientHeight - height) / 2,
				url    = this.href,
				opts   = 'status=1' +
						',width='  + width  +
						',height=' + height +
						',top='    + top    +
						',right='   + right;
	
			window.open(url, 'Share', opts);
	
			return false;
		});
	}

}