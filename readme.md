# Traces

Capture nested traces during code execution in a vendor agnostic way.

[![Development Status](https://github.com/socketry/traces/workflows/Test/badge.svg)](https://github.com/socketry/traces/actions?workflow=Test)

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

  - [traces-backend-open\_telemetry](https://github.com/socketry/traces-backend-open_telemetry) — A backend for submitting traces to [OpenTelemetry](https://github.com/open-telemetry/opentelemetry-ruby), including [ScoutAPM](https://github.com/scoutapp/scout_apm_ruby).
  - [traces-backend-datadog](https://github.com/socketry/traces-backend-datadog) — A backend for submitting traces to [Datadog](https://github.com/DataDog/dd-trace-rb).
  - [metrics](https://github.com/socketry/metrics) — A metrics interface which follows a similar pattern.
