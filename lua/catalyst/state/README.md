# Overview

State module exposes a state object and methods for manipulating on it. The object is fully self contained, meaning that multiple instances of the module can coexist completely separately if supplied with multiple state objects.

# Init.lua

Main file exposes `setup`, which generates a state object and exposes all necessary methods through it. State should be accessed through the object's methods for all components to work properly in tandem, though for testing purposes any module can be used separately.

# Functional vs Stateful

Modules requiring internal state mostly only expose `setup` function, called by `init.lua` during state initialization. The structure of such modules mimics OOP classes. Stateless modules (most notably persistent storage) expose multiple functions, which are wrapped and re-exposed from the state object. Session object is the most important wrap.

# Session

The module provides access to session storage, as well as wrapping other modules to add additional side effects to stateless functions.
