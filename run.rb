load "method.rb"

# list of files to be loaded
dir1500 = "results/dir1500.results"
okapi = "results/okapi.results"
evaluation = "results/evaluation.results"

t1 = Time.now
create_rel_results(dir1500)
create_rel_results(okapi)
t2 = Time.now
puts "Total processing time: #{t2-t1} seconds"
