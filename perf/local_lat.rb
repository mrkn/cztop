#! /usr/bin/env ruby
require "cztop"
require "benchmark"

if ARGV.size != 3
  abort <<MSG
Usage: #{$0} <bind-to> <message-size> <roundtrip-count>
MSG
end

ENDPOINT = ARGV[0]
MSG_SIZE = Integer(ARGV[1]) # bytes
ROUNDTRIP_COUNT = Integer(ARGV[2]) # round trips
MSG = "X" * MSG_SIZE

s = CZTop::Socket::REP.new(ENDPOINT)

# synchronize
s.wait
s.signal

tms = Benchmark.measure do
  ROUNDTRIP_COUNT.times do
    msg = s.receive
    raise "wrong message size" if msg.content_size != MSG_SIZE
    s << msg
  end
end

elapsed = tms.real
latency = elapsed / (ROUNDTRIP_COUNT * 2) * 1_000_000
puts "message size: #{MSG_SIZE} [B]"
puts "roundtrip count: #{ROUNDTRIP_COUNT}"
puts "elapsed time: %.3f [s]" % elapsed
puts "average latency: %.3f [us]" % latency
