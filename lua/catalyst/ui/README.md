# Overview

The UI module exposes multiple functions that initiate dialogues, requiring a state object to be passed in.

# `ui_ctl.lua`

The UI relies on `ui_ctl.lua` for controlling the flow of execution through coroutines. This puts restrictions on the way all component functions are written.

# Controller

The module implements a flow controller, which is responsible for handling the execution of component functions and error handling, as well as multiple component spawners, whose job is to define order in which UI components appear.
