# Image Format Benchmark

This script compares processing time and output size for JPEG, WebP, AVIF, and
JXL images. Images are resized to a maximum width of 1200 pixels.

Place source images in `src-images/`, then install the dependencies:

```sh
bundle install
```

Run the project from the repository root:

```sh
ruby bench.rb
```

Results are saved in `out-images/`; processing times and file sizes are printed
to the terminal. The system `libvips` library must be installed.