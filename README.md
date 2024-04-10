# mason ai

**Goal**: To create an LLM that takes a description and name of a model to generate serialized part and property data that can be loaded into the Roblox game engine.

**How**: By serializing popular models on the Roblox marketplace, and saving the data to train a transformer on it.

**Example**:
```bash
# desired input/output
> Cozy House. A very cozy and nice home.
> P[42;1;0.5,6.3,0.7;...]-P[...]-P[...]-P[...]-...

> Wooden Chair. Round, wooden chair.
> P[12;0;0.0,6.1,0.9;...]-P[...]-P[...]-P[...]-...
```