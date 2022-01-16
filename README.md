# Foo
A test application that implements a seed data, recurrence job for updating all entries at once
and provides API for fetching records by given criteria.

To start your Foo app:

  * Install dependencies with `mix deps.get`
  * Create, migrate and seed your database with 1_000_000 users, use `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can fetch users and last timestamp by calling [`localhost:3000`](http://localhost:3000) from your browser.

## Overview

`Foo.Generator` - responsible for API and recurrence job
`Foo.Time` - module for different time-related manipulations
`Foo.Users` - a context that wraps operations with Foo.User schema
`Foo.User.Query` - a module that handles Ecto queries for users

## Misc
As I understood the goal of the tasks was to create a process that can finish a recurrence job of
Update a big set of records in an adequate time (at least less than recurrence job interval time) for the synchronous requests to GenServer.

Since it was not a `real` task and business requirements are not clear I've tried as
much as possible to write code in a way that new functionality can be added easily later.
Considering this you may notice some modules (Users.Query, Foo.Users, Foo.Time, configuration for Foo.Generator) that is not needed in the scale of this task
but they may be useful if you need to extend API, add configure, other functionality later.

Some specs are missing.
I've added some naive moduledocs.
Tests are in place but maybe it's missing some edge case scenarios.
