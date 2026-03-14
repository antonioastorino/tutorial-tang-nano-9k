# Setup FPGA toolchain on MacOS

## Use Ubuntu X86 docker image

```
brew install container
container system start
container build --tag fpga-dev --file Dockerfile .
container run -u user -it fpga-dev bash
```
