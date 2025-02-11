#output
./url_checker.sh https://<site>
URL check passed:
✓ Status code is 200
✓ Content contains 'success'

#error output
./url_checker.sh https://<site>
URL check failed:
✗ Status code is not 200 (Got: 404)
Running all diagnostics for <site>...
1. Running ping test...
2. Running traceroute...
3. Running NSLookup...
4. Checking SSL Certificate...
✓ SSL Certificate check completed
Check diagnostics.log for certificate details
All diagnostics completed - check diagnostics.log for details
