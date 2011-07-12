sources = %w[util number canvas line segment ray thing world ship exhaust bullet explosion asteroid app].map {|s| "lib/#{s}.coffee" }.join(' ')
compile = "coffee -c -o public -j asteroids.js #{sources}" 

watch 'lib/.*\.coffee' do
  puts compile
  system compile
end
