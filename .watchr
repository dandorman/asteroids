sources = %w[util number canvas line segment ray thing world ship exhaust bullet asteroid app].map {|s| "app/#{s}.coffee" }.join(' ')
compile = "coffee -c -o public -j asteroids.js #{sources}" 

watch 'app/.*\.coffee' do
  puts compile
  system compile
end