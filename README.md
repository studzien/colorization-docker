# Colorization in Docker

[Colorful Image Colorization](https://github.com/richzhang/colorization) wrapped
in a Docker build, to make playing with colorizing single images easier.

To tweak how the model is used play with the attached `colorize.py` file.

## Usage

### Building a Docker image

```
make build
```

### Colorizing a single image

```
make colorize input=$(pwd)/lena_bw.png output=lena_colorized.png
```
