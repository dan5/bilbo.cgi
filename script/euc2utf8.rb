#!/usr/bin/env ruby

Dir.glob('data/*').each do |file|
  `iconv -f euc-jp -t utf-8 #{file} > out/#{file}`
end
