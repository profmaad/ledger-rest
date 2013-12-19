# ledger-rest

> REST assured your finances are in good hands ;-)

`ledger-rest` is a REST webservice to access your ledger account data.

## What you need

*Please Note:* You will have to install ledger with the `--python` flag, because
currently ledger-rest uses a most ugly hack, that uses python to query
complete xacts for the `GET /transactions` endpoint.

To install and run ledger-rest, just clone this repository and run
`bundle`. Everything you need will be installed by bundler. Then run
`rackup` to start ledger rest.

The configuration resides in `ledger-rest.yml` have a look at the
example file in the repository root.

## What already works

* query balance reports (``GET /balance``)
* query register reports (``GET /register``)
* query budget reports (``GET /budget``)
* query a transactions list (``GET /transactions``)
* query the ledger and ledger-rest version (``GET /version``)

# Contribute

All help is welcome. Just fork and send pull requests.

## What needs to be done

### Replace the ugly transactions retrieval

Replace the ugly transactions retrieval by a better method. This is
only implemented because I need to get out the specific data fast. Via
commandline only I do not get the full transactions with all their
posts when I add a query. Only `ledger print` would do what I want,
but then I would have to parse the transactions myself.

The ideal solution would be to implement ruby ledger bindings, but I
am not familiar enough with the inner workings of ledger.

# License

Copyright (c) 2012 Max Wolter, Arthur Andersen

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
