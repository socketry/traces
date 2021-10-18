# Traces

Capture nested traces during code execution in a vendor agnostic way.

[![Development Status](https://github.com/socketry/traces/workflows/Development/badge.svg)](https://github.com/socketry/traces/actions?workflow=Development)

## Features

  - Zero-overhead if tracing is disabled and minimal overhead if enabled.
  - Small opinionated interface with standardised semantics, consistent with the [W3C Trace Context Specification](https://github.com/w3c/trace-context).

## Usage

Please see the [project documentation](https://socketry.github.io/traces).

## Contributing

We welcome contributions to this project.

1.  Fork it
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create new Pull Request

## See Also

- [traces-backend-open_telemetry](https://github.com/socketry/traces-backend-open_telemetry) — A backend for submitting traces to [OpenTelemetry](https://github.com/open-telemetry/opentelemetry-ruby), including [ScoutAPM](https://github.com/scoutapp/scout_apm_ruby).
- [traces-backend-datadog](https://github.com/socketry/traces-backend-datadog) — A backend for submitting traces to [Datadog](https://github.com/DataDog/dd-trace-rb).
- [metrics](https://github.com/socketry/metrics) — A metrics interface which follows a similar pattern.

## License

Released under the MIT license.

Copyright, 2021, by [Samuel G. D. Williams](http://www.codeotaku.com).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
