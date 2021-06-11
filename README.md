To reproduce failed case:

``` sh
cd blinky
export MIX_TARGET=rpi3
mix deps.get
mix compile # compiles everything
mix compile # compiles blinky
mix compile # compiles blinky
```

To reproduce working case:
``` sh
cd blinky
export MIX_TARGET=rpi3
# edit mix.exs to use nerves 1.6.3
mix deps.get
mix compile # compiles everything
mix compile # compiles no modules
```
