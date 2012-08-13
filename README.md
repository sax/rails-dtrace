Note that this branch is deprecated, as Rails 4 now allows you to
support both Evented and Timed notifications in the same subscriber,
with priority to Evented.

This means that you can use the master branch in either version of
Rails. If it supports entry/exit probes, it will expose those. Otherwise
it will expose an event probe with a time diff as one of the probe
arguments.
