
$APIKEY = "API KEY FROM GANDI"
$DOMAIN = "hiller.pro"

# get all records on domain
# curl -H "X-Api-Key: $APIKEY" https://dns.api.gandi.net/api/v5/domains/hiller.pro/records | ConvertFrom-Json


# use the curl flag --trace-ascii <logfile> for tracing issues
# curl -v is good for headers only

$CHALLENGE_VALUE = "value" # SHA String from running 
# certbot certonly --manual --preferred-challenges dns -d hiller.pro --agree-tos --redirect --hsts --uir
$RECORD_NAME = "_acme-challenge" # DO NOT ADD THE MAIN DOMAIN, GANDI DOES THIS FOR US!
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



