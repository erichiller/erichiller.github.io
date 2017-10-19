

param(
	[Parameter(Mandatory=$true, HelpMessage="API Key from Gandi for Live DNS")]
	[String]
	$APIKEY,
	
	[Parameter(Mandatory=$true, HelpMessage="SHA String from certbot")]
	[String]
	$CHALLENGE_VALUE,

	[Parameter(Mandatory=$false)]
	[String]
	$DOMAIN = "hiller.pro",

	[Parameter(Mandatory=$false, HelpMessage="do not add domain portion of string, Gandi does this for us")]
	[String]
	$RECORD_NAME = "_acme_challenge"
)

# get all records on domain
# curl -H "X-Api-Key: $APIKEY" https://dns.api.gandi.net/api/v5/domains/hiller.pro/records | ConvertFrom-Json


# use the curl flag --trace-ascii <logfile> for tracing issues
# curl -v is good for headers only

# certbot certonly --manual --preferred-challenges dns -d hiller.pro --agree-tos --redirect --hsts --uir
@{
	"rrset_name"	= "$RECORD_NAME"
	"rrset_type"	= "TXT"
	"rrset_ttl"		= "300"
	"rrset_values"	= @( "$CHALLENGE_VALUE" )
} | ConvertTo-Json -Compress | C:\Users\ehiller\AppData\Local\omega\bin\curl.cmd `
	-X POST -H "Content-Type: application/json" `
	-H "X-Api-Key: $APIKEY" `
	-d "@-" `
	https://dns.api.gandi.net/api/v5/domains/$DOMAIN/records



