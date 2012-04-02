load "method.rb"
load "array.rb"

# list of files to be loaded
dir1500 = "results/dir1500.results"
okapi = "results/okapi.results"
evaluation = "results/evaluation.results"

# local variables
d_rel_h = {}
o_rel_h = {}
d_eval  = {}
o_eval  = {}
d_mean_eval = {}
o_mean_eval = {}

t1 = Time.now
# create relevant results file from both results
create_rel_results(dir1500)
create_rel_results(okapi)

# build relevant score hash for both results
d_rel_h = build_rel_h(dir1500)
o_rel_h = build_rel_h(okapi)

# update with scores for various evaluation metrics
d_eval = evaluate_scores(d_rel_h)
o_eval = evaluate_scores(o_rel_h)

# get mean evaluation results for both dir1500 and okapi
d_mean_eval = get_mean_eval(d_eval)
o_mean_eval = get_mean_eval(o_eval)

File.open(evaluation, "w") { |f|
  f.write "topicID,avg_prec,prec_at_1,prec_at_10,dcg,ndcg,run_tag\n"
  d_eval.each do |a|
    f.write "#{a[0]},#{a[1][:avg_prec]},#{a[1][:prec_at_1]}," +
      "#{a[1][:prec_at_10]},#{a[1][:dcg]},#{a[1][:ndcg]},dir1500\n"
  end
  f.write "average,#{d_mean_eval[:avg_prec]}," + 
    "#{d_mean_eval[:prec_at_1]},#{d_mean_eval[:prec_at_10]}," +
    "#{d_mean_eval[:dcg]},#{d_mean_eval[:ndcg]},dir1500\n"
  o_eval.each do |a|
    f.write "#{a[0]},#{a[1][:avg_prec]},#{a[1][:prec_at_1]}," +
      "#{a[1][:prec_at_10]},#{a[1][:dcg]},#{a[1][:ndcg]},okapi\n"
  end
  f.write "average,#{o_mean_eval[:avg_prec]}," + 
    "#{o_mean_eval[:prec_at_1]},#{o_mean_eval[:prec_at_10]}," +
    "#{o_mean_eval[:dcg]},#{o_mean_eval[:ndcg]},okapi\n"
}

t2 = Time.now
puts "Total processing time: #{t2-t1} seconds"
