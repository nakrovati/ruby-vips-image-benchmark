require "image_processing/vips"
require "benchmark"
require "fileutils"

Vips.block_untrusted(false)

SOURCE_DIR = "./src-images"
OUTPUT_DIR = "./out-images"

FORMATS = {
  "jpg"  => 82,
  "webp" => 78,
  "avif" => 55,
  "jxl"  => 85
}.freeze

SUPPORTED_EXTENSIONS = %w[
  .jpg .jpeg .png .webp .avif .jxl
  .tif .tiff .bmp .gif .heic
].freeze

images = Dir.glob("#{SOURCE_DIR}/*")
  .select { |path| File.file?(path) }
  .select { |path| SUPPORTED_EXTENSIONS.include?(File.extname(path).downcase) }
  .sort

raise "No images found in #{SOURCE_DIR}" if images.empty?

FORMATS.each_key do |format|
  FileUtils.mkdir_p("#{OUTPUT_DIR}/#{format}")
end

total_times = Hash.new(0.0)
total_sizes = Hash.new(0)

images.each do |source|
  image_name = File.basename(source, File.extname(source))

  puts "\n#{File.basename(source)}"

  FORMATS.each do |format, quality|
    destination = "#{OUTPUT_DIR}/#{format}/#{image_name}.#{format}"

    time = Benchmark.realtime do
      ImageProcessing::Vips
        .source(source)
        .resize_to_limit(1200, nil)
        .convert(format)
        .saver(quality:)
        .call(destination:)
    end

    size = File.size(destination)

    total_times[format] += time
    total_sizes[format] += size

    puts format.ljust(5) +
         " #{format("%.4f", time)} s" +
         " | #{size} bytes"
  end
end

puts "\n" + "=" * 60
puts "SUMMARY"
puts "=" * 60

FORMATS.each_key do |format|
  size = total_sizes[format]

  puts format.ljust(5) +
       " | time: #{format("%.4f", total_times[format])} s" +
       " | size: #{size} bytes" +
       " (#{format("%.2f", size / 1024.0 / 1024.0)} MiB)"
end

puts "\nDirectories:"

FORMATS.each_key do |format|
  directory_size = Dir
    .glob("#{OUTPUT_DIR}/#{format}/**/*")
    .select { |path| File.file?(path) }
    .sum { |path| File.size(path) }

  puts format.ljust(5) +
       " | #{directory_size} bytes" +
       " (#{format("%.2f", directory_size / 1024.0 / 1024.0)} MiB)"
end