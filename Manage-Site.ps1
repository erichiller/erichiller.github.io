<#
.SYNOPSIS
Publish-Site is a set of functions to allow for quick updates and uploads of my Hugo site.
.DESCRIPTION
Allows for management of hugo based site hosted on github. Including building of associated
resources - SASS -> CSS , lunr-index; as well as starting a test server locally. The new page
config from Hugo can be called here as well
.PARAMETER RefreshResources
Takes no parameters
.PARAMETER CreatePage
Loads the test editor configured within Hugo, takes <CATEGORY> <TITLE>
.PARAMETER Category
Category which the article will be entered into within the site. For example, "blog"
.PARAMETER Title
Article Title, this will be made into a URL parseable filename as well.
.PARAMETER StartServer
Starts a local server for testing, takes no parameters.
.PARAMETER Publish
Builds the site, commits the site (source), and pushes it to be available publicly
Publish takes the sole (optional) parameter of <COMMIT MESSEAGE>
Remember that POWERSHELL allows for MULTILINE variables (encapsulate with quotes),
and that longer commit messages are preferred, so please make use of them!
.PARAMETER CommitMessage
Remember that POWERSHELL allows for MULTILINE variables (encapsulate with quotes),
and that longer commit messages are preferred, so please make use of them!
.LINK
https://gohugo.io/overview/introduction/
.LINK
http://www.hiller.pro
.LINK
https://github.com/erichiller/erichiller.github.io
#>

[CmdletBinding(DefaultParameterSetName="help")]
Param(
	[Parameter(Mandatory=$true,ParameterSetName="RefreshResources")]
		[switch] $RefreshResources,
	[Parameter(Mandatory=$true,ParameterSetName="CreatePage")]
		[switch] $CreatePage,
		[Parameter(Mandatory=$true,ParameterSetName="CreatePage")]
			[string] $Category,
		[Parameter(Mandatory=$true,ParameterSetName="CreatePage")]
			[string] $Title,
	[Parameter(Mandatory=$true,ParameterSetName="StartServer")]
		[switch] $StartServer,
	[Parameter(Mandatory=$true,ParameterSetName="Publish")]
		[switch] $Publish,
		[Parameter(Mandatory=$false,ParameterSetName="Publish",Position=2)]
			[string] $CommitMessage = "default message: rebuilt site",
	[Parameter(ParameterSetName="help")]
		[alias("h","?")]
		[switch] $help
)


$local:Path += Add-DirToPath ( Join-Path $Env:LOCALAPPDATA "\go\bin" )
$local:Path += Add-DirToPath ( Join-Path $Env:USERPROFILE "\DEV\bin" )

$SiteRoot = Split-Path $Script:MyInvocation.MyCommand.Path
$OmegaDirectory = ( Join-Path $Env:LOCALAPPDATA "\omega" )

$config = Join-Path $SiteRoot "\src\config.toml"
$source = Join-Path $SiteRoot "\src\"


function RefreshResources {
	# build SASS -> CSS
	& node-sass.cmd $(Join-Path $SiteRoot "\_scss\main.scss" ) $(Join-Path $SiteRoot "\src\static\css\main.css" )

	# build Search INDEX
	grunt --gruntfile $(Join-Path $SiteRoot "\indexer\Gruntfile.js" ) lunr-index
}

function StartServer {
	Write-Debug "Starting Hugo Server with the configuration located at $config"

	RefreshResources

	& hugo.exe server `
		--verbose `
		--disableLiveReload `
		--source=$source `
		--config=$config
}

<#
See the parameter above
#>
function CreatePage {
#	param(
#	[string (Mandatory=$true) ] $Category,
#	[string (Mandatory=$true) ] $Title
#	)

	$CallingDirectory = (Convert-Path . )
	Set-Location $source
	& hugo.exe new --config=$config $Category/$Title
	Set-Location $CallingDirectory
}

function Publish {
#	param(
#		[string (Mandatory=$false) ] $CommitMessage = "default message: rebuilt site"
#	)

	RefreshResources

	# build hugo
	& hugo.exe `
		--verbose `
		--logFile=$(Join-Path $SiteRoot "\hugo_build.log") `
		--source=$source `
		--destination=$(Join-Path $SiteRoot "\public\")

	# copy in the CNAM file required for GitHub sites
	Copy-Item (Join-Path $SiteRoot "\CNAME") (Join-Path $SiteRoot "\public\CNAME")

	# update git, adding changes
	& git add -A

	# commit changes, set message to the date / version
	$FullCommitMessage = "[$(Get-Date -format "yyyy-MMM-dd HH:mm")] $CommitMessage"
	Write-Debug "Commiting: $FullCommitMessage"
	& git commit -m "$FullCommitMessage"

	# push the entirety of the source
	#& git push origin master:source
	& git push origin source

	# push site to git
	#& git push origin `git subtree split --prefix=public master`:master --force
	& git subtree push --prefix=public origin master
}

if( $RefreshResources ){ RefreshResources }
elseif( $CreatePage ){ CreatePage }
elseif( $StartServer ) { StartServer }
elseif( $Publish ) { Publish }
else {
	Get-Help $Script:MyInvocation.invocationname
}
