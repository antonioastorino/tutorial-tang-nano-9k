# Setup FPGA toolchain on MacOS

### Install `yosys`
```
brew install \
    yosys \
    openfpgaloader \
    xdot \
    verialtor
```

> Note: xdot is required by yosys when running `show`


### Install `nextpnr`
```
git clone --depth=1 git@github.com:YosysHQ/nextpnr.git
cd nextpnr
git submodule update --init --recursive
```

Follow the instructions on [nextpnr page](https://github.com/YosysHQ/nextpnr).

With focus on Tang Nano boards, run

```
pip3 install apycula --break-system-packages
mkdir -p build && cd build
cmake .. -DARCH="himbaechel" -DHIMBAECHEL_UARCH="gowin"
make -j$(nproc)
sudo make install
```

## Use Ubuntu X86 docker image

```
brew install container
container system start
container build --tag fpga-dev --file Dockerfile .
container run -it fpga-dev bash
```

## Check VHDL using GHDL

## Resources
[Example toolchain](https://github.com/mrLSD/fpga/blob/master/sipeed-tangnano-9k/lcd_screen/Makefile)
[Example projects](https://github.com/sipeed/TangNano-9K-example/tree/main)
